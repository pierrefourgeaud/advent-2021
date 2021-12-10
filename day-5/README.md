# Day 5

This day was made with `Scala 3`. I didn't use sbt for it, and simply installed the runner for Scala 3 using `cs`:

```bash
cs install scala3
```

## Run

```bash
scala3 main.scala < input.txt
```

## Notes

I started using `foldLeft` and a `Map` for the `compute` function. It works but it started to make the code a bit more convoluted and the copy of the HashMap was optimal. I decided to move away from it and to use the concept of list of point that I can later on count. The second solution is must cleaner, smaller and easier to understand
Bellow is the initial code so it is not lost:

```scala
def compute(input: List[Array[Int]]) =
  input.foldLeft(Map[(Int, Int), Int]()) {case (acc, coords) => {
    var ret = acc
    coords match {
      case Array(x1, y1, x2, y2) =>
        var x = x1
        var y = y1

        ret = ret.updatedWith((x, y)) {
            case Some(n) => Some(n + 1)
            case None => Some(1)
          }
        while (x != x2 || y != y2) do
          x = advance(x, x2)
          y = advance(y, y2)
          ret = ret.updatedWith((x, y)) {
            case Some(n) => Some(n + 1)
            case None => Some(1)
          }
    }
    ret
  }}.filter((k, v) => v > 1).size
```
