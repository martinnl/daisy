#!/usr/bin/perl

# Used a template from cadence support:
# Date : 8th Jan 2010
# Author : Quek Hong Cheang
# Solution : 11609162
# Selectable extraction modes are rc_coupled/decoupled, 
# c_only_coupled/decoupled, r_only

# Modified by JJ Wikner, Prismatic Sensors AB. 
# Added QRC feature, pretty-printing, daisy-based
# Updated the libraries and created $userName-tagged cells.

# Syntax: daisyRunAllPv.pl $ddcName $libName
#

if($#ARGV+1 lt 2) {
    $ddcName = "xrayChannel_3b";
    $libName = "xrayChannelAmp_3b"; #Name of sch library
}
else {
    $ddcName = $ARGV[0];
    $libName = $ARGV[1];
}

if($#ARGV+1 gt 2) {
    $forceRun = 1;
}
else {
    $forceRun = 0;
}

if($#ARGV+1 gt 3) {
    $cellNameForce = $ARGV[3];
}
else {
    ### Unlikely that a cell will be called _runAll, but yet... a more clever approach could be used...
    $cellNameForce = "_runAll";
}

$projArea = $ENV{'PROJAREA'};
$verArea = "$projArea/$ddcName/pv/";
$libPath="$projArea/$ddcName/oa/$libName"; # Note that this is path, not just a name

if (defined $ENV{'DAISY_PV_QRC_GND'}) {
    $capGndNet=$ENV{'DAISY_PV_QRC_GND'};
} else {
    $capGndNet="AVSS";
};

### The following variables need to be defined by user ###

$inputLayType="df2"; #df2, gds2 or oasis
$inputSchType="df2"; #cdl or df2

# if layout input type is df2, 
# please specify libPath and viewName
$layViewName="layout";

# if layout input type is gds2 or oasis, 
# please specify path to gds2/oasis file
$gdsOasisFile="./gdsLib/design.gds";

# if input type is cdl, 
# please specify location of cdl netlist
$cdlNetlist="netlists/cdl/design.cdl";

# if input type is df2, 
# please specify name of sch lib & view
$schViewName="schematic";

$userName =  $ENV{'USER'};
$workArea =  $ENV{'WORKAREA'};

#print "\\cp -f $workArea/cds.lib $verArea";
#system "\\cp -f $workArea/cds.lib $verArea";
#system "cd $verArea";
#chdir($verArea);

#
# Setup assura
#

## The below ones could be picked up from daisy kit (projSetup or similar).

$extRules="/sw/lib/pdk/umc/55/sp/a07/Rulefiles/Assura/LVS/extract.rul";
$comRules="/sw/lib/pdk/umc/55/sp/a07/Rulefiles/Assura/LVS/compare.rul";
$bindRules="/sw/lib/pdk/umc/55/sp/a07/Rulefiles/Assura/LVS/compare.rul";
$drcRules="/sw/lib/pdk/umc/55/sp/a07/Rulefiles/Assura/DRC/G-DF-LOGIC_MIXED_MODE55N-1P10M2T2F-SP-ASSURA-DRC-1.6-P1.rul";
$qrcTechDir="/sw/lib/pdk/umc/55/sp/a07/Rulefiles/QRC/typical";

$lvsIncludeFile=""; #Optional

# lvs switches

$lvsSw= "2.5V_IO Metal_Option--1P10M2T2F POST_SIM_parameter_extract Skip_Soft-Connect_Checks FDK"; # 2.5V_IO FDK Metal_Option--1P10M2T2F Skip_Soft-Connect_Checks ";

$drcSw="Skip_DIFF_DENSITY_Check Skip_POLY_DENSITY_Check Skip_L2_DENSITY_Check Skip_DFM_Priority1_Check Skip_DFM_Priority2_Check Skip_TG33_RULE_Check Skip_SRAM_RULE_Check Skip_eDRAM_RULE_Check Skip_METAL_DENSITY_Check Skip_TG33_RULE_Check";
## Skip_TG25_OD33_RULE_Check Skip_TG25_RULE_Check Skip_TG25_UD18_RULE_Check 

