import ij.*;
import ij.plugin.filter.*;
import ij.plugin.PlugIn;
import ij.process.*;
import ij.gui.*;
import java.math.*;
import java.io.*;
import java.util.*;
import java.net.*;
import ij.Macro.*;
import java.awt.*;
//import ij.macro.*;
import ij.gui.GenericDialog.*;
import java.math.BigDecimal;
import java.math.BigInteger;
import ij.measure.ResultsTable;

public class Mask_Median_Subtraction implements PlugInFilter
{
	ImagePlus imp, imp2;
	ImageProcessor MaskIp, DataIp;
	double maxvalue=0;
	int pix1=0;
	int increment=0;
	int pixset=0;
	double totalmax=0;
	ImagePlus newimp;
	int twohun = 255;
	
	public int setup(String arg, ImagePlus imp)
	{
		IJ.register (Mask_Median_Subtraction.class);
		if (IJ.versionLessThan("1.32c")){
			IJ.showMessage("Error", "Please Update ImageJ.");
			return 0;
		}
		
		//	IJ.log(" wList;"+String.valueOf(wList));
		
		this.imp = imp;
		if(imp.getType()!=imp.GRAY8 && imp.getType()!=imp.GRAY16 && imp.getType()!=imp.GRAY32){
			IJ.showMessage("Error", "Plugin requires 8-, 16- and 32 bit image");
			return 0;
		}
		return DOES_8G+DOES_16+DOES_32;
		
		//	IJ.log(" noisemethod;"+String.valueOf(ff));
	}
	
