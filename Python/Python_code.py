# Name: Colin Nartey

class Piece:
    def __init__(self, color):
        self.color = color # w or b representing black or white
        self.is_king = False 
        self.cooldown_timer = 0 

    #makes the piece king
    def make_king(self):
        self.is_king = True

class Board:
    def __init__(self):
        # 8x8 grid store
        self.grid = [['.' for _ in range(8)] for _ in range(8)]
        self.setup()

    #places the 12 different black and white pieces on their places at the top and bottom of the grid
    def setup(self):
        for r in range(8):
            for c in range(8):
                if (r + c) % 2 != 0:
                    if r < 3: self.grid[r][c] = Piece('B')
                    elif r > 4: self.grid[r][c] = Piece('W')

    #updates the grid and piece positions after a player makes a move
    def update_grid(self, start, end):
        r1, c1 = start
        r2, c2 = end
        self.grid[r2][c2] = self.grid[r1][c1]
        self.grid[r1][c1] = '.'

class Game:
    def __init__(self, student_id):
        self.board = Board()
        self.student_id = student_id 
        self.turn_count = 0
        self.current_player = 'W'
        self.abilities = {"W_skip": False, "B_skip": False, "W_move": False, "B_move": False}
        self.skip_active = False #handles double moves


    def print_board(self):
        print(f"\nTurn: {self.turn_count} | Player: {self.current_player}")
        print("  0 1 2 3 4 5 6 7") # top Column Headers
        for i, row in enumerate(self.board.grid):
            visual_row = [p.color + ('K' if p.is_king else '') if isinstance(p, Piece) else '.' for p in row]
            print(f"{i} {' '.join(visual_row)}")

    def run_loop(self):
        while True:
            # 1 - displays the board
            self.print_board()

            # 2 - gets the user's input
            choice = input("\nchoose (m)ove, (s)kip ability, (a)bility to move opponent: ").lower()

            # 3 - If the user makes a move: verify -> move -> check king
            if choice == 'm':
                s = tuple(map(int, input("from row,col: ").split(',')))
                e = tuple(map(int, input("to row,col: ").split(',')))
                p = self.board.grid[s[0]][s[1]]
                if isinstance(p, Piece) and p.cooldown_timer == 0:
                    self.board.update_grid(s, e)
                    if (p.color == 'W' and e[0] == 0) or (p.color == 'B' and e[0] == 7):
                        p.make_king()
                else: print("invalid piece or on cooldown!")

            # 4 - if the user uses skip ability: move 1 -> mark used -> stay as same player
            elif choice == 's':
                key = f"{self.current_player}_skip"
                if not self.abilities[key]:
                    print(f"skip ability activated, make your first move now.")
                    s = tuple(map(int, input("Move 1 - From r,c: ").split(',')))
                    e = tuple(map(int, input("Move 1 - To r,c: ").split(',')))
                    self.board.update_grid(s, e) # move 1 implementation
                    self.abilities[key] = True
                    self.skip_active = True # stops the players being switched
                else: print("skip ability already used!")

            # 5 - if move opponent ability:
            elif choice == 'a':
                key = f"{self.current_player}_move"
                if not self.abilities[key]:
                    s = tuple(map(int, input("Opponent piece r,c: ").split(',')))
                    e = tuple(map(int, input("New r,c: ").split(',')))
                    target = self.board.grid[s[0]][s[1]]
                    if isinstance(target, Piece) and target.color != self.current_player:
                        self.board.update_grid(s, e)
                        target.cooldown_timer = 1
                        self.abilities[key] = True
                    else: print("not an opponent's piece!")
                else: print("already used!")

            # 6 - switch turn
            if self.skip_active:
                print("Opponent skipped! It is still your turn for Move 2.")
                self.skip_active = False # reset flag so turn switches next time
            else:
                self.turn_count += 1
                self.current_player = 'B' if self.current_player == 'W' else 'W'
            
            # reduce Cooldowns
            for row in self.board.grid:
                for p in row:
                    if isinstance(p, Piece) and p.cooldown_timer > 0: p.cooldown_timer -= 1

# launch game
Game("23666305").run_loop()
