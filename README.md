# Multi Paradigm Board Game Engine: Custom Checkers

## Project Overview
This repository contains a fully functional, console-based Checkers (Draughts) engine played on a standard 8x8 grid. It was developed to explore and compare core programming paradigms by solving the exact same problem using three fundamentally different architectures.

Beyond standard movement and king-promotion rules, I engineered two custom gameplay mechanics to increase the complexity of the state management:
1. **"Miss a Go" Ability:** A one-time-use mechanic allowing a player to force the opponent to skip their turn].
2. **"Move Opponent" Ability:** A one-time-use mechanic where a player can forcibly reposition an opponent's piece and place it on a one-turn movement cooldown.

## Paradigms & Implementation

### 1. Object-Oriented Programming (Python)
The Python implementation models the game as a collection of interacting objects with mutable states.
* **Encapsulation:** The architecture is separated into `Game`, `Board`, and `Piece` classes. Each piece independently tracks its own color, king status, and cooldown timer.
* **State Management:** The game loop continuously updates the board matrix, directly mutating the state of the grid as pieces are moved across the board.

### 2. Functional Programming (Haskell)
The Haskell implementation strictly adheres to immutability and pure functions.
* **Immutability:** Variables cannot be changed once defined. Instead of moving a piece on an existing board, the `movePiece` function takes the old board state as an input and calculates a completely new, independent board state as the output.
* **Recursion:** Standard flow control loops (like `while` loops) are replaced with a recursive `playTurn` function. The entire game state is passed as arguments into this function, which calls itself to simulate a repeating turn sequence.

### 3. Logic Programming (Prolog)
The Prolog implementation abandons traditional variables entirely, functioning instead as a declarative knowledge base.
* **Declarative Rules:** Instead of writing step-by-step algorithms to verify a move, the logic engine uses predefined truth rules (e.g. a move is valid if the start coordinates contain a piece and the destination is empty and the piece is not frozen).
* **Dynamic Database:** The game state is maintained by actively modifying the knowledge base. Using Prolog's built-in `retract` and `assert` predicates, old piece locations are deleted from the database and new locations are injected to progress the game.

## How to Run

### Python (OOP)
```bash
python Python_code.py
```
### Haskell (Functional)
```bash
stack runghc Haskell_code.hs
```
### Prolog (Logic)
```bash
swipl Prolog_code.pl
```



