public class Bench {
    public static void main(String[] args) {
        int sum = 0;
        int i = 0;
        while (i < 100000000) {
            sum = sum + 1;
            i = i + 1;
        }
        System.out.println(sum);
    }
}