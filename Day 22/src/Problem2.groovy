class Problem2 {
    private final List<Command> commands


    Problem2(List<Command> commands) {
        this.commands = commands
    }

    BigInteger solve() {
        ArrayList<Cube> cubes = new ArrayList<Cube>()

        this.commands.forEach {
            c -> {
                def cubeFromCommand = cubeFromCommand(c)
                if(c.commandType == CommandType.Off) {
                    cubeFromCommand = cubeFromCommand.signInverse()
                }
                final intersections = getAllIntersections(cubes, cubeFromCommand.signInverse())
                cubes.addAll(intersections)
                if(c.commandType == CommandType.On) {
                    cubes.add(cubeFromCommand)
                }
            }
        }

        BigInteger sum = 0
        cubes.each{
            cube -> sum += cube.enabledLits
        }
        sum
    }

    static List<Cube> getAllIntersections(ArrayList<Cube> cubes, Cube cubeToReduce) {
        List<Cube> intersections = new ArrayList<>()

        cubes.forEach {
            cube -> {
                if (cube.intersectsWith(cubeToReduce)){
                    def intersected = cube.getProduct(cubeToReduce)
                    intersections.add(intersected)
                }
            }
        }

        intersections
    }

    static Cube cubeFromCommand(Command command) {
        int sign = command.commandType == CommandType.On ? 1 : -1
        return new Cube(command.from, command.to, sign)
    }
}
