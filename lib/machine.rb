class Machine
  def play(board)
    return false if board.draw? || board.won?
    row, col = generate_coordinates(board)
    if board.rows[row][col] == '.'
      board.markBoard(row.next, col.next)
      board.switchPlayer
      return board
    else
      self.play(board)
    end
  end

  def generate_coordinates(board)
    possible_patterns = win_moves(board)
    expected_pattern = possible_patterns[possible_patterns.keys.max]
    mapped_expected_pattern = expected_pattern.map do |position|
      {position => board.rows[position.first][position.last]}
    end
    selected_position = mapped_expected_pattern.select{|position| position.values.first == '.'}.first
    return selected_position.keys.first
  end

  def win_moves(board)    
    win_possibilities = {}
    board.winPatterns.each do |pattern|
      pattern_map = pattern.map do |row, column|
        board.rows[row][column]
      end
      if pattern_map.include?(board.opponent) && pattern_map.include?('.') # !pattern_map.include?(board.current_player)
        pattern_possibility = (pattern_map.count(board.opponent)/3.0)*100
        win_possibilities.merge!(pattern_possibility => pattern)
      end
    end
    return win_possibilities
  end
end
