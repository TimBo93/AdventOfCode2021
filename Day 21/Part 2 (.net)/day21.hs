-- ghc -o day21 day21.hs && ./day21

type Position = Integer
type OverallScore = Integer
type Player = (Position, OverallScore)
type Board = (Player, Player)
type NumDices = Integer
type GameState = (Board, NumDices)

player1 = False
player2 = True

initialGameState :: GameState
initialGameState = (b, ns)
  where b = (p1, p2)
        p1 = (7, 0)
        p2 = (9, 0)
        ns = 0

-- calculates one move
move :: GameState -> GameState
move (b, n)
  | toMove == player1 = ((p1next, p2    ), n+3) -- player 1
  | otherwise         = ((p1    , p2next), n+3) -- player 2
  where
    toMove = atMove (n `div` 3)

    p1next = (newField pos1, score1+(newField pos1))
    p2next = (newField pos2, score2+(newField pos2))

    newField pos = (((pos + diceCount)-1) `mod` 10) + 1

    (pos1, score1) = p1
    (pos2, score2) = p2
    (p1, p2) = b

    diceCount = rollDice(n)

-- decides wheter to play another move or to be finished
diracDice :: GameState -> GameState
diracDice gs
  | isOver gs = gs
  | otherwise = diracDice ( nextMove )
    where nextMove = move (gs)

atMove :: Integer -> Bool
atMove move
  | (move `mod` 2) == 0 = player1
  | otherwise           = player2

isOver :: GameState -> Bool
isOver g
  | wins p1 = True
  | wins p2 = True
  | otherwise = False
  where
    wins (_, score) = score >= 1000
    (p1, p2) = b
    (b, _) = g

rollDice :: NumDices -> Integer
rollDice x = clampDice(x+1) + clampDice(x+2) + clampDice(x+3)
  where
    clampDice x = ((x-1) `mod` 100 + 1)

part1 g = loserPoints * n
  where
    loserPoints = minimum(score1, score2)
    (_, score1) = p1
    (_, score2) = p2
    (p1, p2) = b
    (b, n) = g

-- main = putStrLn  (show ( part1 ( diracDice initialGameState )))

-------------------------------
----------- PART 2 ------------
-------------------------------

type Player1Wins = Integer
type Player2Wins = Integer
type Universe = (GameState, Player1Wins, Player2Wins)
type Dice = Integer

initialUniverse :: Universe
initialUniverse = (initialGameState, 0, 0)

assumeDice :: Universe -> Dice -> Universe
assumeDice un diceCount
  | moveFinished && toMove == player1 = ((( p1next              , p2                 ), n+1), pw1, pw2)
  | moveFinished && toMove == player2 = ((( p1                  , p2next             ), n+1), pw1, pw2)
  | toMove == player1                 = ((( p1next_intermediate , p2                 ), n+1), pw1, pw2) -- player 1
  | otherwise                         = ((( p1                  , p2next_intermediate), n+1), pw1, pw2) -- player 2
  where
    moveFinished = (n `mod` 3) == 2

    toMove = atMove (n `div` 3)

    -- move + addition of score
    p1next = (newField pos1, score1+(newField pos1))
    p2next = (newField pos2, score2+(newField pos2))
    -- just move
    p1next_intermediate = (newField pos1, score1)
    p2next_intermediate = (newField pos2, score2)

    newField pos = (((pos + diceCount)-1) `mod` 10) + 1

    (pos1, score1) = p1
    (pos2, score2) = p2

    (p1, p2) = board
    (board, n) = gameState
    (gameState, pw1, pw2) = un



playUniversum:: Universe -> Universe
playUniversum universe
  | moveFinished && player1Wins = (gameState, p1w+1, p2w  )
  | moveFinished && player2Wins = (gameState, p1w  , p2w+1)
  | otherwise    = (gameState, p1w_1 + p1w_2 + p1w_3, p2w_1 + p2w_2 + p2w_3)
  where
    moveFinished = (numDices `mod` 3) == 0

    player1Wins = player1score >= 21
    player2Wins = player2score >= 21

    ((_, player1score), (_, player2score)) = board
    (board, numDices) = gameState
    (gameState, p1w, p2w) = universe

    (_, p1w_1, p2w_1) = playUniversum nextUniversum1
    (_, p1w_2, p2w_2) = playUniversum nextUniversum2
    (_, p1w_3, p2w_3) = playUniversum nextUniversum3

    nextUniversum1 = assumeDice universe 1
    nextUniversum2 = assumeDice universe 2
    nextUniversum3 = assumeDice universe 3

-- main = print (  playUniversum initialUniverse )
