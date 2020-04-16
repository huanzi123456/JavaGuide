import Util.TimeTool;

/**
 * 计算 1 2 3 4 5 ... n的和
 *
 * 评估算法优劣
 *      正确性，可读性，健壮性
 *      时间复杂度：估算程序指令的执行次数  O()
 *      空间复杂度：估算所占用的储存空间
 *      @see FibonacciArray#fib1(int)
 *      时间复杂度 为 1+2+4+8 ...—>2^0+2^1+2^2+2^3 ->(2^n-1)-1 2^n
 *      @see FibonacciArray#fib3(int)
 *      时间复杂度 为 O(n)
 *      @see Sum1_n#test(int, int) 多个数据规模
 *          时间复杂度为 O(n+k)
 */
public class Sum1_n {
    public static void main(String[] args) {
        //
        TimeTool.check("sum", new TimeTool.Task() {
            @Override
            public void excute() {
                sum(100000);
            }
        });

        TimeTool.check("sum", new TimeTool.Task() {
            @Override
            public void excute() {
                sum1(100000);
            }
        });
    }

    public static int sum(int n){
        int result =0;
        for (int i = 1; i <= n; i++) {
            result +=i;
        }
        return result;
    }

    public static int sum1(int n){
        return (1+n)*n/2;
    }

    public static void test(int n,int k){
        for (int i = 0; i < n; i++) {
            System.out.println("11");
        }
        for (int i = 0; i < k; i++) {
            System.out.println("222");
        }
    }
}
