# frozen_string_literal: true

require_relative 'board.rb'
require_relative 'machine.rb'
require_relative 'graphics.rb'

# Game Loop
class GamePlay
  def initialize
    @board = Board.new
    @graphics_h = GraphicsHandler.new
    fetch_user_options
  end

  def fetch_user_options
    print '(1/2): '
    @board.machine = Machine.new if gets.chomp.strip.to_i == 1
  end

  def play
    @graphics_h.draw_grid(@board.rows)
    game_loop
  ensure
    post_game_process
  end

  private

  attr_accessor :board, :graphics_h

  def game_loop
    until @board.game_concluded?
      player_input = @graphics_h.get_player_input
      mark_status  = @board.mark_board(player_input.row, player_input.col)
      next unless mark_status

      @board.switchPlayer
      @board.machine.play(@board) if @board.machine.is_a?(Machine)
      @graphics_h.draw_grid(@board.rows)
    end
  end

  def post_game_process
    puts @board.getInfo.to_s
    @board.save_moves
  end
end
