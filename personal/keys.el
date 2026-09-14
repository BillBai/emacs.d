;;; keys.el --- Personal keybindings  -*- lexical-binding: t; -*-

;; Loaded last, after extras/vim-like.el, so that `evil-window-map' exists by
;; the time `bill/leader-map' is defined.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Leader key (SPC)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Laid out to match the Doom bindings I already have in my fingers, but only
;; the handful I actually use. which-key lists every level after a half-second
;; pause, so there is nothing here to memorise -- add a line when a command
;; turns out to deserve a leader key, not before.
;;
;; Three of the entries are existing keymaps rather than commands: SPC h is all
;; of C-h, SPC p is all of C-x p, SPC w is evil's whole window map. One line
;; each, and they stay in sync with Emacs upstream for free.

(defun bill/find-config-file ()
  "Find a file under `user-emacs-directory'."
  (interactive)
  (let ((default-directory user-emacs-directory))
    (call-interactively #'find-file)))

(defvar-keymap bill/leader-buffer-map
  :doc "SPC b -- buffers."
  "b" #'consult-buffer
  "k" #'kill-current-buffer
  "s" #'save-buffer
  "r" #'revert-buffer
  "i" #'ibuffer)

(defvar-keymap bill/leader-file-map
  :doc "SPC f -- files."
  "f" #'find-file
  "s" #'save-buffer
  "S" #'write-file                 ; save as
  "r" #'consult-recent-file
  "d" #'dired
  "p" #'bill/find-config-file)     ; p for "private config", as in Doom

(defvar-keymap bill/leader-search-map
  :doc "SPC s -- search."
  "s" #'consult-line               ; this buffer
  "p" #'consult-ripgrep            ; the project
  "i" #'consult-imenu
  "o" #'consult-outline)

(defvar-keymap bill/leader-git-map
  :doc "SPC g -- git."
  "g" #'magit-status
  "b" #'magit-blame-addition
  "l" #'magit-log-buffer-file)

(defvar-keymap bill/leader-map
  :doc "Leader map, bound to SPC in evil's motion state."
  "SPC" #'project-find-file
  "."   #'find-file
  ","   #'consult-buffer
  ":"   #'execute-extended-command
  "/"   #'consult-ripgrep
  ;; A binding of the form (STRING . KEYMAP) is Emacs' built-in "named prefix":
  ;; the string is what which-key and `describe-bindings' show for the prefix.
  ;;
  ;; Do NOT use `which-key-add-keymap-based-replacements' for this. When handed
  ;; a cons it stores that cons as the binding verbatim (which-key.el:1053), so
  ;; passing ("+buffer" . nil) silently replaces the sub-keymap with nil and the
  ;; whole prefix stops working -- despite what its docstring implies.
  "b"   (cons "+buffer"  bill/leader-buffer-map)
  "f"   (cons "+file"    bill/leader-file-map)
  "s"   (cons "+search"  bill/leader-search-map)
  "g"   (cons "+git"     bill/leader-git-map)
  "h"   (cons "+help"    help-map)
  "p"   (cons "+project" project-prefix-map)
  "w"   (cons "+window"  evil-window-map))

;; SPC goes on `evil-motion-state-map', NOT `evil-normal-state-map'.
;;
;; Evil keeps the motion-state keymap active in normal, visual and operator
;; states too (it is not keymap inheritance -- evil composes the active maps in
;; `evil-mode-map-alist'), so this single binding covers all of them, including
;; the read-only buffers that sit in motion state: dired, magit, help,
;; compilation. Binding only normal state is the usual reason a hand-rolled
;; leader "works sometimes".
(keymap-set evil-motion-state-map "SPC" bill/leader-map)

(provide 'keys)
;;; keys.el ends here
