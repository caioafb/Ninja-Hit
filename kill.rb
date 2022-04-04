class Kill
	attr_reader :finished
	def initialize(window,x,y)
		@x = x
		@y = y
		@height = 124
		@width = 120
		@images = []
		for i in 0..9 do
			@images[i] = Gosu::Image.new('images/EDead'+i.to_s+'.png')
		end
		@image_index = 0
		@finished = false
	end

	def draw
		if @image_index < @images.count
			@images[@image_index.to_i].draw(@x - @width/2, @y, 2)
			@image_index += 0.4
		else
			@finished = true
		end
	end
end