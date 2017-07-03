require 'paleta'
require 'color-rgb'

class ColorSaver

  def load image
    save_path = color_path(image)
    if save_path.exist?
      colors = colors_from_file save_path
      image.palette = Paleta::Palette.new colors if colors.length >= 3
      image.colors = rgb_colors save_path
    end
  end

  def rgb_colors save_path
    deserialize_colors(save_path.read).map do |(r,g,b)|
      Color::RGB.new(r, g, b) rescue nil
    end.compact
  end

  def colors_from_file(save_path)
    deserialize_colors(save_path.read).map do |(r,g,b)|
      begin
        Paleta::Color.new(r,g,b)
      rescue ArgumentError
        nil
      end
    end.compact.first(10)
  end

  def deserialize_colors str
    str.split("\n").map {|l| l.split(',').map(&:to_i) }
  end

  def color_path image
    Pathname.new("#{image.path}.colors")
  end
end
