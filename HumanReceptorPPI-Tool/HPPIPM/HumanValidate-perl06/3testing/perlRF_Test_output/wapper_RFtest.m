%function [ resultingPNsocrefile ] = wapper_RFtest( geneID, modelChoice  ) 
function [ resultingPNsocrefile ] = wapper_RFtest( geneID, modelChoice  ) 

% Choose RF model file 
if strcmp(modelChoice , 'posAll')
   modelfile = '../2training/27fea-model/hprdreceptor.valiTrain.posAll.27feafill.rfJ5.200trees.changed'; 
   resultSufix = 'posAll.rf200treJ5'; 
   
elseif strcmp(modelChoice , 'posNoInterv4')
   modelfile = '../2training/27fea-model/hprdreceptor.valiTrain.posNoInterestV4.27feafill.rfJ5.200trees.changed'; 
   resultSufix = 'posNoInterv4.rf200treJ5';    
   
elseif strcmp(modelChoice , 'posHalfInterv4')
   modelfile = '../2training/27fea-model/hprdreceptor.valiTrain.posHalfInterev4.27feafill.rfJ5.200trees.changed'; 
   resultSufix = 'posHalfInterv4.rf200treJ5';

elseif strcmp(modelChoice , 'posNo4TrIV')
   modelfile = '../2training/27fea-model/hprdreceptor.valiTrain.posNo4TrIV.27feafill.rfJ5.200trees.changed'; 
   resultSufix = 'posNo4ErBBTrIV.rf200treJ5';

elseif strcmp(modelChoice , 'posNo2TrV')
   modelfile = '../2training/27fea-model/hprdreceptor.valiTrain.posNo2TrV.27feafill.rfJ5.200trees.changed'; 
   resultSufix = 'posNo2ILTrV.rf200treJ5';
   
elseif strcmp(modelChoice , 'posNoErbb4General')
   modelfile = '../2training/27fea-model/hprdgeneral.valiTrain.posNoErbb4.27feafill.rfJ5.200trees.changed'; 
   resultSufix = 'posNoErbb4General.rf200treJ5';
   
else 
   disp('Wrong modelChoice !'); 
end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we apply the perl_RF_test script

inputTestSetName = sprintf('human.interestedv4.hprdreceptorlabel.ggi.%d.27fea.filled.rf', geneID); 
inputDir = '../1features/ver4_27feaSets/'; 
inputfile = sprintf('%s%s', inputDir, inputTestSetName ); 
outputDir = './perlRF_Test_output/'; 
outpre = sprintf('%s%s.%s', outputDir, inputTestSetName , resultSufix); 

% Usage: command input_test_set RF4_savedForest start_tree_no end_tree_no missing_code out_result_file out_prediction_file
cmd = '!perl RF4Tree_classify_valueout_nomissing_Dec05.pl '; 
para = ' 0 199 -100 '

commond = sprintf('%s %s %s %s %s.predict %s.out  > %s.rflog ', cmd, inputfile , modelfile, para, outpre, outpre, outpre) 
eval(commond);     



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process scores 
cmd = '!perl process_RFtestOut.pl '; 
resultingPNsocrefile = sprintf('%s.scoreLabel', outpre);
commond = sprintf('%s %s.out %s > %s.pnlog ', cmd, outpre, resultingPNsocrefile, outpre) 
eval(commond);     
