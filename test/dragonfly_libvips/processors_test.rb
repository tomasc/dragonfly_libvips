require 'test_helper'
require 'ostruct'
require 'dragonfly_libvips'
require 'dragonfly_libvips/processors/noop'

describe DragonflyLibvips do
  let(:app) { test_libvips_app }
  let(:processor) { DragonflyLibvips::Processors::Noop.new }
  let(:url_attributes) { OpenStruct.new }
  let(:content) { OpenStruct.new(ext: 'xyz') }
  include DragonflyLibvips

  describe 'wrap_process' do
    it 'raises an error if an unsupported format is requested' do
      assert_raises( DragonflyLibvips::UnsupportedFormat ) do
        processor.call(content, {format: 'abc'})
      end
    end

    describe 'update_url' do
      describe 'when ext passed in' do
        before { processor.update_url(url_attributes, '2x2', 'format' => 'png') }
        it { _(url_attributes.ext).must_equal 'png' }
      end

      describe 'when ext not passed in' do
        before { processor.update_url(url_attributes, '2x2') }
        it { _(url_attributes.ext).must_be_nil }
      end
    end

  end
  # describe 'format' do
  #   let(:url_attributes) { OpenStruct.new }
  #
  #   describe 'wrap_process' do
  #     describe 'input options' do
  #
  #     end
  #
  #     describe 'output options' do
  #
  #     end
  #   end


  # end
end
