require 'paleta'

# hack, to get around method incorrectly failing
# https://github.com/jordanstephens/paleta/blob/db19d8b407dc461305f5bfb45c90e5c4383fcf4a/lib/paleta.rb#L14
def Paleta.rmagick_available?
  true
end

class ColorComparer

  # https://github.com/jordanstephens/paleta#comparing-colors
  def diff image1, image2
    image1.palette.similarity image2.palette
  end

  def palette image_path
    Paleta::Palette.generate(:from => :image, :image => image_path, :size => 4)
  end

  def sort_similar image, images
    p = Paleta::Palette.generate(:type => :complementary, :from => :color, :size => 10, color: image.palette.colors.first)
    images.select{|o| o.palette }.to_a.sort_by do |other_image|
      r = p.similarity other_image.palette
      r = r.nan? ? 1 : r
      r2 = image.palette.similarity other_image.palette
      r2 = r2.nan? ? 1 : r2
      r + r2
    end.to_a
  end
end
