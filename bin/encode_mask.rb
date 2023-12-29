require "base64"
require "rmagick"
require "pry"

# convert an image to 2-bit grayscale and base64 encode

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

def encode_image(image_path)
  img = Magick::Image.read(image_path).first
  img = img.quantize(256, Magick::GRAYColorspace)

  binary_str = ""

  img.each_pixel do |pixel, _c, _r|
    gray_value = pixel.to_hsla[2]
    binary_str += quantize_to_2bit(gray_value)
  end

  # convert the binary string to a byte array
  byte_array = [binary_str].pack("B*")

  print Base64.strict_encode64(byte_array)
end

if ARGV.length != 1
  puts "usage: ruby encode_mask.rb <image_path>"
  exit
end

image_path = ARGV[0]
encode_image(image_path)
