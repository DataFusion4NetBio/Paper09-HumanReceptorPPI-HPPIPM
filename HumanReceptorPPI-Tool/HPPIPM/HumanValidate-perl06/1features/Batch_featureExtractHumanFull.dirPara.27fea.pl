# This program is for human-receptor/human PPI feature extraction wrapper 
#
# perl command inputPairlist

use strict; 
die "Usage: command curdir inputPairFile \n" if scalar(@ARGV) < 2;
my ( $curdir , $inputPair ) = @ARGV;


print "\n human PPI Features Extracting ........ \n"; 


print "\n----------------------  1 gene-expression   -----------------------\n"; 

my $cmdPre = "perl $curdir/3expression/batch_geneexp_human.pl  "; 
my $cmdPro = "$curdir/3expression/human/human.ncbiprotein.list 0.6  "; 
my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".16coexp  $curdir/3expression" ; 
print "$cmd\n"; 
system($cmd); 



print "\n -------------------   2 gene-ontology  -------------------- \n";

print "\n ==> Function ! \n"; 
my $cmdPre = "perl $curdir/2GO/get_go_genericdetail.pl  "; 
my $cmdPro = " $curdir/2GO/gene_association.human.slim F $curdir/2GO/human.ncbiprotein.list $curdir/2GO/goslim_generic.func.go "; 

my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".gofunc " ;
print "$cmd\n"; 
system($cmd); 


print "\n ==> Function summarize ! \n"; 
my $cmdPre = "perl $curdir/2GO/summarize_go_genericdetail.pl  "; 
my $cmd = $cmdPre." ".$inputPair.".gofunc  ".$inputPair.".gofuncsum " ;
print "$cmd\n"; 
system($cmd); 


print "\n ==> Component ! \n"; 
my $cmdPre = "perl $curdir/2GO/get_go_genericdetail.pl  "; 
my $cmdPro = " $curdir/2GO/gene_association.human.slim C $curdir/2GO/human.ncbiprotein.list $curdir/2GO/goslim_generic.comp.go "; 

my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".gocomp " ;
print "$cmd\n"; 
system($cmd); 


print "\n ==> Component summarize ! \n"; 
my $cmdPre = "perl $curdir/2GO/summarize_go_genericdetail.pl  "; 
my $cmd = $cmdPre." ".$inputPair.".gocomp  ".$inputPair.".gocompsum " ;
print "$cmd\n"; 
system($cmd); 


print "\n ==> Process ! \n"; 
my $cmdPre = "perl $curdir/2GO/get_go_genericdetail.pl  "; 
my $cmdPro = " $curdir/2GO/gene_association.human.slim P $curdir/2GO/human.ncbiprotein.list $curdir/2GO/goslim_generic.proc.go "; 

my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".goproc " ;
print "$cmd\n"; 
system($cmd); 


print "\n ==> Process summarize ! \n"; 
my $cmdPre = "perl $curdir/2GO/summarize_go_genericdetail.pl  "; 
my $cmd = $cmdPre." ".$inputPair.".goproc  ".$inputPair.".goprocsum " ;
print "$cmd\n"; 
system($cmd); 



print "\n---------------------------   3 sequence-similarity     --------------------------\n"; 

#qyj@PISA  /cygdrive/e/qyj-E/research/12-HumanDrosophilia/dataset/Feature-Set/4sequence
#$ perl get_blastHits.pl ./temp/human.bind.pospair.tempsub human.blastp.scores ../train_gold/human/human.ncbiprotein.list ./temp/human.bind.pospair.tempsub.blastp
#- Size of NCBI_protein_gene_list:  50458.
#- Size of blastp evalue pairs (gene in the recent NCBI ):  97762.
#- Input list:  129 pairs ! - Blastp best hits :  1 pairs !

my $cmdPre = "perl $curdir/4sequence/get_blastHits.pl  "; 
my $cmdPro = " $curdir/4sequence/human.blastp.scores  $curdir/4sequence/human.ncbiprotein.list "; 

my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".blastp " ;
print "$cmd\n"; 
system($cmd); 




print "\n  -------------------   4 homology-PPI ------------------------------\n"; 

# $ perl ../5homology/get_homologyPPI.pl ./human/human.bind.pospair ./human/human.ncbiprotein.list ../5homology/psi_blast/psi_blast.tab.human2yeast ../5homology/dip_ppis/dip.yeast20050403.lst human.bind.pospair.yeastHMppi
# $ perl  get_homologyPPI.pl ./temp/human.bind.pospair.tempsub  ../train_gold/human/human.ncbiprotein.list  ./psi_blast/psi_blast.tab.human2yeast ./dip_ppis/dip.yeast20050403.lst ./temp/human.bind.pospair.tempsub.yeasthomology

my $cmdPre = "perl   $curdir/5homology/get_homologyPPI.pl  "; 

my $cmdPro = " $curdir/5homology/human.ncbiprotein.list  $curdir/5homology/psi_blast/psi_blast.tab.human2yeast $curdir/5homology/dip_ppis/dip.yeast20050403.lst  "; 
my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".yeastHMppi" ; 
print "\n$cmd\n"; 
system($cmd); 



# The Yeast Prediction based PPI homology feature  

