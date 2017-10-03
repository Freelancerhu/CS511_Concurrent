package Assignment2;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Semaphore;

public class Gym implements Runnable {

		private static final int GYM_SIZE = 30;
		private static final int GYM_REGISTERED_CLINETS = 10000;
		private Map<WeightPlateSize, Integer> noOfWeightPlates;
		private Set<Integer> clients;
		private ExecutorService executor;
		private Random rd = new Random();
		
		private static Map<WeightPlateSize, Semaphore> WeightPlateSemaphore;
		private static Map<ApparatusType, Semaphore> ApparatusTypeSemaphore;
		
		public Gym () {
			noOfWeightPlates = new HashMap<WeightPlateSize, Integer>();
			clients = new HashSet<Integer>();
			executor = Executors.newFixedThreadPool(GYM_SIZE);
			
			int GYM_NUM = rd.nextInt(GYM_REGISTERED_CLINETS);
			System.out.println("GYM_NUM = " + GYM_NUM);
			for (int i = 0; i < GYM_NUM; ++i) {
				clients.add(rd.nextInt(GYM_REGISTERED_CLINETS) + 1);
			}
			
			WeightPlateSemaphore = new HashMap<WeightPlateSize, Semaphore>();
			ApparatusTypeSemaphore = new HashMap<ApparatusType, Semaphore>();
			
			noOfWeightPlates.put(WeightPlateSize.SMALL_3KG, 110);
			noOfWeightPlates.put(WeightPlateSize.MEDIUM_5KG, 90);
			noOfWeightPlates.put(WeightPlateSize.LARGE_10KG, 75);

			ApparatusTypeSemaphore.put(ApparatusType.BARBELL, new Semaphore(5));
			ApparatusTypeSemaphore.put(ApparatusType.CABLECROSSOVERMACHINE, new Semaphore(5));
			ApparatusTypeSemaphore.put(ApparatusType.HACKSQUATMACHINE, new Semaphore(5));
			ApparatusTypeSemaphore.put(ApparatusType.LATPULLDOWNMACHINE, new Semaphore(5));
			ApparatusTypeSemaphore.put(ApparatusType.LEGCURLMACHINE, new Semaphore(5));
			ApparatusTypeSemaphore.put(ApparatusType.LEGEXTENSIONMACHINE, new Semaphore(5));
			ApparatusTypeSemaphore.put(ApparatusType.LEGPRESSMACHINE, new Semaphore(5));
			ApparatusTypeSemaphore.put(ApparatusType.PECDECKMACHINE, new Semaphore(5));
			
			WeightPlateSemaphore.put(WeightPlateSize.SMALL_3KG, new Semaphore(110));
			WeightPlateSemaphore.put(WeightPlateSize.MEDIUM_5KG, new Semaphore(90));
			WeightPlateSemaphore.put(WeightPlateSize.LARGE_10KG, new Semaphore(75));
			
			
			
		}
		
		public void run() {
			final Semaphore operating = new Semaphore(1);
			for (Integer singleClient : clients) {
				executor.execute(new Runnable() {
					public void run() {
						for (Exercise Ex : Client.generateRandom(singleClient, noOfWeightPlates).getRoutine()) {
							try {
								operating.acquire();
							} catch (InterruptedException e) {
								e.printStackTrace();
							}
							
							System.out.println("Client : " + singleClient + " is operating.");
							
							try {
								ApparatusTypeSemaphore.get(Ex.getType()).acquire();
							} catch (InterruptedException e) {
								e.printStackTrace();
							}
							
							for (int i = 0; i < Ex.getWeight().get(WeightPlateSize.SMALL_3KG); ++i) {
								try {
									WeightPlateSemaphore.get(WeightPlateSize.SMALL_3KG).acquire();
								} catch (InterruptedException e) {
									e.printStackTrace();
								}
							}
							for (int i = 0; i < Ex.getWeight().get(WeightPlateSize.MEDIUM_5KG); ++i) {
								try {
									WeightPlateSemaphore.get(WeightPlateSize.MEDIUM_5KG).acquire();
								} catch (InterruptedException e) {
									e.printStackTrace();
								}
							}
							for (int i = 0; i < Ex.getWeight().get(WeightPlateSize.LARGE_10KG); ++i) {
								try {
									WeightPlateSemaphore.get(WeightPlateSize.LARGE_10KG).acquire();
								} catch (InterruptedException e) {
									e.printStackTrace();
								}
							}
							
							System.out.println("Client " + singleClient + " operate " + Ex.getType());
							System.out.println("SMALL: " + Ex.getWeight().get(WeightPlateSize.SMALL_3KG));
							System.out.println("MEDIUM: " + Ex.getWeight().get(WeightPlateSize.MEDIUM_5KG));
							System.out.println("LARGE: " + Ex.getWeight().get(WeightPlateSize.LARGE_10KG));
							
							operating.release();
							System.out.println("Client " + singleClient + " is exercise for " + Ex.getDuration());
							try {
								Thread.sleep(Ex.getDuration());
							} catch (InterruptedException e) {
								e.printStackTrace();
							}
							
							for (int i = 0; i < Ex.getWeight().get(WeightPlateSize.SMALL_3KG); ++i) {
								WeightPlateSemaphore.get(WeightPlateSize.SMALL_3KG).release();
							}
							for (int i = 0; i < Ex.getWeight().get(WeightPlateSize.MEDIUM_5KG); ++i) {
								WeightPlateSemaphore.get(WeightPlateSize.MEDIUM_5KG).release();
							}
							for (int i = 0; i < Ex.getWeight().get(WeightPlateSize.LARGE_10KG); ++i) {
								WeightPlateSemaphore.get(WeightPlateSize.LARGE_10KG).release();
							}
							System.out.println("Client " + singleClient + " leaves " + Ex.getType());
							System.out.println("SMALL: " + Ex.getWeight().get(WeightPlateSize.SMALL_3KG));
							System.out.println("MEDIUM: " + Ex.getWeight().get(WeightPlateSize.MEDIUM_5KG));
							System.out.println("LARGE: " + Ex.getWeight().get(WeightPlateSize.LARGE_10KG));
							
							ApparatusTypeSemaphore.get(Ex.getType()).release();
						
						}
						
					}
				
				
			});
			
			
			}
			
		executor.shutdown();

			
		}
}
