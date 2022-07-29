# frozen_string_literal: true

require "vips"

def image_properties(content)
  img = Vips::Image.new_from_file(content.path, access: :sequential)

  {
    format: File.extname(img.filename)[1..-1],
    width: img.width,
    height: img.height,
    xres: img.xres,
    yres: img.yres,
  }
end

module MiniTest::Assertions
  [:width, :height, :format].each do |property|
    define_method "assert_#{property}" do |obj, value|
      assert_equal value, image_properties(obj)[property]
    end
    Object.infect_an_assertion "assert_#{property}", "must_have_#{property}", :reverse
  end
end
