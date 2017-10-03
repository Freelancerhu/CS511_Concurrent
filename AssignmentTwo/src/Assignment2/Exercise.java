package Assignment2;

import java.util.Map;
import java.util.Random;

public class Exercise {

	private ApparatusType at;
	private Map<WeightPlateSize, Integer> weight;
	private int duration;
	private static final Random rd = new Random();
	
	public Exercise(ApparatusType tempAt, Map<WeightPlateSize, Integer> tempWeight,
						int tempDuration) {
		at = tempAt;
		weight = tempWeight;
		duration = tempDuration;
	}
	
	public ApparatusType getType() {
		return at;
	}
	
	public Map<WeightPlateSize, Integer> getWeight () {
		return weight;
	}
	
	public int getDuration() {
		return duration;
	}
	
	public static Exercise generateRandom(Map<WeightPlateSize, Integer> noOfWeightPlates) {
		return new Exercise(ApparatusType.generateApparatusType(), noOfWeightPlates, rd.nextInt(60));
	}
	
}
