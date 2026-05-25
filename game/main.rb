LEGENDARY_GEM_HOME = File.join(Dir.home, ".legendaryos", "venvs", "legendary", "gems")

begin
    require "gosu"
rescue LoadError
    # Dodaj ścieżki z venv do $LOAD_PATH i spróbuj jeszcze raz
    venv_lib_dirs = Dir.glob(File.join(LEGENDARY_GEM_HOME, "gems", "gosu-*", "lib"))
    if venv_lib_dirs.empty?
        warn "\e[1m\e[91m✘  Gosu nie jest zainstalowany.\e[0m"
        warn "\e[90m   Uruchom: \e[1mlegendary game\e[0m\e[90m — zainstaluje automatycznie.\e[0m"
        warn "\e[90m   Lub ręcznie: GEM_HOME=#{LEGENDARY_GEM_HOME} gem install gosu\e[0m"
        exit 1
    end

    venv_lib_dirs.each { |d| $LOAD_PATH.unshift(d) unless $LOAD_PATH.include?(d) }

    # Upewnij się że rozszerzenia natywne (.so) też są widoczne
    Gem.paths = { "GEM_HOME" => LEGENDARY_GEM_HOME, "GEM_PATH" => LEGENDARY_GEM_HOME }

    begin
        require "gosu"
    rescue LoadError => e
        warn "\e[1m\e[91m✘  Nie można załadować Gosu z venv: #{e.message}\e[0m"
        warn "\e[90m   GEM_HOME: #{LEGENDARY_GEM_HOME}\e[0m"
        warn "\e[90m   Spróbuj: GEM_HOME=#{LEGENDARY_GEM_HOME} gem install gosu\e[0m"
        exit 1
    end
end

# ── Constants ──────────────────────────────────────────────────────────────
WINDOW_W     = 900
WINDOW_H     = 540
GAME_TITLE   = "LegendaryOS — Phoenix Runner"
GRAVITY      = 0.55
JUMP_FORCE   = -11.5
GROUND_Y     = WINDOW_H - 80
SCROLL_SPEED_INIT = 5.0
SCROLL_ACCEL      = 0.0008
FPS          = 60

# ── Color helpers ──────────────────────────────────────────────────────────
def gosu_color(r, g, b, a = 255)
    Gosu::Color.argb(a, r, g, b)
end

PALETTE = {
    bg_top:        gosu_color(10,   0,  28),
    bg_bottom:     gosu_color( 5,   0,  50),
    ground:        gosu_color(30,   0,  80),
    ground_line:   gosu_color(90,   0, 200),
    phoenix_body:  gosu_color(200,   0, 255),
    phoenix_wing:  gosu_color(100,  80, 255),
    phoenix_eye:   gosu_color(255, 240,   0),
    obstacle:      gosu_color( 80,   0, 200),
    obstacle_glow: gosu_color(160,  30, 255, 120),
    particle_a:    gosu_color(255,  60, 200),
    particle_b:    gosu_color( 80, 160, 255),
    star:          gosu_color(180, 140, 255, 160),
    ui_text:       gosu_color(220, 180, 255),
    ui_accent:     gosu_color(255,  30, 220),
    grid_line:     gosu_color(40,   0, 100, 60),
    flash:         gosu_color(255, 100, 255, 60),
    }.freeze

# ── Particle ───────────────────────────────────────────────────────────────
class Particle
    attr_reader :dead

    def initialize(x, y, vx, vy, life, color, size)
        @x, @y   = x.to_f, y.to_f
        @vx, @vy = vx.to_f, vy.to_f
        @life    = @max_life = life.to_f
        @color   = color
        @size    = size.to_f
        @dead    = false
    end

    def update
        @x    += @vx
        @y    += @vy
        @vy   += 0.12
        @vx   *= 0.96
        @life -= 1
        @dead  = @life <= 0
    end

    def draw
        alpha = ((@life / @max_life) * 255).clamp(0, 255).to_i
        c = Gosu::Color.argb(alpha, @color.red, @color.green, @color.blue)
        s = @size * (@life / @max_life)
        Gosu.draw_rect(@x - s / 2, @y - s / 2, s, s, c, 3)
    end
end

# ── Star ───────────────────────────────────────────────────────────────────
class Star
    def initialize
        reset(rand(WINDOW_W))
    end

    def reset(x = 0)
        @x    = x
        @y    = rand(WINDOW_H - 120).to_f
        @spd  = rand(0.3..1.2)
        @size = rand(1..3)
        @twinkle = rand(40..120)
        @t    = rand(@twinkle)
    end

    def update(scroll)
        @x -= @spd * (scroll / SCROLL_SPEED_INIT)
        @t += 1
        reset if @x < -4
    end

    def draw
        alpha = (140 + (Math.sin(@t.to_f / @twinkle * 2 * Math::PI) * 80)).clamp(40, 220).to_i
        c = Gosu::Color.argb(alpha, 180, 140, 255)
        Gosu.draw_rect(@x, @y, @size, @size, c, 0)
    end
