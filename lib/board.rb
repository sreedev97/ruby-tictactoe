class Board
  attr_accessor :rows, :current_player, :info, :winner, :machine
  @@winPatterns = [
    # Horizontal Patterns
    [[0, 0], [0, 1], [0, 2]],
    [[1, 0], [1, 1], [1, 2]],
    [[2, 0], [2, 1], [2, 2]],
    # Vertical Patterns
    [[0, 0], [1, 0], [2, 0]],
    [[0, 1], [1, 1], [2, 1]],
    [[0, 2], [1, 2], [2, 2]],
    # Diagonal Patters
    [[0, 0], [1, 1], [2, 2]],
    [[0, 2], [1, 1], [2, 0]]
  ]
  def initialize
    @current_player = 'x'
    @rows = [['.', '.', '.'],
             ['.', '.', '.'],
             ['.', '.', '.']]
  end

  def won?
    winFlag = false
    @@winPatterns.each do |possibility|
      possibility_map = possibility.map do |position|
        self.rows[position.first][position.last]
      end
      if !possibility_map.uniq.include?('.') && possibility_map.uniq.length == 1
        self.winner = possibility_map.uniq.first
        winFlag = true; break
      end
    end
    return winFlag
  end

  def draw?
    !self.won? && !self.rows.flatten.include?('.')
  end

  def switchPlayer
    self.current_player = current_player == 'x' ? 'o' : 'x'
  end

  def opponent
    current_player == 'x' ? 'o' : 'x'
  end

  def winPatterns
    @@winPatterns
  end
  
  def markBoard(row, col)
    row, col = [row, col].map(&:pred)
    if self.rows[row][col] != '.'
      return false
    end
    self.rows[row][col] = self.current_player
    return true
  end

  def getInfo
    self.info = "Player #{self.winner} has won" if self.won?
    self.info == "Game Drawn" if self.draw?
    return self.info
  end

  def printBoard
    self.rows.each do |row|
      row.each do |col|
        print "#{col}\t"
      end
      print "\n"
    end
  end
end
