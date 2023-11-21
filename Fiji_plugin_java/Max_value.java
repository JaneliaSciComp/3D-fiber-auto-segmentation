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
//import ij.macro.*;
import ij.gui.GenericDialog.*;
//import java.math.BigDecimal;
//import java.math.BigInteger;
import ij.measure.ResultsTable; 

public class Max_value implements PlugInFilter{
	
	ImagePlus imp, imp0;
	ImageProcessor ip1, ip0, ip2;
	int pix1=0;
	ResultsTable resulty;
	static String result_ = new String();
	
	public int setup(String arg, ImagePlus imp)
	{
		IJ.register (Max_value.class);
		if (IJ.versionLessThan("1.32c")){
			IJ.showMessage("Error", "Please Update ImageJ.");
			return 0;
		}
		
		this.imp = imp;
		if(imp.getType()!=imp.GRAY8 && imp.getType()!=imp.GRAY16 && imp.getType()!=imp.GRAY32){
			IJ.showMessage("Error", "Plugin requires 8-, 16, 32-bit image");
			return 0;
		}
		return DOES_8G+DOES_16+DOES_32;

	//	IJ.log(" noisemethod;"+String.valueOf(ff));
	}

	public void run(ImageProcessor ip1){
		
		imp = WindowManager.getCurrentImage();
		
		ImageStack stack1 = imp.getStack(); //stack sample
		
		int nSlice = imp.getStackSize(); //stack
		
		int width2 = imp.getWidth();
		int height2 = imp.getHeight();
		int sumpx = width2*height2;
		

		IJ.showStatus("Measuring max value");
		/////////////////////Start: signal detection///////////////////////////////
		int maxvalue=0; int minvalue=1000000;
		for(int nn=1; nn<=nSlice; nn++){
			if(IJ.escapePressed()){
				return;
			}
			IJ.showProgress((double)nn/(double)nSlice);
			
			ip1 = stack1.getProcessor(nn); //stack, sample data
			
			for(int Gn=0; Gn<sumpx; Gn++){
				pix1= ip1.get(Gn);//sample
				
				if(pix1>maxvalue)
				maxvalue=pix1;
				
				if(pix1<minvalue)
				minvalue=pix1;
			}//for(int n=0; n<sumpx; n++){
		}//for(int nn=1; nn<=nSlice; nn++){
		
		IJ.log("Maxvalue; "+String.valueOf(maxvalue)+"  Minvalue; "+String.valueOf(minvalue));
		
		result_ = String.valueOf(maxvalue);
		
	} //public void run(ImageProcessor ip){
	
	public static String getResult() { 
		return result_; 
	}
} //public class Two_windows_mask_search implements PlugInFilter{





