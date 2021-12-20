import scala.io.Source
import scala.math.{ceil, floor}

trait SnailFishNumber {
  var parent: NumberPair
}

class Literal(var value: Int) extends SnailFishNumber() {
  override var parent: NumberPair = _
}
class NumberPair(var left: SnailFishNumber, var right: SnailFishNumber) extends SnailFishNumber() {
  override var parent: NumberPair = _

  left.parent = this
  right.parent = this

  private def creator (): Unit = {

  }

  private def isNumber(node: SnailFishNumber): Boolean = {
    node match {
      case _: Literal => true
      case _ => false
    }
  }

  def consistOfTwoRegularNumbers: Boolean = {
    isNumber(left) && isNumber(right)
  }
}

object HelloWorld {
  private var currentStringPosition: Int = 0
  private var lineToParse: String = ""

  def parseNumberOrPair(): SnailFishNumber = {
    val currentChar = lineToParse.charAt(currentStringPosition)
    if(currentChar == '[') {
      parsePair()
    } else {
      new Literal(currentChar.asDigit)
    }
  }

  def parsePair(): SnailFishNumber = {
    currentStringPosition += 1
    val left = parseNumberOrPair()
    currentStringPosition += 2
    val right = parseNumberOrPair()
    currentStringPosition += 1
    val pair = new NumberPair(left, right)
    pair
  }

  def join(left: SnailFishNumber, right: SnailFishNumber): SnailFishNumber = {
    val newRootNode = new NumberPair(left, right)
    left.parent = newRootNode
    right.parent = newRootNode
    newRootNode
  }

  def findNodeToExplode(node: SnailFishNumber, depth: Integer): NumberPair = {
    node match {
      case _: Literal => null
      case innerNode: NumberPair if !innerNode.consistOfTwoRegularNumbers =>
        val left = findNodeToExplode(innerNode.left, depth+1)
        if(left != null) {
          return left
        }
        val right = findNodeToExplode(innerNode.right, depth+1)
        right
      case terminalNode: NumberPair if terminalNode.consistOfTwoRegularNumbers =>
        if(depth < 4) {
          return null
        }
        terminalNode
    }
  }

  def findNextNode(node: NumberPair): SnailFishNumber = {
    var currentNode = node
    if(currentNode.parent == null) {
      return null
    }
    var parentNode: NumberPair = node.parent

    while (parentNode match {
      case innerNode: NumberPair if innerNode.right != currentNode => false
      case _ => true
    }) {
      if(parentNode.parent == null) {
        return null
      }

      currentNode = currentNode.parent
      parentNode = parentNode.parent
    }

    var childNode = parentNode.right
    while(true) {
      childNode match {
        case innerNode: NumberPair if innerNode.consistOfTwoRegularNumbers =>
          return innerNode.left
        case numberPair: NumberPair =>
          childNode = numberPair.left;
        case terminalNode: Literal =>
          return terminalNode
      }
    }

    null
  }

  def findPrevNode(node: SnailFishNumber): SnailFishNumber = {
    var currentNode = node
    if(currentNode.parent == null) {
      return null
    }
    var parentNode: NumberPair = node.parent

    while (parentNode match {
      case innerNode: NumberPair if innerNode.left != currentNode => false
      case _ => true
    }) {
      if(parentNode.parent == null) {
        return null
      }

      currentNode = currentNode.parent
      parentNode = parentNode.parent
    }

    var childNode = parentNode.left
    while(true) {
      childNode match {
        case innerNode: NumberPair if innerNode.consistOfTwoRegularNumbers =>
          return innerNode.right
        case numberPair: NumberPair =>
          childNode = numberPair.right;
        case terminalNode: Literal =>
          return terminalNode
      }
    }

    null
  }

  def replaceNode(nodeToReplace: SnailFishNumber, nodeToBeSet: SnailFishNumber): Unit = {
    val parent = nodeToReplace.parent

    nodeToBeSet.parent = parent

    if(parent.left == nodeToReplace) {
      parent.left = nodeToBeSet
    } else {
      parent.right = nodeToBeSet
    }
  }

