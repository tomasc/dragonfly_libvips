module DragonflyLibvips
  class Dimensions < Struct.new(:geometry, :orig_w, :orig_h)
    def self.call(*args)
      new(*args).call
    end

    def call
      return OpenStruct.new(width: orig_w, height: orig_h, scale: 1) if do_not_resize_if_image_smaller_than_requested? || do_not_resize_if_image_larger_than_requested?
      OpenStruct.new(width: width, height: height, scale: scale)
    end

    private

    def width
      if landscape?
        dimensions_specified_by_width? ? dimensions.width : dimensions.height / aspect_ratio
      else
        dimensions_specified_by_height? ? dimensions.height / aspect_ratio : dimensions.width
      end
    end

    def height
      if landscape?
        dimensions_specified_by_width? ? dimensions.width * aspect_ratio : dimensions.height
      else
        dimensions_specified_by_height? ? dimensions.height : dimensions.width * aspect_ratio
      end
    end

    def scale
      width.to_f / orig_w.to_f
    end

    def dimensions
      w, h = geometry.scan(/\A(\d*)x(\d*)/).flatten.map(&:to_f)
      OpenStruct.new(width: w, height: h)
    end

    def aspect_ratio
      orig_h.to_f / orig_w
    end

    def dimensions_specified_by_width?
      dimensions.width > 0
    end

    def dimensions_specified_by_height?
      dimensions.height > 0
    end

    def landscape?
      aspect_ratio <= 1.0
    end

    def portrait?
      !landscape?
    end

    def do_not_resize_if_image_smaller_than_requested?
      return false unless geometry.include? '>'
      orig_w < width && orig_h < height
    end

    def do_not_resize_if_image_larger_than_requested?
      return false unless geometry.include? '<'
      orig_w > width && orig_h > height
    end
  end
end
