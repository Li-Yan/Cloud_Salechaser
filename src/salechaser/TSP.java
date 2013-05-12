package salechaser;

import java.util.ArrayList;
import java.util.HashSet;

public class TSP {
	private long[][] matrix;
	
	public TSP(long[][] M) {
		matrix = M.clone();
	}
	
	public ArrayList<Integer> DynamicProgramming() {
		ArrayList<Integer> routeList = new ArrayList<Integer>();
		HashSet<Integer> nodeSet = new HashSet<Integer>();
		for (int i = 1; i < matrix.length; i++) {
			nodeSet.add(i);
		}
		DynamicProgramming_sub(0, nodeSet, routeList);
		return routeList;
	}
	
	@SuppressWarnings("unchecked")
	private long DynamicProgramming_sub(int start, HashSet<Integer> nodeSet, ArrayList<Integer> routeList) {
		if (nodeSet.isEmpty()) {
			routeList.clear();
			routeList.add(0, start);
			return matrix[start][0];
		}
		
		long min = Long.MAX_VALUE;
		for (Integer node : nodeSet) {
			HashSet<Integer> sub_nodeSet = (HashSet<Integer>) nodeSet.clone();
			sub_nodeSet.remove(node);
			ArrayList<Integer> sub_routeList = new ArrayList<Integer>();
			long weight = DynamicProgramming_sub(node, sub_nodeSet, sub_routeList);
			if (min > matrix[start][node] + weight) {
				routeList.clear();
				for (int i = 0; i < sub_routeList.size(); i++) {
					routeList.add(sub_routeList.get(i));
				}
				min = matrix[start][node] + weight;
			}
		}
		routeList.add(0, start);
		return min;
	}
}
