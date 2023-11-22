//************************************************
// 
// Written by Hideo Otsuna (HHMI Janelia inst.)
// Oct 2023
// 
//**************************************************

import ij.*;
import ij.process.*;
import ij.gui.*;
import ij.io.DirectoryChooser;
import ij.io.FileSaver;
import ij.plugin.PlugIn;
import ij.plugin.frame.*; 
import ij.plugin.filter.*;
//import ij.plugin.Macro_Runner.*;
import ij.gui.GenericDialog.*;
import ij.macro.*;
import ij.measure.Calibration;
import ij.plugin.CanvasResizer;
import ij.plugin.Resizer;
import ij.util.Tools;
import ij.io.FileInfo;
import ij.io.TiffEncoder;
import ij.plugin.filter.GaussianBlur;

import java.awt.*;
import java.awt.image.*;
import javax.imageio.*;
import javax.imageio.ImageIO;
import javax.imageio.metadata.IIOMetadata;
import javax.imageio.spi.ImageWriterSpi;
import javax.imageio.stream.ImageInputStream;
import javax.imageio.stream.ImageOutputStream;
import javax.imageio.ImageIO;


import java.io.DataOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.util.zip.GZIPOutputStream;
import java.io.IOException;
import java.io.File;
import java.nio.*;
import java.util.*;
import java.util.Iterator;
import java.nio.charset.Charset;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.util.concurrent.atomic.AtomicInteger;


public class Seg_volume_combine_to_heatmap implements PlugIn {
	
	
	public void run(String arg) {
		
		int Thremethod=(int)Prefs.get("Thremethod.int",0);
		int ThreVal=(int)Prefs.get("ThreVal.int",3);
		
		GenericDialog gd = new GenericDialog("Volume 1 value adding");
		
		String []	shitstr = {"Fixed threshold", "Auto threshold"};
		gd.addRadioButtonGroup("Thresholding method: ", shitstr, 1, 2, shitstr[Thremethod]);
		
		gd.addNumericField("Thresholding value", ThreVal, 0);
		
		gd.showDialog();
		if(gd.wasCanceled()){
			return;
		}
		
		String ThremethodST=(String)gd.getNextRadioButton();
		
		ThreVal = (int)gd.getNextNumber();
		
		if(ThremethodST.equals("Fixed threshold"))
		Thremethod=0;
		else if(ThremethodST.equals("Auto threshold"))
		Thremethod=1;
		
		Prefs.set("ThreVal.int", ThreVal);
		Prefs.set("Thremethod.int", Thremethod);
		
		
		DirectoryChooser dirO = new DirectoryChooser("segmented nrrd directory");
		String Odirectory = dirO.getDirectory();
		
		DirectoryChooser dirs = new DirectoryChooser("Save directory");
		String Sdirectory = dirs.getDirectory();
		
		IJ.log("Odirectory; "+Odirectory+"   Sdirectory; "+Sdirectory);
		
		File OdirectoryFile = new File(Odirectory);
		final File names[] = OdirectoryFile.listFiles(); 
		Arrays.sort(names);
		
		IJ.log("names length;"+names.length);
		
		
		long timestart = System.currentTimeMillis();
		
		MIPfunction(Odirectory,names,Sdirectory,ThremethodST,ThreVal);
		
		long timeend = System.currentTimeMillis();
		
		long gapS = (timeend-timestart)/1000;
		
		IJ.log("Done "+gapS+" second");
		
	} //public void run(String arg) {
	
