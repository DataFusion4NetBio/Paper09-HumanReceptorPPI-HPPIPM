/*
 * humanPPIRunCommand.java
 *
 * Created on July 5, 2006, 5:11 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */


package humanFPPI;


import java.util.*;
import java.io.*;



/**
 *
 * @author qyj
 */
public class humanPPIRunCommand {

    String localPathfPost = "/humanPPIsoftDirPara.txt";    
    String localPath = ""; 

    String ncbiProteinFileName = "ncbi_info/human.ncbiprotein.list"; 
    String ncbiGeneInfoFileName = "ncbi_info/human_gene_info.ncbiGene"; 

    String RequestGeneFilePre = "requestGeneFile/requestGeneFile"; 
    String getRequestGeneInfoPerl = "requestGeneFile/getGeneInfo.pl";         
    
    String [] creatPPIlistPerl = {"0create_ppi_list/makeggpair_4ncbiplist_hpbdlable.pl",  
                                  "0create_ppi_list/makeggpair_4curGenelist_hpbdlable.pl", 
                                  "0create_ppi_list/makeggpair_4curTasklist_hpbdlable.pl"};     
    String posPPIfile = "0create_ppi_list/human.hprd.posPair"; 
    String outPPairfileDir = "0create_ppi_list/PPI_lists/"; 
    String outPPairfilePre = "human.hprdlabel"; 
    String [] outPPairfilePreChange = {".allhuman.ggi", ".withCurGeneList.ggi", ".withCurTaskList.ggi"}; 
    String outPPairfilePreFull = ""; 
    
    String generateFeaCurDir = "1features/";
    String FeaFileDir = "1features/train_gold/27feaSets/";    
    String generateFeaPerl = "Batch_featureExtractHumanFull.dirPara.27feafill.Rf.pl";
    
    String testDir = "3testing/"; 
    String testPerl = "3testing/RF4Tree_classify_valueout_nomissing_Dec05.pl"; 
    String testModelPara = " 0 199 -100 ";     
    public String testModelFile = "2training/27fea-model/hprdreceptor.valiTrain.posAll.27feafill.rfJ5.200trees.changed"; 
    public String curTask = "receptor"; 
    public String testOutputPre = "3testing/perlRF_Test_output/human.hprdlabel." + curTask ;
    String testOutputSuffix = "27feafil.Rf"; 
    
    String resultTransferPerl = "3testing/process_RFtestOut.pl "; 
    
    public String outcombinePre = "4analyze/results/human.hprdlabel." + curTask + ".RFall.ScoreLabelFeaGeneInfo";
    String addGeneInfoPerlcmd = "4analyze/add_NamePartnerGeneInfo_4ListScoreLabelFeaf.pl "; 

    String diseaseInfoFile = "ncbi_info/geneticDisorder-GDB/GDB-genetic.fromHTML.convertRaw"; 
    String adddiseaseInfoPerlcmd = "4analyze/add_geneticDisease_4ListScoreLabelFeafGeInf.pl ";     
    
    Hashtable  ncbiProteinGeneIDList = new Hashtable();
    Hashtable  ncbiProteinGeneNameList = new Hashtable();
    Hashtable  ncbiGeneId2ProteinList = new Hashtable();

    String newTrainFeaDir = "5taskListTrain/"; 
    String generateNewTrainPerl =  "Batch_generateTrain_4inputTaskGeneList.pl"; 
    String outnewTrainRFfillFile = "5taskListTrain/trainingTaskRF/human.hprdl.task.27feafilrf"; 
    
    String reTrainPerl = "5taskListTrain/change_RF_codeRun.pl"; 
    String iniRFcode = "5taskListTrain/RF4_cmdLearnPre_200tres.27feaJ3.f"; 
    String tempTestFile = "5taskListTrain/temp.test.fillrf"; 
    String outRFcodepre = "5taskListTrain/trainingTaskRF/RF4_cmdLearnPre_200tres.27feaJ3.task";
    String newRFmodel = "5taskListTrain/trainingTaskRF/human.hprd.task.27fea.fillrf.200treesJ3"; 
    
    
    /** Creates a new instance of humanPPIRunCommand */    
    public humanPPIRunCommand(  ) {         
        String path = System.getProperty("user.dir");
        String localPathf = path + localPathfPost ; 
        System.out.println("File about the perl program directory location:" + localPathf);
        readinLocalPath(localPathf ); 
    }
                
