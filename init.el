;;; init.el --- Where all the magic begins
;;
;; Part of the Emacs Starter Kit
;;
;; This is the first thing to get loaded.
;;

;; remember this directory
(setq kicker-dir
      (file-name-directory (or load-file-name (buffer-file-name))))

(defconst kicker-start-time (float-time))
(defvar kicker-last-time kicker-start-time)
(defun kicker-m (txt)
  "* Kicker"
  (message "[Kicker] %s in %1f seconds, %1f seconds elapsed"
           txt
           (- (float-time) kicker-last-time)
           (- (float-time) kicker-start-time))
  (setq kicker-last-time (float-time)))

(kicker-m "Added lisp/src as magic source directory.")

(require 'org-install)
(kicker-m "Loaded latest Org-file")
(setq debug-on-error t)
(defcustom kicker-grace nil
  "Handle kicker errors with grace"
  :type 'boolean)


(defun kicker-load-org (file)
  "Loads Emacs Lisp source code blocks like `org-babel-load-file'.  However, byte-compiles the files as well as tangles them..."
  (flet ((age (file)
              (float-time
               (time-subtract (current-time)
                              (nth 5 (or (file-attributes (file-truename file))
                                         (file-attributes file)))))))
    (let* ((base-name (file-name-sans-extension file))
           (exported-file (concat base-name ".el"))
           (compiled-file (concat base-name ".elc")))
      (unless (and (file-exists-p exported-file)
                   (> (age file) (age exported-file)))
	(message "Trying to Tangle %s" file)
        (condition-case err
	    (progn
	      (org-babel-tangle-file file exported-file "emacs-lisp")
              (kicker-m (format "Tangled %s to %s"
				file exported-file)))
          (error (if kicker-grace
		     (message "Error Tangling %s" file)
		   (error "Error Tangling %s" file)))))
      (when (file-exists-p exported-file)
        (if (and (file-exists-p compiled-file)
                 (> (age exported-file) (age compiled-file)))
            (progn
              (condition-case err
                  (load-file compiled-file)
                (error (if kicker-grace
			   (message "Error Loading %s" compiled-file)
			 (error "Error Loading %s" compiled-file))))
              (kicker-m (format "Loaded %s" compiled-file)))
          (condition-case err
              (byte-compile-file exported-file t)
            (error (if kicker-grace
		       (message "Error Byte-compiling and loading %s" exported-file)
		     (error "Error Byte-compiling and loading %s" exported-file))))
          (kicker-m (format "Byte-compiled & loaded %s" exported-file))
          ;; Fallback and load source
          (if (file-exists-p compiled-file)
              (set-file-times compiled-file) ; Touch file.
            (condition-case err
                (load-file exported-file)
              (error (if kicker-grace
			 (message "Error loading %s" exported-file)
		       (error "Error loading %s" exported-file))))
            (kicker-m (format "Loaded %s since byte-compile failed."
			      exported-file))))))))

;; Make sure elpa is present
(when (< emacs-major-version 24)
  (load (expand-file-name "lisp/src/package.el" usb-app-dir)))

;; load up the starter kit
(kicker-load-org (expand-file-name "kicker.org" kicker-dir))

;;; init.el ends here
