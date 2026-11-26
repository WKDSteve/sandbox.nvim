#!/usr/bin/env node
// Claude Code PreToolUse hook (Bash): in a cloud session (CLAUDE_CODE_REMOTE is set) a `git push` that would move
// `main` is refused with exit 2: the maintainer's rule is that a cloud session pushes its own claude/... branch and a
// local session lands it on main. Locally the settings entry does not even start node; run without CLAUDE_CODE_REMOTE,
// this script allows all. It guards against mistakes, not intent: a session can edit .claude/ itself. The copy lives
// in public repositories too, so it names no rule by the id of a private ruleset.
//
// Source of truth: $NVIM_CONFIG_DIR/docs/NOTES/CDX/hooks/cloud-push-guard.mjs, installed into a repository's
// .claude/hooks/ by docs/NOTES/CDX/install-cloud-push-guard.js. Change it there, never in a repository's copy.

import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import path from 'node:path';

const PROTECTED = new Set(['main']);
const SHELLS = new Set(['bash', 'sh', 'zsh', 'dash', 'ksh']);
// Words in front of a command that run the rest as the command: skipped with their options (and a duration/number).
const WRAPPERS = new Set(['command', 'builtin', 'exec', 'nohup', 'sudo', 'time', 'nice', 'timeout', 'stdbuf', 'env']);
const MAX_DEPTH = 4;

/**
 * Split a shell command line into simple commands (arrays of words). Quotes and backslashes are resolved the way a
 * POSIX shell would; `&&`, `||`, `;`, `|`, `&`, newlines, parentheses and backticks end a command; redirections
 * (`2>&1`, `> file`) are dropped. The text of a double-quoted word with a command substitution is kept in `nested`,
 * so it is checked as a command line too.
 * @param {string} line
 * @returns {{ words: string[], nested: string[] }[]}
 */
function splitCommands(line) {
  const commands = [];
  let words = [];
  let nested = [];
  let word = null;
  let dropNext = false;
  const endWord = () => {
    if (word !== null && !dropNext) words.push(word);
    if (word !== null) dropNext = false;
    word = null;
  };
  const endCommand = () => {
    endWord();
    if (words.length > 0) commands.push({ words, nested });
    words = [];
    nested = [];
    dropNext = false;
  };
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (c === "'") {
      const end = line.indexOf("'", i + 1);
      const stop = end === -1 ? line.length : end;
      word = (word ?? '') + line.slice(i + 1, stop);
      i = stop;
    } else if (c === '"') {
      let text = '';
      let j = i + 1;
      for (; j < line.length && line[j] !== '"'; j++) {
        if (line[j] === '\\' && j + 1 < line.length && '"\\$`'.includes(line[j + 1])) {
          text += line[++j];
        } else {
          text += line[j];
        }
      }
      if (/\$\(|`/.test(text)) nested.push(text.replace(/\$\(|`|\)/g, ' ; '));
      word = (word ?? '') + text;
      i = j;
    } else if (c === '\\') {
      if (i + 1 < line.length && line[i + 1] !== '\n') word = (word ?? '') + line[i + 1];
      i++;
    } else if (c === '>' || c === '<') {
      // `2>&1`, `>&2`, `>>log`, `< in`: drop the file descriptor in front and the target after it
      if (word !== null && /^\d+$/.test(word)) word = null;
      endWord();
      let j = i + 1;
      while (j < line.length && (line[j] === '>' || line[j] === '|')) j++;
      if (line[j] === '&') {
        j++;
        while (j < line.length && /[\d-]/.test(line[j])) j++;
      } else {
        dropNext = true;
      }
      i = j - 1;
    } else if (c === ' ' || c === '\t') {
      endWord();
    } else if (c === '#' && word === null) {
      const end = line.indexOf('\n', i);
      i = end === -1 ? line.length : end - 1;
    } else if (';&|\n()`'.includes(c)) {
      endCommand();
    } else if (c === '$' && line[i + 1] === '(') {
      endCommand();
      i++;
    } else {
      word = (word ?? '') + c;
    }
  }
  endCommand();
  return commands;
}

