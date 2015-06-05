;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Version check.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (< emacs-major-version 24)
  (error "This setup requires Emacs v24, or higher. You have: v%d" emacs-major-version))

(setenv "PATH" (concat (getenv "PATH") ":/bin"))
(setq exec-path (append exec-path '("/bin")))
(setq default-directory "~/")
(setq make-backup-files nil)

; use emacs ls for dired
(setq ls-lisp-use-insert-directory-program nil)
(require 'ls-lisp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Packaging setup.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)
(package-initialize)

(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://melpa-stable.milkbox.net/packages/"))
(add-to-list 'package-archives
             '("org" . "http://orgmode.org/elpa/"))

(defvar my-packages '(ag
              auto-complete
		      cider
		      elscreen ace-jump-mode
              evil
		      evil-leader
		      evil-nerd-commenter
		      evil-paredit
		      evil-surround
		      evil-tabs
		      expand-region
		      helm helm-descbinds
		      key-chord
		      magit
		      nrepl-eval-sexp-fu
		      paredit smartparens
		      powerline
		      powerline-evil
		      rainbow-delimiters highlight
		      recentf smart-mode-line
		      rust-mode
		      smooth-scrolling
              )
"A list of packages to check for and install at launch.")

(defun my-missing-packages ()
  (let (missing-packages)
    (dolist (package my-packages (reverse missing-packages))
      (or (package-installed-p package)
		  (push package missing-packages)))))

(defun ensure-my-packages ()
  (let ((missing (my-missing-packages)))
    (when missing
      ;; Check for new packages (package versions)
      (package-refresh-contents)
      ;; Install the missing packages
      (mapc (lambda (package)
			  (when (not (package-installed-p package))
				(package-install package)))
			missing)
      ;; Close the compilation log.
      (let ((compile-window (get-buffer-window "*Compile-Log*")))
		(if compile-window
		  (delete-window compile-window))))))

(ensure-my-packages)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Early requirements.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; system details
(defun krig-macp () (string-match "apple-darwin" system-configuration))
(defun krig-linuxp () (string-match "linux" system-configuration))
(defun krig-winp () (eq system-type 'windows-nt))

;;; basic settings
(progn
  (setq comment-style 'indent)
  (setq make-backup-files nil)
  (setq auto-save-default nil)
  (setq inhibit-startup-message t)
  (auto-compression-mode 1)
  (setq warning-minimum-level :error)
  (fset 'yes-or-no-p 'y-or-n-p)
  (blink-cursor-mode -1)
  (show-paren-mode t)
  (line-number-mode t)
  (column-number-mode t)
  (winner-mode 1) ;; window layout: c-c <left> = undo, c-c <right> = redo
  (global-auto-revert-mode t)
  (setq calendar-week-start-day 1)
  (delete-selection-mode t) ; delete selection when adding new text (like "normal" editors)
  (setq mark-even-if-inactive nil)
  (setq frame-title-format "%b %*") ; nicer window names
  (setq initial-scratch-message ";)\n") ; cleaner scratch buffers
  (setq compilation-skip-threshold 2) ; jump directly to errors with M-p/M-n in compilation-mode
  (setq org-startup-indented t)
  (setq-default ispell-program-name "aspell")
  (setq vc-follow-symlinks t)

  (when (display-graphic-p)
    (scroll-bar-mode -1)
    (tooltip-mode -1)
    (tool-bar-mode -1)))

;; load common lisp
(require 'cl)

(require 'auto-complete)
(add-to-list 'ac-modes 'rust-mode)

; required for tabs later on
(elscreen-start)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Customizations (from M-x customze-*)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-auto-show-menu t)
 '(ac-auto-start t)
 '(ac-show-menu-immediately-on-auto-complete t)
 '(custom-safe-themes
   (quote
    ("6a37be365d1d95fad2f4d185e51928c789ef7a4ccf17e7ca13ad63a8bf5b922f" "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" default)))
 '(nrepl-hide-special-buffers t)
 '(nrepl-popup-stacktraces-in-repl t)
 '(recentf-max-saved-items 50))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Basic Vim Emulation.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'powerline)
(powerline-default-theme)

(global-auto-complete-mode t)
(global-evil-surround-mode t)

(evil-mode t)
(global-evil-tabs-mode 1)

(evil-ex-define-cmd "Exp[lore]" 'dired-jump)
(evil-ex-define-cmd "color[scheme]" 'customize-themes)

(setq evil-emacs-state-cursor '("red" box))
(setq evil-normal-state-cursor '("green" box))
(setq evil-visual-state-cursor '("orange" box))
(setq evil-insert-state-cursor '("red" bar))
(setq evil-replace-state-cursor '("red" bar))
(setq evil-operator-state-cursor '("red" hollow))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Nice-to-haves...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; auto-indent after return key
(define-key global-map (kbd "RET") 'newline-and-indent)

; no backups
(setq make-backup-files nil)

; ignore bell
(setq ring-bell-function 'ignore)

; save cursors location
(setq save-place-file "~/.emacs.d/saveplace")
(setq-default save-place t)
(require 'saveplace)

(require 'expand-region)
(global-set-key (kbd "C-'") 'er/expand-region)
(global-set-key (kbd "M-'") 'er/expand-region)

(helm-mode t)
(helm-descbinds-mode t)
(recentf-mode t)

(setq scroll-margin 5
scroll-conservatively 9999
scroll-step 1)

(if after-init-time
  (sml/setup)
  (add-hook 'after-init-hook 'sml/setup))

(evil-define-key 'normal global-map
  "\M-p" 'helm-mini
  "\M-x" 'helm-M-x
  "\C-x\C-f" 'helm-find-files
  "q:" 'helm-complex-command-history
  "\\\\w" 'evil-ace-jump-word-mode)

; Keep emacs line navigation
(define-key evil-normal-state-map "\C-n" 'evil-next-line)
(define-key evil-insert-state-map "\C-n" 'evil-next-line)
(define-key evil-visual-state-map "\C-n" 'evil-next-line)
(define-key evil-normal-state-map "\C-p" 'evil-previous-line)
(define-key evil-insert-state-map "\C-p" 'evil-previous-line)
(define-key evil-visual-state-map "\C-p" 'evil-previous-line)

;;; Uncomment these key-chord lines if you like that "remap 'jk' to ESC" trick.
(key-chord-mode t)
(key-chord-define evil-insert-state-map "jk" 'evil-normal-state)

; Travel visual lines in evil mode
(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)

;; esc quits
(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
(global-set-key [escape] 'evil-exit-emacs-state)

;; Vim key bindings
(require 'evil-leader)
(evil-leader/set-leader ",")
(setq evil-leader/in-all-states 1)
(global-evil-leader-mode)
(evil-leader/set-key
  "ci" 'evilnc-comment-or-uncomment-lines
  "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
  "ll" 'evilnc-quick-comment-or-uncomment-to-the-line
  "cc" 'evilnc-copy-and-comment-lines
  "cp" 'evilnc-comment-or-uncomment-paragraphs
  "cr" 'comment-or-uncomment-region
  "cv" 'evilnc-toggle-invert-comment-line-by-line
  "\\" 'evilnc-comment-operator ; if you prefer backslash key
)

; indents
(setq-default tab-width 4 indent-tabs-mode nil)
(setq-default c-basic-offset 4 c-default-style "bsd")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Filetype-style hooks.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun standard-lisp-modes ()
  (require 'nrepl-eval-sexp-fu)
  (rainbow-delimiters-mode t)
  (require 'evil-paredit)
  (paredit-mode t)
  (evil-paredit-mode t)
  (local-set-key (kbd "RET") 'newline-and-indent))

;;; Emacs Lisp
(add-hook 'emacs-lisp-mode-hook
		  '(lambda ()
			 (standard-lisp-modes)))

(evil-define-key 'normal emacs-lisp-mode-map
  "\M-q" 'paredit-reindent-defun
										;"\C-c\C-c" 'eval-defun
  "K" '(lambda ()
		 (interactive)
		 (describe-function (symbol-at-point))))

;;;; Clojure
(add-hook 'clojure-mode-hook
    '(lambda ()




	    (standard-lisp-modes)

	    (mapc '(lambda (char)
			    (modify-syntax-entry char "w" clojure-mode-syntax-table))
		    '(?- ?_ ?/ ?< ?> ?: ?' ?.))

	    (require 'clojure-test-mode)

	    (require 'ac-nrepl)
	    (add-hook 'nrepl-mode-hook 'ac-nrepl-setup)
	    (add-hook 'nrepl-interaction-mode-hook 'ac-nrepl-setup)
	    (add-hook 'nrepl-interaction-mode-hook 'nrepl-turn-on-eldoc-mode)
	    (add-to-list 'ac-modes 'nrepl-mode)))

(evil-define-key 'normal clojure-mode-map
  "\M-q" 'paredit-reindent-defun
  "gK" 'nrepl-src
  "K"  'ac-nrepl-popup-doc)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mac specific.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)

(when (display-graphic-p)
  (when (krig-macp)
    (setq mac-allow-anti-aliasing t)
      (set-frame-font "Inconsolata-15")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Themes.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(load-theme 'wombat t)
