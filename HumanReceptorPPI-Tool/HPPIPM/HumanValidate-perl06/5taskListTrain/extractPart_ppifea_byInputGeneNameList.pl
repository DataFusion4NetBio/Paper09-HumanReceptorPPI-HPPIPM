#
# This program is to filter the human PPI list by the input geneName list
#
 


use strict;
die "Usage: command HumanPPIFile HumanPPIfeaFile ncbigenelist inputGeneNameList outFilteredPairList outFilteredPairFea \n" if scalar(@ARGV) < 6;
my ( $HumanPPIFile, $HumanPPIfeaFile, $ncbigenelist, $inputGeneNameList, $outFilteredPairList, $outFilteredPairFea ) = @ARGV;



#--------------------- read in the human NCBI protein-gene mapping file -------------------------------

my @data_array = (); 
my ( $count, $curLine, $curGene, $curGeneSymbol , $curGI ); 

my %genesym2geneid = (); 
my %geneid2genesymb = (); 
$count = 0; 

open(NCBI, $ncbigenelist) || die(" Can not open file(\"$ncbigenelist\").\n"); 
while(<NCBI>)
{
	chomp $_;	
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 		
	$curLine = $_; 

	# format: # proGI	proAcc	geneID	geneSym
	@data_array = split('\t', $_) ;
	$curGene = $data_array[2]; 
	$curGI = $data_array[0]; 
	$curGeneSymbol = uc($data_array[3]); 
	$genesym2geneid{"$curGeneSymbol"} = $curGene;  
	$geneid2genesymb{"$curGene"} = $curGeneSymbol;  
}
close(NCBI);
print "\n- NCBI GeneProtein list file : $ncbigenelist : $count lines\n"; 
print "- genesym2geneid: ". keys(%genesym2geneid) ." entries. \n"; 
print "- geneid2genesymb: ". keys(%geneid2genesymb) ." entries. \n"; 




#--------------------- read in the input task gene list -------------------------------

my %taskGene = (); 
$count = 0; 
my $countGeneName = 0; 
my $countID = 0; 
open(REC, $inputGeneNameList) || die(" Can not open file(\"$inputGeneNameList\").\n"); 
while(<REC>)
{
	chomp $_;
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 
	$curLine = $_; 

	# format: #geneSym
	@data_array = split('\s', $curLine) ;
	$curGene = $genesym2geneid{"$data_array[0]"}; 
	if ( defined  $curGene )
	{	$taskGene{"$curGene"} = $geneid2genesymb{"$curGene"};  
		$countGeneName = $countGeneName + 1; 
	}
	else {
		#print "$curLine\n"; 
	}
}
close(REC);
print "\n- Input Task GeneList file : $count lines\n"; 
print "- valid taskGene : ". keys(%taskGene) ." entries. \n"; 
print "- For input task list file: $countGeneName lines GeneName used \n"; 




#--------------------- filter the human PPI list file  -------------------------------

open(IN, $HumanPPIFile) || die(" Can not open file(\"$HumanPPIFile\").\n"); 
open(OUT, "> $outFilteredPairList") || die(" Can not open file(\"$outFilteredPairList\").\n"); 
open(INF, $HumanPPIfeaFile) || die(" Can not open file(\"$HumanPPIfeaFile\").\n"); 
open(OUTF, "> $outFilteredPairFea") || die(" Can not open file(\"$outFilteredPairFea\").\n"); 

$count = 0; 
my $line_num = 0; 
while (<IN>)	
{
	chomp; 
	next if /^$/; 			#ignore blank lines
	my $per_line = $_; 
	
	if ( $per_line =~ m/^#/ )	#directly output comments
	{
		print OUT $_."\n"; 
		next; 
	}
	$line_num = $line_num +1; 
	
	my $curFea_line = <INF>; 
	
	my @items = split('\t', $per_line); 
	# fileformat:#proGI1	geneID1	proGI2	geneID2	1/0
	my $geneID1 = $items[1];
	my $geneID2 = $items[3];
		
	if (( defined $taskGene{"$geneID1"} ) || ( defined $taskGene{"$geneID2"} ))
	{	
		$count = $count + 1; 				
		print OUT $per_line."\n";
		print OUTF $curFea_line;
	}
	else {
		#print $per_line."\n";
	}
}

print "\n- Input human PPI File: $line_num lines; \n"; 
close(IN); 
close(INF); 

print "- Output task filtered human PPI file: $count lines; \n"; 
close(OUT); 
close(OUTF); 
