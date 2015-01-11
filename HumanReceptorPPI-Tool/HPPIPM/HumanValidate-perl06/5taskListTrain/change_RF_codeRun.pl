#
# This program is a wrapper to change the RF code's training size and compile, then run the training process 
#
# Here we suppose that there is one program MinGW and we could use "G:\MinGW\bin\g77" to compile F77 code 
# 


use strict;
die "Usage: command oldRFcodeFile inputTrainFile inputTestFile outRFcodeFile outRFexeFile outRFtree outRFimpFast \n" if scalar(@ARGV) < 7;
my ( $oldRFcodeFile, $inputTrainFile, $inputTestFile, $outRFcodeFile, $outRFexeFile, $outRFtree, $outRFimpFast ) = @ARGV;


#---------------------  count trainSize  -------------------------------

open(IN, $inputTrainFile) || die(" Can not open file(\"$inputTrainFile\").\n"); 
my $inputTrainSize = 0; 
while (<IN>)	
{
	my $per_line = $_; 
	$inputTrainSize = $inputTrainSize +1; 		
}
close(IN); 
print "\nInput train data: $inputTrainSize examples. \n"; 



#---------------------  change RF code  -------------------------------

open(IN, $oldRFcodeFile) || die(" Can not open file(\"$oldRFcodeFile\").\n"); 
open(OUT, "> $outRFcodeFile") || die(" Can not open file(\"$outRFcodeFile\").\n"); 

my $line_num = 0; 
while (<IN>)	
{
	my $per_line = $_; 
	$line_num = $line_num +1; 	
	
	if ( $per_line =~ m/mdim= 27, nsample0= / )
	{
		print "Original: ".$per_line."\n";
		my @items = split(/,/, $per_line); 
		my $nsample = $items[1];
		
		my @samplearray = split(/=/, $nsample); 
		$samplearray[1] = $inputTrainSize ; 
		$items[1] = join("= ", @samplearray); 
		
		my $changeLine = join(",", @items);	
		print "Changed: ".$changeLine;
		print OUT $changeLine; 
	}
	else {
		print OUT $per_line;
	}
}
close(IN); 
close(OUT); 



#---------------------  compile RF train  -------------------------------

#my $g77cmd = 'G:\MinGW\bin\g77 '; 
my $g77cmd = 'g77 '; 
my $compile = "$g77cmd  $outRFcodeFile -o $outRFexeFile "; 
print "$compile \n"; 
system($compile); 



#---------------------  run RF train  -------------------------------


my $traincmd = "$outRFexeFile $inputTrainFile $outRFtree  $outRFimpFast $inputTestFile $inputTestFile.out "; 
print "$traincmd \n"; 
system($traincmd); 
