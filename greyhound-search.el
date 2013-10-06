;; Work in progress
;; bugs to fix in libraries
;; * bug with google's WebSocket code: expects camelcase websocket name in 'Upgrade', not required.
;; * 'origin' on emacs websocket needs an http attached to it...

(require 'websocket)
(require 'json)
(require 'cl)

(defvar greyhound/server "ws://127.0.0.1:8081/socket")
(defvar greyhound/messages nil) ; the message queue that handles responses
(defvar greyhound/process nil) ; the handle for the process
(defvar greyhound/websocket nil) ; the handle for the websocket
(defvar greyhound/callback nil) ; the callback function that parses output
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
  (sleep-for 0 100)
  (greyhound/open-websocket)
)

(defun greyhound/stop ()
  "Stop the greyhound server"
  (interactive)
  (greyhound/stop-server)
  (greyhound/close-websocket)
)

(defun greyhound/add-project ()
  "Add a project to the greyhound-server"
  (interactive)
  (let ((cwd (file-name-directory (or load-file-name buffer-file-name))))
    (websocket-send-text greyhound/websocket 
                         (json-encode (list :action "add_project"
                                            :querydata (list :name "test" :path cwd)))
                         )
    )
)

(defun greyhound/list-projects ()
  "List all of the projects in existance"
  (interactive)
  (websocket-send-text greyhound/websocket
                       (json-encode (list :action "list_projects")))
)

;;(websocket-openp greyhound/start)
;;(websocket-send-text greyhound/start "{\"action\": \"query\", \"queryData\": {\"project\": \"statics\", \"query\": \"t\"}}")

;; greyhound server methods

(defun greyhound/start-server ()
  "start the greyhound server"
  (unless (and greyhound/process (process-live-p greyhound/process))
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
      (if (websocket-close greyhound/websocket)
          (setq greyhound/websocket nil)))
)
