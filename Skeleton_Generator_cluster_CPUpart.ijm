
filepath0=getDirectory("temp");//C:\Users\??\AppData\Local\Temp\...C:\DOCUME~1\ADMINI~1\LOCALS~1\Temp\
filepath=filepath0+"Skeleton_Creator.txt";
LF=10; TAB=9; swi=0; swi2=0; testline=0;
exi=File.exists(filepath);
List.clear();
setBatchMode(true);
ReduceS=false;
AddSkelton="None";
blockposition=1;
totalblock=1;
JFRCMaskDir=0;
tempMaskpath=0;
tempMaskpath=0;
dir=0;
DirOK=0;
savedir=0;
savedirOK=0;
CPUnum=10;
ShowOriginalVol=true;// single object separation
SkeltonTrue=true;//Skeltonization false
MaxGPUmemPercentage=70;
ScoreAdd=false;//"Add Alignment Score JFRC2010"
OBJscore="";
ThreeDconnect=1;// Maximum 3D
subtraction=10;//"Background Subtraction %"
NumConnection=2;//"20px connection run time"
bit16conv=false;
BrightnessApply=true;//"Apply Brightness increase"
gapVolRatioMaxThre=0.15;//"Max Volume increment ratio; "
MaxDSLT=10;
VxWidth=0.188;
VxDepth=0.38;
pngsave=0;
testarg=0;
moveafterdone=1;
MaxMIPratio=0.28;//" (default 0.36 for GAL4, 0.28 for split & MCFO, 0.19 for larva)"0.6 is for messy line, 0.65 is Reed class4
gapMIPratioThre=0.07;//0.047 is more specific MCFO; 0.07 is MCFO class4 Reed brain, 0.01 is larva
ThreratioMIPweight=0.0011;// 0.00111 is specific split/MCFO, 0.0025 is for class4 Reed
MaxVolPercent=4;

ExM=0;
simplefilenameExp=true; // simple file name save

run("Misc...", "divide=Infinity save");


//testarg="E:/RyoSeg/JRC_SS25540_20161014_27_D4_REG_UNISEX_63x_m_BrainC2.nrrd,E:/RyoSeg/,G:/Template_MIP/,0.188,0.38";
//testarg="A:/test/R_31D09_AE_01-20161111_18_F6-f_63x-CH1.h5j,A:/test/,G:/Template_MIP/,0.5189161,1";

//testarg="/Users/otsunah/test/Segmentation_test/VT005105_116E03_AE_01-20140221_19_A6-f_63x-CH1.h5j,/Users/otsunah/test/Segmentation_test/Res/,/Users/otsunah/test/Brainaligner_CDMcreator/template/,0.5189161,1";

if(testarg==0)
args = split(getArgument(),",");
else{
	args = split(testarg,",");
	CPUnum=15;
}
fullpath=args[0];
savedir=args[1];
JFRCMaskDir=args[2];
VxWidth=args[3];
VxDepth=args[4];


print("fullpath; "+fullpath);
print("savedir; "+savedir);
print("JFRCMaskDir; "+JFRCMaskDir);
print("VxWidth; "+VxWidth);
print("VxDepth; "+VxDepth);

sepIndex=lastIndexOf(fullpath,"/");

dir=substring(fullpath,0,sepIndex+1);
filename=substring(fullpath,sepIndex+1,lengthOf(fullpath));

JFRCexist=File.exists(JFRCMaskDir);

savedirExt=File.exists(savedir);
if(savedirExt==0)
File.makeDirectory(savedir);

predir=substring(savedir, 0, lengthOf(savedir)-1);

savedirfilepathindex = lastIndexOf(predir, "/");

predir= substring(predir, 0, savedirfilepathindex+1);
skeletondir=predir+"skeleton/";

print("skeletondir ; "+skeletondir);

File.makeDirectory(skeletondir);

maskdir=predir+"mask/";
maskMIPdir=predir+"maskMIP/";
print("maskdir; "+maskdir);

File.makeDirectory(maskdir);
File.makeDirectory(maskMIPdir);
filepath=savedir+filename+".txt";

if(JFRCexist==1)
print("JFRCMaskDir; "+JFRCMaskDir);
else{
	print("JFRCMaskDir does not exist; "+JFRCMaskDir);
	logsum=getInfo("log");
	//	File.saveString(logsum, filepath);
	
	
	run("Quit");
}


subtraction=parseFloat(subtraction);//Chaneg string to number
VxWidth=parseFloat(VxWidth);//Chaneg string to number
VxDepth=parseFloat(VxDepth);//Chaneg string to number

VxHeight=VxWidth;

MaxDSLT=1.5/VxWidth;

if(ExM==1)
MaxDSLT=MaxDSLT*4;

dirExt=File.exists(dir);
if(dirExt==0){
	filepath=savedir+filename+".txt";
	filepath=savedir+filename;
	print("dir not existing; "+dir);
	logsum=getInfo("log");
	//	File.saveString(logsum, filepath);
	
	run("Quit");
}

//logsum=getInfo("log");
//File.saveString(logsum, filepath);

MIPstepSlices=1;

if(ReduceS!=0)
MIPstepSlices=2;
//print("MIPstepSlices; "+MIPstepSlices);


///2ch & 3ch lsm file detection ///
run("Close All");

MaxNum=0;
FirstTime=0;



print("\\Clear");
print("dir; "+dir);
print("savedir; "+savedir);
print("JFRCMaskDir; "+JFRCMaskDir);

print("MaxMIPratio; "+MaxMIPratio);
print("ShowOriginalVol; "+ShowOriginalVol);

print("");
/// skeletoniztion ///////////////////////////////////////////////////
nrrdIndex=lastIndexOf(filename, ".nrrd");
nc82Nrrd=lastIndexOf(filename,"01_warp");
if(nc82Nrrd==-1)
nc82Nrrd=lastIndexOf(filename,"_01.nrrd");
if(nc82Nrrd==-1)
nc82Nrrd=lastIndexOf(filename,"_01_APflip.nrrd");
if(nc82Nrrd==-1)
nc82Nrrd=lastIndexOf(filename,"_c3.nrrd");

dotIndex=lastIndexOf(filename, ".");


