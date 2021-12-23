enum CommandType {
    On,
    Off
}

class Command {
    public final Vector3 from
    public final Vector3 to

    public final CommandType commandType

    public Command(int fromX, int fromY, int fromZ, int toX, int toY, int toZ, CommandType commandType) {
        this.commandType = commandType
        this.from = new Vector3(fromX, fromY, fromZ)
        this.to = new Vector3(toX, toY, toZ)
    }
}
