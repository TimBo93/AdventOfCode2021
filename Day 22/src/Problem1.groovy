class Problem1 {
    final List<Command> relevantCommands

    Problem1(List<Command> commands) {
        relevantCommands = Collections.unmodifiableList(commands.findAll(command ->
                command.from.x >= -50 && command.from.y >= -50 && command.from.z >= -50 &&
                command.to.x <= 50 && command.to.y <= 50 && command.to.z <= 50
        ))
    }

    int solve() {
        def buffer = new boolean[101][101][101] // ~ 1MB
        relevantCommands.forEach(c -> {
            for(x in (c.from.x..c.to.x)){
                for(y in (c.from.y..c.to.y)){
                    for(z in (c.from.z..c.to.z)){
                        buffer[x][y][z] = c.commandType == CommandType.On
                    }
                }
            }
        })

        // maybe inplacing the count would make sense
        int count = 0
        for(x in (-50..50)){
            for(y in (-50..50)){
                for(z in (-50..50)){
                    count += buffer[x][y][z] ? 1 : 0
                }
            }
        }
        count
    }
}
