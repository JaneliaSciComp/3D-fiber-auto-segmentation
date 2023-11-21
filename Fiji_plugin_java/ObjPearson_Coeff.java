import ij.*;
import ij.ImagePlus;
import ij.plugin.filter.PlugInFilter;
import ij.plugin.PlugIn;
import ij.process.*;
import ij.gui.*;
import java.math.*;
import java.io.*;
import java.util.*;
import java.net.*;
import ij.Macro.*;
import java.awt.*;
import java.util.concurrent.atomic.AtomicInteger;
import ij.gui.GenericDialog.*;
import java.math.BigDecimal;
import java.math.BigInteger;
import ij.measure.ResultsTable; 

public class ObjPearson_Coeff implements PlugInFilter{
	ImagePlus imp, imp0;
	ImageProcessor ip1, ip0, ip2;
	long pix1=0;
	long pix0=0;
	ResultsTable resulty;
	int thread_num_;
	
	public int setup(String arg, ImagePlus imp)
	{
		IJ.register (ObjPearson_Coeff.class);
		if (IJ.versionLessThan("1.32c")){
			IJ.showMessage("Error", "Please Update ImageJ.");
			return 0;
		}
		
		//	IJ.log(" wList;"+String.valueOf(wList));
		
		this.imp = imp;
		if(imp.getType()!=imp.GRAY8 && imp.getType()!=imp.GRAY16 && imp.getType()!=imp.GRAY32){
			IJ.showMessage("Error", "Plugin requires 8-, 16, 32-bit image");
			return 0;
		}
		return DOES_8G+DOES_16+DOES_32;
		
		//	IJ.log(" noisemethod;"+String.valueOf(ff));
	}
	
