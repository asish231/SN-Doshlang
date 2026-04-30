public class BenchFib{public static void main(String[] a){int x=0,y=1;for(int i=0;i<40;i++){int t=x+y;x=y;y=t;}System.out.println(x);}}
