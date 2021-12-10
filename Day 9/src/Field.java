import java.util.ArrayList;

public class Field {
    private final ArrayList<String> lines = new ArrayList<>();

    public void AddRow(String row) {
        lines.add(row);
    }

    public ArrayList<Integer> smallestSourrounding() {
        var result = new ArrayList<Integer>();
        var width = this.width();
        var height = this.height();


        for(int x = 0; x<width; x++) {
            for(int y = 0; y<height; y++) {
                var currentElement = getHeightAt(x,y);

                var smallerThanTop = true;
                if(y > 0) {
                    var topElement = getHeightAt(x, y-1);
                    smallerThanTop = currentElement < topElement;
                }

                var smallerThanBottom = true;
                if(y < height - 1) {
                    var bottomElement = getHeightAt(x, y+1);
                    smallerThanBottom = currentElement < bottomElement;
                }

                var smallerThanLeft = true;
                if(x > 0) {
                    var leftElement = getHeightAt(x-1, y);
                    smallerThanLeft = currentElement < leftElement;
                }

                var smallerThanRight = true;
                if(x < width - 1) {
                    var rightElement = getHeightAt(x+1, y);
                    smallerThanRight = currentElement < rightElement;
                }

                var smallest = smallerThanTop && smallerThanBottom && smallerThanLeft && smallerThanRight;
                if(smallest) {
                    result.add(currentElement);
                }
            }
        }

        return result;
    }

    public int getHeightAt(int x, int y) {
        return Integer.parseInt(lines.get(y).charAt(x) + "");
    }

    public int width() {
        return lines.get(0).length();
    }

    public int height() {
        return lines.size();
    }
}