	public void run(ImageProcessor ip1){
		
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
		int Mask=(int)Prefs.get("tempimage.int",0);
		int datafile=(int)Prefs.get("sampleimage.int",1);
		boolean showlogobj = (boolean)Prefs.get("showlogobj.boolean",false);
		boolean changetitleobj = (boolean)Prefs.get("changetitleobj.boolean",false);
		int sampleDominant = (int)Prefs.get("sampleDominant.int",0);
		thread_num_=(int)Prefs.get("thread_num.int",6);
		
		if(datafile >= imageno)
		datafile=imageno-1;
		
		if(Mask >= imageno)
		Mask=imageno-1;
		
		GenericDialog gd = new GenericDialog("ObjPearsonCoeff");
		gd.addChoice("Template", titles, titles[Mask]); //template
		gd.addChoice("Sample", titles, titles[datafile]); //sample
		gd.addCheckbox("Show log", showlogobj);
		gd.addCheckbox("Change Title as output", changetitleobj);
		
		String []	CalMST2 = {"Equal weight (temp and sample)", "Sample dominant"};
		gd.addRadioButtonGroup("Weight method", CalMST2, 0, 2, CalMST2[sampleDominant]);
		
		gd.addNumericField("Parallel Threads", thread_num_, 0);
		
		gd.showDialog();
		if(gd.wasCanceled()){
			return;
		}
		
		Mask = gd.getNextChoiceIndex(); //Mask
		datafile = gd.getNextChoiceIndex(); //Color MIP
		showlogobj= gd.getNextBoolean();
		changetitleobj= gd.getNextBoolean();
		String STdominant = (String)gd.getNextRadioButton();
		thread_num_ = (int)gd.getNextNumber();
		
		if(STdominant == "Equal weight (temp and sample)")
		sampleDominant = 0;
		else if(STdominant == "Sample dominant")
		sampleDominant = 1;
		
		Prefs.set("sampleDominant.int", sampleDominant);
		
		Prefs.set("tempimage.int",Mask);
		Prefs.set("sampleimage.int", datafile);
		Prefs.set("showlogobj.boolean", showlogobj);
		Prefs.set("changetitleobj.boolean", changetitleobj);
		
		if(thread_num_ <= 0) thread_num_ = 1;
		Prefs.set("thread_num.int", thread_num_);
		
		ImagePlus imp0 = WindowManager.getImage(wList[Mask]); //temp
		//	titles[Mask] = imask.getTitle();
		ImagePlus imp = WindowManager.getImage(wList[datafile]); //sample
		
		//	imp = WindowManager.getCurrentImage();
		
		ImageStack stack1 = imp.getStack(); //stack sample
		ImageStack stack0 = imp0.getStack(); //stack template
		
		final int Fnslice = imp.getStackSize(); //stack
		int nSliceT = imp0.getStackSize(); //temp stack
		
		if(nSliceT!=Fnslice){
			IJ.log("Sample and Template have different slice number!");
			return;
		}
		
		int width2 = imp.getWidth();
		int height2 = imp.getHeight();
		int sumpx = width2*height2;
		final AtomicInteger ai = new AtomicInteger(1);
		final Thread[] threads = newThreadArray();
		final int FsampleDominant=sampleDominant;
		
		//// sum and average samp value detection for all slices ////////////////////////////////
		
		BigDecimal sumVX = new BigDecimal("0.00");
		BigDecimal sumVX0 = new BigDecimal("0.00");
		double AVEtemp=0, AVEsamp=0;;
		BigDecimal TotalCountTemp = new BigDecimal("0.00");
		
		if(width2==512 && height2==256 && Fnslice==109)
		AVEtemp=88.95;//JFRC2010 mask
		
		/// Sum value measurement /////////////////////////////////////////
		for(int nn=1; nn<=Fnslice; nn++){
			IJ.showProgress((double)nn/(double)Fnslice);
			
			//	IJ.log(" slice;"+String.valueOf(nn)+"   TotalCountTemp; "+String.valueOf(TotalCountTemp));
			
			ip0 = stack0.getProcessor(nn); //stack, tamplate data
			ip1 = stack1.getProcessor(nn); //stack, sample data
		
			for(int Gn=0; Gn<sumpx; Gn++){
				if(AVEtemp==0){
					pix0 = ip0.get(Gn);//template
					if(pix0!=0)
					sumVX0 = sumVX0.add(BigDecimal.valueOf(pix0));//total sum temp
				}
					
				pix1= ip1.get(Gn);//sample
				if(pix1!=0)
				sumVX = sumVX.add(BigDecimal.valueOf(pix1));//total sum sample
				//	TotalCountSamp=TotalCountSamp.add(One);
			}//for(int n=0; n<sumpx; n++){
		}//for(int nn=1; nn<=Fnslice; nn++){
		
		TotalCountTemp=BigDecimal.valueOf(sumpx).multiply(BigDecimal.valueOf(Fnslice));
		
		if(AVEtemp==0){
			if(sumVX0.compareTo(BigDecimal.ZERO)!=0)
			AVEtemp = (sumVX0.divide(TotalCountTemp, 2, BigDecimal.ROUND_HALF_UP)).doubleValue();//template
		}
		
		if(sumVX.compareTo(BigDecimal.ZERO)!=0)
		AVEsamp = (sumVX.divide(TotalCountTemp, 2, BigDecimal.ROUND_HALF_UP)).doubleValue();//sample
		
		if(showlogobj){
			IJ.log("AVEsamp; "+String.valueOf(AVEsamp));
			IJ.log("AVEtemp; "+String.valueOf(AVEtemp)+"   Vol; "+String.valueOf(TotalCountTemp));
		}
		
		final long[] tempPowSum = new long[Fnslice+1];
		final long[] sampPowSum = new long[Fnslice+1];
		final long[] valSum = new long[Fnslice+1];
		final double AVEsampF=AVEsamp;
		final double AVEtempF=AVEtemp;
	
		
		for (int ithread = 0; ithread < threads.length; ithread++) {
			threads[ithread] = new Thread() {
				
				{ setPriority(Thread.NORM_PRIORITY); }
				
				public void run() {
					
					for(int SliceShift=ai.getAndIncrement(); SliceShift<=Fnslice; SliceShift=ai.getAndIncrement()){
						
						ImageProcessor iptemp= stack0.getProcessor(SliceShift); //stack, tamplate data
						ImageProcessor ipsamp= stack1.getProcessor(SliceShift); //stack, sample data
						if(IJ.escapePressed()){
							return;
						}
						int SliceShiftFn=SliceShift-1;
						OBJpearson(ipsamp,iptemp,FsampleDominant,tempPowSum,sampPowSum,valSum,SliceShiftFn,AVEsampF,AVEtempF);
						
					}//for(int SliceShift=ai.getAndIncrement(); SliceShift<=Fnslice; SliceShift=ai.getAndIncrement()){
			}};
		}//	for (int ithread = 0; ithread < threads.length; ithread++) {
		startAndJoin(threads);
		
		long sampPowSumTotal=0, tempPowSumTotal=0, valSumTotal=0;
		for(int islice=0; islice<Fnslice; islice++){
			
			sampPowSumTotal=sampPowSumTotal+sampPowSum[islice];
			tempPowSumTotal=tempPowSumTotal+tempPowSum[islice];
			valSumTotal=valSumTotal+valSum[islice];
		}
		
		
		double score = 0;
		BigDecimal Cross =  new BigDecimal("0.00");
		
		if(sampPowSumTotal!=0 && tempPowSumTotal!=0){
			Cross = BigDecimal.valueOf(sampPowSumTotal).multiply(BigDecimal.valueOf(tempPowSumTotal));//
			Cross = Cross.setScale(2, BigDecimal.ROUND_HALF_UP);
			
			double x = Math.sqrt(Cross.doubleValue());
			long xx= (new Double(x)).longValue();
			
			if(xx!=0){
				long xsqrt = xx+((Cross.longValue()-(xx*xx))/(xx*2));			
				if(valSumTotal!=0 && xsqrt!=0){
					score= (double) valSumTotal / (double) xsqrt;
					
					double score2 = Double.parseDouble(String.format("%.4f", score));
					
					IJ.log("score; "+String.valueOf(score2));
					
					if(changetitleobj)
					imp.setTitle(String.valueOf(score2));
					
				}else
				IJ.log("valSumTotal; "+String.valueOf(valSumTotal)+"   xsqrt; "+String.valueOf(xsqrt)+"Cross; "+String.valueOf(Cross));
				
			}//	if(xx!=0){
		}else{//if(sampPowSumTotal!=0 && tempPowSumTotal!=0){
			IJ.log("The value is 0");
		}
		
		
	} //public void run(ImageProcessor ip){
	public void OBJpearson(ImageProcessor ipSampDupF, ImageProcessor ipTempF, int sampleDominantF, long tempPowSum[], long sampPowSum[], long valSum[], int FSliceShift, double AVEsampO, double AVEtempO){
		
		double TempMinusAVE= 0;
		double SampMinusAVE= 0;
		
		long sumpx = ipTempF.getPixelCount();
		
		
		//		IJ.log("AVEsampO; "+String.valueOf(AVEsampO));
		//		IJ.log("AVEtemp; "+String.valueOf(AVEtemp)+"   Vol; "+String.valueOf(TotalCountTemp));
		
		
		if(AVEtempO!=0 && AVEsampO!=0){
			if(sampleDominantF==1){
				for(int singlepix=0; singlepix<sumpx; singlepix++){
					
					double sampPix=ipSampDupF.get(singlepix);//+sumpx
					
					if(sampPix!=0){
						double tempPix=ipTempF.get(singlepix);
						//		if(tempPix>1 || sampPix>1){
						
						TempMinusAVE=tempPix-AVEtempO;
						SampMinusAVE=sampPix-AVEsampO;
						
						tempPowSum[FSliceShift]=tempPowSum[FSliceShift]+(new Double(TempMinusAVE*TempMinusAVE)).longValue();
						sampPowSum[FSliceShift]=sampPowSum[FSliceShift]+(new Double(SampMinusAVE*SampMinusAVE)).longValue();
						
						valSum[FSliceShift]=valSum[FSliceShift]+(new Double(TempMinusAVE*SampMinusAVE)).longValue();
						//		}
					}//if(sampPix!=0){
				}//for(xx=0; xx<width; xx++){
			}else{
				for(int singlepix=0; singlepix<sumpx; singlepix++){
					
					double tempPix=ipTempF.get(singlepix);
					double sampPix=ipSampDupF.get(singlepix);//+sumpx
					
					//	if(tempPix>1 || sampPix>1){
					
					TempMinusAVE=tempPix-AVEtempO;
					SampMinusAVE=sampPix-AVEsampO;
					
					tempPowSum[FSliceShift]=tempPowSum[FSliceShift]+(new Double(TempMinusAVE*TempMinusAVE)).longValue();
					sampPowSum[FSliceShift]=sampPowSum[FSliceShift]+(new Double(SampMinusAVE*SampMinusAVE)).longValue();
					
					valSum[FSliceShift]=valSum[FSliceShift]+(new Double(TempMinusAVE*SampMinusAVE)).longValue();
					//		}
				}//for(xx=0; xx<width; xx++){
			}//if(sampleDominantF==1){
			
			
		}else if(AVEsampO==0){
			
			if(sampleDominantF==1){
				for(int singlepix=0; singlepix<sumpx; singlepix++){
					
					double sampPix=ipSampDupF.get(singlepix);//+sumpx
					
					if(sampPix>0){
						double tempPix=ipTempF.get(singlepix);
						
						if(tempPix>1 || sampPix>1){
							
							TempMinusAVE=tempPix-AVEtempO;
							SampMinusAVE=sampPix;
							
							tempPowSum[FSliceShift]=tempPowSum[FSliceShift]+(new Double(TempMinusAVE*TempMinusAVE)).longValue();
							sampPowSum[FSliceShift]=sampPowSum[FSliceShift]+(new Double(SampMinusAVE*SampMinusAVE)).longValue();
							
							valSum[FSliceShift]=valSum[FSliceShift]+(new Double(TempMinusAVE*SampMinusAVE)).longValue();
						}//if(tempPix>1 || sampPix>1){
					}//if(sampPix>0){
				}//for(int singlepix=0; singlepix<sumpx; singlepix++){
			}else{
				for(int singlepix=0; singlepix<sumpx; singlepix++){
					
					double tempPix=ipTempF.get(singlepix);
					double sampPix=ipSampDupF.get(singlepix);//+sumpx
					
					if(tempPix>1 || sampPix>1){
						
						TempMinusAVE=tempPix-AVEtempO;
						SampMinusAVE=sampPix;
						
						tempPowSum[FSliceShift]=tempPowSum[FSliceShift]+(new Double(TempMinusAVE*TempMinusAVE)).longValue();
						sampPowSum[FSliceShift]=sampPowSum[FSliceShift]+(new Double(SampMinusAVE*SampMinusAVE)).longValue();
						
						valSum[FSliceShift]=valSum[FSliceShift]+(new Double(TempMinusAVE*SampMinusAVE)).longValue();
					}
				}//for(xx=0; xx<width; xx++){
			}//if(sampleDominantF==1){
			
		}//	if(AVEtempO!=0 && AVEsampO!=0){
//		IJ.log("FSliceShift; "+String.valueOf(FSliceShift));
	}//public void OBJpearson

	
	private Thread[] newThreadArray() {
		int n_cpus = Runtime.getRuntime().availableProcessors();
		if (n_cpus > thread_num_) n_cpus = thread_num_;
		if (n_cpus <= 0) n_cpus = 1;
		return new Thread[n_cpus];
	}
	
	public static void startAndJoin(Thread[] threads)
	{
		for (int ithread = 0; ithread < threads.length; ++ithread)
		{
			threads[ithread].setPriority(Thread.NORM_PRIORITY);
			threads[ithread].start();
		}
		
		try
		{   
			for (int ithread = 0; ithread < threads.length; ++ithread)
			threads[ithread].join();
		} catch (InterruptedException ie)
		{
			throw new RuntimeException(ie);
		}
	}
} //public class Two_windows_mask_search implements PlugInFilter{





