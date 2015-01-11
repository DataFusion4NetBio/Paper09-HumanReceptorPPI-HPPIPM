#
# For the PPI list file + RFScoreLabel file + feature file + relatedGeneInfo
# we would also find their partner's related GDB_geneticDisease_info and added in 
# 

use strict;
die "Usage: command GeneInfoPPIScoreLabelfeaFile gdb_diseaseGeneList outGeneInfoPPIScoreLabelfea_diseaseFile \n" if scalar(@ARGV) < 3;
my ( $GeneInfoPPIScoreLabelfeaFile, $gdb_diseaseGeneList, $outGeneInfoPPIScoreLabelfea_diseaseFile ) = @ARGV;



#--------------------- read in the gdb_diseaseGeneList file  -------------------------------

my @data_array = (); 
my ( $count, $curLine, $curGene, $curGDB, $curdisease ); 

my %geneinfo = (); 
$count = 0; 

open(IN, $gdb_diseaseGeneList) || die(" Can not open file(\"$gdb_diseaseGeneList\").\n"); 
while(<IN>)
{
	chomp $_;	
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 		
	$curLine = $_; 

	# format: GeneID	GDBID	 (zero|more-Disease)
	@data_array = split('\t', $_) ;
	$curGene = $data_array[0]; 
	$curGDB = $data_array[1]; 
	shift(@data_array);
	shift(@data_array);
	if (defined @data_array)
	{
		$curdisease = join " ", @data_array; 
	}
	else {
		$curdisease = ""; 
	}	
	$geneinfo{"$curGene"} = "$curGDB\t$curdisease"; 
}
print "\n- gdb_diseaseGeneList: $gdb_diseaseGeneList : $count lines\n"; 
print "- geneinfo has ". scalar keys( %geneinfo) ." entries.\n"; 
close(IN);



#--------------------- read in the result file and add disease information in  -------------------------------

open(OUT, "> $outGeneInfoPPIScoreLabelfea_diseaseFile");  
my $countout = 0; 
print OUT "#geneID1	geneSym1	geneID2	geneSym2	RFpnScore	hprdLabel		GeneID1:Synonyms:description		27features		GDBID	GeneticDisorder\n"; 

$count = 0; 
open(INS, $GeneInfoPPIScoreLabelfeaFile) || die(" Can not open file(\"$GeneInfoPPIScoreLabelfeaFile\").\n"); 

my $countDisease = 0; 
while(<INS>)
{
	chomp $_;	
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 		
	$curLine = $_; 

	@data_array = split('\t', $_) ;
	my $geneSym = $data_array[1];

	if (defined $geneinfo{"$geneSym"})	
	{
		$curdisease = $geneinfo{"$geneSym"}; 
		$countDisease = $countDisease + 1 ; 
	}	
	else {
		$curdisease = ""; 
	}
	
	print OUT "$curLine		$curdisease\n"; 		
	$countout = $countout + 1; 			
}

print "\n- input result file : $GeneInfoPPIScoreLabelfeaFile: total $count lines; \n"; 
print "\n- out GeneInfoPPIScoreLabelfea_diseaseFile file: $outGeneInfoPPIScoreLabelfea_diseaseFile: $countout lines \n"; 
print "\n- Among them, there are $countDisease lines having GDB-disease-info \n"; 
close(OUT); 
close(INS);
