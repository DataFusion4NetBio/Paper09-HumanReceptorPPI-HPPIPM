# 
# This is a program to combine the 16 human_coexpression features together into an integrated data set
# 
# perl ./Combine16singleFeatures.pl ./temp/human.bind.pospair.tempsub.16coexp ./temp/human.bind.pospair.tempsub.16coexp

use strict; 
die "Usage: command filePres outfile \n" if scalar(@ARGV) < 2;

my ($inputPre, $out_file ) = @ARGV;
my @geneexp_files = ("GDS330", "GDS365", "GDS531", "GDS534", "GDS596", "GDS601", "GDS619", "GDS651", "GDS715", "GDS806", "GDS807", "GDS842", "GDS843", "GDS987", "GDS1085", "GDS1086");

my @filenames = (); 
my $i; 
for ($i = 0; $i < 16; $i++ )
{
	$filenames[$i] = $inputPre.'.'.$geneexp_files[$i].".coexp";
}


open(FIL0, $filenames[0] ) || die(" Can not open file(\"$filenames[0] \").\n");
open(FIL1, $filenames[1] ) || die(" Can not open file(\"$filenames[1] \").\n");
open(FIL2, $filenames[2] ) || die(" Can not open file(\"$filenames[2] \").\n");
open(FIL3, $filenames[3] ) || die(" Can not open file(\"$filenames[3] \").\n");
open(FIL4, $filenames[4] ) || die(" Can not open file(\"$filenames[4] \").\n");
open(FIL5, $filenames[5] ) || die(" Can not open file(\"$filenames[5] \").\n");
open(FIL6, $filenames[6] ) || die(" Can not open file(\"$filenames[6] \").\n");
open(FIL7, $filenames[7] ) || die(" Can not open file(\"$filenames[7] \").\n");
open(FIL8, $filenames[8] ) || die(" Can not open file(\"$filenames[8] \").\n");
open(FIL9, $filenames[9] ) || die(" Can not open file(\"$filenames[9] \").\n");
open(FIL10, $filenames[10] ) || die(" Can not open file(\"$filenames[10] \").\n");
open(FIL11, $filenames[11] ) || die(" Can not open file(\"$filenames[11] \").\n");
open(FIL12, $filenames[12] ) || die(" Can not open file(\"$filenames[12] \").\n");
open(FIL13, $filenames[13] ) || die(" Can not open file(\"$filenames[13] \").\n");
open(FIL14, $filenames[14] ) || die(" Can not open file(\"$filenames[14] \").\n");
open(FIL15, $filenames[15] ) || die(" Can not open file(\"$filenames[15] \").\n");


open(OUT, "> $out_file") || die(" Can not open file(\"$out_file\").\n");

my ( $per_line, $line_num, @lines); 

$line_num = 0; 
my $fea_num = 0; 
my @temp = (); 

while (<FIL0>)
{
		$fea_num = 0;
		$line_num = $line_num +1; 
		$per_line = $_; 
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 

		
		$per_line = <FIL1>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			


		$per_line = <FIL2>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			

		$per_line = <FIL3>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			

		$per_line = <FIL4>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			

		$per_line = <FIL5>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			

		$per_line = <FIL6>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			

		$per_line = <FIL7>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			

		$per_line = <FIL8>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			

		$per_line = <FIL9>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			


		$per_line = <FIL10>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			

		$per_line = <FIL11>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			


		$per_line = <FIL12>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			


		$per_line = <FIL13>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			


		$per_line = <FIL14>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		pop(@temp); 
		print OUT join(',', @temp);  
		print OUT ",";	
		$fea_num = $fea_num + $#temp + 1; 			

		
		$per_line = <FIL15>; 	
		chop($per_line); 
		@temp = split(/,/, $per_line); 
		print OUT join(',', @temp);  
		print OUT "\n";	
		$fea_num = $fea_num + $#temp + 1; 
}
print "$line_num rows !   $fea_num values totally;"; 


close(FIL0); 
close(FIL1);
close(FIL2);
close(FIL3);
close(FIL4);
close(FIL5);
close(FIL6);
close(FIL7);
close(FIL8);
close(FIL9);
close(FIL10);
close(FIL11);
close(FIL12);
close(FIL13);
close(FIL14);
close(FIL15);

close(OUT); 