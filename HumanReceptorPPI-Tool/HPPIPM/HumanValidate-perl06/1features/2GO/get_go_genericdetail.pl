# Program to Extract gene ontology feature (detailed style) for protein pair list  for a specific hierarchy
# There is an input parameter to choose which hierarchy to use [F, P, C]
# 
#
# GO Slim Generic June 2005 Version
# The out put file format:  go features separated by ",", the last one is the class flag
#
# 
# For example: component
# $ perl get_go_genericdetail.pl ./temp/human.bind.pospair.tempsub gene_association.human.slim C ../train_gold/human/human.ncbiprotein.list goslim_generic.comp.go ./temp/human.bind.pospair.tempsub.go
# - 32 go slim entries/features we consider !
# - Size of NCBI_protein_gene_list:  161561.
# - Size of genes having go_association mapping info:  10110.
#
# For example: function
# $ perl get_go_genericdetail.pl ./temp/human.bind.pospair.tempsub gene_association.human.slim F ../train_gold/human/human.ncbipotein.list goslim_generic.func.go ./temp/human.bind.pospair.tempsub.go
# - 32 go slim entries/features we consider !
# - Size of NCBI_protein_gene_list:  161561.
# - Size of genes having go_association mapping info:  11154.
#
# For example: Process
# $ perl get_go_genericdetail.pl ./temp/human.bind.pospair.tempsub gene_association.human.slim P ../train_gold/human/human.ncbiprotein.list goslim_generic.proc.go ./temp/human.bind.pospair.tempsub.go
# - 49 go slim entries/features we consider !
# - Size of NCBI_protein_gene_list:  161561.
# - Size of genes having go_association mapping info:  10810.


# For example: for fly
# $ perl  get_go_genericdetail.pl ./temp/fly.bind.pospair.tempsub gene_association.fly.slim F ../train_gold/fly/fly.ncbiprotein.fbid.list goslim_generic.func.go ./temp/fly.bind.pospair.tempsub.funcgo
#- 32 go slim entries/features we consider !
#- Size of NCBI_protein_gene_list: (if fly, then size of those genes having FBids ) 13445.
#- Size of genes having go_association mapping info:  8225.



use strict; 
die "Usage: command protein_pair_list go_association_file go_choice_tag [F, P, C] gene_list_file go_slim_file out_name\n" if scalar(@ARGV) < 5;

my ($int_file, $map_file, $choice, $list_file, $slim_go_file, $out_file) = @ARGV;


#--------------------- read in the go_slim ontologies  -------------------------------

my %slim_1st = (); 
my %slim_2nd = (); 
my $flag_2ndlevel = 0; 
my $cur_parent = ""; 

open(SLM, $slim_go_file) || die(" Can not open file(\"$slim_go_file\").\n");
while (<SLM>)	
{
	chomp $_; 
	next if /^!/;			#ignore comments !
	next if /^$/; 			#ignore blank lines
	
	my $curline = $_; 
	
 	if (($curline =~ /^\s*-/ ) && ( $flag_2ndlevel == 0))
 	{ 
 		$flag_2ndlevel = 1; 
 	}
 	if ( (!($curline =~ /^\s*-/ )) && ( $flag_2ndlevel == 1))
 	{ 
 		$flag_2ndlevel = 0; 
 	}
 	
 	if ( $flag_2ndlevel == 0 )
 	{
	 	my @temp = split(/%|</, $curline); 	
 		my $go_label = $temp[1]; 
		my @goIDs = $go_label =~ /GO:[0-9]+/gi; 		
		
		my $cur; 
		foreach $cur (@goIDs)		
		{
			$slim_1st{"$cur"} =  1; 	
		}
		$cur_parent = $goIDs[0]; 
 	}
	else {
	 	my @temp = split(/-|%|</, $curline); 	
 		my $go_label = $temp[1]; 
		my @goIDs = $go_label =~ /GO:[0-9]+/gi; 		
		my $cur; 
		foreach $cur (@goIDs)		
		{
			$slim_2nd{"$cur"} =  $cur_parent;
		}
	} 	
}
close(SLM);

my $slim_num = scalar keys %slim_1st; 
print "\n- $slim_num go slim entries/features we consider ! \n"; 

