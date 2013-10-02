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

(setq websocket-debug t)

(defvar greyhound/start
  (websocket-open 
   greyhound/server
   :on-message (lambda (websocket frame)
                 (push (websocket-frame-payload frame) greyhound/messages)
                 (message "ws frame: %S" (websocket-frame-payload frame))
                 (error "Test error (expected)"))
   :on-close (lambda (websocket) (setq greyhound/closed t))))

(defun greyhound/start ()
  "Start and start the websocket communication with the greyhound server"
  (interactive)
  (greyhound/start-server)
  (greyhound/open-websocket)
)

(defun greyhound/stop ()
  "Stop the greyhound server"
  (interactive)
  (greyhound/close-websocket)
  (greyhound/stop-server)
)

(websocket-openp greyhound/start)
(websocket-send-text greyhound/start "{\"action\": \"query\", \"queryData\": {\"project\": \"statics\", \"query\": \"t\"}}")

;; greyhound server methods

(defun greyhound/start-server ()
  "start the greyhound server"
)

(defun greyhound/stop-server ()
  "stop the greyhound server"
)

;; greyhound websocket methods

(defun greyhound/open-websocket ()
  "open the greyhound websocket"
)

(defun greyhound/close-websocket ()
  "close the greyhound websocket"
)
