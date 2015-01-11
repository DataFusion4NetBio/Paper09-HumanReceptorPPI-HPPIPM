# convert the CSV format data file into the RF fortran version input file format file

# This one is specific for the 12PPI research fea filled missing version 

use strict;
die "Usage: command data_file outputfile size" if scalar(@ARGV) < 3;
my ($data_file, $out_file, $out_size ) = @ARGV;

my @data_array =();

# -------- print out the data  ------------------

my $count = 0; 
my $countn = 0; 

open IN, "$data_file";
open OUT, ">$out_file";

while (<IN>) {
	chomp;
  	@data_array = split(',', $_) ;
	
	my $flag = $data_array[$#data_array]; 
	if ( $flag != 1 ) 
	{ 
		$data_array[$#data_array] = 2; 
		$countn = $countn + 1; 
	}
	$count = $count + 1; 		
	
	# This one is specific for the 12PPI research human 27fea version 
	my $i ; 

	print OUT join(' ', @data_array);
  	print OUT "\n";
  	
  	if ( $out_size <= $count )
  		{last; }
}

print "Total: $count ; Rand: $countn ; $#data_array features each line\n"; 

close(IN); 
close(OUT); 
