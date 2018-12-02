class Machine
  def play(board)
    return false if board.draw? || board.won?
    gameMode = gameModeChoice(board)
    row, col = gameMode == :defense ? defense_coordinates(board) : attack_coordinates(board)
    if board.rows[row][col] == '.'
      board.markBoard(row.next, col.next)
      board.switchPlayer
      return board
    else
      self.play(board)
    end
  end

  def gameModeChoice(board)
    attack_choices, defense_choices = attack_moves(board), defense_moves(board)
    if !attack_choices.is_a?(Hash) || attack_choices.keys.max.to_i < defense_choices.keys.max.to_i
      return :defense
    else
      return :attack
    end
  end

  def defense_coordinates(board)
    compute_coordinates(board, :defense) 
  end

  def attack_coordinates(board)
    compute_coordinates(board, :attack)
  end

  def attack_moves(board)
    compute_moves(board, board.current_player)  
  end

  def defense_moves(board)    
    compute_moves(board, board.opponent) 
  end

  def compute_moves(board, player)
    win_possibilities = Hash.new
    board.winPatterns.each do |pattern|
      pattern_map = pattern.map do |row, column|
        board.rows[row][column]
      end
      if pattern_map.include?(player) && pattern_map.include?('.') # !pattern_map.include?(board.current_player)
        pattern_possibility = (pattern_map.count(player)/3.0)*100
        win_possibilities.merge!(pattern_possibility => pattern)
      end
    end
    return win_possibilities
  end

  def compute_coordinates(board, gameMode)
    possible_patterns = gameMode == :defense ? defense_moves(board) : attack_moves(board)
    expected_pattern = possible_patterns[possible_patterns.keys.max]
    return false if expected_pattern.nil?
    mapped_expected_pattern = expected_pattern.map do |position|
     {position => board.rows[position.first][position.last]}
    end
    selected_position = mapped_expected_pattern.select{|position| position.values.first == '.'}.first
    return selected_position.keys.first
  end

end
