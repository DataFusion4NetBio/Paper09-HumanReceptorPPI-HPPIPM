# Program to get gene expression co-expression (abundance) for protein pair list 
# 
# Based on the gene expression data given from NCBI GEO dataset
#
# This is a version particular for making a summary feature out (only 1 feature out)
# For a specific GDS file of the Human specie
# 
# Note: 
# - in the protein pair list file, 
# - for each protein pair, we have a flag representing the class label: "1" means postive pair, "0" means random pairs
#"	The out put file format: 1 gene expression feature and the last one is the class flag
#
#
#qyj@PISA /cygdrive/e/qyj-E/research/12-HumanDrosophilia/dataset/Feature-Set/3expression
#$ perl  get_gene_expression_human.pl ./temp/human.bind.pospair.tempsub ./human/human.ncbiprotein.list ./human/data/GDS/GDS330.soft ./human/data/GPL/GPL91.annot.txt 0.5 ./temp/human.bind.pospair.tempsub.geneexp
#- Size of human geneID_geneSymbol_list: 24380.
#- Size of gene Symbols mentioned in GPL file:11582.
#- Size of gennSymbol having gene expression:8685.
#- This gene expression data's sample size: 120
#==> 92 pairs;
#31 of them has co-expression feature !
#
#qyj@PISA /cygdrive/e/qyj-E/research/12-HumanDrosophilia/dataset/Feature-Set/3expression
#$ perl  get_gene_expression_human.pl ./temp/human.bind.pospair.tempsub ./human/human.ncbiprotein.list ./human/data/GDS/GDS365.soft ./human/data/GPL/GPL271.annot.txt 0.5 ./temp/human.bind.pospair.tempsub.geneexp
#- Size of human geneID_geneSymbol_list: 24380.
#- Size of gene Symbols mentioned in GPL file:19460.
#- Size of gennSymbol having gene expression:8710.
#- This gene expression data's sample size: 66
#==> 92 pairs;
#23 of them has co-expression feature !
#
#qyj@PISA /cygdrive/e/qyj-E/research/12-HumanDrosophilia/dataset/Feature-Set/3expression
#$ perl  get_gene_expression_human.pl ./temp/human.bind.pospair.tempsub ./human/human.ncbiprotein.list ./human/data/GDS/GDS531.soft ./human/data/GPL/GPL91.annot.txt 0.5 ./temp/human.bind.pospair.tempsub.geneexp
#- Size of human geneID_geneSymbol_list: 24380.
#- Size of gene Symbols mentioned in GPL file:11582.
#- Size of gennSymbol having gene expression:8685.
#- This gene expression data's sample size: 173
#==> 92 pairs;
#31 of them has co-expression feature !
#
#qyj@PISA /cygdrive/e/qyj-E/research/12-HumanDrosophilia/dataset/Feature-Set/3expression
#$ perl  get_gene_expression_human.pl ./temp/human.bind.pospair.tempsub ./human/human.ncbiprotein.list ./human/data/GDS/GDS534.soft ./human/data/GPL/GPL96.annot.txt 0.5 ./temp/human.bind.pospair.tempsub.geneexp
#- Size of human geneID_geneSymbol_list: 24380.
#- Size of gene Symbols mentioned in GPL file:20210.
#- Size of gennSymbol having gene expression:12720.
#- This gene expression data's sample size: 75
#==> 92 pairs;
#84 of them has co-expression feature !
#


#use strict; 

die "Usage: command input_pair_list human_ncbifbid_list gene_expression_file GEO_GPL_file percent_miss out_file_name\n" if scalar(@ARGV) < 6;

my ($pr_pair_file, $ncib_list_file, $gene_expression_file, $geo_gpl_file, $percent_miss, $out_file_name) = @ARGV;


#--------------------- read in the ncbi list file -------------------------------

open(LIS, $ncib_list_file) || die(" Can not open file(\"$ncib_list_file\").\n"); 

my %geneid2geneSy = (); 
while (<LIS>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	# File format: ## proGI	proAcc	geneID	geneSym	FBID
	my @line = split('\t', $_);
	my $temp = uc($line[3]); 
	$geneid2geneSy{"$line[2]"} =  $temp ; 
}
close(LIS); 
print "- Size of human geneID_geneSymbol_list: " . keys( %geneid2geneSy ) . ".\n";



#--------------------- read in the selected Human GEO GPL  file -------------------------------

open(GPL, $geo_gpl_file) || die(" Can not open file(\"$geo_gpl_file\").\n"); 

my %gplid2geneSym = (); 
my ( $idref, $geneSym); 

while (<GPL>)	
{
	chomp $_;
	next if /^#/;			#ignore comments
	next if /^!/;			#ignore comments
	next if /^\^/;			#ignore comments
	next if /^\s+$/; 		#ignore blank lines
	next if /^$/; 			#ignore blank lines
	next if /^ID\t/; 			#ignore comments
	
	# format: 
	# ID	Gene	Unigene	UniGene title	Nucleotide	Protein	GI	GenBank Accession	Gene symbol	Platform_CLONEID	Platform_ORF	Platform_SPOTID	Platform_SPACC	Platform_PTACC
	my @cur_per_line = (); 
	@cur_per_line = split('\t', $_);
	
	$idref = $cur_per_line[0]; 
	$geneSym = $cur_per_line[8]; 
		
	if ( $geneSym ne '' )
	{
		$gplid2geneSym{"$idref"} = uc($geneSym) ; 
	}
}
close(GPL);

