(require-extension tcp-server posix srfi-18 tcp)
(declare (uses tcp posix srfi-18))



(define (generate-ip-port str)
  (define-values (ip ip2 ip3)
    (process
     (string-append "./find-network.sh " str)))
  (generate-ip-lst ip))

(define (generate-ip-lst ipp)
  (if (eof-object? (peek-char ipp))
      '()
      (cons (read-line ipp) (generate-ip-lst ipp))))

(define *camera-ips* (generate-ip-port "192.168.22.0/24"))

(define (start-server)
  ((make-tcp-server
    (tcp-listen 6508)
    (lambda () (map (lambda (x)
                      (write-line x))
                    *camera-ips*)))
   #t))

 (thread-start! (make-thread (lambda() (start-server))))

(define (record-stream ip)
  (thread-start!
   (make-thread
    (lambda ()
      (process (string-append "ffmpeg -i rtsp://admin:123456@"
                              ip
                              "/profile1 -rtsp_transport tcp -r 10 -vcodec copy -y -segment_time "
                              *segment-duration*
                              " -f segment -an camera-1 -%03d.mkv"))))))

;;;Perhaps a symbol list for disabling/enabling ffmpeg options?
;;;Or a text file?

;;;Length of video files
(define *segment-duration* "30")

(define (record-all)
  (map record-stream *camera-ips*))


(write-line "hello")

;;;Need to setup an alist with Camera(n):ip-addr
;;;Then use camera number to mkdir's
;;;Place a file with the ip for that camera in directory
;;;Log an alert if the ip changes

