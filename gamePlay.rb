require './lib/board'
require './lib/machine'
class GamePlay
  def initialize
    puts "Welcome To TicTacToe"
    board = Board.new
    print("Would You Like Single Player or Double Player? (1/2): ")
    playType = gets.chomp.strip.to_i
    board.machine = playType == 1 ? Machine.new : nil
    while(!board.won? && !board.draw?)
      system "clear"
      board.printBoard();
      print "Player #{board.current_player} enter row: "
      row = gets.chomp.strip.to_i
      print("\n")
      print "Player #{board.current_player} enter col: "
      col = gets.chomp.strip.to_i
      print("\n")
      markStatus = board.markBoard(row, col);
      if !markStatus
        system "clear"
        puts "[Error: Please Enter a Valid Input] \n\n"
        next
      end
      board.switchPlayer();
      board.machine.play(board) if board.machine.is_a?(Machine)
    end
    system "clear"
    board.printBoard();
    print("Game has ended\n")
    puts "#{board.getInfo}"
  end
end

GamePlay.new
