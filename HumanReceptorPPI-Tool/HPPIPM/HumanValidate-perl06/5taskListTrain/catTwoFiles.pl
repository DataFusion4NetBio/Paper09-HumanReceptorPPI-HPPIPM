#
# This program is to concatenate two files 
#
 


use strict;
die "Usage: command file1 file2 outfile \n" if scalar(@ARGV) < 3;
my ( $file1, $file2, $outfile  ) = @ARGV;


open(IN, $file1) || die(" Can not open file(\"$file1\").\n"); 
open(INF, $file2) || die(" Can not open file(\"$file2\").\n"); 
open(OUT, "> $outfile") || die(" Can not open file(\"$outfile\").\n"); 

my $count = 0; 
my $line_num = 0; 
while (<IN>)	
{
	my $per_line = $_; 
	$line_num = $line_num +1; 
	$count = $count + 1; 
	print OUT $per_line;
}
print "\n- Input first file: $line_num lines; \n"; 
close(IN); 


$line_num = 0; 
while (<INF>)	
{
	my $per_line = $_; 
	$line_num = $line_num +1; 
	$count = $count + 1; 	
	print OUT $per_line;
}
print "\n- Input second file: $line_num lines; \n"; 
close(INF); 


print "- Output concatenate file: $count lines; \n"; 
close(OUT); 

