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
  (defun greyhound/callback (returnvalue) 
    (message "Success!")
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
  (defun greyhound/callback (projectlist) 
    (message "%s" projectlist))
  (websocket-send-text greyhound/websocket
                       (json-encode (list :action "list_projects")))
)

(defun greyhound/find-file (project match)
  "Search the <project> in greyhound for the string <match>"
  (interactive)
  (defun greyhound/callback (result) 
    (message "%s" result))
  (websocket-send-text greyhound/websocket
                       (json-encode (list :action "query"
                                          :querydata (list :project project :query match))))
)
; SANDBOX
(minibuffer-message "hello")
(minibuffer-with-setup-hook 
    (lambda ()
      (message "hello")))

(setq tmp '("cat" "dog" "fish"))
(index '("cat" "dog" "fish"))

(minibuffer-with-setup-hook 'minibuffer-complete
  (completing-read (concat "Pick one (" 
                           (mapconcat 'identity (all-completions "" tmp) " ") 
                           "): ") h
                   tmp))
(set-window-text
; SANDBOX
(let ((root-dir (file-name-as-directory "."))
      (index (fiplr-get-index 'files root-dir nil))
      (file (minibuffer-with-setup-hook
                (lambda ()
                  (fiplr-mode 1))
               (grizzl-completing-read (format "Find in project (%s)" root-dir)
                                       index)))))



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
                        (greyhound/callback (let ((json-object-type 'plist)) 
                                              (json-read-from-string (websocket-frame-payload frame)))))
                        ;;(message "ws frame: %S" (websocket-frame-payload frame))
          :on-close (lambda (websocket) (setq greyhound/closed t))))
   )
)

(defun greyhound/close-websocket ()
  "close the greyhound websocket"
  (if greyhound/websocket
      (if (websocket-close greyhound/websocket)
          (setq greyhound/websocket nil)))
)
