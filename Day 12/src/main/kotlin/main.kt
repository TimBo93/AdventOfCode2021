import java.io.File

class Route (
    val from: String,
    val to: String
    ){
    fun reverse(): Route {
        return Route(to, from)
    }
}

class Transitions {
    private var allTransitions = mutableMapOf<String, MutableList<String>>()

    fun addTransition (r: Route) {
        addRoute(r)
        addRoute(r.reverse())
    }

    private fun addRoute(r: Route) {
        if(allTransitions.containsKey(r.from)) {
            allTransitions[r.from]!!.add(r.to)
            return
        }
        allTransitions[r.from] = mutableListOf(r.to)
    }

    fun getTransitionFrom(node: String): List<String> {
        return allTransitions[node]!!.toList()
    }

}

fun initStatePartOne() : State = State("start", listOf("start"), true)
fun initStatePartTwo() : State = State("start", listOf("start"), false)

class State(val agentPosition: String, private val alreadyVisitedNodes: List<String>, private val hasAlreadyVisitedOneCaveTwice: Boolean) {
    fun moveTo(target: String) : State {
        val newList = alreadyVisitedNodes.toMutableList()

        val hasAlreadyVisitedOneCaveTwiceNow = hasAlreadyVisitedOneCaveTwice || hasAlreadyVisited(target)

        if(canVisitOnlyTwice(target)) {
            newList.add(target)
        }
        return State(target, newList, hasAlreadyVisitedOneCaveTwiceNow)
    }

    fun canVisitNode(node: String): Boolean {
        if(node == "start") {
            return false
        }

        if(canVisitOnlyTwice(node) && hasAlreadyVisitedOneCaveTwice && hasAlreadyVisited(node)) {
            return false
        }
        return true
    }

    private fun hasAlreadyVisited(node: String) = alreadyVisitedNodes.contains(node)

    private fun canVisitOnlyTwice(node: String) = node.lowercase() == node
}

var numPathes = 0
class TravelEngine(private val transitions: Transitions) {
    fun travel(initState: State) {
        val route = "start"
        travel(initState, route)
    }

    private fun travel(currentState: State, route: String) {
        if(currentState.agentPosition == "end") {
            numPathes += 1
            println(route)
            return
        }

        getAllPossibleMoves(currentState).forEach {
            val newState = currentState.moveTo(it)
            travel(newState, "$route -> $it")
        }
    }

    private fun getAllPossibleMoves(state: State) = sequence<String> {
        transitions.getTransitionFrom(state.agentPosition).forEach{
            if(state.canVisitNode(it)) {
                yield (it)
            }
        }
    }
}

fun main(args: Array<String>) {
    val transitions = Transitions()

    File("input.txt").forEachLine {
        val parts = it.split("-")
        transitions.addTransition(Route(parts[0], parts[1]))
    }

    val travelEngine = TravelEngine(transitions)
    travelEngine.travel(initStatePartOne())
    println("Number of paths: $numPathes")

    numPathes = 0
    travelEngine.travel(initStatePartTwo())
    println("Number of paths (Part Two): $numPathes")
}
