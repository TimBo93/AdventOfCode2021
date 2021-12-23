import groovy.time.TimeCategory
import groovy.time.TimeDuration

class Day22 {
    static void main(String[] args) {

        def commands = new InputReader().readCommandsFromFile("input.txt")
        var part1 = new Problem1(commands).solve()
        println "Part 1 $part1"

        def timeStart = new Date()
        var part2 = new Problem2(commands).solve()
        println "Part 2 $part2"
        def timeStop = new Date()
        TimeDuration duration = TimeCategory.minus(timeStop, timeStart)
        println duration
    }
}
