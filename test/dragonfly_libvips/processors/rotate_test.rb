# require 'test_helper'
#
# describe DragonflyLibvips::Processors::Rotate do
#   let(:app) { test_libvips_app }
#   let(:image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('beach.png')) } # 280x355
#   let(:landscape_image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('landscape_beach.png')) } # 355x280
#   let(:processor) { DragonflyLibvips::Processors::Rotate.new }
#
#   it 'rotate 90' do
#     processor.call(image, 90)
#     image.must_have_width 355
#     image.must_have_height 280
#   end
#
#   it 'rotate 180' do
#     processor.call(image, 180)
#     image.must_have_width 280
#     image.must_have_height 355
#   end
#
#   it 'rotate 270' do
#     processor.call(image, 270)
#     image.must_have_width 355
#     image.must_have_height 280
#   end
#
#   it 'rotate with format' do
#     processor.call(image, 90, format: 'png')
#     image.must_have_width 355
#     image.must_have_height 280
#     image.ext.must_equal 'png'
#   end
# end
