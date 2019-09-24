;;; cojorank-csv.el -- Generic parser for CSV formatted rank lists
;;
;;; Code:

;; TODO CHECK:
;; https://emacs.stackexchange.com/questions/17946/how-do-i-include-non-code-resources-as-part-of-an-emacs-package
;; (defconst my-package-directory (file-name-directory load-file-name))


(use-package parse-csv :ensure t)

(defconst cojorank-csv--directory (file-name-directory (or buffer-file-name load-file-name)))
(defvar cojorank-csv--sources '((Scimagojr  "Scimagojr-2018.csv" 1 (7 5 3 2))
                                (GGS  "GGS-2018.csv" 1 (7 2 1))))


(defun cojorank-csv--get-headers (fields)
  (parse-csv-string (buffer-substring (point-min) (search-forward "\n")) ?\; ?\"))

(defun cojorank-csv--search (pubname)
  (occur pubname)
  (with-temp-buffer
    (insert-buffer-substring (get-buffer "*Occur*"))
    (goto-char (point-min))
    (search-forward "\n" nil nil)
    (parse-csv-string-rows (buffer-substring (point) (point-max)) ?\; ?\" "\n")))

(defun cojorank-csv--filter-row (row fields)
  (mapcar (lambda (item) (nth item row)) fields))

(defun cojorank-csv--format-output-line (data)
  (mapconcat (lambda (item) (when item (format "%-20s " item))) data ""))

(defun cojorank-csv-search (source pubname)
  (save-window-excursion
    (let* ((out-buffer (get-buffer-create cojorank-buffer-name))
           (source-info (assoc source cojorank-csv--sources))
           (file-name (expand-file-name (nth 1 source-info) cojorank-csv--directory))
           (source-buffer (find-file file-name))
           (fields (nth 3 source-info))
           (headers (cojorank-csv--get-headers fields))
           (headers-filtered (cojorank-csv--filter-row headers fields))           
           (results (cojorank-csv--search pubname))
           (results-filtered (mapcar (lambda (row) (cojorank-csv--filter-row row fields)) results))
           (output (mapconcat 'cojorank-csv--format-output-line results-filtered "\n")))
      (save-excursion
        (set-buffer out-buffer)
        (goto-char (point-max))
        (insert (format "Searching in %s for %s\n" source pubname))
        (insert (cojorank-csv--format-output-line headers-filtered) "\n")
        (insert output "\n\n")
        ))))

(add-to-list 'cojorank-rank-list-list `("ScimagoJr"
                                        ,(apply-partially 'cojorank-csv-search 'Scimagojr)
                                        "https://www.scimagojr.com/"))

(add-to-list 'cojorank-rank-list-list `("GGS"
                                        ,(apply-partially 'cojorank-csv-search 'GGS)
                                        "GII-GRIN-SCIE Italian-Spanish http://gii-grin-scie-rating.scie.es/ratingSearch.jsf"))

(provide 'cojorank-csv)
