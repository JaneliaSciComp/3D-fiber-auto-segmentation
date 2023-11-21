//************************************************
// Gamma adjustment plugin 
// Written by Hideo Otsuna (HHMI Janelia inst.)
// Aug 2015
// 
//**************************************************

import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
//import ij.plugin.*;
import ij.plugin.PlugIn;
import ij.plugin.frame.*; 
import ij.plugin.filter.*;
//import ij.plugin.Macro_Runner.*;
import ij.gui.GenericDialog.*;
import ij.macro.*;
import javax.swing.*;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener; 
import java.util.concurrent.atomic.AtomicInteger;

public class Gamma_ extends JFrame implements PlugIn {
	//int wList [] = WindowManager.getIDList();
	private JTextField textFieldR;
	private JTextField textFieldL;
	private JFrame sliderFrame;
	ImagePlus imp, nimp;
	ImageProcessor ip, ip2;
	int bittype=0;
	int sourceRR=0;
	int countsource;
	int count;
	String macro;
	int sliceposition=0;
	boolean ThreeD=false;
	double gamma=0;
	int majorT=0;
	int minorT=0;
	double setvalue=0;
	int [] RR= new int [2];
	int thread_num_=0;
	
	public void run(String arg) {
		imp = WindowManager.getCurrentImage();
		//	this.imp = imp;
		
		IJ.register (Gamma_.class);
		if (IJ.versionLessThan("1.32c")){
			IJ.showMessage("Error", "Please Update ImageJ.");
			return;
		}
		int[] wList = WindowManager.getIDList();
		if (wList==null) {
			IJ.error("No images are open.");
			return;
		}
		if(imp.getType()!=imp.GRAY8 && imp.getType()!=imp.GRAY16){
			IJ.showMessage("Error", "Plugin requires 8- or 16-bit image");
			return;
		}
		
		if(imp.getType()==imp.GRAY8){
			bittype=0;
			majorT=3;
			minorT=3;
			setvalue=255;
		}else if(imp.getType()==imp.GRAY16 ){
			bittype=1;
			majorT=3;
			minorT=3;
			setvalue=65535;
		}
		
		int curslice=imp.getSlice();
		int bdepth = imp.getBitDepth();
		String [] macroor = {"InMacro", "NotInMacro"};
		
		gamma = (double)Prefs.get("gamma.double", 1.3);
		ThreeD = (boolean)Prefs.get("ThreeD.boolean",false);
		macro = (String)Prefs.get("macro.String", "InMacro");
		thread_num_=(int)Prefs.get("thread_numG.int",4);
		
		GenericDialog gd = new GenericDialog("Background thresholding");
		
		gd.addNumericField("Gamma value 0.1~3.0", gamma, 2);
		gd.addCheckbox("3D stack", ThreeD);
		gd.addRadioButtonGroup("in macro or not", macroor, 2, 2, macro);
		
		gd.addNumericField("CPU number", thread_num_, 2);
		
		gd.showDialog();
		if(gd.wasCanceled()){
			return;
		}
		
		
		gamma = (double)gd.getNextNumber();
		ThreeD = gd.getNextBoolean();
		macro =(String)gd.getNextRadioButton();
		thread_num_ = (int)gd.getNextNumber();
		
		Prefs.set("gamma.double", gamma);
		Prefs.set("ThreeD.boolean", ThreeD);
		Prefs.set("macro.String", macro);
		if(thread_num_ <= 0) thread_num_ = 1;
		Prefs.set("thread_numG.int", thread_num_);
		
		final double tengamma=gamma*10;
		int defaultgamma = (int) tengamma;
		newimp = imp.duplicate();
		final int Finthread_num_=thread_num_;
		
		if(macro=="NotInMacro"){//not in macro
			
			newimp.setSlice(curslice);
			newimp.show();
			sliceposition=newimp.getCurrentSlice();
			
			sliderFrame = new JFrame("Slider");
			setDefaultCloseOperation(sliderFrame.DISPOSE_ON_CLOSE);
			Container cont = sliderFrame.getContentPane();
			cont.setLayout(new FlowLayout());
			
			gammafunction(newimp, defaultgamma, sliceposition,setvalue,false,imp,Finthread_num_);
			
			JSlider sliderR = new JSlider(0,30,defaultgamma);// (min, max, default value)
			sliderR.setPaintTicks(true);
			sliderR.setPaintLabels(true);
			sliderR.setMajorTickSpacing(majorT);
			sliderR.setMinorTickSpacing(minorT);
			
			textFieldR = new JTextField(""+defaultgamma+"", 5); // ("defaoult value")
			
			sliderR.addChangeListener(new ChangeListener() { // real time slider
					public void stateChanged(ChangeEvent e) {
						JSlider sourceR = (JSlider) e.getSource();
						textFieldR.setText(""+sourceR.getValue());
						
						sliceposition=newimp.getCurrentSlice();
						sourceRR=sourceR.getValue();
						
						sourceRR=Math.round(sourceRR);
						if(sourceRR==0)
						sourceRR = (int) tengamma;
						
						RR[0]=sourceRR;
						//	IJ.log("  RR138; "+String.valueOf(RR[0]));
						
						gammafunction(newimp, RR[0], sliceposition,setvalue,false,imp,Finthread_num_);
						
						newimp.show();
						//	newimp.getProcessor().resetMinAndMax();
						newimp.updateAndRepaintWindow();
						
					}
			});
			cont.add(sliderR);
			cont.add(textFieldR);
			
			JButton button = new JButton("Apply");
			button.addActionListener(new ActionListener() { //real time button
					public void  actionPerformed(ActionEvent e) { // if clicked button
						
						//	newimp.getProcessor().resetMinAndMax();
						//	newimp.updateAndRepaintWindow();
						//	newimp.unlock();
						sliceposition=newimp.getCurrentSlice();
						
						if(RR[0]==0)
						RR[0] = (int) tengamma;
						
						//	IJ.log("  RR; "+String.valueOf(RR[0]));
						Prefs.set("gamma.double", (double) RR[0]/ (double) 10);
						
						gammafunction( newimp, RR[0], sliceposition,setvalue,ThreeD,imp,Finthread_num_);
						
						//	newimp.updateImage();
						sliderFrame.setVisible(false); //you can't see me!
						sliderFrame.dispose();
						
					}
			});
			
			cont.add(button); 
			sliderFrame.setBounds(250,250,300,200);
			sliderFrame.setVisible(true);
		}else{
			//		sliceposition=newimp.getCurrentSlice();
			gammafunction(newimp, defaultgamma, curslice,setvalue,ThreeD,imp, Finthread_num_);
			
		}//if (macro=="In macro"){
		
		newimp.unlock();
		newimp.show();
		newimp.setSlice(curslice);
	
	//	newimp.updateAndRepaintWindow();
		newimp.updateImage();
		
	} //public void run(String arg) {
	
