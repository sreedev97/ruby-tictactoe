# frozen_string_literal: true

require 'sdl2'
require 'pry'
require 'ostruct'

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
    SDL2.init(SDL2::INIT_VIDEO | SDL2::INIT_EVENTS)
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

  def get_player_input
    input_event = 0
    loop do
      while ev = SDL2::Event.poll
        case ev
        when SDL2::Event::MouseButtonDown
          input_event = ev
        end
      end
      break unless input_event == 0
    end
    estimate_input_grid_coords(input_event.x, input_event.y)
  end

  private

  def draw_box(colc, coli, rowc, rowi)
    @renderer.draw_color = fetch_draw_color(colc)
    operation = colc == Board::UNIN_SRPITE ? :draw_rect : :fill_rect
    gridbox = SDL2::Rect.new(coli * GRID_BOX_W_SCALE, rowi * GRID_BOX_H_SCALE, GRID_BOX_W_SCALE, GRID_BOX_H_SCALE)
    @renderer.send(
      operation,      # x, y, w, h
      gridbox
    )
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