    /** Creates a new instance of humanPPIRunCommand */
    // this version we got the perl program location from an input para string
    //String localPathf = "/humanPPIsoftDirPara.txt";     
    public void readinLocalPath( String localPathf ) {
        //readin the location file for the main location of the software 
        //localPathf into variable localPath 
        try 
        {
            BufferedReader  r = new BufferedReader(new FileReader(localPathf));
            localPath = r.readLine(); // first comment line 
            localPath.trim();
            System.out.println("The humanPPIPerlsoftware location: " + localPath );
        }
        catch (IOException e) 
        { System.err.println("Can't read file: " + e.getMessage()); }                
    }

    
    
    
    
    public Vector readRequestGeneListFile(String inputRequestGeneListFile) {
        Vector geneIDarray = new Vector();
        String[] words;         
        int curID; 
        int index = 0; 
        // The input file format: ##proGI	proAcc	geneID	geneSym
        BufferedReader in = null; 
        try {           
            in = new BufferedReader( new FileReader(inputRequestGeneListFile));        
            String line = null; //not declared within while loop
            line = in.readLine();   // First line is the comment line; 
            while ((line = in.readLine()) != null)
            {
                words = line.split("\t"); 
                curID = Integer.parseInt(words[2]); 
                geneIDarray.add(index, curID); 
                index ++; 
            }            
        }  
        catch (FileNotFoundException ex) {
            ex.printStackTrace();
        }
        catch (IOException ex){
            ex.printStackTrace();
        }
        finally {
            try {
                if (in!= null) {
                    in.close();
                }
            }  catch (IOException ex) {
                ex.printStackTrace();
            }
        }      
        return(geneIDarray);         
    }
    
    
    /** generate the new training used RF-fill format feature file */
    public String generateNewTrainFeaFile(String taskInputListFile)   {
        if ( TestFileExist(taskInputListFile) == false )
        {   return("Required task InputList File Not exist !"); }

        String perlCommand = "perl " + localPath + newTrainFeaDir + generateNewTrainPerl;
        String humanProteinList = localPath + ncbiProteinFileName;        
        String cmd = perlCommand + " " + taskInputListFile + " " + localPath + newTrainFeaDir + " " + humanProteinList + " " + localPath + outnewTrainRFfillFile; 
        try {
            System.out.println("\n-----------------------------------------------------------------------------------------------\n");                                    
            System.out.println(cmd);
            Process p = Runtime.getRuntime().exec(cmd); 
            // read the output from the command
            String s = null;            
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            System.out.println("Here is the standard output of the command:\n");
            
            String logFile = localPath + outnewTrainRFfillFile + ".log"; 
            FileWriter out = new FileWriter(new File(logFile));                        
            out.write(cmd + "\n");
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
                out.write(s + "\n");
            }           
            out.close(); 
        }
        catch (IOException e) { 
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        }         
        return( "./" + outnewTrainRFfillFile );        
    }    
    
    /** re-train RF model  */    
    public String reTrainRFmodel(  )   {
        String curlocalPath = localPath; 
        String perlCommand = "perl " + curlocalPath + reTrainPerl ;
        String oldRFcodeFile = curlocalPath + iniRFcode; 
        String inputTrainFile = curlocalPath + outnewTrainRFfillFile; 
        String inputTestFile =  curlocalPath +  tempTestFile; 
        String outRFcodeFilePre =  curlocalPath + outRFcodepre; 
        String outRFmodelfile = curlocalPath + newRFmodel; 
        String cmd = perlCommand + " " + oldRFcodeFile + " "  + inputTrainFile + " " + inputTestFile + " " + outRFcodeFilePre + ".f  " + outRFcodeFilePre + ".exe " + outRFmodelfile + " " + outRFmodelfile + ".imp"; 
        try {
            System.out.println("\n-----------------------------------------------------------------------------------------------\n");                                    
            System.out.println(cmd);
            Process p = Runtime.getRuntime().exec(cmd); 
            // read the output from the command
            String s = null;            
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            System.out.println("Here is the standard output of the command:\n");
            
            String logFile =  outRFmodelfile + ".log"; 
            FileWriter out = new FileWriter(new File(logFile));                        
            out.write(cmd + "\n");
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
                out.write(s + "\n");
            }           
            out.close(); 
        }
        catch (IOException e) { 
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        }         
        return( outRFmodelfile );        
    }    

    
    /** update the system used RF model  */    
    public String updateModelTaskName( String taskName )   
    {
        testModelFile = newRFmodel; 
        testOutputPre = "3testing/perlRF_Test_output/human.hprdlabel." + taskName ;
        outcombinePre = "4analyze/results/human.hprdlabel." + taskName + ".RFall.ScoreLabelFeaGeneInfo";        
        return(testOutputPre); 
    }    
        
            
    /** Read in the ncbi_human_list file */
    public void readinNCBIproteinList()   
    {
        String fileN = localPath + ncbiProteinFileName;
        int curID; 
        String curName; 
        String[] words; 
        String protein; 

        BufferedReader in = null; 
        try {           
            in = new BufferedReader( new FileReader(fileN));        
            String line = null; //not declared within while loop
                /*
                * readLine is a bit quirky :
                * it returns the content of a line MINUS the newline.
                * it returns null only for the END of the stream.
                * it returns an empty String if two newlines appear in a row.
                */
            line = in.readLine();   // First line is the comment line; 
            while ((line = in.readLine()) != null)
            {
                words = line.split("\t"); 
                curID = Integer.parseInt(words[2]); 
                curName = words[3]; 
                ncbiProteinGeneIDList.put(curID, curName); 
                ncbiProteinGeneNameList.put(curName, curID); 
                                
                protein = words[0] + "\t" + words[1]; 
                ncbiGeneId2ProteinList.put(curID, protein); 
            }            
        }  
        catch (FileNotFoundException ex) {
            ex.printStackTrace();
        }
        catch (IOException ex){
            ex.printStackTrace();
        }
        finally {
            try {
                if (in!= null) {
                    in.close();
                }
            }  catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        
    }    
    

    /** Check the input Gene in the ncbi_human_protein list file or not */    
    public int checkNcbiProteinGene(int geneID) 
    {
        Object geneName = ncbiProteinGeneIDList.get(geneID);
        //String result = "Not Found in NCBI protein List!";
        int result = -1;
        if (geneName != null)
        {   
            String curName = geneName.toString(); 
            //result = "#geneID	geneSym\n" + geneID + "\t" + curName + "\n"; 
            result = geneID; 
        }
        return (result); 
    }    

    
    /** Check the input Gene in the ncbi_human_protein list file or not */        
    public int checkNcbiProteinGene(String geneName) 
    {
        Object geneID = ncbiProteinGeneNameList.get(geneName);
        //String result = "Not Found in NCBI protein List!";
        int result = -1;
        if (geneID != null)
        {   
            String curName = geneID.toString(); 
            //result = "#geneID	geneSym\n" + curName + "\t" + geneName + "\n"; 
            result = Integer.parseInt(curName); 
        }
        return (result); 
    }     
    
    
    /** Check the input Gene in the ncbi_human_protein list file or not */        
    public int checkNcbiProteinGene(int geneID, String geneName) 
    {
        //String result = "Not Matched geneID and geneName in NCBI protein List!";
        int result = -1;
        
        Object MappedGeneName = ncbiProteinGeneIDList.get(geneID);        
        if (geneName != null)
        {   
            String curName = MappedGeneName.toString(); 
            if ( geneName.compareTo(curName) == 0 )
            {
                //result = "#geneID	geneSym\n" + curName + "\t" + geneName + "\n"; 
                result = geneID; 
            }
        }        
        return (result); 
    }    

    
    /** Get the intersted Gene ID's corresponding gene symbol */        
    public String getRequestGeneName(int geneID)
    {
        Object MappedGeneName = ncbiProteinGeneIDList.get(geneID); 
        String result = MappedGeneName.toString(); 
        return(result) ; 
    }


    /** Function to test if a file exists or not */
    public boolean TestFileExist(String FileName)
    {
        File f = new File(FileName);
        return(f.exists()); 
    }
    
    
    /** Generate the intersted Gene-Protein List file for perl code using */        
    public String generateRequestGeneFile(int geneID)
    {
        String result = localPath + RequestGeneFilePre + "." + geneID; 
        //String result = "./" + RequestGeneFilePre + "." + geneID; 
        Object MappedGeneName = ncbiProteinGeneIDList.get(geneID); 
        Object MappedProtein = ncbiGeneId2ProteinList.get(geneID); 
        String Contents = "##proGI	proAcc	geneID	geneSym\n" + MappedProtein.toString() + "\t" + geneID + "\t" + MappedGeneName.toString() + "\n"; 
        
        String RequestGeneFile = localPath + RequestGeneFilePre + "." + geneID; 
        File outFile = new File(RequestGeneFile);
        if (outFile == null) {
            result = "Wrong in generating requestGene File!"; 
            throw new IllegalArgumentException("File should not be null.");
        }
        
        Writer output = null;                
        try {
            output = new BufferedWriter( new FileWriter(outFile) );
            output.write( Contents );
        } 
        catch (IOException e) {
            result = "Wrong in generating requestGene File!"; 
            System.out.println("a Java IOException occurred"); 
        } 
        finally {
            try {
                if (output != null) output.close();
            }  catch (IOException ex) {
                ex.printStackTrace();      }
        }
        return(result) ; 
    }
    
    
    /** Check the detailed Gene Info for request GeneID */        
    public String getRequestGeneInfo(int geneID)
    {
        String result = "#geneID \t geneSym \t Description\n";         
        String RequestGeneFile = localPath + RequestGeneFilePre + "." + geneID; 
        String logFile = RequestGeneFile + ".geneinfo.log"  ; 
                
        String geneInfoFile =  localPath + ncbiGeneInfoFileName; 
        String cmd = "perl " + localPath + getRequestGeneInfoPerl + "  " + RequestGeneFile + " " + geneInfoFile + " " + RequestGeneFile + ".geneinfo" ; 
        try {
            Process p = Runtime.getRuntime().exec(cmd);        
            // read the output from the command
            String s = null;            
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            System.out.println("\n-----------------------------------------------------------------------------------------------\n");                        
            System.out.println(cmd);            
            System.out.println("Here is the standard output of the command:\n");

            FileWriter out = new FileWriter(new File(logFile));                        
            out.write(cmd + "\n");
            
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
                out.write(s + "\n");
            }           
            out.close();    
        }
         catch (IOException e) {
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        } 

        // read in the geneinfo file 
        String fileN = RequestGeneFile + ".geneinfo";
        BufferedReader in = null; 
        try {           
            in = new BufferedReader( new FileReader(fileN));        
            String line = in.readLine();   // First line is the comment line; 
            line = in.readLine();   // second line is the content line; 
            result = result + line; 
        }  
        catch (FileNotFoundException ex) {
            ex.printStackTrace();
        }
        catch (IOException ex){
            ex.printStackTrace();
        }
        finally {
            try {
                if (in!= null) {
                    in.close();
                }
            }  catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        
        return(result) ; 
    }
    
    
    /** 0-Create-PPI-List for a specific gene ID with the specified gene list */        
    /** 0-Create-PPI-List for a specific gene ID based on the NCBI-protein-gene-list file */            
    /** 0-Create-PPI-List for a specific gene ID based on the NCBI-protein-gene-list file */        
    public String create_ppi_list(int geneID, int createChoice, String relatedGeneListFile )
    {
        String RequestGeneFile = localPath + RequestGeneFilePre + "." + geneID; 
        if ( TestFileExist(RequestGeneFile) == false )
        {   return("Required requestGeneFile Not exist !"); }
        
        if (( createChoice > 2 ) || ( createChoice < 0 ) )
        {  return("The create PPI choice parameter is wrong !!"); }
        if (( createChoice == 2 ) || ( createChoice == 1 ) )  { 
            if ( TestFileExist(relatedGeneListFile) == false )
            {   return("Required partnerGeneListFile (to search for parterners in) does not exist !"); }            
        }
        
        String humanProteinList = localPath + ncbiProteinFileName;        
        String perlCommand = "perl " + localPath + creatPPIlistPerl[createChoice]; 
        String posPPIchoose = localPath + posPPIfile; 
        String outFile =  localPath + outPPairfileDir + outPPairfilePre + outPPairfilePreChange[createChoice] ;         
        String logFile = outFile  + "." + geneID + ".log";
        outPPairfilePreFull = outPPairfilePre + outPPairfilePreChange[createChoice] ; 
        
        String cmd = perlCommand + "  " + RequestGeneFile + " " + humanProteinList + " " + relatedGeneListFile + " " + posPPIchoose + " " + outFile ; 
        try {
            System.out.println("\n-----------------------------------------------------------------------------------------------\n");                                    
            System.out.println(cmd);
            Process p = Runtime.getRuntime().exec(cmd); 
            // read the output from the command
            String s = null;            
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            FileWriter out = new FileWriter(new File(logFile));                        
            out.write(cmd + "\n");
            
            System.out.println("Here is the standard output of the command:\n");
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
                out.write(s + "\n");
            }           
            out.close();    
        }
         catch (IOException e) { 
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        }         
        return( "./" + outPPairfileDir + outPPairfilePre + outPPairfilePreChange[createChoice]  + "." + geneID);
    }

    
    
    
    /** 1-generate-feature */
    public String generate_ppi_fea(int geneID)
    {
        String ppiListFileLoc1 =  localPath + outPPairfileDir + outPPairfilePreFull + "." + geneID ; 
        if ( TestFileExist(ppiListFileLoc1) == false )
        {   return("Required Candidate_pairList_file Not exist !"); }
        
        String ppiListFileLoc2 =  localPath + FeaFileDir + outPPairfilePreFull + "." + geneID ; 

        String perlCommand = "perl " + localPath + generateFeaCurDir + generateFeaPerl;
        String cmd = perlCommand + " " + localPath + generateFeaCurDir + " " + ppiListFileLoc2; 
        try {
            copyfile(ppiListFileLoc2, ppiListFileLoc1); 
            System.out.println("\n-----------------------------------------------------------------------------------------------\n");                                    
            System.out.println(cmd);
            Process p = Runtime.getRuntime().exec(cmd); 
            // read the output from the command
            String s = null;            
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            System.out.println("Here is the standard output of the command:\n");
            
            String logFile = ppiListFileLoc2 + ".27fea.log"; 
            FileWriter out = new FileWriter(new File(logFile));                        
            out.write(cmd + "\n");
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
                out.write(s + "\n");
            }           
            out.close(); 
        }
        catch (IOException e) { 
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        }         
        return( "./" + FeaFileDir + outPPairfilePreFull + "." + geneID + ".27fea.filled.rf" );
    }
    
    
    /** Implement the copy function : copy file2 contents to file1 */
    public void copyfile(String file1, String file2)  {
    	File inputFile = new File(file2);
	File outputFile = new File(file1);
        try {           
            FileReader in = new FileReader(inputFile);
            FileWriter out = new FileWriter(outputFile);
            int c;
            while ((c = in.read()) != -1)
               out.write(c);
            in.close();
            out.close();    
        }
        catch (IOException ex){
            ex.printStackTrace();
        }        
    }

    
    /** Make the testing process for the generated feature files */
    public String predictPPI(int geneID, int PPIchoice )  {
        String feaFile = localPath + FeaFileDir + outPPairfilePreFull + "." + geneID + ".27fea.filled.rf"; 
        if ( TestFileExist(feaFile) == false )
        {   return("Required Candidate_pairList_featureSet_file Not exist !"); }
        
        String model = localPath + testModelFile ; 
        String outPre = localPath + testOutputPre + outPPairfilePreChange[PPIchoice] + "." + geneID + "." + testOutputSuffix ; 

        String perlCommand = "perl " + localPath +  testPerl;
        String cmd = perlCommand + " " + feaFile + " " + model + " " + testModelPara + " " + outPre + ".predict " + outPre + ".out " ; 
        try {
            System.out.println("\n-----------------------------------------------------------------------------------------------\n");                                    
            System.out.println(cmd);            
            Process p = Runtime.getRuntime().exec(cmd); 
            // read the output from the command
            String s = null;            
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            System.out.println("Here is the standard output of the command:\n");

            String logFile = outPre + ".RFPredict.log"; 
            FileWriter out = new FileWriter(new File(logFile));                        
            out.write(cmd + "\n");
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
                out.write(s + "\n");
            }           
            out.close(); 
        }
        catch (IOException e) { 
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        }                 

        String transformperlCommand = "perl " + localPath +  resultTransferPerl; 
        String transfermCmd = transformperlCommand + " " + outPre + ".out " + outPre + ".scoreLabel " ; 
        try {
            System.out.println("\n-----------------------------------------------------------------------------------------------\n");                                                
            System.out.println(transfermCmd);
            Process q = Runtime.getRuntime().exec(transfermCmd); 
            // read the output from the command
            String s = null;            
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(q.getInputStream()));
            System.out.println("Here is the standard output of the command:\n");
           
            String logFile = outPre + ".scoreLabel.log"; 
            FileWriter out = new FileWriter(new File(logFile));                        
            out.write(transfermCmd + "\n");
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
                out.write(s + "\n");
            }           
            out.close(); 
        }
        catch (IOException e) { 
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        }                 
        
        return( "./" + testOutputPre + outPPairfilePreChange[PPIchoice] + "." + geneID + "." + testOutputSuffix + ".out/scoreLabel " );
    }    


    /** Function to add the geneInfo / feature / and disease information on the predicted PPI scoreLabel file. */
    public String AddInfoResultPPI(int geneID, int PPIchoice)  {
        String feaFile = localPath + FeaFileDir + outPPairfilePreFull + "." + geneID + ".27fea";         
        String ppiListFile =  localPath + outPPairfileDir + outPPairfilePreFull + "." + geneID ; 
        String scoreFile = localPath + testOutputPre + outPPairfilePreChange[PPIchoice] + "." + geneID + "." + testOutputSuffix  + ".scoreLabel ";         
        if ( TestFileExist(feaFile) == false )
        {   return("Required Candidate_pairList_featureSet_file Not exist !"); }
        if ( TestFileExist(ppiListFile) == false )
        {   return("Required Candidate_pairList_file Not exist !"); }
        if ( TestFileExist(scoreFile) == false )
        {   return("Required CandidatePair_PPIScore_file Not exist !"); }

        String Outcombine = localPath + outcombinePre + outPPairfilePreChange[PPIchoice] + "." + geneID ;
        String addGeneInfoCmd = "perl " + localPath +  addGeneInfoPerlcmd;    
        String geneInfoFile = localPath +  ncbiGeneInfoFileName; 
        String addCmd = addGeneInfoCmd + " " + ppiListFile + " " + scoreFile + " " + feaFile + " "  + geneInfoFile + " " + Outcombine; 
        try {
            System.out.println("\n-----------------------------------------------------------------------------------------------\n");                                    
            System.out.println(addCmd);            
            Process p = Runtime.getRuntime().exec(addCmd); 
            // read the output from the command
            String s = null;            
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            System.out.println("Here is the standard output of the command:\n");

            String logFile = Outcombine + ".log"; 
            FileWriter out = new FileWriter(new File(logFile));                        
            out.write(addCmd + "\n");
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
                out.write(s + "\n");
            }           
            out.close();             
        }
        catch (IOException e) { 
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        }                 

        String adddiseaseCommand = "perl " + localPath +  adddiseaseInfoPerlcmd; 
        String diseaseInfo = localPath +  diseaseInfoFile; 
        String adddiseaseCmd = adddiseaseCommand + " " + Outcombine + " " + diseaseInfo + " " + Outcombine + ".addDisease " ; 
        try {
            System.out.println("\n-----------------------------------------------------------------------------------------------\n");                                                            
            System.out.println(adddiseaseCmd);
            Process q = Runtime.getRuntime().exec(adddiseaseCmd); 
            // read the output from the command
            String s = null;            
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(q.getInputStream()));
            System.out.println("Here is the standard output of the command:\n");

            String logFile = Outcombine + ".addDisease.log"; 
            FileWriter out = new FileWriter(new File(logFile));                        
            out.write(adddiseaseCmd + "\n");
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
                out.write(s + "\n");
            }           
            out.close();             
        }
        catch (IOException e) { 
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        }                 
        return( "./" + outcombinePre + outPPairfilePreChange[PPIchoice] + "." + geneID + ".addDisease " );        
    }      
}