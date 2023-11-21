
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
deleteeverything=1;

JunkNrrd=1;// 1 will write junk nrrd file, CirRatio<=0.32 &&

DataType="MCFO";//"Gen1 Gal4","MCFO",VNC_MCFO,"Kei_Th","MCFO_sensitive"

if(DataType=="Gen1 Gal4"){
	MaxMIPratio=0.5;//" (0.36 for GAL4, 0.28 for split & MCFO, 0.19 for larva)"0.6 is for messy line, 0.65 is Reed class4
	gapMIPratioThre=0.07;//0.047 is more specific MCFO; 0.07 is MCFO class4 Reed brain, 0.01 is larva
	ThreratioMIPweight=0.04;// 0.00111 is specific split/MCFO, 0.0025 is for class4 Reed, 0.015 gen1 GAL4
	MaxVolPercent=11;
}else if(DataType=="MCFO"){
	MaxMIPratio=0.28;//" (0.36 for GAL4, 0.28 for split & MCFO, 0.19 for larva)"0.6 is for messy line, 0.65 is Reed class4
	gapMIPratioThre=0.047;//0.047 is more specific MCFO; 0.07 is MCFO class4 Reed brain, 0.01 is larva
	ThreratioMIPweight=0.00111;// 0.00111 is specific split/MCFO, 0.0025 is for class4 Reed, 0.015 gen1 GAL4
	MaxVolPercent=4;
}else if(DataType=="VNC_MCFO"){
	MaxMIPratio=0.4;//" (0.36 for GAL4, 0.28 for split & MCFO, 0.19 for larva)"0.6 is for messy line, 0.65 is Reed class4
	gapMIPratioThre=0.07;//0.047 is more specific MCFO; 0.07 is MCFO class4 Reed brain, 0.01 is larva
	ThreratioMIPweight=0.04;// 0.00111 is specific split/MCFO, 0.0025 is for class4 Reed, 0.015 gen1 GAL4
	MaxVolPercent=7;
}else if(DataType=="Kei_Th"){
	MaxMIPratio=0.8;//" (0.36 for GAL4, 0.28 for split & MCFO, 0.19 for larva)"0.6 is for messy line, 0.65 is Reed class4
	gapMIPratioThre=0.1;//0.047 is more specific MCFO; 0.07 is MCFO class4 Reed brain, 0.01 is larva
	ThreratioMIPweight=0.07;// 0.00111 is specific split/MCFO, 0.0025 is for class4 Reed, 0.015 gen1 GAL4
	MaxVolPercent=15;
}else if(DataType=="MCFO_sensitive"){
	MaxMIPratio=0.45;//" (0.36 for GAL4, 0.28 for split & MCFO, 0.19 for larva)"0.6 is for messy line, 0.65 is Reed class4
	gapMIPratioThre=0.07;//0.047 is more specific MCFO; 0.07 is MCFO class4 Reed brain, 0.01 is larva
	ThreratioMIPweight=0.0025;// 0.00111 is specific split/MCFO, 0.0025 is for class4 Reed, 0.015 gen1 GAL4
	MaxVolPercent=4;
}else if(DataType=="Split"){
	MaxMIPratio=0.1;//" (0.36 for GAL4, 0.28 for split & MCFO, 0.19 for larva)"0.6 is for messy line, 0.65 is Reed class4
	gapMIPratioThre=0.03;//0.047 is more specific MCFO; 0.07 is MCFO class4 Reed brain, 0.01 is larva
	ThreratioMIPweight=0.0005;// 0.00111 is specific split/MCFO, 0.0025 is for class4 Reed, 0.015 gen1 GAL4
	MaxVolPercent=2;
}

ExM=0;
simplefilenameExp=true; // simple file name save

run("Misc...", "divide=Infinity save");

samplenametrue="JRC_SS22721-20160701_22_A3-f_63x-CH2";

//testarg="E:/RyoSeg/JRC_SS25540_20161014_27_D4_REG_UNISEX_63x_m_BrainC2.nrrd,E:/RyoSeg/,G:/Template_MIP/,0.188,0.38";
//testarg="A:/test/"+samplenametrue+"/"+samplenametrue+".nrrd,A:/test/,G:/Template_MIP/,A:/test/"+samplenametrue+"/"+samplenametrue+".txt";

afshirink=getTime();

if(testarg==0)
args = split(getArgument(),",");
else{
	args = split(testarg,",");
	CPUnum=15;
}
fullpath0=args[0];
savedir=args[1];
JFRCMaskDir=args[2];
TextPath=args[3];

print("fullpath0; "+fullpath0);
print("savedir; "+savedir);
print("JFRCMaskDir; "+JFRCMaskDir);
print("TextPath; "+TextPath);

sepIndex=lastIndexOf(fullpath0,"/");

dir=substring(fullpath0,0,sepIndex+1);
filename=substring(fullpath0,sepIndex+1,lengthOf(fullpath0));

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


if(JFRCexist==1)
print("JFRCMaskDir; "+JFRCMaskDir);
else{
	filepath=savedir+filename+".txt";
	print("JFRCMaskDir does not exist; "+JFRCMaskDir);
	logsum=getInfo("log");
	File.saveString(logsum, filepath);
	
	
	run("Quit");
}

textinside=File.openAsString(TextPath);
print("textinside; "+textinside);

parametersCPU = split (textinside,"\n");

sigsize = parametersCPU[0];
originalWidth = parametersCPU[1];
originalHeight = parametersCPU[2];
originalSlices = parametersCPU[3];
Oribitd = parametersCPU[4];
VxHeight = parametersCPU[5];
VxWidth = parametersCPU[6];
VxDepth = parametersCPU[7];
tempMaskpath = parametersCPU[8];
channels = parametersCPU[9];
shrinked =  parametersCPU[10];
imagesize = parseFloat(parametersCPU[11]);
nrrdIndex = parseFloat(parametersCPU[12]);
TISSUE = parametersCPU[13];
fullpath = parametersCPU[14];
dirh5j = parametersCPU[15];
filenameh5j = parametersCPU[16];

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
	File.saveString(logsum, filepath);
	
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
print("sigsize; "+sigsize);

print("");
/// skeletoniztion ///////////////////////////////////////////////////
dotIndex=lastIndexOf(filename, ".");
filenamewitoutdot=substring(filename,0,dotIndex);

