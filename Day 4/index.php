<body style='font-family: monospace, monospace;'>

    <?php

    $myFile = new SplFileObject("input.txt");

    $allBingoFields = [];
    $currentBingoFieldToFill = null;
    $moves = null;

    while (!$myFile->eof()) {
        $line = $myFile->fgets() . PHP_EOL;

        if ($moves == null) {
            $moves = new Moves($line);
            continue;
        }

        if (trim($line) == '') {
            $currentBingoFieldToFill = new BingoField();
            continue;
        }

        if ($currentBingoFieldToFill != null) {
            $currentBingoFieldToFill->addLineFromInput($line);
            if ($currentBingoFieldToFill->isFilledComplete()) {
                array_push($allBingoFields, $currentBingoFieldToFill);
                $currentBingoFieldToFill = null;
            }
        }
    }


    $moveCount = $moves->getMoveCount();
    $bingoFieldCount = count($allBingoFields);
    for ($moveNumber = 0; $moveNumber < $moveCount; $moveNumber++) {
        $bingoNumber = $moves->getmove($moveNumber);

        echo "<p style='color: green'>calculating move " . $moveNumber . " which is " . $bingoNumber . "</p>";
        for ($bingoFieldNumber = 0; $bingoFieldNumber < $bingoFieldCount; $bingoFieldNumber++) {
            if ($allBingoFields[$bingoFieldNumber] != null) {
                $allBingoFields[$bingoFieldNumber]->playNumber($bingoNumber);
            }
        }

        for ($bingoFieldNumber = 0; $bingoFieldNumber < $bingoFieldCount; $bingoFieldNumber++) {
            if ($allBingoFields[$bingoFieldNumber] != null && $allBingoFields[$bingoFieldNumber]->checkWin()) {
                echo "<h1>found a winner</h1>";
                echo "it is bingo field number " . $bingoFieldNumber . "<br>";
                $allBingoFields[$bingoFieldNumber]->printField();

                $sumOfAllRemainingFields = $allBingoFields[$bingoFieldNumber]->getSumOfRemainingFields();
                echo "the sum is " . $sumOfAllRemainingFields . "<br>";
                echo "the last number to play was " . $bingoNumber . "<br>";
                echo "the product is " . $bingoNumber * $sumOfAllRemainingFields . "<br>";
                $allBingoFields[$bingoFieldNumber] = null;
            }
        }
    }

    class Moves
    {
        private $moves = array();

        function __construct($line)
        {
            preg_match_all('!\d+!', $line, $matches);
            $this->moves = $matches[0];
        }

        function getMove($moveNumber)
        {
            return $this->moves[$moveNumber];
        }

        function getMoveCount()
        {
            return count($this->moves);
        }
    }

    class BingoField
    {
        private $currentRowToInsert = 0;
        private $field = array();

        function addLineFromInput($line)
        {
            preg_match_all('!\d+!', $line, $matches);

            for ($i = 0; $i < 5; $i++) {
                $this->field[$this->currentRowToInsert][$i] = $matches[0][$i];
            }

            $this->currentRowToInsert += 1;
        }

        function playNumber($number)
        {
            for ($i = 0; $i < 5; $i++) {
                for ($ii = 0; $ii < 5; $ii++) {
                    if ($this->field[$i][$ii] == $number) {
                        $this->field[$i][$ii] = 0;
                    }
                }
            }
        }

        function checkWin()
        {
            for ($row = 0; $row < 5; $row++) {
                if ($this->checkHorLine($row)) {
                    return true;
                }
            }
            for ($column = 0; $column < 5; $column++) {
                if ($this->checkVerLine($column)) {
                    return true;
                }
            }
            return false;
        }

        function checkHorLine($line)
        {
            for ($i = 0; $i < 5; $i++) {
                if ($this->field[$line][$i] != 0) {
                    return false;
                }
            }
            return true;
        }

        function checkVerLine($column)
        {
            for ($i = 0; $i < 5; $i++) {
                if ($this->field[$i][$column] != 0) {
                    return false;
                }
            }
            return true;
        }

        function isFilledComplete()
        {
            return $this->currentRowToInsert == 5;
        }

        function printField()
        {
            for ($i = 0; $i < 5; $i++) {
                for ($ii = 0; $ii < 5; $ii++) {
                    echo str_pad($this->field[$i][$ii], 2, "0", STR_PAD_LEFT) . " ";
                }
                echo "<br>";
            }
            echo "<br>";
        }

        function getSumOfRemainingFields()
        {
            $sum = 0;
            for ($i = 0; $i < 5; $i++) {
                for ($ii = 0; $ii < 5; $ii++) {
                    $sum += $this->field[$i][$ii];
                }
            }
            return $sum;
        }
    }
    ?>

</body>