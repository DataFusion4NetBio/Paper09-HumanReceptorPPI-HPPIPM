-----------------------------------------------
This directory contains the supplementary files for paper: 

Yanjun Qi[1]1, Harpreet K. Dhiman2, Neil Bhola3, Ivan Budyak4, Siddhartha Kar5, David Man2, Arpana Dutta2, Kalyan Tirupula2, Brian I. Carr5, Jennifer Grandis3,  Ziv Bar-Joseph1§ and Judith Klein-Seetharaman1,2,4§Systematic prediction of human membrane receptor interactions, PROTEOMICS (2009)


Supplementary Information see: http://www.cs.cmu.edu/~qyj/HMRI/

-----------------------------------------------

HPPIPM is the name of a software aiming for predicting human protein-protein intearctions 
by integrating multiple biological data sources based on "Random Forest" classifier. 
It provides a java based GUI interface and perl based interface from command line.  


Human membrane receptor interactome is provided as a test case for this software. 

-----------------------------------------------

If you want to read the codes, please refer to codes in this GitHUb repo: 

- ./HPPIPM

----------------------------------------------

If you just want to use the tool, please download: "HPPIPM.tar"

from 

http://www.cs.cmu.edu/afs/cs.cmu.edu/project/structure-9/PPI/HMRI/software/

==> How to use: 

tar -xvf HPPIPM.tar

then install it based on the manual: HPPIPM.manual.online.pdf


----------------------------------------------

How to run: 

$cd ***/HPPIPM/humanTaskPpi-V2-JavaWrap07-Release/
$java -jar humanTaskPpi07.jar


OR to run 
$cd ***/HPPIPM/HumanValidate-perl06/
$Perl Batch_PrePartAlHum_HprdRecptTrain.pl interested_genelist
