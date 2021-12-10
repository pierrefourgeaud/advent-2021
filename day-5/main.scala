import scala.io.Source.stdin

@main def main() =
  val input = stdin.getLines().map{_.split(" -> ").flatMap(_.split(",")).map(_.toInt)}.toList
  part1(input)
  part2(input)

def part1(input: List[Array[Int]]) =
  println {
    "Part 1: " + compute(input.filter{case Array(x1, y1, x2, y2) => x1 == x2 || y1 == y2})
  }

def part2(input: List[Array[Int]]) =
  println {
    "Part 2: " + compute(input)
  }

def compute(input: List[Array[Int]]) =
  input.flatMap{case Array(x1, y1, x2, y2) =>
    var x = x1
    var y = y1
    var res: List[(Int, Int)] = List((x, y))

    while (x != x2 || y != y2) do
      x = advance(x, x2)
      y = advance(y, y2)
      res = (x, y) :: res
    res
  }
  .groupBy(t => t)
  .filter(_._2.size > 1).size

def advance(a: Int, b: Int): Int = if (a > b) a - 1 else if (a < b) a + 1 else a
