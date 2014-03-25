(defun orgtrello-buffer/back-to-card! () "Given the current position, goes on the card's heading"
  (org-back-to-heading))

(defun orgtrello-buffer/--card-data-start-point () "Compute the first character of the card's text content."
  (save-excursion
    (orgtrello-buffer/back-to-card!)
    (end-of-line)
    (1+ (point))))

(defun orgtrello-buffer/--first-checkbox-point () "Compute the first position of the card's next checkbox."
  (save-excursion
    (orgtrello-buffer/back-to-card!)
    (orgtrello-cbx/--goto-next-checkbox)
    (1- (point))))

(defun orgtrello-buffer/extract-description-from-current-position! () "Given the current position, extract the text content of current card."
  (let ((start (orgtrello-buffer/--card-data-start-point))
        (end   (orgtrello-buffer/--first-checkbox-point)))
    (when (< start end)
          (orgtrello-buffer/filter-out-properties
           (buffer-substring-no-properties start end)))))

(defun orgtrello-buffer/get-card-comments! ()
  "Retrieve the card's comments. Can be nil if not on a card."
  (orgtrello-action/org-entry-get (point) *ORGTRELLO-CARD-COMMENTS*))

(defun orgtrello-buffer/put-card-comments! (comments)
  "Retrieve the card's comments. Can be nil if not on a card."
  (org-entry-put (point) *ORGTRELLO-CARD-COMMENTS* comments))

(defun orgtrello-buffer/filter-out-properties (text-content) "Given a string, remove any org properties if any"
  (->> text-content
       (replace-regexp-in-string "^[ ]*:.*" "")
       (s-trim-left)))

(defun orgtrello-buffer/--get-data! (key)
  (assoc-default key org-file-properties))

(defun orgtrello-buffer/board-name! ()
  "Compute the board's name"
  (orgtrello-buffer/--get-data! *BOARD-NAME*))

(defun orgtrello-buffer/board-id! ()
  "Compute the board's id"
  (orgtrello-buffer/--get-data! *BOARD-ID*))

(defun orgtrello-buffer/me! ()
  "Compute the board's current user"
  (orgtrello-buffer/--get-data! *ORGTRELLO-USER-ME*))

(defun orgtrello-buffer/labels! ()
  "Compute the board's current labels and return it as an association list."
  (mapcar (lambda (color) `(,color . ,(orgtrello-buffer/--get-data! color))) '(":red" ":blue" ":orange" ":yellow" ":purple" ":green")))

(defun orgtrello-buffer/pop-up-with-content! (title body-content)
  "Compute a temporary buffer *ORGTRELLO-TITLE-BUFFER-INFORMATION* with the title and body-content."
  (with-temp-buffer-window
   *ORGTRELLO-TITLE-BUFFER-INFORMATION* nil nil
   (progn
     (temp-buffer-resize-mode 1)
     (insert (format "%s:\n\n%s" title body-content)))))

(defun orgtrello-buffer/set-property-comment! (comments)
  "Update comments property."
  (org-entry-put nil *ORGTRELLO-CARD-COMMENTS* comments))

(defun orgtrello-buffer/compute-card-header-and-description-region! ()
  "Compute the card region zone (only the card headers + description) couple '(start end)."
  (let ((point-start)
        (point-end)))
  (save-excursion
    (orgtrello-buffer/back-to-card!)
    (setq point-start (point-at-bol))
    (orgtrello-cbx/--goto-next-checkbox)
    (setq point-end (1- (point-at-bol)))
    `(,point-start ,point-end)))

(defun orgtrello-buffer/compute-checklist-header-region! ()
  "Compute the checklist's region (only the header, without computing the zone occupied by items) couple '(start end)."
  `(,(point-at-bol) ,(1+ (point-at-eol))))

(defun orgtrello-buffer/compute-checklist-region! ()
  "Compute the checklist's region (including the items) couple '(start end)."
  `(,(point-at-bol) ,(orgtrello-cbx/next-checklist-point!)))

(defun orgtrello-buffer/compute-item-region! ()
  "Compute the item region couple '(start end)."
  `(,(point-at-bol) ,(1+ (point-at-eol))))

(defun orgtrello-buffer/compute-card-region! ()
  "Compute the card region zone (only the card headers + description) couple '(start end)."
  (let ((point-start)
        (point-end)))
  (save-excursion
    (orgtrello-buffer/back-to-card!)
    (setq point-start (point-at-bol))
    (setq point-end (orgtrello-cbx/--compute-next-card-point))
    `(,point-start ,point-end)))

(orgtrello-log/msg *OT/DEBUG* "org-trello - orgtrello-buffer loaded!")


