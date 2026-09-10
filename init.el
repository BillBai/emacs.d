;;; -*- lexical-binding: nil; -*-
;;;  ________                                                _______                 __                            __
;;; /        |                                              /       \               /  |                          /  |
;;; $$$$$$$$/ _____  ____   ______   _______  _______       $$$$$$$  | ______   ____$$ | ______   ______   _______$$ |   __
;;; $$ |__   /     \/    \ /      \ /       |/       |      $$ |__$$ |/      \ /    $$ |/      \ /      \ /       $$ |  /  |
;;; $$    |  $$$$$$ $$$$  |$$$$$$  /$$$$$$$//$$$$$$$/       $$    $$</$$$$$$  /$$$$$$$ /$$$$$$  /$$$$$$  /$$$$$$$/$$ |_/$$/
;;; $$$$$/   $$ | $$ | $$ |/    $$ $$ |     $$      \       $$$$$$$  $$    $$ $$ |  $$ $$ |  $$/$$ |  $$ $$ |     $$   $$<
;;; $$ |_____$$ | $$ | $$ /$$$$$$$ $$ \_____ $$$$$$  |      $$ |__$$ $$$$$$$$/$$ \__$$ $$ |     $$ \__$$ $$ \_____$$$$$$  \
;;; $$       $$ | $$ | $$ $$    $$ $$       /     $$/       $$    $$/$$       $$    $$ $$ |     $$    $$/$$       $$ | $$  |
;;; $$$$$$$$/$$/  $$/  $$/ $$$$$$$/ $$$$$$$/$$$$$$$/        $$$$$$$/  $$$$$$$/ $$$$$$$/$$/       $$$$$$/  $$$$$$$/$$/   $$/

;;; Minimal init.el

;;; Contents:
;;;
;;;  - Basic settings
;;;  - Discovery aids
;;;  - Minibuffer/completion settings
;;;  - Interface enhancements/defaults
;;;  - Tab-bar configuration
;;;  - Theme
;;;  - Optional extras
;;;  - Built-in customization framework

;;; Guardrail

(when (< emacs-major-version 29)
  (error "Emacs Bedrock only works with Emacs 29 and newer; you have version %s" emacs-major-version))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Basic settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Package initialization
