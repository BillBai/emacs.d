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
;; [bill] `text-mode' only, deliberately not `prog-mode': code comments here are
;; frequently Chinese, and flagging them is pure noise. Turn it on by hand in a
;; code buffer with `M-x jinx-mode' on the rare occasion it is wanted.
;;
;; Requires an Enchant backend dictionary: sudo pacman -S hunspell-en_us
(use-package jinx
  :ensure t
  :hook (text-mode . jinx-mode)
  :bind (("C-;" . jinx-correct))
  :custom
  (jinx-camel-modes '(prog-mode))
  (jinx-delay 0.01)
  :config
  ;; [bill] Never spell-check Chinese. Jinx has no notion of scripts, so in a
  ;; bilingual note every Chinese run would be sent to the en_US dictionary and
  ;; come back "misspelled". `\cc' is Emacs' regexp character-category for
  ;; Chinese. Pushed onto the existing `t' entry so jinx's own defaults (URLs,
  ;; e-mail addresses, ALL-CAPS words, ...) are preserved.
  (push "\\cc+" (alist-get t jinx-exclude-regexps)))

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
