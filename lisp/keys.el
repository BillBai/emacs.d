;;; keys.el --- Personal keybindings  -*- lexical-binding: t; -*-

;; Loaded last, after extras/vim-like.el, so that `evil-window-map' exists by
;; the time `bill/leader-map' is defined.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Leader key (SPC)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Deliberately small. which-key lists everything after a half-second pause, so
;; there is nothing here to memorise -- add a line when something turns out to
;; be worth a leader key, not before.
;;
;; The three entries whose value is another keymap cost one line each and bring
;; a whole prefix with them: SPC h is all of C-h, SPC p is all of C-x p, SPC w
;; is evil's full window map.

(defvar-keymap bill/leader-map
  :doc "Leader map, bound to SPC in evil's motion state."
  "SPC" #'project-find-file
  "."   #'find-file
  ","   #'consult-buffer
  ":"   #'execute-extended-command
  "/"   #'consult-ripgrep          ; search the project
  "s"   #'consult-line             ; search this buffer
  "r"   #'consult-recent-file
  "k"   #'kill-current-buffer
  "g"   #'magit-status
  "h"   help-map
  "p"   project-prefix-map
  "w"   evil-window-map)

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