/** Run git in `cwd` and return its trimmed output, or null when it fails. */
function git(cwd, args) {
  try {
    return execFileSync('git', args, { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
  } catch {
    return null;
  }
}

/** The branch a push destination names: `refs/heads/x` and `x` are both `x`. */
function branchOf(ref) {
  return ref.startsWith('refs/heads/') ? ref.slice('refs/heads/'.length) : ref;
}

/** True when a destination is a protected branch, or a pattern that matches one (`refs/heads/*`). */
function isProtected(dst) {
  if (PROTECTED.has(dst)) return true;
  if (!dst.includes('*')) return false;
  const re = new RegExp(`^${dst.replace(/[.+?^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '.*')}$`);
  return [...PROTECTED].some((b) => re.test(b) || re.test(`refs/heads/${b}`));
}

/**
 * Why a `git push` with these arguments (the words after `push`) would move a protected branch, or null.
 * @param {string[]} args
 * @param {string} cwd the directory git would run in
 * @returns {string | null}
 */
function pushVerdict(args, cwd) {
  const positional = [];
  let remote = null;
  let del = false;
  let dryRun = false;
  let everything = null;
  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '--') {
      positional.push(...args.slice(i + 1));
      break;
    }
    if (!a.startsWith('-') || a === '-') {
      positional.push(a);
      continue;
    }
    if (a === '--all' || a === '--branches' || a === '--mirror') everything = a;
    else if (a === '--delete') del = true;
    else if (a === '--dry-run') dryRun = true;
    else if (a === '--repo') remote = args[++i] ?? null;
    else if (a.startsWith('--repo=')) remote = a.slice('--repo='.length);
    else if (['--push-option', '--receive-pack', '--exec'].includes(a)) i++;
    else if (/^-[a-zA-Z]+$/.test(a)) {
      if (a.includes('d')) del = true;
      if (a.includes('n')) dryRun = true;
      if (a.endsWith('o')) i++;
    }
  }
  if (dryRun) return null;
  if (everything) return `\`${everything}\` pushes main too`;
  if (remote === null && positional.length > 0) remote = positional.shift();

  let current;
  const currentBranch = () => {
    if (current === undefined) current = git(cwd, ['symbolic-ref', '--short', '-q', 'HEAD']);
    return current;
  };
  const target = (spec) => {
    if (del) return branchOf(spec);
    const s = spec.startsWith('+') ? spec.slice(1) : spec;
    const colon = s.indexOf(':');
    let dst = colon === -1 ? s : s.slice(colon + 1);
    if (colon !== -1 && dst === '') dst = s.slice(0, colon);
    if (dst === 'HEAD' || dst === '@') dst = currentBranch() ?? dst;
    return branchOf(dst);
  };

  let refspecs = positional;
  const implicit = refspecs.length === 0;
  if (implicit) {
    const configured = git(cwd, ['config', '--get-all', `remote.${remote ?? 'origin'}.push`]);
    refspecs = configured ? configured.split(/\r?\n/) : [];
  }
  for (const spec of refspecs) {
    const dst = target(spec);
    if (isProtected(dst)) return `\`${spec}\` ${del ? 'deletes' : 'targets'} ${dst}`;
  }
  if (implicit && refspecs.length === 0) {
    const branch = currentBranch();
    if (branch && PROTECTED.has(branch)) return `the current branch is ${branch}`;
    if (branch) {
      const mode = git(cwd, ['config', 'push.default']);
      const merge = git(cwd, ['config', `branch.${branch}.merge`]);
      if ((mode === 'upstream' || mode === 'tracking') && merge && PROTECTED.has(branchOf(merge))) {
        return `push.default=${mode} sends ${branch} to its upstream ${branchOf(merge)}`;
      }
    }
  }
  return null;
}

/**
 * The first reason a command line would push to a protected branch, or null.
 * @param {string} line
 * @param {string} cwd
 * @param {number} depth
 * @returns {string | null}
 */
function verdict(line, cwd, depth) {
  if (depth > MAX_DEPTH) return null;
  let dir = cwd;
  for (const { words, nested } of splitCommands(line)) {
    for (const inner of nested) {
      const why = verdict(inner, dir, depth + 1);
      if (why) return why;
    }
    let i = 0;
    for (;;) {
      const w = words[i];
      if (w === undefined) break;
      if (/^[A-Za-z_][A-Za-z0-9_]*=/.test(w) || w === '{' || w === '}' || w === '!') {
        i++;
      } else if (WRAPPERS.has(w)) {
        i++;
        while (i < words.length && (words[i].startsWith('-') || /^\d/.test(words[i]) || words[i].includes('='))) i++;
      } else {
        break;
      }
    }
    const name = words[i] === undefined ? '' : path.basename(words[i]).replace(/\.exe$/i, '');
    if (name === 'cd' && words[i + 1] && !words[i + 1].startsWith('-')) {
      dir = path.resolve(dir, words[i + 1]);
      continue;
    }
    if (SHELLS.has(name)) {
      const flag = words.findIndex((w, k) => k > i && /^-[a-z]*c[a-z]*$/.test(w));
      if (flag !== -1 && words[flag + 1] !== undefined) {
        const why = verdict(words[flag + 1], dir, depth + 1);
        if (why) return why;
      }
      continue;
    }
    if (name === 'eval') {
      const why = verdict(words.slice(i + 1).join(' '), dir, depth + 1);
      if (why) return why;
      continue;
    }
    if (name !== 'git') continue;
    let gitDir = dir;
    let k = i + 1;
    while (k < words.length && words[k].startsWith('-')) {
      const opt = words[k];
      if (opt === '-C') gitDir = path.resolve(gitDir, words[++k] ?? '.');
      else if (['-c', '--git-dir', '--work-tree', '--namespace', '--config-env'].includes(opt)) k++;
      k++;
    }
    if (words[k] !== 'push') continue;
    const why = pushVerdict(words.slice(k + 1), gitDir);
    if (why) return why;
  }
  return null;
}

function main() {
  if (!process.env.CLAUDE_CODE_REMOTE) return 0;
  let input;
  try {
    input = JSON.parse(readFileSync(0, 'utf8'));
  } catch {
    return 0;
  }
  const command = input?.tool_input?.command;
  if (input?.tool_name !== 'Bash' || typeof command !== 'string') return 0;
  const why = verdict(command, input.cwd || process.env.CLAUDE_PROJECT_DIR || process.cwd(), 0);
  if (!why) return 0;
  process.stderr.write(
    `cloud-push-guard: a cloud session never pushes to main (${why}). ` +
      'Push your own branch instead, e.g. `git push -u origin HEAD:claude/<topic>`; a local session lands it on main.\n',
  );
  return 2;
}

process.exitCode = main();
