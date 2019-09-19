;;; cojorank-guide2research.el -- Guide2Research
;; --------------------
;; ;; [ ] Gude2Research http://www.guide2research.com/topconf/

;;; Code:
(require 'url)

(defun cojorank-guide2research--parse-table (table)
  (let* ((table-format "%10s\t%10s\t%-60s\n")
         (header (format table-format "Position" "Hindex" "Venue"))
         (out (mapconcat (lambda (row)
                           (unless (or (stringp row)
                                       (not (equal 'div (car row))))
                             (let* ((inner-table-meat (nth 1 (nthcdr 2 row)))
                                    (position (nth 2 (nth 2 (nth 3 (nth 2 (nth 2 inner-table-meat))))))
                                    (hindex (nth 2 (nth 2 (nth 3 (nth 4 (nth 2 inner-table-meat))))))
                                    (venue (nth 2 (nth 2 (nth 2 (nth 8 (nth 2 inner-table-meat))))))
                                    )
                               (format table-format
                                       (string-trim position)
                                       (string-trim hindex)
                                       (string-trim venue))
                                    ))) table "")))
    (format "%s%s\n\n" header out)))


(defun cojorank-guide2research (pubname)
  (let ((search-url (concat "http://www.guide2research.com/topconf/"
                            "?ajax=1"
                            "&k=" (url-hexify-string pubname)
                            "&due=0" "&con=" "&cat="))
        (buf (get-buffer-create cojorank-buffer-name))
        (listname "Guide2Research"))
    (url-retrieve search-url
                  `(lambda (status)
                     (goto-char (point-min))
                     (if (< 0 (how-many "TODO: Find out a pattern that works for no hits in guide2research"))
                         (save-excursion
                           (set-buffer ,buf)
                           (goto-char (point-max))
                           (insert (format "Could not find any hits in %s for %s\n" ,listname ,pubname)))
                       (progn                           
                         (search-forward "<div id=\"ajax_content\">" nil t 2)
                         (let* ((table (libxml-parse-html-region (point) (point-max)))
                                (table-meat (nthcdr 2 (nth 3 (nth 2 table)))))
                           (save-excursion
                             (set-buffer ,buf)
                             (goto-char (point-max))
                             (insert (format "Searching in %s for %s\n" ,listname ,pubname))
                             (insert (cojorank-guide2research--parse-table table-meat))
                             ))))))))

(add-to-list 'cojorank-rank-list-list '("Guide2Research"
                                        cojorank-guide2research
                                        "http://www.guide2research.com/topconf/

Top Computer Science Conferences
Ranking is based on Conference H5-index>=12 provided by Google Scholar Metrics"))

(provide 'cojorank-guide2research)
