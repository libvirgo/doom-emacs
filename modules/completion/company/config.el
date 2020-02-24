;;; completion/company/config.el -*- lexical-binding: t; -*-

(use-package! company
  :commands company-complete-common company-manual-begin company-grab-line
  :after-call pre-command-hook after-find-file
  :init
  (setq company-minimum-prefix-length 2
        company-tooltip-limit 14
        company-idle-delay 0
        company-box-doc-enable nil
        company-dabbrev-downcase nil
        company-dabbrev-ignore-case nil
        company-dabbrev-code-other-buffers t
        company-tooltip-align-annotations t
        company-require-match 'never
        company-global-modes
        '(not erc-mode message-mode help-mode gud-mode eshell-mode)
        company-backends '(company-capf)
        company-frontends
        '(company-pseudo-tooltip-frontend
          company-echo-metadata-frontend))
  :config
  (when (featurep! :editor evil)
    (add-hook 'company-mode-hook #'evil-normalize-keymaps)
    ;; Don't persist company popups when switching back to normal mode.
    (add-hook 'evil-normal-state-entry-hook #'company-abort)
    ;; Allow users to switch between backends on the fly. E.g. C-x C-s followed
    ;; by C-x C-n, will switch from `company-yasnippet' to
    ;; `company-dabbrev-code'.
    (defadvice! +company--abort-previous-a (&rest _)
      :before #'company-begin-backend
      (company-abort)))

  (add-hook 'company-mode-hook #'+company-init-backends-h)
  (global-company-mode +1))


(use-package! company-tng
  :when (featurep! +tng)
  :after-call post-self-insert-hook
  :config
  (add-to-list 'company-frontends 'company-tng-frontend)
  (define-key! company-active-map
    "RET"       nil
    [return]    nil
    "TAB"       #'company-select-next
    [tab]       #'company-select-next
    [backtab]   #'company-select-previous))


;;
;; Packages

(after! company-files
  (pushnew! company-files--regexps
            "file:\\(\\(?:\\.\\{1,2\\}/\\|~/\\|/\\)[^\]\n]*\\)"))


(use-package! company-prescient
  :hook (company-mode . company-prescient-mode)
  :config
  ;; NOTE prescient config duplicated with `ivy'
  (setq prescient-save-file (concat doom-cache-dir "prescient-save.el"))
  (prescient-persist-mode +1))


(use-package! company-box
  :when (featurep! +childframe)
  :hook (company-mode . company-box-mode)
  :config
  (setq company-box-show-single-candidate t
        company-box-backends-colors nil
        company-box-max-candidates 50
        company-box-icons-alist 'company-box-icons-all-the-icons
        company-box-icons-functions
        (cons #'+company-box-icons--elisp-fn
              (delq 'company-box-icons--elisp
                    company-box-icons-functions))
        company-box-icons-all-the-icons
        (let ((all-the-icons-scale-factor 0.8))
          `((Unknown       . ,(all-the-icons-material "find_in_page"                                        ))
            (Text          . ,(all-the-icons-faicon   "text-width"                                          ))
            (Method        . ,(all-the-icons-faicon   "cube"                     :face 'all-the-icons-purple))
            (Function      . ,(all-the-icons-faicon   "cube"                     :face 'all-the-icons-purple))
            (Constructor   . ,(all-the-icons-material "functions"                :face 'all-the-icons-purple))
            (Field         . ,(all-the-icons-octicon  "tag"                      :face 'all-the-icons-lblue))
            (Variable      . ,(all-the-icons-octicon  "tag"                      :face 'all-the-icons-lblue))
            (Class         . ,(all-the-icons-material "settings_input_component" :face 'all-the-icons-orange))
            (Interface     . ,(all-the-icons-material "share"                    :face 'all-the-icons-lblue))
            (Module        . ,(all-the-icons-material "view_module"              :face 'all-the-icons-lblue))
            (Property      . ,(all-the-icons-faicon   "wrench"                                             ))
            (Unit          . ,(all-the-icons-material "settings_system_daydream"                           ))
            (Value         . ,(all-the-icons-material "format_align_right"       :face 'all-the-icons-lblue))
            (Enum          . ,(all-the-icons-material "storage"                  :face 'all-the-icons-orange))
            (Keyword       . ,(all-the-icons-material "filter_center_focus"                                ))
            (Snippet       . ,(all-the-icons-material "format_align_center"                                ))
            (Color         . ,(all-the-icons-material "palette"                                            ))
            (File          . ,(all-the-icons-faicon   "file-o"                                             ))
            (Reference     . ,(all-the-icons-material "collections_bookmark"                               ))
            (Folder        . ,(all-the-icons-faicon   "folder-open"                                        ))
            (EnumMember    . ,(all-the-icons-material "format_align_right"       :face 'all-the-icons-lblue))
            (Constant      . ,(all-the-icons-faicon   "square-o"                                            ))
            (Struct        . ,(all-the-icons-material "settings_input_component" :face 'all-the-icons-orange))
            (Event         . ,(all-the-icons-octicon  "zap"                      :face 'all-the-icons-orange))
            (Operator      . ,(all-the-icons-material "control_point"                                       ))
            (TypeParameter . ,(all-the-icons-faicon   "arrows"                                              ))
            (Template      . ,(all-the-icons-material "format_align_left"                                   ))
            (ElispFunction . ,(all-the-icons-faicon   "cube"                     :face 'all-the-icons-purple))
            (ElispVariable . ,(all-the-icons-octicon  "tag"                      :face 'all-the-icons-lblue))
            (ElispFeature  . ,(all-the-icons-material "stars"                    :face 'all-the-icons-orange))
            (ElispFace     . ,(all-the-icons-material "format_paint"             :face 'all-the-icons-pink)))))

  (defun +company-box-icons--elisp-fn (candidate)
    (when (derived-mode-p 'emacs-lisp-mode)
      (let ((sym (intern candidate)))
        (cond ((fboundp sym)  'ElispFunction)
              ((boundp sym)   'ElispVariable)
              ((featurep sym) 'ElispFeature)
              ((facep sym)    'ElispFace)))))

  (defadvice! +company-remove-scrollbar-a (orig-fn &rest args)
    "This disables the company-box scrollbar, because:
https://github.com/sebastiencs/company-box/issues/44"
    :around #'company-box--update-scrollbar
    (cl-letf (((symbol-function #'display-buffer-in-side-window)
               (symbol-function #'ignore)))
      (apply orig-fn args))))


(use-package! company-dict
  :defer t
  :config
  (setq company-dict-dir (expand-file-name "dicts" doom-private-dir))
  (add-hook! 'doom-project-hook
    (defun +company-enable-project-dicts-h (mode &rest _)
      "Enable per-project dictionaries."
      (if (symbol-value mode)
          (add-to-list 'company-dict-minor-mode-list mode nil #'eq)
        (setq company-dict-minor-mode-list (delq mode company-dict-minor-mode-list))))))
