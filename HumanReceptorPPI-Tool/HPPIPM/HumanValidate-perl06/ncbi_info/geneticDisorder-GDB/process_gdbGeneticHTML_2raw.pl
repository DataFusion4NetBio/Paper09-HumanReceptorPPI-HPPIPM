# This program is to convert the GDB-genetic-disorder-HTMLs together into a raw format
# 
#


use strict;
die "Usage: command GDB_geneticDisfile outRawFile \n" if scalar(@ARGV) < 2;
my ( $GDB_geneticDisfile, $outRawFile ) = @ARGV;

open(IN, $GDB_geneticDisfile) || die(" Can not open file(\"$GDB_geneticDisfile\").\n"); 
open(OUT, "> $outRawFile") || die(" Can not open file(\"$outRawFile\").\n"); 

my ( $geneID, $gdbID, $omimEntry ); 

my $count = 0; 
my $line_num = 0; 
while (<IN>)	
{
	chomp; 
	chop; 
	next if /^$/; 			#ignore blank lines
	my $per_line = $_; 
	$line_num = $line_num +1; 	
	
	my $temp; 
	if ( $per_line =~ m/^<TR><TD>[A-Za-z0-9~]+<\/TD>$/ )	# start of a gene entry
	{
		$temp = $&; 
		$temp =~ s/<TR><TD>//;
		$temp =~ s/<\/TD>//;	
		print OUT $temp; 
		next; 
	}
	elsif ( $per_line =~ m/^<\/TR>$/ )	# end of a gene entry
	{
		print OUT "\n"; 
		$count = $count + 1; 
		next; 
	}
	elsif ( $per_line =~ m/>GDB:[0-9]+/ )	# start of a GDBID
	{
		$temp = $&; 
		$temp =~ s/>//;
		print OUT "\t$temp"; 
		next; 
	}
	#elsif ( $per_line =~ m/>[A-Za-z0-9,\s;\-\@\:\(\)\/]+<\/A><BR>/ )	# start of a OMIM entry
	elsif ( $per_line =~ m/>.+<\/A><BR>/ )	# start of a OMIM entry
	{
		$temp = $&; 
		$temp =~ s/<\/A><BR>//;
		print OUT "\t$temp"; 
		next; 
	}
}

print "\n- Input GDB-genetic File: $line_num lines; \n"; 
print "- Output transformed file: $count lines; \n"; 
close(IN); 
close(OUT); 
