require 'test_helper'
require 'dragonfly_libvips/geometry'

describe DragonflyLibvips::Dimensions do
  let(:geometry) { '' }
  let(:result) { DragonflyLibvips::Geometry.call(geometry) }

  it 'raises an error if an unrecognized string is given' do
    assert_raises(ArgumentError) do
      DragonflyLibvips::Geometry.call('1200@')
    end
  end

  it 'processes valid geometry strings' do

    describe 'NNxNN' do
      let(:geometry) { '250x300' }
      it { result.geom_w.must_equal 250 }
      it { result.geom_h.must_equal 300 }
    end

    describe 'Resize operations' do
      describe 'NNxNN!' do
        let(:geometry) { '250x300!' }
        it { result.geom_w.must_equal 250 }
        it { result.geom_h.must_equal 300 }
        it { result.operators.must_equal '!' }
      end

      describe 'NNxNN>' do
        let(:geometry) { '250x300>' }
        it { result.geom_w.must_equal 250 }
        it { result.geom_h.must_equal 300 }
        it { result.operators.must_equal '>' }
      end

      describe 'NNxNN<' do
        let(:geometry) { '250x300<' }
        it { result.geom_w.must_equal 250 }
        it { result.geom_h.must_equal 300 }
        it { result.operators.must_equal '<' }
      end
    end

    describe 'crop operations' do
      describe 'NNxNN+x+y' do
        let(:geometry) { '250x300+10+20' }
        it { result.geom_w.must_equal 250 }
        it { result.geom_h.must_equal 300 }
        it { result.x.must_equal '10' }
        it { result.y.must_equal '20' }
      end

      describe 'NNxNN-x+y' do
        let(:geometry) { '250x300-10+20' }
        it { result.geom_w.must_equal 250 }
        it { result.geom_h.must_equal 300 }
        it { result.x.must_equal '-10' }
        it { result.y.must_equal '20' }
      end
    end

    describe 'it accepts gravity arguments' do
      describe 'NNxNN#c' do
        let(:geometry) { '250x300#c' }
        it { result.geom_w.must_equal 250 }
        it { result.geom_h.must_equal 300 }
        it { result.gravity.must_equal 'c' }
      end
      describe 'NNxNN#sw' do
        let(:geometry) { '250x300#sw' }
        it { result.geom_w.must_equal 250 }
        it { result.geom_h.must_equal 300 }
        it { result.gravity.must_equal 'sw' }
      end
    end
  end
end