  def explode(nodeToExplode: NumberPair): Unit = {
    val nextNeighbor = findNextNode(nodeToExplode)
    if(nextNeighbor != null) {
      val nextLiteral = nextNeighbor.asInstanceOf[Literal]
      nextLiteral.value += nodeToExplode.right.asInstanceOf[Literal].value
    }

    val prevNeighbor = findPrevNode(nodeToExplode)
    if(prevNeighbor != null) {
      val prevLiteral = prevNeighbor.asInstanceOf[Literal]
      prevLiteral.value += nodeToExplode.left.asInstanceOf[Literal].value
    }

    replaceNode(nodeToExplode, new Literal(0))
  }

  def split(nodeToSplit: Literal): Unit = {
    val leftValue = floor(nodeToSplit.value / 2.0d).toInt
    val rightValue = ceil(nodeToSplit.value / 2.0d).toInt
    val newNode = new NumberPair(new Literal(leftValue), new Literal(rightValue))
    replaceNode(nodeToSplit, newNode)
  }

  def findNodeToSplit(node: SnailFishNumber): Literal = {
    node match {
      case literal: Literal if literal.value >= 10 =>
        literal
      case _: Literal =>
        null
      case innerNode: NumberPair =>
        val left = findNodeToSplit(innerNode.left)
        if (left != null) {
          return left
        }
        val right = findNodeToSplit(innerNode.right)
        if(right != null) {
          return right
        }
        null
    }
  }

  def renderNode(nodeToRender: SnailFishNumber): String = {
    nodeToRender match {
      case pair: NumberPair =>
        "[" + renderNode(pair.left) + "," + renderNode(pair.right) + "]"
      case literal: Literal =>
        literal.value.toString
    }
  }

  def reduce(rootNode: SnailFishNumber): Unit = {
    var exit = false
    do {
      val nodeToExplode = findNodeToExplode(rootNode, 0)
      if(nodeToExplode != null) {
        explode(nodeToExplode)
      } else {
        val nodeToSplit = findNodeToSplit(rootNode)
        if(nodeToSplit != null) {
          split(nodeToSplit)
        } else {
          exit = true
        }
      }
    } while (!exit)
  }

  def getMagnitude(rootNode: SnailFishNumber): Integer = {
    rootNode match {
      case numberPair: NumberPair => 3 * getMagnitude(numberPair.left) + 2 * getMagnitude(numberPair.right)
      case literal: Literal => literal.value
    }
  }

  def parseLine(line: String): SnailFishNumber = {
    currentStringPosition = 0
    lineToParse = line
    parsePair()
  }

  def main(args: Array[String]): Unit = {
    val filename = "input.txt"
    var accumulated: SnailFishNumber = null

    val source1 = Source.fromFile(filename);
    try{
      source1.getLines().foreach { line =>
        val parsed = parseLine(line)

        if(accumulated == null) {
          accumulated = parsed
        } else{
          accumulated = join(accumulated, parsed)
        }

        reduce(accumulated)
      }
    } finally {
      source1.close()
    }

    println("Part 1")
    println(renderNode(accumulated))
    println(getMagnitude(accumulated))


    val map = collection.mutable.Set[String]()
    val source2 = Source.fromFile(filename)
    try{
      source2.getLines().foreach { line =>
        map += line
      }
    } finally {
      source2.close()
    }

    var highestMagnitude = 0
    map foreach {
      case line1 =>
        map foreach {
         case line2 =>
           if(line1 != line2) {
             val parsed1 = parseLine(line1)
             val parsed2 = parseLine(line2)
             val joined = join(parsed1, parsed2)
             reduce(joined)
             val magnitude = getMagnitude(joined)
             highestMagnitude = scala.math.max(highestMagnitude, magnitude)
           }
        }
    }

    println("Part 2")
    println(highestMagnitude)
  }
}