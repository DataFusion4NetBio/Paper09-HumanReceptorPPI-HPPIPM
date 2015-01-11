#
# For the PPI list file + RFScoreLabel file + feature file 
# we would combine and also find their partner's related gene_info and added in 
# 

use strict;
die "Usage: command PPIlistfile rfScoreLabelFile featureFile humanGeneInfoFile outGeneInfoPPIScoreLabelfeaFile \n" if scalar(@ARGV) < 5;
my ( $PPIlistfile, $rfScoreLabelFile, $featureFile, $humanGeneInfoFile, $outGeneInfoPPIScoreLabelfeaFile ) = @ARGV;



#--------------------- read in the humanGeneInfoFile file  -------------------------------

my @data_array = (); 
my ( $count, $curLine, $curGene, $curGeneSymbol ); 

my %geneinfo = (); 
my %geneid2geneSym = (); 
$count = 0; 

open(INS, $humanGeneInfoFile) || die(" Can not open file(\"$humanGeneInfoFile\").\n"); 
while(<INS>)
{
	chomp $_;	
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 		
	$curLine = $_; 

	# format: tax_id	GeneID	Symbol	LocusTag	Synonyms	dbXrefs	chromosome	maplocation	description	genetype	Symbol_from_nomenclature_authority\n"; 
	@data_array = split('\t', $_) ;
	$curGene = $data_array[1]; 
	$curGeneSymbol = $data_array[2]; 
	$geneid2geneSym{"$curGene"} = $curGeneSymbol; 

	my $sym = $data_array[4 ]; 
	my $des = $data_array[8 ]; 
	$geneinfo{"$curGene"} = "$curGene:$sym:$des"; 

}
print "\n- geneinfo: $humanGeneInfoFile : $count lines\n"; 
print "- geneid2geneSym has ". scalar keys( %geneid2geneSym) ." entries.\n"; 
print "- geneinfo has ". scalar keys(%geneinfo) ." entries.\n\n"; 
close(INS);


#--------------------- read in the PPI list file + scoreLabel file + feature file -------------------------------

open(OUT, "> $outGeneInfoPPIScoreLabelfeaFile");  
my $countout = 0; 
print OUT "#geneID1	geneSym1	geneID2	geneSym2	RFpnScore	hprdLabel		GeneID1:Synonyms:description		27features\n"; 

$count = 0; 
open(INS, $PPIlistfile) || die(" Can not open file(\"$PPIlistfile\").\n"); 
open(INScLab, $rfScoreLabelFile) || die(" Can not open file(\"$rfScoreLabelFile\").\n"); 
open(INF, $featureFile) || die(" Can not open file(\"$featureFile\").\n"); 
while(<INS>)
{
	chomp $_;	
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 		

	#format: proGI1	geneID1	proGI2	geneID2	1
	@data_array = split('\t', $_) ;
	my $geneID1 = $data_array[1]; 
	my $geneSym1 = $geneid2geneSym{"$geneID1"}; 
	if ( ! defined $geneSym1 )	
	{	$geneSym1 = ""; }
	
	my $geneID2 = $data_array[3]; 
	my $geneSym2 = $geneid2geneSym{"$geneID2"};
	if ( ! defined $geneSym2 )	
	{	$geneSym2 = ""; }
	
	my $genepartner = $data_array[1]; 
	if (defined $geneinfo{"$genepartner"})	
	{
		$curLine = $geneinfo{"$genepartner"}; 
	}	
	else {
		$curLine = ""; 
	}
	
	my $features = <INF>; 		# comma seperated 
	chomp($features); 
	
	my $Scorelabe = <INScLab>;   	# tab seperated 
	chomp($Scorelabe); 
	my @temparray = split('\s', $Scorelabe) ;
	
	print OUT "$geneID1	$geneSym1	$geneID2	$geneSym2	$temparray[0]	$temparray[1]		$curLine		$features\n"; 		
	$countout = $countout + 1; 			
}

print "\n- PPIlistFile : $PPIlistfile: total $count lines; \n"; 
print "\n- out outPPIlistGeneInfoFile file: $outGeneInfoPPIScoreLabelfeaFile: $countout lines \n"; 

close(OUT); 
close(INS);
close(INScLab);
close(INF);