if(endsWith(filename,".tif") || endsWith(filename,".nrrd") || endsWith(filename,".h5j") || endsWith(filename,".v3dpbd") || endsWith(filename,".zip") ){
	
	starttime=getTime();
	///duplication check ////////////////
	filepathcolor=0;
	GMRposi=indexOf(filename, "GMR");
	if(GMRposi==-1)
	GMRposi=0;
	
	
	WarpPosition=lastIndexOf(filename, "_warp");
	if(WarpPosition==-1)
	WarpPosition=dotIndex;
	
	
	REGindedx=lastIndexOf(filename,"REG_JRC2018_UNISEX_63x_");
	if(REGindedx!=-1 && GMRposi==0)
	GMRposi=23;
	
	purenameOri=substring(filename, 0, WarpPosition);//original data
	print("purenameOri; "+purenameOri);
	
	OrinameLength=lengthOf(purenameOri);
	
	
	//	print("PosiIndex; "+PosiIndex+"   filepathcolor; "+filepathcolor);
	//		a
	//print("dotIndexVNC; "dotIndexVNC+"   dotIndextif; "+dotIndextif+"   dotIndexzip; "+dotIndexzip+"   dotIndexTIFF; "+dotIndexTIFF+"   dotIndex;"+dotIndex+"   dotIndexAM; "+dotIndexAM+"   dotIndexLSM; "+dotIndexLSM+"   dotIndexMha; "+dotIndexMha+"   dotIndexV3; "+dotIndexV3+"   dotIndexV3raw; "+dotIndexV3raw==-1 && dotIndexJBA==-1 && dotIndexCMTK==-1))
	
	
	if(nc82Nrrd!=-1)
	print("01_warp positive");
	else
	print("Neuron channel");
	
	dotindex=lastIndexOf(filename,".");
	if(dotindex!=-1)
	truname=substring(filename,0,dotindex);
	
	QIindex=lastIndexOf(filename,"._QI");
	if(QIindex!=-1)
	truname=substring(filename,0,QIindex);
	
	h5jindex=lastIndexOf(truname,"h5j");
	if(h5jindex!=-1)
	truname=substring(truname,0,h5jindex);
	
	warpIndex=lastIndexOf(truname,"_warp");
	if(warpIndex!=-1)
	truname=substring(truname,0,warpIndex);
	
	REGindedx=lastIndexOf(truname,"REG_JRC2018_UNISEX_63x_");
	if(REGindedx!=-1)
	truname=replace(truname, "REG_JRC2018_UNISEX_63x_", "");
	
	///////////////// nc82 /////////////////////
	if(nc82Nrrd!=-1 && ScoreAdd){// if file is nc82 nrrd
		print(dir+filename+"   try");
		
		open(dir+filename);
		getDimensions(width, height, channels, slices, frames);
		//	getVoxelSize(VxWidth, VxHeight, VxDepth, VxUnit);
		bitd=bitDepth();
		
		if(channels>1){
			run("Split Channels");
			titlelist=getList("image.titles");
			
			selectWindow(channels[channels-1]);
			close();
		}
		
		print("Sample size; width; "+width+"   height; "+height+"   slices; "+slices);
		///////////mask decision ///////////////////////
		tempMaskpath=0; temppath=0;
		if(width<height){
			TISSUE="VNC";
			
			
			if(width==1401 && height==2740 && slices==402){//1401x2740x402, JRC2018 63x UNISEX
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_UNISEX_63x_3DMASK.nrrd";
				temppath=JFRCMaskDir+"JRC2018_VNC_UNISEX_63x.nrrd";
				tempname="JRC2018_VNC_UNISEX_63x.nrrd";
				print("tempname=JRC2018_VNC_UNISEX_63x.nrrd");
			}else if(width==1402 && height==2851 && slices==377){//1402x2851x377), JRC2018 63x Female
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_FEMALE_63x_3DMASK.nrrd";
			}else if(width==1401 && height==2851 && slices==422){//1401x2851x422), JRC2018 63x MALE
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_MALE_63x_3DMASK.nrrd";
			}else if(width==573 && height==1119 && slices==219){//573x1119x219, JRC2018 20x UNISEX
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_UNISEX_447_3DMASK.nrrd";
			}else if(width==572 && height==1164 && slices==229){//512x1100x220, 2017_VNC 20x MALE
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_MALE_447_G15_3DMASK.nrrd";
			}else if(width==573 && height==1164 && slices==205){//512x1100x220, 2017_VNC 20x MALE
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_FEMALE_447_G15_3DMASK.nrrd";
			}else if(width==512 && height==1100 && slices==220){//512x1100x220, 2017_VNC 20x MALE
				tempMaskpath=JFRCMaskDir+"MaleVNC2017_3DMASK.nrrd";
				
			}else if(width==512 && height==1024 && slices==220){//512x1024x220, JRC2018 20x UNISEX
				tempMaskpath=JFRCMaskDir+"FemaleVNCSymmetric2017_3DMASK.nrrd";
				
			}
			
		}else if(width>height){//if(width<height){
			
			TISSUE="BRAIN";
			
			if(width==1652 && height==773 && slices==456){//1652x773x456, JRC2018 BRAIN 63x UNISEX
				tempMaskpath=JFRCMaskDir+"JRC2018_BRAIN_UNISEX_63x_MASK.nrrd"
			}else if(width==1210 && height==566 && slices==174){//1210x566x174, JRC2018 BRAIN 20xHR UNISEX
				tempMaskpath=JFRCMaskDir+"JRC2018_BRAIN_UNISEX_20xHR_MASK.nrrd"
			}else if(width==1652 && height==768 && slices==478){//1652x768x478, JRC2018 BRAIN 63xDW FEMALE
				tempMaskpath=JFRCMaskDir+"JRC2018_BRAIN_FEMALE_63xDW_MASK.nrrd"
			}else if(width==3333 && height==1550 && slices==478){//3333x1550x478, JRC2018 BRAIN 63x FEMALE
				tempMaskpath=JFRCMaskDir+"JRC2018_BRAIN_FEMALE_63x_MASK.nrrd"
			}else if(width==1561 && height==744 && slices==476){//1561x744x476, JRC2018 BRAIN 63xDW MALE
				tempMaskpath=JFRCMaskDir+"2JRC2018_BRAIN_MALE_63xDW_MASK.nrrd"
			}else if(width==3150 && height==1500 && slices==476){//3150x1500x476, JRC2018 BRAIN 63x MALE
				tempMaskpath=JFRCMaskDir+"JRC2018_BRAIN_MALE_63x_MASK.nrrd"
			}else if(width==1024 && height==512 && slices==220){//1024x512x220, JFRC2010
				tempMaskpath=JFRCMaskDir+"JFRC2010_MASK.nrrd"
			}
		}//if(width>height){
		
		
		
		
		if(bitd==8 || bitd==24){
			maxScan=200;
			maxVal=255;
			increscan=1;
			AveMedian=10;
			MinWeight=0.1;
			
		}else if (bitd==16){
			
			run("Max value");/// need new plugin
			maxvalue0 = call("Max_value.getResult");
			maxvalue0= parseFloat(maxvalue0);//Chaneg string to number
			
			MinWeight=1;
			
			if(maxvalue0<4096){
				maxVal=4095;
				maxScan=3000;
				increscan=10;
				AveMedian=100;
				
				print("Detected max; 4095");
			}else{
				maxVal=65535;
				maxScan=40000;
				increscan=200;
				AveMedian=500;
				print("Detected max; 65535");
			}
		}//else if (bitd==16){
		
		if(VxWidth==1){
			if(width==1024)
			if(height==512)
			if(slices==218){
				VxDepth=1;
				VxWidth=0.62;
				VxHeight=0.62;
				run("Properties...", "channels="+channels+" slices="+nSlices/channels+" frames=1 unit=microns pixel_width="+VxWidth+" pixel_height="+VxHeight+" voxel_depth="+VxDepth+"");
			}
		}//if(VxWidth==1){
		
		if(channels>1)
		run("Split Channels");
		
		titlelist=getList("image.titles");
		OBJscore="";
		////// For Nc82 //////////////////////////////////////
		
		if(endsWith(filename,".tif") || endsWith(filename,".h5j") || endsWith(filename,".v3dpbd") || nc82Nrrd!=-1){
			print("The file is nc82!");
			selectWindow(titlelist[titlelist.length-1]);//nc82
			
			
			
			originalSliceNum=nSlices();//round(nSlices/2);
			run("Size...", "width="+round(getWidth()/2)+" height="+round(getHeight()/2)+" depth="+round(nSlices)+" constrain average interpolation=Bicubic");//()/2
			
			stack=getImageID();
			Score3D(stack,temppath,tempMaskpath,tempname,CPUnum);// check alignment score
			
			logsum=getInfo("log");
			endlog=lengthOf(logsum);
			scoreposition=lastIndexOf(logsum, "score");
			OBJscore=substring(logsum,scoreposition+7,endlog);
			OBJscore=parseFloat(OBJscore);//Chaneg string to number
			
			while(isOpen("Mask.tif")){
				selectWindow("Mask.tif");
				close();
				//		print("Mask.tif closed in 238");
			}
			
			print("OBJscore; "+OBJscore);
			if(OBJscore>0.6){// if alignment is good, create nc82 mask from sample
				selectImage(stack);
				run("Duplicate...", "title=Mask.tif duplicate");
				
				if(bitd==16){
					threArray=newArray(nSlices+1);
					
					for(islice=1; islice<nSlices; islice++){
						setSlice(islice);
						setAutoThreshold("MinError dark");
						
						getThreshold(threArray[islice-1],max);
						sum=sum+threArray[islice-1];
					}
					
					avethre=round(sum/nSlices);
					minthre=round(avethre*0.67);
					print("258; minthre; "+minthre+"  avethre; "+avethre);
					run("Duplicate...", "title=SingleMask.tif");
					selectWindow("Mask.tif");
					
					print("261 originalSliceNum; "+originalSliceNum);
					
					for(islice2=1; islice2<=originalSliceNum; islice2++){
						
						setSlice(islice2);
						
						run("Select All");
						run("Copy");
						selectWindow("SingleMask.tif");
						run("Paste");
						
						nextThre=0; CurrentThre=0; preThre=0;
						
						CurrentThre=threArray[islice2-1];
						
						if(islice2>1 && islice2<originalSliceNum-1)
						nextThre=threArray[islice2];
						
						if(islice2>2)
						preThre=threArray[islice2-2];
						
						if(nextThre!=0 && preThre!=0)
						aveThre=(nextThre+preThre)/2;
						else if (nextThre==0 && preThre!=0)
						aveThre=preThre;
						else if (nextThre!=0 && preThre==0)
						aveThre=nextThre;
						else if (nextThre==0 && preThre==0)
						aveThre=0;
						//		print("Slice; "+islice2);
						//		print("preThre; "+preThre+"  nextThre; "+nextThre+"  aveThre; "+aveThre);//"  aveThre; "+aveThre
						GapThre=abs(aveThre-CurrentThre);
						GapVal=GapThre/CurrentThre;
						
						if(GapVal<0.5)
						CurrentThre=round(aveThre);
						
						if(CurrentThre<avethre)
						CurrentThre=avethre;
						
						//		print("CurrentThre; "+CurrentThre);
						
						setThreshold(CurrentThre, maxVal);
						run("Convert to Mask");
						run("16-bit");
						
						
						run("Select All");
						run("Copy");
						selectWindow("Mask.tif");
						setSlice(islice2);
						run("Paste");
						
					}//for(islice2=1; islice2<nSlices; islice2++){
					print("308");
					selectWindow("SingleMask.tif");
					close();
				}else{//if(bitd==8){
					run("Convert to Mask", "method=MinError background=Dark calculate black");
					run("Mask255 to 4095");// set mask to 4095
					rename("Mask.tif");
					print("313");
				}
			}else{//if(OBJscore>0.6){// if alignment is good, create nc82 mask from sample
				
				run("Close All");
				
				open(tempMaskpath);//"JFRC2010_Mask_Small.nrrd";
				run("Mask255 to 4095");// set mask to 4095
				rename("Mask.tif");
				
				endlist=titlelist.length-1;
			}//if(OBJscore>0.6){/
		}//if(endsWith(filename,".tif") || endsWith(filename,".h5j") || endsWith(filename,".v3dpbd"  || nc82Nrrd!=-1)){
		
		
	}//if(nc82Nrrd!=-1 && ScoreAdd){
	
	
	////// For neuron channels ///////////////////////////////////////
	if(nc82Nrrd==-1){// if it is not nc82
		print("The file is Not nc82!");
		
		print("dir; "+dir+"   filename; "+filename);
		
		open(dir+filename);
		getDimensions(width, height, channels, slices, frames);
		//		getVoxelSize(VxWidth, VxHeight, VxDepth, VxUnit);
		
		if(channels>1){
			run("Split Channels");
			titlelist=getList("image.titles");
			
			selectWindow(titlelist[channels-1]);
			close();
		}
		
		Oribitd=bitDepth();
		bitd=bitDepth();
		StartOpen=getTime();
		///////////mask decision ///////////////////////
		tempMaskpath=0; temppath=0; tempname=""; TISSUE="BRAIN";
		if(width<height){
			TISSUE="VNC";
			
			if(width==1401 && height==2740 && slices==402){//1401x2740x402, JRC2018 63x UNISEX
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_UNISEX_63x_3DMASK.nrrd";
				temppath=JFRCMaskDir+"JRC2018_VNC_UNISEX_63x.nrrd";
				tempname="JRC2018_VNC_UNISEX_63x.nrrd";
				print("tempname=JRC2018_VNC_UNISEX_63x.nrrd");
				VxWidth=0.1882689; VxDepth=0.38;
			}else if(width==1402 && height==2851 && slices==377){//1402x2851x377), JRC2018 63x Female
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_FEMALE_63x_3DMASK.nrrd";
				VxWidth=0.1882689; VxDepth=0.38;
			}else if(width==1401 && height==2851 && slices==422){//1401x2851x422), JRC2018 63x MALE
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_MALE_63x_3DMASK.nrrd";
				VxWidth=0.1882689; VxDepth=0.38;
			}else if(width==573 && height==1119 && slices==219){//573x1119x219, JRC2018 20x UNISEX
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_UNISEX_447_3DMASK.nrrd";
				VxWidth=0.4611220; VxDepth=0.7;
			}else if(width==572 && height==1164 && slices==229){//512x1100x220, 2017_VNC 20x MALE
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_MALE_447_G15_3DMASK.nrrd";
				VxWidth=0.4611220; VxDepth=0.7;
			}else if(width==573 && height==1164 && slices==205){//512x1100x220, 2017_VNC 20x MALE
				tempMaskpath=JFRCMaskDir+"JRC2018_VNC_FEMALE_447_G15_3DMASK.nrrd";
				VxWidth=0.4611220; VxDepth=0.7;
			}else if(width==512 && height==1100 && slices==220){//512x1100x220, 2017_VNC 20x MALE
				tempMaskpath=JFRCMaskDir+"MaleVNC2017_3DMASK.nrrd";
				VxWidth=0.4612588; VxDepth=0.7;
			}else if(width==512 && height==1024 && slices==220){//512x1024x220, FemaleVNCSymmetric2017_3DMASK
				tempMaskpath=JFRCMaskDir+"FemaleVNCSymmetric2017_3DMASK.nrrd";
				VxWidth=0.4611222; VxDepth=0.7;
			}
			
			
		}else if(width>height){//if(width<height){
			
			TISSUE="BRAIN";
			
			if(width==3333 && height==1560 && slices==456){//3333x1560x456, JRC2018 BRAIN 63x UNISEX
				tempMaskpath=JFRCMaskDir+"JRC2018_UNISEX_63xOri_3DMASK.nrrd";
				VxWidth=0.1882680; VxDepth=0.38;
			}else if(width==1652 && height==773 && slices==456){//1652x773x456, JRC2018 BRAIN 63xDW UNISEX
				tempMaskpath=JFRCMaskDir+"JRC2018_UNISEX_38um_iso_3DMASK.nrrd";
				VxWidth=0.38; VxDepth=0.38;
			}else if(width==1427 && height==668 && slices==394){
				tempMaskpath=JFRCMaskDir+"JRC2018_UNISEX_40x_3DMASK.nrrd";
				VxWidth=0.44; VxDepth=0.44;
			}else if(width==1210 && height==566 && slices==174){//1210x566x174, JRC2018 BRAIN 20xHR UNISEX
				tempMaskpath=JFRCMaskDir+"JRC2018_UNISEX_20x_HR_3DMASK.nrrd";
				VxWidth=0.5189161; VxDepth=1;
			}else if(width==1010 && height==473 && slices==174){
				tempMaskpath=JFRCMaskDir+"JRC2018_UNISEX_20x_gen1_3DMASK.nrrd";
				VxWidth=0.6214809; VxDepth=1;
				
			}else if(width==3333 && height==1550 && slices==478){//3333x1550x478, JRC2018 BRAIN 63x FEMALE
				tempMaskpath=JFRCMaskDir+"JRC2018_FEMALE_63x_3DMASK.nrrd";
				VxWidth=0.1882680; VxDepth=0.38;
			}else if(width==1652 && height==768 && slices==478){//1652x768x478, JRC2018 BRAIN 63xDW FEMALE
				tempMaskpath=JFRCMaskDir+"JRC2018_FEMALE_38um_iso_3DMASK.nrrd";
				VxWidth=0.38; VxDepth=0.38;
			}else if(width==1427 && height==664 && slices==413){
				tempMaskpath=JFRCMaskDir+"JRC2018_FEMALE_40x_3DMASK.nrrd";
				VxWidth=0.44; VxDepth=0.44;
			}else if(width==1210 && height==563 && slices==182){
				tempMaskpath=JFRCMaskDir+"JRC2018_FEMALE_20x_HR_3DMASK.nrrd";
				VxWidth=0.5189161; VxDepth=1;
			}else if(width==1010 && height==470 && slices==182){
				tempMaskpath=JFRCMaskDir+"JRC2018_FEMALE_20x_gen1_3DMASK.nrrd";
				VxWidth=0.6214809; VxDepth=1;
				
			}else if(width==3150 && height==1500 && slices==476){//3150x1500x476, JRC2018 BRAIN 63x MALE
				
				tempMaskpath=JFRCMaskDir+"JRC2018_MALE_63x_3DMASK.nrrd";
				VxWidth=0.1882680; VxDepth=0.38;
			}else if(width==1561 && height==744 && slices==476){//1561x744x476, JRC2018 BRAIN 63xDW MALE
				tempMaskpath=JFRCMaskDir+"JRC2018_MALE_38um_iso_3DMASK.nrrd";
				VxWidth=0.38; VxDepth=0.38;
			}else if(width==1348 && height==642 && slices==411){
				tempMaskpath=JFRCMaskDir+"JRC2018_MALE_40x_3DMASK.nrrd";
				VxWidth=0.44; VxDepth=0.44;
			}else if(width==1143 && height==545 && slices==181){
				tempMaskpath=JFRCMaskDir+"JRC2018_MALE_20xHR_3DMASK.nrrd";
				VxWidth=0.5189161; VxDepth=1;
			}else if(width==955 && height==455 && slices==181){
				tempMaskpath=JFRCMaskDir+"JRC2018_MALE_20x_gen1_3DMASK.nrrd";
				VxWidth=0.6214809; VxDepth=1;
				
			}else if(width==1184 && height==592 && slices==218){
				tempMaskpath=JFRCMaskDir+"JFRC2013_20x_New_dist_G16_3DMASK.nrrd";
				VxWidth=0.46; VxDepth=0.83;
			}else if(width==1450 && height==725 && slices==436){
				tempMaskpath=JFRCMaskDir+"JFRC2013_63x_New_dist_G16_3DMASK.nrrd";
				VxWidth=0.38; VxDepth=0.38;
			}else if(width==1024 && height==512 && slices==220){//1024x512x220, JFRC2010
				
				tempMaskpath=JFRCMaskDir+"JFRC2010_3DMask.nrrd";
				VxWidth=0.64; VxDepth=1;
			}
		}//if(width>height){
		
		VxHeight=VxWidth;
		
		print("tempMaskpath; "+tempMaskpath+"  VxWidth; "+VxWidth+"  width; "+width+"  height; "+height);
		
		run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width="+VxWidth+" pixel_height="+VxHeight+" voxel_depth="+VxDepth+"");
		
		
		if(bitd==8 || bitd==24){
			maxScan=200;
			maxVal=255;
			increscan=1;
			AveMedian=10;
			MinWeight=0.1;
			
		}else if (bitd==16){
			
			run("Max value");/// need new plugin
			maxvalue0 = call("Max_value.getResult");
			maxvalue0= parseFloat(maxvalue0);//Chaneg string to number
			print("maxvalue0; "+maxvalue0);
			
			MinWeight=0.1;
			
			if(maxvalue0<4096){
				maxVal=4095;
				maxScan=3000;
				increscan=10;
				AveMedian=100;
				
				print("Detected max; 4095");
			}else{
				maxVal=65535;
				maxScan=40000;
				increscan=200;
				AveMedian=500;
				print("Detected max; 65535");
			}
		}//else if (bitd==16){
		
		titlelist=getList("image.titles");
		print(nImages+" images open");
		endlist=1;
		if(endsWith(filename,".nrrd") || h5jindex!=-1 || endsWith(filename,".tif") || endsWith(filename,".zip")){
			endlist=titlelist.length;
	//		if(h5jindex!=-1 && channels>1)
	//		endlist=endlist-1;// not segmenting nc82
			print("endlist; "+endlist);
		}
		
		///back ground subtraction & neuronal segmentation ////////////////////
		for(ititle=0; ititle<endlist; ititle++){
			
			print("ReduceS; "+ReduceS);
			print("CPUnum; "+CPUnum);
			print("16bit conversion; "+bit16conv);
			print("3D connection size; "+ThreeDconnect);
			print("Background Subtraction %; "+subtraction);
			print("20px connection run time; "+NumConnection);
			print("MaxMIPratio; "+MaxMIPratio);
			print("gapVolRatioMaxThre; "+gapVolRatioMaxThre);
			print("");
			print("dir; "+dir);
			print("titlelist["+ititle+"]; "+titlelist[ititle]);
			
			if(titlelist[ititle]=="Mask.tif"){
				//ititle=ititle+1;
				print("Mask.tif already open");
				//			selectWindow(titlelist[ititle]);
				//			setBatchMode(false);
				//						updateDisplay();
				//						a
			}else{
				
				selectWindow(titlelist[ititle]);// CH2
				
				originalWidth=getWidth();
				originalHeight=getHeight();
				originalSlices=nSlices();
				
				print("originalWidth; "+originalWidth+"   originalHeight; "+originalHeight);
				if(ShowOriginalVol==true){
					run("Duplicate...", "title=Dup_Signal.tif duplicate");
					selectWindow(titlelist[ititle]);// CH2
				}
				
				//		setBatchMode(false);
				//		updateDisplay();
				//		a
				imagesize = round((originalWidth*originalHeight*originalSlices)/1000000);
				print("Original imagesize; "+imagesize+"  MB");
				
				shrinked=0;
				
				
				
				GPUmemsize=1900;//JAVACL
				samplesize=(getValue("image.size")/1000000);
				
				VolPercent=(samplesize/GPUmemsize)*100;
				
				
				shrinkratio=MaxGPUmemPercentage/VolPercent;
				
				print("samplesize; "+samplesize+"  GPUmemsize"+GPUmemsize+"  VolPercent; "+VolPercent);
				
				Volsize=imagesize;
				if(shrinkratio<1 || imagesize>330){// shrink image size for fitting GPU mem
					Memratio=100;
					Trueshrinkratio=1;
					while(Memratio>MaxGPUmemPercentage || imagesize>400){
						Trueshrinkratio=Trueshrinkratio-0.03;
						imagesize = ((originalWidth*Trueshrinkratio)*(originalHeight*Trueshrinkratio)*originalSlices)/1000000;
						Volsize = (imagesize*3*4);
						Memratio = Volsize / GPUmemsize * 100.0;
						//	previousTrueshrinkratio=Trueshrinkratio+0.03;
						//		print("Trueshrinkratio; "+Trueshrinkratio+"   Volsize; "+Volsize+"   GPUmemsize; "+GPUmemsize+"   Memratio; "+Memratio+"   imagesize; "+imagesize);
					}
					
					shrinkratio=Trueshrinkratio;
					
					desiredWidth=round(originalWidth*shrinkratio);
					desiredHeight=round(originalHeight*shrinkratio);
					
					if (ReduceS==false)
					run("Size...", "width="+desiredWidth+" height="+desiredHeight+" depth="+nSlices+" interpolation=Bicubic");//Bicubic None
					else
					run("Size...", "width="+desiredWidth+" height="+desiredHeight+" depth="+round(nSlices/2)+" interpolation=Bicubic");//Bicubic None
					
					shrinked=1;
					
					print("Image shrink; "+shrinkratio+" times"+"   imagesize; "+imagesize+" MB   desiredWidth; "+desiredWidth+"   desiredHeight; "+desiredHeight);
				}//if(shrinkratio<1){
				
				afshirink=getTime();
				print("Time 795 after shirink from file open; "+(afshirink-StartOpen)/1000+" sec");
				//		setBatchMode(false);
				//		updateDisplay();
				//		a
				
				//				run("Size based Noise elimination", "ignore=5 less=6");
				stack=getImageID();
				DataType="FlipOut";
				if(DataType=="Gen1 Gal4"){
					for(ilowerSlice=1; ilowerSlice<54; ilowerSlice++){
						setSlice(ilowerSlice);
						
						run("Remove Outliers...", "radius=1 threshold=5 which=Bright slice");
					}
					for(ilowerSlice2=54; ilowerSlice2<130; ilowerSlice2++){
						setSlice(ilowerSlice2);
						run("Remove Outliers...", "radius=0.5 threshold=50 which=Bright slice");
					}
				}//if(DataType=="Gen1 Gal4"){
				
				if(Oribitd==8 && bit16conv){
					oristack = getTitle();
					
					run("16-bit");
					setMinAndMax(2, 255);
					run("Apply LUT", "stack");
					run("Gamma ", "gamma=1.30 3d in=InMacro cpu="+CPUnum+"");
					
					gammastack=getTitle();
					
					selectWindow(oristack);
					close();
					
					selectWindow(gammastack);
					rename(oristack);
					bitd=16;
					print("16bit converted");
				}//if(Oribitd==8 && bit16conv){
				
				//		setBatchMode(false);
				//				updateDisplay();
				//				a
				
				
				plugindir=getDir("Plugins");
				if(File.exists(plugindir+"Anisotropic_Diffusion_2D_multi.jar"))
				run("Anisotropic Diffusion 2D multi", "number=6 smoothings=7 keep=20 a1=0.50 a2=0.90 dt=20 edge=2 threads="+CPUnum+"");
				else
				run("Anisotropic Diffusion 2D", "number=6 smoothings=7 keep=20 a1=0.50 a2=0.90 dt=20 edge=2 threads="+CPUnum+"");
				stackAni=getImageID();
				rename("itr.tif");
				
				//		setBatchMode(false);
				//				updateDisplay();
				//				a
				
				while(isOpen(titlelist[ititle])){
					selectWindow(titlelist[ititle]);// CH2
					close();
				}
				
				selectWindow("itr.tif");
				stack=getImageID();
				
				//		setBatchMode(false);
				//		updateDisplay();
				//		a
				
				wait(100);
				call("java.lang.System.gc");
				
				print("line 531 nSlices; "+nSlices);
				
				if(isOpen("Mask.tif")){
					selectWindow("Mask.tif");
					close();
				}
				
				if(tempMaskpath!=0){
					open(tempMaskpath);
					print("tempMaskpath open; "+tempMaskpath);
					
					if(shrinked==1){// shrink image
						if(ReduceS==false)
						run("Size...", "width="+desiredWidth+" height="+desiredHeight+" depth="+nSlices+" interpolation=None");//Bicubic None
						else
						run("Size...", "width="+desiredWidth+" height="+desiredHeight+" depth="+round(nSlices/2)+" average interpolation=Bicubic");//Bicubic None
					}else if (ReduceS==true)
					run("Size...", "width="+getWidth+" height="+getHeight+" depth="+round(nSlices/2)+" average interpolation=Bicubic");//Bicubic None
					
				}else{
					if(shrinked==0){
						if(ReduceS==false)
						newImage("JFRC2010_3D_Mask.nrrd", "8-bit white", originalWidth, originalHeight, originalSlices);
						else
						newImage("JFRC2010_3D_Mask.nrrd", "8-bit white", originalWidth, originalHeight, round(originalSlices/2));
					}else{
						if(ReduceS==false)
						newImage("JFRC2010_3D_Mask.nrrd", "8-bit white", desiredWidth, desiredHeight, originalSlices);
						else
						newImage("JFRC2010_3D_Mask.nrrd", "8-bit white", desiredWidth, desiredHeight, round(originalSlices/2));
					}
					print("JFRC2010_3D_Mask.nrrd created");
				}//	if(tempMaskpath!=0){
				
				maskbitd=bitDepth();
				
				if(maskbitd==8){
					run("16-bit");
					setMinAndMax(0, 255);
					run("Apply LUT", "stack");
				}
				
				masktitle=getTitle();
				
				
				//// clopping mask by volume tile ////////////////
				
				imageCalculator("AND stack", ""+masktitle+"","itr.tif");
				//		setBatchMode(false);
				//									updateDisplay();
				//								a
				
				
				setThreshold(1, 65535);
				setOption("BlackBackground", true);
				run("Convert to Mask", "method=Default background=Dark black");
				bfmasksub=getTime();
				print("Time911 before masksub from after shirink; "+(bfmasksub-afshirink)/1000+" sec");
				
				//	run("Max Filter2D", "expansion=40 cpu="+CPUnum+" xyscaling=2");
				//	run("Min Filter2D", "expansion=40 cpu="+CPUnum+" xyscaling=2");
				
				run("16-bit");
				setThreshold(1, 65535);
				
				//		setBatchMode(false);
				//					updateDisplay();
				//					a
				workdirname=substring(filename, 0, lastIndexOf(filename,"."));
				File.makeDirectory(savedir+workdirname+"/");
				
				run("Nrrd Writer", "compressed nrrd="+savedir+workdirname+"/Mask3D.nrrd");
				
				if(subtraction>0)
				run("Mask Median Subtraction", "mask="+masktitle+" data=itr.tif %="+subtraction+" subtract histogram="+AveMedian+"");
				
				updateResults();
				
				//		print(getTitle()+" open 879");
				
				//	setBatchMode(false);
				//		updateDisplay();
				//		a
				
				masksub=getTime();
				print("Time919 after masksub from after bfmasksub; "+(masksub-bfmasksub)/1000+" sec");
				
				//			setBatchMode(false);
				//				updateDisplay();
				//				a
				
				titlelist2=getList("image.titles");
				for(image=0; image<titlelist2.length; image++){
					
					if(titlelist2[image]!="itr.tif" && titlelist2[image]!="Dup_Signal.tif" && titlelist2[image]!="C2-"+filename && titlelist2[image]!="C1-"+filename && titlelist2[image]!="C3-"+filename && titlelist2[image]!=masktitle){
						selectWindow(titlelist2[image]);
						close();
						print(titlelist2[image]+"  closed");
					}
				}
				
				selectWindow("itr.tif");// CH2
				
				//			setBatchMode(false);
				//			updateDisplay();
				//			a
				
				
				lowerweight=0.7; secondjump=245;
				
				run("Z Project...", "start=30 projection=[Max Intensity]");
				rename("MIP.tif");
				getMinAndMax(min, DefMaxValue);
				MIP=getImageID();
				
				
				if(bitd==16)
				resetMinAndMax();
				desiredmean=210; multiDSLT=1;
				
				briadj=newArray(desiredmean, 0, 0, 0,lowerweight,DefMaxValue,MIP,stack,multiDSLT,secondjump);
				autobradjustment(briadj);
				applyV=briadj[2];
				sigsize=briadj[1];
				sigsizethre=briadj[3];
				sigsizethre=round(sigsizethre);
				sigsize=round(sigsize);
				
				if(isOpen("test.tif")){
					selectWindow("test.tif");
					close();
				}
				
				if(isOpen("MIP.tif")){
					selectWindow("MIP.tif");
					close();
				}
				if(BrightnessApply){
					
					if(bitd==8){
						if(applyV!=255 && applyV!=0){
							setMinAndMax(0, applyV);
							run("Apply LUT", "stack");
							print("Brightness changed; "+applyV);
						}
					}else{
						
						selectImage(stack);
						setMinAndMax(0, applyV);
						run("Apply LUT", "stack");
						run("A4095 normalizer", "subtraction=1 start=1 end="+nSlices+"");
						print("12 bit adjusted");
					}
				}//if(BrightnessApply){
				selectWindow("itr.tif");
				
				originalSliceNum=nSlices();//round(nSlices/2);
				print(originalSliceNum);
				
				//			setBatchMode(false);
				//			updateDisplay();
				//			a
				
				if(isOpen("Mask.tif"))
				print("Mask.tif open line 336");
				else
				print("Mask.tif not open line 338");
				
				if(isOpen("itr.tif"))
				print(""+"itr.tif"+" open line 341");
				else
				print(""+"itr.tif"+" not open line 343");
				
				print("579 nImages open; "+nImages+" sigsize; "+sigsize);
				
				rename("DSLT_score.tif");
				
				
				
				
				run("Nrrd Writer", "compressed nrrd="+savedir+workdirname+"/"+truname+".nrrd");
				
				selectWindow("Dup_Signal.tif");
				run("Nrrd Writer", "compressed nrrd="+savedir+workdirname+"/original.nrrd");
				
				tempMaskpath=savedir+workdirname+"/Mask3D.nrrd";
				
				File.saveString(sigsize+"\n"+originalWidth+"\n"+originalHeight+"\n"+originalSlices+"\n"+Oribitd+"\n"+VxHeight+"\n"+VxWidth+"\n"+VxDepth+"\n"+tempMaskpath+"\n"+channels+"\n"+shrinked+"\n"+imagesize+"\n"+nrrdIndex+"\n"+TISSUE+"\n"+fullpath+"\n"+dir+"\n"+filename+"\n", savedir+workdirname+"/"+truname+".txt"); //- Saves string as a file. 
				//		File.rename(fullpath, dir+"done/"+filename);
				run("Close All");
				
				if(testarg==0){
					run("Misc...", "divide=Infinity save");
					break;
					run("Quit");
				}
				
			}//	if(titlelist[ititle]=="Mask.tif"){
		}//	for(ititle=0; ititle<endlist; ititle++){
		
		
		run("Close All");
	}else{
		if(isOpen(filename)){
			selectWindow(filename);
			close();
		}
		
	}//	if(nc82Nrrd==-1){
	
	endtime=getTime();
	gapmin=(endtime-starttime)/(1000*60);
	print(gapmin+" min processing time");
	
	Done2=getTime();
	
	logsum=getInfo("log");
	
	
	//	File.saveString(logsum, filepath);
	print("\\Clear");
	
	
}//if(endsWith(filename,".tif") || endsWith(filename,".nrrd") || endsWith(filename,".h5j") || endsWith(filename,".v3dpbd")){


