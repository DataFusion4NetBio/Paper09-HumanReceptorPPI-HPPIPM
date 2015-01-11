# 
# This program is extended from make_fullpair_4protein.pl
# perl make_fullpair_4protein.pl protein_list.txt pos_list output_pos output_other output_replicate_geneProtein
# 
# 
# We have a list of interested proteins , we want to make the PPI list of these proteins with the NCBI human gene list 
# 
# input interested protein list format:   # proGI	proAcc	geneID	geneSym
# input human_protein_list: human.ncbiprotein.list    # proGI	proAcc	geneID	geneSym
# input hprd-receptor PPI pos_list format:  # proGI1	geneID1	proGI2	geneID2	1
# 
# output Pair file format: 
# ==> proGI1	geneID1	proGI2	geneID2	1/0
# 
# example: 
# $ perl makeggpair_4ncbiplist_hpbdlable.pl ../requestGeneFile/requestGeneFile.2203 ../ncbi_info/human.ncbiprotein.list human.hprd.posPair temp


use strict; 
die "Usage: command interested_proteinlist human_proteinlist inpos_pair outPairFilePre \n" if scalar(@ARGV) < 4; 

my ($inProteinList, $protein_file, $pos_pairFile, $outPairFilePre ) = @ARGV; 


#--------------------- read in the interested protein name file -------------------------------

my %geneInterested = ();                  # lookup table to gene list we need 

open(INPUT, $inProteinList) || die(" Can not open file(\"$inProteinList\").\n"); 
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
}
close(INPUT);
my $count = scalar keys %geneInterested ; 
print "\n- $count Genes in the interested list.  \n"; 


#--------------------- read in the derived ncbi protein gene mapping_list file  -------------------------------

open(LIS, $protein_file) || die(" Can not open file(\"$protein_file\").\n"); 

my %geneid2proteingi = (); 
my %proteingi2geneid2 = (); 
while (<LIS>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	# File format: ## proGI	proAcc	geneID	geneSym	
	my @line = split('\t', $_);
	if (( $line[2] ne "" ) && ( $line[0] ne "" ))
	{
		$geneid2proteingi{"$line[2]"} = $line[0];   #actually here it should be an array to contains all the mapped proteins
		$proteingi2geneid2{"$line[0]"} = $line[2]; 
	}
}
close(LIS); 
print "- Size proteins in NCBI_protein_gene_mappinglist:  " . keys( %proteingi2geneid2 ) . ".\n";
print "- Size genes in NCBI_protein_gene_mappinglist:  " . keys( %geneid2proteingi ) . ".\n";

my $sum = $count * scalar keys( %geneid2proteingi ); 
print "\n==> we could generate GGI pairs $sum then.\n\n ";



#--------------------- read in the hprd pos protein pair list file -------------------------------

open(PR1, $pos_pairFile) || die(" Can not open file(\"$pos_pairFile\").\n");

my %posPairLookup = (); ; 
$count = 0; 
while (<PR1>)
{
	chomp; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	my @per_line = split('\t', $_); 
	#format # proGI1	geneID1	proGI2	geneID2	1
	my $geneID1 = $per_line[1]; 
	my $geneID2 = $per_line[3]; 

	my $temp = $geneID1.":".$geneID2; 
	$posPairLookup{"$temp"} = 1 ; 
	
	$count ++; 
}
close(PR1); 
print "# There are $count POS pairs originally .\n";  



#--------------------- generate PPIs list we need  -------------------------------

my ( $countp, $countn, $countr, $geneID1, $geneID2, $proGI1, $proGI2 ); 
foreach $geneID2 ( keys %geneInterested )
{
	my $curFile = $outPairFilePre.".".$geneID2 ; 
	
	open(OUT, "> $curFile") || die(" Can not open file(\"$curFile\").\n"); 
	print OUT "# proGI1\tgeneID1\tproGI2\tgeneID2\t1/0\n";

	$countp = 0; 
	$countn = 0; 
	
	$proGI2 = $geneInterested{"$geneID2"}; 

	foreach $geneID1 (sort keys %geneid2proteingi)
	{
		$proGI1 = $geneid2proteingi{"$geneID1"}; 
		if ( $geneID1 ne $geneID2 )
		{
			my $temp1 = $geneID1.":".$geneID2; 		
			my $temp2 = $geneID2.":".$geneID1; 		
			if (( defined $posPairLookup{"$temp1"}) || ( defined $posPairLookup{"$temp2"}))
			{
				print OUT "$proGI1\t$geneID1\t$proGI2\t$geneID2\t1\n";
				$countp = $countp +1; 
			}
			else 
			{
				print OUT "$proGI1\t$geneID1\t$proGI2\t$geneID2\t0\n";
				$countn = $countn +1; 
			}
		}
	}
	close(OUT);		
		
	print "#$curFile has: \n  -$countp POS pairs.\n";  
	print "#$curFile has: \n  -$countn RAND pairs.\n";  

	my $temptemp = $countp + $countn; 
	print "==>  There are $temptemp pairs outputed totally ! \n\n"; 
}