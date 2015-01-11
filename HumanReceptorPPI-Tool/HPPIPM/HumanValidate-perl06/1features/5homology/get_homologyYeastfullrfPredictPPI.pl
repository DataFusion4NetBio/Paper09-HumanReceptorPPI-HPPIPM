# Program to Extract Features of Homology PPI  for protein pair list subset
# 
# Two data used: 
# - 1. SGD PSI-BLAST sequence comparison result  ( also we need to transfer the protACC used here into the GeneID )
# - 2. other species' PPI pairs and scores from the prediction of RF method 
#
# -----------------------------------------------------------------------------------------------
#  ==> in make the feature: 
#"	The input pair list file format: "proGI1 geneID1 proGI2 geneID2	Flag" ( 0 rand or 1 postive)
#"	The out put file format:  real valued feature, the last one is the class flag
# -----------------------------------------------------------------------------------------------
#  Currently we are using the following 1 species to derive the homology PPI for the Human/fly protein pairs. 
#"	S.C.(Yeast)
# -----------------------------------------------------------------------------------------------
#
# The final score = PPI_score_RF_yeast * (minus natural log of [first protein homology E-value]  +  minus natural log [second protein homology E-value]) / constant
#	we use constant = 1000
# -----------------------------------------------------------------------------------------------
# 
# $ perl get_homologyYeastfullsvmPredictPPI.pl ./temp/fly.bind.pospair.tempsub fly.ncbiprotein.list ./psi_blast/psi_blast.tab.fly2yeast ./full_svm_predict/full_pair_list.dips.svm.0.7.subpairs ./temp/fly.bind.pospair.tempsub.yeasthomologydipssvm
# - Size of NCBI_protein_gene_list:  50384.
# - Size of genes having homology in Yeast: 745.
# - Yeast species ./full_svm_predict/full_pair_list.dips.svm.0.7.subpairs PPI pairs: 179365;
# - Input protein pair file: 129 pairs ! ;
# - 0 has homology PPI in ./full_svm_predict/full_pair_list.dips.svm.0.7.subpairs;
# 
# 
# $ perl get_homologyYeastfullsvmPredictPPI.pl ./temp/human.bind.pospair.tempsub human.ncbiprotein.list ./psi_blast/psi_blast.tab.human2yeast ./full_svm_predict/full_pair_list.dips.svm.0.7.subpairs ./temp/human.bind.pospair.tempsub.YeastsvmppiHomology
# - Size of NCBI_protein_gene_list:  161561.
# - Size of genes having homology in Yeast: 4722.
# - Yeast species ./full_svm_predict/full_pair_list.dips.svm.0.7.subpairs PPI pairs: 179365;
# - Input protein pair file: 92 pairs ! ;
# - 16 has homology PPI in ./full_svm_predict/full_pair_list.dips.svm.0.7.subpairs;
# 

#$ perl  get_homologyYeastfullrfPredictPPI.pl ./temp/human.bind.pospair.tempsub human.ncbiprotein.list ./psi_blast/psi_blast.tab.human2yeast ./full_rf_predict/full_pair_list.combineNoHm.filled.mips.rf0.2.subpairs ./temp/human.bind.pospair.tempsub.YeastrfHmppi
#- Size of NCBI_protein_gene_list:  161561.
#- Size of genes having homology in Yeast: 4722.
#- Yeast species ./full_rf_predict/full_pair_list.combineNoHm.filled.mips.rf0.2.subpairs PPI pairs: 155850;
#- Input protein pair file: 92 pairs ! ;
#- 19 has homology PPI in ./full_rf_predict/full_pair_list.combineNoHm.filled.mips.rf0.2.subpairs;



use strict; 
die "Usage: command protein_pair_file ncbi_genelist PsiBlastFile YeastPPI out_file_name\n" if scalar(@ARGV) < 5;

print "\npara1: $ARGV[1]\n"; 
print "para2: $ARGV[2]\n"; 
print "para3: $ARGV[3]\n\n"; 


my ($int_file, $ncbi_listfile, $homology_file, $hPPI_file, $out_file) = @ARGV;


#--------------------- read in the derived ncbi protein_gene_list file  -------------------------------

open(LIS, $ncbi_listfile) || die(" Can not open file(\"$ncbi_listfile\").\n"); 