function brightnessapply(applyV, bitd,lowerweight,stack,JFRCpath,VncMaskpath){
	stacktoApply=getTitle();
	
	
	if(bitd==8){
		if(applyV<255){
			setMinAndMax(0, applyV);
			
			if(applyV<secondjump){
				run("Z Project...", "projection=[Max Intensity]");
				MIPapply=getTitle();
				
				setMinAndMax(0, applyV);
				run("Apply LUT");
				
				if(getHeight==512 && getWidth==1024){
					
					tissue="Brain";
					BackgroundMask (tissue,JFRCpath,VncMaskpath,MIPapply,bitd);
					
				}else if (getHeight==1024 && getWidth==512){// VNC
					
					tissue="VNC";
					BackgroundMask (tissue,JFRCpath,VncMaskpath,MIPapply,bitd);
					
				}//	if(getHeight==512 && getWidth==1024){
				
				getHistogram(values, counts,  256);
				for(i3=0; i3<200; i3++){
					
					sumave=0;
					for(peakave=i3; peakave<i3+5; peakave++){
						Val=counts[peakave];
						sumave=sumave+Val;
					}
					aveave=sumave/5;
					
					if(aveave>maxcounts){
						
						maxcounts=aveave;
						maxi=i3+2;
						print("GrayValue; "+i3+"  "+aveave+"  maxi; "+maxi);
					}
				}//for(i3=0; i3<200; i3++){
				if(maxi!=2)
				changelower=maxi*lowerweight;
				else
				changelower=0;
				
				//		if(changelower>100)
				//		changelower=100;
				
				selectWindow(MIPapply);
				close();
				
				selectWindow(stacktoApply);
				setMinAndMax(0, applyV);//brightness adjustment
				run("Apply LUT", "stack");
				
				
				if(changelower>0){
					changelower=round(changelower);
					
					setMinAndMax(changelower, 255);//lowthre cut
					run("Apply LUT", "stack");
				}else
				changelower=0;
				print("  lower threshold; 	"+changelower);
			}
		}
	}
	if(bitd==16){
		
		applyV2=applyV;
		if(applyV==4095)
		applyV2=4094;
		
		selectImage(stack);
		run("Z Project...", "projection=[Max Intensity]");
		MIP2=getImageID();
		getMinAndMax(min, max);
		
		minus=0;
		while(max<65530){
			minus=minus+50;
			selectImage(MIP2);//MIP
			run("Duplicate...", "title=MIPDUP.tif");
			
			//		print("premax; "+max+"premin; "+min);
			run("Histgram stretch", "lower="+min+" higher="+applyV2-minus+"");//histogram stretch	
			getMinAndMax(min, max);
			//	print("postmax; "+max+"postmin; "+min);
			close();
		}
		selectImage(MIP2);//MIP
		close();
		selectImage(stack);
		stackSt=getTitle();
		
		run("Histgram stretch", "lower=0 higher="+applyV2-minus+" 3d");//histogram stretch
		
		if(isOpen("full.tif")==0);
		newImage("full.tif", "8-bit white", getWidth, getHeight, nSlices);
		
		run("Mask Median Subtraction", "mask=full.tif data="+stackSt+" histogram=300");
		
		selectWindow("full.tif");
		close;
		
		selectImage(stack);
		
		countregion=35500;
		
		run("Z Project...", "projection=[Max Intensity]");
		MIPthresholding=getTitle();
		//	setBatchMode(false);
		//	updateDisplay();
		//	a
		
		if(getHeight==512 && getWidth==1024){
			tissue="Brain";
			BackgroundMask (tissue,JFRCpath,VncMaskpath,MIPthresholding,bitd);
			
		}else if (getHeight==1024 && getWidth==512){
			tissue="VNC";
			BackgroundMask (tissue,JFRCpath,VncMaskpath,MIPthresholding,bitd);
			
		}//	if(getHeight==512 && getWidth==1024){
		
		//// lower thresholding //////////////////////////////////	
		maxi=0;
		
		run("Gaussian Blur...", "sigma=2");
		maxcounts=0; medianNum=400;
		getHistogram(values, counts,  65530);
		for(i3=5; i3<countregion-medianNum; i3++){
			
			sumVal20=0; 
			
			for(aveval=i3; aveval<i3+medianNum; aveval++){
				Val20=counts[aveval];
				sumVal20=sumVal20+Val20;
			}
			AveVal20=sumVal20/medianNum;
			
			if(AveVal20>maxcounts){
				maxcounts=AveVal20;
				maxi=i3+100;
			}
		}
		
		changelower = 0;
		if (maxi>9000)
		changelower=maxi*0.9;
		else if (maxi>6000 && maxi<=9000)
		changelower=maxi*0.6;
		else if (maxi>3500 && maxi<=6000)
		changelower=maxi*0.2;
		
		print("lower threshold; 	"+changelower+"   maxi; "+maxi);
		
		close();
		selectWindow(stacktoApply);
		changelower=round(changelower);
		setMinAndMax(changelower, 65535);//subtraction
		
		run("8-bit");
	}//if(bitd==16){
}//function brightnessapply(applyV, bitd){

