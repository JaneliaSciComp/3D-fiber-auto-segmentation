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



public class ThreeD_vol_measure implements PlugInFilter
{
	ImagePlus imp;
	ImageProcessor ip1;
	static String result_ = new String();
	
	public int setup(String arg, ImagePlus imp)
	{
		IJ.register (ThreeD_vol_measure.class);
		if (IJ.versionLessThan("1.32c")){
			IJ.showMessage("Error", "Please Update ImageJ.");
			return 0;
		}
		
		this.imp = imp;
		
		return DOES_ALL;
	}
	
	public void run(ImageProcessor ip1){
		
		int Morethan=(int)Prefs.get("Morethan.int",0);
		int Volume=(int)Prefs.get("Volume.int",0);
		
		int wList [] = WindowManager.getIDList();
		if (wList==null) {
			IJ.showMessage("There should be at least one image open");
			return;
		}
		
		ImagePlus imp = WindowManager.getCurrentImage();
		
		GenericDialog gd = new GenericDialog("3D volume measurement");
		gd.addSlider("Measure volume more than this value; ", 0, 255, Morethan);
		
		gd.showDialog();
		if(gd.wasCanceled()){
			return;
		}
		
		Morethan=(int)gd.getNextNumber();
		
		Prefs.set("Morethan.int", Morethan);
		
		//	imp.updateAndDraw();
		//	imp.show();
		VolM (imp,Morethan);
	} //public void run(ImageProcessor ip){
	
	ImagePlus VolM (ImagePlus impF, int MorethanF) {
		
		int slicenumber = impF.getStackSize();
		
		ImageProcessor ip3 = impF.getProcessor();
		
		int sumpx = ip3.getPixelCount();
		int width = impF.getWidth();
		int height = impF.getHeight();
		
		ImageStack stvol = impF.getStack();
		
		
		double maxval=0;
		double pixV=0;
		double areaArray[]; 
		areaArray = new double [slicenumber+1]; 
		
		for(int isliceB=1; isliceB<=slicenumber; isliceB++){
			ImageProcessor ipvol = stvol.getProcessor(isliceB);// data		
			
			for(int ipixB=0; ipixB<sumpx; ipixB++){
				
				pixV=ipvol.get(ipixB);
				
				if(pixV > MorethanF)
				areaArray[isliceB]=areaArray[isliceB]+1;
				
			}
		}
		
		double totalVolume=0;
		
		for(int islice2=1; islice2<=slicenumber; islice2++){
			totalVolume = totalVolume+areaArray[islice2-1];	
		}
		
		IJ.log("totalVolume; "+String.valueOf(totalVolume));
		result_ = String.valueOf(totalVolume);
		return impF;
		//newimp.show();
	} //public void run(ImageProcessor ip){
	
	public static String getResult() { 
		return result_; 
	}
} //public class Two_windows_mask_search implements PlugInFilter{



























