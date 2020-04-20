import java.util.HashMap;
import java.util.Map;

/**
 * https://leetcode-cn.com/problems/two-sum/
 */
public class _1两数之和 {
    public static int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> map = new HashMap<>((int) ((float) nums.length / 0.75F + 1.0F));
        for (int i = 0; i < nums.length; i++) {
            int i1 = target - nums[i];
            boolean b = map.containsKey(i1);
            if (b) {
                return new int[]{map.get(target - nums[i]), i};
            }
            map.put(nums[i], i);
        }
        throw new IllegalArgumentException("No two sum value");
    }

    public static void main(String[] args) {
        int[] array={2,7,11,15};
        int target =26;
        int[] ints = twoSum(array, target);
        System.out.println(ints);


    }



}