if(endsWith(filename,".tif") || endsWith(filename,".nrrd") || endsWith(filename,".h5j") || endsWith(filename,".v3dpbd") || endsWith(filename,".zip") ){
	
	starttime=getTime();
	dotindex=lastIndexOf(filename,".");
	truname=filename;
	if(dotindex!=-1)
	truname=substring(filename,0,dotindex);
	
	open(tempMaskpath);
	masktitle=getTitle();
	tempname=masktitle;
	////// For neuron channels ///////////////////////////////////////
	
	print("masktitle; "+masktitle);
	print("dir; "+dir+"   filename; "+filename);
	
	open(dir+filename);
	
	bitd=bitDepth();
	///////////mask decision //////////////////////
	print("tempMaskpath; "+tempMaskpath+"  VxWidth; "+VxWidth+"  width; "+originalWidth+"  height; "+originalHeight);
	
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
	
	///back ground subtraction & neuronal segmentation ////////////////////
	
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
	
	
	rename("DSLT_score.tif");
	run("Duplicate...", "title=DSLT_score_Spare.tif duplicate");
	//setBatchMode(false);
	//updateDisplay();
	//a
	
	selectWindow("DSLT_score.tif");
	
	Gen1Gal4=false;
	if(Gen1Gal4==true){
		StopMaxValSlice=1;
		//	print("nResults; "+getValue("results.count"));
		
		for(iresult=0; iresult<originalSliceNum; iresult++){
			maxnumval=getResult("MaxNum", iresult);
			maxnumval=round(maxnumval);
			
			//		print("maxnumval; "+maxnumval+"  nResults; "+getValue("results.count")+"   iresult; "+iresult);
			
			if(maxnumval!=0){
				StopMaxValSlice=iresult+1;
				iresult=originalSliceNum;
			}
		}
		if(StopMaxValSlice<4)
		StopMaxValSlice=4;
		
		print("   StopMaxValSlice; "+StopMaxValSlice);
		
		//				setBatchMode(false);
		//				updateDisplay();
		//				a
		
		setForegroundColor(0, 0, 0);
		run("Select All");
		for(ifill=1; ifill<=StopMaxValSlice; ifill++){
			setSlice(ifill);
			run("Fill", "slice");
		}
	}//	if(Gen1Gal4==true){
	
	//		setBatchMode(false);
	//			updateDisplay();
	//			a
	
	if(sigsize>=28){
		//	if(shrinked==1)
		//	weight=6000;
		
		if(Oribitd==16){
			weight=30;
			DefIncriweight= -3;
			segtry1weight = 20;
		}else if(Oribitd==8 && bit16conv){
			weight=7000;
			DefIncriweight= -100;
			segtry1weight = 4500;
		}
		if(bitd==8){
			weight=50;
			segtry1weight=40;
			DefIncriweight= -2;
		}
	}else if(sigsize>=12 && sigsize<28){
		
		if(Oribitd==16){
			weight=20;
			DefIncriweight= -2;
			segtry1weight = 10;
		}else if(Oribitd==8 && bit16conv){
			weight=4000;
			DefIncriweight= -70;
			segtry1weight=3000;
		}
		if(bitd==8){
			weight=30;
			segtry1weight=30;
			DefIncriweight= -2;
		}
	}
	if(sigsize>5 && sigsize<12){
		
		if(Oribitd==16){
			weight=8;// これ
			DefIncriweight= -0.5;
			segtry1weight = 1;
			print("line 342");
		}else if(Oribitd==8 && bit16conv){
			weight=2000;
			DefIncriweight= -50;
			segtry1weight=1500;
		}
		if(bitd==8){
			weight=20;
			segtry1weight=12;
			DefIncriweight= -1;
		}
	}
	if(sigsize<=5){
		
		if(Oribitd==16){
			weight=6;
			DefIncriweight= -0.6;
			segtry1weight = 1;
		}else if(Oribitd==8 && bit16conv){
			weight=500;
			DefIncriweight= -50;
			segtry1weight=300;
		}
		
		if(bitd==8){
			weight=1.2;
			segtry1weight=1;
			DefIncriweight= -0.6;
		}
	}//if(sigsize>=28){
	
	savepath="";
	if(pngsave==1){
		savepath=	savedir+truname+"/";
		File.makeDirectory(savepath);
	}
	
	print("segtry1weight; "+segtry1weight+"  DefIncriweight; "+DefIncriweight);
	
	if(BrightnessApply==false){
		weight=20;
		DefIncriweight= -0.7;
	}
	
	segtry0weight=weight;
	
	segtry=1;
	print("   weight; "+weight+"   sigsize; "+sigsize+"  DefIncriweight; "+DefIncriweight);
	
	selectWindow("DSLT_score.tif");
	
	//			setBatchMode(false);
	//			updateDisplay();
	//			a
	// 1st time DSLTfunLine ///////////////////
	
	beforeDSLT=getTime();
	print("Time 427 before 1st DSLT from after shrink; "+(beforeDSLT-afshirink)/1000+" sec");
	
	oriImageNo=nImages();
	
	if(ExM==0)
	run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=1 radius_r_step=5 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
	else
	run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=10 radius_r_step=15 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
	afImageNo=nImages();
	
	if(pngsave==1)
	run("Nrrd Writer", "compressed nrrd="+savepath+"_"+weight+"_initial_407.nrrd");
	
	
	if(afImageNo==oriImageNo){
		print("DSLT segmentatioj is not working");
		exit();
	}
	print(" ");
	rename("DSLTmask"+segtry+".tif");
	//			setBatchMode(false);
	//			updateDisplay();
	//			a
	
	///	if(ReduceS==false)
	//	run("Size...", "width="+round(originalWidth/2)+" height="+round(originalHeight/2)+" depth="+round(originalSliceNum)+" constrain interpolation=None");
	
	
	VolPercent=0;
	ThreeDVolArray=newArray(VolPercent,0,0,0,0,0,0,masktitle,savepath,sigsize,weight,VolPercent,pngsave);
	ThreeDVol(ThreeDVolArray);
	VolPercent = ThreeDVolArray[0];
	VolPercentUP = ThreeDVolArray[1];
	VolPercentDW = ThreeDVolArray[2];
	VolPercentF = ThreeDVolArray[3];
	VolPercentR = ThreeDVolArray[4];
	VolPercentF2=ThreeDVolArray[5];
	MIPratio=ThreeDVolArray[6];
	
	print("VolPercent; "+VolPercent+"  VolPercentUP; "+VolPercentUP+"  VolPercentDW; "+VolPercentDW+"  VolPercentF; "+VolPercentF+"  VolPercentR; "+VolPercentR+"  VolPercentF2; "+VolPercentF2+"  MIPratio; "+MIPratio);
	
	if(VolPercent<3 && weight>MinWeight && VolPercentF<4 && VolPercentUP<6 && VolPercentF2<6 && MIPratio<MaxMIPratio){
		selectWindow("DSLTmask"+segtry+".tif");
		rename("Previous_DSLT.tif");
	}
	previousVolPercent=VolPercent;
	previousweight=weight;
	prepreweight=previousweight;
	previousMIPratio=MIPratio;
	
	previousVolPercent1stTry=VolPercent;
	
	Fratio=VolPercentF/VolPercent;
	
	if(VolPercentF<9)
	Fratio=1;
	
	ReasonVal=VolPercent;
	ReasonST="TotalVol";
	
	VolPercentUPlimit=10;
	if(weight==1)
	VolPercentUPlimit=6;
	else if(weight<3)
	VolPercentUPlimit=8;
	
	DSLTtitleList = newArray(1000);
	FrontVolList = newArray(1000);
	WeightVolList = newArray(1000);
	VolPercentList = newArray(1000);
	
	
	DSLTtitleList[segtry-1]="DSLTmask"+segtry+".tif";
	FrontVolList[segtry-1]=VolPercentF;
	WeightVolList[segtry-1]=weight;
	VolPercentList[segtry-1] = VolPercent;
	Trueweight=weight;
	
	endDSLT=0;
	// till 1425 ///////////
	if(VolPercent>10 || VolPercentF>10 || VolPercentUP>VolPercentUPlimit || VolPercentDW>13 || MIPratio>MaxMIPratio){// was MIPratio > 0.6 for gen1 GAL4
		//					while(VolPercent>10 || VolPercentF>10 || VolPercentUP>VolPercentUPlimit || VolPercentDW>13 || Fratio>1.4 || MIPratio>0.6){//VolPercentF2>10 
		while(endDSLT==0){
			
			if(isOpen("DSLTmask.tif")){
				selectWindow("DSLTmask.tif");
				close();// segmented mask
			}
			print("");
			print("772");
			selectWindow("DSLT_score.tif");
			//		setBatchMode(false);
			//					updateDisplay();
			//					a
			
			weight=weight+2;
			
			volgapT=VolPercent-10;
			volgapF=VolPercentF-10;
			volgapU=VolPercentUP-10;
			volgapD=VolPercentDW-13;
			maxGap=0;
			if(volgapT>volgapF && volgapT>volgapU && volgapT>volgapD){
				maxGap=volgapT;
				print("maxGap; volgapT "+maxGap);
			}else if(volgapT<volgapF && volgapF>volgapU && volgapF>volgapD){
				maxGap=volgapF;
				print("maxGap; volgapF "+maxGap);
			}else if(volgapU>volgapF && volgapT>volgapU && volgapU>volgapD){
				maxGap=volgapU;
				print("maxGap; volgapU "+maxGap);
			}else if(volgapD>volgapF && volgapD>volgapU && volgapT<volgapD){
				maxGap=volgapD;
				print("maxGap; volgapD "+maxGap);
			}
			
			
			if(VolPercent>MaxVolPercent){
				ReasonST="TotalVol";
				ReasonVal=VolPercent;
			}else if(VolPercentF>10){
				ReasonST="F-Vol";
				ReasonVal=VolPercentF;
			}else if(VolPercentDW>15){
				ReasonST="F-Vol";
				ReasonVal=VolPercentDW;
			}else if(Fratio>1.9){
				ReasonST="F-ratio";
				ReasonVal=Fratio;
			}
			
			if(MaxMIPratio<MIPratio)
			ReasonST="MIPratio";
			
			if(VolPercentUP>11 && VolPercentUP>VolPercent){
				ReasonST="UP-Vol";
				ReasonVal=VolPercentUP;
			}
			
			if(weight>=20 && weight<41 && segtry>5)
			weight=weight+3;
			
			if(weight>40 && weight<60 && segtry>5)
			weight=weight+6;
			
			if(weight>60 && segtry>=5){
				weightP=10;
				
				if(weight*0.1>weightP)
				weightP=round(weight*0.04);
				
				if(segtry>10)
				weight=weight+round(weight*0.1);
				else
				weight=weight+weightP;
				print("Line 550");
			}
			
			if(maxGap>4)
			weight=weight+2;
			
			if(volgapT>3)
			weight=weight+2;
			
			if(volgapT>8)
			weight=weight+4;
			
			if(volgapT>13)
			weight=weight+8;
			
			if (MIPratio>0.7)
			weight=weight+round(weight*0.05);
			//	if (MIPratio>0.9)
			//	weight=weight*2;
			if (MIPratio<=0.7 && MIPratio>=0.4){
				weight=weight+round(weight*0.1);
				print("Line 599; weight; "+weight);
			}
			print("Line601   weight; "+weight+"   2Dsigsize; "+sigsize+"   ReasonST; "+ReasonST+"   ReasonVal; "+ReasonVal+"   segtry; "+segtry+"  volgapT; "+volgapT);
			CLEAR_MEMORY();
			
			if(ExM==0)
			run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=1 radius_r_step=5 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
			else
			run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=10 radius_r_step=15 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
			
			rename("DSLTmask"+segtry+".tif");
			print("renamed; "+" DSLTmask"+segtry+".tif");
			
			if(pngsave==1)
			run("Nrrd Writer", "compressed nrrd="+savepath+"_"+weight+"_screen_578.nrrd");
			
			//		if(ReduceS==false)
			//		run("Size...", "width="+round(originalWidth/2)+" height="+round(originalHeight/2)+" depth="+round(originalSliceNum)+" constrain interpolation=None");
			ThreeDVolArray[10]=weight;
			
			ThreeDVol(ThreeDVolArray);
			VolPercent = ThreeDVolArray[0];
			VolPercentUP = ThreeDVolArray[1];
			VolPercentDW = ThreeDVolArray[2];
			VolPercentF = ThreeDVolArray[3];
			VolPercentR = ThreeDVolArray[4];
			VolPercentF2 = ThreeDVolArray[5];
			MIPratio=ThreeDVolArray[6];
			
			Fratio=VolPercentF/VolPercent;
			
			if(VolPercentF<10)
			Fratio=1;
			
			DSLTtitleList[segtry-1]="DSLTmask"+segtry+".tif";
			FrontVolList[segtry-1]=VolPercentF;
			WeightVolList[segtry-1]=weight;
			VolPercentList[segtry-1] = VolPercent;
			Trueweight=weight;
			
			//				if(VolPercent>10 || VolPercentF>10 || VolPercentUP>VolPercentUPlimit || VolPercentDW>13 || Fratio>1.4 || MIPratio>0.6)
			//				endDSLT=0;
			//				else
			//				endDSLT=1;
			print("643 segtry; "+segtry);
			
			gonext=0;
			
			if(MIPratio<0.2)
			VolPercent=9;
			
			ratioMIPweight=0;
			if(segtry>=2){
				weightGap=weight-WeightVolList[segtry-2];
				print("653 weightGap; "+weightGap+"  segtry-2; "+segtry-2);
				
				MIPratioGap = previousMIPratio-MIPratio;
				ratioMIPweight = MIPratioGap/weightGap;
			}
			print("ratioMIPweight; "+ratioMIPweight+"  VolPercent; "+VolPercent+"  MIPratio; "+MIPratio);
			
			if(segtry>4 && endDSLT==0 && VolPercent<MaxVolPercent && MIPratio<0.6){
				
				gapF=2;
				
				for(Fval=segtry-2; Fval>=0; Fval--){
					
					if(ratioMIPweight<ThreratioMIPweight && MIPratio<MaxMIPratio){
						
						Fgap=parseFloat(FrontVolList[Fval])-parseFloat(VolPercentF);// gap value from previous VolPercentF
						print("   parseFloat(FrontVolList[Fval]; "+parseFloat(FrontVolList[Fval])+"parseFloat(VolPercentF); "+parseFloat(VolPercentF));
						
						GoodFga=weightGap*0.7;
						print("GoodFga; "+GoodFga+"  Fgap/GoodFga; less than One; "+Fgap/GoodFga+"  Fgap; "+Fgap+"   weightGap; "+weightGap);
						
						if(Fgap<GoodFga){// if VolPercentF is less than 2 changed
							weight=WeightVolList[Fval+1];
							VolPercent = VolPercentList[Fval+1];
							TrueImage=DSLTtitleList[Fval+1];
							
							endDSLT=1;
							print("  endDSLT; TrueImage "+TrueImage+"  TrueWeight; "+weight);
							
							for(iclose=0; iclose<segtry-1; iclose++){
								
								if(DSLTtitleList[iclose]!=TrueImage){
									if(isOpen(DSLTtitleList[iclose])){
										selectWindow(DSLTtitleList[iclose]);
										close();
										print(DSLTtitleList[iclose]+"  closed");
									}//if(isOpen(DSLTtitleList[iclose])){
								}
							}//for(iclose=0; iclose<segtry; iclose++){
							selectWindow(TrueImage);
							rename("DSLTmask.tif");
							Fval=-1;
						}//if(Fgap<2){
						
					}else{
						gonext=1;
					}
				}//for(Fval=segtry-2; Fval>=0; Fval--){
				
			}//if(segtry>4 && endDSLT==0 && VolPercent<1.5 && MIPratio<0.4){
			
			previousMIPratio=MIPratio;
			
			if(gonext==0){
				if(VolPercent<10 && MIPratio<MaxMIPratio && ratioMIPweight<ThreratioMIPweight){
					endDSLT=1;
					
					if(isOpen("DSLTmask"+segtry+".tif")){
						selectWindow("DSLTmask"+segtry+".tif");
						close();
					}
					
					if(isOpen("DSLTmask"+segtry-1+".tif")){
						selectWindow("DSLTmask"+segtry-1+".tif");
						close();
					}
					print("Incri weight finished; weight "+weight+"  VolPercent"+VolPercent+" %  MaxMIPratio; "+MaxMIPratio);
				}//	if(VolPercent<10 && MIPratio<MaxMIPratio){
			}//if(gonext==0){
			segtry=segtry+1;
		}//while (endDSLT==0){
		//			break;
		
		//					}//while(VolPercent>9 || VolPe
	}//	if(VolPercent>9 || VolPercentF>10 || VolPercentUP>Vo
	
	
	
	if(endDSLT==0){
		if(segtry>=2){
			
			print("endDSLT==0"+"  segtry; "+segtry);
			for(iclose=0; iclose<segtry-1; iclose++){
				print("iclose; "+iclose+"  segtry-1; "+segtry-1+"   DSLTtitleList[iclose]; "+DSLTtitleList[iclose]+"    DSLTtitleList[segtry-2]; "+ DSLTtitleList[segtry-2]);
				
				if( DSLTtitleList[iclose] != DSLTtitleList[segtry-2]){
					if(isOpen(DSLTtitleList[iclose])){
						selectWindow( DSLTtitleList[iclose]);
						close();
					}
				}//if( DSLTtitleList[iclose] != DSLTtitleList[segtry-1]){
			}//for(iclose=0; iclose<segtry; iclose++){
			selectWindow( DSLTtitleList[segtry-2]);
			rename("DSLTmask.tif");
		}//if(segtry>=2){
	}
	
	segtry=1;
	print("751 nImages; "+nImages);
	
	gapVolRatio=0.05; 
	previousgapVolRatio=0.05;
	
	if(BrightnessApply==false)
	gapVolRatioMaxThre=0.13;
	if(endDSLT==0){
		if(VolPercent<3 && weight>MinWeight && VolPercentF<4 && VolPercentUP<6 && VolPercentF2<6 && MIPratio<=MaxMIPratio){
			print("Less_Than_3_Vol!   MinWeight; "+MinWeight);
			
			
			//	fillstart=getTime();
			selectWindow("DSLT_score.tif");
			
			//		setBatchMode(false);
			//		updateDisplay();
			//		a
			
			preweight=0;
			
			while(VolPercent<3 && VolPercentF<4 && VolPercentUP<6 && weight>MinWeight && VolPercentF2<6  && MIPratio<MaxMIPratio && endDSLT==0){
				if(weight>=MinWeight){
					
					if(isOpen("DSLTmask.tif")){
						selectWindow("DSLTmask.tif");
						close();// segmented mask
					}
					
					volgapT=VolPercent-3;
					volgapF=VolPercentF-4;
					volgapU=VolPercentUP-6;
					volgapF2=VolPercentF2-4;
					maxGap=0;
					
					print("786 VolPercent; "+VolPercent+"  volgapT; "+volgapT+"  volgapF; "+volgapF+"  volgapU; "+volgapU+"  volgapF2; "+volgapF2+"  segtry; "+segtry+"  weight; "+weight);
					if(volgapT>volgapF && volgapT>volgapU && volgapT>volgapF2){
						maxGap=volgapT;
						print("maxGap; volgapT "+maxGap);
					}else if(volgapT<volgapF && volgapF>volgapU && volgapF>volgapF2){
						maxGap=volgapF;
						print("maxGap; volgapF "+maxGap);
					}else if(volgapU>volgapF && volgapT>volgapU && volgapU>volgapF2){
						maxGap=volgapU;
						print("maxGap; volgapU "+maxGap);
					}else if(volgapF2>volgapF && volgapF2>volgapU && volgapT<volgapF2){
						maxGap=volgapF2;
						print("maxGap; volgapF2 "+maxGap);
					}
					
					selectWindow("DSLT_score.tif");
					
					if(BrightnessApply==true){
						if(bitd==8 || bitd==24 || bitd==16){
							
							if(sigsize<28 && bitd==16){
								
								gapVolRatioThre = gapVolRatio/gapVolRatioMaxThre ;
								threMIPratio = MIPratio/MaxMIPratio;
								
								if(previousMIPratio<0.1){
									weight=weight-(weight*0.2);
									print("Line 812; weight; "+weight+"   previousMIPratio; "+previousMIPratio);
								}
								//		if(segtry==1){
								//		weight=segtry1weight;
								//		
								//	}
								//			if (segtry==2){
								if(gapVolRatio>gapVolRatioMaxThre){
									weight=segtry0weight-1;
									print("Line 822");
									previousweight=segtry0weight;
									previousVolPercent=previousVolPercent1stTry;
									
								}else{
									
									if(MIPratio>0.06){
										if(weight>=segtry1weight+DefIncriweight)
										weight=segtry1weight+DefIncriweight;
										print("Line 830, weight; "+weight+"   segtry1weight; "+segtry1weight+"   DefIncriweight; "+DefIncriweight+"  MIPratio; "+MIPratio);
									}else{
										weight=segtry1weight+DefIncriweight*2;
										print("Line 833");
									}
								}
								
								if (segtry>2){
									weight=weight+DefIncriweight;
									print("Line 839, weight; "+weight+"   DefIncriweight;"+DefIncriweight);
									
									if(MIPratio>0.6){
										weight=weight+round(weight*0.3);
										print("Line 843");
									}
									
									threMIPratio = MIPratio/MaxMIPratio;
									print("Line 847  threMIPratio; "+threMIPratio+"   MIPratio; "+MIPratio+"   MaxMIPratio; "+MaxMIPratio+"  weight; "+weight+"   DefIncriweight; "+DefIncriweight);
									if(gapVolRatioThre<0.5){//threMIPratio<0.3 || 
										weight=weight+DefIncriweight*2;
										print("Line 850; gapVolRatioThre; "+gapVolRatioThre);
									}
									//			}
								}//	if (segtry>2){
								
							}//if(sigsize<28 && bitd==16){
							
							if(sigsize>=28){//	if(sigsize>=28){
								gapVolRatioThre = gapVolRatio/gapVolRatioMaxThre;
								threMIPratio = MIPratio/MaxMIPratio;
								
								if(segtry==1){
									weight=segtry1weight;
									print("line 863, weight; "+weight);
								}else{
									
									if(threMIPratio<0.25)//|| gapVolRatio<0.03
									weight=weight+DefIncriweight*2;
									
									
									else if(gapVolRatioThre<0.5)
									weight=weight+DefIncriweight*2;
									
									else if(gapVolRatioThre<0.8 && gapVolRatioThre>=0.5)
									weight=weight+DefIncriweight*1.5;
									else if(gapVolRatioThre<0.25)
									weight=weight+DefIncriweight*2;
									else
									weight=weight+DefIncriweight;
									
									print("Line 880, weight; "+weight);
								}// if segtry is more than 2
							}
						}//	if(bitd==8 || bitd==24 || bitd==16){
					}	//if(BrightnessApply==true){
					if(BrightnessApply==false){
						if(weight>10){
							weight=weight+DefIncriweight*2;
							print("Line 844");
						}else{
							weight=weight+DefIncriweight;
							print("Line 1548");
						}
					}//if(BrightnessApply==false){
					
					if(VolPercent<3){
						ReasonST="TotalVol";
						ReasonVal=VolPercent;
					}
					
					
					
					if(weight==preweight){
						if(weight<0.5){
							weight=weight-0.1;
							DefIncriweight=-0.1;
						}else if(weight>=0.5 && weight<=2){
							weight=weight-0.3;
							DefIncriweight=-0.3;
						}else if (weight>2 && weight<11){
							weight=weight-1;
							DefIncriweight=-1;
						}else if (weight>10 && weight<20){
							weight=weight-3;
							DefIncriweight=-3;
						}else{
							weight=weight-5;
							DefIncriweight=-5;
							print("Line 873");
						}
						print("Line 920, weight; "+weight);
					}
					
					
					
					if(weight<MinWeight){
						print("Line 883");
						if(preweight>MinWeight)
						weight=preweight/2;
					}
					
					if(weight==MinWeight || preweight==MinWeight)
					break;
					
					if(weight<MinWeight){
						weight=1;
						break;
					}
					
					preweight=weight;
					
					print("");
					print("Line 1578   weight; "+weight+"   2Dsigsize; "+sigsize+"   ReasonST; "+ReasonST+"   ReasonVal; "+ReasonVal+"   VolPercentF; "+VolPercentF+"  DefIncriweight; "+DefIncriweight + "  segtry; "+segtry);
					BeforeDSLT=nImages();
					
					CLEAR_MEMORY();
					
					if(ExM==0)
					run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=1 radius_r_step=5 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
					else
					run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=10 radius_r_step=15 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
					
					AfterDSLT=nImages();
					
					if(pngsave==1)
					run("Nrrd Writer", "compressed nrrd="+savepath+"_"+weight+"_duringTest_916.nrrd");
					
					if(BeforeDSLT==AfterDSLT){
						print("DSLT is not working; segtry; "+ segtry);
						if(isOpen("DSLT_score.tif"))
						selectWindow("DSLT_score.tif");/// sometime, no DSLT_score.tif...
						else{
							selectWindow("DSLT_score_Spare.tif");
							print("1636 DSLT_score.tif not open, used DSLT_score_Spare.tif");
						}
						looptry=1;
						while(BeforeDSLT==AfterDSLT){
							looptry=looptry+1;
							CLEAR_MEMORY();
							if(ExM==0)
							run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=1 radius_r_step=5 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
							else
							run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=10 radius_r_step=15 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
							AfterDSLT=nImages();
							
							if(looptry==5)
							exit("DSLT 3D cannot run");
							
							print("loop DSLT; "+looptry);
						}
					}
					
					rename("DSLTmask.tif");
					
					//		if(ReduceS==false)
					//		run("Size...", "width="+round(originalWidth/2)+" height="+round(originalHeight/2)+" depth="+round(originalSliceNum)+" constrain interpolation=None");
					ThreeDVolArray[10]=weight;
					
					ThreeDVol(ThreeDVolArray);
					VolPercent = ThreeDVolArray[0];
					VolPercentUP = ThreeDVolArray[1];
					VolPercentDW = ThreeDVolArray[2];
					VolPercentF = ThreeDVolArray[3];
					VolPercentR = ThreeDVolArray[4];
					VolPercentF2 = ThreeDVolArray[5];
					MIPratio=ThreeDVolArray[6];
					
					
					
				}else//	if(weight!=1){
				break;
				
				if(isOpen("Previous_DSLT.tif")){
					
					gapVol=VolPercent-previousVolPercent;
					
					gapMIPratio = abs((previousMIPratio-MIPratio)/(previousweight-weight));
					
					gapVolRatio=abs(gapVol/(previousweight-weight));
					
					//	if(bitd==16)
					//	gapVolRatio=gapVolRatio*(previousweight-weight);
					//	gapMIPratio = gapMIPratio*(previousweight-weight);
					
					
					incriVolratio=gapVolRatio/previousgapVolRatio;
					
					if(isNaN(previousgapVolRatio))
					incriVolratio=0;
					
					print("1020, gapVol; "+gapVol+"  VolPercent; "+VolPercent+"   previousVolPercent; "+previousVolPercent+"   previousweight; "+previousweight+"   weight; "+weight);
					print("gapVolRatio; "+gapVolRatio + "   gapMIPratio; "+gapMIPratio+"   incriVolratio; "+incriVolratio+"   previousgapVolRatio; "+previousgapVolRatio);
					
					if(segtry!=1){
						if(weight>7)
						incriVolratio=1;
						
						stopSeg=0;
						if(gapVolRatio>0.1){
							if(incriVolratio>1.5)//was 1.3
							stopSeg=1;
						}
						
						if(gapVolRatio>gapVolRatioMaxThre || stopSeg==1 || gapMIPratio>gapMIPratioThre){//0.07 before//  || 
							
							weight=previousweight;
							VolPercent=previousVolPercent;
							if(isOpen("DSLTmask.tif")){
								selectWindow("DSLTmask.tif");
								close();
							}
							
							if(isOpen("Previous_DSLT.tif")){
								selectWindow("Previous_DSLT.tif");
								close();
							}
							print("Detected final weight 1083; "+weight+"  final gapVolRatio; "+gapVolRatio);
							break;
							print("not break??");
							MIPratio==0.4;
						}//	if(gapVolRatio>gapVolRatioMaxThre || stopSeg==1){//0.07 before// gapMIPratio>gapMIPratioThre || 
					}//	if(segtry!=1){
					if(VolPercent<3 && VolPercentF<4 && VolPercentUP<6 && VolPercentF2<6  && MIPratio<MaxMIPratio){
						
						if(isOpen("DSLTmask.tif")){
							selectWindow("Previous_DSLT.tif");
							close();
							
							selectWindow("DSLTmask.tif");
							rename("Previous_DSLT.tif");
						}
						
						if(gapMIPratio>gapMIPratioThre){
							weight=previousweight;
							endDSLT=1;
							print("endDSLT due to MIP ratio too much increase, Line 1019");
						}else{
							prepreweight=previousweight;
							previousweight=weight;
							print("Line 1022, previousweight; "+previousweight);
						}
					}//	if(VolPercent<3 && VolPercentF<4 && VolPercentUP<6 && VolPercentF2<6  && MIPratio<MaxMIPratio){
					if(VolPercent>=3 && MIPratio>=MaxMIPratio){
						
						weight=previousweight;
						print("1075, weight; "+weight);
						//			previousVolPercent=VolPercent;
						if(isOpen("DSLTmask.tif")){
							selectWindow("DSLTmask.tif");
							close();
						}
						if(isOpen("Previous_DSLT.tif")){
							selectWindow("Previous_DSLT.tif");
							rename("DSLTmask.tif");
						}
					}
				}//if(isOpen("Previous_DSLT.tif")){
				
				if(isOpen("Previous_DSLT.tif")==0){//if(isOpen("Previous_DSLT.tif")){
					if(isOpen("DSLTmask.tif")){
						selectWindow("DSLTmask.tif");
						rename("Previous_DSLT.tif");
						//	previousVolPercent=VolPercent;
						previousweight=weight;
						print("Line 1731");
					}
				}//if(isOpen("Previous_DSLT.tif")){
				
				if(segtry==1){
					if(VolPercent>=3 || MIPratio>=MaxMIPratio){// || VolPercentF>=4 || VolPercentUP>=6 || VolPercentF2>=6  ||  || gapVolRatio>gapVolRatioMaxThre
						//	MIPratio=0.1;
						//		gapVolRatio=100;
						
						MIPratio=0.2;
						weight = weight*3;//segtry0weight+DefIncriweight;
						print("weight*3; "+weight*3+"  VolPercent; "+VolPercent+"  MIPratio; "+MIPratio+"  segtry; "+segtry);
						//		segtry=segtry-1;
						
						if(VolPercent>=3)
						VolPercent=2;
					}
				}//if(segtry==1){
				segtry=segtry+1;
				previousMIPratio=MIPratio;
				previousVolPercent=VolPercent;
				previousgapVolRatio=gapVolRatio;
			}//while(VolPercent<3 && VolPercentF<4 && VolPercentUP<6 && weight>MinWeight && VolPercentF2<6  && MIPratio<MaxMIPratio){
			weight=previousweight;
		}//if(VolPercent<3 && weight>1 && VolPercentF<5 && VolPercentUP<8){
	}//if(endDSLT==0){
	if(ReduceS==true || DataType=="Gen1 Gal4"){// if Gen1 Gal4
		a=getWidth();
		b=getHeight();
		deletedSliceArray=newArray(100);
		print("if(VolPercent<3) done");
		
		for(isli=1; isli<30; isli++){
			sum=0;
			setSlice(isli);
			for(ia=0; ia<a; ia++){
				for(ib=0; ib<b; ib++){
					if(getPixel(ia,ib)!=0)
					sum=sum+1;
				}
			}
			
			if(sum>6000 && isli<=10){
				run("Select All");
				run("Fill", "slice");
				print("Slice ;"+isli+" deleted, size; "+sum);
				deletedSliceArray[isli]=1;
			}else if(sum>10000 && isli>10 && isli<15){
				run("Select All");
				run("Fill", "slice");
				print("Slice ;"+isli+" deleted, size; "+sum);
				deletedSliceArray[isli]=1;
			}else if (sum>11000 && isli==15){
				run("Select All");
				run("Fill", "slice");
				print("Slice ;"+isli+" deleted, size; "+sum);
				deletedSliceArray[isli]=1;
			}else if (sum>13000 && isli==16){
				run("Select All");
				run("Fill", "slice");
				print("Slice ;"+isli+" deleted, size; "+sum);
				deletedSliceArray[isli]=1;
			}else if (sum>14000 && isli==17){
				run("Select All");
				run("Fill", "slice");
				print("Slice ;"+isli+" deleted, size; "+sum);
				deletedSliceArray[isli]=1;
			}else if (sum>30000 && isli>17){
				run("Select All");
				run("Fill", "slice");
				print("Slice ;"+isli+" deleted, size; "+sum);
				deletedSliceArray[isli]=1;
			}
		}//for(isli=1; isli<13; isli++){
		
		run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width="+VxWidth*2+" pixel_height="+VxHeight*2+" voxel_depth="+VxDepth*2+"");
		
		run("Set Measurements...", "area centroid center perimeter fit shape stack redirect=None decimal=2");
		
		setThreshold(1, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask", "method=Default background=Dark black");
		run("Analyze Particles...", "size=500-Infinity display clear stack");
		run("Select All");
		updateResults();
		
		for(iresultscan=0; iresultscan<getValue("results.count"); iresultscan++){
			areasize=getResult("Area", iresultscan);
			prim = getResult("Perim.", iresultscan);
			sliceposition = getResult("Slice", iresultscan);
			
			if(sliceposition<=26){
				if(areasize>15000){
					big=0;
					Xposition=getResult("X", iresultscan);
					if(Xposition>180 && Xposition<453){//avoiding optic lobe
						
						if(prim/areasize>0.15 && sliceposition<24){
							setSlice(sliceposition);
							
							slicefill (sliceposition);
							print("  Slice ;"+sliceposition+" deleted, size; "+areasize+"   prim; "+prim+"  "+prim/areasize+" %");
							deletedSliceArray[sliceposition]=1;
						}else if(areasize>17000){
							if(sliceposition<24){
								
								slicefill (sliceposition);
								print("  Slice ;"+sliceposition+" deleted, size BIG; "+areasize+"   prim; "+prim+"  "+prim/areasize+" %");
								deletedSliceArray[sliceposition]=1;
								big=1;
							}
						}//if(prim/areasize>0.15 && sliceposition<24){
					}//if(Xposition>180 && Xposition<453){
					
					if(big==0){
						if(areasize>20000){//more than slice = 24
							
							slicefill (sliceposition);
							print("  Slice ;"+sliceposition+" deleted, size TOOBIG; "+areasize+"   prim; "+prim+"  "+prim/areasize+" %");
							deletedSliceArray[sliceposition]=1;
						}
					}
				}else if(areasize>13000 && prim/areasize>0.20){
					
					slicefill (sliceposition);
					print("  Slice ;"+sliceposition+" deleted, size; "+areasize+"   prim; "+prim+"  "+prim/areasize+"_BIG %");
					deletedSliceArray[sliceposition]=1;
				}else if(areasize>10000 && prim/areasize>0.20 && sliceposition<22){
					
					slicefill (sliceposition);
					print("  Slice ;"+sliceposition+" deleted, size; "+areasize+"   prim; "+prim+"  "+prim/areasize+"_BIG %");
					deletedSliceArray[sliceposition]=1;
				}//if(areasize>15000){
			}//if(sliceposition<=26){
			
		}//		for(iresultscan=0; iresultscan<getValue("results.count"); iresultscan++){
		//		print("1244 done");
	}//	if(ReduceS==true){
	
	setForegroundColor(0, 0, 0);
	if(isOpen("DSLTmask.tif")){
		selectWindow("DSLTmask.tif");
		close();// segmented mask
	}
	print("Final weight; "+weight);
	
	if(isOpen("DSLT_score.tif"))
	selectWindow("DSLT_score.tif");/// sometime, no DSLT_score.tif...
	else{
		selectWindow("DSLT_score_Spare.tif");
		print("1329 DSLT_score.tif not open, used DSLT_score_Spare.tif");
	}
	
	if(shrinked==0)
	rotStep=10;
	else
	rotStep=6;
	CLEAR_MEMORY();
	BeforeDSLT=nImages();
	//	run("DSLT3D CL", "radius_r_max=15 radius_r_min=1 radius_r_step=5 rotation=10 weight="+weight+" filter=MEAN close=None noise=5px parallel=7");
	if(ExM==0)
	run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=1 radius_r_step=5 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
	else
	run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=10 radius_r_step=15 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
	
	AfterDSLT=nImages();
	
	if(pngsave==1)
	run("Nrrd Writer", "compressed nrrd="+savepath+"_"+weight+"_finalDSLT.nrrd");
	
	
	if(BeforeDSLT==AfterDSLT){
		print("Final DSLT is not working");
		if(isOpen("DSLT_score.tif"))
		selectWindow("DSLT_score.tif");/// sometime, no DSLT_score.tif...
		else{
			selectWindow("DSLT_score_Spare.tif");
			print("1636 DSLT_score.tif not open, used DSLT_score_Spare.tif");
		}
		DSLTnum=1;
		while(BeforeDSLT==AfterDSLT){
			
			print("Final DSLT is not working; "+DSLTnum);
			CLEAR_MEMORY();
			if(ExM==0)
			run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=1 radius_r_step=5 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
			else
			run("DSLT3D LINE2 CL", "radius_r_max="+MaxDSLT+" radius_r_min=10 radius_r_step=15 rotation=6 weight="+weight+" filter=MEAN close=None noise=5px");
			AfterDSLT=nImages();
			DSLTnum=DSLTnum+1;
			
			if(DSLTnum==6)
			exit("Final DSLT fail x6");
		}
		
	}
	
	rename("DSLTmask.tif");
	
	if(ReduceS==true || DataType=="Gen1 Gal4"){
		for(islibig=1; islibig<30; islibig++){
			
			if(deletedSliceArray[islibig]==1){
				setSlice(islibig*2);
				run("Select All");
				run("Fill", "slice");
				
				setSlice(islibig*2-1);
				run("Fill", "slice");
				
				setSlice(islibig*2+1);
				run("Fill", "slice");
				print("Slice ;"+islibig*2+" deleted");
			}
		}	
	}//if(ReduceS==true || DataType=="Gen1 Gal4"){
	
	print("1425 done; final DSLT3D LINE2 CL done");
	
	//			setBatchMode(false);
	//									updateDisplay();
	//									a
	
	//////////////// Adding saturated signals //////////////////////
	
	selectWindow("DSLT_score_Spare.tif");
	//	print("1440 DSLT_score.tif not open, used DSLT_score_Spare.tif");
	
	run("Duplicate...", "title=Saturated.tif duplicate");
	
	satuW=getWidth();
	satuH=getHeight();
	satuD=nSlices();
	
	maxthre=200;//thresholdingValue;
	if(bitd==8){
		Maxval=255;
	}else if (Oribitd==8 && bitd==16){
		maxthre=30000;
		Maxval=65535;
	}else if (Oribitd==16){
		maxthre=3000;
		Maxval=65535;
	}
	
	setThreshold(maxthre, Maxval);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Dark black");
	
	
	selectWindow("DSLTmask.tif");
	maskW=getWidth();
	maskH=getHeight();
	maskD=nSlices();
	
	selectWindow("Saturated.tif");
	if(maskW!=satuW || maskH!=satuH){
		
		if(maskW<satuW){
			if(maskH<satuH){
				selectWindow("DSLTmask.tif");
				run("Size...", "width="+maskW+" height="+maskH+" depth="+maskD+" interpolation=None");
			}
		}else{//if(maskW<satuW){
			selectWindow("Saturated.tif");
			run("Size...", "width="+satuW+" height="+satuH+" depth="+satuD+" interpolation=None");
		}
	}//	if(maskW!=satuW || maskH!=satuH){ shrink original signal for GPU memory 20x connection
	
	imageCalculator("Max stack", "DSLTmask.tif","Saturated.tif");
	
	selectWindow("Saturated.tif");
	close();
	print("1460 done");
	
	
	afDSLT=getTime();
	print("Time 2024 after DSLT from beforeDSLT; "+(afDSLT-beforeDSLT)/1000+" sec");
	
	selectWindow("DSLTmask.tif");
	MinVolSize=(imagesize/390)*13500;
	
	if(VxWidth==0.44)
	MinVolSize=3500;
	
	if(tempname=="JRC2018_VNC_UNISEX_63x.nrrd")
	MinVolSize=100000;
	
	print("---MinVolSize; "+MinVolSize);
	//////////////////// connecting cmponent ///////////////////////////////////////
	if(ShowOriginalVol==false){
		
		connectionArray = newArray("");
		Vx3Dconnection (NumConnection,CPUnum,connectionArray,shrinked,ReduceS);//20px connection + noise elimination
		
		GPUconnect = connectionArray[0];
		
		while(isOpen("DSLTmask.tif")){
			selectWindow("DSLTmask.tif");
			close();
		}
		selectWindow(GPUconnect);
	}//if(ShowOriginalVol==false){
	
	print("1807 done; go to Connect Flagments");
	if(ShowOriginalVol==true){
		
		//					setBatchMode(false);
		//					updateDisplay();
		//				a
		
		
		connectionArray = newArray("");
		Vx3Dconnection (NumConnection,CPUnum,connectionArray,shrinked,ReduceS);//20px connection + noise elimination
		
		GPUconnect = connectionArray[0];
		
		selectWindow(GPUconnect);
		print("1489 done");
		
		if(pngsave==1)
		run("Nrrd Writer", "compressed nrrd="+savepath+"_"+weight+"_afterGPUConnect_1372.nrrd");
		
	}//if(ShowOriginalVol==true){
	
	if(maskW!=satuW || maskH!=satuH){
		
		if(maskW<satuW){
			if(maskH<satuH){
				run("Size...", "width="+satuW+" height="+satuH+" depth="+satuD+" interpolation=None");
			}
		}else{//if(maskW<satuW){
			run("Size...", "width="+maskW+" height="+maskH+" depth="+maskD+" interpolation=None");
		}
	}//	if(maskW!=satuW || maskH!=satuH){
	
	
	
	//	rename("Skeleton.tif");
	
	if(OBJscore>0)
	OBJscore=d2s(OBJscore,2);
	
	truname=truname+"_"+OBJscore;
	
	if(shrinked==1 || ReduceS==true){
		run("Size...", "width="+originalWidth+" height="+originalHeight+" depth="+originalSlices+" interpolation=None");
		
		if(ThreeDconnect>0){
			if(ReduceS==false)
			run("Maximum 3D...", "x="+ThreeDconnect+" y="+ThreeDconnect+" z=0");
			else
			run("Maximum 3D...", "x="+ThreeDconnect+" y="+ThreeDconnect+" z="+ThreeDconnect+"");
			
			print("3D max; "+ThreeDconnect);
		}
	}//	if(shrinked==1 || ReduceS==true){
	
	
	//	setBatchMode(false);
	//						updateDisplay();
	//							a
	
	run("Connecting Components seg CPU", "ignore=1 minimum="+MinVolSize+" thread="+CPUnum+"");// object separation
	showStatus("Find Connected Done");
	rename("Skeleton.tif");
	
	if(pngsave==1)
	run("Nrrd Writer", "compressed nrrd="+savepath+"_"+weight+"_afterConnectComponent_1419.nrrd");
	
	resultsST = call("Connecting_Components_seg_CPU.getResult");
	results=split(resultsST,"_");
	
	print(results.length+" object after connecting component 3D in 2055");
	
	setMinAndMax(0, 255);
	run("8-bit");
	
	af3Dconnect=getTime();
	print("Time 2105 after 3Dconnect from DSLTend; "+(af3Dconnect-afDSLT)/1000+" sec");
	
	if(ShowOriginalVol==true){
		run("Duplicate...", "title=Duplicated_GrayMask.tif duplicate");
		run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width="+VxWidth+" pixel_height="+VxHeight+" voxel_depth="+VxDepth+"");
		
		selectWindow("Skeleton.tif");
	}
	
	run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width="+VxWidth+" pixel_height="+VxHeight+" voxel_depth="+VxDepth+"");
	
	skeletonDirMIP=savedir+truname+"_"+results.length+"_objects_"+weight+"_weight"+File.separator;
	File.makeDirectory(skeletonDirMIP);
	
	if(nrrdIndex==-1){
		if(ShowOriginalVol==true)
		run("Nrrd Writer", "compressed nrrd="+maskdir+truname+"_"+results.length+"_objects.nrrd");
		else
		run("Nrrd Writer", "compressed nrrd="+skeletonDirMIP+truname+".nrrd");
	}else{
		if(ShowOriginalVol==true)
		run("Nrrd Writer", "compressed nrrd="+skeletonDirMIP+truname+"_"+results.length+"_objects_"+weight+"_weight_.nrrd");
		else
		run("Nrrd Writer", "compressed nrrd="+skeletonDirMIP+truname+"_"+weight+"_weight_.nrrd");
	}
	
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("PNG", ""+maskMIPdir+truname+"__"+results.length+"_objects.png");
	close();
	
	setThreshold(1, 65535);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Dark black");
	//	run("NBLAST Skeletonize");
	
	if(SkeltonTrue){
		run("Skeletonize (2D/3D)");
		run("Fill Holes", "stack");
		run("Skeletonize (2D/3D)");
		SkeletonSt=getTitle();
		
		//			setBatchMode(false);
		//						updateDisplay();
		//						a
		VolPercent=d2s(VolPercent, 2);
		
		run("Z Project...", "projection=[Max Intensity]");
		saveAs("PNG", ""+skeletondir+truname+"_"+sigsize+"_2Dsize,__"+weight+"_weight,__"+VolPercent+"_Skeleton_MIP.png");//save 20x MIP
		//MIP and median, then threshold??
		close();
		
		selectWindow(SkeletonSt);
		if(nrrdIndex==-1)
		run("Nrrd Writer", "compressed nrrd="+skeletondir+truname+"Skeleton.nrrd");
		else
		run("Nrrd Writer", "compressed nrrd="+skeletondir+truname+"_All_Skeletons.nrrd");
		close();
	}//if(SkeltonTrue){
	
	//		selectWindow("Skeleton.tif");
	//		close();
	
	//		if(isOpen(titlelist[ititle])){
	//			selectWindow(titlelist[ititle]);
	//			close();
	//			print("titlelist[ititle] closed; "+titlelist[ititle]);
	//		}
	
	if(isOpen("itr.tif")){
		selectWindow("itr.tif");
		close();
		print("itr.tif closed; itr.tif");
	}
	
	if(isOpen("DSLT_score.tif")){
		selectWindow("DSLT_score.tif");
		close();
		print("1497 DSLT_score.tif closed;");
	}
	
	if(isOpen("DSLTmask.tif")){
		selectWindow("DSLTmask.tif");
		close();
		print("DSLTmask.tif closed");
	}
	
	if(ShowOriginalVol==true){
		
		VolST=""; volume=0; 	NumSkeST=""; CirRatio=0; weight=0; NumSke=1;
		
		print(dir+"original.nrrd  open");
		open(dir+"original.nrrd");
		rename("Dup_Signal.tif");
		//			selectWindow("Dup_Signal.tif");
		//			run("Janelia H265 Writer", "save="+skeletonDirMIP+truname+".h5j");
		
		run("Z Project...", "projection=[Max Intensity]");
		rename("Original_MIP.tif");
		run("Enhance Contrast", "saturated=2");
		getMinAndMax(MIPmin, MIPmax);
		
		print("Original_MIP size; W; "+getWidth+"  H; "+getHeight);
		
		if(results.length>0){
			print(results.length+" objects");
			OBJnumber=results.length;
			
			MIPjunk=skeletonDirMIP+"JunkMIP"+File.separator;
			File.makeDirectory(MIPjunk);
			
			MIPSmall=skeletonDirMIP+"Small_MIP"+File.separator;
			File.makeDirectory(MIPSmall);
			
			//		MIPjunkSmall=MIPSmall+"JunkMIP_Small"+File.separator;
			//		File.makeDirectory(MIPjunkSmall);
			
			MIPjunkSmall=MIPjunk;
			
			skeletonDir3D=skeletonDirMIP;
			
			Voljunk=skeletonDir3D+"JunkVolume"+File.separator;
			File.makeDirectory(Voljunk);
			
			VolSmall=skeletonDir3D+"Small_Volume"+File.separator;
			File.makeDirectory(VolSmall);
			
			//		VoljunkSmall=VolSmall+"JunkVolume_Small"+File.separator;
			//		File.makeDirectory(VoljunkSmall);
			
			VoljunkSmall=Voljunk;
			
			VolumeArray=newArray(OBJnumber+1);
			maxVolsize=0;
			for(iresult=0; iresult<results.length; iresult++){
				VolumeArray[iresult] =results[iresult];
				ivol = parseFloat(VolumeArray[iresult]);//Chaneg string to number
				if(ivol>maxVolsize)
				maxVolsize=ivol;
			}
			
			run("Set Measurements...", "area centroid center perimeter fit shape stack redirect=None decimal=2");
			
			for(iresultC=0; iresultC<OBJnumber; iresultC++){
				
				selectWindow("Original_MIP.tif");
				run("Duplicate...", "title=Original_MIP2.tif");
				setMinAndMax(MIPmin, round(MIPmax+MIPmax*0.1));
				run("Apply LUT");
				print("Original MIapply LUT; "+round(MIPmax+MIPmax*0.1));
				
				selectWindow("Duplicated_GrayMask.tif");
				
				//			setBatchMode(false);
				//			updateDisplay();
				//			a
				
				run("Duplicate...", "title=SingleValue_GrayMask.tif duplicate");
				
				setThreshold(iresultC+1, iresultC+1);
				setOption("BlackBackground", true);
				
				run("Convert to Mask", "method=Default background=Dark black");
				
				//			setBatchMode(false);
				//					updateDisplay();
				//					a
				
				if(bitd==16){
					run("16-bit");
					setMinAndMax(0, 1);
					run("Apply LUT", "stack");
					//			run("Mask255 to 4095");// set mask to 4095
				}
				
				
				if(pngsave==1)
				run("Nrrd Writer", "compressed nrrd="+savepath+"_"+weight+"_beforeMeasurement.nrrd");
				
				run("Z Project...", "projection=[Max Intensity]");
				MIPIMG=getTitle();
				if(bitd==16){
					run("8-bit");
					run("Convert to Mask", "method=Default background=Dark black");
				}
				run("Analyze Particles...", "display clear");
				
				updateResults();
				
				print("2261 Analyze particle result n; "+getValue("results.count"));
				
				if(getValue("results.count")!=0){
					
					CirRatio=getResult("Circ.", 0);
					CirRatio=parseFloat(CirRatio);//Chaneg string to number
					close();
					print("CirRatio; "+CirRatio);
					
					imageCalculator("AND stack", "SingleValue_GrayMask.tif","Dup_Signal.tif");
					
					volume=VolumeArray[iresultC];
					volume=parseFloat(volume);//Chaneg string to number(volume);
					
					maxst="";
					if(volume==maxVolsize)
					maxst="_Max";
					
					MinVolSize2=(imagesize/390)*13500;
					
					if(VxWidth==0.44)
					MinVolSize2=MinVolSize+2000;// for small object
					
					if(tempname=="JRC2018_VNC_UNISEX_63x.nrrd")
					MinVolSize2=100000;
					
					if(volume<100000 && volume>9999)
					VolST="0";
					else if(volume<10000 && volume>999)
					VolST="00";
					else if(volume<1000 && volume>99)
					VolST="000";
					else if(volume<100 && volume>9)
					VolST="0000";
					else if(volume<10)
					VolST="00000";
					
					
					if(NumSke<10)
					NumSkeST="0";
					else
					NumSkeST="";
					
					
					selectWindow("SingleValue_GrayMask.tif");
					run("Z Project...", "projection=[Max Intensity]");
					rename("Signal_MIP.tif");
					
					print("Signal_MIP.tif W; "+getWidth+"  H; "+getHeight);
					
					setAutoThreshold("Otsu dark");
					getThreshold(lower, upper);
					
					print(iresultC+1+" Junk decision; lower; "+lower+"  CirRatio; "+CirRatio+"   volume; "+volume);
					
					Junk=true;
					if(lower>70)
					Junk=false;
					
					if(Junk==false){
						minCirRatio=0.125;
						if(volume>100000)
						minCirRatio=0.18;
						
						if(volume>70000 && volume<=100000)
						minCirRatio=0.16;
						
						if(CirRatio<=minCirRatio)
						Junk=false;
						else
						Junk=true;
					}
					
					if(volume>80000)
					if(CirRatio<0.04)
					if(lower>45)
					Junk=false;
					
					if(volume>200000)
					if(CirRatio<0.025)
					if(lower>30)
					Junk=false;
					
					if(volume>20000)
					if(CirRatio<0.03)
					if(lower>58)
					Junk=false;
					
					if(CirRatio<0.09)
					Junk=false;
					
					if(volume>200000)
					if(CirRatio<0.35)
					if(lower>600)
					Junk=false;
					
					
					if(bitd==16){
						//		run("Enhance Contrast", "saturated=1");
						//	getMinAndMax(min, max);
						//		setMinAndMax(min, max);
						setMinAndMax(MIPmin, round(MIPmax+MIPmax*0.1));
						run("Apply LUT");
						print("Signal Apply LUT; "+round(MIPmax+MIPmax*0.1));
						
					}else{//	if(bitd==16){
						setMinAndMax(MIPmin, round(MIPmax+MIPmax*0.1));
						run("Apply LUT");
					}
					run("Merge Channels...", "c1=[Original_MIP2.tif] c2=[Signal_MIP.tif] c3=[Original_MIP2.tif]");
					
					if(volume>MinVolSize2){
						if(Junk==false){
							if(simplefilenameExp==false){
								saveAs("PNG", ""+skeletonDirMIP+truname+"_"+NumSkeST+NumSke+"_"+VolST+volume+"_"+CirRatio+"_MIP"+maxst+".png");//save 20x MIP
							}else{
								saveAs("PNG", ""+skeletonDirMIP+truname+NumSkeST+NumSke+"_MIP.png");//save 20x MIP
							}
						}else{
							if(simplefilenameExp==false)
							saveAs("PNG", ""+MIPjunk+truname+"_"+NumSkeST+NumSke+"_"+VolST+volume+"_"+CirRatio+"_MIP_Junk.png");//save 20x MIP
							else
							saveAs("PNG", ""+MIPjunk+truname+NumSkeST+NumSke+"_MIP.png");
							close();
							
						}
						
						selectWindow("SingleValue_GrayMask.tif");
						if(Junk==false){
							if(simplefilenameExp==false)
							run("Nrrd Writer", "compressed nrrd="+skeletonDir3D+truname+"_"+NumSkeST+NumSke+"_"+VolST+volume+"_"+CirRatio+""+maxst+".nrrd");
							else
							run("Nrrd Writer", "compressed nrrd="+skeletonDir3D+truname+NumSkeST+NumSke+".nrrd");
						}
						else if (JunkNrrd==1){// for speed up
							if(volume>10000 && TISSUE=="VNC")
							run("Nrrd Writer", "compressed nrrd="+Voljunk+truname+NumSkeST+NumSke+".nrrd");
							else{
								if(simplefilenameExp==false)
								run("Nrrd Writer", "compressed nrrd="+Voljunk+truname+"_"+NumSkeST+NumSke+"_"+VolST+volume+"_"+CirRatio+"_Junk.nrrd");
								else
								run("Nrrd Writer", "compressed nrrd="+Voljunk+truname+NumSkeST+NumSke+".nrrd");
							}
						}
					}else{
						if(Junk==false){
							if(simplefilenameExp==false){
								saveAs("PNG", ""+MIPSmall+truname+"_"+NumSkeST+NumSke+"_"+VolST+volume+"_"+CirRatio+"_MIP_Small.png");//save 20x MIP
							}else{
								saveAs("PNG", ""+MIPSmall+truname+NumSkeST+NumSke+".png");//save 20x MIP
							}
						}else
						saveAs("PNG", ""+MIPjunkSmall+truname+"_"+NumSkeST+NumSke+"_"+VolST+volume+"_"+CirRatio+"_MIP_Junk_Small.png");//save 20x MIP
						close();
						
						selectWindow("SingleValue_GrayMask.tif");
						if(Junk==false){
							if(TISSUE!="VNC"){
								if(simplefilenameExp==false)
								run("Nrrd Writer", "compressed nrrd="+VolSmall+truname+"_"+NumSkeST+NumSke+"_"+VolST+volume+"_"+CirRatio+"_Small.nrrd");
								else
								run("Nrrd Writer", "compressed nrrd="+VolSmall+truname+NumSkeST+NumSke+".nrrd");
							}
						}else if (CirRatio<=0.2){// for speed up
							if(TISSUE!="VNC"){
								if(simplefilenameExp==false)
								run("Nrrd Writer", "compressed nrrd="+VoljunkSmall+truname+"_"+NumSkeST+NumSke+"_"+VolST+volume+"_"+CirRatio+"_Junk_Small.nrrd");
								else
								run("Nrrd Writer", "compressed nrrd="+VoljunkSmall+truname+NumSkeST+NumSke+".nrrd");
							}
						}
					}//	if(volume>MinVolSize2){
					print(iresultC+"_"+VolST+volume+" closed");
					NumSke=NumSke+1;
					close();
					print("");
				}else{//if(getValue("results.count")!=0){
					selectWindow("SingleValue_GrayMask.tif");
					close();
					selectWindow(MIPIMG);
					close();
				}//if(volume>MinVolSize2){
			}//for(iresultC=0; iresultC<titlelistSke.length; iresultC++){
			
			
		}//	if(getValue("results.count")>0){
	}//if(ShowOriginalVol==true){
	
	
	
	
	
	run("Close All");
}else{
	if(isOpen(filename)){
		selectWindow(filename);
		close();
	}
	
	
	if(endsWith(filename,".h5j") || endsWith(filename,".v3dpbd")){
		if(isOpen (titlelist[endlist-1])){
			selectWindow(titlelist[endlist-1]);//nc82
			close();
		}
	}
	endtime=getTime();
	gapmin=(endtime-starttime)/(1000*60);
	print(gapmin+" min processing time");
	
	Done2=getTime();
	print("Time 3419 after fileExport from 3Dconnect; "+(Done2-af3Dconnect)/1000+" sec");
	
	logsum=getInfo("log");
	
	if(ShowOriginalVol==true)
	filepath=skeletonDirMIP+"log_"+VolST+volume+"_"+NumSkeST+NumSke+"_"+CirRatio+"_Circ_"+weight+"_weight_"+gapmin+"_min.txt";
	else
	filepath=skeletonDirMIP+"log_"+weight+"_weight_"+gapmin+"_min.txt";
	
	
	File.saveString(logsum, filepath);
//	print("\\Clear");
	
	
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
	//	if(File.exists(dir+"done/")!=1)
	//	File.makeDirectory(dir+"done/");
	
	File.rename(fullpath, dirh5j+"done/"+filenameh5j);
	//	File.rename(dir+filename, dir+"done/"+filename); // - Renames, or moves, a file or directory. Returns "1" (true) if successful. 
}

if(deleteeverything==1 && pngsave==0){
	File.delete(tempMaskpath);
	File.delete(TextPath);
	File.delete(dir+filename);
	File.delete(dir+"original.nrrd");
	File.delete(dir);
}

if(testarg==0){
	
	run("Misc...", "divide=Infinity save");
	run("Close All");
	run("Quit");
}





"Done"