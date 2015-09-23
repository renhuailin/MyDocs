;; (server-start)

;;set up fonts
;;(set-default-font "Monaco-13")
(set-default-font "Source Code Pro-14")
;;(set-default-font "Verily Serif Mono-13")

;;Set lisp load path
(setq load-path (cons "~/.emacs.d/site-lisp/emacs-goodies-el" load-path))

;;Turn of message beep
;;(set-message-beep 'silent)

;;Don't make backup file.
(setq make-backup-files nil)

;; share with X11 clipboard,add it for linux X11 only;
;(setq x-select-enable-clipboard t)
;;(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;;
(setq inhibit-startup-message t)

;;
(show-paren-mode t)

;;
(setq indent-tabs-mode nil)
(setq tab-stop-list ())
(setq default-tab-width 4)
(setq tab-width 4)

;;set tab width to 4 in c mode
(defvaralias 'c-basic-offset 'tab-width)

;;set tab width to 4 in perl mode
(defvaralias 'cperl-indent-level 'tab-width)

; set return key replacing tab which means newline-and-indent
(define-key global-map (kbd "RET") 'newline-and-indent) ;

(fset 'yes-or-no-p 'y-or-n-p)

;;Load yasnippet mode.
(add-to-list 'load-path "~/.emacs.d/plugins/yasnippet")
(require 'yasnippet)
(setq yas-snippet-dirs '("~/.emacs.d/plugins/yasnippet/snippets" "~/.emacs.d/snippets" "~/.emacs.d/plugins/yasnippet"))
(yas-global-mode 1)


;; CEDET configuration
;;In emacs 23.2 CEDET was merged into the main emacs distribution.The configuration code which is explained in CEDET tutorials does not work any more.
;;I got a basic configuration to work:
(global-ede-mode 1)
(require 'semantic/sb)
(semantic-mode 1)

;; * This enables the database and idle reparse engines
;;(semantic-load-enable-minimum-features)

;; * This enables some tools useful for coding, such as summary mode
;;   imenu support, and the semantic navigator
;;(semantic-load-enable-code-helpers)

;; * This enables even more coding tools such as the nascent intellisense mode
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
;; (semantic-load-enable-guady-code-helpers)

;; * This enables the use of Exuberent ctags if you have it installed.
;; (semantic-load-enable-all-exuberent-ctags-support)
(require 'semantic/ia)

;; END OF CEDET




;;format code.
(global-set-key [(control shift f)] 'indent-region)

;;;;speedbar

;;Why are the lines in the ECB-, temp- and compilation-buffers not wrapped but truncated?
;;Check the variable truncate-partial-width-windows and set it to nil.
(setq truncate-partial-width-windows nil)


;;;
;; Tabbar configuration.
(require 'tabbar)
(tabbar-mode 1)
;; Put all buffers(tabs) in one group.
;; (setq tabbar-buffer-groups-function
;;           (lambda ()
;;             (list "All")))

 (defun my-tabbar-buffer-groups () ;; customize to show all normal files in one group
   "Returns the name of the tab group names the current buffer belongs to.
 There are two groups: Emacs buffers (those whose name starts with “*”, plus
 dired buffers), and the rest.  This works at least with Emacs v24.2 using
 tabbar.el v1.7."
   (list (cond ((string-equal "*" (substring (buffer-name) 0 1)) "emacs")
               ((eq major-mode 'dired-mode) "emacs")
               (t "user"))))
 (setq tabbar-buffer-groups-function 'my-tabbar-buffer-groups)

;;End of tabbar configuration

;;In ruby mode,set tab width 4
(setq ruby-indent-level 4)

;;Load auto complete plug in.
(add-to-list 'load-path "~/.emacs.d/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)



;;Always show line number.
(global-linum-mode 1)

;;Show scrollbar at right
(set-scroll-bar-mode 'right)

;;enable delete selection mode.
(delete-selection-mode 1)

;;put all auto-saves and backup file to temporary directory.
(setq backup-directory-alist
	  `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
	  `((".*" ,temporary-file-directory t)))


;; delte tailing white spaces before saving.
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (tango-dark)))
 '(show-paren-mode t)
 '(speedbar-supported-extension-expressions (quote (".[ch]\\(\\+\\+\\|pp\\|c\\|h\\|xx\\)?" ".tex\\(i\\(nfo\\)?\\)?" ".el" ".emacs" ".l" ".lsp" ".p" ".java" ".js" ".f\\(90\\|77\\|or\\)?" ".ad[abs]" ".p[lm]" ".tcl" ".m" ".scm" ".pm" ".py" ".g" ".s?html" ".ma?k" "[Mm]akefile\\(\\.in\\)?" ".go" ".rb"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;smoothy scroll.
(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)

;;Show speedbar in same frame.
(require 'sr-speedbar)
(global-set-key (kbd "<f6>") 'sr-speedbar-toggle)


;; add package archive.
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))

;;============= Go lang config ===============
;;Load go mode
(add-to-list 'load-path "/usr/local/go/misc/emacs" t)
(require 'go-mode-load)

;; go flycheck
;(add-to-list 'load-path "/Users/harley/Workspace/go/src/github.com/dougm/goflymake")
;(require 'go-flymake)

;; gocode
(require 'go-autocomplete)
(require 'auto-complete-config)
(global-set-key (kbd "M-F") 'gofmt)

;;============= Go lang config ===============
