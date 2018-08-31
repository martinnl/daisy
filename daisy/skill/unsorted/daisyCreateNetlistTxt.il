(simulator 'spectre)
(design 
 (getShellEnvVar "NETLIST_LIB")  
 (getShellEnvVar "NETLIST_CELL")
 (getShellEnvVar "NETLIST_TYPE"))

(createNetlist 
 ?recreateAll t)

(setq p1
      (outfile 
       (sprintf nil "%s/%s/sim/ocean/tmp-%s-%s-%s-%s.txt" 
		(getShellEnvVar "WORKAREA") 
		(getShellEnvVar "NETLIST_DDC")
		(getShellEnvVar "NETLIST_LIB")
		(getShellEnvVar "NETLIST_CELL")
		(getShellEnvVar "NETLIST_TYPE")
		(getShellEnvVar "USER"))
       "w" ))

(fprintf p1 "createNetlist: %s %s %s\n" 
	 (getShellEnvVar "NETLIST_LIB")
         (getShellEnvVar "NETLIST_CELL") 
	 (getShellEnvVar "NETLIST_TYPE"))
(close p1)
(exit)
