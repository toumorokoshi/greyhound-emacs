;; Work in progress
(require 'websocket)
(require 'cl)

(defvar greyhound/server "ws://127.0.0.1:8081/socket")
(defvar greyhound/messages nil)
(defvar greyhound/closed nil)

(setq websocket-debug t)

(defvar greyhound/start
  (websocket-open 
   greyhound/server
   :on-message (lambda (websocket frame)
                 (push (websocket-frame-payload frame) greyhound/messages)
                 (message "ws frame: %S" (websocket-frame-payload frame))
                 (error "Test error (expected)"))
   :on-close (lambda (websocket) (setq greyhound/closed t))))

(websocket-openp greyhound/start)
(websocket-send-text greyhound/start "{\"action\": \"query\", \"queryData\": {\"project\": \"statics\", \"query\": \"t\"}}")

