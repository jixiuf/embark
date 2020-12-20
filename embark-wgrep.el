(require 'wgrep)

;;;###autoload
(defun embark-occur-wgrep-setup ()
  (set (make-local-variable 'wgrep-header/footer-parser)
       'embark-occur-wgrep-prepare-header/footer)
  (set (make-local-variable 'wgrep-results-parser)
       'embark-occur-wgrep-parse-command-results)
  (wgrep-setup-internal))

(defun embark-occur-wgrep-prepare-header/footer ()
  (let ((beg (point-min))
        (end (point-min))
        (overlays (overlays-at (point-min))))
    ;; Set read-only grep result header
    (dolist (o overlays)
      (when (eq (overlay-get o 'face) 'tabulated-list-fake-header)
        (setq end (overlay-end o))))
    (put-text-property beg end 'read-only t)
    (put-text-property beg end 'wgrep-header t)
    ;; embark-occur-mode have NO footer.
    (put-text-property (1- (point-max)) (point-max) 'read-only t)
    (put-text-property (1- (point-max)) (point-max) 'wgrep-footer t)))


(defun embark-occur-wgrep-parse-command-results ()
  (while (not (eobp))
    (when (looking-at wgrep-line-file-regexp)
      (let* ((start (match-beginning 0))
             (end (match-end 0))
             (line (string-to-number (match-string 3)))
             (fn (match-string 1))
             (fnamelen (length fn))
             (dir (locate-dominating-file default-directory fn)))
        (unless (file-name-absolute-p fn)
          (setq fn (expand-file-name fn dir)))
        (let* ((fprop (wgrep-construct-filename-property fn)))
          (put-text-property start end 'wgrep-line-filename fn)
          (put-text-property start end 'wgrep-line-number line)
          (put-text-property start (+ start fnamelen) fprop fn))))
    (forward-line 1)))


;;;###autoload
(add-hook 'embark-occur-mode-hook 'embark-occur-wgrep-setup)

;; For `unload-feature'
(defun embark-wgrep-unload-function ()
  (remove-hook 'embark-occur-mode-hook 'embark-occur-wgrep-setup))

(provide 'embark-wgrep)

;;; embark-wgrep.el ends here
