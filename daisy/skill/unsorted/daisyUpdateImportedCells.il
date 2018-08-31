(setq iopin (dbOpenCellViewByType "basic" "iopin" "symbol" "" "r" ) )
(setq ipin  (dbOpenCellViewByType "basic"  "ipin" "symbol" "" "r" ) )
(setq oppin (dbOpenCellViewByType "basic"  "opin" "symbol" "" "r" ) )

cellName = "AD42M2HA"
libName  = "uk65lscsp10bbhccs"
libName  = "uk65lscsp10bbrccs"
schType  = "schematic" ;; "schematic_lvs"
nType    = "N_11_SPRVT" ;; "N_11_SPHVT"
pType    = "P_11_SPRVT" ;; "P_11_SPHVT"

(setq ddLibId  (ddGetObj libName))
cellIds = ddLibId->cells

;; (setq cellId (dbOpenCellViewByType libName cellName schType "" "a"))

;; cellIdX = (nth 35 cellIds)

(foreach cellIdX cellIds

(setq cellId (dbOpenCellViewByType cellIdX->lib->name  cellIdX->name schType "" "a"))

(if cellId (progn
;; replace all the nmos
(setq nfetId (dbOpenCellViewByType "umc65sp" nType "symbol" "" "r"))
(foreach nmos (setof x cellId->instances (and 
					  (equal x->libName "daisyScripts")
					  (equal x->cellName "nfet")))
	 (printf "hehe\n")
	 nmos->master = nfetId)

;; replace all the pmos
(setq pfetId (dbOpenCellViewByType "umc65sp" pType "symbol" "" "r"))
(foreach pmos (setof x cellId->instances (and 
					  (equal x->libName "daisyScripts")
					  (equal x->cellName "pfet")))
	 (printf "hehe\n")
	 pmos->master = pfetId)

(setq symbolId (dbOpenCellViewByType libName cellName "symbol" "" "r"))


(foreach schTerm (setq schTerminals cellId->terminals)
	 (foreach terminal (setof x symbolId->terminals (equal x->name schTerm->name))		  
		  (if (not (equal terminal->direction schTerm->direction))		
		      ;; Then check the pins against each other and swap the terminal
		      (printf "%s : %s = %s \n" terminal->name terminal->direction schTerm->direction))))
	 
(dbSave cellId)

)
)
)
