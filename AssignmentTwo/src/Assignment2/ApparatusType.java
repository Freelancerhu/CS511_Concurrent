package Assignment2;

import java.util.Random;

public enum ApparatusType {
	LEGPRESSMACHINE, BARBELL, HACKSQUATMACHINE, LEGEXTENSIONMACHINE, LEGCURLMACHINE, 
	LATPULLDOWNMACHINE, PECDECKMACHINE, CABLECROSSOVERMACHINE;
	
	private final static ApparatusType[] app = values();
	private final static int size = 8;
	private final static Random Rd = new Random();
	
	public static ApparatusType generateApparatusType() {
		return app[Rd.nextInt(size)];
	}
	
	
	
}