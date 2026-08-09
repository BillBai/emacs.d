;;; Emacs Bedrock
;;;
;;; Extra config: Writer

;;; Usage: Append or require this file from init.el for writing aids.
;;;
;;; Jinx is a spell-checking package that is performant and flexible.
;;; You can use Jinx inside of programming modes and it will only
;;; check spelling inside of strings and comments. (Configurable, of
;;; course.) It also supports having multiple languages (e.g. English
;;; and German) in the same file.
;;;
;;; Olivetti narrows the window margins so that your text is centered.
;;; This makes writing in a wide, dedicated window more pleasant.
;;;
;;; NOTE: the Olivetti package lives on the MELPA repository; you will
;;; need to update the `package-archives' variable in init.el before
;;; before loading this file; see the comment in init.el under
;;; "Package initialization".

;;; Contents:
;;;
;;;  - Spell checking
;;;  - Dictionary
;;;  - Distraction mitigation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   General prose-friendly behavior
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when (>= emacs-major-version 30)       ; compat test
  (add-hook 'text-mode-hook 'visual-wrap-prefix-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Spell checking
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Jinx: Enchanted spell-checking
;;
;; [bill] Two reasons the upstream auto-hook is disabled here:
;;
;;   1. Jinx needs an Enchant backend dictionary. There is none installed:
;;        sudo pacman -S hunspell-en_us
;;      Without it `jinx-mode' errors every time a text buffer opens.
;;
;;   2. Half of what I write is Chinese, and there is no Chinese dictionary
;;      (nor does spell-checking make sense for it). With the hook on, every
;;      CJK word gets underlined as a misspelling.
;;
;; So: no hook. Turn it on per buffer with `M-x jinx-mode' when writing English,
;; and use C-; to correct the word at point.
(use-package jinx
  :ensure t
  :bind (("C-;" . jinx-correct))
  :custom
  (jinx-camel-modes '(prog-mode))
  (jinx-delay 0.01))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Dictionary
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setopt dictionary-use-single-buffer t)
(setopt dictionary-server "dict.org")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Distraction mitigation
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Olivetti: Set the window margins so your text is centered
(use-package olivetti
  :ensure t
  ;; [bill] On for prose. Toggle by hand elsewhere with `M-x olivetti-mode'.
  :hook ((markdown-mode . olivetti-mode))
  :custom
  (olivetti-body-width 90))
