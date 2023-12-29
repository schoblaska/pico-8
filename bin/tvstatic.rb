require "rmagick"
require "pry"

RED = 65_535

def encode_image(image_path)
  img = Magick::Image.read(image_path).first
  img = img.quantize(256, Magick::GRAYColorspace) # Ensure it's grayscale

  bin_str = ""

  img.each_pixel do |pixel, _c, _r|
    gray_val = pixel.to_hsla[2]
    bin_str << quantize_to_2bit(gray_val)
  end

  # encode bin_str to hex and print
  puts bin_str.to_i(2).to_s(16)
end

def find_line(image_path)
  img = Magick::Image.read(image_path).first
  line = []

  128.times do |y|
    128.times do |x|
      line[y] = x if img.pixel_color(x, y).red == RED
    end
  end

  avg = (line.sum / line.length.to_f).to_i

  p(line.map { |x| x - avg })
end

def quantize_to_2bit(value)
  case value
  when 0..63
    "00" # black
  when 64..127
    "01" # dark gray
  when 128..191
    "10" # light gray
  else
    "11" # white
  end
end

if ARGV.length != 2
  puts "usage: ruby tvstatic.rb <encode | find_line> <image_path>"
  exit
end

command = ARGV[0]
image_path = ARGV[1]

case command
when "encode"
  encode_image(image_path)
when "find_line"
  find_line(image_path)
else
  raise "Unknown command: #{command}"
end
