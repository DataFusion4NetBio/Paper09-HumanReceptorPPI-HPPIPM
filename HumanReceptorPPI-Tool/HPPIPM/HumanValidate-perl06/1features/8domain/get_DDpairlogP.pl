#
# Program to Extract Features of domain-domain pairInteract for protein pair list subset  
# 
# $ perl  get_DDpairlogP.pl ../train_gold/human/lists/curUsedLists/human.hprdpairwiseNoself.posPair.receptfilter human.hprdNoself.posNoRecp.rand60w.cut0.001000.ddpcutpvalue hprdxml.gene-domain.geneID ./temp/temp1
# - domainGeneMapFile: hprdxml.gene-domain.geneID : 11477 lines
# - geneid2geneSym:11477 entries.
# - geneid2domain: 11477 entries.
# - dd2pvalue:5169 entries.
# - Input list:  2522 pairs ! - DDpvalue hits :  2339 pairs ! - DDpvalue zero value :  543 pairs !
# 


use strict; 
die "Usage: command protein_pair_file  ddPairPvalueList  domainGeneMapFile  outputDDfeature \n" if scalar(@ARGV) < 4;

my ( $protein_pair_file,  $ddPairPvalueList,  $domainGeneMapFile,  $outputDDfeature ) = @ARGV;



#--------------------- read in the domainGeneMapFile  -------------------------------

my @data_array = (); 
my ( $count, $curLine, $curGene, $curGeneSymbol , $curDomainList ); 

my %geneid2domain = (); 
my %geneid2geneSym = (); 
$count = 0; 

open(DOM, $domainGeneMapFile) || die(" Can not open file(\"$domainGeneMapFile\").\n"); 
while(<DOM>)
{
	chomp $_;	
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 		
	$curLine = $_; 

	# format: #GeneID	GeneSymbol	domainName(one|multiple)
	@data_array = split('\t', $_) ;
	$curGene = $data_array[0]; 
	$curGeneSymbol = $data_array[1]; 
	$curDomainList = $data_array[2]; 
	
	$geneid2geneSym{"$curGene"} = $curGeneSymbol; 

	my @temparray = split(/\|/, $curDomainList) ;
 	$geneid2domain{"$curGene"} = \@temparray ;
}
close(DOM);
print "\n- domainGeneMapFile: $domainGeneMapFile : $count lines\n"; 
print "- geneid2geneSym:". keys(%geneid2geneSym) ." entries. \n"; 
print "- geneid2domain: ". keys(%geneid2domain) ." entries. \n"; 




#--------------------- read in the ddPairPvalueList  -------------------------------

my %dd2pvalue = (); 
$count = 0; 
my ( $domainpair, $logpvalue ); 
open(DD, $ddPairPvalueList) || die(" Can not open file(\"$ddPairPvalueList\").\n"); 
while(<DD>)
{
	chomp $_;	
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	$count = $count + 1; 		
	$curLine = $_; 

	# format: #ddpairnames log10-hyperge-pvalue
	@data_array = split('\s', $_) ;
	$domainpair = $data_array[0] ; 
	$logpvalue = $data_array[1] ; 
	$dd2pvalue{"$domainpair"} = $logpvalue; 
}
close(DD);
print "- dd2pvalue:". keys(%dd2pvalue) ." entries. \n"; 





#--------------------- Begin to process the int set -------------------------------

open(INT, $protein_pair_file) || die(" Can not open file(\"$protein_pair_file\").\n"); 
open(OUT, "> $outputDDfeature") || die(" Can not open file(\"$outputDDfeature\").\n");

my $count =  0; 
my $count_hits = 0; 
my $count_zero = 0; 

while (<INT>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	# input format # proGI1	geneID1	proGI2	geneID2	flag
	my ($proGI1, $geneID1, $proGI2, $geneID2, $flag) = split('\t', $_);

	my $domainarrayRef1 = $geneid2domain{"$geneID1"}; 
	my $domainarrayRef2 = $geneid2domain{"$geneID2"}; 

	my $ppiddpvalue = -100; 
	if (( defined $domainarrayRef1 ) && ( defined $domainarrayRef2 ))
	{
		$count_hits = $count_hits + 1; 
		my ($domain1, $domain2, $minPvalue); 
		$minPvalue = 0; 
		foreach $domain1 ( @{$domainarrayRef1} )
		{
			foreach $domain2 ( @{$domainarrayRef2} )
			{
				if ( defined $dd2pvalue{"$domain1|$domain2"} )
				{	
					if ( $minPvalue >  $dd2pvalue{"$domain1|$domain2"} ) 
					{	$minPvalue = $dd2pvalue{"$domain1|$domain2"}; }
				}
				elsif ( defined $dd2pvalue{"$domain2|$domain1"} )
				{
					if ( $minPvalue >  $dd2pvalue{"$domain2|$domain1"} ) 
					{	$minPvalue =  $dd2pvalue{"$domain2|$domain1"}; }	
				}
		 	}
		}		
		$ppiddpvalue = 	-$minPvalue; 
	}
	print OUT "$ppiddpvalue,$flag\n";
	if ( $ppiddpvalue == 0 )
	{ $count_zero = $count_zero + 1; }
	$count = $count + 1; 
}

print "- Input list:  $count pairs ! ";
print "- DDpvalue hits :  $count_hits pairs ! ";
print "- DDpvalue zero value :  $count_zero pairs ! ";
close(INT);					
close(OUT);