;;; cojorank-nsd.el -- support for NSD-Nordic rankings
;; --------------------

;;; Code:
(require 'url)
(require 'libxml)

(defun cojorank-NSD--parse-table (table)
  (let ((header (format "%4s\t%s" "Rank (3=top)" "Venue"))
        (out (mapconcat (lambda (row)
                          (unless (or (stringp row)
                                      (not (equal 'tr (car row))))
                            (let ((rank (string-trim (nth 2 (nth 2 row))))
                                  (name (nth 2 (nth 3 (nth 4 row)))))
                              (format "%4s\t%s\n" rank name)))) table "")))
    (format "%s\n%s\n\n" header out)))

(defun cojorank-NSD (pubname)
  (let ((search-url (concat "https://dbh.nsd.uib.no//publiseringskanaler/KanalTreffliste.action"
                            "?xs=" (url-hexify-string pubname)
                            "&tv=true"))
        (buf (get-buffer-create cojorank-buffer-name)))
    (url-retrieve search-url
                  `(lambda (status)
                     (goto-char (point-min))
                     (if (< 0 (how-many "<h2>Ingen treff</h2>"))
                         (save-excursion
                           (set-buffer ,buf)
                           (goto-char (point-max))
                           (insert "Could not find any hits\n"))
                       (progn                           
                         (search-forward "<h3>Tidsskrifter/serier</h3>")
                         (search-forward "<tbody>")
                         (let* ((table (libxml-parse-html-region (point) (point-max)))
                                (table-meat (cddr (nth 2 table))))
                           (save-excursion
                             (set-buffer ,buf)
                             (goto-char (point-max))
                             (insert (cojorank-NSD--parse-table table-meat))
                             ))))))))

(add-to-list 'cojorank-rank-list-list '("NSD-Nordic"
                                        'cojorank-NSD
                                        "The Nordic List
Published: 2019-05-14

Since 2015 the Nordic countries have been collaborating to develop a common registry of authorized research publication channels with bibliographic data on journals, series and publishers. Denmark, Finland and Norway have joined their national lists of authorized research publication channels, used for indicators in the national performance-based research funding systems.

Sweden, Iceland, Greenland and Faroe Islands do not have a similar funding system but are planning to use such lists as a tool for a national or Nordic overview of authorized research publication channels.

NSD - Norwegian Centre for Research Data, have coordinated the technical development in 2017/2018 and the work is funded by NordForsk and The Presidency of the Nordic Council.

The Nordic list consists of a bibliographic dataset on the publication channels listed in each countries national database. The national lists are joined technically which give superusers in all the countries a common source of information desirable from the perspective of resource efficiency and as a tool for the countries without a list. The list provides more information by updating the bibliographic data in the national databases and facilitates an overview of research output in the Nordic countries.

The Nordic List application and database are hosted in a cloud solution and are available for the contributing stakeholders via a log in solution. The list supports publishers, series, journals and conferences, with associated data fields and OECD fields are added. The list also supports metadata unique to the Nordic list (registration dates, modification dates, history, comments etc.)"))
