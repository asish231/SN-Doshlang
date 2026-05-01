public class BenchArraySum {
    public static void main(String[] args) {
        long sum = 0;
        long i = 0;
        while (i < 10000000) {
            sum = sum + i;
            i = i + 1;
        }
        System.out.println(sum);
    }
}