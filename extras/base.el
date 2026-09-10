;;; -*- lexical-binding: nil; -*-
;;; Emacs Bedrock
;;;
;;; Extra config: Base enhancements

;;; Usage: Append or require this file from init.el to enable various UI/UX
;;; enhancements.
;;;
;;; The consult package in particular has a vast number of functions that you
;;; can use as replacements to what Emacs provides by default. Please see the
;;; consult documentation for more information and help:
;;;
;;;     https://github.com/minad/consult
;;;
;;; In particular, many users may find `consult-line' to be more useful to them
;;; than isearch, so binding this to `C-s' might make sense. This is left to the
;;; user to configure, however, as isearch and consult-line are not equivalent.

;;; Contents:
;;;
;;;  - Motion aids
;;;  - Power-ups: Embark and Consult
;;;  - Minibuffer and completion
;;;  - Misc. editing enhancements

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Motion aids
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package avy
  :ensure t
  :demand t
  :bind (("C-c j" . avy-goto-line)
         ("s-j"   . avy-goto-char-timer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Power-ups: Embark and Consult
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Consult: Misc. enhanced commands
(use-package consult
  :ensure t
  :bind (
         ;; Drop-in replacements
         ("C-x b" . consult-buffer)     ; orig. switch-to-buffer
         ("M-y"   . consult-yank-pop)   ; orig. yank-pop
         ;; Searching
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)       ; Alternative: rebind C-s to use
         ("M-s s" . consult-line)       ; consult-line instead of isearch, bind
         ("M-s L" . consult-line-multi) ; isearch to M-s s
         ("M-s o" . consult-outline)
         ;; Isearch integration
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)   ; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history) ; orig. isearch-edit-string
         ("M-s l" . consult-line)            ; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)      ; needed by consult-line to detect isearch
         )
  :config
  ;; Narrowing lets you restrict results to certain groups of candidates
  (setq consult-narrow-key "<"))

(use-package embark-consult
  :ensure t)

;; Embark: supercharged context-dependent menu; kinda like a
;; super-charged right-click.
(use-package embark
  :ensure t
  :demand t
  :after (avy embark-consult)
  :bind (("C-c a" . embark-act))        ; bind this to an easy key to hit
  :init
  ;; Add the option to run embark when using avy
  (defun bedrock/avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  ;; After invoking avy-goto-char-timer, hit "." to run embark at the next
  ;; candidate you select
  (setf (alist-get ?. avy-dispatch-alist) 'bedrock/avy-action-embark))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer and completion
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Vertico: better vertical completion for minibuffer commands
(use-package vertico
  :ensure t
  :init
  ;; You'll want to make sure that e.g. fido-mode isn't enabled
  (vertico-mode))

;; [bill] M-DEL eats a whole path component at once during find-file.
(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
              ("M-DEL" . vertico-directory-delete-word)))

;; Marginalia: annotations for minibuffer
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

;; Corfu: Popup completion-at-point
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode 1)
  :bind
  (:map corfu-map
        ("SPC" . corfu-insert-separator)
        ("C-n" . corfu-next)
        ("C-p" . corfu-previous))
  :config
  (corfu-history-mode 1)
  ;; [bill] corfu-history-mode only sorts by past usage; without this the
  ;; history is thrown away on exit. savehist is already on (init.el).
  (add-to-list 'savehist-additional-variables 'corfu-history))

