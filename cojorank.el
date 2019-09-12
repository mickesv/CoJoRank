;;;  CoJoRank -- Conference and Journal Rank aggregator
;;
;; Author: Mikael Svahnberg <mikael.svahnberg@gmail.com>
;; Version: 0.1.0
;;
;; The MIT License (MIT)
;;
;; Copyright (c) 2016 Mikael Svahnberg
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;;
;;; Commentary:
;;
;; A search aggregator to get ranks of conferences and journals from various sites
;;
;; <2019-09-09 Mon> Lists
;; [X] NSD-Nordic https://dbh.nsd.uib.no/publiseringskanaler/Forside
;; [ ] GII-GRIN-SCIE Italian-Spanish http://gii-grin-scie-rating.scie.es/ratingSearch.jsf
;; [ ] Core Journals http://portal.core.edu.au/jnl-ranks/
;; [ ] Core Conferences http://portal.core.edu.au/conf-ranks/
;; [ ] Gude2Research http://www.guide2research.com/topconf/
;; [ ] ConferenceRanks http://www.conferenceranks.com/
;; [ ] Scimagojr https://www.scimagojr.com/journalrank.php?type=p
;; [ ] Google Scholar https://scholar.google.com/citations?view_op=top_venues&hl=en&vq=eng_softwaresystems


;;; Code:
(require 'url)
(require 'libxml)

(defconst cojorank-buffer-name "*CoJoRank*")
(defvar cojorank-rank-list-list nil "List of (:name desriptive-name :function function-that-searches-rank-list :details text-description)")


;; rank-lists
(require 'cojorank-nsd)
(require 'cojorank-gii-grin-scie)
 
;; Generic functions
;; --------------------

(defun cojorank-details (list-name)
  (interactive (list (completing-read "Name of List: " (mapcar (lambda (line) (car line)) cojorank-rank-list-list))))
  (let ((buf (get-buffer-create cojorank-buffer-name))
        (elt (assoc list-name cojorank-rank-list-list)))
    (switch-to-buffer buf)
    (goto-char (point-max)) 
    (insert (format "\nDetails for %s:\n" list-name))
    (insert (format "%s\n" (nth 2 elt)))))

(defun cojorank-search (pubname)
  (interactive "PPublication to search for: ")
  (let ((buf (get-buffer-create cojorank-buffer-name)))
    (switch-to-buffer buf)
    (goto-char (point-max))     
    (dolist (rank-list cojorank-rank-list-list)    
      (insert (format "\nSearching for %s in %s..." pubname (car rank-list)))
      (funcall (nth 2 rank-list)) pubname)))

(provide 'cojorank)
;;; cojorank.el ends here