;;
;; We'll stick to the built-in GNU and non-GNU ELPAs (Emacs Lisp Package
;; Archive) for the base install, but there are some other ELPAs you could look
;; at if you want more packages. MELPA in particular is very popular. See
;; instructions at:
;;
;;    https://melpa.org/#/getting-started
;;
;; You can simply uncomment the following if you'd like to get started with
;; MELPA packages quickly:
;;
(with-eval-after-load 'package
  (setopt package-archives
	  '(("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
	    ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
	    ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/"))))

;; [bill] Import PATH from the login shell (macOS only).
;;
;; A GUI-launched Emacs gets the default system PATH, which lacks
;; /opt/homebrew/bin -- so eglot cannot find language servers and magit falls
;; back to the ancient /usr/bin/git. Launching from a terminal masks the
;; problem; that is why it "only breaks sometimes".
(use-package exec-path-from-shell
  :ensure t
  :if (eq system-type 'darwin)
  :config
  (exec-path-from-shell-initialize))

;; If you want to turn off the welcome screen, uncomment this
;(setopt inhibit-splash-screen t)

(setopt initial-major-mode 'fundamental-mode)  ; default mode for the *scratch* buffer
(setopt display-time-default-load-average nil) ; this information is useless for most

;; Automatically reread from disk if the underlying file changes
(setopt auto-revert-avoid-polling t)
;; Some systems don't do file notifications well; see
;; https://todo.sr.ht/~ashton314/emacs-bedrock/11
(setopt auto-revert-interval 5)
(setopt auto-revert-check-vc-info t)
(global-auto-revert-mode)

;; Save history of minibuffer
(savehist-mode)

;; [bill] ... and a few more histories worth keeping across sessions:
;; kill-ring (`M-y' still works after a restart) and the search rings.
(setopt savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

;; [bill] The default of 20 entries makes `consult-recent-file' (SPC f r)
;; nearly useless. Exclude the files Emacs generates for itself.
(setopt recentf-max-saved-items 300)
(setopt recentf-exclude (list (concat "\\`" (regexp-quote user-emacs-directory) "elpa/")
                              (concat "\\`" (regexp-quote user-emacs-directory) "eln-cache/")
                              "/\\.git/"))

(recentf-mode 1)
(save-place-mode 1)

;; [bill] Restore the previous session (buffers, window layout) on startup.
;; Frames are restored too: size, position and which monitor they were on are
;; all remembered from the last graceful quit. The desktop file lives in
;; user-emacs-directory and is gitignored.
(setopt desktop-restore-frames t)
(desktop-save-mode 1)

;; Move through windows with Ctrl-<arrow keys>
(windmove-default-keybindings 'control) ; You can use other modifiers here

;; Fix archaic defaults
(setopt sentence-end-double-space nil)

;; Make right-click do something sensible
(when (display-graphic-p)
  (context-menu-mode))

;; Don't litter file system with *~ backup files; put them all inside
;; ~/.emacs.d/backup or wherever
(defun bedrock--backup-file-name (fpath)
  "Return a new file path of a given file path.
If the new path's directories does not exist, create them."
  (let* ((backupRootDir (concat user-emacs-directory "emacs-backup/"))
         (filePath (replace-regexp-in-string "[A-Za-z]:" "" fpath )) ; remove Windows driver letter in path
         (backupFilePath (replace-regexp-in-string "//" "/" (concat backupRootDir filePath "~") )))
    (make-directory (file-name-directory backupFilePath) (file-name-directory backupFilePath))
    backupFilePath))
(setopt make-backup-file-name-function 'bedrock--backup-file-name)

;; [bill] The *~ backup files are redirected above; do the same for the
;; #auto-save# files, which otherwise land next to the file being edited.
(let ((auto-save-dir (expand-file-name "auto-save/" user-emacs-directory)))
  (make-directory auto-save-dir t)
  (setopt auto-save-file-name-transforms `((".*" ,auto-save-dir t))))

;; The above creates nested directories in the backup folder. If
;; instead you would like all backup files in a flat structure, albeit
;; with their full paths concatenated into a filename, then you can
;; use the following configuration:
;; (Run `'M-x describe-variable RET backup-directory-alist RET' for more help)
;;
;; (let ((backup-dir (expand-file-name "emacs-backup/" user-emacs-directory)))
;;   (setopt backup-directory-alist `(("." . ,backup-dir))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Discovery aids
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Show the help buffer after startup
;; (add-hook 'after-init-hook 'help-quick)

;; which-key: shows a popup of available keybindings when typing a long key
;; sequence (e.g. C-x ...)
(use-package which-key
  :config
  (which-key-mode))

;; [bill] Richer help buffers: source code, call graph, references -- the
;; describe-* replacements become the primary way to explore Emacs.
(use-package helpful
  :ensure t
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)
         ("C-h F" . helpful-function)
         ("C-h C-d" . helpful-at-point)))

;; [bill] Real-world usage examples inside helpful's elisp buffers.
(use-package elisp-demos
  :ensure t
  :config
  (advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer/completion settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; For help, see: https://www.masteringemacs.org/article/understanding-minibuffer-completion

(setopt enable-recursive-minibuffers t)                ; Use the minibuffer whilst in the minibuffer
(setopt completion-cycle-threshold 1)                  ; TAB cycles candidates
(setopt completions-detailed t)                        ; Show annotations
(setopt tab-always-indent 'complete)                   ; When I hit TAB, try to complete, otherwise, indent
(setopt completion-styles '(basic initials substring)) ; Different styles to match input to candidates

(setopt completion-auto-help 'always)                  ; Open completion always; `lazy' another option
(setopt completions-max-height 20)                     ; This is arbitrary
(setopt completions-format 'one-column)
(setopt completions-group t)
(setopt completion-auto-select 'second-tab)            ; Much more eager
;(setopt completion-auto-select t)                     ; See `C-h v completion-auto-select' for more possible values

(keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete) ; TAB acts more like how it does in the shell

;; For a fancier built-in completion option, try ido-mode,
;; icomplete-vertical, or fido-mode. See also the file extras/base.el

;(icomplete-vertical-mode)
;(fido-vertical-mode)
;(setopt icomplete-delay-completions-threshold 4000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Interface enhancements/defaults
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mode line information
(setopt line-number-mode t)                        ; Show current line in modeline
(setopt column-number-mode t)                      ; Show column as well

(setopt x-underline-at-descent-line nil)           ; Prettier underlines
(setopt switch-to-buffer-obey-display-actions t)   ; Make switching buffers more consistent

(setopt show-trailing-whitespace nil)      ; By default, don't underline trailing spaces
(setopt indicate-buffer-boundaries 'left)  ; Show buffer top and bottom in the margin

;; Enable horizontal scrolling
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)

;; We won't set these, but they're good to know about
;;
;; (setopt indent-tabs-mode nil)
;; (setopt tab-width 4)

;; Misc. UI tweaks
(blink-cursor-mode -1)                                ; Steady cursor
;; [bill] Smooth scrolling is handled by ultra-scroll (extras/base.el); the
;; built-in pixel-scroll-precision-mode conflicts with it over wheel events.
;(pixel-scroll-precision-mode)                         ; Smooth scrolling

;; [bill] Open URLs and previews in a real browser.
;;
;; The default (`browse-url-default-browser') shells out to xdg-open, which
;; dispatches on the *sniffed* MIME type. Pandoc emits XHTML, and on this box
;; `application/xhtml+xml' is registered to calibre-ebook-edit.desktop -- so
;; `C-c C-c p' in Markdown opened Calibre instead of a browser. Naming the
;; program explicitly sidesteps the whole xdg lookup.
;;
;; If none of these exist (e.g. macOS), fall through to the default, which
;; uses `open' and behaves correctly there.
(when-let* ((browser (seq-find #'executable-find
                               '("google-chrome-stable" "google-chrome"
                                 "chromium" "firefox"))))
  (setopt browse-url-browser-function #'browse-url-generic
          browse-url-generic-program browser))

;; Use common keystrokes by default
;; (cua-mode)

;; For terminal users, make the mouse more useful

(xterm-mouse-mode 1)

;; Display line numbers in programming mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setopt display-line-numbers-width 3)           ; Set a minimum width

;; Nice line wrapping when working with text
(add-hook 'text-mode-hook 'visual-line-mode)

;; Modes to highlight the current line with
(let ((hl-line-hooks '(text-mode-hook prog-mode-hook)))
  (mapc (lambda (hook) (add-hook hook 'hl-line-mode)) hl-line-hooks))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Tab-bar configuration
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Show the tab-bar as soon as tab-bar functions are invoked
(setopt tab-bar-show 1)

;; Add the time to the tab-bar, if visible
(add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-global 'append)
(setopt display-time-format "%a %F %T")
;; (setopt display-time-interval 1)
(display-time-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Theme
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package emacs
  ;; :config
  ;; (load-theme 'modus-vivendi))          ; for light theme, use modus-operandi

;; (use-package gruvbox-theme
;;   :ensure t
;;   :config
;;   (mapc #'disable-theme custom-enabled-themes)
;;   (load-theme 'gruvbox-light-medium t))

(use-package solarized-theme
  :ensure t
  :config
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'solarized-gruvbox-light t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Fonts
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun bill/first-available-font (&rest families)
  "Returns first font from a FAMILIES, nil if none"
  (seq-find (lambda (f) (member f (font-family-list))) families))

(defun bill/setup-fonts ()
  (let ((latin (bill/first-available-font
		"Ioskeley Mono Term SmCn" "Ioskeley Mono Term" "Iosevka" "Menlo" "Monospace"))
	(cjk (bill/first-available-font
	      "LXGW WenKai Mono Medium" "LXGW WenKai Mono" "Sarasa Mono SC")))
    (when latin
      (set-face-attribute 'default nil :family latin :weight 'medium :height 130))
    (when cjk
      (dolist (charset '(han cjk-misc))
	(set-fontset-font t charset cjk nil 'prepend)))))

;; [bill] In daemon mode there is no graphical display at startup, so a plain
;; (display-graphic-p) check would never fire. Defer to the first graphical
;; client frame instead; the hook removes itself once it has done its job.
(defun bill/setup-fonts-once (frame)
  (with-selected-frame frame
    (when (display-graphic-p frame)
      (bill/setup-fonts)
      (remove-hook 'after-make-frame-functions #'bill/setup-fonts-once))))

(if (daemonp)
    (add-hook 'after-make-frame-functions #'bill/setup-fonts-once)
  (when (display-graphic-p)
    (bill/setup-fonts)))

(setq-default line-spacing 0.1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Optional extras
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Uncomment the (load-file …) lines or copy code from the extras/ elisp files
;; as desired

;; UI/UX enhancements mostly focused on minibuffer and autocompletion interfaces
;; These ones are *strongly* recommended!
(load-file (expand-file-name "extras/base.el" user-emacs-directory))

;; Packages for software development
(load-file (expand-file-name "extras/dev.el" user-emacs-directory))

;; Vim-bindings in Emacs (evil-mode configuration)
(load-file (expand-file-name "extras/vim-like.el" user-emacs-directory))

;; Org-mode: plain markup/links/export only -- notes stay in Obsidian, so no
;; agenda, capture or roam here. See extras/org-intro.txt for an overview.
(load-file (expand-file-name "extras/org.el" user-emacs-directory))

;; Email configuration in Emacs
;; WARNING: needs the `mu' program installed; see the elisp file for more
;; details.
;(load-file (expand-file-name "extras/email.el" user-emacs-directory))

;; Tools for academic researchers
;(load-file (expand-file-name "extras/researcher.el" user-emacs-directory))

;; Writing aids: jinx (spell-check, opt-in per buffer) and olivetti (centered prose)
(load-file (expand-file-name "extras/writer.el" user-emacs-directory))

(load-file (expand-file-name "lisp/programming.el" user-emacs-directory))

;; Personal keybindings. Must come after extras/vim-like.el -- it references
;; `evil-window-map' at definition time.
(load-file (expand-file-name "lisp/keys.el" user-emacs-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Built-in customization framework
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file t t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Machine-local settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; local.el is not tracked by git; use it for per-machine overrides.
(let ((local-file (expand-file-name "local.el" user-emacs-directory)))
  (when (file-exists-p local-file)
    (load-file local-file)))

(setq gc-cons-threshold (or bedrock--initial-gc-threshold 800000))
