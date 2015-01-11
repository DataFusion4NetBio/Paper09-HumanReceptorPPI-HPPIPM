# This is a changed version of program RF4Tree_classify_valueout.pl
#
# Program to run RandomForest4_qyj's savedForest based on RF4's runforest() functions
# Input is a test set of feature points
# Output performance confusion matrix and the approximately error rate 
# also we would output the real value prediction for each test point int a output file for further using

# Two of the input parameters are to specify which range of RF trees we would use for your data points
# Totally range of RFtrees are: [0, 2*$jbt -1]
# Range of RFtrees used are: [$start_tree_no, min(2*$jbt-1, $end_tree_no)]
# 
# Usually for a tree labeled $jbt trees, it has 2*$jbt trees actually
# For our raw data, we should use the the first [0, $jbt] trees to generate nodes, classlables ...
# For this version, we would only use its classify value output
# 
# But for tree: qyj_saveforest-Train01.15fea-200tre.. it is created by combined two 100trees...
# So for it and raw input , we should use [0, 99] and [ 200, 299 ]
#
# perl command ./temp/temp.test.txt qyj_saveforest-Train01.15fea-200tre 0 99 -100 ./temp/temp.result ./temp.out
# Also in this version, we do not consider missing value in the feature set 

use strict; 

die "Usage: command input_test_set RF4_savedForest start_tree_no end_tree_no missing_code out_result_file out_prediction_file\n" if scalar(@ARGV) < 7;
my ($input_test, $RF4_forest, $start_tree_no, $end_tree_no,$missing_code, $out_result, $out_predict) = @ARGV;

open(INPUT_TEST, $input_test) || die(" Can not open file(\"$input_test\").\n"); 
open(RF4_FOREST, $RF4_forest) || die(" Can not open file(\"$RF4_forest\").\n"); 

# -------------------- Read in the input_test set --------------------
my ($per_line, @input_test_lines, @input_test_set, $nsample, $dim, @num_each_class, @cl, @cl_old);  

@input_test_lines = <INPUT_TEST>; 

$nsample = scalar(@input_test_lines); 
my $n = 0; 
@input_test_set = @cl = @num_each_class = (); 
for ( $n =0; $n < $nsample; $n ++)
{
	my @current_line = split(/\s+/, $input_test_lines[$n]); 
	$input_test_set[$n] = \@current_line; 
	
	# -------------      the last column of @input_test_set means the class label line
	# The labels are in three categories: 1 pos, 3 negative, 2 random
	# Sine this is the "pos vs. rand" RF tree classifier, we would treat neg 3 as random 2 as generated. 
	# 
	$dim = scalar(@current_line); 	
	$cl[$n] = $input_test_set[$n][$dim-1 ]; 
	$cl_old[$n] = $cl[$n]; 
	if ($cl[$n] == 3)
		{$cl[$n] = 2; }
	$num_each_class[$cl[$n]-1] = $num_each_class[$cl[$n]-1] + 1;
}

# -----------  The following arrays would be used for calculation of the classification error rate 
# $@countr = [nclass, nsample], $@tmiss = [nclass]
my (@counttr, @tmiss, @input_test_nodex, @input_test_jtr, $t); 
@counttr = @tmiss = (); 

# ------------- Array @input_test_nodex would contain the output nodeposition file' content .. we initialze here first
# ------------- Array @input_test_jtr would contain the output each tree classlable file' content .. we initialze here first
@input_test_nodex = (); 
@input_test_jtr = (); 

# ---------------------------------------------------------------------
# -------------      read in the RF4_savedForest first several infor lines
#                    based on RF4 code's runforest() function
# ---------------------------------------------------------------------
my ($mdim, $nsampleTr, $nclass, $nrnodes, $jbt, @cat, @fill, $maxcat, $temp );

# first line: comments
$per_line = <RF4_FOREST>;

# second line
$per_line = <RF4_FOREST>;
($temp, $mdim, $nsampleTr, $nclass, $nrnodes, $jbt, $maxcat) = split(/\s+/, $per_line);  

# third line : dimension if category feature or not 
$per_line = <RF4_FOREST>;
@cat = split(/\s+/, $per_line);  
($temp, @cat)= @cat; 

