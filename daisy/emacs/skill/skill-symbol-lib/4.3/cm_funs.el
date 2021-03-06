(put 'cm_funs 'symbol-type "configuration management fun")
(setq cm_funs '(
("cmChangeConfigPermission" "d_libraryId t_configName t_configName t_configType")
("cmChangeDesignConfigPermission" "d_libraryId t_configName t_mode")
("cmChangeEntryConfigPermission" "d_libraryId t_configName t_mode")
("cmChangeRunConfigPermission" "d_libraryId t_configName t_mode")
("cmCopyConfig" "d_libraryId t_configName t_destinationDirectory t_destinationLibrary t_configType")
("cmCopyDesignConfig" "d_libraryId t_configName t_destinationDirectory t_destinationLibrary")
("cmCopyEntryConfig" "d_libraryId t_configName t_destinationDirectory t_destinationLibrary")
("cmCopyRunConfig" "d_libraryId t_configName t_destinationDirectory t_destinationLibrary")
("cmCreateConfig" "d_libraryId t_configName y_temp t_configType t_DesignPathSubConfig l_cellviewList t_cellviewFileName t_entryConfig")
("cmCreateDesignConfig" "d_libraryId t_configName y_temp t_subconfigName")
("cmCreateEntryConfig" "d_libraryId t_configName y_temp t_topDesign l_cellviewList t_cellviewFileName")
("cmCreateRunConfig" "d_libraryId t_configName y_temp t_toolType t_runDirPath l_cellviewList t_entryConfig")
("cmDeleteConfig" "d_libraryId t_configName t_configType y_delUnrefObj y_askUser")
("cmDeleteDesignConfig" "d_libraryId t_configName y_delUnrefObj y_askUser")
("cmDeleteEntryConfig" "d_libraryId t_configName y_delUnrefObj y_askUser")
("cmDeleteRunConfig" "d_libraryId t_configName y_delUnrefObj y_askUser")
("cmFreezeConfig" "d_libraryId t_configName t_templateName t_postfix t_configType")
("cmFreezeDesignConfig" "d_libraryId t_configName t_templateName t_postfix")
("cmFreezeEntryConfig" "d_libraryId t_configName t_templateName t_postfix")
("cmFreezeRunConfig" "d_libraryId t_configName t_templateName t_postfix")
("cmGenConfigFlatList" "d_libraryId t_rootConfig l_component y_reset")
("cmGenConfigHierList" "d_libraryId t_rootConfig l_component x_level")
("cmGetConfigParent" "d_libraryId t_configName")
("cmKeepConfig" "d_libraryId t_configName t_configType")
("cmKeepDesignConfig" "d_libraryId t_configName")
("cmKeepEntryConfig" "d_libraryId t_configName")
("cmKeepRunConfig" "d_libraryId t_configName")
("cmRollConfig" "d_libraryId t_configName y_roll t_configType [t_destination]")
("cmRollEntryConfig" "d_libraryId t_configName y_roll")
("cmRollRunConfig" "d_libraryId t_configName y_roll t_runDirectory")
("cmUnfreezeConfig" "d_libraryId t_configName t_configType")
("cmUnfreezeDesignConfig" "d_libraryId t_configName")
("cmUnfreezeEntryConfig" "d_libraryId t_configName")
("cmUnfreezeRunConfig" "d_libraryId t_configName")
))
