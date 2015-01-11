# Program to summarize one kind of gene ontology feature (detailed style) for protein pair list  for a specific hierarchy
# 
# GO Slim Generic June 2005 Version
# The input file format:  go features separated by ",", the last one is the class flag
#

use strict; 
die "Usage: command go_slimFeature_file out_name\n" if scalar(@ARGV) < 2;

my ($int_file, $out_file) = @ARGV;


#--------------------- read in the feature and then summarize to one and output  -------------------------------
# For initial each of them, the feature be a 2-value category variable... 
# 

open(IN, $int_file) || die(" Can not open file(\"$int_file\").\n"); 
open(OUT, "> $out_file") || die(" Can not open file(\"$out_file\").\n");
my $line = 0; 
while (<IN>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	# input format: separated by ",", the last one is the class flag
	my @data_array = split(',', $_);
	my $flag = $data_array[$#data_array]; 
	
	my $i; 
	my $sum = 0; 
	my $count = 0; 
	for ( $i = 0; $i < $#data_array ; $i ++ )
	{
		if ( $data_array[$i] != -100 )
		{	$sum = $sum + $data_array[$i] ; }
		else {
			$count = $count + 1; 			
		}
	}
	if ($count == $#data_array )
	{	$sum = -100; }
   	print OUT "$sum, $flag\n";    
   	$line = $line + 1; 
}
close(IN); 
close(OUT);
print "Summary GO feature file: $int_file  - $line lines.\n"; 
