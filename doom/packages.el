;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)
(package! org-gcal)
(package! calfw)
(package! calfw-org)
;; ══════════════════════════════════════════════════════════════════════════════
;; ORG-MODE ENHANCEMENT PACKAGES
;; ══════════════════════════════════════════════════════════════════════════════
(package! org-modern)      ; Beautiful modern styling (★ ◉ ○ bullets)
(package! org-download)    ; Drag-and-drop images
(package! org-cliplink)    ; Auto-format URLs with titles
(package! org-rich-yank)   ; Paste with source attribution
(package! org-pomodoro)    ; Pomodoro timer
(package! org-present)     ; Presentation mode
(package! org-ql)          ; Advanced query language
(package! org-mime)        ; HTML emails from org