my $key; 
foreach $key (sort (keys(%slim_1st)))
{
        #print "$key\n";
}



#--------------------- read in the gene protein list file  -------------------------------

open(LIS, $list_file) || die(" Can not open file(\"$list_file\").\n"); 

my %id2geneid = (); 
while (<LIS>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	# File format: ## proGI	proAcc	geneID	geneSym	FBID
	my @line = split('\t', $_);
	if ( $list_file =~ /fly/)  
	{
		if ( $line[4] ne "" )
		{
			$id2geneid{"$line[4]"} = $line[2]; 
		}
	}
	else {
		if ( $line[1] ne "" )
		{
			$id2geneid{"$line[1]"} = $line[2]; 
		}
				
	}
}

close(LIS); 

print "- Size of NCBI_protein_gene_list: (if fly, then size of those genes having FBids ) " . keys( %id2geneid ) . ".\n";


#--------------------- read in the go_slim_association file  -------------------------------

open(MAP, $map_file) || die(" Can not open file(\"$map_file\").\n"); 

my %gene_map_go = (); 

while (<MAP>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines

	my @map_line = split('\t', $_);

	my $oid = $map_line[1]; 
	my $geneid = $id2geneid{"$oid"}; 
	
	my $goid  =  $map_line[4];  
	my $aspect  = $map_line[8]; 
	
	my %goid_ary = (); 
	if (( $aspect eq $choice )&& (defined $geneid ))	
	{
		if (defined $gene_map_go{"$geneid"})
		{
			${ $gene_map_go{"$geneid"} }{ "$goid" } =   1; 
		}
		else 
		{
			$goid_ary{"$goid"} = 1; 
			$gene_map_go{"$geneid"} = \%goid_ary; 
		}
	}
}

close(MAP);
print "- Size of genes having go_association mapping info:  " . keys( %gene_map_go ) . ".\n";




#--------------------- Begin to process the yeast_int set and find if the pair in go_slim ontologies -------------------------------
# Here we only use slim all to the second levels 
# For each of them, we would have one feature. The feature would be a 2-value category variable... 
# 1 means the pair genes both have this func/comp/proc. 0 means otherwise


open(IN, $int_file) || die(" Can not open file(\"$int_file\").\n"); 
open(OUT, "> $out_file") || die(" Can not open file(\"$out_file\").\n");

while (<IN>)	
{
	chomp $_; 
	next if /^#/;			#ignore comments
	next if /^$/; 			#ignore blank lines
	# input format: 
	# # proGI1	geneID1	proGI2	geneID2	flag
	
	my ($progi1, $geneid1, $progi2, $geneid2, $flag) = split('\t', $_);

   	my $temp_score = 0; 
   	if ((defined $gene_map_go{"$geneid1"}) && (defined $gene_map_go{"$geneid2"})) 
   	{
			my %func1 = %{ $gene_map_go{"$geneid1"} }; 
			my %func2 = %{ $gene_map_go{"$geneid2"} }; 
			my $key; 	

			# map the GO id in the second level into the first leave 
			for $key (sort( keys %func1 ))
			{
				if (defined $slim_2nd{"$key"})	
				{
					my $temp = $slim_2nd{"$key"}; 
					$func1{"$temp"} =  1; 
				}
			}
			for $key (sort( keys %func2 ))
			{
				if (defined $slim_2nd{"$key"})	
				{
					my $temp = $slim_2nd{"$key"}; 
					$func2{"$temp"} =  1; 
				}
			}



			for $key (sort( keys %slim_1st )) 
			{
				# unknown case would not be mapped into one feature
				if (($key ne "GO:0000004") && ($key ne "GO:0005554") && ($key ne "GO:0008372"))
				{
					my $temp1 = $func1{"$key"}; 
					my $temp2 = $func2{"$key"}; 
					if ((defined $temp1 )&&( defined $temp2 ))
						{ print OUT "1,"; }
					else 
						{ print OUT "0,";}
				}
    			}
   	} 
     	else {
     		my $i; 
     		for ( $i = 0; $i < $slim_num - 1 ; $i++ )
			{ print OUT "-100,"; }
     	}
   	print OUT "$flag\n"; 
   
}

close(IN); 
close(OUT);
