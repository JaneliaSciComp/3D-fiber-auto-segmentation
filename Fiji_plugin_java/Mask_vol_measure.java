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



public class Mask_vol_measure implements PlugInFilter
{
	ImagePlus imp;
	ImageProcessor ip1;
	static String result_ = new String();
	
	public int setup(String arg, ImagePlus imp)
	{
		IJ.register (Mask_vol_measure.class);
		if (IJ.versionLessThan("1.32c")){
			IJ.showMessage("Error", "Please Update ImageJ.");
			return 0;
		}
		
		this.imp = imp;
		
		return DOES_ALL;
	}
	
	public void run(ImageProcessor ip1){
		
		int ThMask=(int)Prefs.get("ThMask.int",0);
		int Volume=(int)Prefs.get("Volume.int",0);
		
		int wList [] = WindowManager.getIDList();
		if (wList==null || wList.length<2) {
			IJ.showMessage("There should be at least two windows open");
			return;
		}
		int imageno = 0; int SingleSliceMIPnum=0; int MultiSliceStack=0;
		String titles [] = new String[wList.length];
		int slices [] = new int[wList.length];
		
		for (int i=0; i<wList.length; i++) {
			ImagePlus imp = WindowManager.getImage(wList[i]);
			if (imp!=null){
				titles[i] = imp.getTitle();//Mask.tif and Data.tif
				slices[i] = imp.getStackSize();
				
				imageno = imageno +1;
			}else
			titles[i] = "";
		}
		
		
		if(Volume >= wList.length || ThMask >= wList.length){
			Volume = wList.length-1;
			ThMask = 0;
		}
		
		
		GenericDialog gd = new GenericDialog("Mask 3D volume measurement");
		gd.addChoice("Volume to be measure signal amount", titles, titles[Volume]); //Mask
		gd.addChoice("3D mask for the volume", titles , titles[ThMask]); //Negative Mask
		
		gd.showDialog();
		if(gd.wasCanceled()){
			return;
		}
		
		Volume = gd.getNextChoiceIndex();
		ThMask = gd.getNextChoiceIndex();
		
		
		Prefs.set("Volume.int", Volume);
		Prefs.set("ThMask.int", ThMask);
		
		ImagePlus VolumePlus = WindowManager.getImage(wList[Volume]);
		ImagePlus MaskPlus = WindowManager.getImage(wList[ThMask]);
		
		//	imp.updateAndDraw();
		//	imp.show();
		maskM (VolumePlus,MaskPlus);
	} //public void run(ImageProcessor ip){
	
	ImagePlus maskM (ImagePlus VolumePlusF, ImagePlus MaskPlusF) {
		
		int slicenumber = VolumePlusF.getStackSize();
		
		ImageProcessor ip3 = VolumePlusF.getProcessor();
		
		int sumpx = ip3.getPixelCount();
		int width = VolumePlusF.getWidth();
		int height = VolumePlusF.getHeight();
		
		ImageStack stvol = VolumePlusF.getStack();
		ImageStack stmask = MaskPlusF.getStack();
		
		
		double maxval=0;
		double pixM=0, pixV=0;
		double areaArray[]; 
		areaArray = new double [slicenumber+1]; 
		
		for(int isliceB=1; isliceB<=slicenumber; isliceB++){
			ImageProcessor ipvol = stvol.getProcessor(isliceB);// data
			ImageProcessor ipmask = stmask.getProcessor(isliceB);// data
			
			
			for(int ipixB=0; ipixB<sumpx; ipixB++){
				
				pixM=ipmask.get(ipixB);
				
				if(pixM!=0){
					pixV=ipvol.get(ipixB);
					
					if(pixV!=0)
					areaArray[isliceB]=areaArray[isliceB]+1;
				}
			}
		}
		
		double totalVolume=0;
		
		for(int islice2=1; islice2<=slicenumber; islice2++){
			totalVolume = totalVolume+areaArray[islice2-1];	
		}
		
		IJ.log("totalVolume; "+String.valueOf(totalVolume));
		result_ = String.valueOf(totalVolume);
		return VolumePlusF;
		//newimp.show();
	} //public void run(ImageProcessor ip){
	
	public static String getResult() { 
		return result_; 
	}
} //public class Two_windows_mask_search implements PlugInFilter{



























