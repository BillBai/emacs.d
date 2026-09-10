;;; -*- lexical-binding: nil; -*-
;;; Emacs Bedrock
;;;
;;; Extra config: Vim emulation

;;; Usage: Append or require this file from init.el for bindings in Emacs.

;;; Contents:
;;;
;;;  - Core Packages

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Core Packages
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Evil: vi emulation
(use-package evil
  :ensure t

  :init
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-keybinding nil)

  ;; Enable this if you want C-u to scroll up, more like pure Vim
  (setq evil-want-C-u-scroll t)

  :config
  (evil-mode)

  ;; [bill] Cursor color/shape per state, gruvbox palette -- you can tell the
  ;; state from the corner of your eye.
  (setq evil-normal-state-cursor   '("#b57614" box)         ; orange box
        evil-insert-state-cursor   '("#79740e" (bar . 2))   ; green bar
        evil-visual-state-cursor   '("#8f3f71" box)         ; purple box
        evil-replace-state-cursor  '("#c14a4a" (hbar . 2))  ; red underline
        evil-operator-state-cursor '("#b57614" hollow))     ; hollow box

  ;; If you use Magit, start editing in insert state
  (add-hook 'git-commit-setup-hook 'evil-insert-state)

  ;; Configuring initial major mode for some modes
  (evil-set-initial-state 'eat-mode 'emacs)
  (evil-set-initial-state 'vterm-mode 'emacs))

(use-package evil-collection
  :ensure t

  :after evil

  :config
  (evil-collection-init '(dired magit help compile xref))

;; [bill] Multiple cursors. The prefix is "gz" in normal/visual state --
;; pause after it and which-key lists the operations (make cursor, skip
;; match, undo cursor, ...).
(use-package evil-mc
  :ensure t
  :after evil
  :config
  (global-evil-mc-mode 1))

;; [bill] Keep the system IME in sync with evil state: entering normal state
;; switches to ABC, entering insert restores WeType pinyin. Drives macOS via
;; macism (a tiny CLI in ~/.local/bin; not in Homebrew). Cursor color already
;; encodes the evil state, so sis-global-cursor-color-mode stays off.
(use-package sis
  :ensure t
  :after evil
  :config
  (sis-ism-lazyman-config "com.apple.keylayout.ABC"
                          "com.tencent.inputmethod.wetype.pinyin")
  (sis-global-respect-mode t)))

(use-package evil-commentary
  :ensure t
  :after evil
  :config
  (evil-commentary-mode))
