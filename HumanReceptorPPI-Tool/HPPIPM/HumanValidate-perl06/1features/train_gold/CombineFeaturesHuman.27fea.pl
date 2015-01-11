# This is a program to combine the features and labels files together into an integrated data set - 27 feature version
#!perl -w datasetPre outset 

use strict; 
die "Usage: command InFilePre outfile \n" if scalar(@ARGV) < 2;
my ($inputPair, $out_file ) = @ARGV;

my $cmd1 = $inputPair.".gofuncsum" ; 
my $cmd2 = $inputPair.".gocompsum" ; 
my $cmd3 = $inputPair.".goprocsum" ; 
#my $cmd4 = $inputPair.".goproc" ; 
my $cmd5 = $inputPair.".tissue" ; 
my $cmd6 = $inputPair.".16coexp" ; 
my $cmd7 = $inputPair.".blastp" ; 
my $cmd8 = $inputPair.".yeastHMppi" ; 
my $cmd9 = $inputPair.".yeastHMppi.dips.svm" ; 
my $cmd10 = $inputPair.".yeastHMppi.mips.svm" ; 
my $cmd11 = $inputPair.".yeastHMppi.dips.rf" ; 
my $cmd12 = $inputPair.".yeastHMppi.mips.rf" ; 
#my $cmd11 = $inputPair.".naturey2h" ; 
#my $cmd12 = $inputPair.".celly2h" ; 
my $cmd13 = $inputPair.".ddpvalue" ; 


open(F1, $cmd1) || die(" Can not open file(\"$cmd1\").\n"); 
open(F2, $cmd2) || die(" Can not open file(\"$cmd2\").\n"); 
open(F3, $cmd3) || die(" Can not open file(\"$cmd3\").\n"); 
#open(F4, $cmd4) || die(" Can not open file(\"$cmd4\").\n"); 
open(F5, $cmd5) || die(" Can not open file(\"$cmd5\").\n"); 
open(F6, $cmd6) || die(" Can not open file(\"$cmd6\").\n"); 
open(F7, $cmd7) || die(" Can not open file(\"$cmd7\").\n"); 
open(F8, $cmd8) || die(" Can not open file(\"$cmd8\").\n"); 
open(F9, $cmd9) || die(" Can not open file(\"$cmd9\").\n"); 
open(F10, $cmd10) || die(" Can not open file(\"$cmd10\").\n"); 
open(F11, $cmd11) || die(" Can not open file(\"$cmd11\").\n"); 
open(F12, $cmd12) || die(" Can not open file(\"$cmd12\").\n"); 
open(F13, $cmd13) || die(" Can not open file(\"$cmd13\").\n"); 


open(OUT, "> $out_file") || die(" Can not open file(\"$out_file\").\n");

my ( $per_line, $line_num, @lines); 

$line_num = 0; 
my $fea_num = 0; 
my @temp = (); 

while (<F1>)
{
		$line_num = $line_num +1; 
		$fea_num = 0; 
		
		$per_line = $_; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 1 )
			{ print "Go Func Sum wrong: not $#temp features ! \n"; }; 
 
		$per_line = <F2>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 	
		if ( $fea_num != 2 )
			{ print "GO Comp Sum feature wrong: not $#temp features ! \n"; }; 	

		$per_line = <F3>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 3 )
		{ print " Go Process Sum feature wrong: not $#temp features ! \n"; }; 	


		#$per_line = <F4>; 
		#chop($per_line); 
		#@temp = split(/,/, $per_line); 
		#pop(@temp); 
		#print OUT join(',', @temp);  
		#print OUT ",";	
		#$fea_num = $fea_num + $#temp + 1; 
		#if ( $fea_num != 51 )
		#{ print " Go Process detail feature wrong: not $#temp features ! \n"; }; 			


		$per_line = <F5>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 4 )
		{ print " Co-Tissue PPI feature wrong: not $#temp features ! \n"; }; 


		$per_line = <F6>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 20 )
		{ print " Co-expression feature wrong: not $#temp features ! \n"; }; 			


		$per_line = <F7>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 21 )
		{ print " sequence blastp wrong: not $#temp features ! \n"; }; 	


		$per_line = <F8>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 22 )
		{ print " Yeast DIP Homology PPI feature wrong: not $#temp features ! \n"; }; 	


		$per_line = <F9>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 23 )
		{ print " Yeast SVM-DIPS Homology PPI feature wrong: not $#temp features ! \n"; }; 	


		$per_line = <F10>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 24 )
		{ print " Yeast SVM-MIPS Homology PPI feature wrong: not $#temp features ! \n "; }; 	


		$per_line = <F11>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 25 )
		{ print " Yeast RF-DIPS Homology PPI feature wrong: not $#temp features ! \n"; }; 	


		$per_line = <F12>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 26 )
		{ print " Yeast RF-MIPS Homology PPI feature wrong: not $#temp features ! \n"; }; 	
		#{ print " Nature Y2H PPI feature wrong: not $#temp features ! \n"; }; 	
		#{ print " Cell Y2H PPI feature wrong: not $#temp features ! \n"; }; 	


		$per_line = <F13>; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		print OUT join(',', @temp);  
		print OUT "\n";	
		$fea_num = $fea_num + $#temp + 1; 
		if ( $fea_num != 28 )
		{ print " Domain-Domain logpValue PPI feature wrong: not $#temp -1 features ! \n"; }; 	
}
print "\n$line_num rows !   $fea_num features;"; 

close(F1);
close(F2);
close(F3);
#close(F4);
close(F5);
close(F6);
close(F7);
close(F8);
close(F9);
close(F10);
close(F11);
close(F12);
close(F13);

close(OUT); 