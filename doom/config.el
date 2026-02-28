;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ──────────────────────────────────────────
;; Core Emacs Settings
;; ──────────────────────────────────────────

(setq doom-font (font-spec :family "Hack Nerd Font" :size 14))
(setq doom-theme 'doom-one)
(setq display-line-numbers-type t)


;; ──────────────────────────────────────────
;; Org Settings (must be set before org loads)
;; ──────────────────────────────────────────

(setq org-directory "~/org/")
(setq org-default-notes-file "~/org/inbox.org")


;; ──────────────────────────────────────────
;; Google Calendar credentials
;; Loaded from private file — NOT stored in this config
;; File lives at ~/.doom.d/private/org-gcal-credentials.el
;; That file is gitignored and must be created manually on each machine
;; ──────────────────────────────────────────

(let ((creds (expand-file-name "private/org-gcal-credentials.el" doom-private-dir)))
  (when (file-exists-p creds)
    (load creds)))


;; ──────────────────────────────────────────
;; Org Configuration
;; ──────────────────────────────────────────

(after! org

  ;; Agenda files - area files + all gcal files
  (setq org-agenda-files
        '("~/org/inbox.org"
          "~/org/personal.org"
          "~/org/dynamite_doubles.org"
          "~/org/pickleballhut.org"
          "~/org/revlogic.org"
          "~/org/gcal-personal.org"
          "~/org/gcal-holidays.org"
          "~/org/gcal-dynamite-doubles.org"
          "~/org/gcal-pickleballhut.org"
          "~/org/gcal-revlogic.org"))

  ;; TODO keyword workflow
  (setq org-todo-keywords
        '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))

  (setq org-todo-keyword-faces
        '(("TODO"        . "tomato")
          ("IN-PROGRESS" . "orange")
          ("WAITING"     . "yellow")
          ("DONE"        . "green")
          ("CANCELLED"   . "grey")))

  ;; Log when tasks are completed
  (setq org-log-done 'time)

  ;; Follow links with Enter
  (setq org-return-follows-link t)

  ;; Syntax highlighting inside code blocks
  (setq org-src-fontify-natively t)

  ;; Visual indentation
  (setq org-startup-indented t)

  ;; Warn about deadlines 7 days out
  (setq org-deadline-warning-days 7)

  ;; Capture templates
  (setq org-capture-templates
        '(("t" "Todo" entry
           (file "~/org/inbox.org")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")

          ("n" "Note" entry
           (file "~/org/inbox.org")
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")

          ("m" "Meeting" entry
           (file "~/org/inbox.org")
           "* %? :meeting:\n:PROPERTIES:\n:DATE: %T\n:ATTENDEES: \n:END:\n\n** Notes\n\n** Action Items\n")

          ("j" "Journal" entry
           (file+datetree "~/org/journal.org")
           "* %?\nEntered: %U\n\n")))

  ;; Refile targets
  (setq org-refile-targets
        '(("~/org/personal.org"         :maxlevel . 3)
          ("~/org/dynamite_doubles.org" :maxlevel . 3)
          ("~/org/pickleballhut.org"    :maxlevel . 3)
          ("~/org/revlogic.org"         :maxlevel . 3)
          ("~/org/someday.org"          :maxlevel . 1)))

  (setq org-refile-use-outline-path 'file)
  (setq org-refile-allow-creating-parent-nodes 'confirm)

  ;; Custom agenda dashboard
  (setq org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda ""
                    ((org-agenda-span 7)
                     (org-agenda-start-on-weekday 1)
                     (org-agenda-show-all-dates nil)
                     (org-deadline-warning-days 7)
                     (org-agenda-block-separator "────────────────────────")
                     (org-agenda-overriding-header "📅 Week Ahead\n")))
            (todo "IN-PROGRESS"
                  ((org-agenda-overriding-header "🔥 In Progress\n")
                   (org-agenda-block-separator "────────────────────────")))
            (todo "WAITING"
                  ((org-agenda-overriding-header "⏳ Waiting\n")
                   (org-agenda-block-separator "────────────────────────")))
            (todo "TODO"
                  ((org-agenda-overriding-header "📋 All Tasks by Area\n")
                   (org-agenda-sorting-strategy '(category-keep priority-down))
                   (org-agenda-block-separator "────────────────────────"))))))))


;; ──────────────────────────────────────────
;; Org-Modern
;; ──────────────────────────────────────────

(after! org-modern
  (add-hook 'org-mode-hook #'org-modern-mode))


;; ──────────────────────────────────────────
;; Org Agenda — disable Evil so f/b/j/d/w/m keys work
;; ──────────────────────────────────────────

(evil-set-initial-state 'org-agenda-mode 'emacs)


;; ──────────────────────────────────────────
;; Spell Check
;; ──────────────────────────────────────────

(after! flyspell
  (add-hook 'org-mode-hook #'flyspell-mode)
  (add-hook 'text-mode-hook #'flyspell-mode)
  (add-hook 'markdown-mode-hook #'flyspell-mode))


;; ──────────────────────────────────────────
;; Org-Roam
;; ──────────────────────────────────────────

(setq org-roam-directory "~/org/roam/")
(setq org-roam-db-autosync-mode t)


;; ──────────────────────────────────────────
;; Org-Journal
;; ──────────────────────────────────────────

(setq org-journal-dir "~/org/journal/"
      org-journal-date-format "%A, %d %B %Y"
      org-journal-file-type 'weekly)


;; ──────────────────────────────────────────
;; Google Calendar — org-gcal
;; ──────────────────────────────────────────

(after! org-gcal
  (setq org-gcal-fetch-file-alist
        '(("hjsizemore@gmail.com"
           . "~/org/gcal-personal.org")
          ("en.usa#holiday@group.v.calendar.google.com"
           . "~/org/gcal-holidays.org")
          ("trey@dynamitedoubles.com"
           . "~/org/gcal-dynamite-doubles.org")
          ("trey@pickleballhut.com"
           . "~/org/gcal-pickleballhut.org")
          ("trey@rev-logic.com"
           . "~/org/gcal-revlogic.org"))

        org-gcal-down-days 30
        org-gcal-up-days   30
        org-gcal-remove-api-cancelled-events t)

  (add-hook 'org-agenda-mode-hook #'org-gcal-fetch))


;; ──────────────────────────────────────────
;; Keybindings
;; SPC o g → manual Google Calendar sync
;; SPC o v → open calfw visual calendar
;; ──────────────────────────────────────────

(map! :leader
      :desc "Fetch Google Calendar" "o g" #'org-gcal-fetch
      :desc "Visual calendar"       "o v" #'cfw:open-org-calendar)


;; ──────────────────────────────────────────
;; Calfw — visual month/week calendar grid
;; ──────────────────────────────────────────

(after! calfw
  (setq cfw:org-capture-template "t"))

(after! calfw-org
  (setq cfw:face-title              '(:foreground "#61afef" :weight bold)
        cfw:face-header             '(:foreground "#98c379" :weight bold)
        cfw:face-sunday             '(:foreground "#e06c75")
        cfw:face-saturday           '(:foreground "#e5c07b")
        cfw:face-today-title        '(:foreground "#61afef" :weight bold :underline t)
        cfw:face-today              '(:foreground "#61afef")))