#spectre, spice, dspf, lvs_extracted_view or extracted_view
$outputType="extracted_view";
$outputName="av_extracted";

#r_only, c_only_coupled, c_only_decoupled, rc_coupled, rc_decoupled
$extractType="r_only"; $outputName = "av_extracted_r";
#$extractType="c_only"; $outputName="av_extracted_c"; 
#$extractType="c_only_coupled"; $outputName="av_extracted_c_cop"; 
#$extractType="c_only_decoupled"; $outputName="av_extracted_c_dec"; 
#$extractType="rc_coupled"; $outputName="av_extracted_rc_cop"; 
#$extractType="rc_decoupled"; $outputName="av_extracted_rc_dec";


my %extractList;
$extractList{'r_only'}='av_extracted_r';
$extractList{'c_only'}='av_extracted_c';

$extractList{'c_only_coupled'}='av_extracted_c_cop';
$extractList{'c_only_decoupled'}='av_extracted_c_dec';

$extractList{'rc_coupled'}='av_extracted_rc_cop';
$extractList{'rc_decoupled'}='av_extracted_rc_dec';


### The above variables need to be defined by user ###


############################
############################


@pathList=split /\//, $libPath;
$libName=@pathList[len-1];

@corList=split /\//, $qrcTechDir;
$corName=@corList[len-1];

print "Start: ".`date`;
print "=== Generating $outputType output for library $libName ===\n\n";

@swList=split / /, $lvsSw;
foreach $sw (@swList) {
   $lvsSw2="$lvsSw2 \"$sw\"";
} #foreach

@swDrcList=split / /, $drcSw;
foreach $sw (@swDrcList) {
   $drcSw2="$drcSw2 \"$sw\"";
} #foreach

if(!open(qrcTechLib, ">my_qrcTech.lib")) {
      die("Cannot create file my_qrcTech.lib\n")
} #if
print qrcTechLib "DEFINE myTech $qrcTechDir\n";

unless( -e "$verArea/lvs" ) { system "mkdir -p $verArea/lvs"; }
unless( -e "$verArea/log" ) { system "mkdir -p $verArea/log"; }
#system "touch $verArea/log/daisyRunAllPv.$libName.log";
    
if( $outputType =~ /spice|spectre|dspf/ ) {
   unless( -e "qrcOutput" ) { system "mkdir qrcOutput"; }
   unless( -e "qrcOutput/$corName" ) { system "mkdir qrcOutput/$corName"; }
} #if

if($outputType eq "spectre") {
   $fileExt="scs";
} #spectre
elsif($outputType eq "spice") {
   $fileExt="sp";
} #spice
elsif($outputType eq "dspf") {
   $fileExt="dspf";
} #dspf

if ( -e $verArea."/log/daisyRunAllPv.".$libName.".timestamp.log" ) { 
    $lastTime = ( stat ( $verArea."/log/daisyRunAllPv.".$libName.".timestamp.log" ))[9];
} else {
    $lastTime = 0;
}

if ($forceRun) {
    $lastTime = 0;
}