my %proacc2geneid = (); 
while (<LIS>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	# File format: ## proGI	proAcc	geneID	geneSym	
	my @line = split('\t', $_);
	if ( $line[1] ne "" )
	{
		$proacc2geneid{"$line[1]"} = $line[2]; 
	}
}

close(LIS); 
print "- Size of NCBI_protein_gene_list:  " . keys( %proacc2geneid ) . ".\n";



#--------------------- read in the homology PSI-BLAST SGD file  -------------------------------

my %homology = (); 

open(HGY, $homology_file) || die(" Can not open file(\"$homology_file\").\n"); 

while (<HGY>)	
{
	chomp $_; 
	next if /^\s*$/; 			#ignore blank lines
	
	my @line = split('\t', $_);
	
	my $orf = $line[0]; 
	# We use the minus natural log_e of the E-value as the feature
	my $eValue = - log($line[6]); 
	my $proAcc = $line[7];
	my $geneID = $proacc2geneid{"$proAcc"}; 
	
	if ( defined $geneID )
	{
		if (! defined $homology{ "$geneID" } )
		{
			my @cur = (); 
			$cur[0] = $orf.":".$eValue ; 
			$homology{ "$geneID" } = \@cur; 
		}	
		else {
			push( @ {$homology{ "$geneID" }}, $orf.":".$eValue  ); 	
		}
	}
}
close(HGY);
print "- Size of genes having homology in Yeast: " . keys( %homology ) . ".\n";



#--------------------- read in the DIP Yeast PPI file  -------------------------------

my %speciesppr = (); 

open(PPI, $hPPI_file) || die(" Can not open file(\"$hPPI_file\").\n"); 

while (<PPI>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	
	my @orf = split('\t', $_);
	
	my $orf1 = $orf[0]; 
	my $orf2 = $orf[1]; 
	my $scorePPI = $orf[2]; 

	my $pair = $orf1.":".$orf2; 
	$speciesppr{ "$pair" } = $scorePPI ; 
}

close(PPI);

my $proteinSize = scalar keys (%homology); 
my $pairsize = scalar keys (%speciesppr);
print "- Yeast species $hPPI_file PPI pairs: $pairsize; \n"; 


#--------------------- Begin to process the input pair list and find if their homolgy pair in PPIs -------------------------------

open(INT, $int_file) || die(" Can not open file(\"$int_file\").\n"); 
open(OUT, "> $out_file") || die(" Can not open file(\"$out_file\").\n");

# this is specific for RF score | also SVM score
my $evalueDivide = 1000; 

my $count =  0; 
my $homCatchNum = 0; 

while (<INT>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	
	# input format # proGI1	geneID1	proGI2	geneID2	flag
	my ($proGI1, $geneID1, $proGI2, $geneID2, $flag) = split('\t', $_);

	my $score = 0; 
	if ( (defined $homology{"$geneID1"} ) &&  (defined $homology{"$geneID2"} ))
	{
		my @proteins1 = @{$homology{"$geneID1"}}; 
		my @proteins2 = @{$homology{"$geneID2"}}; 	
		
		my ($curpro1, $curpro2); 
	
		$score = 0; 
		my (@temp, $orf1, $evalue1, $orf2, $evalue2, $pair_l, $pair_r); 
		foreach $curpro1 (@proteins1) 
		{
			foreach $curpro2 (@proteins2) 
			{
				@temp = split(/:/, $curpro1); 
				$orf1 = $temp[0]; 
				$evalue1 = $temp[1]; 
				@temp = split(/:/, $curpro2); 
				$orf2 = $temp[0]; 
				$evalue2 = $temp[1]; 
				
				$pair_l = $orf1.":".$orf2; 
				$pair_r = $orf2.":".$orf1; 
			
				if (defined $speciesppr{"$pair_l"} )
				{ 
					$score = $score + $speciesppr{"$pair_l"}* ($evalue1 + $evalue2)/$evalueDivide;  
				}
				elsif (defined $speciesppr{"$pair_r"} )
				{
					$score = $score + $speciesppr{"$pair_l"}* ($evalue1 + $evalue2)/$evalueDivide;  
				}
				else 
				{ 
					$score = $score + 0;  
				}
			}
		}
		if ( $score > 0)
		{
			$homCatchNum = $homCatchNum + 1; 		
		}
	}
	print OUT "$score,$flag\n"; 
	$count = $count + 1; 
}

print "\n- Input protein pair file: $count pairs ! ; \n- $homCatchNum has homology PPI in $hPPI_file; ";

close(INT);					
close(OUT);