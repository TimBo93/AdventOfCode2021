class BasianMap {
    private int[][] basianMap;
    private Field field;
    public int numBiases = 0;

    public BasianMap(Field field) {
        this.field = field;
        basianMap = new int[field.width()][field.height()];
        numBiases = calcualteField();
    }


    private int calcualteField() {
        var currentBasian = 1;
        var fieldWidth = field.width();
        var fieldHeight = field.height();

        for (int x = 0; x < fieldWidth; x++) {
            for (int y = 0; y < fieldHeight; y++) {
                var height = field.getHeightAt(x, y);
                if (height == 9) {
                    continue;
                }

                var basisAtPosition = getBasianAt(x, y);
                if (basisAtPosition > 0) {
                    continue;
                }

                expandBasian(currentBasian, x, y);
                currentBasian += 1;
            }
        }

        return currentBasian - 1;
    }

    private void expandBasian(int currentBasian, int x, int y) {
        if (x < 0 || x >= field.width() || y < 0 || y >= field.height() || isBasianAssigned(x, y) || field.getHeightAt(x, y) == 9) {
            return;
        }

        basianMap[x][y] = currentBasian;
        expandBasian(currentBasian, x + 1, y);
        expandBasian(currentBasian, x - 1, y);
        expandBasian(currentBasian, x, y + 1);
        expandBasian(currentBasian, x, y - 1);
    }

    private boolean isBasianAssigned(int x, int y) {
        return getBasianAt(x, y) > 0;
    }

    public int getBasianAt(int x, int y) {
        return basianMap[x][y];
    }

    public int getBasianSize(int basianNumber) {
        var sum = 0;
        for (int x = 0; x < field.width(); x++) {
            for (int y = 0; y < field.height(); y++) {
                if (basianMap[x][y] == basianNumber) {
                    sum += 1;
                }
            }
        }
        return sum;
    }
}
