;;; iMessage.el --- Control iMessage with helm
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

(defun imessage-get-buddies-names ()
  "apple script to get buddy names"
  (imessage-parse-blob
   (shell-command-to-string (format "osascript -e 'tell application %S to get name of buddies'"
                                    "Messages"))))
(defun imessage-get-service-buddy (buddy)
  "apples script to get the service of the buddy"
  (message
   (replace-regexp-in-string "\n\\'" "" 
                             (shell-command-to-string (format "osascript -e 'tell application %S to get name of service of buddy %S'"
                                                              "Messages"
                                                              buddy)))))

(defun imessage-send-buddy-message (buddy service)
  "send message to the buddy and their service"
  (shell-command-to-string (format "osascript -e 'tell application %S to send %S to buddy %S of service %S'"
                                   "Messages"
                                   (call-interactively 'imessage-get-message)
                                   buddy
                                   service)))

(defun imessage-get-message (msg)
  "Prompt user for the message"
  (interactive "MMessage to send: ")
  (message "%s" msg))


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
                     (imessage-s-trim candidate)
                     (imessage-get-service-buddy
                      (imessage-s-trim candidate)))))))

;;;###autoload
(defun imessage ()
  "Bring up helm buddy search"
  (interactive)
  (helm :sources '(helm-source-message)
  :buffer "*imessage*"))

(provide 'imessage)
;;; iMessage.el ends here