	public void MIPfunction (final String FOdirectory, File names[],final String SdirectoryF, String ThremethodSTF, int ThreValF){
		
		int firsttime=0;
		ImagePlus impSUM =null;
		ImageStack stackSUM=null;
		int numnrrd=0;
		
		for(int inrrd=0; inrrd<names.length; inrrd++){
			
			//IJ.showProgress((double)inrrd/(double) names.length);
			IJ.showStatus(String.valueOf(inrrd));
			
			int tifposi = names[inrrd].getName().lastIndexOf("nrrd");
			
			if(tifposi>0){
				
				ImagePlus imp =null;// new ImagePlus();
				numnrrd=numnrrd+1;
				
				while(imp==null){
					imp = IJ.openImage(FOdirectory+names[inrrd].getName());
				}
				
				ImageStack stack = imp.getStack(); //stack
				int nSlice = imp.getStackSize(); //stack
				ImageProcessor ip = imp.getProcessor(); //Mask
				int sumpx = ip.getPixelCount();
				
				if(firsttime==0){
					impSUM = imp.duplicate();
					stackSUM = impSUM.getStack();
					
					for(int nsum=1; nsum<=nSlice; nsum++){// set to zero
						
						ImageProcessor ipSUM = stackSUM.getProcessor(nsum);
						for(int n=0; n<sumpx; n++){
							ipSUM.set(n,0);
						}
					}
					firsttime=1;
				}
				
				if(ThremethodSTF.equals("Auto threshold")){
					int maxsize=10000;
					int iskip=10;
					
					///MIP creation ///
					
					int width = ip.getWidth();
					int height = ip.getHeight();
					
					int[] HistoArary = new int[65536];
					
					ImageProcessor MIPip = new ShortProcessor(width, height);
					ImagePlus originalValue1imp = new ImagePlus ("MIP.tif",MIPip);
					
					int maxpx=0;
					
					for(int nsum=1; nsum<=nSlice; nsum++){// set to zero
						
						ImageProcessor ipslice = stack.getProcessor(nsum);
						
						for(int n=0; n<sumpx; n++){
							int pix = ipslice.get(n);
							
							if(pix>0){
								
								int Mpix = MIPip.get(n);
								if(Mpix<pix)
								MIPip.set(n,pix);
								
								if(pix>maxpx)
								maxpx=pix;
							}
						}//	for(int n=0; n<sumpx; n++){
					}
					
					for(int nM=0; nM<sumpx; nM++){
						int pixM = MIPip.get(nM);
						if(pixM>0)
						HistoArary[pixM]=HistoArary[pixM]+1;
					}
					
					int [] STDarray=new int [maxpx];
					int bestthreValue=0;
					
					int sdtmax=0; 
					
					for(int i=0; i<maxpx-iskip; i++){
						long sum=0;
						
						for(int ihisto=i; ihisto<i+iskip; ihisto++){
							sum = sum+(HistoArary[ihisto]-HistoArary[ihisto+1])*(HistoArary[ihisto]-HistoArary[ihisto+1]);
						}
						STDarray[i + 1] = (int) Math.round(Math.sqrt((sum) / iskip));
						
						if(sdtmax<STDarray[i+1]){
							sdtmax=STDarray[i+1];
						
				//			IJ.log(i+"_"+STDarray[i+1]);
							if(STDarray[i+1]>0)
							bestthreValue=STDarray[i+1];
						}
					}
					
					if(bestthreValue<=500)
					bestthreValue=Math.round(bestthreValue/2);
					
					ThreValF=bestthreValue;
					IJ.log(names[inrrd].getName()+"  bestthreValue; "+bestthreValue+"  maxpx; "+maxpx);
				}//		if(ThremethodST.equals("Auto threshold")){
				
				for(int nn=1; nn<=nSlice; nn++){
					ip = stack.getProcessor(nn); //stack
					
					ImageProcessor ipSUM = stackSUM.getProcessor(nn);
					
					for(int n=0; n<sumpx; n++){
						int pix1= ip.get(n);
						
						if(pix1>ThreValF){// count mask more than 3 gray value
							int pixSUM= ipSUM.get(n);
							
							ipSUM.set(n,1+pixSUM);
						}
					}//for(int n=0; n<sumpx; n++){
				}//for(int nn=1; nn<=nSlice; nn++){
				
				imp.flush();
				imp.close();
			}//	if(tifposi>0){
		}
		
		IJ.saveAs(impSUM,"Tiff", SdirectoryF+"Heatmap_"+numnrrd+"_Added.tif");
		
		impSUM.flush();
		impSUM.close();
		
	}
}