@dirContents=<$libPath/*>;
foreach $item (@dirContents) {
   @itemList=split /\//, $item;
   $cellName=@itemList[@itemList-1];
   # Add check here if cellNameForce is defined and only run for that cell

   if( $cellName eq $cellNameForce  or  $cellNameForce eq "_runAll")  {
       
   if( -d $libPath."/" . $cellName . "/" . $layViewName ) {

       $modTime = ( stat ( $libPath."/" . $cellName . "/" . $layViewName ))[9];
       
       print "\n ==================== $cellName ($modTime/$lastTime) =================== \n";
       
       if( ($modTime gt $lastTime) or $forceRun ) {	   
	   print "The layout has changed (or runs are forced): tests will be performed \n";

       print "Running Assura DRC for cell : $cellName ... ";
       unless( -e "$verArea/drc/$cellName" ) { system "mkdir -p $verArea/drc/$cellName"; }

       &createDRCrsf;
       
      system "assura /tmp/$userName.drc.rsf -cdslib $workArea/cds.lib > $verArea/drc/$cellName/$cellName.log";
      system "cp /tmp/$userName.drc.rsf $verArea/drc/$cellName/$cellName.rsf";
      if(!open(drcLogFile, "$verArea/drc/$cellName/$cellName.log")) {
         die("Cannot read Assura log file $verArea/drc/$cellName/$cellName.log\n")
      } #if
      $drcResults="There are no DRC errors in $cellName";
      while( chomp($inLine=<drcLogFile>)) {
         if( $inLine =~ /Total  errors:/ ) {
            $drcResults=$inLine; 
         } #if
      } #while
      close drcLogFile;
      print "Completed DRC - see  $cellName.err. \n ------------ \n DRC: $drcResults\n ------------ \n";
       
	   
	   #######
	   
	   print "Running Assura LVS for cell : $cellName ... ";
	   unless( -e "$verArea/lvs/$cellName" ) { system "mkdir -p $verArea/lvs/$cellName"; }

      &createLVSrsf;
      if( $inputSchType eq "df2" ) {
         system "dfIItoVldb $verArea/lvs/$cellName/$cellName.vlr";
      } #if
       
       system "assura -v /tmp/$userName.lvs.rsf -cdslib $workArea/cds.lib -v > $verArea/lvs/$cellName/$cellName.log";
       
      system "cp /tmp/$userName.lvs.rsf $verArea/lvs/$cellName/$cellName.rsf";
      if(!open(lvsLogFile, "$verArea/lvs/$cellName/$cellName.log")) {
         die("Cannot read Assura log file $verArea/lvs/$cellName/$cellName.log\n")
      } #if
      $lvsResults="LVS errors";
      while( chomp($inLine=<lvsLogFile>)) {
         if( $inLine =~ /Schematic and Layout Match/ ) {
            $lvsResults="LVS match";
         } #if
      } #while
      close lvsLogFile;
      print "Completed LVS for $cellName.  \n ------------ \n LVS: $lvsResults\n ------------ \n ";


       #######

       print "Running QRC extraction for cell : $cellName ... \n ";

       ## Run a loop over all settings here.

       @extractions = keys %extractList;
       for $extractType (@extractions){
	   print "Running $extractType... ";
	   $outputName = $extractList{$extractType};
	   
	   &createQRCccl;
	   #system "cd $verArea/lvs/$cellName";
	   system "qrc -cmd /tmp/$userName.qrc.ccl > $verArea/lvs/$cellName/$cellName.$extractType.qrc.log";
	   #system "cd ../..";
	   system "cp /tmp/$userName.qrc.ccl $verArea/lvs/$cellName/$cellName.$extractType.qrc.ccl";       
	   if(!open(qrcLogFile, "$verArea/lvs/$cellName/$cellName.$extractType.qrc.log")) {
	       die("Cannot read qrc log file $verArea/lvs/$cellName/$cellName.$extractType.qrc.log\n")
	   } #if
	   $qrcResults="Completed with errors";
	   while( chomp($inLine=<qrcLogFile>)) {
	       if( $inLine =~ /QRC terminated normally/ ) {
		   $qrcResults="Completed QRC for $cellName successfully!";
	       } #if
	   } #while
	   close qrcLogFile;
	   print "$qrcResults\n";
	   # system "cat $verArea/lvs/$cellName/$cellName.$extractType.qrc.log";
	   
       } # for $extractType
       
       } else
       {
	   print "Layout of $cellName did not change since last time. \nThat does not necessarily mean they are clean though. Check older log files. \n";
       }
       
       print "======================================= \n";
       
       
   } #if
   }
   
} #foreach

print "\n=== LVS run data is at $verArea/lvs directory ===\n";
print "=== QRC output netlists are at ./qrcOutput/$corName directory ===\n";
system "rm -f /tmp/$userName.lvs.rsf /tmp/$userName.qrc.ccl my_qrcTech.lib";
print "End: ".`date`;

system "echo \"hello\" >> $verArea/log/daisyRunAllPv.$libName.timestamp.log";
system "grep `find $verArea -name '*log' | grep drc` -H -e 'Total  ' > $verArea/log/$libName.results.log";

## Subroutines to generate the run specification files

sub createDRCrsf {
   if(!open(drcFile, ">/tmp/$userName.drc.rsf")) {
      die("Cannot create file /tmp/$userName.drc.rsf\n")
   } #if
   print drcFile "avParameters(\n";
   if( $inputLayType eq "df2" ) {
      print drcFile "   ?inputLayout (\"$inputLayType\" \"$libName\")\n";
   } #if
   else {
      print drcFile "   ?inputLayout (\"$inputLayType\" \"$gdsOasisFile\")\n";
   } #else
   print drcFile "   ?cellName \"$cellName\"\n";
   print drcFile "   ?viewName \"$layViewName\"\n";
   print drcFile "   ?workingDirectory \"$verArea/drc/$cellName\"\n";
   print drcFile "   ?rulesFile \"$drcRules\"\n";
   print drcFile "   ?set ($drcSw2)\n";
   print drcFile ") ;avParameters\n\n";

   print drcFile "avDRC()";
   close drcFile;
} #createDRCrsf

sub createLVSrsf {
   if(!open(lvsFile, ">/tmp/$userName.lvs.rsf")) {
      die("Cannot create file /tmp/$userName.lvs.rsf\n")
   } #if
   print lvsFile "avParameters(\n";
   if( $inputLayType eq "df2" ) {
      print lvsFile "   ?inputLayout (\"$inputLayType\" \"$libName\")\n";
   } #if
   else {
      print lvsFile "   ?inputLayout (\"$inputLayType\" \"$gdsOasisFile\")\n";
   } #else
   print lvsFile "   ?cellName \"$cellName\"\n";
   print lvsFile "   ?viewName \"$layViewName\"\n";
   print lvsFile "   ?workingDirectory \"$verArea/lvs/$cellName\"\n";
   print lvsFile "   ?rulesFile \"$extRules\"\n";
   print lvsFile "   ?set ($lvsSw2)\n";
   print lvsFile "   ?avrpt t\n";
   print lvsFile "   ?joinPins top\n";
   print lvsFile ") ;avParameters\n\n";
   print lvsFile "load \"$comRules\"\n\n";
   if( -e $lvsIncludeFile ) {
      print lvsFile "load \"$lvsIncludeFile\"\n\n";
   } #if
   print lvsFile "avCompareRules(\n";
   print lvsFile "   schematic(\n";
   if( $inputSchType eq "cdl" ) {
      print lvsFile "      netlist(cdl \"$cdlNetlist\")\n";
   } #if
   else {
      &createLVSvlr;
      print lvsFile "      netlist(df2 \"$verArea/lvs/$cellName/$cellName.vlr\")\n";
   } #else
   print lvsFile "      filterOptions(\"XZ\")\n";
   print lvsFile "   ) ;schematic\n";
   print lvsFile "   layout(\n";
   print lvsFile "      filterOptions(\"XZ\")\n";
   print lvsFile "   ) ;layout\n";
#   print lvsFile "   bindingFile(\"$bindRules\")\n";
   print lvsFile "   abortOnUnboundDevices(nil)\n";
   print lvsFile "  bind( cell(\"DION_SP\" \"DION_SP_A\")) \n";
   print lvsFile "   autoPinSwap(t 250000)\n";
   print lvsFile "   expandOnError( 
			(unstableDevices t) (swap t) (reduce t) 
			(pins t) (match t) (swapThres t) (instCount t) 
			(skipMatchOnReduceError t) (ambiguousPinAssignment t) 
			(parameter t) )\n";
   print lvsFile "   listFilteredDevices()\n";
   print lvsFile "   mergeSplitGate( mergeAll )\n";
   print lvsFile ") ;avCompareRules\n\n";
   print lvsFile "avLVS() \n \n";
   print lvsFile "changeLabel( \"DVDD\" \"DVDD:P\")\n";
   print lvsFile "changeLabel( \"DVSS\" \"DVSS:P\")\n";
   print lvsFile "changeLabel( \"AVDD\" \"AVDD:P\")\n";
   print lvsFile "changeLabel( \"VSSANA\" \"VSSANA:P\")\n";
   print lvsFile "changeLabel( \"VDDANA\" \"VDDANA:P\")\n";
   print lvsFile "changeLabel( \"VSS\" \"VSS:P\")\n";
   print lvsFile "changeLabel( \"AVSS\" \"AVSS:P\")\n";
   close lvsFile;
} #createLVSrsf

sub createLVSvlr {
   if(!open(vlrFile, ">$verArea/lvs/$cellName/$cellName.vlr")) {
      die("Cannot create file $verArea/lvs/$cellName/$cellName.vlr\n")
   } #if
   print vlrFile "avSimName = \"auLvs\"\n";
   print vlrFile "avDisableWildcardPG = nil\n";
   print vlrFile "avLibName  = \"$libName\"\n";
   print vlrFile "avCellName = \"$cellName\"\n";
   print vlrFile "avViewName = \"$schViewName\"\n";
   print vlrFile "avViewList = \"auLvs $schViewName symbol\"\n";
   print vlrFile "avStopList = \"auLvs\"\n";
   print vlrFile "avVldbFile = \"$verArea/lvs/$cellName/$cellName.sdb\"\n";
   close vlrFile;
} #createLVSvlr


sub createQRCccl {
   if(!open(qrcFile, ">/tmp/$userName.qrc.ccl")) {
      die("Cannot create file /tmp/$userName.qrc.ccl\n")
   } #if
   print qrcFile "process_technology \\\n";
   print qrcFile "   -technology_library_file \"my_qrcTech.lib\" \\\n";
   print qrcFile "   -technology_name \"myTech\"\n\n";

   if($outputType eq "spectre") {
      print qrcFile "output_db -type spice \\\n";
      print qrcFile "   -postprocess_output_netlist \"spp -convert ".
			"-log $cellName.scs.log\" \n\n";
   } #spectre
   else {
      print qrcFile "output_db -type $outputType -enable_cellview_check false -view_name \"$outputName\" \n";
   } #Others

   print qrcFile "output_setup \\\n";
   if( $outputType =~ /spectre|spice|dspf/) {
      print qrcFile "   -file_name \"qrcOutput/$corName/$cellName.$fileExt\" \\\n";
      print qrcFile "   -net_name_space \"SCHEMATIC\" \\\n";
   } #if
   print qrcFile "   -temporary_directory_name \"$cellName\"\n\n";
   print qrcFile "input_db -type assura \\\n";
   print qrcFile "   -design_cell_name \"$cellName $layViewName $libName\" \\\n";
   print qrcFile "   -directory_name \"$verArea/lvs/$cellName\" \\\n";
   print qrcFile "   -format \"DFII\" \\\n";
   print qrcFile "   -library_definitions_file \"$workArea/cds.lib\" \\\n";
   print qrcFile "   -run_name \"$cellName\" \n\n";
   if( $outputType ne "lvs_extracted_view") {
      print qrcFile "extract \\\n";
      print qrcFile "   -selection \"all\" \\\n";
      print qrcFile "   -type \"$extractType\" \n\n";
   } #unless
   if( $extractType ne "r_only" ) {
      print qrcFile "capacitance \\\n";
      print qrcFile "   -ground_net \"$capGndNet\" \n\n";
      #print qrcFile "   -cap_ground_layer substrate \n\n";
   } #unless
   close qrcFile;
} #createQRCccl
