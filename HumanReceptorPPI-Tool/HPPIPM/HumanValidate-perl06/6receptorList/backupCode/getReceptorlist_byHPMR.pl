# This program is to get the HPMR receptor geneNameID list
#
# Here not only based on the HPMR geneList, also based on a list manually labelled from those nonSearchable genes symbols into another file 
#
# The output format: 
##proGI	proAcc	geneID	geneSym


use strict;
die "Usage: command ncbigenelist hpmReceptorGeneNameIDList hpmReceptorManualLabeledList outFullReceptorList \n" if scalar(@ARGV) < 4;
my (  $ncbigenelist, $hpmReceptorGeneNameIDList, $hpmReceptorManualLabeledList, $outFullReceptorList ) = @ARGV;




#--------------------- read in the human NCBI protein-gene mapping file -------------------------------

my @data_array = (); 
my ( $count, $curLine, $curGene, $curGeneSymbol , $curGI, $curAcc ); 

my %genesym2geneid = (); 
my %geneid2genesymb = ();
my %geneid2proGI = (); 
my %geneid2proAcc = (); 
 
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
	$curAcc = $data_array[1]; 
	$curGeneSymbol = uc($data_array[3]); 
	
	$genesym2geneid{"$curGeneSymbol"} = $curGene;  
	$geneid2genesymb{"$curGene"} = $curGeneSymbol;  
	$geneid2proGI{"$curGene"} = $curGI;  	
	$geneid2proAcc{"$curGene"} = $curAcc;  		
}
close(NCBI);
print "\n- NCBI GeneProtein list file : $ncbigenelist : $count lines\n"; 
print "- genesym2geneid: ". keys(%genesym2geneid) ." entries. \n"; 
print "- geneid2genesymb: ". keys(%geneid2genesymb) ." entries. \n"; 




#--------------------- read in the HPMR receptor gene list -------------------------------
# This list is extracted from the GeneName column and the URL column on the HPMR search resulting HTML page

my %receptorNCBIgene = (); 
$count = 0; 
my $countGeneName = 0; 
my $countID = 0; 
open(REC, $hpmReceptorGeneNameIDList) || die(" Can not open file(\"$hpmReceptorGeneNameIDList\").\n"); 
while(<REC>)
{
	chomp $_;
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 
	$curLine = $_; 
	chop($curLine); 

	# format: #geneSym	UrlHpredID
	@data_array = split('\t', $curLine) ;
	my @tempSymbols = split('\s', uc($data_array[0])); 
	$curGene = $genesym2geneid{"$tempSymbols[0]"}; 
	my $hpredID = $data_array[1]; 
	my $mappgedGeneSym = $geneid2genesymb{"$hpredID"}; 	
	if ( defined  $curGene )
	{	$receptorNCBIgene{"$curGene"} = $curGeneSymbol;  
		$countGeneName = $countGeneName + 1; 
	}
	elsif ( defined  $mappgedGeneSym )
	{	$receptorNCBIgene{"$hpredID"} = $mappgedGeneSym;   
		$countID = $countID + 1; 
	}
	else {
		#print "$curLine\n"; 
	}
}
close(REC);
print "\n- HPMR ReceptorGeneList file : $count lines\n"; 
print "- receptorNCBIgene: ". keys(%receptorNCBIgene) ." entries. \n"; 
print "- For receptor list file: $countGeneName lines GeneName items used \n"; 
print "- For receptor list file: $countID lines HpredID items used \n"; 




#--------------------- read in the HPMR receptor geneSymbol Manually Labeled list -------------------------------
# This list is derived from the above list (that from the GeneName column and the URL column on the HPMR search resulting HTML page)
# Also the items in this list could not be directly searchable from NCBI
# we manually label their GeneSymbols in each line if existing 

$count = 0; 
my $countManualGeneName = 0; 
open(MAN, $hpmReceptorManualLabeledList) || die(" Can not open file(\"$hpmReceptorManualLabeledList\").\n"); 
while(<MAN>)
{
	chomp $_;
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 
	$curLine = $_; 
	#chop($curLine); 

	# format: #geneSym	UrlHpredID	manualGeneSymbol
	@data_array = split('\t', $curLine) ;
	if ($#data_array == 2) 
	{
		$curGeneSymbol = $data_array[2]; 
		$curGene = $genesym2geneid{"$curGeneSymbol"}; 
		if ( defined  $curGene )
		{	$receptorNCBIgene{"$curGene"} = $curGeneSymbol;  
			$countManualGeneName = $countManualGeneName + 1; 
		}
	}
}
close(MAN);
print "\n- Add Manually labeled HPMR Receptor file : $count lines\n"; 
print "- Now receptorNCBIgene: ". keys(%receptorNCBIgene) ." entries. \n"; 
print "- From this Manually labeled HPMR Receptor file: $countManualGeneName lines GeneSymbol used \n"; 




#--------------------- output the full human receptor list to file  -------------------------------

# The output format: 
##proGI	proAcc	geneID	geneSym


open(OUT, "> $outFullReceptorList") || die(" Can not open file(\"$outFullReceptorList\").\n"); 
$count = 0; 
print OUT "#proGI	proAcc	geneID	geneSym\n"; 
while ( my ($key, $value) = each(%receptorNCBIgene) ) 
{
	$curGI = $geneid2proGI{"$key"} ;  	
	$curAcc = $geneid2proAcc{"$key"} ;  	
	$curGeneSymbol = $geneid2genesymb{"$key"} ; 
	$count = $count + 1; 				
	print OUT "$curGI	$curAcc	$key	$curGeneSymbol\n";
}

print "- Output receptors (full list): $count lines; \n"; 
close(OUT); 
