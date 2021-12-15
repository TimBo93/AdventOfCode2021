open System.IO
open System

let file = "input.txt"
let input = File.ReadAllLines(file) |> Array.toList
type Position = {x: int; y: int}

let rec alreadyExists (searchItem: Position) (searchList: Position list) =
    match searchList with
    | head :: tail -> 
        if head = searchItem then
            true
        else
            alreadyExists searchItem tail
    | [] -> false

type Board = {Positions: Position list} with 
    static member Empty = {Positions = []}

    static member addPosition (position) board = 
        { Positions = position::board.Positions }

    static member foldAlongX (xFold: int) board = 
        let rightOf position =
            position.x > xFold

        let calculateReflection position = 
            {x = xFold - (position.x - xFold); y = position.y}

        let isPositionValid position = 
            position.x >= 0

        let rec expandItems list =
            match list with
            | [] -> []
            | head::tail -> 
            let asIs = expandItems(tail)
                
            let listWithOriginal = 
                if (not (rightOf head) && not(asIs |> alreadyExists head)) then
                    head::asIs
                else
                    asIs

            let listWithFolded = 
                let reflection = calculateReflection head
                if (rightOf head && reflection |> isPositionValid && not (listWithOriginal |> alreadyExists reflection)) then
                    reflection::listWithOriginal
                else
                    listWithOriginal

            listWithFolded

        { Positions = board.Positions |> expandItems }

    static member foldAlongY (yFold: int) board = 
        let underneath position =
            position.y > yFold

        let calculateReflection position = 
            {x = position.x; y = yFold - (position.y - yFold)}

        let isPositionValid position = 
            position.y >= 0

        let rec expandItems list =
          match list with
          | [] -> []
          | head::tail -> 
            let asIs = expandItems(tail)
            
            let listWithOriginal = 
                if (not (underneath head) && not(asIs |> alreadyExists head)) then
                    head::asIs
                else
                    asIs

            let listWithFolded = 
                let reflection = calculateReflection head
                if (underneath head && reflection |> isPositionValid && not (listWithOriginal |> alreadyExists reflection)) then
                    reflection::listWithOriginal
                else
                    listWithOriginal

            listWithFolded

        { Positions = board.Positions |> expandItems }

let parse isPart1 (lines:string list) =
    let parseSingleLine (line: String) =
        let splitted = line.Split([|","|], StringSplitOptions.RemoveEmptyEntries)
        let x = splitted.[0] |> int
        let y = splitted.[1] |> int
        {x = x; y=y}

    let isPositionLine (line: String) = 
        line.Contains ","

    let isFoldLine (line: String) =
        line.Contains "fold along"

    let foldByLine (line: String) (board: Board) =
        let axisPos = line.Split("=")[1] |> int
        if(line.Contains "x") then
            board |> Board.foldAlongX axisPos
        else
            board |> Board.foldAlongY axisPos

    let rec parsePosition list board =
      match list with
      | [] -> board
      | head::tail -> 
        if (head |> isPositionLine) then
            board |> parsePosition tail |> Board.addPosition (head |> parseSingleLine)
        else
            parsePosition tail board

    let rec parseCommands list board = 
      match list with
      | [] -> board
      | head::tail -> 
        if(head |> isFoldLine) then
            let afterFold = board |> foldByLine head
            if(isPart1) then
                afterFold
            else
                afterFold |> parseCommands tail 
        else
         parseCommands tail board

    parsePosition lines Board.Empty |> parseCommands lines
            
Console.WriteLine($"Num items part 1 = {(input |> parse true).Positions.Length}")

// Part 2
for x in (input |> parse false).Positions do
    Console.SetCursorPosition(x.x, x.y + 5)
    Console.Write("#")

Console.SetCursorPosition(0, 20)
