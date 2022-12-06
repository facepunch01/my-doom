(beacon-mode 1)

(setq user-full-name "Jake Hackl"
      user-mail-address "jakerhackl@gmail.com")

(setq doom-font (font-spec :family "Iosevka Comfy" :size 21))
(setq doom-variable-pitch-font (font-spec :family "Iosevka Comfy" :size 21))
(setq doom-theme 'doom-dracula)
(setq modus-themes-mode-line '(borderless (padding . 4)))
(setq display-line-numbers-type t)
(setq ispell-program-name "C:/msys64/mingw64/bin/aspell.exe"
      ispell-dictionary "en_US")

(setq org-directory "~/org/")
(setq org-display-inline-images t) (setq org-redisplay-inline-images t) (setq org-startup-with-inline-images "inlineimages")
(setq org-image-actual-width 600)
(setq electric-quote-replace-double t)
(setq electric-quote-paragraph t) ;; default
(setq electric-quote-comment t) ;; default.
(electric-quote-mode)
(add-to-list 'electric-quote-inhibit-functions (lambda () (org-babel-when-in-src-block)))
(add-hook 'org-mode-hook #'anki-editor-mode) ;; anki notes
;; Org-capture templates
(defun add-name ()
   (setq Anki-capture (format "%s" (read-string "input name:"))))
(after! org
  (add-to-list 'org-capture-templates
               '("a" "Anki basic"
                 entry
                 (function add-name)
                 "** %(format \"%s\" Anki-capture)   %^g\n:PROPERTIES:\n:ANKI_NOTE_TYPE: Basic\n:ANKI_DECK: Main\n:END:\n*** Front\n%?\n*** Back\n%(x-get-clipboard)\n"))
  (add-to-list 'org-capture-templates
               '("A" "Anki cloze"
                 entry
                 (function add-name)
                 "** %(format \"%s\" Anki-capture)   %^g\n:PROPERTIES:\n:ANKI_NOTE_TYPE: Cloze\n:ANKI_DECK: Main\n:END:\n*** Text\n%(x-get-clipboard)\n*** Extra\n")))

;; Allow Emacs to access content from clipboard.
(setq select-enable-clipboard t
      select-enable-primary t)
(use-package! anki-editor
             :bind (:map org-mode-map
                         ("<f12>" . anki-editor-cloze-region-auto-incr)
                         ("<f11>" . anki-editor-cloze-region-dont-incr)
                         ("<f10>" . anki-editor-reset-cloze-number)
                         ("<f9>"  . anki-editor-push-tree))
             :hook (org-capture-after-finalize . anki-editor-reset-cloze-number)) ; Reset cloze-number after each capture.
(after! anki-editor
  (defun anki-editor-cloze-region-auto-incr (&optional arg)
    "Cloze region without hint and increase card number."
    (interactive)
    (anki-editor-cloze-region my-anki-editor-cloze-number "")
    (setq my-anki-editor-cloze-number (1+ my-anki-editor-cloze-number))
    (forward-sexp))
  (defun anki-editor-cloze-region-dont-incr (&optional arg)
    "Cloze region without hint using the previous card number."
    (interactive)
    (anki-editor-cloze-region (1- my-anki-editor-cloze-number) "")
    (forward-sexp))
  (defun anki-editor-reset-cloze-number (&optional arg)
    "Reset cloze number to ARG or 1"
    (interactive)
    (setq my-anki-editor-cloze-number (or arg 1)))
  (defun anki-editor-push-tree ()
    "Push all notes under a tree."
    (interactive)
    (anki-editor-push-notes '(4))
    (anki-editor-reset-cloze-number))
  (anki-editor-reset-cloze-number))

(require 'org-download "C:/Users/Jake/org-download/org-download.el")
(add-hook 'org-mode-hook 'org-download-enable)
(after! org-download
  (setq org-download-screenshot-method "i_view64 /capture=4 /convert=\"%s\""
        org-download-insert-annotate nil)
  (setq-default org-download-image-dir "C:/Users/Jake/org-roam/screenshots")
  (setq-default org-download-heading-lvl nil))

(setq exec-path (add-to-list 'exec-path "C:/Program Files/Git/bin"))
(setenv "PATH" (concat "C:\\Program Files\\Git\\bin;" (getenv "PATH")))

(require 'khoj "c:/users/Jake/khoj-emacs/khoj.el")

(setq
 ;; Edit settings
 org-auto-align-tags nil
 org-tags-column 0
 org-fold-catch-invisible-edits 'show-and-error
 org-special-ctrl-a/e t
 org-insert-heading-respect-content t

 ;; Org styling, hide markup etc.
 org-hide-emphasis-markers t
 org-pretty-entities t
 org-ellipsis "…"
 org-modern-list
  '((?+ . "+")
    (?- . "–")
    (?* . "•"))

 ;; Agenda styling
 org-agenda-tags-column 0
 org-agenda-time-grid
 '((daily today require-timed)
   (800 1000 1200 1400 1600 1800 2000)
   " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
 org-agenda-current-time-string
 "⭠ now ─────────────────────────────────────────────────")
(global-set-key (kbd "<f5>") (lambda () (interactive) (find-file "~/org-roam/20220914215450-index.org")))
(global-org-modern-mode)

(defun my/org-roam-filter-by-tag (tag-name)
  (lambda (node)
    (member tag-name (org-roam-node-tags node))))

(defun my/org-roam-list-notes-by-tag (tag-name)
  (mapcar #'org-roam-node-file
          (seq-filter
           (my/org-roam-filter-by-tag tag-name)
           (org-roam-node-list))))

(defun my/org-roam-refresh-agenda-list ()
  (interactive)
  (setq org-agenda-files (my/org-roam-list-notes-by-tag "subject")))
(use-package! org-roam
  :custom
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
       :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: ${title}\n")
       :unnarrowed t)))
  (org-roam-directory "~/org-roam")

  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)))
  :init
  (my/org-roam-refresh-agenda-list)

