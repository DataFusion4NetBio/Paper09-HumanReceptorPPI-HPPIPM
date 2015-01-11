#
# This program is a wrapper to Batch_generateTrain feature file (RF filled version ) based on the inputTaskGeneListFile
#
# suppose inputTaskGeneListFile used the absolute path file name 
 


use strict;
die "Usage: command inputTaskGeneListFile curDir  ncbigenelist outTrainFeaRFfill \n" if scalar(@ARGV) < 3;
my ( $inputTaskGeneListFile, $curDir, $ncbigenelist, $outTrainFeaRFfill ) = @ARGV;


print "-------- Build the new task based train feature RF-format file  ---------------\n"; 


print "\n1. --------  get task related pos feature \n"; 
my $extractPosCmd = "perl $curDir/extractPart_ppifea_byInputGeneNameList.pl "; 
# Usage: command HumanPPIFile HumanPPIfeaFile ncbigenelist inputGeneNameList outFilteredPairList outFilteredPairFea 

my $humanHprdPosPPI = $curDir."/hprdpos-rand42w-ppi-fea/human.hprdpairwiseNoself.posPair "; 
my $humanHprdPosPPIFea = $curDir."/hprdpos-rand42w-ppi-fea/human.hprdpairwiseNoself.posPair.27fea ";
my $humanHprdPosPPItask = $curDir."/trainingTaskRF/human.hprdpairwiseNoself.posPair.task "; 
my $humanHprdPosPPIFeatask = $curDir."/trainingTaskRF/human.hprdpairwiseNoself.posPair.27fea.task ";

my $cmd = $extractPosCmd." ".$humanHprdPosPPI." ".$humanHprdPosPPIFea." ".$ncbigenelist." ".$inputTaskGeneListFile." ".$humanHprdPosPPItask." ".$humanHprdPosPPIFeatask; 
print "$cmd\n"; 
system($cmd); 



print "\n2. --------  get task related rand feature \n"; 

my $humanHprdRandPPI = $curDir."/hprdpos-rand42w-ppi-fea/human.nohprdbind.randPair.300w.first42w "; 
my $humanHprdRandPPIFea = $curDir."/hprdpos-rand42w-ppi-fea/human.nohprdbind.randPair.300w.first42w.27fea ";
my $humanHprdRandPPItask = $curDir."/trainingTaskRF/human.nohprdbind.randPair.300w.first42w.task "; 
my $humanHprdRandPPIFeatask = $curDir."/trainingTaskRF/human.nohprdbind.randPair.300w.first42w.27fea.task ";

$cmd = $extractPosCmd." ".$humanHprdRandPPI." ".$humanHprdRandPPIFea." ".$ncbigenelist." ".$inputTaskGeneListFile." ".$humanHprdRandPPItask." ".$humanHprdRandPPIFeatask; 
print "$cmd\n"; 
system($cmd); 



print "\n3. --------  combine to get the train feature file in raw format \n"; 

my $catperl = "perl $curDir/catTwoFiles.pl  "; 
my $curCombineFea = $curDir."/trainingTaskRF/human.hprd.posrand.task.27fea";
$cmd = $catperl." ".$humanHprdPosPPIFeatask." ".$humanHprdRandPPIFeatask." ".$curCombineFea ; 
print "$cmd\n"; 
system($cmd); 



print "\n4. --------  fill missing the feature  \n"; 

my $fillperl = "perl $curDir/filledMissingValueHuman.27fea.pl  "; 
$cmd = $fillperl." ".$curCombineFea." ".$curCombineFea.".fill "; 
print "$cmd\n"; 
system($cmd); 


print "\n5. --------  convert the feature to RF format \n"; 

my $convertperl = "perl $curDir/convert_file_forRF_12PPI.human27fea.pl  "; 
$cmd = $convertperl." ".$curCombineFea.".fill ".$outTrainFeaRFfill."  420000" ; 
print "$cmd\n"; 
system($cmd); 


