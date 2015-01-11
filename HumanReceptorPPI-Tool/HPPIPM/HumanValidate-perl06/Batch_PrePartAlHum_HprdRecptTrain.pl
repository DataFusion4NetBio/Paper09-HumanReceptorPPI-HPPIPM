# 
# This program is to batch process and predict the intearction partners from all human genes for a list of input genes
# The trained model is on the hprd-receptor based 
# 
# perl Batch_PrePartAlHum_HprdRecptTrain.pl 12HumanValidateSoftwareDir inputGeneListFile  
# 
# 
# We have a list of interested genes , we want to make the interaction predictions among the NCBI human gene list 
# 
# input interested gene list format:   # proGI	proAcc	geneID	geneSym
# 


use strict; 
die "Usage: command HumanValidateSoftwareDir interested_genelist \n" if scalar(@ARGV) < 2; 

my ($localPath, $interested_genelist ) = @ARGV; 

my $ncbiProteinFileName = "/ncbi_info/human.ncbiprotein.list"; 
my $ncbiGeneInfoFileName = "/ncbi_info/human_gene_info.ncbiGene"; 
  
my $RequestGeneFilePre = "/requestGeneFile/requestGeneFile"; 
my $getRequestGeneInfoPerl = "requestGeneFile/getGeneInfo.pl";         
my $RequestGeneFile ; 
    
#--------------------- read in the interested gene name file -------------------------------

