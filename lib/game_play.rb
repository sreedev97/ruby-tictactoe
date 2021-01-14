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
  end

  def fetch_user_options
    game_options = @graphics_h.render_splash
    @board.machine = Machine.new if game_options[:game_type] == Board::SINGLE_PLAYER
  end

  def play
    fetch_user_options
    @graphics_h.draw_grid(@board.rows)
    game_loop
  end

  private

  attr_accessor :board, :graphics_h

  def game_loop
    flags = {}
    loop do
      if @board.game_concluded?
        flags[:play_again] = @graphics_h.render_result(@board.getInfo.to_s)
        post_game_process
        break
      end

      player_input = @graphics_h.get_player_input
      mark_status  = @board.mark_board(player_input.row, player_input.col)
      next unless mark_status

      @board.switchPlayer
      @board.machine.play(@board) if @board.machine.is_a?(Machine)
      @graphics_h.draw_grid(@board.rows)
    end

    return unless flags[:play_again]

    @board = Board.new
    play
  end

  def post_game_process
    @board.save_moves
  end
end
