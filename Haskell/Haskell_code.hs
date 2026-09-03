-- Name: Colin Nartey


-- command to run: stack runghc haskell_solution.hs

import Data.Char (toUpper, toLower, isUpper)
import Text.Read (readMaybe)

-- data types 
type Board = [[Char]]   -- list of characters.
type Player = Char    -- 'w' or 'b'
type Coords = (Int, Int)    -- (Row, Col)

-- the states of abilities and cooldowns need to be passed through recursion
type Abilities = (Bool, Bool, Bool, Bool) -- this is for black skip and white skip and black move and white move
type Cooldowns = [Coords]  -- coordinates for pieces that are frozen


-- main Functions

-- Creates the  8x8 grid
setupBoard :: Board
setupBoard = [[pieceAt r c | c <- [0..7]] | r <- [0..7]]
  where
    pieceAt r c
      | odd (r + c) && r < 3 = 'b'
      | odd (r + c) && r > 4 = 'w'
      | otherwise            = '.'

-- gets pieces at their specific coordinates
getPiece :: Board -> Coords -> Char
getPiece board (r, c) = (board !! r) !! c

-- update a specific spot in the list of lists using a functional change of state
setAt :: Board -> Coords -> Char -> Board
setAt board (r, c) val =
  take r board ++
  [take c (board !! r) ++ [val] ++ drop (c + 1) (board !! r)] ++
  drop (r + 1) board

-- moves a piece and returns a brand new board (immutable)
movePiece :: Board -> Coords -> Coords -> Board
movePiece board start@(r1, c1) end@(r2, c2) = 
    let 
        piece = getPiece board start
        -- checkes if a piece is to be made king
        newPiece = if (piece == 'w' && r2 == 0) || (piece == 'b' && r2 == 7) 
                   then toUpper piece 
                   else piece
        -- removes from old spot, add to new spot
        boardStep1 = setAt board start '.'
    in setAt boardStep1 end newPiece

-- checks if a move is basic valid (bounds and empty target)
isValidMove :: Board -> Coords -> Coords -> Player -> Cooldowns -> Bool
isValidMove board s@(r1, c1) e@(r2, c2) player cooldowns =
    let piece = getPiece board s
        target = getPiece board e
    in 
       -- checks Bounds
       r1 >= 0 && r1 < 8 && c1 >= 0 && c1 < 8 &&
       r2 >= 0 && r2 < 8 && c2 >= 0 && c2 < 8 &&
       -- 
       toLower piece == player &&
       -- checks to see if Target square is empty
       target == '.' &&
       -- Check Cooldowns
       not (s `elem` cooldowns)

-- displays the board  
printBoard :: Board -> Int -> Player -> IO ()
printBoard board turn player = do
    putStrLn $ "\nTurn: " ++ show turn ++ " | Player: " ++ [toUpper player]
    putStrLn "  0 1 2 3 4 5 6 7"
    printRows board 0

printRows :: Board -> Int -> IO ()
printRows [] _ = return ()
printRows (row:rest) i = do
    putStrLn $ show i ++ " " ++ [c | c <- row]
    printRows rest (i + 1)

-- switches player
otherPlayer :: Player -> Player
otherPlayer 'w' = 'b'
otherPlayer 'b' = 'w'

-- the game loop (recursion instead of while loop)
playTurn :: Board -> Player -> Int -> Abilities -> Cooldowns -> IO ()
playTurn board player turn abilities cooldowns = do
    -- 1. prints board
    printBoard board turn player
    
    -- 2. gets input
    putStrLn "\choose (m)ove, (s)kip ability, (a)bility to move opponent:"
    choice <- getLine
    
    case choice of
        "m" -> do
            putStrLn "From row:"
            r1 <- readLn
            putStrLn "From col:"
            c1 <- readLn
            putStrLn "To row:"
            r2 <- readLn
            putStrLn "To col:"
            c2 <- readLn
            
            if isValidMove board (r1, c1) (r2, c2) player cooldowns
                then do
                    -- calculate new board state
                    let newBoard = movePiece board (r1, c1) (r2, c2)
                    -- switch turn using recursive call 
                    playTurn newBoard (otherPlayer player) (turn + 1) abilities []
                else do
                    putStrLn "invalid move or piece on cooldown!"
                    playTurn board player turn abilities cooldowns 

        "s" -> do
            -- 3. Skip Ability 
            let (w_sk, b_sk, w_mv, b_mv) = abilities
            let canSkip = if player == 'w' then not w_sk else not b_sk
            
            if canSkip
                then do
                    putStrLn "skip has been activated! pelase make your first move now"
                    -- getting the extra move inputs
                    putStrLn "Move 1 From row:"
                    r1 <- readLn
                    putStrLn "Move 1 From col:"
                    c1 <- readLn
                    putStrLn "Move 1 To row:"
                    r2 <- readLn
                    putStrLn "Move 1 To col:"
                    c2 <- readLn
                    
                    let newBoard = movePiece board (r1, c1) (r2, c2)
                    let newAbilities = if player == 'w' then (True, b_sk, w_mv, b_mv) else (w_sk, True, w_mv, b_mv)
                    
                    -- calls playTurn with the same player
                    playTurn newBoard player turn newAbilities cooldowns
                else do
                    putStrLn "you have already used this ability!"
                    playTurn board player turn abilities cooldowns

        "a" -> do
            -- 4. Move Opponent Ability 
            let (w_sk, b_sk, w_mv, b_mv) = abilities
            let canMoveOpp = if player == 'w' then not w_mv else not b_mv
            
            if canMoveOpp
                then do
                    putStrLn "Opponent piece row:"
                    r1 <- readLn
                    putStrLn "Opponent piece col:"
                    c1 <- readLn
                    putStrLn "Target row:"
                    r2 <- readLn
                    putStrLn "Target col:"
                    c2 <- readLn
                    
                    let targetPiece = getPiece board (r1, c1)
                    if targetPiece /= '.' && toLower targetPiece /= player
                        then do
                            let newBoard = movePiece board (r1, c1) (r2, c2)
                            let newAbilities = if player == 'w' then (w_sk, b_sk, True, b_mv) else (w_sk, b_sk, w_mv, True)
                            -- adds the target piece to cooldowns list so they can't move next turn
                            let newCooldowns = [(r2, c2)] 
                            
                            -- switch turn 
                            playTurn newBoard (otherPlayer player) (turn + 1) newAbilities newCooldowns
                        else do
                            putStrLn "not an opponent piece!"
                            playTurn board player turn abilities cooldowns
                else do
                    putStrLn "ability already used!"
                    playTurn board player turn abilities cooldowns

        _ -> do
            putStrLn "invalid choice (type m, s, or a)"
            playTurn board player turn abilities cooldowns

main :: IO ()
main = do
    putStrLn "Student ID: 23666305 - Starting Haskell Draughts..."
    let initialBoard = setupBoard
    playTurn initialBoard 'w' 0 (False, False, False, False) []