end

# ── Obstacle ───────────────────────────────────────────────────────────────
class Obstacle
    WIDTHS  = [18, 24, 14].freeze
    HEIGHTS = [38, 55, 70, 45, 90].freeze

    attr_reader :x, :y, :w, :h, :passed

    def initialize(scroll_speed)
        @w    = WIDTHS.sample
        @h    = HEIGHTS.sample
        @x    = WINDOW_W + 20.0
        @y    = (GROUND_Y - @h).to_f
        @spd  = scroll_speed
        @passed = false
    end

    def update(scroll_speed)
        @spd = scroll_speed
        @x  -= @spd
    end

    def pass!
        @passed = true
    end

    def offscreen?
        @x + @w < -10
    end

    def hitbox
        { x: @x + 3, y: @y + 3, w: @w - 6, h: @h - 6 }
    end

    def draw
        glow_pad = 8
        Gosu.draw_rect(@x - glow_pad, @y - glow_pad,
                       @w + glow_pad * 2, @h + glow_pad * 2,
                       PALETTE[:obstacle_glow], 1)
        Gosu.draw_rect(@x, @y, @w, @h, PALETTE[:obstacle], 2)
        Gosu.draw_rect(@x, @y, @w, 3, gosu_color(160, 60, 255), 2)
        step = 12
        step.step(@h - step, step) do |oy|
            Gosu.draw_rect(@x, @y + oy, @w, 1, gosu_color(50, 0, 120, 80), 2)
        end
    end
end

# ── Phoenix (player) ───────────────────────────────────────────────────────
class Phoenix
    BODY_W = 38
    BODY_H = 28

    attr_reader :x, :y, :alive

    def initialize
        @x         = 120.0
        @y         = (GROUND_Y - BODY_H).to_f
        @vy        = 0.0
        @alive     = true
        @on_ground = true
        @wing_t    = 0
        @flash_t   = 0
    end

    def jump
        return unless @on_ground

        @vy = JUMP_FORCE
        @on_ground = false
    end

    def update(particles)
        @wing_t += 1
        @vy += GRAVITY
        @y  += @vy

        if @y >= GROUND_Y - BODY_H
            @y  = GROUND_Y - BODY_H
            @vy = 0.0
            @on_ground = true
        end

        if rand < 0.55
            col = rand < 0.5 ? PALETTE[:particle_a] : PALETTE[:particle_b]
            particles << Particle.new(
                @x + rand(8),
                @y + BODY_H * 0.6 + rand(8),
                rand(-2.5..-0.5),
                rand(-1.5..0.5),
                rand(14..28).to_f,
                col,
                rand(3..7).to_f
            )
        end

        @flash_t -= 1 if @flash_t > 0
    end

    def die!
        @alive   = false
        @flash_t = 12
    end

    def hitbox
        pad = 6
        { x: @x + pad, y: @y + pad, w: BODY_W - pad * 2, h: BODY_H - pad * 2 }
    end

    def draw
        if @flash_t > 0
            alpha = (@flash_t * 15).clamp(0, 180)
            Gosu.draw_rect(@x - 10, @y - 10, BODY_W + 20, BODY_H + 20,
                           Gosu::Color.argb(alpha, 255, 100, 255), 4)
        end

        wing_offset = (Math.sin(@wing_t * 0.25) * 7).to_i
        draw_wing(@x - 4, @y - 14 + wing_offset, 30, 14, flipped: false)
        draw_wing(@x - 4, @y + BODY_H - 4 - wing_offset, 30, 12, flipped: true)
        Gosu.draw_rect(@x, @y, BODY_W, BODY_H, PALETTE[:phoenix_body], 2)
        Gosu.draw_rect(@x + BODY_W - 9, @y + 8, 5, 5, PALETTE[:phoenix_eye], 3)
        Gosu.draw_rect(@x + BODY_W, @y + 10, 8, 4, gosu_color(255, 180, 0), 3)
    end

    private

    def draw_wing(wx, wy, ww, wh, flipped:)
        Gosu.draw_rect(wx, wy, ww, wh, PALETTE[:phoenix_wing], 2)
        tip_x = wx - 10
        tip_y = flipped ? wy + wh - 6 : wy
        Gosu.draw_rect(tip_x, tip_y, 12, 6, gosu_color(130, 100, 255), 2)
    end
end

