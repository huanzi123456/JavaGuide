import java.math.BigInteger;

/**
 * 关于斐波那契数列的思考
 *
 *       0  1  1  2  3  5  8  13 ...
 * 相加次数    1  2  3
 * n           2  3  4
 *  第一个数与第二个数的和是第三数
 *  f(n) = f(n-1) + f(n-2)
 */
public class FibonacciArray {

    public static void main(String[] args) {
        System.out.println(fib2(50));
    }


    /** 递归方法 得到 多次调用方法
     * @param n
     * @return
     */
    public static int fib1(int n){
        if (n<=1){return n;}
        return fib1(n-1) + fib1(n-2);
    }

    /** 递归方法 得到 多次调用方法
     * @param n
     * @return
     */
    public static int fib3(int n){
        if (n<=1){return n;}
        int first = 0;
        int secend = 1;
        for (int i = 0; i < n - 1; i++) {
            int sum = first + secend;
            first=secend;
            secend = sum;
        }
        return secend;
    }

    /** 递归方法 得到 多次调用方法
     * @param n
     * @return
     */
    public static BigInteger fib2(int n){
        if (n<=1){return BigInteger.valueOf(n);}
        BigInteger first = BigInteger.valueOf(0);
        BigInteger secend = BigInteger.valueOf(1);
        for (int i = 0; i < n - 1; i++) {
            BigInteger sum = first.add(secend);
            first=secend;
            secend = sum;
        }
        return secend;
    }


}
