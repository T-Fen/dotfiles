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

  ;; Agenda files - area files + all gcal files + email notes
  (setq org-agenda-files
        '("~/org/inbox.org"
          "~/org/notes.org"              ; email notes (mu4e captures)
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
        '((sequence "TODO(t)" "NEXT(n)" "IN-PROGRESS(i)" "WAITING(w@/!)" "SOMEDAY(s)" "|" "DONE(d!)" "CANCELLED(c@)")))

  (setq org-todo-keyword-faces
        '(("TODO"        . "tomato")
          ("NEXT"        . (:foreground "#98be65" :weight bold))
          ("IN-PROGRESS" . "orange")
          ("WAITING"     . "yellow")
          ("SOMEDAY"     . (:foreground "#5699af" :weight bold))
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
           "* %?\nEntered: %U\n\n")

          ;; ── Email captures (triggered with C in mu4e view buffer) ──────────

          ("e" "Email → TODO" entry
           (file+headline "~/org/inbox.org" "Inbox")
           "* TODO %? :email:\n:PROPERTIES:\n:CREATED: %U\n:END:\n\nFrom: %:fromname <%:fromaddress>\nSubject: %:subject\nDate: %:date\n\n[[mu4e:msgid:%:message-id][Open Email]]\n"
           :empty-lines 1)

          ("r" "Email → Reply Needed" entry
           (file+headline "~/org/inbox.org" "Reply Needed")
           "* TODO Reply to %:fromname: %:subject :email:reply:\nDEADLINE: %^{Due}t\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n[[mu4e:msgid:%:message-id][Open Email]]\n"
           :empty-lines 1)

          ("w" "Email → Waiting" entry
           (file+headline "~/org/inbox.org" "Waiting")
           "* WAITING %:fromname re: %:subject :email:waiting:\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n[[mu4e:msgid:%:message-id][Open Email]]\n"
           :empty-lines 1)

          ("E" "Email → TODO with body" entry
           (file+headline "~/org/inbox.org" "Inbox")
           "* TODO %? :email:\n:PROPERTIES:\n:CREATED: %U\n:END:\n\nFrom: %:fromname <%:fromaddress>\nSubject: %:subject\n\n[[mu4e:msgid:%:message-id][Open Email]]\n\n%:body\n"
           :empty-lines 1)))

  ;; Refile targets
  (setq org-refile-targets
        '(("~/org/personal.org"         :maxlevel . 3)
          ("~/org/dynamite_doubles.org" :maxlevel . 3)
          ("~/org/pickleballhut.org"    :maxlevel . 3)
          ("~/org/revlogic.org"         :maxlevel . 3)
          ("~/org/someday.org"          :maxlevel . 1)))

  (setq org-refile-use-outline-path 'file)
  (setq org-refile-allow-creating-parent-nodes 'confirm)

  ;; Custom agenda views
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
            (tags-todo "reply"
                  ((org-agenda-overriding-header "↩️  Replies Needed\n")
                   (org-agenda-block-separator "────────────────────────")
                   (org-agenda-sorting-strategy '(deadline-up priority-down))))
            (todo "WAITING"
                  ((org-agenda-overriding-header "⏳ Waiting\n")
                   (org-agenda-block-separator "────────────────────────")))
            (tags-todo "email"
                  ((org-agenda-overriding-header "📧 Email Tasks\n")
                   (org-agenda-block-separator "────────────────────────")
                   (org-agenda-sorting-strategy '(priority-down deadline-up))))
            (todo "TODO"
                  ((org-agenda-overriding-header "📋 All Tasks by Area\n")
                   (org-agenda-sorting-strategy '(category-keep priority-down))
                   (org-agenda-block-separator "────────────────────────")))))

          ;; SPC o e  — Email triage only
          ("e" "Email Triage"
           ((tags-todo "email|reply"
                       ((org-agenda-overriding-header "📧 Email Tasks to Process")
                        (org-agenda-sorting-strategy '(deadline-up priority-down ts-down))))
            (todo "WAITING"
                  ((org-agenda-overriding-header "⏳ Waiting on Reply")
                   (org-agenda-files '("~/org/inbox.org"))))))

          ;; SPC o w  — Weekly review
          ("w" "Weekly Review"
           ((agenda ""
                    ((org-agenda-span 7)
                     (org-agenda-overriding-header "📅 This Week")))
            (tags-todo "email|reply"
                       ((org-agenda-overriding-header "📧 Open Email Tasks")
                        (org-agenda-sorting-strategy '(deadline-up priority-down))))
            (todo "WAITING"
                  ((org-agenda-overriding-header "⏳ Waiting on Someone")))
            (todo "SOMEDAY"
                  ((org-agenda-overriding-header "💭 Someday / Maybe")
                   (org-agenda-max-entries 15))))))))


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

(setq ispell-dictionary "en_US")

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
      :desc "Fetch Google Calendar" "o g" #'org-gcal-fetch)


;; ──────────────────────────────────────────
;; Calfw — visual month/week calendar grid
;; Force-loaded at startup so cfw: functions are always available
;; ──────────────────────────────────────────

(require 'calfw)
(require 'calfw-org)

(setq cfw:org-capture-template "t")
(setq cfw:face-title              '(:foreground "#61afef" :weight bold)
      cfw:face-header             '(:foreground "#98c379" :weight bold)
      cfw:face-sunday             '(:foreground "#e06c75")
      cfw:face-saturday           '(:foreground "#e5c07b")
      cfw:face-today-title        '(:foreground "#61afef" :weight bold :underline t)
      cfw:face-today              '(:foreground "#61afef"))

(defun my/open-calendar ()
  "Open calfw org calendar view."
  (interactive)
  (cfw:open-org-calendar))

(map! :leader
      :desc "Visual calendar" "o v" #'my/open-calendar)


;; ══════════════════════════════════════════
;; mu4e — Email
;; ══════════════════════════════════════════

(after! mu4e

  ;; ── Core settings ──────────────────────────────────────────────────────────
  (setq mu4e-maildir                    "~/.mail"
        mu4e-get-mail-command           "mbsync gmail-hj gmail-trey"
        mu4e-update-interval            (* 10 60)       ; sync every 10 minutes
        mu4e-index-update-in-background t
        mu4e-use-fancy-chars            t
        mu4e-view-show-images           t
        mu4e-view-image-max-width       800
        mu4e-compose-signature-auto-include nil
        mu4e-sent-messages-behavior     'delete         ; Gmail saves sent automatically

        ;; Context behavior
        mu4e-context-policy             'pick-first     ; auto-select Fastmail on open
        mu4e-compose-context-policy     'ask-always     ; always ask which account when composing

        ;; HTML rendering via gnus-article + shr (eww engine)
        mu4e-view-use-gnus              t
        mm-text-html-renderer           'shr
        mm-inline-large-images          t
        mm-discouraged-alternatives     '("text/html" "text/richtext")
        shr-color-visible-luminance-min 60
        shr-use-colors                  nil
        shr-width                       80

        ;; Threading
        mu4e-headers-show-threads       t
        mu4e-headers-include-related    t
        mu4e-headers-skip-duplicates    t               ; essential for Gmail labels
        mu4e-headers-results-limit      500

        ;; Sending via msmtp
        send-mail-function              'sendmail-send-it
        sendmail-program                (executable-find "msmtp")
        message-send-mail-function      'message-send-mail-with-sendmail
        message-sendmail-f-is-evil      t)

  ;; ── Maildir shortcuts (appear in Maildirs section of main view) ───────────
  (setq mu4e-maildir-shortcuts
    '((:maildir "/fastmail/INBOX"               :key ?f)
      (:maildir "/fastmail/INBOX.Archive"       :key ?a)
      (:maildir "/fastmail/INBOX.Sent"          :key ?s)
      (:maildir "/gmail-hj/INBOX"               :key ?h)
      (:maildir "/gmail-hj/[Gmail]/Sent Mail"   :key ?H)
      (:maildir "/gmail-trey/INBOX"             :key ?t)
      (:maildir "/gmail-trey/[Gmail]/Sent Mail" :key ?T)))

  ;; ── Contexts (one per account) ─────────────────────────────────────────────
  (setq mu4e-contexts
    (list

      ;; Fastmail: trey@fastmail.fm
      (make-mu4e-context
        :name "Fastmail"
        :match-func (lambda (msg)
          (when msg
            (string-prefix-p "/fastmail" (mu4e-message-field msg :maildir))))
        :vars '((user-mail-address    . "trey@fastmail.fm")
                (user-full-name       . "Trey Sizemore")
                (mu4e-sent-folder     . "/fastmail/INBOX.Sent")
                (mu4e-drafts-folder   . "/fastmail/INBOX.Drafts")
                (mu4e-trash-folder    . "/fastmail/INBOX.Deleted Messages")
                (mu4e-refile-folder   . "/fastmail/INBOX.Archive")
                (smtpmail-smtp-user   . "trey@fastmail.fm")))

      ;; Gmail: hjsizemore@gmail.com
      (make-mu4e-context
        :name "Gmail-HJ"
        :match-func (lambda (msg)
          (when msg
            (string-prefix-p "/gmail-hj" (mu4e-message-field msg :maildir))))
        :vars '((user-mail-address    . "hjsizemore@gmail.com")
                (user-full-name       . "Trey Sizemore")
                (mu4e-sent-folder     . "/gmail-hj/[Gmail]/Sent Mail")
                (mu4e-drafts-folder   . "/gmail-hj/[Gmail]/Drafts")
                (mu4e-trash-folder    . "/gmail-hj/[Gmail]/Trash")
                (mu4e-refile-folder   . "/gmail-hj/[Gmail]/All Mail")
                (smtpmail-smtp-user   . "hjsizemore@gmail.com")))

      ;; Gmail: trey.sizemore@gmail.com
      (make-mu4e-context
        :name "Gmail-Trey"
        :match-func (lambda (msg)
          (when msg
            (string-prefix-p "/gmail-trey" (mu4e-message-field msg :maildir))))
        :vars '((user-mail-address    . "trey.sizemore@gmail.com")
                (user-full-name       . "Trey Sizemore")
                (mu4e-sent-folder     . "/gmail-trey/[Gmail]/Sent Mail")
                (mu4e-drafts-folder   . "/gmail-trey/[Gmail]/Drafts")
                (mu4e-trash-folder    . "/gmail-trey/[Gmail]/Trash")
                (mu4e-refile-folder   . "/gmail-trey/[Gmail]/All Mail")
                (smtpmail-smtp-user   . "trey.sizemore@gmail.com")))))

  ;; ── Bookmarks ──────────────────────────────────────────────────────────────
  (add-to-list 'mu4e-bookmarks
    '(:name "All Inboxes"
      :query "maildir:/fastmail/INBOX OR maildir:/gmail-hj/INBOX OR maildir:/gmail-trey/INBOX"
      :key ?i))
  (add-to-list 'mu4e-bookmarks
    '(:name "All Unread"
      :query "flag:unread AND NOT flag:trashed"
      :key ?u))

  ;; ── View actions (trigger with 'a' in view buffer) ─────────────────────────
  (add-to-list 'mu4e-view-actions
    '("view in browser" . mu4e-action-view-in-browser) t)   ; a v
  (add-to-list 'mu4e-view-actions
    '("xdg browser" . my/mu4e-view-in-xdg-browser) t)       ; a x
  (add-to-list 'mu4e-view-actions
    '("extract links" . my/mu4e-extract-links) t)            ; a e

  ;; ── Keybinds ───────────────────────────────────────────────────────────────
  (map! :map mu4e-view-mode-map
        :n "C" #'mu4e-org-store-and-capture))               ; capture email to org


;; ── mu4e agenda keybinds (alongside existing SPC o g / SPC o v) ───────────
(map! :leader
      :desc "Open mu4e"       "o m" #'mu4e
      :desc "Email triage"    "o e" (lambda () (interactive) (org-agenda nil "e"))
      :desc "Weekly review"   "o w" (lambda () (interactive) (org-agenda nil "w")))


;; ── org-mu4e link support ──────────────────────────────────────────────────
(after! mu4e
(require 'mu4e-org)
(setq mu4e-org-link-query-in-headers-mode nil))


;; ── msmtp: auto-select sending account from From header ───────────────────
(defun my/msmtp-select-account ()
  "Set msmtp --account flag based on the From address when sending."
  (save-excursion
    (let* ((from (message-fetch-field "from"))
           (account (cond
                     ((string-match "trey@fastmail.fm" from)        "fastmail")
                     ((string-match "hjsizemore@gmail.com" from)    "gmail-hj")
                     ((string-match "trey.sizemore@gmail.com" from) "gmail-trey")
                     (t "fastmail"))))
      (setq message-sendmail-extra-arguments (list "--account" account)))))

(add-hook 'message-send-hook #'my/msmtp-select-account)


;; ── Open HTML part of email in system browser ─────────────────────────────
(defun my/mu4e-view-in-xdg-browser (msg)
  "Save the HTML part of MSG to a temp file and open in system browser."
  (let* ((html (mu4e-message-field msg :body-html))
         (tmpfile (make-temp-file "mu4e-" nil ".html")))
    (if html
        (progn (with-temp-file tmpfile (insert html))
               (start-process "xdg-open" nil "xdg-open" tmpfile))
      (message "No HTML part found in this message."))))


;; ── Extract all URLs from email into a searchable list ────────────────────
(defun my/mu4e-extract-links (msg)
  "Extract all URLs from MSG and open selected one via completing-read."
  (let* ((body (or (mu4e-message-field msg :body-html)
                   (mu4e-message-field msg :body-txt) ""))
         (urls '()))
    (with-temp-buffer
      (insert body)
      (goto-char (point-min))
      (while (re-search-forward "https?://[^ \t\n\r<>\"']+" nil t)
        (push (match-string 0) urls)))
    (if urls
        (browse-url (completing-read "Open URL: " (delete-dups (reverse urls))))
      (message "No URLs found in this message."))))
