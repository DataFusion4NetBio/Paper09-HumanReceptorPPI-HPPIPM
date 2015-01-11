function [ outcombine ] = wrapper_analyzeAdd( geneID , modelchoice ) 

% Choose files 
if strcmp(modelchoice , 'posAll')
    scorelablfile = sprintf('../3testing/perlRF_Test_output/human.interestedv4.hprdreceptorlabel.ggi.%d.27fea.filled.rf.posAll.rf200treJ5.scoreLabel', geneID); 
elseif strcmp(modelchoice , 'posNoInterv4')
    scorelablfile = sprintf('../3testing/perlRF_Test_output/human.interestedv4.hprdreceptorlabel.ggi.%d.27fea.filled.rf.posNoInterv4.rf200treJ5.scoreLabel', geneID); 
elseif strcmp(modelchoice , 'posHalfInterv4')
    scorelablfile = sprintf('../3testing/perlRF_Test_output/human.interestedv4.hprdreceptorlabel.ggi.%d.27fea.filled.rf.posHalfInterv4.rf200treJ5.scoreLabel', geneID); 
    
elseif strcmp(modelchoice , 'posNo4TrIV')
    scorelablfile = sprintf('../3testing/perlRF_Test_output/human.interestedv4.hprdreceptorlabel.ggi.%d.27fea.filled.rf.posNo4ErBBTrIV.rf200treJ5.scoreLabel', geneID); 

elseif strcmp(modelchoice , 'posNo2TrV')
    scorelablfile = sprintf('../3testing/perlRF_Test_output/human.interestedv4.hprdreceptorlabel.ggi.%d.27fea.filled.rf.posNo2ILTrV.rf200treJ5.scoreLabel', geneID); 

elseif strcmp(modelchoice , 'posNoErbb4General')
    scorelablfile = sprintf('../3testing/perlRF_Test_output/human.interestedv4.hprdreceptorlabel.ggi.%d.27fea.filled.rf.posNoErbb4General.rf200treJ5.scoreLabel', geneID); 
    
else 
   disp('Wrong modelChoice !'); 
end 

featurefile = sprintf('../1features/ver4_27feaSets/human.interestedv4.hprdreceptorlabel.ggi.%d.27fea', geneID); 
listfile = sprintf('../0create_ppi_list/ver4_PPI_lists/human.interestedv4.hprdreceptorlabel.ggi.%d', geneID); 


% First measure performance 
if (( geneID ~= 2915) & ( geneID ~= 2916)  & ( geneID ~= 112744) & ( geneID ~= 84818))
    [ resultMatFile ] = measure_score( scorelablfile, geneID , modelchoice)
end 

% add geneName and geneInfo on 
humanGeneInfoFile = './ncbi_human_geneInfo/human_gene_info.ncbiGene'; 
outcombine = sprintf('./results/human.interestedv4.hprdreceptorlabel.ggi.%d.%s.outGeneInfoPPIScoreLabel27feaFile', geneID , modelchoice)
cmd = '!perl add_NamePartnerGeneInfo_4ListScoreLabelFeaf.pl '; 
% Usage: command PPIlistfile rfScoreLabelFile featureFile humanGeneInfoFile outGeneInfoPPIScoreLabelfeaFile
command = sprintf('%s %s %s %s %s %s > %s.log', cmd, listfile, scorelablfile, featurefile, humanGeneInfoFile, outcombine , outcombine) 
eval(command)

% add disease information on 
diseaseInfoFile = './geneticDisorder-GDB/GDB-genetic.fromHTML.convertRaw'; 
outcombineAdd = sprintf('%s.addDisease', outcombine )
cmd = '!perl add_geneticDisease_4ListScoreLabelFeafGeInf.pl '; 
command = sprintf('%s %s %s %s > %s.log', cmd, outcombine, diseaseInfoFile, outcombineAdd, outcombineAdd ) 
eval(command)