# ── Ground ─────────────────────────────────────────────────────────────────
class Ground
    def initialize
        @offset = 0.0
        @tile   = 60
    end

    def update(speed)
        @offset = (@offset + speed) % @tile
    end

    def draw
        Gosu.draw_rect(0, GROUND_Y, WINDOW_W, WINDOW_H - GROUND_Y,
                       PALETTE[:ground], 1)
        Gosu.draw_rect(0, GROUND_Y, WINDOW_W, 3, PALETTE[:ground_line], 1)
        x = -@offset
        while x < WINDOW_W
            Gosu.draw_rect(x, GROUND_Y + 3, 1, WINDOW_H - GROUND_Y - 3,
                           gosu_color(60, 0, 140, 80), 1)
            x += @tile
        end
    end
end

# ── HUD ────────────────────────────────────────────────────────────────────
class Hud
    def initialize
        @font_lg = Gosu::Font.new(36, bold: true)
        @font_sm = Gosu::Font.new(20)
        @font_xs = Gosu::Font.new(15)
    end

    def draw_game(score, hi, speed)
        @font_lg.draw_text("#{score}", WINDOW_W - 140, 18, 5,
                           1, 1, PALETTE[:ui_accent])
        @font_xs.draw_text("SCORE", WINDOW_W - 140, 10, 5,
                           1, 1, PALETTE[:ui_text])
        @font_sm.draw_text("BEST #{hi}", WINDOW_W - 140, 56, 5,
                           1, 1, PALETTE[:ui_text])
        bar_w = 120
        spd_n = ((speed - SCROLL_SPEED_INIT) / 10.0).clamp(0.0, 1.0)
        Gosu.draw_rect(WINDOW_W - 145, 82, bar_w, 6, gosu_color(40, 0, 80), 5)
        Gosu.draw_rect(WINDOW_W - 145, 82, (bar_w * spd_n).to_i, 6,
                       PALETTE[:ui_accent], 5)
        @font_xs.draw_text("SPD", WINDOW_W - 145, 90, 5,
                           1, 1, PALETTE[:ui_text])
        @font_xs.draw_text("LegendaryOS", 14, 10, 5,
                           1, 1, gosu_color(100, 50, 180, 140))
    end

    def draw_menu(hi)
        overlay(180)
        cx = WINDOW_W / 2
        @font_lg.draw_text_rel("⚡ PHOENIX RUNNER", cx, 140, 6,
                               0.5, 0.5, 1, 1, PALETTE[:ui_accent])
        @font_sm.draw_text_rel("LegendaryOS Edition", cx, 185, 6,
                               0.5, 0.5, 1, 1, PALETTE[:ui_text])
        @font_sm.draw_text_rel("Spacja / ↑ — skocz", cx, 280, 6,
                               0.5, 0.5, 1, 1, gosu_color(180, 140, 255))
        @font_sm.draw_text_rel("Naciśnij dowolny klawisz aby zacząć", cx, 320, 6,
                               0.5, 0.5, 1, 1, PALETTE[:ui_text])
        @font_sm.draw_text_rel("BEST: #{hi}", cx, 380, 6,
                               0.5, 0.5, 1, 1, PALETTE[:ui_accent]) if hi > 0
        @font_xs.draw_text_rel("ESC — wyjście", cx, WINDOW_H - 30, 6,
                               0.5, 0.5, 1, 1, gosu_color(100, 80, 160))
    end

    def draw_gameover(score, hi)
        overlay(160)
        cx = WINDOW_W / 2
        @font_lg.draw_text_rel("GAME OVER", cx, 190, 6,
                               0.5, 0.5, 1, 1, gosu_color(255, 60, 180))
        @font_sm.draw_text_rel("Wynik: #{score}", cx, 260, 6,
                               0.5, 0.5, 1, 1, PALETTE[:ui_accent])
        @font_sm.draw_text_rel("Rekord: #{hi}", cx, 295, 6,
                               0.5, 0.5, 1, 1, PALETTE[:ui_text])
        @font_sm.draw_text_rel("Spacja — zagraj ponownie", cx, 360, 6,
                               0.5, 0.5, 1, 1, gosu_color(180, 140, 255))
        @font_xs.draw_text_rel("ESC — wyjście", cx, 410, 6,
                               0.5, 0.5, 1, 1, gosu_color(100, 80, 160))
    end

    private

    def overlay(alpha)
        Gosu.draw_rect(0, 0, WINDOW_W, WINDOW_H,
                       Gosu::Color.argb(alpha, 5, 0, 20), 5)
    end
end

