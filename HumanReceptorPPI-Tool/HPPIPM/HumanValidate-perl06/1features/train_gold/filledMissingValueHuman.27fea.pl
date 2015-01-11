# This is a program to filled the missing value in the data set of PPI Human-receptor (27fea version)

#o	To filled the missing value in each feature : filled with the median value 

# Actually then for our data set
# - Gene expression 16 features use mean value 
# - all other missing slots use 0 to fill
#

use strict; 
die "Usage: command file filledFile \n" if scalar(@ARGV) < 2;

my $orgFile = $ARGV[0];
my $fillFile = $ARGV[1];

# - Gene expression 16 features use mean value 
my @genexp_filled = ('0.3780', '0.0056', '0.0276', '0.0233', '0.0315', '0.0095', '0.3669', '0.0708', '0.2713', '0.0167', '0.0029', '0.0477', '0.0420', '0.0395', '0.0467', '0.0836');
my $go_dd_filled = 0; 
my $tissue_filled = 8.5; 

open IN, "$orgFile";
open OUT, ">$fillFile";
	
	my $curLine; 
	my $count = 0; 
	
	while (<IN>)
	{
		$curLine = $_ ;
		
		my @items = split(',', $curLine); 
		my $i ; 
		
		my $curSize = $#items; 
		for ($i = 0; $i <= $curSize ; $i ++ )
		{
		    if ($items[ $i ] == -100)
		    {	
			if ($i < 3)
			{	# go
				$items[ $i ] = $go_dd_filled; 
			}
			elsif ($i < 4)
			{	# cotissue
				$items[ $i ] = $tissue_filled; 
			}
			elsif ( $i < 20 )
			{	# gene exp
				$items[ $i ] = $genexp_filled[$i - 4 ]; 
			}
			else 
			{	$items[ $i ] =~ s/-100/0/;	}
		    }
		}
		
		print OUT join(",", @items); 
		$count = $count + 1; 
	}
	
print "$count lines.\n"; 
close(IN);
close(OUT);
