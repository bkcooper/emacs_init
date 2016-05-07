(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#fdf6e3" :foreground "#657b83" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 120 :width normal :foundry "nil" :family "Source Code Pro")))))

;; general setup
(add-to-list 'load-path "~/.emacs.d/lisp")
(package-initialize)
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))


; set default frame sizes
(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width . 80))
(setq minibuffer-elduf-shorten-default 't)

; set up mouse wheel scrolling
(setq mouse-wheel-follow-mouse 't)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

;ELPA setup
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

; some recommendations from better defaults
(global-set-key (kbd "M-/") 'hippie-expand) ; ropemode overrides
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "M-z") 'zap-up-to-char)
(global-set-key (kbd "C-x g") 'magit-status)

(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

;; specific packages

; org-mode setup
(setq org-directory (expand-file-name "~/Google Drive/org/"))
(setq org-default-notes-file (concat org-directory "/capture.org"))
(setq org-log-done `time)
(setq org-todo-keywords
      `((sequence "TODO" "THINKING" "DOING" "CONSULT" "|" "DONE" "CANCELLED" "HANDED OFF")))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

; uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)

; helm
(require 'helm)
(require 'helm-config)

(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

; some recommended keymappings
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "C-x b") 'helm-mini)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-c o") 'helm-occur)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
; make TAB works in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action)
; list actions using C-z

; change some default executables for use in helm
(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))
(when (executable-find "ack-grep")
  (setq helm-grep-default-command "ack-grep -Hn --nogroup %p %f"
        helm-grep-default-recurse-command "ack-grep -H --nogroup %e %p %f"))

(setq helm-split-window-in-side-p           t
      helm-move-to-line-cycle-in-source     t
      helm-ff-search-library-in-sexp        t
      helm-scroll-amount                    8
      helm-ff-file-name-history-use-recentf t)

(helm-mode 1)

;;LaTeX configuration
(setq latex-run-command "pdflatex")
(add-hook 'latex-mode-hook 'flycheck-mode)
(defun set-checker-to-lacheck ()
  (setq flycheck-checker 'tex-lacheck))
(add-hook 'latex-mode-hook 'set-checker-to-lacheck)

;; Python configuration

; virtualenvwrapper
(require 'virtualenvwrapper)
(setq venv-location "~/miniconda/envs")
(venv-workon) ; prompts for venv when starting emacs

;; Jedi
(setq jedi:complete-on-dot t)
(setq jedi:use-shortcuts t)
(setq jedi-server-file-suffix "lib/python2.7/site-packages/jediepcserver-0.0.0-py2.7.egg/jediepcserver.py")
(defun jedi:buffer-local-setup ()
  "allows which jedi server you start to be buffer local"
  (let ((cmds (list (mapconcat 'symbol-value '(venv-current-dir jedi-server-file-suffix) ""))))
    (when cmds (set (make-local-variable 'jedi:server-command) cmds))))

(add-hook 'python-mode-hook 'jedi:buffer-local-setup)
(add-hook 'python-mode-hook 'jedi:setup)
(add-hook 'venv-postdeactivate-hook 'jedi:stop-server)
(defun venv-restart-jedi-server ()
  "restarts the jedi server after switching virtualenvs"
  (when (featurep `jedi)
    (jedi:buffer-local-setup)))
(add-hook 'venv-postactivate-hook 'venv-restart-jedi-server)

;; make IPython what we run with run-python, C-c C-p in python mode
(setq python-shell-interpreter "ipython"
  python-shell-interpreter-args "-i")
(defun ipython-set-python-indent-offset ()
  (setq python-indent-offset 4))
(add-hook 'inferior-python-mode-hook 'ipython-set-python-indent-offset)

;; handle indenting on new lines, set up flycheck with flake8,
;; clean whitespace on save
(defun set-newline-and-indent ()
  (local-set-key (kbd "RET") 'newline-and-indent))
(add-hook 'python-mode-hook 'set-newline-and-indent)
(add-hook 'python-mode-hook 'flycheck-mode)
(defun set-checker-to-flake8 ()
  (setq flycheck-checker 'python-flake8))
(add-hook 'python-mode-hook 'set-checker-to-flake8)
(defun clean-whitespace-on-save ()
  (add-hook 'before-save-hook 'delete-trailing-whitespace))
(add-hook 'python-mode-hook 'clean-whitespace-on-save)

;;; C configuration

;; flycheck with clang
(setq c-default-style "python"
      c-basic-offset 4)
(add-hook 'c-mode-hook 'flycheck-mode)
(defun set-checker-to-clang ()
  (setq flycheck-checker 'c/c++-clang))
(add-hook 'c-mode-hook 'set-checker-to-clang)

;; Julia configuration
(eval-after-load 'julia-mode
  '(define-key julia-mode-map (kbd "C-c C-p") 'inferior-julia))
