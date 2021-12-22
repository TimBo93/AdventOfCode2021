struct GameState
{
    public int Player1Pos = 1;
    public int Player1Score = 0;

    public int Player2Pos = 1;
    public int Player2Score = 0;

    public Player atMove = Player.Player1;
}


enum Player
{
    Player1 = 0,
    Player2 = 1,
}

struct WinChance
{
    public long Player1;
    public long Player2;
}

class Day21
{
    private readonly Dictionary<GameState, WinChance> gameStates = new();

    static void Main()
    {
        var result = new Day21().CalculateUniversum(new GameState()
        {
            Player1Pos = 7,
            Player2Pos = 9,
            Player1Score = 0,
            Player2Score = 0,
            atMove = Player.Player1,
        }, 0);

        Console.WriteLine($"{result.Player1}, {result.Player2}");
        Console.WriteLine($"{Math.Max(result.Player1, result.Player2)}");
    }

    WinChance CalculateUniversum(GameState gameState, int diceCount)
    {
        var moveFinished = diceCount % 3 == 0;
        if(moveFinished)
        {
            if (gameState.Player1Score >= 21)
            {
                return new WinChance
                {
                    Player1 = 1,
                    Player2 = 0
                };
            }

            if (gameState.Player2Score >= 21)
            {
                return new WinChance
                {
                    Player1 = 0,
                    Player2 = 1
                };
            }

            if (gameStates.TryGetValue(gameState, out var cachedValue))
            {
                return cachedValue;
            }
        }

        WinChance w1 = CalculateUniversum(AssumeDice(gameState, 1, diceCount + 1), diceCount + 1);
        WinChance w2 = CalculateUniversum(AssumeDice(gameState, 2, diceCount + 1), diceCount + 1);
        WinChance w3 = CalculateUniversum(AssumeDice(gameState, 3, diceCount + 1), diceCount + 1);
        
        var chance = new WinChance
        {
            Player1 = w1.Player1 + w2.Player1 + w3.Player1,
            Player2 = w1.Player2 + w2.Player2 + w3.Player2
        };

        if(moveFinished)
        {
            gameStates.Add(gameState, chance);
        }

        return chance;
    }


    private GameState AssumeDice(GameState gameState, int diceAssumption, int diceCount)
    {
        var moveFinished = diceCount % 3 == 0;
        var playerAtMove = ((diceCount-1) / 3) % 2; // 0 = Player 1 , 1 = Player 2

        int newFieldPos(int pos)
        {
            return (pos + diceAssumption - 1) % 10 + 1;
        }

        if (moveFinished && playerAtMove == 0)
        {
            var newPlayer1Pos = newFieldPos(gameState.Player1Pos);
            return new GameState()
            {
                Player1Pos = newPlayer1Pos,
                Player1Score = gameState.Player1Score + newPlayer1Pos,
                Player2Pos = gameState.Player2Pos,
                Player2Score = gameState.Player2Score,
                atMove = Player.Player1
            };
        }
        else if(moveFinished && playerAtMove == 1)
        {
            var newPlayer2Pos = newFieldPos(gameState.Player2Pos);
            return new GameState()
            {
                Player1Pos = gameState.Player1Pos,
                Player1Score = gameState.Player1Score,
                Player2Pos = newPlayer2Pos,
                Player2Score = gameState.Player2Score + newPlayer2Pos,
                atMove = Player.Player2
            };
        } else if(playerAtMove == 0)
        {
            var newPlayer1Pos = newFieldPos(gameState.Player1Pos);
            return new GameState()
            {
                Player1Pos = newPlayer1Pos,
                Player1Score = gameState.Player1Score,
                Player2Pos = gameState.Player2Pos,
                Player2Score = gameState.Player2Score,
                atMove = Player.Player1
            };
        }
        else
        {
            var newPlayer2Pos = newFieldPos(gameState.Player2Pos);
            return new GameState()
            {
                Player1Pos = gameState.Player1Pos ,
                Player1Score = gameState.Player1Score,
                Player2Pos = newPlayer2Pos,
                Player2Score = gameState.Player2Score,
                atMove = Player.Player2
            };
        }
    }
}

