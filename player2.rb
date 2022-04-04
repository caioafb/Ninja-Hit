class Player2
	SPEED = 5
	attr_reader :x, :y, :height, :width
	def initialize(window)
		@x = window.width - 100
		@y = 275
		@height = 109
		@width = 58
		@images = []
		for i in 0..9 do
			@images[i] = Gosu::Image.new('images/EIdle'+i.to_s+'.png')
		end
		@images_throw = []
		for i in 0..9 do
			@images_throw[i] = Gosu::Image.new('images/EThrow'+i.to_s+'.png')
		end
		@image_hurt = []
		@image_hurt[0] = Gosu::Image.new('images/EDead0.png')
		@image_index = 0
		@window = window
		@throw = false
		@hurt = false
	end

	def move_up
		@y -= SPEED
		if @y < 0
			@y = 0
		end
	end

	def move_down
		@y += SPEED
		if @y > @window.height - @height
			@y = @window.height - @height
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
			@images_throw[@image_index.to_i].draw(@x, @y, 1)
			@image_index += 0.5
			if @image_index > 9
				@throw = false
			end
		elsif hurt?
			@image_hurt[0].draw(@x-@width, @y, 1)
			@image_index += 0.1
			if @image_index > 1
				@hurt = false
			end
		else
			@images[@image_index.to_i].draw(@x, @y, 1)
			@image_index += 0.3
			if @image_index > 9
				@image_index = 0
			end
		end
	end
end
