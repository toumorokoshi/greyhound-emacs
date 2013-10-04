;; Work in progress
;; bugs to fix in libraries
;; * bug with google's WebSocket code: expects camelcase websocket name in 'Upgrade', not required.
;; * 'origin' on emacs websocket needs an http attached to it...

(require 'websocket)
(require 'cl)

(defvar greyhound/server "ws://127.0.0.1:8081/socket")
(defvar greyhound/messages nil)
(defvar greyhound/closed nil)
(defvar greyhound/process nil)
(defvar greyhound/websocket nil)
; (defvar greyhound/executable "greyhound-search")
(defvar greyhound/executable "/home/tsutsumi/workspace/greyhound-search/greyhound-search")

(setq websocket-debug t)

;; (defvar greyhound/start
;;   (websocket-open 
;;    greyhound/server
;;    :on-message (lambda (websocket frame)
;;                  (push (websocket-frame-payload frame) greyhound/messages)
;;                  (message "ws frame: %S" (websocket-frame-payload frame))
;;                  (error "Test error (expected)"))
;;    :on-close (lambda (websocket) (setq greyhound/closed t))))

(defun greyhound/start ()
  "Start and start the websocket communication with the greyhound server"
  (interactive)
  (greyhound/start-server)
  (greyhound/open-websocket)
)

(defun greyhound/stop ()
  "Stop the greyhound server"
  (interactive)
  (greyhound/stop-server)
  (greyhound/close-websocket)
)

;;(websocket-openp greyhound/start)
;;(websocket-send-text greyhound/start "{\"action\": \"query\", \"queryData\": {\"project\": \"statics\", \"query\": \"t\"}}")

;; greyhound server methods

(defun greyhound/start-server ()
  "start the greyhound server"
  (unless (or greyhound/process (not (process-live-p greyhound/process)))
    (setq greyhound/process (start-process 
                             "greyhound" 
                             "*greyhound*" 
                             greyhound/executable))))

(defun greyhound/stop-server ()
  "stop the greyhound server"
  (if greyhound/process
      (kill-process greyhound/process))
)

;; greyhound websocket methods

(defun greyhound/open-websocket ()
  "open the greyhound websocket"
  (unless greyhound/websocket
   (setq greyhound/websocket 
         (websocket-open 
          greyhound/server
          :on-message (lambda (websocket frame)
                        (push (websocket-frame-payload frame) greyhound/messages)
                        (message "ws frame: %S" (websocket-frame-payload frame))
                        (error "Test error (expected)"))
          :on-close (lambda (websocket) (setq greyhound/closed t))))
   )
)

(defun greyhound/close-websocket ()
  "close the greyhound websocket"
  (if greyhound/websocket
      (setq greyhound/websocket (websocket-close greyhound/websocket)))
)
