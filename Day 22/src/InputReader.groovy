class InputReader {
    static List<Command> readCommandsFromFile(String filePath) {
        def file = new File(filePath)
        List<Command> result = new ArrayList<Command>()

        String line
        file.withReader { reader ->
            while ((line = reader.readLine()) != null) {
                def commandType = line.contains("on") ? CommandType.On : CommandType.Off
                def numbers = extractInts(line)
                def command = new Command(numbers[0], numbers[2], numbers[4], numbers[1], numbers[3], numbers[5], commandType)
                result.add(command)
            }
        }

        return Collections.unmodifiableList(result)
    }

    static extractInts( String input ) {
        input.findAll( /-?\d+/ )*.toInteger()
    }
}
