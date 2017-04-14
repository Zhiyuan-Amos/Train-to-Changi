import java.util.*;

public class Main {

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        while (sc.hasNext()) {
            int n = sc.nextInt();
            sc.nextLine();
            int[][][] galaxy = new int[n][n][n];

            for (int i=0; i<n; i++) {
                for (int j=0; j<n; j++) {
                    for (int k=0; k<n; k++) {
                            galaxy[i][j][k] = sc.nextInt();
                    }
                }
            }

            System.out.println(kadane3D(galaxy));
        }
    }

    public static int kadane3D(int[][][] cuboid) {
        int highest = 0;
        int n = cuboid.length;

        for (int t = 0; t < n; t++) {
            int[][] temp = new int[n][n];
            for (int b = t; b < n; b++) {

                for (int idx = 0; idx < n; idx++) {
                    for (int jdx = 0; jdx < n; jdx ++) {
                        temp[idx][jdx] += cuboid[idx][jdx][b];
                    }
                }
                int current = kadane2D(temp);
                if (current > highest)
                    highest = current;
            }
        }
        return highest;
    }

    // O(n)
    public static int kadane2D(int[][] mat) {
        int highest = 0;
        int n = mat.length;

        for (int l = 0; l < n; l++) {
            int[] temp = new int[n];
            for (int r = l; r < n; r++) {
                for (int idx = 0; idx < n; idx++) {
                    temp[idx] += mat[idx][r];
                }
                int current = kadane1D(temp);
                if (current > highest)
                    highest = current;
            }
        }
        return highest;
    }

    // O(n)
    public static int kadane1D(int[] arr) {
        int highest = 0;
        int highestHere = 0;

        for (int i = 0; i < arr.length; i++) {
            highestHere = highestHere + arr[i];
            if (highest < highestHere)
                highest = highestHere;
            if (highestHere < 0)
                highestHere = 0;
        }
        return highest;
    }
}
