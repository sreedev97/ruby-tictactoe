# frozen_string_literal: true

require 'sdl2'
require 'ostruct'
require 'pry'

# Graphics Rendering Handler
class GraphicsHandler
  WINDOW_HEIGHT  = 480
  WINDOW_WIDTH   = 640
  GRID_BOX_W_SCALE = WINDOW_WIDTH / 3
  GRID_BOX_H_SCALE = WINDOW_HEIGHT / 3
  GRID_RENDER_COLOR   = [139, 94, 131, 255].freeze
  X_RENDER_COLOR      = [255, 255, 255, 255].freeze
  O_RENDER_COLOR      = [235, 198, 52, 255].freeze
  BACKGROUND_COLOR    = [0, 0, 0, 255].freeze

  def initialize
    SDL2.init(SDL2::INIT_EVERYTHING)
    SDL2::TTF.init
    load_fonts
    @window = SDL2::Window.create(
      'TicTacToe',
      SDL2::Window::POS_CENTERED,
      SDL2::Window::POS_CENTERED,
      WINDOW_WIDTH, WINDOW_HEIGHT, 0
    )
    @renderer = window.create_renderer(-1, 0)
    @renderer.draw_blend_mode = SDL2::BlendMode::ADD
    @renderer.draw_color = BACKGROUND_COLOR
    @renderer.clear
  end

  def render_splash
    @renderer.copy(
      renderer.create_texture_from(
        @result_font.render_solid('TIC-TAC-TOE', [255, 255, 255])
      ),
      nil, SDL2::Rect.new(100, 50, 400, 100))
    option_buttons = []
    option_buttons << draw_button(Board::SINGLE_PLAYER, 80, 200, 200, 100)
    option_buttons << draw_button(Board::MULTI_PLAYER, 300, 200, 200, 100)
    @renderer.present
    input_event = wait_for_event
    selected_game_type = option_buttons.find do |button|
      button[:btnx].cover?(input_event.x) &&
        button[:btny].cover?(input_event.y)
    end
    { game_type: selected_game_type[:value] }
  end

  def draw_button(button_text, xcoord, ycoord, wid, hei)
    button_rect = SDL2::Rect.new(xcoord, ycoord, wid, hei)
    @renderer.draw_color = GRID_RENDER_COLOR
    @renderer.draw_rect(button_rect)
    @renderer.copy(
      renderer.create_texture_from(
        @result_font.render_solid(button_text, GRID_RENDER_COLOR)
      ),
      nil, SDL2::Rect.new(xcoord+10, ycoord+10, wid-20, hei-20))

    { btnx: (xcoord..(xcoord+wid)), btny: (ycoord..(ycoord+hei)), value: button_text }
  end

  def draw_grid(grid)
    @renderer.draw_color = BACKGROUND_COLOR
    @renderer.clear
    grid.map.with_index do |row, ri|
      row.map.with_index do |col, ci|
        draw_box(col, ci, row, ri)
      end
    end
    @renderer.present
  end

  def wait_for_event
    input_event = 0
    loop do
      while ev = SDL2::Event.poll
        case ev
        when SDL2::Event::MouseButtonDown
          input_event = ev
        when SDL2::Event::Quit
          exit
        end
      end
      break unless input_event == 0
    end
    input_event
  end

  def get_player_input
    input_event = wait_for_event
    estimate_input_grid_coords(input_event.x, input_event.y)
  end

  def render_result(result_text)
    render_overlay
    @renderer.copy(
      renderer.create_texture_from(
        @result_font.render_blended(result_text, [255, 255, 255])
      ),
      nil, SDL2::Rect.new(100, 50, 400, 100))
    @renderer.present
  end

  def render_overlay
    @renderer.draw_color = [0, 0, 0, 120]
    @renderer.fill_rect(
      SDL2::Rect.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    )
    @renderer.present
  end

  private

  def load_fonts
    @result_font = SDL2::TTF.open(File.join(File.dirname(__FILE__), '..', 'assets', 'fonts', 'jetbrainsmono_bold.ttf'), 40)
  end

  def draw_box(colc, coli, rowc, rowi)
    @renderer.draw_color = fetch_draw_color(colc)
    gridbox = SDL2::Rect.new(coli * GRID_BOX_W_SCALE, rowi * GRID_BOX_H_SCALE, GRID_BOX_W_SCALE, GRID_BOX_H_SCALE)

    @renderer.copy(
      renderer.create_texture_from(
        @result_font.render_solid(colc, fetch_draw_color(colc))
      ),
      nil, gridbox)
  end

  def estimate_input_grid_coords(evx, evy)
    estimated_grid_x = 0
    estimated_grid_y = 0
    w_ranges = 3.times.map { |i| ((i * GRID_BOX_W_SCALE)..(i.next * GRID_BOX_W_SCALE)) }
    w_ranges.map.with_index do |grid_range, gindex|
      estimated_grid_x = gindex if grid_range.cover?(evx)
    end

    h_ranges = 3.times.map { |i| ((i * GRID_BOX_H_SCALE)..(i.next * GRID_BOX_H_SCALE)) }
    h_ranges.map.with_index do |grid_range, gindex|
      estimated_grid_y = gindex if grid_range.cover?(evy)
    end

    OpenStruct.new(row: estimated_grid_y, col: estimated_grid_x)
  end

  def fetch_draw_color(sprite)
    {
      Board::X_SPRITE => X_RENDER_COLOR,
      Board::O_SPRITE => O_RENDER_COLOR,
      Board::UNIN_SRPITE => GRID_RENDER_COLOR
    }[sprite]
  end

  attr_accessor :window, :renderer
end