;; Part of corfu
(use-package corfu-popupinfo
  :after corfu
  :ensure nil
  :hook (corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay '(0.25 . 0.1))
  (corfu-popupinfo-hide nil)
  :config
  (corfu-popupinfo-mode))

;; Make corfu popup come up in terminal overlay
(use-package corfu-terminal
  :if (and (< emacs-major-version 31) (not (display-graphic-p)))
  :ensure t
  :config
  (corfu-terminal-mode))

;; Fancy completion-at-point functions; there's too much in the cape package to
;; configure here; dive in when you're comfortable!
(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;; Pretty icons for corfu
(use-package kind-icon
  :if (display-graphic-p)
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package eshell
  :init
  (defun bedrock/setup-eshell ()
    ;; Something funny is going on with how Eshell sets up its keymaps; this is
    ;; a work-around to make C-r bound in the keymap
    (keymap-set eshell-mode-map "C-r" 'consult-history))
  :hook ((eshell-mode . bedrock/setup-eshell)))

;; Eat: Emulate A Terminal
(use-package eat
  :ensure t
  :custom
  (eat-term-name "xterm")
  :config
  (eat-eshell-mode)                     ; use Eat to handle term codes in program output
  (eat-eshell-visual-command-mode))     ; commands like less will be handled by Eat

;; [bill] vterm: a real terminal emulator (libvterm-backed), for the cases
;; where eat is not enough -- full-screen TUI programs, SSH sessions, etc.
;; The first `M-x vterm' offers to compile its module, which needs cmake.
;; evil already starts vterm buffers in emacs state (extras/vim-like.el).
;; `:commands' keeps it deferred: loading vterm.el checks for the compiled
;; module and would otherwise prompt on every startup.
(use-package vterm
  :ensure t
  :commands vterm)

;; Orderless: powerful completion style
(use-package orderless
  :ensure t
  :config
  ;; [bill] `basic' as a fallback after orderless. Orderless alone has no
  ;; prefix matching, which some LSP servers rely on for filtering, and it
  ;; loses the `/u/s/l' -> `/usr/share/lib' expansion when finding files --
  ;; hence the per-category override for file names.
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Misc. editing enhancements
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Modify search results en masse
(use-package wgrep
  :ensure t
  :config
  (setq wgrep-auto-save-buffer t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Eye candy (visual feedback)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; [bill] Briefly flash the line point lands on after a jump -- window switch,
;; scroll, consult pick. Cheap, and genuinely helps re-acquire the cursor.
(use-package pulsar
  :ensure t
  :config
  (pulsar-global-mode 1)
  ;; consult jumps (SPC s s, SPC /, imenu, ...) don't trigger the built-in
  ;; pulse hooks, so wire them up here.
  (add-hook 'consult-after-jump-hook #'pulsar-recenter-top))

;; [bill] Highlight TODO/FIXME/NOTE in code comments. Prose is jinx's job.
(use-package hl-todo
  :ensure t
  :hook (prog-mode . hl-todo-mode))

;; [bill] Indentation guides: one thin, quiet, uniform line per level.
;; Character-based (│), NOT stipple: on Retina/NS the stipple bitmap is
;; computed in logical pixels (window-font-width) but drawn unscaled, so it
;; tiles and shows TWO bars per column. One faint color for all depths, and
;; no current-depth highlight (a second shade also reads as a double line).
(use-package indent-bars
  :ensure t
  :hook (prog-mode . indent-bars-mode)
  :custom
  (indent-bars-prefer-character t)   ; draw │ glyphs, immune to stipple scaling
  (indent-bars-color-by-depth nil)
  (indent-bars-color '("#bdae93"))   ; gruvbox light3: visible but quiet
  (indent-bars-highlight-current-depth nil))

;; [bill] Slightly darken the background of "tool" buffers (dired, help,
;; terminals, ...) so file-visiting buffers stand out.
(use-package solaire-mode
  :ensure t
  :config
  (solaire-global-mode 1))

;; [bill] File-type icons in completion lists and ibuffer. (dired gets its
;; icons from dirvish, see the navigation section.) Requires a Symbols Nerd
;; Font on the system (macOS:
;; `brew install --cask font-symbols-only-nerd-font'); the body font is
;; untouched -- icons come from the separate symbols font.
(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (nerd-icons-completion-mode))

(use-package nerd-icons-ibuffer
  :ensure t
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

;; [bill] Trackpad-smooth scrolling. Replaces pixel-scroll-precision-mode
;; (disabled in init.el -- the two fight over scroll events).
(use-package ultra-scroll
  :ensure t
  :init
  (setq scroll-conservatively 101
        scroll-margin 2)
  :config
  (ultra-scroll-mode 1))

;; [bill] Stick the enclosing defun's signature to the top of the window once
;; its own line scrolls out of view. Treesitter-aware where grammars exist.
(use-package topsy
  :ensure t
  :hook (prog-mode . topsy-mode))

;; [bill] Render color codes (#b57614, rgb(...), ...) as swatches of the color
;; itself. Only where colors are expected: themes and stylesheets.
(use-package rainbow-mode
  :ensure t
  :hook ((css-mode emacs-lisp-mode conf-mode) . rainbow-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Navigation extras
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; [bill] Jump to a window by letter when more than two are open (complements
;; C-<arrows> windmove, which gets tedious with many windows).
(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window)
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;; [bill] Jump to recently-used directories; C-x C-j switches to a *file*
;; inside the chosen directory. Works inside any minibuffer path prompt.
(use-package consult-dir
  :ensure t
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

;; [bill] dirvish: a modern dired -- file previews, icons, git status -- while
;; staying inside the dired paradigm (no treemacs-style sidebar). All dired
;; keys keep working; evil keys come from evil-collection.
(use-package dirvish
  :ensure t
  :init
  (dirvish-override-dired-mode))

;; [bill] Disabled: Breadcrumb expects a list in header-line-format, but
;; Topsy uses a symbol. Keep Topsy as the sole header-line provider.
(use-package breadcrumb
  :disabled t
  :ensure t
  :config
  (breadcrumb-mode 1))
