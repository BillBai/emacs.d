;;; -*- lexical-binding: nil; -*-
;;; Emacs Bedrock
;;;
;;; Extra config: Org-mode starter config

;;; [bill] Trimmed to plain org-mode: markup, links, export. No agenda,
;;; capture, refile or roam -- notes live in Obsidian; this file is just for
;;; using org itself. Bedrock's phased agenda setup is in git history if it
;;; is ever wanted. See "org-intro.txt" for a high-level overview.

(setq org-directory "~/Documents/org/") ; used only if agenda/capture appear

(use-package org
  ;; No :hook needed -- org-mode descends from outline-mode → text-mode, so
  ;; visual-line-mode (init.el) and jinx (writer.el) already apply.
  :bind (:map global-map
              ("C-c l s" . org-store-link)          ; Mnemonic: link → store
              ("C-c l i" . org-insert-link-global)) ; Mnemonic: link → insert
  :config
  (add-to-list 'org-export-backends 'md)

  ;; Make org-open-at-point follow file links in the same window
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)

  ;; Make exporting quotes better
  (setq org-export-with-smart-quotes t))