# IN this version, we do not have the missing value related code 
# four line : read in quick missing value alternative for each variable 
# $per_line = <RF4_FOREST>;
# @fill = split(/\s+/, $per_line);  
#($temp, @fill) = @fill; 

# Initialize the two arrays used for calculating error rate
# $@countr = [nclass, nsample], $@tmiss = [nclass]
for ($t=0; $t<$nclass; $t++)
{ 
	$tmiss[$t] = 0; 
	my @tp_countr = (); 
	$counttr[$t] = \@tp_countr; 
	for ( $n =0; $n < $nsample; $n ++)
		{$counttr[$t][$n] = 0; }
}

# IN this version, we do not have the missing value related code 
# substitute missing value in test set into these filling values just read in ( mean of each dimension)
my ($i, $j); 
# for ( $i =0; $i<$nsample; $i ++)
# {
# 	for ( $j =0; $j < $mdim; $j ++)
# 	{
# 		if ($input_test_set[$i][$j] == $missing_code)	
# 		{	
# 			$input_test_set[$i][$j] = $fill[$j]; 
# 		}
# 	}
# }


# ---------------------------------------------------------------------
# -------------      read in the RF4_savedForest  forests
#                    based on RF4 code's runforest() function
# ---------------------------------------------------------------------

my ($k,  $ndbigtree, @nodestatus, @bestvar, @treemap1, @treemap2, @nodeclass, @xbestsplit, @tnodewt, @nbestcat); 
my ($err, $cmax, $jmax, @jestr );     # arrays used for recording the error rate and resulting prediction matrix

