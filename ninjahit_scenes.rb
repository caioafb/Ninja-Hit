require 'gosu'
require_relative 'player'
require_relative 'player2'
require_relative 'enemy'
require_relative 'kunai'
require_relative 'ekunai'
require_relative 'kill'
require_relative 'death'
require_relative 'gameover'

class NinjaHit < Gosu::Window
	WIDTH = 1280
	HEIGHT = 720
	ENEMY_FREQUENCY = 0.005
	LIVES = 3
	def initialize
		super(WIDTH,HEIGHT)
		self.caption = 'Ninja Hit'
		@background_image = Gosu::Image.new('images/background_start.png')
		@scene = :start
		@start_music = Gosu::Song.new('sounds/intro.ogg')
		@start_music.play(true)
	end

	def initialize_game
		@background_image = Gosu::Image.new('images/background_game.jpg')
		@player = Player.new(self)
		@enemies = []
		@kunais = []
		@enemy_kunais = []
		@kills = []
		@counter = 0
		@ninjas_killed = 0
		@score = 0
		@scene = :game
		@player_life = LIVES
		@font = Gosu::Font.new(30)
		@game_music = Gosu::Song.new('sounds/game.ogg')
		@game_music.play(true)
		@collide_sound = Gosu::Sample.new('sounds/collide.ogg')
		@death_sound = Gosu::Sample.new('sounds/death1.ogg')
		@hurt_sound = Gosu::Sample.new('sounds/hurt.ogg')
		@player_death_sound = Gosu::Sample.new('sounds/player_death.ogg')
		@throw_sound = Gosu::Sample.new('sounds/throw.ogg')
	end

	def initialize_game2
		@background_image= Gosu::Image.new('images/background_game2.jpg')
		@player = Player.new(self)
		@player2 = Player2.new(self)
		@kunais = []
		@enemy_kunais = []
		@ninjas_killed = 0
		@scene = :game2
		@player_life = LIVES
		@player2_life = LIVES
		@font = Gosu::Font.new(30)
		@game2_music = Gosu::Song.new('sounds/game.ogg')
		@game2_music.play(true)
		@collide_sound = Gosu::Sample.new('sounds/collide.ogg')
		@enemy_hurt_sound = Gosu::Sample.new('sounds/death1.ogg')
		@death_sound = Gosu::Sample.new('sounds/death0.ogg')
		@hurt_sound = Gosu::Sample.new('sounds/hurt.ogg')
		@player_death_sound = Gosu::Sample.new('sounds/player_death.ogg')
		@throw_sound = Gosu::Sample.new('sounds/throw.ogg')
	end

	def initialize_end
		if @ninjas_killed > 50
			@message = "BLACK BELT!"
			@message2 = "Bad ass! You defeated #{@ninjas_killed} evil ninjas. CONGRATS!"
		elsif @ninjas_killed > 35
			@message = "Red belt!"
			@message2 = "You defeated #{@ninjas_killed} evil ninjas. Awesome!"
		elsif @ninjas_killed > 20
			@message = "Green belt!"
			@message2 = "You defeated #{@ninjas_killed} evil ninjas. Pretty good!"
		elsif @ninjas_killed > 10
			@message = "Yellow belt"
			@message2 = "#{@ninjas_killed} kills, you have much to improve. Keep working."
		elsif @ninjas_killed >= 0
			@message = "White belt..."
			@message2 = "#{@ninjas_killed} ninjas? You can do better than this."
		elsif @ninjas_killed == -1
			@message = "Player 1 won!"
			@message2 = "Congratulations o/"
		elsif @ninjas_killed == -2
			@message = "Player 2 won!"
			@message2 = "Congratulations o/"
		end
		@bottom_message = "Press P to play again, or Q to quit."
		@message_font = Gosu::Font.new(28)
		@font = Gosu::Font.new(30)
		@credits = []
		y = 700
		File.open('credits.txt').each do |line|
			@credits.push(Gameover.new(self,line.chomp,100,y))
			y+=30
		end
		@scene = :end
		@end_music = Gosu::Song.new('sounds/gameover.ogg')
		@end_music.play(true)
	end

	def update
		case @scene
		when :game
			update_game
		when :game2
			update_game2
		when :end
			update_end
		end
	end

	def update_game
		@player.move_up if button_down?(Gosu::KbW)
		@player.move_down if button_down?(Gosu::KbS)
		if @counter < 1+@ninjas_killed/5
			@enemies.push Enemy.new(self, @ninjas_killed)
			@counter += 1
		end
		@enemies.each do |enemy|
			enemy.move
			if rand < ENEMY_FREQUENCY+(@ninjas_killed/2000.0) && not(enemy.dead?) && not(enemy.start?)
				@enemy_kunais.push Ekunai.new(self, enemy.x, enemy.y)
				enemy.throw
				@throw_sound.play
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
					@counter -= 1
					@ninjas_killed += 1
					@score += 10 + (@ninjas_killed).to_i
					@death_sound.play
				end
			end
		end
		@enemy_kunais.dup.each do |kunai|
			distance = Gosu.distance(@player.x+@player.width/2-20, @player.y-@player.height/2+8, kunai.x, kunai.y)
			if distance < @player.height/2 && @player_life > 0
				@enemy_kunais.delete kunai
				@player_life -= 1 if not(@player.hurt?)
				@player.hurt if @player_life > 0
				@death = Death.new(self, @player.x, @player.y) if @player_life == 0
				if @player_life > 0
					@hurt_sound.play
				else
					@player_death_sound.play
				end
			end
		end

		@kunais.dup.each do |kunai|
			@enemy_kunais.dup.each do |enemy_kunai|
				distance = Gosu.distance(kunai.x+100, kunai.y-50, enemy_kunai.x, enemy_kunai.y)
				if distance < kunai.height/2
					@kunais.delete kunai
					@enemy_kunais.delete enemy_kunai
					@collide_sound.play
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
		initialize_end if @player_life == 0 && @death.finished
	end

	def update_game2
		@player.move_up if button_down?(Gosu::KbW)
		@player.move_down if button_down?(Gosu::KbS)
		@player2.move_up if button_down?(Gosu::KbUp) || button_down?(Gosu::KbNumpad8)
		@player2.move_down if button_down?(Gosu::KbDown) || button_down?(Gosu::KbNumpad5)
		@kunais.each do |kunai|
			kunai.move
		end
		@enemy_kunais.each do |kunai|
			kunai.move
		end
		
		@kunais.dup.each do |kunai|
			distance = Gosu.distance(@player2.x, (@player2.y+@player2.height/2-10), kunai.x, kunai.y)
			if distance < @player2.height/2 && @player2_life > 0
				@kunais.delete kunai
				@player2_life -= 1 if not(@player2.hurt?)
				@player2.hurt if @player2_life > 0
				@death2 = Kill.new(self, @player2.x, @player2.y) if @player2_life == 0
				initialize_end if @player_life2 == 0 && @death2.finished
				@ninjas_killed = -1 if @player2_life == 0
				if @player2_life == 0
					@death_sound.play
				else
					@enemy_hurt_sound.play
				end
			end
		end

		@enemy_kunais.dup.each do |kunai|
			distance = Gosu.distance(@player.x+@player.width/2-20, @player.y-@player.height/2+8, kunai.x, kunai.y)
			if distance < @player.height/2 && @player_life > 0
				@enemy_kunais.delete kunai
				@player_life -= 1 if not(@player.hurt?)
				@player.hurt if @player_life > 0
				@death = Death.new(self, @player.x, @player.y) if @player_life == 0
				initialize_end if @player_life == 0 && @death.finished
				@ninjas_killed = -2 if @player_life == 0
				if @player_life == 0
					@player_death_sound.play
				else
					@hurt_sound.play
				end
			end
		end

		@kunais.dup.each do |kunai|
			@enemy_kunais.dup.each do |enemy_kunai|
				distance = Gosu.distance(kunai.x+100, kunai.y-50, enemy_kunai.x, enemy_kunai.y)
				if distance < kunai.height/2
					@kunais.delete kunai
					@enemy_kunais.delete enemy_kunai
					@collide_sound.play
				end
			end
		end

		@enemy_kunais.dup.each do |kunai|
			@enemy_kunais.delete kunai unless kunai.onscreen?
		end
		@kunais.dup.each do |kunai|
			@kunais.delete kunai unless kunai.onscreen?
		end
		initialize_end if (@player_life == 0 || @player2_life == 0)
	end

	def update_end
		@credits.each do |credit|
			credit.move
		end
		if @credits.last.y < 150
			@credits.each do |credit|
				credit.reset
			end
		end
	end

	def button_down(id)
		case @scene
		when :start
			button_down_start(id)
		when :game
			button_down_game(id)
		when :game2
			button_down_game2(id)
		when :end
			button_down_end(id)
		end
	end

	def button_down_start(id)
		if id == Gosu::Kb1 || id == Gosu::KbNumpad1
			initialize_game
		elsif id == Gosu::Kb2 || id == Gosu::KbNumpad2
			initialize_game2
		end
	end

	def button_down_game(id)
		if id == Gosu::KbSpace
			if @kunais.count < 1+@ninjas_killed/10
				@kunais.push Kunai.new(self, @player.x, @player.y)
				@player.throw
				@throw_sound.play
			end
		end
	end

	def button_down_game2(id)
		if id == Gosu::KbSpace
			if @kunais.count < 10
				@kunais.push Kunai.new(self, @player.x, @player.y)
				@player.throw
				@throw_sound.play
			end
		end
		if id == Gosu::KbNumpad0 || id == Gosu::KbP
			if @enemy_kunais.count < 10
				@enemy_kunais.push Ekunai.new(self, @player2.x, @player2.y)
				@player2.throw
				@throw_sound.play
			end
		end
	end

	def button_down_end(id)
		if id == Gosu::KbP
			initialize
		elsif id == Gosu::KbQ
			close
		end
	end

	def draw
		case @scene
		when :start
			draw_start
		when :game
			draw_game
		when :game2
			draw_game2
		when :end
			draw_end
		end
	end

	def draw_start
		@background_image.draw(0,0,0)
	end

	def draw_game
		@background_image.draw(0,0,0)
		@player.draw if @player_life > 0
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
		@death.draw if @player_life == 0
		@font.draw("Score: #{@score.to_s}", WIDTH - 200, 20, 2)
		@font.draw("Lives: #{@player_life.to_s}", 100, 20, 2)
		@font.draw("Kunais: #{1+@ninjas_killed/10}", 100, 50, 2)
	end

	def draw_game2
		@background_image.draw(0,0,0)
		@player.draw if @player_life > 0
		@player2.draw if @player2_life > 0
		@kunais.each do |kunai|
			kunai.draw
		end
		@enemy_kunais.each do |kunai|
			kunai.draw
		end
		@kill.draw if @player2_life == 0
		@death.draw if @player_life == 0
		@font.draw("Lives: #{@player2_life.to_s}", WIDTH - 200, 20, 2)
		@font.draw("Lives: #{@player_life.to_s}", 100, 20, 2)
	end

	def draw_end
		clip_to(50, 140, 700, 360) do
			@credits.each do |credit|
				credit.draw
			end
		end
		draw_line(0,140,Gosu::Color::RED,WIDTH,140,Gosu::Color::RED)
		if @ninjas_killed > 40
			@message_font.draw(@message,40,41,1,1,1,Gosu::Color::GRAY)
		elsif @ninjas_killed > 30
			@message_font.draw(@message,40,41,1,1,1,Gosu::Color::RED)
		elsif @ninjas_killed > 20
			@message_font.draw(@message,40,41,1,1,1,Gosu::Color::GREEN)
		elsif @ninjas_killed > 10
			@message_font.draw(@message,40,41,1,1,1,Gosu::Color::YELLOW)
		else
			@message_font.draw(@message,40,41,1,1,1,Gosu::Color::WHITE)
		end
		@message_font.draw(@message2,40,75,1,1,1,Gosu::Color::FUCHSIA)
		draw_line(0,500,Gosu::Color::RED,WIDTH,500,Gosu::Color::RED)
		@message_font.draw(@bottom_message,180,540,1,1,1,Gosu::Color::AQUA)
		@font.draw("Score: #{@score.to_s}", WIDTH - 200, 20, 2)
	end
end
window = NinjaHit.new
window.show