function autobradjustment(briadj){
	DOUBLEdslt=0;
	desiredmean=briadj[0];
	lowerweight=briadj[4];
	DefMaxValue=briadj[5];
	MIP=briadj[6];
	stack=briadj[7];
	multiDSLT=briadj[8];
	secondjump=briadj[9];
	
	bitd=bitDepth();
	run("Properties...", "channels=1 slices=1 frames=1 unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
	getDimensions(width2, height2, channels, slices, frames);
	totalpix=width2*height2;
	
	run("Select All");
	if(bitd==8){
		run("Copy");
	}
	
	if(bitd==16){
		setMinAndMax(0, DefMaxValue);
		run("Copy");
	}
	/////////////////////signal size measurement/////////////////////
	selectImage(MIP);
	run("Duplicate...", "title=test2.tif");
	setAutoThreshold("Triangle dark");
	getThreshold(lower, upper);
	setThreshold(lower, DefMaxValue);//is this only for 8bit??
	
	run("Convert to Mask", "method=Triangle background=Dark black");
	
	selectWindow("test2.tif");
	
	if(bitd==16)
	run("8-bit");
	
	run("Create Selection");
	getStatistics(areathre, mean, min, max, std, histogram);
	if(areathre!=totalpix){
		if(mean<200){
			selectWindow("test2.tif");
			run("Make Inverse");
		}
	}
	getStatistics(areathre, mean, min, max, std, histogram);
	close();//test2.tif
	
	
	if(areathre/totalpix>0.4){
		
		selectImage(MIP);
		
		run("Duplicate...", "title=test2.tif");
		setAutoThreshold("Moments dark");
		getThreshold(lower, upper);
		setThreshold(lower, DefMaxValue);
		
		run("Convert to Mask", "method=Moments background=Dark black");
		
		selectWindow("test2.tif");
		
		if(bitd==16)
		run("8-bit");
		
		run("Create Selection");
		getStatistics(areathre, mean, min, max, std, histogram);
		if(areathre!=totalpix){
			if(mean<200){
				selectWindow("test2.tif");
				run("Make Inverse");
			}
		}
		getStatistics(areathre, mean, min, max, std, histogram);
		close();//test2.tif
		
	}//if(area/totalpix>0.4){
	
	/////////////////////Fin signal size measurement/////////////////////
	
	selectImage(MIP);
	sizediff=0;
	dsltarray=newArray(bitd, totalpix, desiredmean, 0,multiDSLT,sizediff);
	DSLTfun(dsltarray);
	desiredmean=dsltarray[2];
	area2=dsltarray[3];
	sizediff=dsltarray[5];
	//////////////////////
	
	selectImage(MIP);//MIP
	getMinAndMax(min1, max);
	if(max>4095){//16bit
		minus=0;
		getMinAndMax(min, max1);
		while(max<65530){
			minus=minus+100;
			selectImage(MIP);//MIP
			run("Duplicate...", "title=MIPDUP.tif");
			
			
			//		print("premax; "+max+"premin; "+min);
			run("Histgram stretch", "lower=0 higher="+max1-minus+"");//histogram stretch	\
			getMinAndMax(min, max);
			//		print("postmax; "+max+"postmin; "+min);
			close();
		}
		
		//		print("minus; "+minus);
		
		selectImage(MIP);//MIP
		run("Histgram stretch", "lower="+min1+" higher="+max1-minus-100+"");//histogram stretch	\
		getMinAndMax(min, max);
		//		print("after max; "+max);
		
		selectImage(stack);
		run("Histgram stretch", "lower="+min1+" higher="+max1-minus-100+" 3d");//histogram stretch	
		selectImage(MIP);//MIP
	}//if(max>4095){//16bit
	
	run("Mask Brightness Measure", "mask=test.tif data=MIP.tif desired="+desiredmean+"");
	selectImage(MIP);//MIP
	
	fff=getTitle();
	//	print("fff 1202; "+fff);
	applyvv=newArray(1,bitd,stack,MIP);
	applyVcalculation(applyvv);
	applyV=applyvv[0];
	
	selectImage(MIP);//MIP
	
	
	if(fff=="MIP.tif"){
		if(bitd==16)
		applyV=400;
		
		if(bitd==8)
		applyV=40;
		
	}
	
	rename("MIP.tif");//MIP
	
	selectWindow("test.tif");//new window from DSLT
	close();
	/////////////////2nd time DSLT for picking up dimmer neurons/////////////////////
	
	
	if(applyV>50 && applyV<secondjump && bitd==8 && DOUBLEdslt==1){
		applyVpre=applyV;
		selectImage(MIP);
		
		setMinAndMax(0, applyV);
		
		run("Duplicate...", "title=MIPtest.tif");
		
		setMinAndMax(0, applyV);
		run("Apply LUT");
		maxcounts=0; maxi=0;
		getHistogram(values, counts,  256);
		for(i=0; i<100; i++){
			Val=counts[i];
			
			if(Val>maxcounts){
				maxcounts=counts[i];
				maxi=i;
			}
		}
		
		changelower=maxi*lowerweight;
		if(changelower<1)
		changelower=1;
		
		selectWindow("MIPtest.tif");
		close();
		
		selectImage(MIP);
		setMinAndMax(0, applyV);
		run("Apply LUT");
		
		setMinAndMax(changelower, 255);
		run("Apply LUT");
		
		print("LowerThreshold; "+changelower);
		print("Double DSLT");
		//	run("Multibit thresholdtwo", "w/b=Set_black max=207 in=[In macro]");
		
		desiredmean=secondjump;//230 for GMR
		
		dsltarray=newArray(bitd, totalpix, desiredmean, 0, multiDSLT,sizediff);
		DSLTfun(dsltarray);//will generate test.tif DSLT thresholded mask
		desiredmean=dsltarray[2];
		area2=dsltarray[3];
		sizediff=dsltarray[5];
		
		selectImage(MIP);//MIP
		
		run("Mask Brightness Measure", "mask=test.tif data=MIP.tif desired="+desiredmean+"");
		
		selectImage(MIP);//MIP
		
		fff=getTitle();
		//	print("fff 1279; "+fff);
		
		applyvv=newArray(1,bitd,stack,MIP);
		applyVcalculation(applyvv);
		applyV=applyvv[0];
		
		if(applyVpre<applyV){
			applyV=applyVpre;
			print("previous applyV is brighter");
		}
		
		selectImage(MIP);//MIP
		rename("MIP.tif");//MIP
		close();
		
		selectWindow("test.tif");//new window from DSLT
		close();
	}//	if(applyV>50 && applyV<150 && bitd==8){
	
	if(isOpen("test.tif")){
		selectWindow("test.tif");
		close();
	}
	
	sigsize=area2/totalpix;
	if(sigsize==1)
	sigsize=0;
	
	if(sizediff>10 && sigsize>0.1)
	sigsize=0.21;
	else if(sizediff>10 && sigsize<=0.1)
	sigsize=0.15;
	
	sigsizethre=areathre/totalpix;
	
	print("    Signal brightness; 	"+applyV+"	 Signal Size DSLT; 	"+sigsize+"	 Sig size threshold; 	"+sigsizethre);
	briadj[1]=(sigsize)*100;
	briadj[2]=applyV;
	briadj[3]=sigsizethre*100;
}//function autobradjustment

function DSLTfun(dsltarray){
	
	bitd=dsltarray[0];
	totalpix=dsltarray[1];
	desiredmean=dsltarray[2];
	multiDSLT=dsltarray[4];
	
	CLEAR_MEMORY();
	
	if(bitd==8)
	//	run("DSLT ", "radius_r_max=4 radius_r_min=2 radius_r_step=2 rotation=6 weight=14 filter=GAUSSIAN close=None noise=5px");
	run("DSLT ", "radius_r_max=15 radius_r_min=1 radius_r_step=5 rotation=8 weight=3 filter=MEAN close=None noise=7px");
	
	if(bitd==16){
		run("DSLT ", "radius_r_max=15 radius_r_min=1 radius_r_step=5 rotation=8 weight=100 filter=MEAN close=None noise=10px");
		
		run("16-bit");
		run("Mask255 to 4095");
	}
	rename("test.tif");//new window from DSLT
	selectWindow("test.tif");
	
	//setBatchMode(false);
	//	updateDisplay();
	//	a
	
	run("Duplicate...", "title=test2.tif");
	selectWindow("test2.tif");
	
	if(bitd==16)
	run("8-bit");
	
	a=getWidth();
	b=getHeight();
	
	startXscan=0;
	endX=a;
	
	if(a==1024 && b==512){/// JFRC2010
		startXscan=210;
		endX=800;
	}
	area1=0;
	for(iaa=startXscan; iaa<endX; iaa++){
		for(ibb=0; ibb<b; ibb++){
			if(getPixel(iaa,ibb)!=0)
			area1=area1+1;
		}
	}
	close();//test2.tif
	
	//	print("Area 1412;  "+area+"   mean; "+mean);
	
	presize=area1/totalpix;
	
	if(area1==totalpix){
		presize=0.0001;
		print("Equal");
	}
	print("Area 1st time;  "+area1+"   mean; "+mean+"  totalpix; "+totalpix+"   presize; "+presize+"   bitd; "+bitd);
	realArea=area1;
	sizediff=1;
	
	if(multiDSLT==1 && area1!=0){
		if(presize<0.13){// set DSLT more sensitive, too dim images, less than 5%
			selectWindow("test.tif");//new window from DSLT
			close();
			
			if(isOpen("test.tif")){
				selectWindow("test.tif");
				close();
			}
			
			selectWindow("MIP.tif");//MIP
			
			//				setBatchMode(false);
			//		updateDisplay();
			//		a
			CLEAR_MEMORY();
			if(bitd==8){
				//run("DSLT ", "radius_r_max=4 radius_r_min=2 radius_r_step=2 rotation=6 weight=5 filter=GAUSSIAN close=None noise=10px");
				run("DSLT ", "radius_r_max=15 radius_r_min=1 radius_r_step=5 rotation=8 weight=2 filter=MEAN close=None noise=7px");
				
			}
			if(bitd==16)
			run("DSLT ", "radius_r_max=15 radius_r_min=1 radius_r_step=5 rotation=8 weight=24 filter=MEAN close=None noise=10px");
			
			a=getWidth();
			b=getHeight();
			
			startXscan=0;
			endX=a;
			
			if(a==1024 && b==512){/// JFRC2010
				startXscan=210;
				endX=800;
			}
			
			area2=0;
			for(iaaa=startXscan; iaaa<endX; iaaa++){
				for(ibbb=0; ibbb<b; ibbb++){
					if(getPixel(iaaa,ibbb)!=0)
					area2=area2+1;
				}
			}
			
			if(bitd==16){
				run("16-bit");
				run("Mask255 to 4095");
			}//if(bitd==16){
			
			
			rename("test.tif");//new window from DSLT
			run("Select All");
			print("2nd size;"+area2/totalpix);
			realArea=area2;
			
			sizediff=(area2/totalpix)/presize;
			print("2nd_sizediff; 	"+sizediff+" times");
			if(bitd==16){
				if(sizediff>1.3 && 0.2>area2/totalpix){
					repeatnum=(sizediff-1)*10;
					oriss=1;
					
					for(rep=1; rep<repeatnum+1; rep++){
						oriss=oriss+oriss*0.11;
					}
					weight=oriss/3;
					desiredmean=desiredmean+(desiredmean/4)*weight;
					desiredmean=round(desiredmean);
					
					if(desiredmean>secondjump || desiredmean==NaN)
					desiredmean=secondjump;
					
					print("desiredmean; 	"+desiredmean+"	 sizediff; "+sizediff+"	 weight *25%;"+(desiredmean/4)*weight);
				}
			}else if(bitd==8){
				if(sizediff>2){
					repeatnum=(sizediff-1);//*10
					oriss=1;
					
					for(rep=1; rep<=repeatnum+1; rep++){
						oriss=oriss+oriss*0.08;
					}
					weight=oriss/7;
					desiredmean=desiredmean+(desiredmean/7)*weight;
					desiredmean=round(desiredmean);
					
					if(desiredmean>225)
					desiredmean=secondjump;
					
					print("desiredmean; 	"+desiredmean+"	 sizediff; "+sizediff+"	 weight *25%;"+(desiredmean/4)*weight);
				}
			}
		}//if(area2/totalpix<0.01){
	}//	if(multiDSLT==1){
	
	
	dsltarray[2]=desiredmean;
	dsltarray[3]=realArea;
	dsltarray[5]=sizediff;
}//function DSLTfun

function applyVcalculation(applyvv){
	bitd=applyvv[1];
	stack=applyvv[2];
	MIP=applyvv[3];
	
	selectImage(MIP);//MIP
	applyV=getTitle();
	
	if(applyV=="MIP.tif")
	applyV=200;
	
	applyV=round(applyV);
	run("Select All");
	getMinAndMax(min, max);
	
	//print("applyV max; "+max+"   bitd; "+bitd+"   applyV; "+applyV);
	
	if(bitd==8){
		applyV=255-applyV;
		
		if(applyV==0)
		applyV=255;
		else if(applyV<20)
		applyV=20;
	}else if(bitd==16){
		
		if(max<=4095)
		applyV=4095-applyV;
		
		if(max>4095)
		applyV=65535-applyV;
		
		if(applyV==0)
		applyV=max;
		else if(applyV<150)
		applyV=1500;
	}
	applyvv[0]=applyV;
}

function ThreeDVol(ThreeDVolArray){
	
	masktitle=ThreeDVolArray[7];
	savepath=ThreeDVolArray[8];
	sigsize=ThreeDVolArray[9];
	weight=ThreeDVolArray[10];
	VolPercent=ThreeDVolArray[11];
	pngsave=ThreeDVolArray[12];
	
	sumDW=0; sumUP=0; sumFront1=0; sumFront=0; sumpost=0; sum=0;
	sttime=getTime();
	totalSli=nSlices();
	voltitle = getTitle();
	
	a=getWidth();
	b=getHeight();
	
	usemask=1;
	
	if(usemask==0){
		if(a>b){//brain
			X1start=round(a/5); X1end=round(4*(a/5)); StSlice=18; Yend=round(b/3); EdSlice=totalSli;
			X2start=round(a/10); X2end=a-round(a/10);
			SliceMiddle=round(totalSli/2-2); Y2end=b-(b/10);
			
			if(a==512){
				X1start=105;
				X1end=400;
				
				X2start=48;//143 for non op
				X2end=480;//383 for non op
				StSlice=18;
				EdSlice=102;
				
				SliceMiddle=50;
				
				Yend=115;
				Y2end=222;
			}
			
			print("X1start; "+X1start+"  X1end; "+X1end+"   Yend; "+Yend+"   EdSlice; "+EdSlice+"   X2start; "+X2start+"   X2end; "+X2end);
			sumtotal=0;
			for(isli=StSlice; isli<=EdSlice; isli++){
				
				setSlice(isli);
				for(ia=X1start; ia<X1end; ia++){//upper brain
					for(ib=0; ib<Yend; ib++){
						if(getPixel(ia,ib)!=0){
							sumUP=sumUP+1;
							sum=sum+1;
						}
						//	sumtotal=sumtotal+1;
					}
				}
				for(ia=X2start; ia<X2end; ia++){//lower brain
					for(ib=Yend+1; ib<Y2end; ib++){
						if(getPixel(ia,ib)!=0){
							sumDW=sumDW+1;
							sum=sum+1;
						}
						//	sumtotal=sumtotal+1;
					}
				}
			}//	for(isli=StSlice; isli<=EdSlice; isli++){
			halfF=round(SliceMiddle/2);
			print("halfF; "+halfF);
			for(isli2=StSlice-4; isli2<SliceMiddle+1; isli2++){//Frontal
				setSlice(isli2);
				
				
				if(isli2<=halfF){
					for(ia=X1start; ia<X1end; ia++){//upper brain
						for(ib=0; ib<Yend; ib++){
							if(getPixel(ia,ib)!=0){
								sumFront1=sumFront1+1;
								sumFront=sumFront+1;
							}
						}
					}
					for(ia=X2start; ia<X2end; ia++){//lower brain
						for(ib=Yend+1; ib<Y2end; ib++){
							if(getPixel(ia,ib)!=0){
								sumFront1=sumFront1+1;
								sumFront=sumFront+1;
							}
						}
					}
				}else if (isli2>halfF){//if(isli2<=round(SliceMiddle/2)){
					for(ia=X1start; ia<X1end; ia++){//upper brain
						for(ib=0; ib<Yend; ib++){
							if(getPixel(ia,ib)!=0)
							sumFront=sumFront+1;
						}
					}
					for(ia=X2start; ia<X2end; ia++){//lower brain
						for(ib=Yend+1; ib<Y2end; ib++){
							if(getPixel(ia,ib)!=0)
							sumFront=sumFront+1;
						}
					}
					
				}
			}
			
			stacktitle=getTitle();
			
			MIPsum=0; totalMIPsum=0;
			run("Z Project...", "projection=[Max Intensity]");
			for(ia2=X2start; ia2<X2end; ia2++){//upper brain
				for(ib2=b/10; ib2<b/2; ib2++){
					if(getPixel(ia2,ib2)!=0){
						MIPsum=MIPsum+1;
					}
					totalMIPsum=totalMIPsum+1;
				}
			}
			close();
			
			selectWindow(stacktitle);
			
			for(isli3=SliceMiddle+1; isli3<EdSlice; isli3++){//Posterior
				setSlice(isli3);
				
				for(ia=X1start; ia<X1end; ia++){//posterior upper brain
					for(ib=0; ib<Yend; ib++){
						if(getPixel(ia,ib)!=0)
						sumpost=sumpost+1;
					}
				}
				for(ia=X2start; ia<X2end; ia++){//posterior lower brain
					for(ib=Yend+1; ib<Y2end; ib++){
						if(getPixel(ia,ib)!=0)
						sumpost=sumpost+1;
					}
				}
			}
			
			edtime=getTime();
			gap=(edtime-sttime)/1000;
			
			VolPercent=(sum/((((X1end-X1start)*(Yend+1))+((X2end-X2start)*(b-Yend+1)))*(EdSlice-StSlice)))*100;
			print("Total sum; "+sum+" vol,   "+VolPercent+" %,   "+gap+" sec  ");
			
			VolPercentUP=(sumUP/(((X1end-X1start)*(Yend+1))*(EdSlice-StSlice)))*100;
			print("Upper sum; "+sumUP+" vol,   "+VolPercentUP+" %");
			
			VolPercentDW=(sumDW/(((X2end-X2start)*(b-Yend+1))*(EdSlice-StSlice)))*100;
			print("Lower sum; "+sumDW+" vol,   "+VolPercentDW+" %");
			
			VolPercentF=(sumFront/((((X1end-X1start)*(Yend+1))+((X2end-X2start)*(b-Yend+1)))*(SliceMiddle+1-StSlice-4)))*100;
			print("Frontal sum; "+sumFront+" vol,   "+VolPercentF+" %");
			
			VolPercentF2=(sumFront1/((((X1end-X1start)*(Yend+1))+((X2end-X2start)*(b-Yend+1)))*(halfF+1-StSlice-4)))*100;
			print("Frontal2 sum; "+sumFront1+" vol,   "+VolPercentF2+" %");
			
			VolPercentR=(sumpost/((((X1end-X1start)*(Yend+1))+((X2end-X2start)*(b-Yend+1)))*(EdSlice-halfF+1)))*100;
			print("Posterior sum; "+sumpost+" vol,   "+VolPercentR+" %,   "+gap+" sec  ");
			print("Fratio; "+VolPercentF/VolPercent);
		}//if brain
	}
	if(b>=a || usemask==1){// VNC
		run("Mask vol measure", "volume="+voltitle+" 3d="+masktitle+"");
		volnum = call("Mask_vol_measure.getResult");
		volnum = parseFloat(volnum);//Chaneg string to number
		
		
		selectWindow(masktitle);
		run("ThreeD vol measure", "measure=0");
		maskvol = call("ThreeD_vol_measure.getResult");
		maskvol = parseFloat(maskvol);//Chaneg string to number
		
		
		edtime=getTime();
		gap=(edtime-sttime)/1000;
		
		VolPercent=(volnum/maskvol)*100;
		print("Neuron vol:   "+VolPercent+" %,   "+gap+" sec  ");
		
		selectWindow(voltitle);
		run("Z Project...", "projection=[Max Intensity]");
		volMIP=getTitle();
		setMinAndMax(0, 1);
		run("Apply LUT");
		
		selectWindow(masktitle);
		run("Z Project...", "projection=[Max Intensity]");
		maskMIP=getTitle();
		
		imageCalculator("AND create", ""+volMIP+"",""+maskMIP+"");
		ANDresult = getTitle();
		MIPsum=0; totalMIPsum=0;
		
		for(ix=0; ix<a; ix++){
			for(iy=0; iy<b; iy++){
				if(getPixel(ix,iy)!=0){
					MIPsum=MIPsum+1;
				}
			}
		}
		if(pngsave==1)
		saveAs("PNG", ""+savepath+"_"+sigsize+"_2Dsize,__"+weight+"_weight,__"+VolPercent+"_Sig_MIP.png");//save 20x MIP
		close();
		selectWindow(volMIP);
		close();
		
		selectWindow(maskMIP);
		for(ix=0; ix<a; ix++){
			for(iy=0; iy<b; iy++){
				if(getPixel(ix,iy)!=0){
					totalMIPsum=totalMIPsum+1;
				}
			}
		}
		if(pngsave==1)
		saveAs("PNG", ""+savepath+"_"+sigsize+"_2Dsize,__"+weight+"_weight,__"+VolPercent+"_MSK_MIP.png");//save 20x MIP
		close();
		
		ed2time=getTime();
		gap2=(ed2time-edtime)/1000;
		print("MIP vol measurement time; "+gap2);
		
		selectWindow(voltitle);
		
		VolPercentUP=0;
		VolPercentDW=0;
		VolPercentF=0;
		VolPercentR=0;
		VolPercentF2=0;
	}//if(b>=a){// VNC
	MIPratio = MIPsum / totalMIPsum;
	print("MIPratio; "+MIPratio);
	print("");
	//	setBatchMode(false);
	//						updateDisplay();
	//						a
	
	
	ThreeDVolArray[0]=VolPercent;
	ThreeDVolArray[1]=VolPercentUP;
	ThreeDVolArray[2]=VolPercentDW;
	ThreeDVolArray[3]=VolPercentF;
	ThreeDVolArray[4]=VolPercentR;
	ThreeDVolArray[5]=VolPercentF2;
	ThreeDVolArray[6]=MIPratio;
}

function Score3D (stack,temppath,tempMaskpath,tempname,CPUnum){
	selectImage(stack);
	stackname=getTitle();
	
	tempopen=isOpen(tempname);
	if(tempopen!=1)
	open(temppath);
	
	run("ObjPearson Coeff", "template="+tempname+" sample="+stackname+" show weight=[Equal weight (temp and sample)] parallel="+CPUnum+"");
	
	selectWindow(tempname);
	close();
}

function slicefill (sliceposition){
	setSlice(sliceposition);
	run("Fill", "slice");
	setSlice(sliceposition+1);
	run("Fill", "slice");
	setSlice(sliceposition-1);
	run("Fill", "slice");
}

function Vx3Dconnection (NumConnection,CPUnum,connectionArray,shrinked,ReduceS){
	
	
	for(iconnect=1; iconnect<=NumConnection; iconnect++){
		Ori3Dstack = getTitle();
		
		CLEAR_MEMORY();
		
		BeforeDSLT=nImages();
		run("Connect Flagments", "radius=20");
		rename("connected"+iconnect+".tif");
		
		AfterDSLT=nImages();
		
		if(BeforeDSLT==AfterDSLT){
			print("20 vx connection is not working");
			
			DSLTnum=1;
			while(BeforeDSLT==AfterDSLT){
				selectWindow("DSLTmask.tif");
				run("Connect Flagments", "radius=20");
				
				AfterDSLT=nImages();
				DSLTnum=DSLTnum+1;
				
				print("20x connection is not working; "+DSLTnum);
				
				if(DSLTnum==6)
				exit("20x connection fail x6");
			}//	while(BeforeDSLT==AfterDSLT){
		}
		
		GPUconnect1 = getTitle();
		
		if(isOpen(Ori3Dstack)){
			selectWindow(Ori3Dstack);
			close();
		}
		
		selectWindow(GPUconnect1);
	}
	
	if(shrinked==0 && ReduceS==false){
		/// noise deletion ///////////////////////
		run("Connecting Components seg CPU", "ignore=1 minimum=30 thread="+CPUnum+"");
		GPUconnect = getTitle();
		
		while(isOpen(GPUconnect1)){
			selectWindow(GPUconnect1);
			close();
		}
		connectionArray[0] = GPUconnect;
	}else
	connectionArray[0] = GPUconnect1;
	
	
}

function CLEAR_MEMORY() {
	d=call("ij.IJ.maxMemory");
	e=call("ij.IJ.currentMemory");
	for (trials=0; trials<3; trials++) {
		wait(100);
		call("java.lang.System.gc");
	}
}

if(moveafterdone==1){
	if(File.exists(dir+"done/")!=1)
	File.makeDirectory(dir+"done/");
	
	
	//File.rename(fullpath, dir+"done/"+filename); // - Renames, or moves, a file or directory. Returns "1" (true) if successful. 
}

run("Misc...", "divide=Infinity save");
run("Close All");
run("Quit");






"Done"