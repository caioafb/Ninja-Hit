class Ekunai
	SPEED = 8
	attr_reader :x, :y, :width, :height
	def initialize(window, x, y)
		@x = x
		@y = y
		@image = Gosu::Image.new('images/EKunai.png')
		@width = 80
		@height = 16
		@window = window
	end

	def move
		@x -= SPEED
	end

	def onscreen?
		right = @window.width+@width
		left = -@width
		@x > left and @x < right
	end

	def draw
		@image.draw(@x-50, @y+50, 1)
	end
end