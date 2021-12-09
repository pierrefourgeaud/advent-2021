import java.io.File
import java.io.FileNotFoundException
import java.nio.charset.Charset

typealias Board = List<List<String>>;

data class ResultBoard(var board: Board, var moves: Int)

fun checkBoardWin(board: Board, numbers: HashMap<String, Int>): Int {
    var moves: Int = -1

    // Check the horizontal first
    board.forEach { line ->
        var max: Int = -1
        line.all { n ->
            val num = numbers.get(n)
            if (num != null) {
                max = maxOf(max, num)
            }
            num != null
        }.let {
            moves = if (moves == -1) max else minOf(max, moves)
        }
    }

    // Then check the vertical
    for (i in board[0].indices) {
        var max: Int = -1
        board.all { line ->
            val num = numbers.get(line[i])
            if (num != null) {
                max = maxOf(max, num)
            }
            num != null
        }.let {
            moves = if (moves == -1) max else minOf(max, moves)
        }
    }

    // Returns the result, -1 means this is a loosing board
    return moves
}

fun getScore(board: ResultBoard, numbers: List<String>): Int {
    // Get all the numbers of the board in one list
    val boardNumbers = board.board.fold(mutableListOf<String>()) { list, line ->
        list.addAll(line)
        list
    }

    // Remove all the played numbers until the winning move included
    for (i in 0..board.moves) {
        boardNumbers.remove(numbers[i])
    }

    // Compute the score
    return boardNumbers.fold(0) { score, n -> score + n.toInt() } * numbers[board.moves].toInt()
}

fun main(args: Array<String>) {
    val filename: String = args[0]
    try {
        val input = File(filename).reader(Charset.forName("ASCII")).readText().split("\n")

        // The first line are the drawnNumbers
        val drawNumbers = input[0].split(",")
        // We move the numbers to a hashMap as:
        // key = number
        // value = when it was called
        // to simplify/speed up the check for when we work on the check
        val numbers: HashMap<String, Int> =
            HashMap(drawNumbers.mapIndexed { index, number -> number to index }.toMap())

        val boards: MutableList<Board> = mutableListOf();
        var currentBoard: MutableList<List<String>> = mutableListOf();
        // Drop the drawNumbers then parse the boards
        input.drop(2).forEach { line ->
            if (line.isEmpty()) {
                boards.add(currentBoard)
                currentBoard = mutableListOf()
            } else {
                currentBoard.add(
                    // We split the board line (some number have two spaces in front so it creates
                    // empty items therefore we filter them out
                    line.split(" ").filter { c -> !c.trim().isEmpty() }
                )
            }
        }
        boards.add(currentBoard)

        // The pair contains the first and the last winning board respectively the boards for the parts 1 and 2.
        val finalBoards =
            boards.fold(Pair(ResultBoard(listOf(), Int.MAX_VALUE), ResultBoard(listOf(), -1))) { result, board ->
                val moves = checkBoardWin(board, numbers)
                if (moves > -1 && moves < result.first.moves) {
                    result.first.board = board
                    result.first.moves = moves
                }
                if (moves > result.second.moves) {
                    result.second.board = board
                    result.second.moves = moves
                }
                result
            }
        println("Part 1: ${getScore(finalBoards.first, drawNumbers)}")
        println("Part 2: ${getScore(finalBoards.second, drawNumbers)}")
    } catch (e: FileNotFoundException) {
        println("File not found!")
    }
}
