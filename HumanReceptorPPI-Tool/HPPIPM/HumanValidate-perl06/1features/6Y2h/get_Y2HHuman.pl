# Program to Extract Features of Y2H for protein pair list subset - Human Y2H 2005 Feature Set 
# 
# Use  Human Nature Y2H 2005 Feature Set: 
#	- PPIs .\human_natureY2H\NatureHumanY2H.PPIs.txt          	2754 pairs
#       - related genes: .\human_natureY2H\NatureHumanY2H.PPIs.txt    	8107 genes
# 	- Actually related size of genes: 				1549 genes
#
# Use  Human Cell Y2H 2005 Feature Set: 
#	- PPIs .\human_cellY2H\table_S3_Y2HPPIs.txt          		3269 pairs
#       - related genes: .\human_cellY2H\table_S2_geneList.txt    	1925 genes
# 
#
#$ perl get_Y2HHuman_nature.pl ./temp/human.bind.pospair.tempsub ./human_natureY2H/NatureHumanY2H.PPIs.txt nature ./temp/human.bind.pospair.tempsub.naturey2h
#- Size of Nature Human Y2H PPI:  2754.
#- Size of Nature Human Y2H related genes :  1549.
#- Input list:  92 pairs ! - Y2H hits :  1 pairs !
#
#$ perl get_Y2HHuman.pl ./temp/human.bind.pospair.tempsub ./human_cellY2H/table_S3_Y2HPPIs.txt cell ./temp/human.bind.pospair.tempsub.celly2h
#- Size of Cell Human Y2H PPI:  3194.
#- Size of Cell Human Y2H related genes :  1694.
#- Input list:  92 pairs ! - Y2H hits :  1 pairs !
#



use strict; 
die "Usage: command protein_pair_file natureHumany2h_ppis y2hsource[nature,cell] out_file_name\n" if scalar(@ARGV) < 4;

my ($int_file, $y2h_file, $y2hsource, $out_file) = @ARGV;


#--------------------- read in the nature human Y2H features -------------------------------

open(Y2H, $y2h_file) || die(" Can not open file(\"$y2h_file\").\n"); 

my %y2hpairs = (); 
my %y2hgene = (); 
while (<Y2H>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	my @line = split('\t', $_);

	my $geneID1 =   $line[0]; 
	my $geneID2 =   $line[2]; 
	if ( $y2hsource eq 'nature') {
		$geneID1 =   $line[0]; 
		$geneID2 =   $line[2]; 		
	}
	elsif ( $y2hsource eq 'cell') {
		$geneID1 =   $line[3]; 
		$geneID2 =   $line[6]; 		
	}
	else {
		die "Wrong y2hsource choice. Two choice: [nature,cell]\n" 
	}

	if ((defined $geneID1) && (defined $geneID2))
	{
		my $temp = $geneID1.":".$geneID2; 

		$y2hpairs{ "$temp" } = 1 ; 
		$y2hgene{ "$geneID2" } = 1; 
		$y2hgene{ "$geneID1" } = 1; 
	}
}

close(Y2H);

if ( $y2hsource eq 'nature') {
	print "- Size of Nature Human Y2H PPI:  " . keys( %y2hpairs ) . ".\n";
	print "- Size of Nature Human Y2H related genes :  " . keys( %y2hgene ) . ".\n";
}
elsif ( $y2hsource eq 'cell') {
	print "- Size of Cell Human Y2H PPI:  " . keys( %y2hpairs ) . ".\n";
	print "- Size of Cell Human Y2H related genes :  " . keys( %y2hgene ) . ".\n";
}



#--------------------- Begin to process the int set and find if the pair in Y2H set -------------------------------

open(INT, $int_file) || die(" Can not open file(\"$int_file\").\n"); 
open(OUT, "> $out_file") || die(" Can not open file(\"$out_file\").\n");

my $count =  0; 
my $count_hits = 0; 

while (<INT>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	# input format # proGI1	geneID1	proGI2	geneID2	flag
	my ($proGI1, $geneID1, $proGI2, $geneID2, $flag) = split('\t', $_);

	my $pair_l = $geneID1.":".$geneID2; 
	my $pair_r = $geneID2.":".$geneID1;

	my $count_y2h = 0; 	
	if ((! defined $y2hgene{"$geneID1"}) || (! defined $y2hgene{"$geneID2"}))
	{	
		$count_y2h = -100;	
	}
	else 
	{
		if (defined $y2hpairs{"$pair_l"}) 
		{
			$count_y2h = $y2hpairs{"$pair_l"} ; 
			$count_hits ++; 			
		}
		elsif (defined $y2hpairs{"$pair_r"})
		{
			$count_y2h = $y2hpairs{"$pair_r"} ; 
			$count_hits ++; 						
		}
		else
			{$count_y2h = 0 ; }			
	}
	
	print OUT "$count_y2h,$flag\n";
	$count = $count + 1; 
}

print "- Input list:  $count pairs ! ";
print "- Y2H hits :  $count_hits pairs ! ";
close(INT);					
close(OUT);