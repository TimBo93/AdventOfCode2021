import java.io.*;
import java.util.ArrayList;
import java.util.Comparator;

public class main {
    public static void main(String [] args) {
        var field = new Field();

        var file = new File("input.txt");
        if(file.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = br.readLine()) != null) {
                    field.AddRow(line);
                }
            } catch (FileNotFoundException e) {
                // .. ToDo
            } catch (IOException e) {
                // .. ToDo
            }
        }

        var smallestElements = field.smallestSourrounding();
        var part1 = smallestElements.stream().mapToInt(x -> x + 1).sum();

        var basianMap = new BasianMap(field);
        var basianSizes = new ArrayList<Integer>();
        for (var i=1; i<basianMap.numBiases; i++) {
            basianSizes.add(basianMap.getBasianSize(i));
        }
        var part2 = basianSizes.stream().sorted(Comparator.reverseOrder()).limit(3l).reduce(1, (a, b) -> a * b);
    }
}
