public class Bench {
    public static void main(String[] args) {
        int sum = 0;
        int i = 0;
        while (i < 100000000) {
            sum = sum + 1;
            i++;
        }
        System.out.println(sum);
    }
}