(use-package! websocket
    :after org-roam)

(use-package! org-roam-ui
    :after org-roam ;; or :after org
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
;;  :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))

(setq evil-want-C-u-scroll t)
(after! evil
  (evil-global-set-key 'normal (kbd "ZW") 'save-buffer))
(global-set-key [remap dabbrev-expand] 'hippie-expand)
(map! :leader :desc "Hippe-expand" :n "TAB" #'hippe-expand)
(map! :map 'org-mode-map :desc "Next link item" :n "<f6>" #'org-next-link)
(map! :map 'org-mode-map :desc "Next link item" :n "S-<f6>" #'org-previous-link)
(map! :leader :desc "khoj" :n "k" #'khoj)
(setq-default abbrev-mode t)

(setq org-latex-compiler "xelatex")
(setq org-export-with-toc nil)
(setq org-latex-pdf-process
      (list (concat "latexmk -"
                    org-latex-compiler
                    " -recorder -synctex=1 -bibtex-cond %b")))
(setq org-latex-default-packages-alist
      '(("" "graphicx" t)
        ("" "grffile" t)
        ("" "longtable" nil)
        ("" "wrapfig" nil)
        ("" "rotating" nil)
        ("normalem" "ulem" t)
        ("" "amsmath" t)
        ("" "textcomp" t)
        ("" "amssymb" t)
        ("" "capt-of" nil)
        ("" "hyperref" nil)))
(setq org-latex-classes
'(("article"
"\\RequirePackage{fix-cm}
\\PassOptionsToPackage{svgnames}{xcolor}
\\documentclass[11pt]{article}
\\usepackage{fontspec}
\\setmainfont{Iosevka Comfy}
\\setsansfont[Scale=MatchLowercase]{Iosevka Comfy}
\\setmonofont[Scale=MatchLowercase]{Iosevka Comfy}
\\usepackage{sectsty}
\\allsectionsfont{\\sffamily}
\\usepackage{enumitem}
\\setlist[description]{style=unboxed,font=\\sffamily\\bfseries}
\\usepackage{listings}
\\lstset{frame=single,aboveskip=1em,
	framesep=.5em,backgroundcolor=\\color{AliceBlue},
	rulecolor=\\color{LightSteelBlue},framerule=1pt}
\\usepackage{xcolor}
\\newcommand\\basicdefault[1]{\\scriptsize\\color{Black}\\ttfamily#1}
\\lstset{basicstyle=\\basicdefault{\\spaceskip1em}}
\\lstset{literate=
	    {§}{{\\S}}1
	    {©}{{\\raisebox{.125ex}{\\copyright}\\enspace}}1
	    {«}{{\\guillemotleft}}1
	    {»}{{\\guillemotright}}1
	    {Á}{{\\'A}}1
	    {Ä}{{\\\"A}}1
	    {É}{{\\'E}}1
	    {Í}{{\\'I}}1
	    {Ó}{{\\'O}}1
	    {Ö}{{\\\"O}}1
	    {Ú}{{\\'U}}1
	    {Ü}{{\\\"U}}1
	    {ß}{{\\ss}}2
	    {á}{{\\`a}}1
	    {à}{{\\'a}}1
	    {ä}{{\\\"a}}1
	    {é}{{\\'e}}1
	    {í}{{\\'i}}1
	    {ó}{{\\'o}}1
	    {ö}{{\\\"o}}1
	    {ú}{{\\'u}}1
	    {ü}{{\\\"u}}1
	    {¹}{{\\textsuperscript1}}1
            {²}{{\\textsuperscript2}}1
            {³}{{\\textsuperscript3}}1
	    {i}{{\\i}}1
	    {-}{{---}}1
	    {'}{{'}}1
	    {.}{{\\dots}}1
            {?}{{$\\hookleftarrow$}}1
	    { }{{\\textvisiblespace}}1,
	    keywordstyle=\\color{DarkGreen}\\bfseries,
	    identifierstyle=\\color{DarkRed},
	    commentstyle=\\color{Gray}\\upshape,
	    stringstyle=\\color{DarkBlue}\\upshape,
	    emphstyle=\\color{Chocolate}\\upshape,
	    showstringspaces=false,
	    columns=fullflexible,
	    keepspaces=true}
\\usepackage[a4paper,margin=1in,left=1.5in]{geometry}
\\usepackage{parskip}
\\makeatletter
\\renewcommand{\\maketitle}{%
  \\begingroup\\parindent0pt
  \\sffamily
  \\Huge{\\bfseries\\@title}\\par\\bigskip
  \\LARGE{\\bfseries\\@author}\\par\\medskip
  \\normalsize\\@date\\par\\bigskip
  \\endgroup\\@afterindentfalse\\@afterheading}
\\makeatother
[DEFAULT-PACKAGES]
\\hypersetup{linkcolor=Blue,urlcolor=DarkBlue,
  citecolor=DarkRed,colorlinks=true}
\\AtBeginDocument{\\renewcommand{\\UrlFont}{\\ttfamily}}
[PACKAGES]
[EXTRA]"
("\\section{%s}" . "\\section*{%s}")
("\\subsection{%s}" . "\\subsection*{%s}")
("\\subsubsection{%s}" . "\\subsubsection*{%s}")
("\\paragraph{%s}" . "\\paragraph*{%s}")
("\\subparagraph{%s}" . "\\subparagraph*{%s}"))

("report" "\\documentclass[11pt]{report}"
("\\part{%s}" . "\\part*{%s}")
("\\chapter{%s}" . "\\chapter*{%s}")
("\\section{%s}" . "\\section*{%s}")
("\\subsection{%s}" . "\\subsection*{%s}")
("\\subsubsection{%s}" . "\\subsubsection*{%s}"))

("book" "\\documentclass[11pt]{book}"
("\\part{%s}" . "\\part*{%s}")
("\\chapter{%s}" . "\\chapter*{%s}")
("\\section{%s}" . "\\section*{%s}")
("\\subsection{%s}" . "\\subsection*{%s}")
("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))
(setq cdlatex-env-alist
 '(("equation*" "\\begin{equation*}\nAUTOLABEL\n?\n\\end{equation*}\n" nil)))
(setq cdlatex-command-alist
 '(("equ*" "Insert equation* env"   "" cdlatex-environment ("equation*") t nil)))
(add-hook 'org-mode-hook #'turn-on-org-cdlatex)

;(use-package! eaf
;  :load-path "~/.eaf/"
;  :init
;  :custom
;  (eaf-browser-continue-where-left-off t)
;  (eaf-browser-enable-adblocker t)
;  (browse-url-browser-function 'eaf-open-browser) ;; Make EAF Browser my default browser
;  :config
;  (defalias 'browse-web #'eaf-open-browser)
;  (require 'eaf-2048)
;  (require 'eaf-browser)
;  (require 'eaf-demo)
;  (require 'eaf-markdown-previewer)
;  (require 'eaf-org-previewer)
;  (require 'eaf-pdf-viewer)
;  (when (display-graphic-p)
;    (require 'eaf-all-the-icons))
;  (require 'eaf-evil)
;  (define-key key-translation-map (kbd "SPC")
;    (lambda (prompt)
;      (if (derived-mode-p 'eaf-mode)
;          (pcase eaf--buffer-app-name
;            ("browser" (if  (string= (eaf-call-sync "call_function" eaf--buffer-id "is_focus") "True")
;                           (kbd "SPC")
;                         (kbd eaf-evil-leader-key)))
;            ("pdf-viewer" (kbd eaf-evil-leader-key))
;            ("image-viewer" (kbd eaf-evil-leader-key))
;            (_  (kbd "SPC")))
;        (kbd "SPC")))))

(after! good-scroll
       (good-scroll-mode 1))
(setq ispell-list-command "--list")
