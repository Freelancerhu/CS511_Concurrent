/*
 *Shengjie Hu
 *CS 511 homework 1
 *PrimeFinder.java
 */
import java.util.*;
public class PrimeFinder implements Runnable{
	private Integer start;
	private Integer end;
	private List<Integer> primes = new ArrayList<Integer>();;
	PrimeFinder(Integer startNum, Integer endNum) {
		start = startNum;
		end = endNum;
	}
	
	public List<Integer> getPrimesList() {
		return primes;
	}
	
	public Boolean isPrime(int n) {
		if (n < 2) return false;
		int counter = 0;
		for (int i = 2; i <= n; i++) {
			if (n % i == 0) counter++;
		}
		if (counter == 1) return true;
		return false;
	}
	
	public void run() {
		for (Integer i = start; i < end; ++i) {
			if (this.isPrime(i)) {
				primes.add(i);
				System.out.println(i);
			}
		}
	}
}
