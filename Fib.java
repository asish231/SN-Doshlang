public class Fib { public static void main(String[] args) { int a=0, b=1; for(int i=0;i<40;i++) { int temp=a+b;a=b;b=temp;} System.out.println(a);}}
