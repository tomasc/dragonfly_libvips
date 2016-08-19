def image_properties(image)
  details = `vipsheader #{image.path}`
  raise "couldn't identify #{image.path} in image_properties" if details.empty?
  filename, dimensions, _bands, _interpretation, vips_loader = details.split(/\s*[:,]\s*/)
  width, height = dimensions.split(/\s+/).first.split('x')
  format = vips_loader.gsub(/\s*load\s*/, '').downcase

  {
    filename: filename,
    format: format.downcase,
    width: width.to_i,
    height: height.to_i
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
