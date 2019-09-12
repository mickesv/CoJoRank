;;; cojorank-gii-grin-scie.el
;; --------------------
;;; Commentary
;; F*ck J2EE and their session-obsession. This does not work; in order to get to a point where a simple search can be done you need to make at least three different calls to different webpages just to say that you are you.

;;; Code:
(defun cojorank-gii-grin-scie (pubname)
  (let ((search-url "http://gii-grin-scie-rating.scie.es/ratingSearch.jsf")
        (url-request-method "POST")
        (url-request-extra-headers '(("Content-Type" . "application/x-www-form-urlencoded")))
        (url-request-data (concat "j_idt55=j_idt55&j_idt55%3Aj_idt58="
                                  (url-hexify-string pubname)
                                  "&j_idt55%3Aj_idt59=Search"))
        (buf (get-buffer-create cojorank-buffer-name)))
    (url-retrieve search-url
                  `(lambda (status) ;; First callback: get viewstate
                     (goto-char (point-min))
                     (let* ((start (search-forward "javax.faces.ViewState:0\" value=\"" nil t))
                            (end (- (search-forward "\"" nil t) 1))
                            (vs (buffer-substring start end))
                            (url-request-method ',url-request-method)
                            (url-request-extra-headers ',url-request-extra-headers)
                            (url-request-data (concat ,url-request-data
                                                      "&javax.faces.ViewState="
                                                      vs))
                            (buf ,buf))
                       (message "so far: %s\n%s" url-request-data vs)
                       (url-retrieve ,search-url
                                     `(lambda (status)
                                        (let (out)
                                          (goto-char (point-min))
                                          (while (search-forward "javax.faces.ViewState:" nil t)
                                            (setq out (concat out "\n----------\n" (buffer-substring (point) (+ 40 (point))))))
                                          (save-excursion
                                            (set-buffer ,buf)
                                            (goto-char (point-max))
                                            (insert "\n\nvsdebug\n====================")
                                            (insert (format "%S" out))
                                            ))                    
                                        (append-to-buffer ,buf (point-min) (point-max))
                                        ))
                       )))
    nil
  ))
