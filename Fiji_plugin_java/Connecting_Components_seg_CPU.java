import ij.*;
import ij.process.*;
import ij.gui.*;
import ij.measure.*;
import java.awt.*;
import ij.plugin.filter.*;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.commons.io.FileUtils;

import java.io.IOException;
import java.io.File;
import java.nio.ByteOrder;
import java.nio.Buffer;
import java.nio.FloatBuffer;
import org.bridj.Pointer;
import static org.bridj.Pointer.*;

public class Connecting_Components_seg_CPU implements PlugInFilter {
	ImagePlus imp_;
	int th_  = (int)Prefs.get("th.int", 10);
	int volth_ = (int)Prefs.get("volth.int", 50);
	int thread_num_ = (int)Prefs.get("thread_num.int", 8);
	static String result_ = new String();
	
	public int setup(String arg, ImagePlus imp) {
		this.imp_ = imp;
		return DOES_8G + DOES_16 + DOES_32;
	}

	private boolean showDialog() {
		GenericDialog gd = new GenericDialog("Connecting Components GPU");
		gd.addNumericField("Ignore signal value less than",  th_, 0);
		gd.addNumericField("Minimum size",  volth_, 0);
		gd.addNumericField("thread (CPU)",  thread_num_, 0);
		gd.showDialog();
	
		if (gd.wasCanceled()) return false;
		th_ = (int)gd.getNextNumber();
		volth_ = (int)gd.getNextNumber();
		thread_num_ = (int)gd.getNextNumber();
								
		Prefs.set("th.int", th_);
		Prefs.set("volth.int", volth_);
		Prefs.set("thread_num.int", thread_num_);
		
		return true;
	}

