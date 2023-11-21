import ij.*;
import ij.CompositeImage;
import ij.ImagePlus;
import ij.ImageStack;
import ij.plugin.filter.*;
import ij.plugin.PlugIn;
import ij.process.*;
import ij.gui.*;
import java.math.*;
import java.io.*;
import java.util.Arrays;
import java.util.ArrayList;
import java.net.*;
import ij.Macro.*;
import java.awt.*;
//import ij.macro.*;
import ij.gui.GenericDialog.*;
import java.util.*;
import java.lang.*;
import ij.plugin.HyperStackConverter;

import org.apache.commons.lang.ArrayUtils;



public class A4095_normalizer implements PlugInFilter
{
	ImagePlus imp;
	ImageProcessor ip1;
	
	public int setup(String arg, ImagePlus imp)
	{
		IJ.register (A4095_normalizer.class);
		if (IJ.versionLessThan("1.32c")){
			IJ.showMessage("Error", "Please Update ImageJ.");
			return 0;
		}
		
		this.imp = imp;
		
		return DOES_ALL;
	}
	
	public void run(ImageProcessor ip1){
		imp = WindowManager.getCurrentImage();
		
		
		int SubtractV=(int)Prefs.get("SubtractV.int",0);

		
		int startsli=(int)Prefs.get("startsli.int",0);
		int endslice=(int)Prefs.get("endslice.int",100);
		
		GenericDialog gd = new GenericDialog("Subtraction value");
		
		gd.addNumericField("Subtraction value", SubtractV, 0);
		
		gd.addNumericField("Start slice", startsli, 0);
		gd.addNumericField("End slice", imp.getStackSize(), 0);
		
		gd.showDialog();
		if(gd.wasCanceled()){
			return;
		}
		
		SubtractV=(int)gd.getNextNumber();
		
		startsli=(int)gd.getNextNumber();
		endslice=(int)gd.getNextNumber();
		
		Prefs.set("SubtractV.int",SubtractV);
		
		Prefs.set("startsli.int",startsli);
		Prefs.set("endslice.int",endslice);
		
	
	

		imp=zresizeMIP (imp,SubtractV,startsli,endslice);
		imp.updateAndDraw();
	//	imp.show();
		
	} //public void run(ImageProcessor ip){
	
	ImagePlus zresizeMIP (ImagePlus channels,int subV, int sts, int ends) {
		
		int slicenumber = channels.getStackSize();
		//	slicenumber=slicenumber/channels.length;
		
	
		
		ImageProcessor ip3 = channels.getProcessor();
		
		int sumpx = ip3.getPixelCount();
		int width = channels.getWidth();
		int height = channels.getHeight();
		
		ImageStack st1 = channels.getStack();
		
		if(sts<1)
		sts=1;
		
		if(ends>slicenumber)
		ends=slicenumber;
		double maxval=0;
		double pixM=0;
		
		for(int isliceB=sts; isliceB<=ends; isliceB++){
			ip3 = st1.getProcessor(isliceB);// data
			
			for(int ipixB=0; ipixB<sumpx; ipixB++){
				pixM=ip3.get(ipixB);
				
				if(pixM>maxval){
					maxval=pixM;
				}
			}
		}
		
		IJ.log("start; "+String.valueOf(sts)+"  end; "+String.valueOf(ends)+"  maxval; "+String.valueOf(maxval));
		
		double divideval=maxval/4096;
		
		for(int islice=sts; islice<=ends; islice++){
			ip3 = st1.getProcessor(islice);// data
			
			for(int ipix=0; ipix<sumpx; ipix++){
				double pix1=ip3.get(ipix);
				double pix1sub = pix1/divideval;
				
				int finalpix= (int) pix1sub - subV;
				
				if(finalpix<0)
				finalpix=0;
				
				if (finalpix>4095)
				finalpix=4095;
				
				ip3.set(ipix,finalpix);
				
			}
		}
		
		return channels;
		//newimp.show();
	} //public void run(ImageProcessor ip){
} //public class Two_windows_mask_search implements PlugInFilter{



























