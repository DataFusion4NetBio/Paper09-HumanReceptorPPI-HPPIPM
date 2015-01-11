#
# For the gene list file, we would get the gene_info
# 

use strict;
die "Usage: command RequestGeneFile humanGeneInfoFile outRequestGeneInfo \n" if scalar(@ARGV) < 3;
my ( $RequestGeneFile, $humanGeneInfoFile, $outRequestGeneInfo ) = @ARGV;



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
	$geneinfo{"$curGene"} = "$curGene	$sym	$des"; 

}
print "\n- geneinfo: $humanGeneInfoFile : $count lines\n"; 
print "- geneid2geneSym has ". scalar keys( %geneid2geneSym) ." entries.\n"; 
print "- geneinfo has ". scalar keys(%geneinfo) ." entries.\n\n"; 
close(INS);



#--------------------- read in the RequestGeneFile ------------------------------

open(OUT, "> $outRequestGeneInfo");  
my $countout = 0; 
print OUT "#geneID	geneSym	description\n"; 

$count = 0; 
open(INS, $RequestGeneFile) || die(" Can not open file(\"$RequestGeneFile\").\n"); 
while(<INS>)
{
	chomp $_;	
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 		

	#format: ##proGI	proAcc	geneID	geneSym
	@data_array = split('\t', $_) ;
	my $geneID = $data_array[2]; 
	my $geneSym = $geneid2geneSym{"$geneID"}; 
	if ( ! defined $geneSym )	
	{	$geneSym = ""; }

	if (defined $geneinfo{"$geneID"})	
	{
		$curLine = $geneinfo{"$geneID"}; 
	}	
	else {
		$curLine = ""; 
	}
	
	print OUT "$curLine\n"; 		
	$countout = $countout + 1; 			
}
print "\n- Request GeneFile : $RequestGeneFile: total $count lines; \n"; 
print "\n- outRequestGeneInfo file: $outRequestGeneInfo: $countout lines \n"; 

close(OUT); 
close(INS);
