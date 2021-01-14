# frozen_string_literal: true

require 'redis'
require 'json'
require 'pry'
REDIS_SERV = Redis.new host: 'localhost', port: '6379'
REDIS_CHANNEL = 'tictactoe'
REDIS_ENABLED = false

class Board
  O_SPRITE = 'o'
  X_SPRITE = 'x'
  UNIN_SRPITE = '.'
  attr_accessor :rows, :current_player, :info, :winner, :machine, :id, :moves
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
    @moves = []
    @current_player = X_SPRITE
    @rows = 3.times.map { 3.times.map { UNIN_SRPITE.dup } }
  end

  def won?
    winFlag = false
    @@winPatterns.each do |possibility|
      possibility_map = possibility.map do |position|
        self.rows[position.first][position.last]
      end
      if !possibility_map.uniq.include?(UNIN_SRPITE) && possibility_map.uniq.length == 1
        self.winner = possibility_map.uniq.first
        winFlag = true; break
      end
    end
    return winFlag
  end

  def draw?
    !self.won? && !self.rows.flatten.include?(UNIN_SRPITE)
  end

  def game_concluded?
    won? || draw?
  end

  def switchPlayer
    self.current_player = current_player == X_SPRITE ? O_SPRITE : X_SPRITE
  end

  def opponent
    current_player == X_SPRITE ? O_SPRITE : X_SPRITE
  end

  def winPatterns
    @@winPatterns
  end

  def mark_board(row, col)
    return false unless @rows[row][col] == UNIN_SRPITE

    @rows[row][col] = @current_player
    @moves << { @current_player => [row, col] }
    Board.saveBoard(self) if REDIS_ENABLED
    true
  end

  def save_moves
    setId if self.id.nil?
    app_root = File.realpath('.')
    file = File.new("#{app_root}/db/#{self.id}.json", 'w+')
    file.puts({outcome: currentStatus, moves: self.moves}.to_json)
    file.close
  end

  def currentStatus
    if self.won?
      return self.winner
    elsif self.draw?
      return 'xo'
    else
      return 'Game in Progress'
    end
  end

  def setId(proposedId=rand(1..Time.now.to_i))
    self.id = proposedId
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

  def self.saveBoard(board)
    setId if board.id.nil?
    REDIS_SERV.set(board.id, board.rows)
    REDIS_SERV.publish REDIS_CHANNEL, {board_id: board.id, message: 'board-updated'}.to_json
  end

  def self.retrieveBoard(board_id)
    REDIS_SERV.get(board_id)
  end

end
