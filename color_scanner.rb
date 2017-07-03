require 'paleta'

class ColorScanner
  def scan image
    image.palette = palette image
  end

  def palette image
    found_colors = colors(image)
    return nil if found_colors.length == 0
    Paleta::Palette.new(*found_colors)
  end

  def colors image
    rgbs = IO.popen(['./bin/dcolors', '-k', '10', image.path.to_s]).read
      .split("\n")
      .map {|l| l.split(',').map(&:to_i) }
      .map {|(r, g, b)| Paleta::Color.new(r,g,b) rescue nil }
      .compact
    rgbs
  end
end
