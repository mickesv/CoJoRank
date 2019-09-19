;;; cojorank-core-conferences.el -- CORE conferences
;;; Commentary:
;; [ ] Core Conferences http://portal.core.edu.au/conf-ranks/
;;

;;; Code:

(require 'url)

(defun cojorank-core-conferences--parse-table (table)
  (let* ((table-format "%4s\t%-10s\t%-60s\t%10s\n")
         (header (format table-format "Rank" "Acronym" "Venue" "Source"))
         (out (mapconcat (lambda (row)
                           (unless (or (stringp row)
                                       (not (equal 'tr (car row))))
                             (let ((name (nth 2 (nth 1 (cdr row))))
                                   (acronym (nth 2 (nth 2 (cdr row))))
                                   (source (nth 2 (nth 3 (cdr row))))
                                   (rank (nth 2 (nth 4 (cdr row)))))
                               (format table-format
                                       (string-trim rank)
                                       (string-trim acronym)
                                       (string-trim name)
                                       (string-trim source)
                                       ))))
                           table "")))
    (format "%s%s\n\n" header out)))

(defun cojorank-core-conferences (pubname)
  (let ((search-url (concat "http://portal.core.edu.au/conf-ranks/"
                            "?search=" (url-hexify-string pubname)
                            "&by=all" "&source=CORE2018" "&sort=atitle" "&page=1"))
        (buf (get-buffer-create cojorank-buffer-name)))
    (url-retrieve search-url
                  `(lambda (status)
                     (goto-char (point-min))
                     (if (< 0 (how-many "0 Results found."))
                         (save-excursion
                           (set-buffer ,buf)
                           (goto-char (point-max))
                           (insert (format "Could not find any hits in CORE Conferences for %s\n" ,pubname)))
                       (progn                           
                         (search-forward "<table>")
                         ;;(search-forward "<tbody>")
                         (search-forward "</tr>")                         
                         (let* ((table (libxml-parse-html-region (point) (point-max)))
                                (table-meat (cddr (nth 2 table))))
                           (save-excursion
                             (set-buffer ,buf)
                             (goto-char (point-max))
                             (insert (format "Searching in CORE Conferences for %s\n" ,pubname))
                             (insert (cojorank-core-conferences--parse-table table-meat)))
                             )))))))

(add-to-list 'cojorank-rank-list-list '("CORE Conferences"
                                        cojorank-core-conferences
                                        ""))

(provide 'cojorank-core-conferences)