# ── Background ─────────────────────────────────────────────────────────────
class Background
    def draw
        row_h = 4
        rows  = (GROUND_Y / row_h).ceil
        rows.times do |i|
            t = i.to_f / rows
            r = (10 + t * 20).to_i
            b = (28 + t * 22).to_i
            Gosu.draw_rect(0, i * row_h, WINDOW_W, row_h, gosu_color(r, 0, b), 0)
        end
        (1..6).each do |i|
            y = (GROUND_Y * i / 7.0).to_i
            Gosu.draw_rect(0, y, WINDOW_W, 1, PALETTE[:grid_line], 0)
        end
    end
end

# ── Main Window ────────────────────────────────────────────────────────────
class PhoenixRunnerWindow < Gosu::Window
    def initialize
        super(WINDOW_W, WINDOW_H, false)
        self.caption = GAME_TITLE

        @bg       = Background.new
        @hud      = Hud.new
        @hi_score = load_hi_score

        reset_game
        @state = :menu
    end

    def update
        case @state
        when :menu     then update_menu
        when :playing  then update_playing
        when :gameover then update_gameover
        end
        @stars.each { |s| s.update(@scroll_speed) }
    end

    def draw
        @bg.draw
        @stars.each(&:draw)
        @ground.draw

        case @state
        when :menu
            @phoenix.draw
            @hud.draw_menu(@hi_score)
        when :playing
            @obstacles.each(&:draw)
            @particles.each(&:draw)
            @phoenix.draw
            @hud.draw_game(@score, @hi_score, @scroll_speed)
        when :gameover
            @obstacles.each(&:draw)
            @particles.each(&:draw)
            @phoenix.draw
            @hud.draw_game(@score, @hi_score, @scroll_speed)
            @hud.draw_gameover(@score, @hi_score)
        end
    end

    def button_down(id)
        close if id == Gosu::KB_ESCAPE

        case @state
        when :menu     then start_game if jump_key?(id)
        when :playing  then @phoenix.jump if jump_key?(id)
        when :gameover then start_game if id == Gosu::KB_SPACE
        end
    end

    private

    def start_game
        reset_game
        @state = :playing
    end

    def reset_game
        @phoenix      = Phoenix.new
        @ground       = Ground.new
        @obstacles    = []
        @particles    = []
        @stars        = Array.new(70) { Star.new }
        @score        = 0
        @frame        = 0
        @scroll_speed = SCROLL_SPEED_INIT
        @spawn_timer  = spawn_interval
    end

    def update_menu
        @phoenix.update(@particles)
        @particles.reject!(&:dead)
        @particles.each(&:update)
        @ground.update(SCROLL_SPEED_INIT)
    end

    def update_playing
        @frame        += 1
        @scroll_speed += SCROLL_ACCEL
        @score         = @frame / 6

        @ground.update(@scroll_speed)
        @phoenix.update(@particles)

        @spawn_timer -= 1
        if @spawn_timer <= 0
            @obstacles << Obstacle.new(@scroll_speed)
            @spawn_timer = spawn_interval
        end

        @obstacles.each { |o| o.update(@scroll_speed) }
        @obstacles.reject!(&:offscreen?)

        @obstacles.each { |o| o.pass! if !o.passed && o.x + o.w < @phoenix.x }

        @particles.each(&:update)
        @particles.reject!(&:dead)

        ph = @phoenix.hitbox
        @obstacles.each do |o|
            ob = o.hitbox
            next unless rects_overlap?(ph, ob)

            @phoenix.die!
            @hi_score = [@score, @hi_score].max
            save_hi_score(@hi_score)
            @state = :gameover
            break
        end
    end

    def update_gameover
        @particles.each(&:update)
        @particles.reject!(&:dead)
        @phoenix.update(@particles)
    end

    def rects_overlap?(a, b)
        a[:x] < b[:x] + b[:w] &&
                a[:x] + a[:w] > b[:x] &&
                a[:y] < b[:y] + b[:h] &&
                a[:y] + a[:h] > b[:y]
    end

    def spawn_interval
        base      = 90
        min       = 38
        spd_bonus = ((@scroll_speed - SCROLL_SPEED_INIT) * 2.5).to_i
        [base - spd_bonus, min].max + rand(30)
    end

    def jump_key?(id)
        [Gosu::KB_SPACE, Gosu::KB_UP, Gosu::KB_W].include?(id)
    end

    HI_FILE = File.join(Dir.home, ".legendaryos", "game_hiscore.txt")

    def load_hi_score
        return 0 unless File.exist?(HI_FILE)
        File.read(HI_FILE).to_i
    rescue StandardError
        0
    end

    def save_hi_score(score)
        require "fileutils"
        FileUtils.mkdir_p(File.dirname(HI_FILE))
        File.write(HI_FILE, score.to_s)
    rescue StandardError
        nil
    end
end

# ── Entry point ────────────────────────────────────────────────────────────
require "fileutils"
PhoenixRunnerWindow.new.show
