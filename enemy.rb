class Enemy
	SPEED = 3.0
	attr_reader :x, :y, :height, :width
	def initialize(window, ninjas_killed)
		@height = 109
		@width = 58
		@speed = SPEED
		@window = window
		@x = @window.width
		@y = rand(@window.height - 80 - 2*@height) + @height-80
		@images = []
		for i in 0..9 do
			@images[i] = Gosu::Image.new('images/EIdle'+i.to_s+'.png')
		end
		@images_throw = []
		for i in 0..9 do
			@images_throw[i] = Gosu::Image.new('images/EThrow'+i.to_s+'.png')
		end
		@images_jump = []
		for i in 0..9 do
			@images_jump[i] = Gosu::Image.new('images/EJump'+i.to_s+'.png')
		end
		@dead = false
		@image_index = 0
		@throw = false
		@start = true
		@ninjas_killed = ninjas_killed
	end
	def move
		if @start
			@x -= 5
			if @image_index < 2
				@y -= 5
			else
				@y += 5
			end
		else
			@y += @speed + @ninjas_killed/30.0
			if @y > @window.height - @height || @y < 0
				@speed *= -1
				@ninjas_killed *= -1
			end
		end
	end

	def dead?
		return @dead
	end

	def dead
		@dead = true
	end

	def throw
		@throw = true
		@image_index = 0
	end

	def throw?
		return @throw
	end

	def start?
		return @start
	end

	def draw
		if @start
			@images_jump[@image_index.to_i].draw(@x, @y, 1)
			@image_index += 0.3
			if @image_index > 9
				@start = false
			end
		elsif throw?
			@images_throw[@image_index.to_i].draw(@x, @y, 1)
			@image_index += 0.5
			if @image_index > 9
				@throw = false
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
