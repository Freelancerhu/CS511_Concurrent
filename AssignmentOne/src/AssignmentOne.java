/*
 *Shengjie Hu
 *CS 511 homework 1
 *AssignmentOne.java
 */
import java.util.*;

public class AssignmentOne{
	public List<Integer> lprimes (List<Integer[]> intervals) throws InterruptedException {
		List<Integer> result = new ArrayList<Integer>();
		List<PrimeFinder> findPrimes = new ArrayList<PrimeFinder>();
		List<Thread> checkThread = new ArrayList<Thread>();
		for (Integer[] tempIntervals : intervals) {
			findPrimes.add(new PrimeFinder(tempIntervals[0], tempIntervals[1]));
		}
		for (PrimeFinder PF : findPrimes) {
			Thread pf = new Thread(PF);
			pf.start();
			checkThread.add(pf);
		}
		for (Thread cT: checkThread) {
			try {
				cT.join();
			} catch (InterruptedException e) {
				System.out.println(e);
			}
		}
		for (PrimeFinder PF : findPrimes) {
			result.addAll(PF.getPrimesList());
		}
		return result;
	}
	
	public void printResult (List<Integer> re) {
		for (Integer tempInt : re) {
			System.out.print(tempInt);
			System.out.print( " " );
		}
	}
	
	public static void main(String[] args) throws InterruptedException {
		List<Integer[]> intervals = new ArrayList<Integer[]>();
		for (int i = 0; i < args.length - 1; ++i) {
			Integer[] tempInter = new Integer[2];
			tempInter[0] = Integer.parseInt(args[i]);
			tempInter[1] = Integer.parseInt(args[i + 1]);
			intervals.add(tempInter);
		}
		AssignmentOne AO = new AssignmentOne();
		List<Integer> re = AO.lprimes(intervals);
		AO.printResult(re);
	}
}
