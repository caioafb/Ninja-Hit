require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'kunai'
require_relative 'ekunai'
require_relative 'kill'
class NinjaHit < Gosu::Window
	WIDTH = 1280
	HEIGHT = 720
	ENEMY_FREQUENCY = 0.005
	def initialize
		super(WIDTH,HEIGHT)
		self.caption = 'Ninja Hit'
		@player = Player.new(self)
		@enemies = []
		@kunais = []
		@enemy_kunais = []
		@kills = []
		@counter = 0
		@score = 0
	end

	def update
		@player.move_up if button_down?(Gosu::KbW)
		@player.move_down if button_down?(Gosu::KbS)
		if @counter == 0
			@enemies.push Enemy.new(self, @score)
			@counter = 1
		end
		@enemies.each do |enemy|
			enemy.move
			if rand < ENEMY_FREQUENCY+(@score/200.0) && not(enemy.dead?) && not(enemy.start?)
				@enemy_kunais.push Ekunai.new(self, enemy.x, enemy.y)
				enemy.throw
			end
		end
		@kunais.each do |kunai|
			kunai.move
		end
		@enemy_kunais.each do |kunai|
			kunai.move
		end
		@enemies.dup.each do |enemy|
			@kunais.dup.each do |kunai|
				distance = Gosu.distance(enemy.x, (enemy.y+enemy.height/2-10), kunai.x, kunai.y)
				if distance < enemy.height/2 && not(enemy.dead?)
					enemy.dead
					@enemies.delete enemy
					@kunais.delete kunai
					@kills.push Kill.new(self, enemy.x, enemy.y)
					@counter = 0
					@score += 1
				end
			end
		end
		@enemy_kunais.dup.each do |kunai|
			distance = Gosu.distance(@player.x+@player.width/2-20, @player.y-@player.height/2+8, kunai.x, kunai.y)
			if distance < @player.height/2
				@enemy_kunais.delete kunai
			end
		end

		@kunais.dup.each do |kunai|
			@enemy_kunais.dup.each do |enemy_kunai|
				distance = Gosu.distance(kunai.x+100, kunai.y-50, enemy_kunai.x, enemy_kunai.y)
				if distance < kunai.height/2
					@kunais.delete kunai
					@enemy_kunais.delete enemy_kunai
				end
			end
		end

		@kills.dup.each do |kill|
			@kills.delete kill if kill.finished
		end
		@enemy_kunais.dup.each do |kunai|
			@enemy_kunais.delete kunai unless kunai.onscreen?
		end
		@kunais.dup.each do |kunai|
			@kunais.delete kunai unless kunai.onscreen?
		end
	end

	def button_down(id)
		if id == Gosu::KbSpace
			if @kunais.count < 1+@score/10
				@kunais.push Kunai.new(self, @player.x, @player.y)
				@player.throw
			end
		end
	end

	def draw
		@player.draw
		@enemies.each do |enemy|
			enemy.draw if not(enemy.dead?)
		end
		@kunais.each do |kunai|
			kunai.draw
		end
		@enemy_kunais.each do |kunai|
			kunai.draw
		end
		@kills.each do |kill|
			kill.draw
		end
	end
end

window = NinjaHit.new
window.show