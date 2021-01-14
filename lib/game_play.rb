# frozen_string_literal: true

require_relative 'board.rb'
require_relative 'machine.rb'
require_relative 'graphics.rb'

# Game Loop
class GamePlay
  attr_accessor :gamestate
  def initialize
    @board = Board.new
    @graphics_h = GraphicsHandler.new
    fetch_user_options
  end

  def fetch_user_options
    game_options = @graphics_h.render_splash
    @board.machine = Machine.new if game_options[:game_type] == Board::SINGLE_PLAYER
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
    loop do
      if @board.game_concluded?
        @graphics_h.render_result(@board.getInfo.to_s)
        @graphics_h.get_player_input
        next
      end

      player_input = @graphics_h.get_player_input
      mark_status  = @board.mark_board(player_input.row, player_input.col)
      next unless mark_status

      @board.switchPlayer
      @board.machine.play(@board) if @board.machine.is_a?(Machine)
      @graphics_h.draw_grid(@board.rows)
    end
  end

  def post_game_process
    @graphics_h.render_result(@board.getInfo.to_s) if @board.game_concluded?
    @board.save_moves
  end
end
