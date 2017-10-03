package Assignment2;

import java.util.Random;

public enum WeightPlateSize {
	SMALL_3KG, MEDIUM_5KG, LARGE_10KG;
	
	private static final WeightPlateSize[]  WPS = values();
	private final static int size = 3;
	private final static Random rd = new Random();
	
	public static WeightPlateSize generateWeightPlateSize () {
		return WPS[rd.nextInt(size)];
	}
	
}
