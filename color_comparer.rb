require 'rmagick'
require 'paleta'

# hack, to get around method incorrectly failing
# https://github.com/jordanstephens/paleta/blob/db19d8b407dc461305f5bfb45c90e5c4383fcf4a/lib/paleta.rb#L14
def Paleta.rmagick_available?
  true
end

class ColorComparer

  # https://github.com/jordanstephens/paleta#comparing-colors
  def diff image_path1, image_path2
    palette(image_path1).similarity(palette(image_path2))
  end

  def palette image_path
    Paleta::Palette.generate(:from => :image, :image => image_path, :size => 64)
  end

end
