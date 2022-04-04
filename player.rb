class Player
	SPEED = 5
	attr_reader :x, :y, :height, :width
	def initialize(window)
		@x = 100
		@y = 330
		@height = 125
		@width = 72
		@images = []
		for i in 0..9 do
			@images[i] = Gosu::Image.new('images/PIdle'+i.to_s+'.png')
		end
		@images_throw = []
		for i in 0..9 do
			@images_throw[i] = Gosu::Image.new('images/PThrow'+i.to_s+'.png')
		end
		@image_hurt = []
		@image_hurt[0] = Gosu::Image.new('images/PDead0.png')
		@image_index = 0
		@window = window
		@throw = false
		@hurt = false
	end

	def move_up
		@y -= SPEED
		if @y < @height/2
			@y = @height/2
		end
	end

	def move_down
		@y += SPEED
		if @y > @window.height - @height/2
			@y = @window.height - @height/2
		end
	end

	def throw
		@throw = true
		@image_index = 0
	end

	def throw?
		return @throw
	end

	def hurt
		@hurt = true
		@image_index = 0
	end

	def hurt?
		return @hurt
	end

	def draw
		if throw?
			@images_throw[@image_index.to_i].draw(@x - @width/2, @y - @height/2, 1)
			@image_index += 0.5
			if @image_index > 9
				@throw = false
			end
		elsif hurt?
			@image_hurt[0].draw(@x - @width/2, @y - @height/2, 1)
			@image_index += 0.1
			if @image_index > 1
				@hurt = false
			end
		else
			@images[@image_index.to_i].draw(@x - @width/2, @y - @height/2, 1)
			@image_index += 0.3
			if @image_index > 9
				@image_index = 0
			end
		end
	end
end