require 'paleta'
require 'color-rgb'

# hack, to get around method incorrectly failing
# https://github.com/jordanstephens/paleta/blob/db19d8b407dc461305f5bfb45c90e5c4383fcf4a/lib/paleta.rb#L14
def Paleta.rmagick_available?
  true
end

class ColorComparer

  def initialize
    @cache = {}
  end

  # https://github.com/jordanstephens/paleta#comparing-colors
  def diff image1, image2
    image1.palette.similarity image2.palette
  end

  def palette image_path
    Paleta::Palette.generate(:from => :image, :image => image_path, :size => 4)
  end

  # palette similarity
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

  # main color distance
  def sort_similar image, images
    main_color = image.colors.first
    comparitor = Color::Comparison.new(main_color)
    images.select{|o| o.palette }.to_a.sort_by do |other_image|
      comparitor.compare other_image.colors.first
    end.to_a
  end

  # matching color distances
  #  BEST SO FAR
  def sort_similar image, images
    r = images.select{|o| o.colors? }.to_a.sort_by do |other_image|
      s = Time.now.to_f
      # go through each images colors finding closest distance from
      # the other images colors and sum
      r = image.colors.map do |color|
        other_image.colors.map do |other_color|
          human_compare_colors color, other_color
        end.sort.first
      end.reduce(:+)
      puts "compare took: #{Time.now.to_f - s}"
      r
    end.to_a
  end

  def human_compare_colors color1, color2
    Color::Comparison.distance color1, color2
  end
end