	public void run(ImageProcessor ip) {
		if (!showDialog()) return;

		int[] dims = imp_.getDimensions();
		final int imageW = dims[0];
		final int imageH = dims[1];
		final int nCh    = dims[2];
		final int imageD = dims[3];
		final int nFrame = dims[4];
		final int bdepth = imp_.getBitDepth();

		final int w = imageW+2;
		final int h = imageH+2;
		final int d = imageD+2;

		ImagePlus newimp = IJ.createHyperStack(imp_.getTitle()+"_th_"+String.valueOf(th_)+"_minvol_"+String.valueOf(volth_), imageW, imageH, nCh, imageD, nFrame, 16);
		ImageStack istack = imp_.getStack();
		ImageStack ostack = newimp.getStack();

		long imagesize = (long) w * (long) h* (long) d;
		IJ.log("w; "+String.valueOf(w)+"  h; "+h+"  d; "+d+"  imagesize; "+imagesize);
		
		long start, end;
		start = System.nanoTime();
		
        final Pointer<Long> tptr = Pointer.allocateLongs(imagesize);
        
		for(int f = 0; f < nFrame; f++){
			for(int ch = 0; ch < nCh; ch++){
				final Pointer<Long> outPtr = Pointer.allocateLongs(imagesize);
				
				final ImageProcessor[] iplist = new ImageProcessor[imageD];
				final ImageProcessor[] oplist = new ImageProcessor[imageD];
				for(int s = 0; s < imageD; s++){
					iplist[s] =  istack.getProcessor(imp_.getStackIndex(ch+1, s+1, f+1));
					oplist[s] =  ostack.getProcessor(newimp.getStackIndex(ch+1, s+1, f+1));
				}

				final AtomicInteger ai1 = new AtomicInteger(0);
				final Thread[] threads = newThreadArray();
				for (int ithread = 0; ithread < threads.length; ithread++) {
					// Concurrently run in as many threads as CPUs
					threads[ithread] = new Thread() {
				
						{ setPriority(Thread.NORM_PRIORITY); }
				
						public void run() {
							for (int z = ai1.getAndIncrement(); z < imageD; z = ai1.getAndIncrement()) {
								for(int y = 0; y < imageH; y++) {
									for(int x = 0; x < imageW; x++) {
										long val = (long)iplist[z].getf(y*imageW+x);
										val = (val >= th_) ? 1 : 0;
										tptr.set((long)(z+1)*(long)w*(long)h+(long)(y+1)*(long)w+(long)x+(long)1, val);
									}
								}				
							}//	for (int i = ai.getAndIncrement(); i < names.length;
						}
					};//threads[ithread] = new Thread() {
				}//	for (int ithread = 0; ithread < threads.length; ithread++)
				startAndJoin(threads);

				//flood fill
				int segid = 1;
				IJ.showProgress(0.0);
				for(int z = 1; z < d-1; z++) {
					for(int y = 1; y < h-1; y++) {
						for(int x = 1; x < w-1; x++) {
							long id = (long) z * (long) h* (long) w + (long) y * (long) w + (long) x;
							long val = tptr.get(id);
							long segval = outPtr.get(id);
							if (val > 0 && segval == 0) {
								Queue<Long> que = new ArrayDeque<Long>();
								int count = 0;
								long cx, cy, cz;

								long tmp;
	
								outPtr.set((long)z*(long)h*(long)w + (long)y*(long)w + (long)x, (long)segid);

								que.add(((long)x << 16 | (long)y) << 16 | (long)z);

								long minx, miny, minz, maxx, maxy, maxz;
								minx = x; miny = y; minz = z; maxx = x; maxy = y; maxz = z;

								while(que.peek() != null){
									count++;
									tmp = que.poll();
				
									cx = tmp >> 32;
									cy = (tmp >> 16) & (long)0xFFFF;
									cz = tmp & (long)0xFFFF;
									for(int dz = -1; dz <= 1; dz++){
										for(int dy = -1; dy <= 1; dy++){
											for(int dx = -1; dx <= 1; dx++){
												if(tptr.getLongAtIndex((long)(cz + (long) dz)*(long)h*(long)w + (cy + (long) dy)*w + cx + (long) dx) > 0 && outPtr.getLongAtIndex((long)(cz + (long) dz)*(long)h*(long)w + (cy + (long) dy)*(long)w + cx + (long) dx) == 0){
													outPtr.set((long)(cz + (long) dz)*(long)h*(long)w + (long)(cy + (long)dy)*(long)w + cx + (long) dx, (long)segid);
													que.add(((long)(cx + dx) << 16 | (long)(cy + dy)) << 16 | (long)(cz + dz));
													if(cx + dx > maxx)maxx = cx + dx;
													if(cx + dx < minx)minx = cx + dx;
													if(cy + dy > maxy)maxy = cy + dy;
													if(cy + dy < miny)miny = cy + dy;
													if(cz + dz > maxz)maxz = cz + dz;
													if(cz + dz < minz)minz = cz + dz;
												}
											}
										}
									}
								}
								segid++;
							}
						}
					}
					IJ.showProgress((double)(z-1)/(double)(imageD));
				}

				final Map<Long, Long> map = new HashMap<>();
				for(int z = 1; z < d-1; z++) {
					for(int y = 1; y < h-1; y++) {
						for(int x = 1; x < w-1; x++) {
							long id = (long)z*(long)h*(long)w + (long)y*(long)w + (long)x;
							long val = outPtr.get(id);
							if (val != 0) {
								tptr.set(id, outPtr.get(id));
							//	IJ.log("173 working");
								if (map.containsKey(val)) {
										long num = map.get(val);
										map.put(val, num+1);
								} else
										map.put(val, (long)1);
							}
						}
					}
				}
				
				String valueST="";
				long newsegid = 1;
				ResultsTable rt = new ResultsTable();
				for(Map.Entry<Long, Long> entry : map.entrySet()) {
					if (entry.getValue() > volth_) {
						rt.incrementCounter();
						rt.addLabel(""+newsegid);
						rt.addValue("VoxelNum", entry.getValue());
						valueST=valueST+"_"+entry.getValue();
						entry.setValue(newsegid++);
					} else
						entry.setValue((long)-1);
				}
				rt.show("Results");
				result_ = valueST;
				
				final int vt = volth_;
				final AtomicInteger ai2 = new AtomicInteger(0);
				for (int ithread = 0; ithread < threads.length; ithread++) {
					// Concurrently run in as many threads as CPUs
					threads[ithread] = new Thread() {
				
						{ setPriority(Thread.NORM_PRIORITY); }
				
						public void run() {
							for (int z = ai2.getAndIncrement(); z < imageD; z = ai2.getAndIncrement()) {
								for(int y = 0; y < imageH; y++) {
									for(int x = 0; x < imageW; x++) {
										long val = tptr.getLongAtIndex((long)((long)z+(long)1)*(long)w*(long)h+(long)((long)y+(long)1)*(long)w+(long)((long)x+(long)1));
										if (map.containsKey(val)) {
								//			IJ.log("211 working");
											long num = map.get(val);
											oplist[z].setf(y * imageW + x, (num == -1) ? 0.0f : (float)num);
											if((y * imageW + x)<0){
												IJ.log("overflow 212");
											}
										}
									}
								}
							}//	for (int z = ai2.getAndIncrement(); z < imageD; z = ai2.getAndIncrement())
						}
					};//threads[ithread] = new Thread() {
				}//	for (int ithread = 0; ithread < threads.length; ithread++) {
				startAndJoin(threads);
			}
		}

		end = System.nanoTime();
		IJ.log("time: "+((float)(end-start)/1000000.0)+"msec");
		
		newimp.show();

	} //public void run(ImageProcessor ip) {
	
	/** Create a Thread[] array as large as the number of processors available.
		* From Stephan Preibisch's Multithreading.java class. See:
		* http://repo.or.cz/w/trakem2.git?a=blob;f=mpi/fruitfly/general/MultiThreading.java;hb=HEAD
		*/
	private Thread[] newThreadArray() {
		int n_cpus = Runtime.getRuntime().availableProcessors();
		if (n_cpus > thread_num_) n_cpus = thread_num_;
		if (n_cpus <= 0) n_cpus = 1;
		return new Thread[n_cpus];
	}
	
	/** Start all given threads and wait on each of them until all are done.
		* From Stephan Preibisch's Multithreading.java class. See:
		* http://repo.or.cz/w/trakem2.git?a=blob;f=mpi/fruitfly/general/MultiThreading.java;hb=HEAD
		*/
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
	public static String getResult() { 
		return result_; 
	}
}
