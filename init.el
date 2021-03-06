(package-initialize)

;;; set UTF-8 as default file encoding
(set-language-environment "UTF-8")
;; (set-default-coding-systems 'utf-8)
;; (set-default buffer-file-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(define-coding-system-alias 'UTF-8 'utf-8)
(define-coding-system-alias 'utf8 'utf-8)
(define-coding-system-alias 'UTF8 'utf-8)

(eval-when-compile
  ;; (add-to-list 'package-archives '("mepla". "http://melpa.org/packages/"))
  (setq package-archives '(("gnu"   . "http://elpa.emacs-china.org/gnu/")
			   ("melpa" . "http://elpa.emacs-china.org/melpa/")))
  (require 'package))
;; (add-to-list 'load-path (expand-file-name "site-lisp" user-emacs-directory))

;;; custom theme
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(load-theme 'molokai t)

(add-to-list 'exec-path "c:/Program Files/Steel Bank Common Lisp/1.3.18")

;;; set a default font
(when (and (display-graphic-p)
           (member "Source Code Pro" (font-family-list)))
  (set-frame-font "Source Code Pro-13:demibold")
  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font)
                      charset
                      (font-spec :family "Microsoft Yahei"))))

;;; show directory name when open files with same names
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;;; show buffer name in title instead of hostname
(setq frame-title-format "emacs@%b")


;;; stop creating backup~ files
(setq make-backup-files nil)

;;; stop creating #autosave# files
(setq auto-save-default nil)

;;; stop creating .#lock file links
(setq create-lockfiles nil)

;;; make ibuffer default
(defalias 'list-buffers 'ibuffer)

;;; always show line numbers
;; (global-linum-mode 1)
(add-hook 'prog-mode-hook 'linum-mode)

;;; always show line and column number
(line-number-mode 1)
(column-number-mode 1)

;;; turn on highlight current line
(global-hl-line-mode 1)

;;; turn on highlight matching brackets when cursor is on one
(show-paren-mode 1)
(setq show-paren-style 'mixed)	; parenthesis, expression or mixed

;;; make soft wrap
(global-visual-line-mode 1)

;;; display "lambda" as "λ"
(global-prettify-symbols-mode 1)

;;; set fill-column
(setq fill-column 80)

;;; move according to logical line
(global-set-key (kbd "M-n") 'next-logical-line)
(global-set-key (kbd "M-p") 'previous-logical-line)

;;; remove more than one blank line
(defun single-lines-only ()
  "replace multiple blank lines with a single one"
  (interactive)
  (goto-char (point-min))
  (while (re-search-forward "\\(^\\s-*$\\)\n" nil t)
    (replace-match "\n")
    (forward-char 1)))

;;; recentf-mode
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 30)
(recentf-mode 1)
(global-set-key (kbd "C-c r") 'recentf-open-files)

;;; make the tab do complete
(setq-default tab-always-indent 'complete)

;;; use hippie expand instead of dbbrev-expand
(global-set-key (kbd "M-/") 'hippie-expand)

;;; use zap-up-to-char
(autoload 'zap-up-to-char "misc"
  "Kill up to, but not including ARGth occurrence of CHAR." t)
(global-set-key (kbd "M-z") 'zap-up-to-char)


;;; highlight line numbers
;; (use-package hlinum
;;   :config
;;   (hlinum-activate)
;;   (setq linum-highlight-in-all-buffersp t))

(use-package novel-mode
  :load-path "site-lisp")

(use-package window-number
  :ensure t
  :config
  (window-number-mode 1)
  :bind (("C-x o". window-number-switch)))

(use-package paredit
  :ensure t
  :hook ((emacs-lisp-mode
	  eval-expression-minibuffer-setup
	  ielm-mode
	  lisp-mode
	  lisp-interaction-mode
	  scheme-mode
	  racket-mode
	  racket-repl-mode
	  sly-mode
	  inferior-scheme-mode) . enable-paredit-mode))

(use-package paredit-everywhere
  :ensure t
  :hook (prog-mode . paredit-everywhere-mode))

(use-package paredit-menu
  :ensure t
  :after paredit
  :config
  (define-key paredit-mode-map (kbd "M-[") 'paredit-backward)
  (define-key paredit-mode-map (kbd "M-]") 'paredit-forward))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package smex
  :ensure t)

(use-package counsel
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-extra-directories nil)

  (defun eh-ivy-open-current-typed-path ()
    (interactive)
    (when ivy--directory
      (let* ((dir ivy--directory)
	     (text-typed ivy-text)
	     (path (concat dir text-typed)))
	(delete-minibuffer-contents)
	(ivy--done path))))

  (define-key ivy-minibuffer-map (kbd "<return>") 'ivy-alt-done)
  (define-key ivy-minibuffer-map (kbd "C-f") 'eh-ivy-open-current-typed-path)

  (setq ivy-count-format "(%d/%d) ")

  :bind (("M-x". counsel-M-x)
	 ("C-s". swiper)
	 ("C-c k". counsel-rg)
	 ("C-x C-f". counsel-find-file)
	 ("C-c C-r". ivy-resume)))

(use-package magit
  :ensure t
  ;; :commands (magit-after-save-refresh-status magit-process-file)
  :bind (("C-x g". magit-status)
	 ("C-x M-g". magit-dispatch-popup))
  :hook (after-save . magit-after-save-refresh-status)
  :config
  ;; use ivy
  (setq magit-completing-read-function 'ivy-completing-read)
  (setq split-width-threshold 80))

(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  ;; activate quickhelp
  (company-quickhelp-mode 1)
  ;; make TAB complete first, then cycle
  ;; make S-TAB cycle backward
  (define-key company-active-map (kbd "<tab>") 'company-complete-common-or-cycle)
  (define-key company-active-map (kbd "<backtab>") 'company-select-previous)
  (define-key company-active-map (kbd "\C-n") 'company-select-next)
  (define-key company-active-map (kbd "\C-p") 'company-select-previous)
  (define-key company-active-map (kbd "\C-d") 'company-show-doc-buffer)
  (define-key company-active-map (kbd "M-.") 'company-show-location)
  ;; cancel selections by typing non-matching characters
  (setq company-require-match 'never)
  ;; activate quickhelp
  (company-quickhelp-mode 1)
  ;;; custom backends
  (add-to-list 'company-backends '(sly-company company-files)))

(use-package org
  :ensure t
  :config
  (defun my-org-mode-hook ()
    (add-hook 'completion-at-point-functions 'pcomplete-completions-at-point nil t))
  (add-hook 'org-mode-hook #'my-org-mode-hook))

(use-package sly
  :ensure t
  :hook (sly-mode . sly-company-mode)
  :init
  ;;; inferior lisp
  (setq inferior-lisp-program "sbcl --no-linedit")
  :config
  ;;; generalized documentation lookup
  (define-key sly-prefix-map (kbd "M-h") 'sly-documentation-lookup)
  ;;; clear last REPL prompt's output
  (eval-after-load 'sly-mrepl
    '(define-key sly-mrepl-mode-map (kbd "C-c C-k") 'sly-mrepl-clear-recent-output))
  ;;; multiple lisps
  (setq sly-lisp-implementations
	'((sbcl ("sbcl.exe"))
	  (ecl ("ecl.exe"))
	  (clisp ("clisp.exe")))))

(use-package dired+
  :ensure t
  :init
  (setq diredp-hide-details-initially-flag nil)
  (setq dired-listing-switches "-alF"))

(use-package vlf
  :ensure t
  :requires vlf-setup
  )

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t)
 '(package-selected-packages
   (quote
    (hexo ox-gfm org markdown-mode+ smex vlf vimrc-mode recentf-ext use-package-chords company-math magit sly use-package dired+ sly-company sly-quicklisp company-quickhelp counsel rainbow-delimiters paredit-everywhere paredit-menu paredit window-number))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