# read each tree ( $jbt trees totally) .. and also process on the test input set
for ($i = 0; $i < (2*$jbt); $i++) 
{
    last if ($i > $end_tree_no); 
    	
    #each tree's first line means the number of $ndbigtree
    $per_line = <RF4_FOREST>; 
    chomp $per_line; 
    my $current_tree_no = 0; 
    ($temp, $current_tree_no, $ndbigtree) = split(/\s+/, $per_line);  
    print "Tree: $current_tree_no,  $ndbigtree\n"; 
    
    @nodestatus = @bestvar = @treemap1 = @treemap2 = @nodeclass = @xbestsplit = @tnodewt = @nbestcat = (); 	    
    for ( $j = 0; $j < $ndbigtree; $j ++)
    {
    	$per_line = <RF4_FOREST>;
    	chomp $per_line; 
    	my @line_items = split(/\s+/, $per_line); 	
	($temp, @line_items) = @line_items; 

	# nodestatus(k)=1 if the kth node has been split.
        # nodestatus(k)=2 if the node exists but has not yet been split, 
	# nodestatus(k)=-1 of the node is terminal.	
	$nodestatus[$j] = $line_items[1]; 
	$bestvar[$j]= $line_items[2];
     	$treemap1[$j] = $line_items[3];
     	$treemap2[$j] = $line_items[4]; 
     	$nodeclass[$j] = $line_items[5];
     	$xbestsplit[$j] = $line_items[6];
     	$tnodewt[$j] = $line_items[7];
     	
	my @current_nbestcat =(); 
	for ( $k=0; $k < $maxcat; $k++)
	{ 	$current_nbestcat[$k] = $line_items[ 8 + $k];
	}
	$nbestcat[$j] = \@current_nbestcat; 	
    }    

    if (($i >= $start_tree_no) &&  ($i <=$end_tree_no))
    {
    	# -------------    for each tree, then process all test points  -------------------------------
    	# -------------    This step gets all points' node position on this tree => nodex() -----------
    	# -------------    This step based on RF4 code's  testreebag() function -----------------------
    	
    	# arrary: current_jbt_nodex contains the node position within this tree of those test points
    	# arrary: current_jbt_jtr contains predicted label for that leaf within this tree of those test points
    	my @current_jbt_nodex = (); 
    	my @current_jbt_jtr = (); 
    	for ( $n=0; $n < $nsample; $n++)
    	{ 	
    		#- For a J-class problem, the class to be numbered 1,2,..,J
    		#- For an L valued categorical, it expects the values numbered 1,2,...,L 
    		my  $kt = 0;
	    	for ( $k = 0; $k < $ndbigtree; $k ++)
	    	{
			if ($nodestatus[$kt] == -1)	
			{
				$current_jbt_jtr[$n] = $nodeclass[$kt]; 
				$current_jbt_nodex[$n] = $kt; 
				last; 
			}
			
			# $mm contains the best split variable of this node
			# The following to choose which branch to go for the current node
			my $mm = $bestvar[$kt] -1 ; 
			if ($cat[$mm ] == 1)
			{
				if ($input_test_set[$n][$mm ] <= $xbestsplit[$kt])
				{
					$kt = $treemap1[$kt] -1; 
				}	
				else {
					$kt = $treemap2[$kt] -1;
				}
			}	
			else {
				my $jcat = int($input_test_set[$n][$mm]) -1 ; 	
				if ($nbestcat[$kt][$jcat] == 1)
				{	
					$kt = $treemap1[$kt] -1 ;
				}
				else {
					$kt = $treemap2[$kt] -1;
				}
			}	
		}
    	}
    	#$input_test_nodex[$i-$start_tree_no] = \@current_jbt_nodex; 
    	#$input_test_jtr[$i-$start_tree_no] = \@current_jbt_jtr;

    	# -------------      we make some preparation calculation for    --------------------
	# 			compute error rate to verify with the initial RF result        
	#$@countr = [nclass, nsample], $@tmiss = [nclass]
    	#my ($pp, $qq);
    	#for ($pp =0; $pp < $nclass; $pp ++ ) 
    	#{
    	#	$tmiss[$pp] = 0; 
    	#	for ( $qq=0; $qq < $nsample; $qq++)    
    	#	{	$counttr[$pp][$qq] = 0;  }
    	#}
    
	# the array @counttr contains the scores of each test example for each possible class 
    	for ( $n=0; $n < $nsample; $n++)
    	{
	    	$counttr[$current_jbt_jtr[$n]-1][$n] = $counttr[$current_jbt_jtr[$n]-1][$n] + $tnodewt[$current_jbt_nodex[$n]]; 
    	}
    
    	# The following are based on RF's func: comperrts(counttr,cl,nsample,nclass,errtr, tmiss,nc,jest,label)
    	$err = 0; 
    	@jestr = (); 	# contain the predicted each point's class label
    	@tmiss = (); 	# contain the num_error predicted points of each class
    	for ( $n=0; $n < $nsample; $n++)
	{
	    	$cmax = -1; 
    		$jmax = -1; 
    		for ($j =0; $j < $nclass; $j ++ )
    		{
    			if ($counttr[$j][$n] > $cmax)
    			{
    				$jmax = $j; 
    				$cmax = $counttr[$j][$n]; 
    			}
    		}
		
		# the array @jestr contains the predicted class label for each test example     		
    		$jestr[$n] = $jmax + 1; 	# due to the class name is from 1 ... j 
    	
    		if ( $jestr[$n] != $cl[$n]) 
    		{
			$tmiss[$cl[$n]-1] = $tmiss[$cl[$n]-1] + 1; 
			$err = $err + 1; 
    		}
    	}
        $err = $err / $nsample; 
    
    	my $look_freq = 10; 
    	if ( $i % $look_freq == 0 )
    	{
    		print "tr$i, "; 
	    	print "err: $err; Class: ";
	    	for ($j =0; $j < $nclass; $j ++ )
	    	{
    			$tmiss[$j] = $tmiss[$j]/($num_each_class[$j] + 0.0000000000000000001); 
    			print "$tmiss[$j],	"; 
    		}    	
    		print "\n"; 
    	}
    }
}

my @mtab = (); 
for ($j =0; $j < $nclass; $j ++ )
{
	for ($i =0; $i < $nclass; $i ++ )	
	{ 
		$mtab[$i][$j] = 0; 
	}
}

# the array @counttr contains the scores of each test example for each possible class 
# the array @jestr contains the predicted class label for each test example 
for ( $n=0; $n < $nsample; $n++)
{
	if ($jestr[$n] > 0 )
	{
		$mtab[$cl[$n]-1 ][$jestr[$n] -1 ] = $mtab[$cl[$n]-1 ][$jestr[$n] -1 ] + 1; 
	}
}


