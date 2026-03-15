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

;; Use passphrase-free GPG key for plstore — no prompts ever
;; Key created with: gpg --batch --gen-key (no-protection, plstore@localhost)
(setq plstore-encrypt-to "plstore@localhost")
(setq plstore-cache-passphrase-for-symmetric-encryption t)


;; ──────────────────────────────────────────
;; Org Configuration
;; ──────────────────────────────────────────

(after! org

  ;; ── Agenda files ───────────────────────────────────────────────────────────
  ;; Area files (renamed to hyphenated convention)
  ;; Note: if you had ~/org/dynamite_doubles.org or ~/org/pickleballhut.org,
  ;;       rename them: mv dynamite_doubles.org dynamite-doubles.org, etc.
  (setq org-agenda-files
        '("~/org/inbox.org"
          "~/org/notes.org"                    ; mu4e capture notes
          "~/org/personal.org"
          "~/org/dynamite-doubles.org"         ; renamed from dynamite_doubles.org
          "~/org/pickleball-hut.org"           ; renamed from pickleballhut.org
          "~/org/revlogic.org"
          "~/org/gcal-personal.org"
          "~/org/gcal-holidays.org"
          "~/org/gcal-dynamite-doubles.org"
          "~/org/gcal-pickleballhut.org"
          "~/org/gcal-revlogic.org"))

  ;; ── TODO keyword workflow ──────────────────────────────────────────────────
  ;; Promotion ladder:  TODO → NEXT (this week) → IN-PROGRESS → DONE
  ;; Holding states:    WAITING (blocked), SOMEDAY (not now)
  ;; Dashboard shows NEXT + IN-PROGRESS only — keeps the view clean.
  ;; To surface a task this week: press t → n on any TODO heading.
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

  ;; ── Skip function: exclude 90-Day Scaling Plan from main TODO dump ─────────
  ;; The 90-Day Plan has 246 tasks tagged :90day: at the parent heading.
  ;; They appear in "Week Ahead" automatically via their DEADLINE dates.
  ;; This skip function keeps them out of the NEXT/TODO list views so the
  ;; dashboard stays manageable. Remove the tag to re-enable a task.
  (defun my/org-skip-90day-subtree ()
    "Skip any entry that is inside or tagged with :90day:."
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (if (member "90day" (org-get-tags))
          subtree-end
        nil)))

  ;; ── Capture templates ──────────────────────────────────────────────────────
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

  ;; ── Refile targets ─────────────────────────────────────────────────────────
  ;; maxlevel 4 lets you refile into subproject headings (e.g. Course Content)
  (setq org-refile-targets
        '(("~/org/personal.org"          :maxlevel . 4)
          ("~/org/dynamite-doubles.org"  :maxlevel . 4)
          ("~/org/pickleball-hut.org"    :maxlevel . 4)
          ("~/org/revlogic.org"          :maxlevel . 4)
          ("~/org/inbox.org"             :maxlevel . 2)
          ("~/org/someday.org"           :maxlevel . 1)))

  (setq org-refile-use-outline-path 'file)
  (setq org-refile-allow-creating-parent-nodes 'confirm)

  ;; ── Custom agenda views ────────────────────────────────────────────────────
  (setq org-agenda-custom-commands
        '(

          ;; ── "d" Dashboard — SPC o a d ──────────────────────────────────────
          ;; Primary daily view. Shows the 7-day calendar (with gcal events
          ;; and deadlines from all files), active items, and blocked items.
          ;;
          ;; The 90-Day Scaling Plan tasks are intentionally EXCLUDED from
          ;; the NEXT/In-Progress blocks. They surface in "Week Ahead"
          ;; automatically when their DEADLINE is within 7 days.
          ;; To promote a 90-day task to active: open pickleball-hut.org,
          ;; find the task, press t → n (NEXT). It will appear in dashboard.
          ("d" "Dashboard"
           ((agenda ""
                    ((org-agenda-span 7)
                     (org-agenda-start-day nil)
                     (org-agenda-start-on-weekday nil)
                     (org-agenda-show-all-dates nil)
                     (org-deadline-warning-days 7)
                     (org-agenda-block-separator "────────────────────────")
                     (org-agenda-overriding-header "📅 Week Ahead\n")))

            (todo "NEXT"
                  ((org-agenda-overriding-header "⚡ Up Next  (promote TODO → NEXT to add here)\n")
                   (org-agenda-sorting-strategy '(category-keep priority-down))
                   (org-agenda-block-separator "────────────────────────")
                   (org-agenda-skip-function #'my/org-skip-90day-subtree)))

            (todo "IN-PROGRESS"
                  ((org-agenda-overriding-header "🔥 In Progress\n")
                   (org-agenda-block-separator "────────────────────────")
                   (org-agenda-skip-function #'my/org-skip-90day-subtree)))

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
                   (org-agenda-sorting-strategy '(priority-down deadline-up))))))

          ;; ── "e" Email Triage — SPC o e ─────────────────────────────────────
          ("e" "Email Triage"
           ((tags-todo "email|reply"
                       ((org-agenda-overriding-header "📧 Email Tasks to Process")
                        (org-agenda-sorting-strategy '(deadline-up priority-down ts-down))))
            (todo "WAITING"
                  ((org-agenda-overriding-header "⏳ Waiting on Reply")
                   (org-agenda-files '("~/org/inbox.org"))))))

          ;; ── "w" Weekly Review — SPC o w ────────────────────────────────────
          ;; Use this every Sunday (or Friday) to:
          ;;   1. Check what's coming up this week (agenda block)
          ;;   2. Process open email tasks
          ;;   3. Review WAITING items — follow up or cancel
          ;;   4. Scan TODO backlog — promote anything actionable to NEXT
          ;;   5. Browse SOMEDAY pile — capture anything newly relevant
          ;;   6. Check 90-Day Plan milestones for the coming week
          ("w" "Weekly Review"
           ((agenda ""
                    ((org-agenda-span 14)           ; two weeks out
                     (org-agenda-overriding-header "📅 Next Two Weeks")))

            (todo "NEXT"
                  ((org-agenda-overriding-header "⚡ Committed This Week")
                   (org-agenda-skip-function #'my/org-skip-90day-subtree)))

            (todo "TODO"
                  ((org-agenda-overriding-header "📋 Full Backlog — promote to NEXT as needed")
                   (org-agenda-sorting-strategy '(category-keep))
                   (org-agenda-skip-function #'my/org-skip-90day-subtree)
                   (org-agenda-max-entries 60)))   ; guard against overflow

            (tags-todo "email|reply"
                       ((org-agenda-overriding-header "📧 Open Email Tasks")
                        (org-agenda-sorting-strategy '(deadline-up priority-down))))

            (todo "WAITING"
                  ((org-agenda-overriding-header "⏳ Waiting on Someone")))

            (todo "SOMEDAY"
                  ((org-agenda-overriding-header "💭 Someday / Maybe — anything newly relevant?")
                   (org-agenda-max-entries 20)))))

          ;; ── "9" 90-Day Plan view — SPC o 9 ─────────────────────────────────
          ;; Focused view of the Pickleball Hut 90-day scaling plan.
          ;; Shows the 4-week ahead agenda (deadlines from the plan)
          ;; and any tasks you've promoted from TODO → NEXT within the plan.
          ("9" "90-Day Scaling Plan"
           ((agenda ""
                    ((org-agenda-span 28)
                     (org-agenda-files '("~/org/pickleball-hut.org"))
                     (org-agenda-overriding-header "📅 90-Day Plan — Next 4 Weeks")))
            (tags-todo "90day"
                  ((org-agenda-overriding-header "All 90-Day Tasks (sorted by deadline)")
                   (org-agenda-files '("~/org/pickleball-hut.org"))
                   (org-agenda-sorting-strategy '(deadline-up category-keep))
                   (org-agenda-max-entries 50)))))

          ;; ── Per-area focused views ──────────────────────────────────────────
          ;; Use when you want a heads-down session on a single area.
          ;; SPC o a → then press the key letter.

          ("D" "Dynamite Doubles"
           ((todo "NEXT|IN-PROGRESS"
                  ((org-agenda-files '("~/org/dynamite-doubles.org"))
                   (org-agenda-overriding-header "⚡ Active — Dynamite Doubles")))
            (todo "TODO"
                  ((org-agenda-files '("~/org/dynamite-doubles.org"))
                   (org-agenda-overriding-header "📋 Backlog — Dynamite Doubles")
                   (org-agenda-sorting-strategy '(category-keep))))))

          ("P" "Pickleball Hut"
           ((todo "NEXT|IN-PROGRESS"
                  ((org-agenda-files '("~/org/pickleball-hut.org"))
                   (org-agenda-overriding-header "⚡ Active — Pickleball Hut")
                   (org-agenda-skip-function #'my/org-skip-90day-subtree)))
            (todo "TODO"
                  ((org-agenda-files '("~/org/pickleball-hut.org"))
                   (org-agenda-overriding-header "📋 Backlog — Pickleball Hut")
                   (org-agenda-sorting-strategy '(category-keep))
                   (org-agenda-skip-function #'my/org-skip-90day-subtree)))))

          ("R" "RevLogic"
           ((todo "NEXT|IN-PROGRESS"
                  ((org-agenda-files '("~/org/revlogic.org"))
                   (org-agenda-overriding-header "⚡ Active — RevLogic")))
            (todo "TODO"
                  ((org-agenda-files '("~/org/revlogic.org"))
                   (org-agenda-overriding-header "📋 Backlog — RevLogic")))))

          ("X" "Personal"
           ((todo "NEXT|IN-PROGRESS"
                  ((org-agenda-files '("~/org/personal.org"))
                   (org-agenda-overriding-header "⚡ Active — Personal")))
            (todo "TODO"
                  ((org-agenda-files '("~/org/personal.org"))
                   (org-agenda-overriding-header "📋 Backlog — Personal"))))))))


;; ──────────────────────────────────────────
;; Org-Modern
;; ──────────────────────────────────────────

(use-package! org-modern
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda))


;; ──────────────────────────────────────────
;; Org Agenda — force Emacs state so r/g/f/b/t/d keys work
;; Must be a hook, not evil-set-initial-state — evil-collection loads
;; after config and silently overrides the initial state setting.
;; ──────────────────────────────────────────

(add-hook 'org-agenda-mode-hook #'evil-emacs-state)


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
;; ──────────────────────────────────────────

;; Calendar + gcal sync
(map! :leader
      :desc "Fetch Google Calendar" "o g" #'org-gcal-fetch)

;; Quick agenda shortcuts (all under SPC o)
(map! :leader
      :desc "Dashboard"          "o d" (lambda () (interactive) (org-agenda nil "d"))
      :desc "Email triage"       "o e" (lambda () (interactive) (org-agenda nil "e"))
      :desc "Weekly review"      "o w" (lambda () (interactive) (org-agenda nil "w"))
      :desc "90-Day Plan"        "o 9" (lambda () (interactive) (org-agenda nil "9"))
      :desc "DD focused"         "o D" (lambda () (interactive) (org-agenda nil "D"))
      :desc "PH focused"         "o P" (lambda () (interactive) (org-agenda nil "P"))
      :desc "RevLogic focused"   "o R" (lambda () (interactive) (org-agenda nil "R"))
      :desc "Personal focused"   "o X" (lambda () (interactive) (org-agenda nil "X"))
      :desc "Open mu4e"          "o m" #'mu4e
      :desc "Visual calendar"    "o v" #'my/open-calendar)


;; ──────────────────────────────────────────
;; Calfw — visual month/week calendar grid
;; Uses calfw- prefix (not cfw:) — correct for this version of emacs-calfw
;; ──────────────────────────────────────────

;; Week starts on Monday (must be global — set before calfw renders)
(setq calendar-week-start-day 1)

;; calfw has no evil-collection bindings — use Emacs state so native keys work
;; Native keys: M=month W=week T=two-weeks D=day t=today g=goto-date
;;              f/b=forward/back n/p=next/prev-day [/]=prev/next-week
(after! evil
  (evil-set-initial-state 'calfw-calendar-mode 'emacs))

;; Explicit bindings for quit and calendar refresh
(map! :map calfw-calendar-mode-map
      "q" #'calfw-quit-calendar
      "r" #'org-gcal-fetch)

(defun my/open-calendar ()
  "Open calfw org calendar view."
  (interactive)
  (require 'calfw)
  (require 'calfw-compat)
  (require 'calfw-org)
  ;; Face customization using calfw- prefix (v2.0+ naming)
  (set-face-attribute 'calfw-title-face       nil :foreground "#61afef" :weight 'bold)
  (set-face-attribute 'calfw-header-face      nil :foreground "#98c379" :weight 'bold)
  (set-face-attribute 'calfw-sunday-face      nil :foreground "#e06c75")
  (set-face-attribute 'calfw-saturday-face    nil :foreground "#e5c07b")
  (set-face-attribute 'calfw-today-title-face nil :foreground "#61afef" :weight 'bold :underline t)
  (set-face-attribute 'calfw-today-face       nil :foreground "#61afef")
  (calfw-org-open-calendar))


;; ── Wash email: strip citations, signature, blank lines in one shot ─────────
(defun my/wash-email ()
  "Strip citations, signature and excess blank lines from current message."
  (interactive)
  (gnus-article-hide-citation)
  (gnus-article-hide-signature)
  (gnus-article-strip-multiple-blank-lines))

;; ── Reply: bottom-post and clean compose buffer ───────────────────────────
(setq message-cite-reply-position 'below)   ; cursor below quote on reply

(defun my/message-clean-reply ()
  "Remove excess blank lines in reply compose buffer."
  (interactive)
  (save-excursion
    (message-goto-body)
    (flush-lines "^[[:space:]]*$")))

(map! :map message-mode-map
      :n "WW" #'my/message-clean-reply)


;; ══════════════════════════════════════════
;; mu4e — Email
;; ══════════════════════════════════════════

(after! mu4e

  ;; ── Core settings ──────────────────────────────────────────────────────────
  (setq mu4e-maildir                    "~/.mail"
        mu4e-get-mail-command           "mbsync fastmail gmail-hj gmail-trey"
        mu4e-update-interval            (* 10 60)       ; sync every 10 minutes
        mu4e-index-update-in-background t
        mu4e-use-fancy-chars            t
        mu4e-view-show-images           t
        mu4e-view-image-max-width       800
        mu4e-compose-signature-auto-include t           ; signature enabled
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
        message-sendmail-f-is-evil      t

        ;; Browser for links/HTML — must be set here to ensure xdg-open is used
        browse-url-browser-function     'browse-url-xdg-open)

  ;; ── Headers display — date (04MAR2026 14:35), size, flags ─────────────────
  (defun my/mu4e-date-uppercase (msg)
    "Return date formatted as 04MAR2026 14:35 (uppercase month)."
    (upcase (format-time-string "%d%b%Y %H:%M"
      (mu4e-message-field msg :date))))

  (add-to-list 'mu4e-header-info-custom
    '(:date-upper . (:name "Date"
                     :shortname "Date"
                     :function my/mu4e-date-uppercase)))

  (setq mu4e-headers-fields
    '((:date-upper  . 20)   ; "04MAR2026 14:35"
      (:flags       .  6)
      (:size        .  7)   ; "245K" or "2.3M"
      (:from        . 22)
      (:subject     . nil)))

  ;; ── Visible header fields in message view ─────────────────────────────────
  (setq mu4e-view-fields
    '(:from :to :subject :date :flags :maildir :mailing-list
      :attachments :x-mailer))

  ;; ── Maildir shortcuts (Maildirs section of main view) ─────────────────────
  (setq mu4e-maildir-shortcuts
    '((:maildir "/fastmail/INBOX"               :key ?f)
      (:maildir "/fastmail/Archive"       :key ?a)
      (:maildir "/fastmail/Sent"          :key ?s)
      (:maildir "/gmail-hj/INBOX"               :key ?h)
      (:maildir "/gmail-hj/[Gmail]/Sent Mail"   :key ?H)
      (:maildir "/gmail-trey/INBOX"             :key ?t)
      (:maildir "/gmail-trey/[Gmail]/Sent Mail" :key ?T)))

  ;; ── Contexts (one per account) ─────────────────────────────────────────────
  (setq mu4e-contexts
    (list

      ;; Fastmail: trey@fastmail.fm
      ;; Signature loaded from ~/.signature (only this account)
      (make-mu4e-context
        :name "Fastmail"
        :match-func (lambda (msg)
          (when msg
            (string-prefix-p "/fastmail" (mu4e-message-field msg :maildir))))
        :vars '((user-mail-address       . "trey@fastmail.fm")
                (user-full-name          . "Trey Sizemore")
                (mu4e-sent-folder        . "/fastmail/Sent")
                (mu4e-drafts-folder      . "/fastmail/Drafts")
                (mu4e-trash-folder       . "/fastmail/Deleted Messages")
                (mu4e-refile-folder      . "/fastmail/Archive")
                (smtpmail-smtp-user      . "trey@fastmail.fm")
                (mu4e-compose-signature  . my/fastmail-signature)))

      ;; Gmail: hjsizemore@gmail.com — no signature
      (make-mu4e-context
        :name "Gmail-HJ"
        :match-func (lambda (msg)
          (when msg
            (string-prefix-p "/gmail-hj" (mu4e-message-field msg :maildir))))
        :vars '((user-mail-address       . "hjsizemore@gmail.com")
                (user-full-name          . "Trey Sizemore")
                (mu4e-sent-folder        . "/gmail-hj/[Gmail]/Sent Mail")
                (mu4e-drafts-folder      . "/gmail-hj/[Gmail]/Drafts")
                (mu4e-trash-folder       . "/gmail-hj/[Gmail]/Trash")
                (mu4e-refile-folder      . "/gmail-hj/[Gmail]/All Mail")
                (smtpmail-smtp-user      . "hjsizemore@gmail.com")
                (mu4e-compose-signature  . nil)))

      ;; Gmail: trey.sizemore@gmail.com — no signature
      (make-mu4e-context
        :name "Gmail-Trey"
        :match-func (lambda (msg)
          (when msg
            (string-prefix-p "/gmail-trey" (mu4e-message-field msg :maildir))))
        :vars '((user-mail-address       . "trey.sizemore@gmail.com")
                (user-full-name          . "Trey Sizemore")
                (mu4e-sent-folder        . "/gmail-trey/[Gmail]/Sent Mail")
                (mu4e-drafts-folder      . "/gmail-trey/[Gmail]/Drafts")
                (mu4e-trash-folder       . "/gmail-trey/[Gmail]/Trash")
                (mu4e-refile-folder      . "/gmail-trey/[Gmail]/All Mail")
                (smtpmail-smtp-user      . "trey.sizemore@gmail.com")
                (mu4e-compose-signature  . nil)))))

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
        :n "C" #'mu4e-org-store-and-capture                ; capture email to org
        :n "WW" #'my/wash-email                            ; wash all
        :n "Wc" #'gnus-article-hide-citation               ; strip citations / quoted replies
        :n "Ws" #'gnus-article-hide-signature              ; hide signature block
        :n "Wl" #'gnus-article-strip-multiple-blank-lines  ; remove excess blank lines
        :n "Wq" #'gnus-article-fill-cited-article          ; reflow/fill long lines
        :n "Wh" #'gnus-article-wash-html)                  ; render HTML part

  ;; U in headers view = sync (not "unmark all" which is the default)
  (map! :map mu4e-headers-mode-map
        :n "U" #'mu4e-update-mail-and-index)

  ;; Auto-fetch Google Calendar every time mail syncs
  (add-hook 'mu4e-update-post-hook #'org-gcal-fetch))


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


;; ── Signature: Fastmail only, loaded from ~/.signature ────────────────────
;; Create ~/.signature with your desired signature text.
;; Example:
;;   Trey Sizemore
;;   RevLogic | PickleballHut | Dynamite Doubles
;;   trey@fastmail.fm
(defun my/fastmail-signature ()
  "Load signature from ~/.signature file."
  (if (file-exists-p "~/.signature")
      (with-temp-buffer
        (insert-file-contents "~/.signature")
        (buffer-string))
    "Trey Sizemore"))   ; fallback if file missing


;; ── PGP / mml-sec signing and encryption ──────────────────────────────────
;; Requires gpg key to be set up: gpg --list-secret-keys
;; Sign with C-c RET s p while composing
;; Encrypt with C-c RET e p while composing
(after! mu4e
  (setq mml-secure-openpgp-sign-with-sender t   ; auto-select key from From address
        mml-secure-openpgp-encrypt-to-self  t   ; always encrypt a copy to yourself
        mm-verify-option                    'always
        mm-decrypt-option                   'always))

;; Ensure epg uses pinentry-tty or pinentry-qt (not loopback) on Arch
(setq epg-pinentry-mode 'loopback)


;; ── Remove signature when replying ────────────────────────────────────────
;; gs in normal mode while composing removes the signature block
(defun my/remove-signature ()
  "Remove signature (everything from '-- ' separator) in compose buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^-- $" nil t)
      (delete-region (match-beginning 0) (point-max))
      (message "Signature removed."))))

(map! :map message-mode-map
      :n "gs" #'my/remove-signature)


;; ── Dired rename: pre-populate minibuffer with original filename ──────────
(defun my/dired-rename-with-filename ()
  "Rename file with original name pre-populated in minibuffer."
  (interactive)
  (let* ((file (dired-get-filename))
         (base (file-name-nondirectory file))
         (dir  (file-name-directory file))
         (new  (read-string "Rename to: " base)))
    (rename-file file (concat dir new))
    (revert-buffer)))

(after! dired
  (map! :map dired-mode-map
        :n "R" #'my/dired-rename-with-filename))


;; ── Open HTML part of email in system browser ─────────────────────────────
(defun my/mu4e-view-in-xdg-browser (msg)
  "Save the HTML part of MSG to a temp file and open in system browser."
  (let* ((html (mu4e-message-field msg :body-html))
         (tmpfile (make-temp-file "mu4e-" nil ".html")))
    (if html
        (progn (with-temp-file tmpfile (insert html))
               (start-process "xdg-open" nil "xdg-open" tmpfile))
      (message "No HTML part found in this message."))))


;; ── Extract all URLs from the rendered view buffer ────────────────────────
;; Fixed: scans the visible buffer rather than raw message fields,
;; so it works for plain text and NO-CONVERSION messages too.
(defun my/mu4e-extract-links (msg)
  "Extract all URLs from the mu4e article view buffer.
Works for both HTML (shr-url properties) and plain text messages."
  (let ((urls '())
        (buf (get-buffer "*mu4e-article*")))
    (if (not buf)
        (message "No article buffer found.")
      (with-current-buffer buf
        ;; Method 1: shr-url text properties (HTML rendered messages)
        (goto-char (point-min))
        (while (not (eobp))
          (let ((url (get-text-property (point) 'shr-url)))
            (when url (push url urls)))
          (goto-char (or (next-single-property-change (point) 'shr-url)
                         (point-max))))
        ;; Method 2: regex scan for plain text messages
        ;; Join lines first to handle wrapped URLs
        (when (null urls)
          (let ((text (buffer-substring-no-properties (point-min) (point-max)))
                (url-regex "https?://[^ 	
<>"']+"))
            ;; Remove soft line breaks and rejoin wrapped URLs
            (setq text (replace-regexp-in-string "
+" " " text))
            (with-temp-buffer
              (insert text)
              (goto-char (point-min))
              (while (re-search-forward url-regex nil t)
                (push (match-string 0) urls)))))))
    (if urls
        (browse-url (completing-read "Open URL: " (delete-dups (reverse urls))))
      (message "No URLs found in this message."))))
