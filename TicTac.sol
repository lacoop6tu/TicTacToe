pragma solidity 0.5.11;

// * All state of the game should live on-chain. State includes open games, games currently in progress and completed games.
// * Any user can submit a transaction to the network to invite others to start a game (i.e. create an open game).
// * Other users may submit transactions to accept invitations. When an invitation is accepted, the game starts.
// * The roles of “X” and “O” are decided as follows. The users' public keys are concatenated and the result is hashed. 
// If the first bit of the output is 0, then the game's initiator (whoever posted the invitation) plays "O" and the second player plays "X" and vice versa. 
// “X” has the first move.
// * Both users submit transactions to the network to make their moves until the game is complete.

contract TicTac {


    enum State { Open, Running, Played }

    enum boardState { Empty, PlayerOne, PlayerTwo }

    enum WinnerState { None, PlayerOne, PlayerTwo, Draw }

    struct Game {
        State gameState;
        address playerOne;
        address playerTwo;
        address turn;
        boardState[3][3] board;
        WinnerState winner;
    }

    event GameOver (uint256 gameId, WinnerState winner);


    uint256 public totalGames; 

    mapping(uint256 => Game) public games;

    bytes32 public test;
    
    //uint8 public numero;
    
    byte public value;
    
    bool public one;
    
    
    event NewGame (State GameState, address creator, uint gameId);

    event NewMove (uint gameId, uint coordX, uint coordY, address player);


    function startGame() public returns(uint, State){
             
            
            totalGames = totalGames+1;


            Game storage game = games[totalGames];
            

            game.gameState = State.Open;

            game.playerOne = msg.sender;


            emit NewGame(game.gameState, game.playerOne, totalGames);

            


    }


    function enterGame (uint256 _id) public returns (uint256 gamesId, State, address) {
        
        require(_id <= totalGames, 'this game does not exist');

        Game storage game = games[_id];

        require(game.playerOne != msg.sender, 'same player');
        require(game.gameState == State.Open, 'this game is being played or it has ended');

        game.playerTwo = msg.sender;

        game.gameState = State.Running;

        test  = sha256(abi.encodePacked(game.playerOne, msg.sender));
        value = test[0];
        one = value & shiftLeft(0x01, 7) != 0;

        if (one == true) game.turn = game.playerOne;
        else game.turn = game.playerTwo;

        return (_id, game.gameState, game.turn);



     }


     function makeMove(uint _id, uint _xCoordinate, uint _yCoordinate) public returns (bool){
         require(_id <= totalGames, 'this game does not exist');

         Game storage game = games[_id];

         require(game.gameState == State.Running, 'this game has not started or it has already ended');

         require(game.turn == msg.sender, 'not your turn'); // this works also to check if someone who's not playing tries to.

         require(game.board[_xCoordinate][_yCoordinate] == boardState.Empty, 'this cell has been already filled, choose another one');

         if (game.playerOne == msg.sender) {
            
            game.board[_xCoordinate][_yCoordinate] = boardState.PlayerOne;
            game.turn = game.playerTwo;

         }

         else {
            
            game.board[_xCoordinate][_yCoordinate] = boardState.PlayerTwo;
            game.turn = game.playerOne;

         }
            
        emit NewMove(_id,_xCoordinate, _yCoordinate, msg.sender);

        WinnerState winner = checkWinner(game.board);

        if (winner != WinnerState.None){
            
            game.winner = winner;

            game.gameState = State.Played;
         

           
            emit GameOver (_id, winner);
            return true;

        }
        

        else return true;
     }


     function checkWinner(boardState[3][3] memory _board) private pure returns (WinnerState winner) {
       
        boardState player = winnerInRow(_board);
        if (player == boardState.PlayerOne) {
            return WinnerState.PlayerOne;
        }
        if (player == boardState.PlayerTwo) {
            return WinnerState.PlayerTwo;
        }

        player = winnerInColumn(_board);
        if (player == boardState.PlayerOne) {
            return WinnerState.PlayerOne;
        }
        if (player == boardState.PlayerTwo) {
            return WinnerState.PlayerTwo;
        }

        player = winnerInDiagonal(_board);
        if (player == boardState.PlayerOne) {
            return WinnerState.PlayerOne;
        }
        if (player == boardState.PlayerTwo) {
            return WinnerState.PlayerTwo;
        }

        // If there is no winner and no more space on the board,
        // then it is a draw.
        if (isBoardFull(_board)) {
            return WinnerState.Draw;
        }

        return WinnerState.None;
    }


     // winnerInRow returns the player that wins in any row.
  
    function winnerInRow(boardState[3][3] memory _board) private pure returns (boardState winner) {
        for (uint8 x = 0; x < 3; x++) {
            if (
                _board[x][0] == _board[x][1]
                && _board[x][1]  == _board[x][2]
                && _board[x][0] != boardState.Empty
            ) {
                return _board[x][0];
            }
        }

        return boardState.Empty;
    }

    
    // winnerInColumn returns the player that wins in any column.

    function winnerInColumn(boardState[3][3] memory _board) private pure returns (boardState winner) {
        for (uint8 y = 0; y < 3; y++) {
            if (
                _board[0][y] == _board[1][y]
                && _board[1][y] == _board[2][y]
                && _board[0][y] != boardState.Empty
            ) {
                return _board[0][y];
            }
        }

        return boardState.Empty;
    }

    // winnerInDiagoral returns the player that wins in any diagonal.
    
    function winnerInDiagonal(boardState[3][3] memory _board) private pure returns (boardState winner) {
        if (
            _board[0][0] == _board[1][1]
            && _board[1][1] == _board[2][2]
            && _board[0][0] != boardState.Empty
        ) {
            return _board[0][0];
        }

        if (
            _board[0][2] == _board[1][1]
            && _board[1][1] == _board[2][0]
            && _board[0][2] != boardState.Empty
        ) {
            return _board[0][2];
        }

        return boardState.Empty;
    }

    function isBoardFull(boardState[3][3] memory _board) private pure returns (bool isFull) {
        for (uint8 x = 0; x < 3; x++) {
            for (uint8 y = 0; y < 3; y++) {
                if (_board[x][y] == boardState.Empty) {
                    return false;
                }
            }
        }

        return true;
    }


    function shiftLeft(bytes1 a, uint8 n) private returns (bytes1) {
         uint8 shifted = uint8(a) * 2 ** n;
        return bytes1(shifted);
    }

    function viewGame(uint _id) public view returns(State,address,address,address,WinnerState) {
            
            Game storage game = games[_id];

     
            return (game.gameState, game.playerOne, game.playerTwo, game.turn, game.winner);
    }


// getting the bit step by step

    // function hashit() public returns (bytes32){ 
    //       test  = sha256(abi.encodePacked(gamer1, gamer2));
    //     // test = keccak256(gamer1,gamer2);

    //     return test;
    // }
    
    
    // function accessByte(
    //  bytes32 _arg, 
    //  uint8 _index
    // ) public returns (uint8) {
    //  value = _arg[_index];
    //  numero = uint8(value);
     
     
    //  return numero;
    // }
    
    
  


    //   // Get bit value at position
    // function getBit(bytes1 a, uint8 n) public returns (bool) {
    //     one = a & shiftLeft(0x01, n) != 0;
        
    //     return one;
    // }



    // all in one steps
    // function allInOne () public {
    //     test  = sha256(abi.encodePacked(gamer1, gamer2));
    //     value = test[0];
    //     one = a & shiftLeft(0x01, 7) != 0;

    //     return one;
    // }



}
