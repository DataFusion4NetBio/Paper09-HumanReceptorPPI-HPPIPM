# This program is to get the interacting partners - receptors' scores 
#
# Here not only based on the HPMR geneList, we also manually labelled those nonSearchable genes symbols into another file 
#
# 


use strict;
die "Usage: command HumanPPIResultFile ncbigenelist hpmReceptorGeneNameIDList hpmReceptorManualLabeledList outReceptorScorefile \n" if scalar(@ARGV) < 5;
my ( $HumanPPIResultFile, $ncbigenelist, $hpmReceptorGeneNameIDList, $hpmReceptorManualLabeledList, $outReceptorScorefile ) = @ARGV;






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




#--------------------- filter the human PPI result list file  -------------------------------

my %receptorScore = (); 

open(IN, $HumanPPIResultFile) || die(" Can not open file(\"$HumanPPIResultFile\").\n"); 
$count = 0; 
my $line_num = 0; 
while (<IN>)	
{
	chomp; 
	next if /^$/; 			#ignore blank lines
	my $per_line = $_; 
	
	if ( $per_line =~ m/^#/ )	#directly output comments
	{
		print $_."\n"; 
		next; 
	}
	$line_num = $line_num +1; 

	my @items = split('\t', $per_line); 
	# fileformat:#geneID1	geneSym1	geneID2	geneSym2	RFpnScore	
	my $geneID1 = $items[0];
	my $geneID2 = $items[2];
		
	if ( defined $receptorNCBIgene{"$geneID1"} ) 
	{	
		$count = $count + 1; 		
		$receptorScore{"$geneID1"} = $items[4]; 
	}
}

print "\n- Input human PPI result File: $line_num lines; \n"; 
close(IN); 

$count = 0; 
open(OUT, "> $outReceptorScorefile") || die(" Can not open file(\"$outReceptorScorefile\").\n"); 
while ( my ($key, $value) = each(%receptorScore) ) 
{
	my $temp = $geneid2genesymb{"$key"}; 
        print OUT "$temp\t$key\t$value\n";
        $count = $count + 1; 		
}
print "- Output receptors filtered human PPI score file: $count lines; \n"; 
close(OUT); 