# $ perl get_homologyYeastfullsvmPredictPPI.pl ./temp/human.bind.pospair.tempsub human.ncbiprotein.list ./psi_blast/psi_blast.tab.human2yeast ./full_svm_predict/full_pair_list.dips.svm.0.7.subpairs ./temp/human.bind.pospair.tempsub.YeastsvmppiHomology

my $cmdPre = "perl   $curdir/5homology/get_homologyYeastfullsvmPredictPPI.pl  "; 
my $cmdPro = " $curdir/5homology/human.ncbiprotein.list  $curdir/5homology/psi_blast/psi_blast.tab.human2yeast $curdir/5homology/full_svm_predict/full_pair_list.NoHm.filled.dips.svm.0.7.subpairs  "; 
my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".yeastHMppi.dips.svm" ; 
print "\n$cmd\n"; 
system($cmd); 


my $cmdPre = "perl   $curdir/5homology/get_homologyYeastfullsvmPredictPPI.pl  "; 
my $cmdPro = " $curdir/5homology/human.ncbiprotein.list  $curdir/5homology/psi_blast/psi_blast.tab.human2yeast $curdir/5homology/full_svm_predict/full_pair_list.NoHm.filled.mips.svm.m0.2process.subpairs  "; 
my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".yeastHMppi.mips.svm" ; 
print "\n$cmd\n"; 
system($cmd); 


my $cmdPre = "perl   $curdir/5homology/get_homologyYeastfullrfPredictPPI.pl  "; 
my $cmdPro = " $curdir/5homology/human.ncbiprotein.list  $curdir/5homology/psi_blast/psi_blast.tab.human2yeast $curdir/5homology/full_rf_predict/full_pair_list.spokeNoHm.filled.dips.rf0.32.subpairs   "; 
my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".yeastHMppi.dips.rf" ; 
print "\n$cmd\n"; 
system($cmd); 


my $cmdPre = "perl   $curdir/5homology/get_homologyYeastfullrfPredictPPI.pl  "; 
my $cmdPro = " $curdir/5homology/human.ncbiprotein.list  $curdir/5homology/psi_blast/psi_blast.tab.human2yeast $curdir/5homology/full_rf_predict/full_pair_list.combineNoHm.filled.mips.rf0.2.subpairs  "; 
my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".yeastHMppi.mips.rf" ; 
print "\n$cmd\n"; 
system($cmd); 



print "\n # -------------------  5 domain-interaction  ------------------------------ \n"; 
# $ perl  get_DDpairlogP.pl ../train_gold/human/lists/curUsedLists/human.hprdpairwiseNoself.posPair.receptfilter human.hprdNoself.posNoRecp.rand60w.cut0.001000.ddpcutpvalue hprdxml.gene-domain.geneID ./temp/temp1

my $cmdPre = "perl   $curdir/8domain/get_DDpairlogP.pl  "; 
my $cmdPro = " $curdir/8domain/human.hprdNoself.posNoRecp.rand60w.cut0.000001.ddpcutpvalue  $curdir/8domain/hprdxml.gene-domain.geneID  "; 
my $cmd = $cmdPre." ".$inputPair." ".$cmdPro."   ".$inputPair.".ddpvalue" ; 
print "\n$cmd\n"; 
system($cmd); 




print "\n # -------------------   6 yeast - 2 - hybrid human  ------------------------------ \n"; 

my $cmdPre = "perl   $curdir/6Y2h/get_Y2HHuman.pl  "; 
my $cmdPro = " $curdir/6Y2h/human_natureY2H/NatureHumanY2H.PPIs.txt  "; 
my $cmd = $cmdPre." ".$inputPair." ".$cmdPro."  nature  ".$inputPair.".naturey2h" ; 
print "\n$cmd\n"; 
system($cmd); 


my $cmdPre = "perl   $curdir/6Y2h/get_Y2HHuman.pl  "; 
my $cmdPro = " $curdir/6Y2h/human_cellY2H/table_S3_Y2HPPIs.txt  "; 
my $cmd = $cmdPre." ".$inputPair." ".$cmdPro."  cell  ".$inputPair.".celly2h" ; 
print "\n$cmd\n"; 
system($cmd); 




print "\n # -------------------   7 tissue feature human  ------------------------------ \n"; 
# $ perl  get_GeneTissue.pl ./temp/human.bind.pospair.tempsub human.ncbiprotein.list Hs.data.GeneTissueMap ./temp/human.bind.pospair.tempsub.cotissue

my $cmdPre = "perl   $curdir/7tissue/get_GeneTissue.pl  "; 
my $cmdPro = " $curdir/7tissue/human.ncbiprotein.list     $curdir/7tissue/Hs.data.GeneTissueMap  "; 
my $cmd = $cmdPre." ".$inputPair."  ".$cmdPro."   ".$inputPair.".tissue" ; 
print "\n$cmd\n"; 
system($cmd); 




print "\n------------------------   combine features into one set  ----------------------\n"; 

my $cmdPre = "perl $curdir/train_gold/CombineFeaturesHuman.27fea.pl  "; 

my $cmdPro = "   "; 
my $cmd = $cmdPre." ".$inputPair." ".$cmdPro." ".$inputPair.".27fea" ; 
print "\n$cmd\n"; 
system($cmd); 


