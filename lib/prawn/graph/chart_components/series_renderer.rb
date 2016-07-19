module Prawn
  module Graph
    module ChartComponents

      # The Prawn::Graph::ChartComponents::SeriesRenderer is used to plot indivdual Prawn::Graph::Series on
      # a Prawn::Graph::ChartComponents::Canvas and its associated Prawn::Document.
      #
      class SeriesRenderer
        # @param series [Prawn::Graph::Series]
        # @param canvas [Prawn::Graph::ChartComponents::Canvas]
        #
        def initialize(series, canvas, color = '000000')
          raise ArgumentError.new("series must be a Prawn::Graph::Series") unless series.is_a?(Prawn::Graph::Series)
          raise ArgumentError.new("canvas must be a Prawn::Graph::ChartComponents::Canvas") unless canvas.is_a?(Prawn::Graph::ChartComponents::Canvas)

          @series = series
          @canvas = canvas
          @prawn = canvas.prawn
          @color = color

          @graph_area = @canvas.layout.graph_area

          @plot_area_width  = @graph_area.width - 25
          @plot_area_height = @graph_area.height - 20
        end

        def render
          render_chart
        end

        private

        def render_chart
          raise "Subclass Me"
        end

        def render_axes
          prawn.stroke_color  = @canvas.theme.axes
          prawn.fill_color  = @canvas.theme.axes
          prawn.stroke_horizontal_line(0, @plot_area_width, at: 0) 
          prawn.stroke_vertical_line(0, @plot_area_height, at: 0) 
          prawn.fill_and_stroke_ellipse [ 0,0], 1

          max = @series.max || 0
          min = @series.min || 0
          avg = @series.avg || 0
          mid = (min + max) / 2 rescue 0

          add_y_axis_label(max)
          add_y_axis_label(min)
          add_y_axis_label(avg)
          add_y_axis_label(mid)

          add_x_axis_labels
        end

        def add_x_axis_labels 
          return if @canvas.options[:xaxis_labels].size.zero?
          width_of_each_label = (@plot_area_width / @canvas.options[:xaxis_labels].size) - 1
          @canvas.options[:xaxis_labels].each_with_index do |label, i|
            offset    = i + 1
            position  = ((offset * width_of_each_label) - width_of_each_label) + 1
            
            prawn.text_box  label, at: [ position, -2 ], width: width_of_each_label, height: 6, valign: :center, align: :center,
                            overflow: :shrink_to_fit
          end
        end

        def add_y_axis_label(value)
          unless value.zero?
            y = (point_height_percentage(value) * @plot_area_height)
            prawn.text_box "#{max}", at: [-14, y], height: 5, overflow: :shrink_to_fit, width: 12, valign: :bottom, align: :right 
          end
        end

        # Calculates the relative height of a given point based on the maximum value present in
        # the series.
        #
        def point_height_percentage(value)
          ((BigDecimal(value, 10)/BigDecimal(@canvas.series.collect(&:max).max, 10)) * BigDecimal(1)).round(2) rescue 0
        end

        def prawn
          @prawn
        end
      end
    end
  end
end
