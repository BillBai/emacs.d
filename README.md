# Emacs Configuration

Personal Emacs setup built on [Emacs Bedrock](https://codeberg.org/ashton314/emacs-bedrock) 1.5.0.
Emacs 30.2 (pgtk build) on Arch Linux, KDE/Wayland.

**Design goals**

- **AI-free.** No LLM packages (gptel, copilot, codeium, aider, ...). Completion is
  explicit: nothing pops up until you press `TAB`. The point is to keep writing code by hand.
- **Small and readable.** Bedrock is a *template*, not a dependency — every file here was
  copied in and is mine to edit. No module system, no `doom sync`, no framework layer.
- **Vim keys** via evil, coming from Doom.
- **Languages:** C/C++, Rust, JS/TS, Python, and Scheme (SICP, via Racket).

---

## Layout

```
~/.config/emacs/
├── early-init.el          frame defaults, GC tuning (runs before the GUI exists)
├── init.el                main config; loads everything below at the bottom
├── extras/                copied verbatim from Bedrock, then edited
│   ├── base.el            vertico, consult, corfu, embark, cape, avy, eat, wgrep
│   ├── dev.el             magit, eglot, tempel, markdown/yaml/json modes
│   ├── vim-like.el        evil, evil-collection, evil-commentary
│   ├── writer.el          olivetti (centred prose), jinx (spell-check, text-mode only)
│   └── org.el, email.el, researcher.el              ← present but NOT loaded
├── lisp/
│   ├── programming.el     mine: tree-sitter grammars, major modes, eglot, Racket
│   └── keys.el            mine: the SPC leader map
├── templates              tempel snippet definitions
├── custom.el              written by Emacs (gitignored — machine-local)
├── elpa/  eln-cache/  tree-sitter/                  ← build output, gitignored
└── README.md              this file
```

**Load order** (matters when a setting seems to be ignored):

```
early-init.el
  → init.el (top: package archives, defaults, UI, theme, fonts)
    → extras/base.el
    → extras/dev.el
    → extras/vim-like.el
    → extras/writer.el
    → lisp/programming.el
    → lisp/keys.el         ← last; needs evil-window-map to exist
  → custom.el              ← loaded last, so Customize settings win
```

Anything loaded later overrides anything loaded earlier. `base.el`, for example, replaces
`completion-styles` that `init.el` set higher up.

---

## Keybindings

### Discovery — use these instead of memorizing the rest

| Key | What it does |
|---|---|
| `C-h k` *then a key* | What does this key do? Also shows the key Emacs *actually received* |
| `C-h w` *command* | Which key runs this command? |
| `C-h v` *variable* | Value + documentation. **No documentation = you misspelled it** |
| `C-h f` *function* | Function documentation |
| `C-h m` | Every keybinding active in the current buffer |
| *(pause after a prefix)* | which-key pops up all continuations |

### Leader key — `SPC`

Laid out to match Doom, so the muscle memory carries over. Defined in `lisp/keys.el`.
Pause after `SPC` and which-key lists everything — none of this needs memorizing.

| Key | What it does |
|---|---|
| `SPC SPC` | Find file in project |
| `SPC .` | Find file |
| `SPC ,` | Switch buffer |
| `SPC :` | `M-x` |
| `SPC /` | ripgrep the project |

| `SPC b` — buffer | | `SPC f` — file | |
|---|---|---|---|
| `b` | Switch buffer | `f` | Find file |
| `k` | Kill this buffer | `s` | **Save** |
| `s` | Save | `S` | Save as |
| `r` | Revert from disk | `r` | Recent files |
| `i` | ibuffer | `d` | dired |
| | | `p` | Find a file in the config dir |

| `SPC s` — search | | `SPC g` — git | |
|---|---|---|---|
| `s` | Search this buffer | `g` | Magit status |
| `p` | Search the project | `b` | Blame |
| `i` | imenu | `l` | Log for this file |
| `o` | Outline | | |

Three prefixes are existing Emacs keymaps rather than hand-written menus, so they stay in
sync with upstream for free and cost one line each:

| Key | Is |
|---|---|
| `SPC h` | the whole of `C-h` (`help-map`) |
| `SPC p` | the whole of `C-x p` (`project-prefix-map`) |
| `SPC w` | evil's whole window map (`evil-window-map`) |

`SPC` is bound in `evil-motion-state-map`, which stays active in normal, visual and operator
states as well as in read-only buffers (dired, magit, help, compilation). Binding it in
`evil-normal-state-map` instead is the usual reason a hand-rolled leader "works sometimes".

### Evil

Standard vim, plus:

| Key | What it does |
|---|---|
| `u` / `C-r` | Undo / redo (uses the built-in `undo-redo`, no undo-tree needed) |
| `C-u` / `C-d` | Scroll up / down half a page |
| `gcc` | Comment/uncomment current line (evil-commentary) |
| `gc` + motion | `gc3j`, `gcap`, `gci{` — comment over any motion |
| `gc` in visual | Comment the selection |
| `%` | Jump to matching paren |

`evil-collection` is enabled for `dired`, `magit`, `help`, `compile`, `xref` only.
Any other read-only buffer still uses native Emacs keys. Add more modes in
`extras/vim-like.el`; see `C-h v evil-collection-mode-list` for what is available.

Emacs keys still work in normal state — evil does not remove them.

### Files, buffers, windows

| Key | What it does |
|---|---|
| `C-x C-f` | Find file |
| `C-x b` | Switch buffer (consult — shows buffers, recent files, bookmarks) |
| `C-x C-s` | Save |
| `C-x g` | **Magit status** |
| `C-<arrows>` | Move between windows |
| `C-x o` | Other window |

### Completion

| Key | What it does |
|---|---|
| `TAB` | In code: complete (corfu popup). **Nothing pops up on its own** — this is deliberate |
| `C-n` / `C-p` | Next/previous candidate in the corfu popup |
| `SPC` (in popup) | Insert a separator — lets you type `foo bar` to match `fooBarBaz` |
| `TAB` (minibuffer) | Complete |
| `M-DEL` (find-file) | Delete one path component |

Minibuffer completion is `vertico` + `orderless` (space-separated fragments, any order) +
`marginalia` (the annotations on the right).

### Search & navigation

| Key | What it does |
|---|---|
| `M-s l` / `M-s s` | Search lines in this buffer (consult-line) |
| `M-s L` | Search across all buffers |
| `M-s r` | ripgrep the project |
| `M-s o` | Jump by outline/heading |
| `M-y` | Browse the kill ring |
| `C-c j` | Jump to a visible line (avy) |
| `C-c a` | **embark-act** — context menu for whatever is under point or selected in the minibuffer |

`embark` is worth learning: in any completion list, `C-c a` gives you actions on the
candidate (open in other window, copy path, run a command on all matches, ...).

### LSP (eglot)

Starts automatically for C, C++, Rust, Python, JS, TS, TSX.

| Key | What it does |
|---|---|
| `M-.` | Go to definition (`xref-find-definitions`) |
| `M-,` | Go back |
| `M-?` | Find references |
| *(automatic)* | Function signature in the echo area (eldoc) |
| `M-x eglot-rename` | Rename a symbol project-wide |
| `M-x eglot-code-actions` | Code actions at point |
| `M-x eglot-format-buffer` | Format via the language server |
| `M-x eglot-events-buffer` | Raw traffic with the language server — first stop when LSP misbehaves |

Eglot deliberately ships **no keybindings of its own** — `eglot-mode-map` is empty apart from
one eldoc remap. `M-.` / `M-,` / `M-?` are plain `xref` bindings that eglot plugs into. If you
end up using `eglot-rename` often, bind it yourself.

Servers used: `clangd`, `rust-analyzer`, `pyright-langserver`, `typescript-language-server`.
Eglot picks these by scanning `eglot-server-programs` for the first executable that exists.

### Lisp / s-expressions

No paredit — built-ins only, on purpose.

| Key | What it does |
|---|---|
| `C-M-f` / `C-M-b` | Move over a whole s-expression |
| `C-M-u` | **Up** one level of parens (out of the current form) |
| `C-M-d` | **Down** into the next form |
| `C-M-n` / `C-M-p` | Next/previous sibling form |
| `C-M-k` | Kill the sexp after point |
| `C-M-t` | Transpose two sexps |
| `C-M-SPC` | Select the next sexp (then use evil's `d` / `y`) |
| `C-x C-e` | **Evaluate the expression before point** — the fastest way to test config changes |

`C-M-u` and `C-M-f` cover most of it. The rest can wait.

### Racket / SICP

| Key | What it does |
|---|---|
| `C-c C-c` | `racket-run` — load the file into the REPL |
| `C-c C-s` | Open the REPL |
| `M-.` | Go to definition (works into Racket's own source) |
| `C-c C-d` | Open the official docs for the identifier at point |

SICP files start with `#lang sicp` and use the `.rkt` extension. That language level
provides the MIT-Scheme-only pieces the book relies on: `cons-stream` (a special form,
so it cannot be a plain function), `true` / `false` / `nil`, `inc` / `dec`, `runtime`.
`stream-car` / `stream-cdr` are *not* provided — the book defines them in §3.5.1, and
that exercise was left intact.

`racket-xp-mode` gives cross-references, docs, and live error underlining **without** LSP,
using Racket's own `check-syntax` backend.

### Comments

| Key | What it does |
|---|---|
| `gcc` / `gc`+motion | evil-commentary (preferred) |
| `C-x C-;` | Comment/uncomment the current line |
| `M-;` | Toggle comments on the region; with no region, start a comment at end of line |

---

## Packages

| Package | Why it is here |
|---|---|
| `evil`, `evil-collection`, `evil-commentary` | Vim emulation, third-party mode keymaps, `gc` operator |
| `vertico`, `orderless`, `marginalia`, `consult`, `embark` | Minibuffer completion stack |
| `corfu`, `cape`, `kind-icon`, `corfu-terminal` | In-buffer completion (manual trigger only) |
| `avy` | Jump to any visible position |
| `magit` | Git |
| `eglot` *(built-in)* | LSP client |
| `treesit` *(built-in)* | Syntax parsing / highlighting |
| `tempel` | Snippets (definitions live in `templates`) |
| `racket-mode`, `rainbow-delimiters` | Scheme/SICP |
| `markdown-mode`, `yaml-mode`, `json-mode` | File types |
| `eat`, `wgrep` | Terminal emulation; editable grep results |
| `solarized-theme` | Theme (`solarized-gruvbox-light`) |
| `which-key` *(built-in in Emacs 30)* | Keybinding popups |

Deliberately **not** installed: `lsp-mode` (eglot is built in), `flycheck` (flymake is built in),
`projectile` (project.el is built in), `general.el` (`defvar-keymap` is enough), `undo-tree`,
`doom-modeline`, and anything that talks to an LLM.

---

## Common tasks

### Set up on a new machine

```bash
git clone <this repo> ~/.config/emacs
```

Then install the external tools:

```bash
# Arch
sudo pacman -S emacs-wayland clangd cmake pyright ruff typescript-language-server racket
rustup component add rust-analyzer
raco pkg install sicp
```

Start Emacs — packages install themselves from the `:ensure t` declarations. Then:

```
M-x bill/install-treesit-grammars
```

Tree-sitter grammars and native-compiled `.eln` files are architecture-specific and are
**not** in git; every machine builds its own.

### Add a new language

Everything lives in `lisp/programming.el`:

1. Add the grammar repo to `treesit-language-source-alist`
2. Run `M-x bill/install-treesit-grammars`
3. If the extension has no default mode (like `.rs`, `.ts`, `.tsx` did), add an entry to
   `auto-mode-alist`. If it *does* have one, add a `major-mode-remap-alist` entry instead.
   These two are not interchangeable — see Gotchas.
4. Add the mode's hook to the `eglot-ensure` list
5. Install the language server; check `C-h v eglot-server-programs` to see what eglot looks for

### Change the theme

Edit the `use-package solarized-theme` block in `init.el`. Available light variants in that
package: `solarized-light`, `solarized-light-high-contrast`, `solarized-selenized-light`,
`solarized-gruvbox-light`.

To try themes interactively, **disable the current one first** — themes stack:

```
M-x disable-theme    then    M-x load-theme
```

### Update packages

```
M-x list-packages    then    U    then    x
```

Package archives point at the TUNA mirror (`mirrors.tuna.tsinghua.edu.cn/elpa/`). Upstream
`elpa.gnu.org` is effectively unreachable from here — it timed out at 16 KB of a 188 KB index,
while the mirror served the same file in 0.27 s.

---

## Troubleshooting

| Symptom | First thing to check |
|---|---|
| A config change did nothing | Did you restart? A running daemon keeps the config it started with. `emacs --debug-init` gives a full backtrace on errors. |
| A key does nothing | `C-h k` and press it. If the echo area shows a *different* key sequence, your fingers slipped. If nothing happens at all, something outside Emacs grabbed the key (fcitx5, KDE shortcuts). |
| A setting has no effect | `C-h v` the variable name. "no documentation" means the variable does not exist — you misspelled it, and Emacs will never warn you. |
| Fonts look wrong | Put point on a character and press `C-u C-x =`. It reports the font actually used. |
| Text looks washed out | Compute the contrast ratio of foreground vs background. Solarized Light's body text is 4.13:1; gruvbox light is 10.22:1. This is measurable, not a matter of taste. |
| A file loads but nothing happens | `#` is not a comment character in Emacs Lisp; `;` is. A stray `#` aborts the *whole file* at read time, silently. |
| `.el` file changed but behaviour did not | `C-x C-e` at the end of an expression re-evaluates just that expression — no restart needed. |

---

## Gotchas (things that cost time once already)

- **`~/.emacs.d` wins over `~/.config/emacs`.** If `~/.emacs.d/` exists *at all* — even empty —
  Emacs uses it and never looks at the XDG path (`startup.el`, `startup--xdg-or-homedot`).
- **`cua-mode` was removed** from Bedrock's `init.el`. It rebinds `C-x`/`C-c` to cut/copy when a
  region is active, using a 0.2 s timing hack — so with evil (where a selection is usually live)
  `C-x` becomes unpredictable.
- **`auto-mode-alist` vs `major-mode-remap-alist`.** The first decides *which mode a filename
  gets*; the second only *rewrites a mode that was already chosen*. `.rs`, `.ts` and `.tsx` have
  no default mode in Emacs 30, so remapping alone does nothing for them.
- **`use-package` keywords split into two kinds.** `:custom`, `:bind`, `:hook`, `:mode` take
  *data* — code placed there is never evaluated, and fails silently. Anything involving `when`,
  `let` or a function call belongs in `:init` (before load) or `:config` (after load).
- **`evil-want-keybinding nil` must be set before evil loads** — hence `:init`, not `:config`.
- **`git commit -a` skips untracked files.** New files always need an explicit `git add`.
- **Enabling MELPA silently upgrades everything.** MELPA's date versions (`20260805.1130`) always
  outrank GNU ELPA's semver (`1.9`), so the whole completion stack now tracks MELPA snapshots.
  Set `package-archive-priorities` *before* installing if that is not wanted.
- **`custom.el` is gitignored**, so anything set through `M-x customize` is machine-local. To
  share a setting across machines, write it in `init.el` as code.
- **`setq` vs `setq-default`.** Many variables are buffer-local; `setq` only affects the current
  buffer. `line-spacing` is one of them.
- **Name a prefix key with `(cons "+label" keymap)`, not with which-key.** Handed a cons,
  `which-key-add-keymap-based-replacements` stores that cons as the binding verbatim
  (`which-key.el:1053`), so `("+file" . nil)` replaces the sub-keymap with nil and the entire
  prefix stops working. Its docstring says COMMAND may be nil for a prefix; that only holds for
  the deprecated string form.
- **A `.gitignore` without a trailing newline eats the next line you append.** `echo >>` glued
  `/.cache/` onto `.nfs*`, producing `.nfs*/.cache/` — a pattern that matches nothing and warns
  about nothing. `git check-ignore -v <path>` is the way to confirm a rule actually fires.

---

## Upstream

Bedrock is vendored, not depended on. The first commit (`vendor emacs-bedrock`) is an
unmodified copy, so `git diff <that commit> -- init.el` shows exactly what has been changed.
A reference clone lives at `~/Workspace/emacs-bedrock` for comparison with future releases.