	public void run(ImageProcessor ip){
		
		int wList [] = WindowManager.getIDList();
		if (wList==null || wList.length<2) {
			IJ.showMessage("There must be at least two windows open");
			return;
		}
		int imageno = 0;
		String titles [] = new String[wList.length];
		for (int i=0; i<wList.length; i++) {
			ImagePlus imp = WindowManager.getImage(wList[i]);
			if (imp!=null){
				titles[i] = imp.getTitle();//Mask.tif and Data.tif
				imageno = imageno +1;
			}else
			titles[i] = "";
		}
		/////Dialog//////////////////////////////////////////////		
		
		int averaging=(int)Prefs.get("averaging.int",1);
		int datafile=(int)Prefs.get("datafile.int",0);
		int Mask=(int)Prefs.get("Mask.int",1);
		boolean subave = (boolean)Prefs.get("subave.boolean",false);
		int medianPercent = (int)Prefs.get("medianPercent.int",100);
		
		if(Mask>=wList.length)
		Mask=wList.length-1;
		
		if(datafile>=wList.length)
		datafile=wList.length-1;
		
		GenericDialog gd = new GenericDialog("Mask Brightness adjustment");
		gd.addChoice("Mask", titles, titles[Mask]); //Mask
		gd.addChoice("Data for the median measure", titles, titles[datafile]); //Data
		gd.addNumericField("% of median subtraction", medianPercent,0);
		
		gd.addCheckbox("Subtract 3D averaged value", subave);
		
		gd.addNumericField("Histogram averaging number (1 is no averaging)", averaging,0);
		
		gd.showDialog();
		if(gd.wasCanceled()){
			return;
		}
		
		Mask = gd.getNextChoiceIndex(); //Min projection
		datafile = gd.getNextChoiceIndex(); //stack
		medianPercent=(int)gd.getNextNumber();
		subave = gd.getNextBoolean();
		averaging=(int)gd.getNextNumber();
		
		IJ.log("averaging; "+String.valueOf(averaging));
		
		imp = WindowManager.getImage(wList[Mask]);
		titles[Mask] = imp.getTitle();//Mask.tif and Data.tif
		
		imp2 = WindowManager.getImage(wList[datafile]);
		titles[datafile] = imp2.getTitle();//Mask.tif and Data.tif
		
		Prefs.set("averaging.int",averaging);
		Prefs.set("datafile.int",datafile);
		Prefs.set("Mask.int",Mask);
		Prefs.set("subave.boolean", subave);
		Prefs.set("medianPercent.int",medianPercent);
		double medianPercent2= (double) ( (double) medianPercent /  (double) 100);
		
		IJ.log("medianPercent2; "+String.valueOf(medianPercent2));
		///////		
		ImagePlus imask = WindowManager.getImage(wList[Mask]); //Mask
		ImagePlus idata = WindowManager.getImage(wList[datafile]); //Data
		
		ImageStack stackMask = imask.getStack(); //stack Mask
		ImageStack stackData = idata.getStack(); //stack data
		
		int Fnslice = imask.getStackSize(); //stack
		int Fidatanslice = idata.getStackSize(); //stack
		
		if(Fnslice!=Fidatanslice){
			IJ.log("Slice number is different!!  Mask; "+String.valueOf(Fnslice)+"   Data; "+String.valueOf(Fidatanslice));
			
			if(Fnslice>Fidatanslice)
			Fnslice=Fidatanslice;
		}
		
		MaskIp = imask.getProcessor(); //Mask
		int sumpx = MaskIp.getPixelCount();
		
		IJ.showStatus("Mask_median_measurement");
		
		//	IJ.log(" posipx;"+String.valueOf(posipx));
		/////////////////////Start: signal detection///////////////////////////////
		int MaxPix3=0; 	int MinPix3 = 100000;
		
		ResultsTable rt = new ResultsTable();
		
		//// Min Max measurement //////////////////////
		for(int islice2=1; islice2<=Fnslice; islice2++){
			MaskIp= stackMask.getProcessor(islice2); //IP mask
			DataIp=stackData.getProcessor(islice2); //IP mask
			
			for(int nn=0; nn<sumpx; nn++){
				int pix5= MaskIp.get(nn);
				if(pix5>200){//Mask value
					
					float pix3=0;
					if(imp2.getType()!=imp2.GRAY32)
					pix3= DataIp.get(nn);//double, sample
					else{
						pix3= DataIp.getf(nn);//double, sample
						pix3=pix3*1000;
					}
					if(pix3>0){
						if(pix3>MaxPix3)
						MaxPix3= Math.round(pix3);
						
						if(pix3<MinPix3)
						MinPix3= Math.round(pix3);
					}
				}//	if(pix1>200){
			}//for(int n=0; n<sumpx; n++){
		}
		
		int maxVal = 65536;
		
		if(imp2.getType()==imp2.GRAY32)
		maxVal = MaxPix3+1;//2147483645;
		
		int[] histog = new int[maxVal];
		int GapValue=MaxPix3-MinPix3;
		
		IJ.log("maxVal; "+String.valueOf(maxVal));
		
		int Avemedian=0; long MaxPointSum=0;
		int maxNum=0, MaxPoint=0, aveVal=0;
		
		int [] MedianArray = new int[Fnslice+1];
		
		for(int islice=1; islice<=Fnslice; islice++){
			if(IJ.escapePressed())
			return;
			
			MaskIp= stackMask.getProcessor(islice); //IP mask
			DataIp=stackData.getProcessor(islice); //IP mask
			
			for(int n=0; n<sumpx; n++){
				pix1= MaskIp.get(n);
				if(pix1>200){//Mask value
					
					float pix3=0;
					if(imp2.getType()!=imp2.GRAY32)
					pix3= DataIp.get(n);//double, sample
					else{
						pix3= DataIp.getf(n);//double, sample
						pix3=pix3*1000;
					}
					//		if(Math.round(pix3)!=0)
					//		IJ.log("pix3; "+String.valueOf(Math.round(pix3)));
				//	if(pix3>0)
					histog[Math.round(pix3)]=histog[Math.round(pix3)]+1;
					
					//	IJ.log("pix3; "+String.valueOf(pix3));
					
				}//	if(pix1>200){
			}//for(int n=0; n<sumpx; n++){
			
			//// Histogram scan and get median number //////////////
			maxNum=0; MaxPoint=0; aveVal=0;
			
			if(averaging<2){
				for(int ihistoScan=1; ihistoScan<histog.length; ihistoScan++){
					
					int numVal=histog[ihistoScan];
					
					if(numVal>maxNum){
						maxNum=numVal;
						MaxPoint=ihistoScan;
						
					}
				}
			}else{//if(averaging==false){
				
				for(int ihistoScan=1; ihistoScan<histog.length-averaging-1; ihistoScan++){
					int sumCountval=0;
					for(int iave=0; iave<averaging; iave++){
						int numVal=histog[ihistoScan+iave];
						sumCountval=numVal+sumCountval;
					}
					aveVal=sumCountval/averaging;
					//		IJ.log("aveVal; "+String.valueOf(aveVal));
					if(aveVal>maxNum){
						maxNum=aveVal;
						MaxPoint=ihistoScan+Math.round(averaging/2);
						
						if(MaxPoint==Math.round(averaging/2))
						MaxPoint=ihistoScan;
						//	IJ.log("ihistoScan; "+String.valueOf(ihistoScan)+"   aveVal; "+String.valueOf(averaging));
					}
				}
			}
			//		IJ.log(String.valueOf(islice)+" Median; "+String.valueOf(MaxPoint)+"   maxNum; "+String.valueOf(maxNum));
			MaxPointSum=MaxPointSum+MaxPoint;
			
			MaxPoint= (int) ((double)MaxPoint * medianPercent2);
			rt.incrementCounter();
			rt.addValue("Median", (int) MaxPoint);//median value
			rt.addValue("MaxNum", (int) maxNum);//number of the pixels
			rt.show("Results");
			
			if(subave)
			MedianArray[islice-1]=MaxPoint;
			
			if(subave==false){
				double SliceGapValue=MaxPix3-MaxPoint;
				
				for(int npix=0; npix<sumpx; npix++){
					
					float pix3=0;
					if(imp2.getType()!=imp2.GRAY32)
					pix3= DataIp.get(npix);//double, sample
					else{
						pix3= DataIp.getf(npix);//double, sample
						pix3=pix3*1000;
					}
					
					double ratio = ((double) pix3- (double) MaxPoint)/SliceGapValue;
					
					int NewPix3=0;
					if(pix3>=MaxPoint){
						NewPix3 = ( Math.round(pix3) - MaxPoint)+(int) (MaxPoint*ratio);
						
					}else 
					NewPix3 = 0;
					
					if(NewPix3>MaxPix3)
					NewPix3=MaxPix3;
					
					if(imp2.getType()!=imp2.GRAY32)
					DataIp.set(npix,NewPix3);
					else
					DataIp.setf(npix,(float) NewPix3);
					
				}
			}//	if(subave==false){
		}//for(int islice=1; islice<=Fnslice; islice++){
		
		if(subave){//subtract 3D averaged median value in each slice
			
	//		MaxPoint = (int) (MaxPointSum/(long)Fnslice);
	//		MaxPoint= (int) ((double)MaxPoint * medianPercent2);
			
			IJ.log("3Dave median; "+String.valueOf(MaxPoint)+"  but it will subtract larger number of median in each slice");
			
			for(int islice2=1; islice2<=Fnslice; islice2++){
				if(IJ.escapePressed())
				return;
				
				MaxPoint = (int) (MaxPointSum/(long)Fnslice);
				MaxPoint= (int) ((double)MaxPoint * medianPercent2);
				
				if(MedianArray[islice2-1]>MaxPoint)
				MaxPoint=MedianArray[islice2-1];
				
				MaskIp= stackMask.getProcessor(islice2); //IP mask
				DataIp=stackData.getProcessor(islice2); //IP mask
				
				
				double SliceGapValue=MaxPix3-MaxPoint;
				
				for(int npix=0; npix<sumpx; npix++){
					
					float pix3=0;
					if(imp2.getType()!=imp2.GRAY32)
					pix3= DataIp.get(npix);//double, sample
					else{
						pix3= DataIp.getf(npix);//double, sample
						pix3=pix3*1000;
					}
					
					double ratio = ((double) pix3- (double) MaxPoint)/SliceGapValue;
					
					int NewPix3=0;
					if(pix3>=MaxPoint){
						NewPix3 = ( Math.round(pix3) - MaxPoint)+(int) (MaxPoint*ratio);
						
					}else 
					NewPix3 = 0;
					
					if(NewPix3>MaxPix3)
					NewPix3=MaxPix3;
					
					if(imp2.getType()!=imp2.GRAY32)
					DataIp.set(npix,NewPix3);
					else
					DataIp.setf(npix,(float) NewPix3);
					
				}
				
			}//for(int islice2=1; islice2<=Fnslice; islice2++){
		}
		
		idata.show();
		
	} //public void run(ImageProcessor ip){
} //public class Two_windows_mask_search implements PlugInFilter{



























