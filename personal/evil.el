;;; evil.el --- Personal Evil configs -*- lexical-binding: t; -*-


;; evil-collection requires this var set before evil loaded.
(setq evil-want-keybinding nil
      evil-want-C-u-scroll t)

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init '(dired magit help compile xref)))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

(use-package sis
    :after evil
    :config
    (pcase system-type
      ;; macOS：使用 macism，默认恢复微信输入法。
      ('darwin
       (sis-ism-lazyman-config
        "com.apple.keylayout.ABC"
        "com.tencent.inputmethod.wetype.pinyin"
        'macism))

      ;; Linux：使用 fcitx5，当前输入法组里选择 Rime。
      ('gnu/linux
       (sis-ism-lazyman-config nil nil 'fcitx5)))

    (when (memq system-type '(darwin gnu/linux))
      (sis-global-respect-mode 1)))

(provide 'personal-evil)
