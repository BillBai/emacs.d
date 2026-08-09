;; -*- lexical-binding: t; -*-

;; Tree-sitter
(require 'treesit)

(setq treesit-language-source-alist
      '((c          "https://github.com/tree-sitter/tree-sitter-c")
        (cpp        "https://github.com/tree-sitter/tree-sitter-cpp")
        (rust       "https://github.com/tree-sitter/tree-sitter-rust")
        (python     "https://github.com/tree-sitter/tree-sitter-python")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" nil "typescript/src")
        (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" nil "tsx/src")
        (json       "https://github.com/tree-sitter/tree-sitter-json")
        (yaml       "https://github.com/tree-sitter-grammars/tree-sitter-yaml")
        (bash       "https://github.com/tree-sitter/tree-sitter-bash")
        (toml       "https://github.com/tree-sitter-grammars/tree-sitter-toml")))

(defun bill/install-treesit-grammars ()
  "Installs tresitter grammars"
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (if (treesit-language-available-p lang)
	(message "Already exists, skip: %s" lang)
      (message "Installing: %s ..." lang)
      (treesit-install-language-grammar lang))))

(dolist (entry '(("\\.rs\\'"  . rust-ts-mode)
                 ("\\.ts\\'"  . typescript-ts-mode)
                 ("\\.tsx\\'" . tsx-ts-mode)))
  (add-to-list 'auto-mode-alist entry))

(dolist (entry '((c-mode          . c-ts-mode)
                 (c++-mode        . c++-ts-mode)
                 (c-or-c++-mode   . c-or-c++-ts-mode)
                 (python-mode     . python-ts-mode)
                 (javascript-mode . js-ts-mode)
                 (js-mode         . js-ts-mode)
                 (js-json-mode    . json-ts-mode)
                 (json-mode       . json-ts-mode)
                 (yaml-mode       . yaml-ts-mode)
                 (sh-mode         . bash-ts-mode)
                 (conf-toml-mode  . toml-ts-mode)))
  (add-to-list 'major-mode-remap-alist entry))

;;;;  LSP (eglot)

(dolist (hook '(c-ts-mode-hook
                c++-ts-mode-hook
                rust-ts-mode-hook
                python-ts-mode-hook
                js-ts-mode-hook
                typescript-ts-mode-hook
                tsx-ts-mode-hook))
  (add-hook hook #'eglot-ensure))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((c-mode c-ts-mode c++-mode c++-ts-mode)
                 . ("clangd"
                    "--clang-tidy"
                    "--header-insertion=never"
                    "--completion-style=detailed"))))

;;;  Racket / SICP
(use-package racket-mode
  :ensure t
  :hook (racket-mode . racket-xp-mode))

(use-package rainbow-delimiters
  :ensure t
  :hook ((emacs-lisp-mode lisp-data-mode racket-mode racket-repl-mode)
         . rainbow-delimiters-mode))

(with-eval-after-load 'evil
  (evil-set-initial-state 'racket-repl-mode 'insert))

(setopt show-paren-context-when-offscreen 'overlay)

;;; ---------------------

(provide 'programming)
