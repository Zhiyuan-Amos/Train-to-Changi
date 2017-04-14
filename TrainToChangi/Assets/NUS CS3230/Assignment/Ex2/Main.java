import java.util.*;

public class Main {

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        String line = sc.nextLine();

        line = line.replace("I", "");

        int numS = 0;
        int numE = 0;
        int numL = 0;

        for (int i = 0; i < line.length(); i++) {
            switch (line.charAt(i)) {
                case 'S':
                    numS++;
                    break;
                case 'E':
                    numE++;
                    break;
                case 'L':
                    numL++;
                    break;
            }
        }

        int total = 0;
        if (numS > 0) total += findRingCount("S", numS - 1, numE, numL, line.length());
        if (numE > 0) total += findRingCount("E", numS, numE - 1, numL, line.length());
        if (numL > 0) total += findRingCount("L", numS, numE, numL - 1, line.length());
        System.out.println(total);
    }

    public static int findRingCount(String currentRing, int numS, int numE, int numL, int size) {
        if (currentRing.length() == size) {
            return isValidRing(currentRing) ? 1 : 0;
        }
        int total = 0;

        switch (currentRing.charAt(currentRing.length() - 1)) {
            case 'S':
                if (numE > 0) {
                    total += findRingCount(currentRing + "E", numS, numE - 1, numL, size);
                }
                if (numL > 0) {
                    total += findRingCount(currentRing + "L", numS, numE, numL - 1, size);
                }
                break;
            case 'E':
                if (numS > 0) {
                    total += findRingCount(currentRing + "S", numS - 1, numE, numL, size);
                }
                if (numL > 0) {
                    total += findRingCount(currentRing + "L", numS, numE, numL - 1, size);
                }
                break;
            case 'L':
                if (numE > 0) {
                    total += findRingCount(currentRing + "E", numS, numE - 1, numL, size);
                }
                if (numS > 0) {
                    total += findRingCount(currentRing + "S", numS - 1, numE, numL, size);
                }
                break;
        }
        return total;
    }

    public static boolean isValidRing(String currentRing) {
        if (currentRing.charAt(0) == currentRing.charAt(currentRing.length() - 1)) {
            return false;
        }
        // System.out.println(currentRing);
        return true;
    }
}
