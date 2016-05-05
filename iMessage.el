;; iMessage.el --- Control iMessage with helm
;; Copyright 2016 Chad Sahlhoff
;;
;; Author: Chad Sahlhoff <chad@sahlhoff.com>
;; Maintainer: Chad Sahlhoff <chad@sahlhoff.com>
;; Keywords: helm iMessage
;; URL: https://github.com/sahlhoff/imessage
;; Created: 1st May 2016
;; Version: 0.1.0
;; Package-Requires: ((helm "0.0.0") (s "1.0.0"))

;;; Commentary:
;;
;; An iMessage interface for osx
;;
;; Only supports osx and imessage
;;

;;; Code:

(defvar imessage-disable-service-check t "Sometimes a message won't send if the service is passed in, disable this if you run into issues.")

(defun imessage-call-osascript (cmd)
  "Simple wrapper around the whole OSAscript call that gets made almost everywhere."
  (setq result "")
  (setq imessage-cmd (format "osascript -e 'tell application \"Messages\" %s'" cmd))
  (message "OSAScript cmd: %s" imessage-cmd)
  (setq result (shell-command-to-string imessage-cmd))
  (message result))

(defun imessage-get-buddies-names ()
  "apple script to get buddy names"
  (imessage-parse-blob (imessage-call-osascript "to get name of buddies")))

(defun imessage-get-service-buddy (buddy)
  "apples script to get the service of the buddy"
  (unless imessage-disable-service-check
    (replace-regexp-in-string "\n\\'" "" (imessage-call-osascript (format "to get name of service of buddy %S" buddy)))))

(defun imessage-send-buddy-message (buddy)
  "send message to the buddy and their service"
  (let (service (imessage-get-service-buddy buddy))
    (setq imessage-cmd (format "to send %s to buddy %S" (call-interactively 'imessage-get-message) buddy))
    (if service
	(setq imessage-cmd (format " of service %S" service)))
    (imessage-call-osascript imessage-cmd)))

(defun imessage-get-message (msg)
  "Prompt user for the message"
  (interactive "MMessage to send: ")
  (format "%S" msg))


(defun imessage-parse-blob (blob)
  "Split the buddies returning list"
  (split-string blob ","))

(defun imessage-s-trim (s)
  "Remove whitespace at the beginning and end of S."
  (s-trim-left (s-trim-right s)))

(setq helm-source-message
      '((name . "imessage")
        (candidates . imessage-get-buddies-names)
        (action . (lambda (candidate)
                    (imessage-send-buddy-message
                      (imessage-s-trim candidate))))))

;;;###autoload
(defun imessage ()
  "Bring up helm buddy search"
  (interactive)
  (helm :sources '(helm-source-message)
  :buffer "*imessage*"))

(provide 'imessage)
;;; iMessage.el ends here

