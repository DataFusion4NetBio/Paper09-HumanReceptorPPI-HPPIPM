# Program to Extract Features of blastp BestHits Evalues
# 
#qyj@PISA /cygdrive/e/qyj-E/research/12-HumanDrosophilia/dataset/Feature-Set/4sequence
#$ perl get_blastHits.pl ./temp/fly.bind.pospair.tempsub fly.blastp.scores ../train_gold/fly/fly.ncbiprotein.list ./temp/fly.bind.pospair.tempsub.blastp
#- Size of NCBI_protein_gene_list:  50458.
#- Size of blastp evalue pairs (gene in the recent NCBI ):  97762.
#- Input list:  129 pairs ! - Blastp best hits :  1 pairs !
#
#qyj@PISA /cygdrive/e/qyj-E/research/12-HumanDrosophilia/dataset/Feature-Set/4sequence
#$ perl get_blastHits.pl ./temp/human.bind.pospair.tempsub human.blastp.scores ../train_gold/human/human.ncbiprotein.list ./temp/human.bind.pospair.tempsub.blastp
#- Size of NCBI_protein_gene_list:  161564.
#- Size of blastp evalue pairs (gene in the recent NCBI ):  804685.
#- Input list:  92 pairs ! - Blastp best hits :  8 pairs !
# 

use strict; 
die "Usage: command protein_pair_file blast_evalueList ncbi_geneprotein_list out_file_name\n" if scalar(@ARGV) < 4;

my ($int_file, $blastscore_file, $list_file, $out_file) = @ARGV;



#--------------------- read in the derived ncbi protein_gene_list file  -------------------------------

open(LIS, $list_file) || die(" Can not open file(\"$list_file\").\n"); 

my %gi2geneid = (); 
while (<LIS>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	# File format: ## proGI	proAcc	geneID	geneSym	
	my @line = split('\t', $_);
	if ( $line[0] ne "" )
	{
		$gi2geneid{"$line[0]"} = $line[2]; 
	}
}

close(LIS); 
print "- Size of NCBI_protein_gene_list:  " . keys( %gi2geneid ) . ".\n";



#--------------------- read in blast bestHits score file  -------------------------------

open(BLAST, $blastscore_file) || die(" Can not open file(\"$blastscore_file\").\n"); 

my %pairsScore = (); 
while (<BLAST>)	
{
	# format: # GI1   DBID1   GI2     DBID2   score   eValue
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	my @line = split('\t', $_);
	
	my $gi1 = $line[0]; 
	my $gi2 = $line[2]; 
	my $score = $line[4];
	my $evalue = $line[5];

	my ($geneID1, $geneID2 ); 
	$geneID1 =  $gi2geneid{"$gi1"}; 
	$geneID2 =  $gi2geneid{"$gi2"}; 

	if ((defined $geneID1) && (defined $geneID2) && ( $evalue > 0.0 ))
	{
		my $temp = $geneID1.":".$geneID2; 
		$pairsScore{ "$temp" } = $evalue ; 
	}
}
close(Y2H);
print "- Size of blastp evalue pairs (gene in the recent NCBI ):  ". keys( %pairsScore ) . ".\n";




#--------------------- Begin to process the int set and find if the pair in blast score set -------------------------------

open(INT, $int_file) || die(" Can not open file(\"$int_file\").\n"); 
open(OUT, "> $out_file") || die(" Can not open file(\"$out_file\").\n");

my $count =  0; 
my $count_hits = 0; 
my $evalue = 0; 	

while (<INT>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	# input format # proGI1	geneID1	proGI2	geneID2	flag
	my ($proGI1, $geneID1, $proGI2, $geneID2, $flag) = split('\t', $_);

	my $pair_l = $geneID1.":".$geneID2; 
	my $pair_r = $geneID2.":".$geneID1;

	$evalue = 0;
	
		if (defined $pairsScore{"$pair_l"}) 
		{
			$evalue = $pairsScore{"$pair_l"} ; 
			$evalue = - log($evalue); 
			$count_hits ++; 			
		}
		elsif (defined $pairsScore{"$pair_r"})
		{
			$evalue = $pairsScore{"$pair_r"} ; 
			$evalue = - log($evalue); 			
			$count_hits ++; 						
		}
		else
		{
			$evalue = 0 ; }			
	
	print OUT "$evalue,$flag\n";
	$count = $count + 1; 
}

print "- Input list:  $count pairs ! ";
print "- Blastp best hits :  $count_hits pairs ! ";
close(INT);					
close(OUT);