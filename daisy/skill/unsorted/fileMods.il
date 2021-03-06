(printf " ... loading %s.il ...\n" "fileMods")

(defun convertTxtFile 
  (@key 
   (fileNameIn     "~/input.dat")
   (fileNameUt     "~/input.txt")
   (sampleTime    4n) 
   (noSamples     10000)
   (delayTime     0)
   (delayLevel    0)
   (posNode       "netP") 
   (negNode       "netN") 
   (srcName       "I0") 
   (spiceFormat   t) )
  
  ;; The program takes a text file input which is a vector and 
  ;; creates a pwlf or matlab stimuli file dependent on input arguments.
  ;; Filenames can be specified as well as nodes or similar for a pwlf 
  ;; source. Sample time and number of samples are specified - although we 
  ;; could let the function continue until end of file.
  
  (let ( (timeStamp 0.0n)		 		
	 (yVal 0.0)
	 (PI 3.1415926535897932385)
	 (sampleNo 1)
	 (iport nil)
	 (oport nil)
	 )
    (setq iport (infile fileNameIn))
    (setq oport (outfile fileNameUt))
    
    (if (and iport oport)
	(progn			  
	  (if spiceFormat
	      (progn
		(fprintf oport "* This file is automatically generated.\n")
		(fprintf oport "* Update your stimulus.cir file to include it.\n")
		(fprintf oport "* .include %s \n" fileNameUt)
		(fprintf oport "%s %s %s PWL( \n" srcName posNode negNode)))
	  (if (float delayTime) > 0
	      (progn
		(fprintf oport "%s %1.12f %6.6f\n" (if spiceFormat "+" "") (float 0)  (float delayLevel))
		(fprintf oport "%s %1.12f %6.6f\n"  (if spiceFormat "+" "") (float delayTime) (float delayLevel)))
	      (fprintf oport "%s %1.12f %6.6f\n" (if spiceFormat "+" "")  (float 0) (float 0)))
	  
	  (while (sampleNo <= noSamples)
	    (fscanf iport "%s" yVal)
	    (setq timeStamp sampleNo*sampleTime+delayTime)
	    (fprintf oport "%s %1.12f %s\n" (if spiceFormat "+" "")  timeStamp yVal)
	    (setq sampleNo (plus sampleNo 1)))
	  (if spiceFormat
	      (fprintf oport "+ R=%1.12f SHIFT=%1.12f )" 
		       (float 0) (float delayTime) ))
	  (close oport)
	  (close iport) ))))

(defun convertAllTxtFiles ()
  (foreach file (ls)	   
	   (if (strlen file) > 3
	       (if (equal (substring file (strlen file)-2) "dat")
		   (progn
		     (convertTxtFile 
		      ?fileNameIn file 
		      ?fileNameUt (strcat (substring file 1 (strlen file)-4) ".pwlf")
		      ?spiceFormat t)
		     (convertTxtFile 
		      ?fileNameIn file 
		      ?fileNameUt (strcat (substring file 1 (strlen file)-4) ".txt")
		      ?spiceFormat nil))))) t)

(defun csvAlist (textAlist @optional (separator ",") (lineend "\n"))
  ;; Takes an association list and generates two csv strings:
  ;; One with the keys and one with the values.
  ;; (list (list "a" "b") (list "c" "d")) -> 
  ;;    (list (list "a,c\n") (list "b,d\n"))
  (let ((keyList (list))
	(valList (list)))
    (foreach keyValue textAlist
	     (setq keyList (append keyList (list (car keyValue))))
	     (setq valList (append valList (cdr keyValue))))
    (list 
     (csvList keyList separator lineend)
     (csvList valList separator lineend))))


(defun csvList (textList @optional (separator ",") (lineend "\n"))
  ;; Takes a list of text strings and generates a combined text string with comma 
  ;; separation.
  ;; (list "a" "b" "c") -> "a,b,c"
  ;;
  (let ((csvString ""))    
    (setq csvString (car textList))
    (foreach component (cdr textList)
	     (setq csvString (strcat csvString separator component)))    
    (setq csvString (strcat csvString lineend))
    csvString))

(defun readCSVfile (fileName @optional (separator ",\n") )
  ;; Takes a csv file from e.g. excel and translates it into a list. 
  ;; very similar to the csvread function, but slightly different.
  
  ;; It associates the first line of the file with all other lines.
  ;; Non-empty cells in the spread sheet are not allowed.

  (let ((csvPort nil)
	(verbose nil)
	(padList nil)
	(list1 nil)
	(line "")
	(headerLine nil)
	(itemPointer 0)
	(lineItems nil))
    
    (setq csvPort (infile fileName))
    (when csvPort 
      (gets headerLine csvPort)
      (if verbose (printf "%s\n" headerLine))
      (setq items (parseString headerLine separator))
      (while  (gets line csvPort)
	(if verbose (printf "%s\n" line) )
	(setq lineItems (parseString line separator))
	(setq itemPointer 0)
	(setq list1 nil)
	(foreach itemX items 
		 (setq list1 
		       (append list1 
			       (list (list itemX (nth itemPointer lineItems)))))
		 (setq itemPointer (plus itemPointer 1)))
	(setq padList (append padList (list list1))))
      (close csvPort) )
    padList))

(defun daisySaveListToFile (textList @optional (fileName nil))
  (let ( (tmpFileName "") (tmpList nil) (oport nil) (textString "") )
    (if (not fileName)
	(setq oPort 
	      (outfile 
	       (setq fileName (makeTempFileName "/tmp/filetkniv.txt"))))
      (setq oPort
	    (outfile fileName)))

    (if oPort 
	(progn
	  (setq tmpList textList) ;; Not really needed, but just to avoid the final line feed...
	  (while tmpList
	    (setq textString (car tmpList))
	    (fprintf oPort textString)
	    (if (cdr tmpList) (fprintf oPort "\n"))
	    (setq tmpList (cdr tmpList)))
	  
	  (close oPort)))
    fileName) )
	     
(defun daisyDisplayFile (fileName)
  (if fileName
      
      (sh (sprintf nil "emacs %s &" fileName))))

(defun daisyDisplayList (textList)
  (daisyDisplayFile (daisySaveListToFile textList)))

(defun daisyRunBigFile (fileName)
  (let ((iport (infile fileName)) 
	)
    (while (setq a (read iport))
      (eval a))
    (close iport)))