print "\nTest Set: \n "; 
for ($j = 0; $j < $nclass; $j ++ )
{	print "$num_each_class[$j], 	" ; }
print "\n ---->  true class \n	  ";
for ($j =1; $j <= $nclass; $j ++ )
{	print "   $j  " ; }
print "\n";


# OUTput contains each trees's error and each class's error rate
# print OUT "confusion_matrix";
open(OUTRES, "> $out_result") || die(" Can not open file(\"$out_result\").\n");

for ($j =0; $j < $nclass; $j ++ )
{
	my $index = $j+1;
   	print "$index,	"; 
   	for ($i =0; $i < $nclass; $i ++ )
   	{
   		print "  $mtab[$i][$j]";
   		print OUTRES "$mtab[$i][$j] "
   	}
	print "\n"; 
}
print OUTRES "\n"; 
close(OUTRES); 


#--- destroy some variables
@input_test_lines = (); 
@nodestatus = @bestvar = @treemap1 = @treemap2 = @nodeclass = @xbestsplit = @tnodewt = @nbestcat = ();


# Totally range of RFtrees are: [0, 2*$jbt -1]
# Range of RFtrees used are: [$start_tree_no, min(2*$jbt-1, $end_tree_no)]

my $used_trees = 2*$jbt - 1 ; 
print " \n ----------------------------------------------- \n"; 
print " Total RFtrees: [  0 , $used_trees] \n"; 

if ( $end_tree_no < $used_trees)
	{ $used_trees = $end_tree_no}; 
print " Used RFtrees: [  $start_tree_no , $used_trees] \n"; 
$used_trees =  $used_trees - $start_tree_no;	


# -------------      output nodex(num_test_points, num_trees) array to the out_file    --------------------
#  @$input_test_nodex  [ " number of trees used", $nsample]

#open(OUTNOD, "> $out_nodes") || die(" Can not open file(\"$out_nodes\").\n");
#for ( $i = 0; $i < $nsample; $i++)
#{
#	for ( $j = 0; $j <= $used_trees; $j++)
#	{
#		if ( $j == 0 )
#			{ print OUTNOD "$input_test_nodex[$j][$i]"; }
#		else 
#			{ print OUTNOD ",$input_test_nodex[$j][$i]"; }		
#	}
#	print OUTNOD ",$cl_old[$i]\n"; 
#}
#close(OUTNOD); 


# -------------      output jtr (num_test_points, num_trees) array to the out_file    --------------------
#  @$input_test_jtr  [ " number of trees used", $nsample] contains the class label within each tree

#open(OUTCLB, "> $out_classlabel") || die(" Can not open file(\"$out_classlabel\").\n");

#for ( $i = 0; $i < $nsample; $i++)
#{
#	for ( $j = 0; $j <= $used_trees; $j++)
#	{
#		if ( $j == 0 )
#			{ print OUTCLB "$input_test_jtr[$j][$i]"; }
#		else 
#			{ print OUTCLB ",$input_test_jtr[$j][$i]"; }		
#	}
#	print OUTCLB ",$cl_old[$i]\n"; 
#}
#close(OUTCLB); 


# output the prediction value ( each class' contribution ratio summing within all trees) into a file for each test point
#  @counttr  [ " number of classes ", $nsample] contains the class sum-weight for each test point

# In origianl RF file: 	write(4,'(3i5,50f10.3)') n,clts(n),jests(n), (qts(j,n), j=1,nclass)
# qts(j,n)=countts(j,n)/jbt

open(OUTPRE, "> $out_predict") || die(" Can not open file(\"$out_predict\").\n");
for ( $i = 0; $i < $nsample; $i++)
{
	my $curIndex = $i + 1; 
	print OUTPRE "$curIndex	$cl_old[$i]	$jestr[$i]";
    	for ($j =0; $j < $nclass; $j ++ )
    	{
    		my $curValue = $counttr[$j][$i]/$jbt; 
		print OUTPRE "	$curValue"; 
	}
	print OUTPRE "\n"; 
}
close(OUTPRE);

close(INPUT_TEST); 
close(RF4_FOREST); 