my %geneInterested = ();                  # lookup table to gene list we need 
my $count = 0; 
open(INPUT, $interested_genelist) || die(" Can not open file(\"$interested_genelist\").\n"); 
while (<INPUT>)	
{
	chomp $_;	
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
		
	my @cur_line = split('\t', $_); 
	my $proGI  = $cur_line[0] ;
	my $proAcc  = $cur_line[1] ;
	my $geneID  = $cur_line[2] ;
	my $geneSym  = $cur_line[3] ;
	$geneInterested{"$geneID"} = "$proGI"; 
	$count = $count  +  1; 				

	$RequestGeneFile = "$localPath$RequestGeneFilePre.$geneID"; 
	
	open(OUT, "> $RequestGeneFile") || die(" Can not open file(\"$RequestGeneFile\").\n"); 
	print OUT "#proGI	proAcc	geneID	geneSym\n"; 
	print OUT "$proGI	$proAcc	$geneID	$geneSym\n";
	close(OUT); 


	print "\n********************* count: $count *********************************************\n"; 
	print "\n-------------   For GENEID: $geneID ----------------------------\n";
	print "\n\nRequestGeneFile: $RequestGeneFile\n\n";

# -----------------------------------------------------------------------------------
#/** 0-Create-PPI-List for a specific gene ID based on the NCBI-protein-gene-list file */        

print "#/** 0-Create-PPI-List for a specific gene ID based on the NCBI-protein-gene-list file */        \n";
my $creatPPIlistPerl = "/0create_ppi_list/makeggpair_4ncbiplist_hpbdlable.pl";
#                                  "0create_ppi_list/makeggpair_4curGenelist_hpbdlable.pl", 
#                                  "0create_ppi_list/makeggpair_4curTasklist_hpbdlable.pl"};     
 
my $posPPIfile = "/0create_ppi_list/human.hprd.posPair"; 
my $outPPairfileDir = "/0create_ppi_list/PPI_lists/"; 
my $outPPairfilePre = "human.hprdlabel"; 
my $outPPairfilePreChange = ".allhuman.ggi"; #= {".allhuman.ggi", ".withCurGeneList.ggi", ".withCurTaskList.ggi"}; 

my $humanProteinList = $localPath . $ncbiProteinFileName;        
my $perlCommand = "perl "  .  $localPath  .  $creatPPIlistPerl; 
my $posPPIchoose = $localPath  .  $posPPIfile; 
my $outFile =  $localPath  .  $outPPairfileDir  .  $outPPairfilePre  .  $outPPairfilePreChange ; #outPPairfilePreChange[createChoice] ;
my $logFile = $outFile   .  "."  .  $geneID  .  ".log";
        
my $cmd = $perlCommand  .  "  "  .  $RequestGeneFile  .  " "  .  $humanProteinList  .  " "  .  " "  .  $posPPIchoose  .  " "  .  $outFile  .  " > $logFile"; 
print "$cmd\n";
system($cmd) ;
my $outPPairfilePreFull = $outPPairfilePre  .  $outPPairfilePreChange ;


# -----------------------------------------------------------------------------------
#/** 1-generate-feature */
print "\n#/** 1-generate-feature */\n";
     
my $generateFeaCurDir = "/1features/";
my $FeaFileDir = "/1features/train_gold/27feaSets/";    
my $generateFeaPerl = "Batch_featureExtractHumanFull.dirPara.27feafill.Rf.pl";

my $ppiListFileLoc1 =  $localPath  .  $outPPairfileDir  .  $outPPairfilePreFull  .  "."  .  $geneID ; 
my $ppiListFileLoc2 =  $localPath  .  $FeaFileDir  .  $outPPairfilePreFull  .  "."  .  $geneID ; 
$cmd = "cp $ppiListFileLoc1  $ppiListFileLoc2";
print "$cmd\n";
system($cmd) ;


$perlCommand = "perl "  .  $localPath  .  $generateFeaCurDir  .  $generateFeaPerl;
$cmd = $perlCommand  .  " "  .  $localPath  .  $generateFeaCurDir  .  " "  .  $ppiListFileLoc2  .  " > $ppiListFileLoc2.27fea.log "; ; 
print "$cmd\n";
system($cmd) ;



# -----------------------------------------------------------------------------------
#/** 2-Make the testing process for the generated feature files */

print "\n#/** 2-Make the testing process for the generated feature files */\n"; 
my $testDir = "/3testing/"; 
my $testPerl = "/3testing/RF4Tree_classify_valueout_nomissing_Dec05.pl"; 
my $testModelPara = " 0 199 -100 ";     
my $testModelFile = "/2training/27fea-model/hprdreceptor.valiTrain.posAll.27feafill.rfJ5.200trees.changed"; 
my $curTask = "receptor"; 
my $testOutputPre = "/3testing/perlRF_Test_output/human.hprdlabel."  .  $curTask ;
my $testOutputSuffix = "27feafil.Rf"; 
   

my $feaFile = $localPath  .  $FeaFileDir  .  $outPPairfilePreFull  .  "."  .  $geneID  .  ".27fea.filled.rf"; 
my $model = $localPath  .  $testModelFile ; 
my $outPre = $localPath  .  $testOutputPre  .  $outPPairfilePreChange  .  "."  .  $geneID  .  "."  .  $testOutputSuffix ; 

$perlCommand = "perl "  .  $localPath  .   $testPerl;
$cmd = $perlCommand  .  " "  .  $feaFile  .  " "  .  $model  .  " "  .  $testModelPara  .  " "  .  $outPre  .  ".predict "  .  $outPre  .  ".out > $outPre.log" ; 
print "$cmd\n";
system($cmd) ;


my $resultTransferPerl = "/3testing/process_RFtestOut.pl "; 
my $transformperlCommand = "perl "  .  $localPath  .   $resultTransferPerl; 
my $transfermCmd = $transformperlCommand  .  " "  .  $outPre  .  ".out "  .  $outPre  .  ".scoreLabel > $outPre.scorelabl.log " ; 
print "\n$transfermCmd\n";
system($transfermCmd) ;



# -----------------------------------------------------------------------------------
# /** 3-add the geneInfo / feature / and disease information on the predicted PPI scoreLabel file. */

my $outcombinePre = "/4analyze/results/human.hprdlabel."  .  $curTask  .  ".RFall.ScorLablFeaGeneInfo";
my $addGeneInfoPerlcmd = "/4analyze/add_NamePartnerGeneInfo_4ListScoreLabelFeaf.pl "; 
my $scoreFile = $outPre  .  ".scoreLabel ";        

my $Outcombine = $localPath  .  $outcombinePre  .  $outPPairfilePreChange  .  "."  .  $geneID ;
my $addGeneInfoCmd = "perl "  .  $localPath  .   $addGeneInfoPerlcmd;    
my $geneInfoFile = $localPath  .   $ncbiGeneInfoFileName; 

my $feaFileFill = $localPath  .  $FeaFileDir  .  $outPPairfilePreFull  .  "."  .  $geneID  .  ".27fea.filled"; 

my $addCmd = $addGeneInfoCmd  .  " "  .  $ppiListFileLoc1  .  " "  .  $scoreFile  .  " "  .  $feaFileFill  .  " "   .  $geneInfoFile  .  " "  .  $Outcombine . "  > $Outcombine.log "; 
print "\n$addCmd\n";
system($addCmd) ;


my $diseaseInfoFile = "/ncbi_info/geneticDisorder-GDB/GDB-genetic.fromHTML.convertRaw"; 
my $adddiseaseInfoPerlcmd = "/4analyze/add_geneticDisease_4ListScoreLabelFeafGeInf.pl ";     
my $adddiseaseCommand = "perl "  .  $localPath  .   $adddiseaseInfoPerlcmd; 
my $diseaseInfo = $localPath  .   $diseaseInfoFile; 
my $adddiseaseCmd = $adddiseaseCommand  .  " "  .  $Outcombine  .  " "  .  $diseaseInfo  .  " "  .  $Outcombine  .  ".addDisease " ; 
print "\n$adddiseaseCmd\n";
system($adddiseaseCmd) ;
	
}
close(INPUT);
print "\n\n==> - Totally $count Genes in the interested list.  \n"; 
