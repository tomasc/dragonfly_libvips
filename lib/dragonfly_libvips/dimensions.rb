# frozen_string_literal: true

module DragonflyLibvips
  Dimensions = Struct.new(:orig_w, :orig_h, :geom_w, :geom_h, :xpos, :ypos, :operators, :gravity, keyword_init: true) do
    def self.call(*args, **kwargs)
      new(*args, **kwargs).call
    end

    def call
      case
        when exact_size_requested?
          OpenStruct.new(width: geom_w, height: geom_h)
        when do_not_resize?
          OpenStruct.new(width: orig_w, height: orig_h, scale: 1)
        when cropping_requested?
          OpenStruct.new(width: width, height: height, x: xoffset, y: yoffset, scale: scale)
        else
          OpenStruct.new(width: width, height: height, scale: scale)
      end
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
      width.to_f / orig_w
    end

    def xoffset
      # image 1000, 100
      # centre = 500, 500
      # image centre at 500,500 with have x at 400, y at 400
      # with x offset becomes 450, 400

      x = case gravity
        when /e/
          orig_w - width
        when /w/
          0
        else
          #  centre is the defaults
          (orig_w - width)*0.5
      end
      x += xpos
    end

    def yoffset

      y = case gravity
        when /n/
          0
        when /s/
          orig_h - height
        else
          (orig_h - height) * 0.5
      end
      y += ypos
    end

    def dimensions
      OpenStruct.new(width: geom_w, height: geom_h)
    end

    def aspect_ratio
      orig_h.to_f / orig_w
    end

    def dimensions_specified_by_width?
      dimensions.width.positive?
    end

    def dimensions_specified_by_height?
      dimensions.height.positive?
    end

    def landscape?
      aspect_ratio <= 1.0
    end

    def portrait?
      !landscape?
    end

    def do_not_resize_if_image_smaller_than_requested?
      return false unless operators&.include? '>'

      orig_w < geom_w && orig_h < geom_h
    end

    def do_not_resize_if_image_larger_than_requested?
      return false unless operators&.include? '<'

      orig_w > geom_w && orig_h > geom_h
    end

    def do_not_resize?
      do_not_resize_if_image_smaller_than_requested? || do_not_resize_if_image_larger_than_requested?
    end

    def exact_size_requested?
      operators&.include?('!')
    end

    def cropping_requested?
      gravity || !(xpos.zero? && ypos.zero?)
    end
  end
end
