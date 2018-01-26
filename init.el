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
(require 'helm-ag)

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
(setq helm-ag-insert-at-point 'symbol)
(setq bibtex-completion-bibliography '("/Users/bencooper/google_drive/Papers/bkc_full_references.bib"))

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
; install jediepcserver.py in bin directory of each conda env
(setq jedi:server-command '("jediepcserver.py"))
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
(add-hook 'c-mode-common-hook 'flycheck-mode)
(defun set-checker-to-clang ()
  (setq flycheck-checker 'c/c++-clang))
(add-hook 'c-mode-common-hook 'set-checker-to-clang)

;; Julia configuration
(eval-after-load 'julia-mode
  '(define-key julia-mode-map (kbd "C-c C-p") 'inferior-julia))

;; HTML stuff
(defun wrap-p-tag ()
  "Add a tag to beginning and ending of current word or text selection."
  (interactive)
  (let (p1 p2 inputText)
    (if (use-region-p)
        (progn
          (setq p1 (region-beginning) )
          (setq p2 (region-end) )
          )
      (let ((bds (bounds-of-thing-at-point 'symbol)))
        (setq p1 (car bds) )
        (setq p2 (cdr bds) ) ) )

    (goto-char p2)
    (delete-backward-char 1)
    (insert "</p>")
    (newline)
    (goto-char p1)
    (insert "<p>")
    ))

(defun insert-andy-figure-template (fignum)
  "Set up skeleton for figure"
  (interactive "nFigure number: ")
  (let ()
    (insert "<figure id=\"Figure_" (number-to-string fignum) "\">")
    (newline)
    (insert "<img src=\"./images/figure_" (number-to-string fignum) "/\" alt=\"Figure " (number-to-string fignum) "\" id=\"Figure_" (number-to-string fignum) "_image\">")
    (newline)
    (insert "<figcaption><strong>Figure " (number-to-string fignum) ": </strong> </figcaption>")
    (newline)
    (insert "</figure><p></p>")
    ))

(add-hook 'html-mode-hook
	  (lambda () (let ()
		       (local-set-key (kbd "C-c RET") #'wrap-p-tag)
		       (local-set-key (kbd "C-c f") #'insert-andy-figure-template)
		       (local-set-key (kbd "C-c r") #'helm-bibtex))))
(add-hook 'html-mode-hook (lambda () (electric-indent-local-mode -1)))

;; custom reference format for helm-bibtex
;; if you run into problems here, require 's, possibly 'cl-lib
(require 'helm-bibtex)
(defun bibtex-completion-insert-bkc-reference (keys)
  "Insert a reference for each selected entry."
  (let* ((refs (--map
                (s-word-wrap fill-column
                             (concat "\n" (bibtex-completion-bkc-format-reference it)))
                keys)))
    (insert "\n" (s-join "\n" refs) "\n")))

(defun bibtex-completion-bkc-format-reference (key)
  "Returns a plain text reference in APA format for the
publication specified by KEY."
  (let*
   ((entry (bibtex-completion-get-entry key))
    (ref (pcase (downcase (bibtex-completion-get-value "=type=" entry))
           ("article"
            (s-format
	     "<a class=\"citation\" href=\"https://doi.org/${doi}\" title=\"${title}. ${author}. ${journal}, <b>${volume}</b>, ${pages} (${year}). doi:${doi}.\"> </a>"
             'bibtex-completion-bkc-get-value entry))
           ("inproceedings"
            (s-format
	     "<a class=\"citation\" href=\"https://doi.org/${doi}\" title=\"${title}. ${author}. ${booktitle}, ${pages} (${year}). doi:${doi}.\"> </a>"
             'bibtex-completion-bkc-get-value entry))
           ("book"
            (s-format
	     "<a class=\"citation\" href=\"http://\" title=\"<i>${title}</i>. ${author}. ${publisher} (${year}). ISBN: ${isbn}.\"> </a>"
             'bibtex-completion-bkc-get-value entry))
           ("phdthesis"
            (s-format
             "${author} (${year}). ${title} (Doctoral dissertation). ${school}, ${address}."
             'bibtex-completion-bkc-get-value entry))
           ("inbook"
            (s-format
             "${author} (${year}). ${title}. In ${editor} (Eds.), ${booktitle} (pp. ${pages}). ${address}: ${publisher}."
             'bibtex-completion-bkc-get-value entry))
           ("incollection"
            (s-format
             "${author} (${year}). ${title}. In ${editor} (Eds.), ${booktitle} (pp. ${pages}). ${address}: ${publisher}."
             'bibtex-completion-bkc-get-value entry))
           ("proceedings"
            (s-format
             "${editor} (Eds.). (${year}). ${booktitle}. ${address}: ${publisher}."
             'bibtex-completion-bkc-get-value entry))
           ("unpublished"
            (s-format
             "${author} (${year}). ${title}. Unpublished manuscript."
             'bibtex-completion-bkc-get-value entry))
           (_
            (s-format
             "${author} (${year}). ${title}."
             'bibtex-completion-bkc-get-value entry)))))
   (replace-regexp-in-string "\\([.?!]\\)\\." "\\1" ref))) ; Avoid sequences of punctuation marks.

(defun bibtex-completion-bkc-get-value (field entry &optional default)
  "Return FIELD or ENTRY formatted following the APA
guidelines.  Return DEFAULT if FIELD is not present in ENTRY."
  (let ((value (bibtex-completion-get-value field entry))
        (entry-type (bibtex-completion-get-value "=type=" entry)))
    (if value
       (pcase field
         ;; https://owl.english.purdue.edu/owl/resource/560/06/
         ("author" (bibtex-completion-bkc-format-authors value))
         ("editor"
          (if (string= entry-type "proceedings")
              (bibtex-completion-apa-format-editors value)
            (bibtex-completion-apa-format-editors value)))
         ;; When referring to books, chapters, articles, or Web pages,
         ;; capitalize only the first letter of the first word of a
         ;; title and subtitle, the first word after a colon or a dash
         ;; in the title, and proper nouns. Do not capitalize the first
         ;; letter of the second word in a hyphenated compound word.
         ("title" (replace-regexp-in-string ; remove braces
                   "[{}]"
                   ""
                    (replace-regexp-in-string ; upcase initial letter
                    "^[[:alpha:]]"
                    'upcase
                    (replace-regexp-in-string ; preserve stuff in braces from being downcased
                     "\\(^[^{]*{\\)\\|\\(}[^{]*{\\)\\|\\(}.*$\\)\\|\\(^[^{}]*$\\)"
                     (lambda (x) (downcase (s-replace "\\" "\\\\" x)))
                     value))))
         ("booktitle" value)
         ;; Maintain the punctuation and capitalization that is used by
         ;; the journal in its title.
         ("pages" (s-join "–" (s-split "[^0-9]+" value t)))
         (_ value))
      "")))

(defun bibtex-completion-bkc-format-authors (value)
  (cl-loop for a in (s-split " and " value t)
           if (s-index-of "{" a)
             collect
             (replace-regexp-in-string "[{}]" "" a)
             into authors
           else if (s-index-of "," a)
             collect
             (let ((p (s-split " *, *" a t)))
               (concat
                (s-join " " (-map (lambda (it) (concat (s-left 1 it) "."))
                                  (s-split " " (cadr p)))) " "
		(car p)))
             into authors
           else
             collect
             (let ((p (s-split " " a t)))
               (concat
                (-last-item p) ", "
                (s-join " " (-map (lambda (it) (concat (s-left 1 it) "."))
                                  (-butlast p)))))
             into authors
           finally return
             (let ((l (length authors)))
               (cond
                 ((= l 1) (car authors))
                 ((< l 15) (concat (s-join ", " (-butlast authors))
                                  ", &amp; " (-last-item authors)))
                 (t (concat (s-join ", " (-slice authors 1 15)) ", …"))))))

(helm-bibtex-helmify-action bibtex-completion-insert-bkc-reference helm-bibtex-insert-bkc-reference)
(helm-add-action-to-source
 "Add reference for Github publications" `helm-bibtex-insert-bkc-reference
 helm-source-bibtex 0)