print "- Size of gene Symbols mentioned in GPL file:" . keys( %gplid2geneSym ) . ".\n";



#--------------------- read in the selected Human GDS gene expression file -------------------------------

open(GEN, $gene_expression_file) || die(" Can not open file(\"$gene_expression_file\").\n"); 
my ( %gene_exp, $indexnum ); 
%gene_exp = (); 

my ($gdsID ) ; 
my $sampleSize ; 

while (<GEN>)	
{
	chomp $_;
	next if /^#/;			#ignore comments
	next if /^!/;			#ignore comments
	next if /^\^/;			#ignore comments
	next if /^\s+$/; 		#ignore blank lines
	next if /^$/; 			#ignore blank lines
	next if /^ID_REF/; 			#ignore comments
	
	my @cur_per_line = (); 
	@cur_per_line = split('\t', $_);

	$gdsID = $cur_per_line[0]; 
	my $geneSym = $gplid2geneSym{"$gdsID"}; 	
		
	if (defined $geneSym )
	{
		shift(@cur_per_line); 
		shift(@cur_per_line); 
		$gene_exp{"$geneSym"} = \@cur_per_line; 
		$sampleSize = $#cur_per_line + 1; 
	}
}
close(GEN);

print "- Size of gennSymbol having gene expression:" . keys( %gene_exp ) . ".\n";
print "- This gene expression data's sample size: $sampleSize\n"; 



#--------------------- Begin to generate 1 summary gene expression feature  -------------------------------

open(INT, $pr_pair_file) || die(" Can not open file(\"$pr_pair_file\").\n"); 
open(OUT, "> $out_file_name") || die(" Can not open file(\"$out_file_name\").\n");

my $count = 0; 
my $countNomissing = 0; 
my $feaCount = 0; 


my ( $geneid1, $orfs1, $geneid2, $orfs2, $orf1, $orf2, @exp1, @exp2, $flag ); 
my ( $geneSym1, $geneSym2 ); 
while (<INT>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	# input format: 
	# proGI1	geneID1	proGI2	geneID2	flag
	( $orfs1, $geneid1, $orfs2, $geneid2, $flag) = split('\t', $_);

 	$geneSym1 =  $geneid2geneSy{"$geneid1"}; 
 	$geneSym2 =  $geneid2geneSy{"$geneid2"}; 
 	
    if (( defined $geneSym1) && (  defined $geneSym2 ))
    {
	if (( ! (defined $gene_exp{"$geneSym1"})  )||( ! ( defined $gene_exp{"$geneSym2"})) )
	{
		print OUT "-100,$flag\n"; 
	}
	else {
		$exp1 = $gene_exp{"$geneSym1"};
		$exp2 = $gene_exp{"$geneSym2"};

		my $temp =  &pearsoncc($exp1, $exp2, $percent_miss); 
		print OUT "$temp,$flag\n";  
		$countNomissing ++; 
	}
	
    }	
    else {
    		print OUT "-100,$flag\n"; 
    	}

	$count = $count + 1;
	
	if ( $count % 5000 == 0)
		{print "$count ";} 
}
print "==> $count pairs; \n$countNomissing of them has co-expression feature !\n"; 


close(INT);					
close(OUT);





# ==================================================================================
# here we define the subroutine to get pearson correlation coefficients


sub pearsoncc 
{
   my(@a) = @{$_[0]};
   my(@b) = @{$_[1]};
   my($percent) = $_[2];

   my $i = 0;        
   my $revalue = 0; 
   
   my @af = (); 
   my @bf = (); 
   
   for($i = 0 ; $i <= $#a ; $i ++)
   {
	if (( $a[$i] ne 'null' ) && ( $b[$i] ne 'null' ))
	{
		push(@af, $a[$i]); 
		push(@bf, $b[$i]);
	}	
   }
   
   my $n = $#af + 1; 
   if (( $#af < $#a * ( 1- $percent )) || ($n <= 1))
   { 
   	$revalue =  -100;
   }    
   else 
   {
	   	my $sum_xy = 0; 
   		my $sum_x = 0; 
		my $sum_x2 = 0;    	
   		my $sum_y = 0; 
   		my $sum_y2 = 0; 
   	
   		for($i = 0 ; $i <= $#af ; $i ++)
   		{
   			$sum_xy = $sum_xy + $af[$i] * $bf[$i] ; 
   			$sum_x = $sum_x + $af[$i] ; 
			$sum_x2 = $sum_x2 + $af[$i] * $af[$i] ;
   			$sum_y = $sum_y + $bf[$i] ;
   			$sum_y2 = $sum_y2 + $bf[$i] * $bf[$i];  
   		}
		my $up = $sum_xy - $sum_x * $sum_y / $n ; 
        	my $low = ($sum_x2 - ($sum_x * $sum_x)/$n)*( $sum_y2 - ($sum_y * $sum_y)/$n);   	
   		$revalue = $up/sqrt($low + 0.00001); 
   } 
   return($revalue); 
}
