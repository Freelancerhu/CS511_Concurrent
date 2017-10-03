package Assignment2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;



public class Client {
	private int id;
	private List<Exercise> routine;
	private static final Random rd = new Random();
	
	
	public Client(int tempId) {
		id = tempId;
		routine = new ArrayList<Exercise>();
	}
	
	
	public void addExercise(Exercise e) {
		routine.add(e);
	}
	
	public List<Exercise> getRoutine () {
		return routine;
	}
	
	
	public static Client generateRandom(int id, Map<WeightPlateSize, Integer> noOfWeightPlates) {
		Client tempClient = new Client(id);
		
		for (int i = 0; i < rd.nextInt(5) + 15; ++i) {
			Map<WeightPlateSize, Integer> tempMap = new HashMap<WeightPlateSize, Integer>();
			tempMap.put(WeightPlateSize.LARGE_10KG, rd.nextInt(10) + 1);
			tempMap.put(WeightPlateSize.MEDIUM_5KG, rd.nextInt(10) + 1);
			tempMap.put(WeightPlateSize.SMALL_3KG, rd.nextInt(10) + 1);
			tempClient.addExercise(Exercise.generateRandom(tempMap));
		}
		
		return tempClient;
	}
}
