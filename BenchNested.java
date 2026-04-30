public class BenchNested{public static void main(String[] a){int s=0;for(int i=0;i<1000;i++)for(int j=0;j<1000;j++)for(int k=0;k<100;k++)s+=1;System.out.println(s);}}
