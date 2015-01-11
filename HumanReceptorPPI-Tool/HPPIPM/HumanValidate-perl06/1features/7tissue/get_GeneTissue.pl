#
# Program to Extract gene _ co-tissue information for protein pairs 
#
# $ perl  get_GeneTissue.pl ./temp/human.bind.pospair.tempsub human.ncbiprotein.list Hs.data.GeneTissueMap ./temp/human.bind.pospair.tempsub.cotissue
#
# - gene Size of NCBI_protein_gene_list :  24370.
# - Size of genes having tissue information : 17204.
# - Input protein pair file: 92 pairs ! ;
# - 89 gene Pairs has co-tissue.
# 


use strict; 
die "Usage: command protein_pair_file ncbi_genelist Gene_Tissue_mapfile out_file_name\n" if scalar(@ARGV) < 4 ;

print "\npara1: $ARGV[1]\n"; 
print "para2: $ARGV[2]\n"; 
print "para3: $ARGV[3]\n\n"; 

my ($int_file, $ncbi_listfile, $geneTissue_file, $out_file) = @ARGV;


#--------------------- read in the derived ncbi protein_gene_list file  -------------------------------

open(LIS, $ncbi_listfile) || die(" Can not open file(\"$ncbi_listfile\").\n"); 

my %geneSym2geneid = (); 
while (<LIS>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	# File format: ## proGI	proAcc	geneID	geneSym	
	my @line = split('\t', $_);
	if ( $line[3] ne "" )
	{
		$geneSym2geneid{"$line[3]"} = $line[2]; 
	}
}

close(LIS); 
print "- gene Size of NCBI_protein_gene_list :  " . keys( %geneSym2geneid ) . ".\n";



#--------------------- read in the Gene_Tissue_mapfile  -------------------------------

my %geneTissue = (); 

open(TIS, $geneTissue_file) || die(" Can not open file(\"$geneTissue_file\").\n"); 
while (<TIS>)	
{
	chomp $_; 
	next if /^\s*$/; 			#ignore blank lines
	
	my @line = split('\t', $_);
	
	my $geneSym = $line[0]; 
	my $geneID = $geneSym2geneid{"$geneSym"}; 
	
	if ( defined $geneID )
	{
		my $i; 
		my @tissues = split(/;/, $line[1]);
		my @finalTissues = (); 
		for ( $i = 0; $i <= $#tissues ; $i ++ )
		{
			my $temp = trim($tissues[$i]); 
			if ( $temp ne '' )
			{
				push( @finalTissues, $temp ); 
			}
			if ($#finalTissues > 0)
			{
				$geneTissue{"$geneID"} = \@finalTissues; 
			}
		}
	}
}
close(TIS);
print "- Size of genes having tissue information : " . keys( %geneTissue ) . ".\n";




#--------------------- Begin to process the input pair list and find if their homolgy pair in PPIs -------------------------------

open(INT, $int_file) || die(" Can not open file(\"$int_file\").\n"); 
open(OUT, "> $out_file") || die(" Can not open file(\"$out_file\").\n");

my $count =  0; 
my $count_co = 0; 

while (<INT>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	
	# input format # proGI1	geneID1	proGI2	geneID2	flag
	my ($proGI1, $geneID1, $proGI2, $geneID2, $flag) = split('\t', $_);

	my $score = -100; 
	if ( (defined $geneTissue{"$geneID1"} ) &&  (defined $geneTissue{"$geneID2"} ))
	{
		my @tissue1 = @{$geneTissue{"$geneID1"}}; 
		my @tissue2 = @{$geneTissue{"$geneID2"}}; 	
		
		my ($curpro1, $curpro2); 

		$score = 0; 
		foreach $curpro1 (@tissue1) 
		{
			foreach $curpro2 (@tissue2) 
			{
				if (( $curpro1 eq $curpro2 ) && (  $curpro1 ne 'mixed' ) && (  $curpro1 ne 'other' ))
				{
					$score = $score + 1 ;  
				}
				# The following two elsif are newly added 
				elsif (( $curpro1 eq $curpro2 ) && (  $curpro1 eq 'mixed' ))
				{
					$score = $score + 0.5 ;  
				}
				elsif (( $curpro1 eq $curpro2 ) && (  $curpro1 eq 'other' ))
				{
					$score = $score + 0.5 ;  
				}
				else 
				{ 
					$score = $score + 0;  
				}
			}
		}
		if ( $score > 0)
		{
			$count_co = $count_co + 1; 		
		}
	}
	print OUT "$score,$flag\n"; 
	$count = $count + 1; 
}

print "\n- Input protein pair file: $count pairs ! ; \n- $count_co gene Pairs has co-tissue. \n ";

close(INT);					
close(OUT);


# Perl trim function to remove whitespace from the start and end of the string
sub trim($)
{
	my $str = shift;
	my ( $string1, $string2 ); 
	( $string1 = $str) =~ s/^\s+//;
	( $string2 = $string1 ) =~ s/\s+$//;
	return $string2;
}
