# Program to get gene expression co-expression (abundance) for protein pair list 
# 
# Based on the gene expression data given from NCBI GEO dataset
#
# This is a version particular for making a summary feature out (only 1 feature out)
# For a specific GDS file of the human specie
# 
# Note: 
# - in the protein pair list file, 
# - for each protein pair, we have a flag representing the class label: "1" means postive pair, "0" means random pairs
#   The out put file format: 16 gene expression feature and the last one is the class flag
#
# For example: how to use get_gene_expression_fly.pl
# qyj@PISA /cygdrive/e/qyj-E/research/12-HumanDrosophilia/dataset/Feature-Set/3expression
#$ perl  get_gene_expression_human.pl ./temp/human.bind.pospair.tempsub ./human/human.ncbiprotein.list ./human/data/GDS/GDS330.soft ./human/data/GPL/GPL91.annot.txt 0.5 ./temp/human.bind.pospair.tempsub.geneexp
#

# The list of Human GEO files we use 
# GDS330	GPL91	120
# GDS365	GPL271	66
# GDS531	GPL91	173
# GDS534	GPL96	75
# GDS596	GPL96	158
# GDS601	GPL771	42
# GDS619	GPL962	91
# GDS651	GPL570	37
# GDS715	GPL96	87
# GDS806	GPL1223	60
# GDS807	GPL1223	60
# GDS842	GPL318	44
# GDS843	GPL319	49
# GDS987	GPL96	41
# GDS1085	GPL1823	35
# GDS1086	GPL1824	38


use strict; 
die "Usage: command input_pair_list ncib_list_file percent_miss out_file_name script_dir\n" if scalar(@ARGV) < 5;
my ($pr_pair_file, $ncib_list_file, $percent_miss, $out_file_name, $script_dir) = @ARGV;

my @geneexp_files = ("GDS330", "GDS365", "GDS531", "GDS534", "GDS596", "GDS601", "GDS619", "GDS651", "GDS715", "GDS806", "GDS807", "GDS842", "GDS843", "GDS987", "GDS1085", "GDS1086");
my @gpl_files =      ("GPL91", "GPL271", "GPL91", "GPL96",   "GPL96", "GPL771", "GPL962", "GPL570",  "GPL96", "GPL1223", "GPL1223", "GPL318", "GPL319", "GPL96", "GPL1823", "GPL1824");

my $data_dir = '/human/data/'; 

my ($i, $gene_expression_file, $gpl_file); 
for ($i = 0; $i <= $#geneexp_files ; $i ++)
{
	print "\n- ".$geneexp_files[$i]."\n"; 
	my $cmdPre = "perl $script_dir/get_gene_expression_human.pl  "; 
	
	my $temp = $data_dir."GDS/".$geneexp_files[$i].".soft"; 
	my $tempgpl = $data_dir."GPL/".$gpl_files[$i].".annot.txt"; 
	
	$gene_expression_file = "$script_dir$temp"; 
	$gpl_file = "$script_dir$tempgpl"; 
	my $cur_coexp_file = $out_file_name.'.'.$geneexp_files[$i].".coexp"; 

	my $cmd = $cmdPre." ".$pr_pair_file." ".$ncib_list_file." ".$gene_expression_file." ".$gpl_file." ".$percent_miss." ".$cur_coexp_file ; 
	
	print "$cmd\n"; 
	system($cmd); 
}


my $cmdPre = "perl $script_dir/Combine16singleFeatures.pl"; 
my $cmd = $cmdPre; 

# $cur_coexp_file = $out_file_name.'.'.$geneexp_files[$i].".coexp"; 
$cmd = $cmd." ".$out_file_name." ".$out_file_name; 
print "\n$cmd\n"; 
system($cmd); 