	public void gammafunction(ImagePlus Fnewimp, int FsourceRR, int Fsliceposition, final double Fsetvalue, boolean FThreeD, ImagePlus Fimp, int Fthread_num_){
		final ImageStack stack1 = Fimp.getStack();
		final ImageStack stack2 = Fnewimp.getStack(); 
		
		final double Dgamma= (double) FsourceRR/ (double) 10;
		
		//	IJ.log("  Dgamma;"+String.valueOf(Dgamma));
		int nslice = Fimp.getNSlices();
		if(FThreeD==true){
			
			if(Fthread_num_ <= 0) Fthread_num_ = 1;
			Prefs.set("thread_num.int", Fthread_num_);
			
			for(int iii=1; iii<=nslice; iii++){
				
				final AtomicInteger ai = new AtomicInteger(0);
				final Thread[] threads = newThreadArray();
				final int Fiii=iii;
				final int Fnslice=nslice;
				
				for (int ithread = 0; ithread < threads.length; ithread++) {
					// Concurrently run in as many threads as CPUs
					threads[ithread] = new Thread() {
						
						{ setPriority(Thread.NORM_PRIORITY); }
						
						public void run() {
							
							
							ImageProcessor Fip2 = stack2.getProcessor(Fiii);
							ImageProcessor Fip = stack1.getProcessor(Fiii);
							int sumpx = Fip.getPixelCount();
							IJ.showProgress((double)Fiii/(double)Fnslice);
							
							for(int ii=ai.getAndIncrement(); ii<sumpx; ii = ai.getAndIncrement()){
								double pix=Fip.get(ii);
								
								double out= (double) Fsetvalue*Math.pow( (double) pix/ (double) Fsetvalue, (double) 1/ (double)  Dgamma);
								
								if(out>Fsetvalue)
								out= (int) Fsetvalue;
								
								if(out<0)
								out= (int) 0;
								
								Fip2.set(ii, (int) out);
								
							}
					}};
				}//	for (int ithread = 0; ithread < threads.length; ithread++) {
				startAndJoin(threads);
			}//	for(int iii=1; iii<=nslice; iii++){
			
		}else{//if(ThreeD not rue){
			ImageProcessor Fip2 = stack2.getProcessor(Fsliceposition);
			ImageProcessor Fip = stack1.getProcessor(Fsliceposition);
			int sumpx = Fip.getPixelCount();
			for(int ii=0; ii<sumpx; ii++){
				double pix=Fip.get(ii);
				
				double out=Fsetvalue*Math.pow( pix/ Fsetvalue, (double) 1/ (double)  Dgamma);
				
				if(out>Fsetvalue)
				out= (int) Fsetvalue;
				Fip2.set(ii, (int) out);
			}
		}
		//	Fnewimp.show();
	}
	
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
} 



