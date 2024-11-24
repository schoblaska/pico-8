pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- vhs vault: sokoban sepulcher

function _init()
  -- stop color palette from resetting
  poke(0x5f2e, 1)

  cfg = {
    max_idle = 90, -- how many frames do the monsters wait before acting?
    fog_light = 1, -- light level for tiles covered by fog of war
    max_brightness = 4,
    starting_hp = 3,
    lightmap_refresh_rate = 10,
    static_refresh_rate = 35,
    movie_refresh_rate = 35,
    starting_level = 1,
    spawn_time = 90,

    -- for debugging
    draw_lightmap = false,
    draw_cpu = false,
    global_illumination = false, -- disable lighting effects
    god_mode = false, -- immune to monster damage
    skip_title = false
  }

  -- map key
  mk = {
    player = 16,
    wall = {
      flat_e = 17,
      flat_w = 18,
      flat_s = 19,
      flat_n = 20,
      concave_ne = 33,
      concave_se = 34,
      concave_sw = 35,
      concave_nw = 36,
      convex_ne = 49,
      convex_se = 50,
      convex_sw = 51,
      convex_nw = 52,
      invisible = 53
    },
    tv = 2,
    cassette_red = 5,
    cassette_green = 3,
    cassette_blue = 4,
    door = 6,
    box = 7
  }

  color_to_monster = {
    red = "vampire",
    green = "zombie",
    blue = "ghost"
  }

  tracks = {
    eyes_in_the_dark = 2,
    dungeon = 1
  }

  sprites = {
    player = {
      d = { { 0, 44 }, { 11, 44 } },
      u = { { 33, 44 }, { 44, 44 } },
      lr = { { 66, 44 }, { 77, 44 } }
    },
    player_pushing = {
      d = { { 22, 44 }, { 22, 44 } },
      u = { { 55, 44 }, { 55, 44 } },
      lr = { { 88, 44 }, { 88, 44 } }
    },
    cassette_red = { 0, 55 },
    cassette_green = { 0, 33 },
    cassette_blue = { 0, 22 },
    floor = { 0, 0 },
    wall_horizontal = { 11, 0 }, -- horizontal
    wall_vertical = { 22, 0 }, -- vertical
    wall_concave = { 33, 0 }, -- concave corner
    wall_convex = { 0, 66 }, -- convex corner
    tv = { 0, 11 },
    tv_static = { { 0, 11 }, { 11, 11 }, { 22, 11 }, { 33, 11 } },
    tv_movies = {
      red = { { 11, 55 }, { 22, 55 }, { 33, 55 } },
      green = { { 11, 33 }, { 22, 33 }, { 33, 33 } },
      blue = { { 11, 22 }, { 22, 22 }, { 33, 22 } }
    },
    vampire = {
      d = { { 44, 55 }, { 55, 55 } },
      u = { { 66, 55 }, { 77, 55 } },
      lr = { { 88, 55 }, { 99, 55 } }
    },
    zombie = {
      d = { { 44, 33 }, { 55, 33 } },
      u = { { 66, 33 }, { 77, 33 } },
      lr = { { 99, 33 }, { 88, 33 } }
    },
    ghost = {
      d = { { 44, 22 }, { 55, 22 } },
      u = { { 66, 22 }, { 77, 22 } },
      lr = { { 88, 22 }, { 99, 22 } }
    },
    ghostwall = {
      d = { { 44, 66 }, { 55, 66 } },
      u = { { 66, 66 }, { 77, 66 } },
      lr = { { 88, 66 }, { 99, 66 } }
    },
    tv_booting = { 44, 11 },
    door_horizontal = {
      closed = { 44, 0 },
      ajar = { 55, 0 },
      open = { 66, 0 }
    },
    door_vertical = {
      closed = { 11, 66 },
      ajar = { 22, 66 },
      open = { 33, 66 }
    },
    heart_full = { 55, 11 },
    heart_empty = { 66, 11 },
    heart_animation = { { 77, 11 }, { 88, 11 }, { 99, 11 } },
    lighting_gradient = { 120, 0 },
    box = { 77, 0 },
    blood_orb_horizontal = { { 99, 44 }, { 110, 55 } },
    blood_orb_vertical = { { 110, 44 }, { 110, 33 } },
    title_logo = { 0, 77 },
    dvd = { { 110, 22 }, { 110, 66 }, { 110, 77 }, { 110, 88 } }
  }

  player = {
    type = "player",
    x = 0,
    y = 0,
    facing = "d",
    offset = { x = 0, y = 0 },
    sprites = sprites.player,
    pushing_sprites = sprites.player_pushing,
    luminosity = 3,
    frame = 0,
    anim_speed = 66,
    idle = 0
  }

  levels = {
    { x = 0, y = 0, xpad = true, ypad = true }, -- zombie_intro.png
    { x = 11, y = 0, xpad = false, ypad = false }, -- display_case.png
    { x = 22, y = 0, xpad = false, ypad = false }, -- fetch_the_box.png
    { x = 33, y = 0, xpad = false, ypad = false }, -- box_ruminations.png
    { x = 44, y = 0, xpad = false, ypad = true }, -- ghost_intro.png
    { x = 55, y = 0, xpad = false, ypad = false }, -- ghost_twins.png
    { x = 66, y = 0, xpad = true, ypad = true }, -- crowded_storeroom.png
    { x = 77, y = 0, xpad = false, ypad = false }, -- vampire_intro.png
    { x = 88, y = 0, xpad = false, ypad = false }, -- needs_a_name.png
    { x = 99, y = 0, xpad = false, ypad = false }, -- box_maze.png
    { x = 110, y = 0, xpad = false, ypad = false }, -- kitty_corner.png
    { x = 0, y = 11, xpad = false, ypad = false } -- prototype.png
  }

  door = {}
  cur_level = cfg.starting_level
  input_pause = false
  input_pause_queue = {}
  ui_frame = 0
  lightmap_refresh_frame = 0
  game_loop = false
  steps = 0
  resets = 0
  secrets = 0
  bleeding_idx = 0
  bleeding_start = 0
  cur_track = -1

  alt_pals = {}
  build_alt_pal(1, 3)
  build_alt_pal(2, 2)
  build_alt_pal(4, 0)

  update_func = wait_for_title_screen
  draw_func = draw_title_screen

  names_for_credits = shuffle({ "schoblaska", "jomch", "andy" })
end

function _update60()
  update_func()

  if not game_loop then
    return
  end

  if input_pause and input_pause.name == "death" then
  else
    update_animations(player)
  end

  for monster in all(monsters) do
    update_animations(monster)

    if monster.projectiles then
      for projectile in all(monster.projectiles) do
        update_animations(projectile)
      end
    end
  end

  for cassette in all(cassettes) do
    update_animations(cassette)

    if cassette.offset.x == 0 and cassette.offset.y == 0 and tv_at(cassette.x, cassette.y) then
      del(cassettes, cassette)
    end
  end

  for box in all(boxes) do
    update_animations(box)
  end

  for tv in all(tvs) do
    update_tv_sprite(tv)
  end

  for explosion in all(explosions) do
    explosion.frame += 1

    if explosion.frame > 15 then
      del(explosions, explosion)
    end
  end

  if door.open and door.frame and door.frame < 50 then
    door.frame += 1
  end

  if player.idle >= cfg.max_idle then
    game_tick()
    player.idle = 0
  elseif not input_pause then
    player.idle += 1
  end

  if lightmap_is_stale or lightmap_refresh_frame >= cfg.lightmap_refresh_rate then
    refresh_lightmap()
  end

  if lightmap_refresh_frame >= cfg.lightmap_refresh_rate then
    lightmap_refresh_frame = 0
  else
    lightmap_refresh_frame += 1
  end

  if won and player.offset.x == 0 and player.offset.y == 0 then
    won = false
    pause_input("won", 50)
  end
end

function _draw()
  cls()

  draw_func()

  pal({ 0, 13, 6, 7, 128, 133, 5, 134, 129, 140, 131, 11, 136, 8, 2, 1 }, 1)
  palt(1, true)

  if cfg.draw_cpu then
    draw_cpu()
  end
end

function draw_game_stats(x, y, c)
  local h = 7
  print("steps taken:   " .. steps, x, y, c)
  print("times reset:   " .. resets, x, y + h, c)
  print("secrets found: " .. secrets .. "/??", x, y + 2 * h, c)
end

function draw_credits(x, y, c)
  local h = 7

  print("a game by: " .. names_for_credits[1], x, y, c)
  print(names_for_credits[2], x + 44, y + h, c)
  print("& " .. names_for_credits[3], x + 44, y + 2 * h, c)

  print("music: pico-8 tunes vol. 1&2", x, y + 4 * h, c)
  print("by @gruber_music,", x + 8, y + 5 * h, c)
  print("@castpixel & @krajzeg", x + 20, y + 6 * h, c)
end

function draw_title_screen()
  cls(1)
  camera(0, 0)
  draw_title_logo(10, 2)
  print("press any key to continue", 10, 54, 13)
  draw_credits(10, 72, 6)
end

function draw_intro_screen()
  cls(1)
  camera(0, 0)
  draw_intro_text(10, 48, 6)
end

function draw_intro_text(x, y, c)
  local h = 7
  print("another closing shift", x + 10, y, c)
  print("at the", x + 18, y + h, c)
  print("vhs vault", x + 46, y + h, 13)
  print(".", x + 82, y + h, c)
  print("i gotta put these tapes away", x - 2, y + 3 * h, c)
  print("before i can leave...", x + 14, y + 4 * h, c)
end

function draw_dvd()
  t = time()
  dvd_sprite_index = flr(t % 4 + 1)
  bigspr(sprites.dvd[dvd_sprite_index], 5, 5)
end

function draw_end_screen()
  cls(1)
  camera(0, 0)
  draw_dvd()
  print("you win!!!", 40, 12, 12)
  print("thanks for playing :)", 20, 19, 11)
  draw_game_stats(24, 30, 10)
  draw_credits(10, 72, 15)
end

function draw_game()
  cls(1)

  local camx, camy = 0, 0

  if #explosions > 0 or input_pause and input_pause.name == "attack" then
    -- camera shake
    camx, camy = -4 + rnd(2), -2 + rnd(2)
  elseif input_pause and input_pause.name == "load_cassette" and input_pause.frame > 0 then
    camx, camy = -3 - input_pause.data[1], -1 - input_pause.data[2]
  else
    camx, camy = -3, -1
  end

  local xoff = levels[cur_level].xpad and 6 or 0
  local yoff = levels[cur_level].ypad and 5 or 0

  camera(camx - xoff, camy - yoff)

  draw_ll0()
  draw_ll1()
  draw_ll2()
  draw_ll3()

  camera(camx, camy)

  draw_ui()

  if cfg.draw_lightmap then
    camera(camx + levelxoff, camy + levelyoff)
    draw_lightmap()
  end
end

function draw_map_sprite(x, y)
  local msprite = curmget(x, y)

  if fget(msprite, 0) then
    local tile = wall_tiles[x + 1][y + 1]

    if tile then
      bigspr(tile.sprite, x, y, 0, 0, tile.flipx, tile.flipy)
    end
  elseif msprite == mk.door then
    -- door sprites
    local ds, dsfx, dsfy = {}, false, false

    if is_floor_tile(x - 1, y) then
      ds = sprites.door_vertical
    elseif is_floor_tile(x, y + 1) then
      ds = sprites.door_horizontal
    elseif is_floor_tile(x + 1, y) then
      ds = sprites.door_vertical
      dsfx = true
    else
      ds = sprites.door_horizontal
      dsfy = true
    end

    if door.open and door.frame == 50 then
      bigspr(ds.open, x, y, 0, 0, dsfx, dsfy)
    elseif door.open then
      bigspr(ds.ajar, x, y, 0, 0, dsfx, dsfy)
    else
      bigspr(ds.closed, x, y, 0, 0, dsfx, dsfy)
    end
  else
    bigspr(sprites.floor, x, y)
  end
end

function wait_for_title_screen()
  if btnp() > 0 or cfg.skip_title then
    draw_func = draw_intro_screen
    update_func = wait_for_intro_screen
  end
end

function wait_for_intro_screen()
  if btnp() > 0 or cfg.skip_title then
    cur_level = cfg.starting_level
    reset_level()
    draw_func = draw_game
    update_func = wait_for_player_movement
    game_loop = true
  end
end

function wait_for_end_screen()
  if btn() > 0 then
    draw_func = draw_title_screen
    update_func = wait_for_title_screen
  end
end

function wait_for_player_input()
  if input_pause then
    input_pause.frame += 1

    if input_pause.frame >= input_pause.duration then
      end_input_pause(input_pause)

      if #input_pause_queue > 0 then
        input_pause = input_pause_queue[1]
        del(input_pause_queue, input_pause)
      else
        input_pause = false
      end
    end
  else
    if btnp(⬆️) then
      try_player_move(0, -1)
    elseif btnp(⬇️) then
      try_player_move(0, 1)
    elseif btnp(⬅️) then
      try_player_move(-1, 0)
    elseif btnp(➡️) then
      try_player_move(1, 0)
    elseif btnp(❎) then
      sfx(0)
      resets += 1
      pause_input("reset", 50)
    end
  end
end

-- what to do when an input pause concludes
function end_input_pause(pause)
  if pause.name == "death" then
    reset_level()
  elseif pause.name == "reset" then
    reset_level(true)
  elseif pause.name == "won" then
    if cur_level < #levels then
      cur_level += 1
      reset_level()
    else
      draw_func = draw_end_screen
      update_func = wait_for_end_screen
      game_loop = false
    end
  elseif pause.name == "fade in" then
    if pause.data and pause.data.start_music then
      change_track(tracks.eyes_in_the_dark)
    end
  elseif pause.name == "damage monster" then
    del(monsters, pause.data.monster)
  end
end

function wait_for_player_movement()
  if player.offset.x == 0 and player.offset.y == 0 then
    update_func = wait_for_player_input
    player.bumping = false
    player.pushing = false
  end
end

function draw_ui()
  if ui_frame >= cfg.starting_hp * 100 then
    ui_frame = 0
  end

  for h = 1, cfg.starting_hp do
    local sprite = player.hp >= h and sprites.heart_full or sprites.heart_empty
    if bleeding_idx == h then
      local t = time()
      local dt = flr((t - bleeding_start) * 3)
      local idx = mid(1, dt, 3)
      if dt > 3 then
        bleeding_idx = 0
      end
      sprite = sprites.heart_animation[idx]
    end
    local offy = flr(ui_frame / 100) + 1 == h and 1 or 0

    bigspr(sprite, h - 1, 10, -1, offy + 3)
  end

  print("⬆️⬇️⬅️➡️ move", 71, 119, 10)
  print("❎ reset", 91, 112, 10)

  if not input_pause or not input_pause.name == "death" then
    ui_frame += 1
  end
end

function spawn_monster(type, x, y)
  local monster = {
    type = type,
    x = x,
    y = y,
    offset = { x = 0, y = 0 },
    facing = "d",
    spawning = true,
    spawning_frame = 0,
    frame = 0,
    anim_speed = 60
  }

  if type == "zombie" then
    monster.sprites = sprites.zombie
    monster.patrol_dir = { 0, -1 }
    monster.tick = function(self) wrap_monster_tick(self, zombie_tick) end
  elseif type == "ghost" then
    monster.sprites = sprites.ghost
    monster.tick = function(self) wrap_monster_tick(self, ghost_tick) end
  elseif type == "vampire" then
    monster.sprites = sprites.vampire
    monster.tick = function(self) wrap_monster_tick(self, vampire_tick) end
    monster.patrol_dir = { 0, -1 }
    monster.projectiles = {}
    monster.projectile_cooldown = 0
  end

  add(monsters, monster)
  sfx(1)
  pause_input("spawning", cfg.spawn_time)
end

function wrap_monster_tick(monster, tick)
  if monster.spawning then
    monster.spawning = false
    monster.facing = "d"
    return
  end

  if input_pause and input_pause.name == "damage monster" and input_pause.data.monster == monster then
  else
    tick(monster)
  end
end

function set_door(x, y)
  door.x = x
  door.y = y
end

function zombie_tick(zombie)
  if can_attack_player(zombie) then
    attack_player(zombie)
    return
  end

  hug_side(zombie, "left")
end

function ghost_tick(ghost)
  -- my favorite game, ghost tick: insect detective

  if can_attack_player(ghost) then
    attack_player(ghost)
    return
  end

  -- pause idle animations while ghost is standing still
  if player_sees_monster(ghost) then
    ghost.frame = false
    return
  elseif not ghost.frame then
    ghost.frame = 0
  end

  local x_dist = abs(player.x - ghost.x)
  local y_dist = abs(player.y - ghost.y)
  local can_chase_x = open_square(player.x, ghost.y) and can_move(ghost, player.x, ghost.y)
  local can_chase_y = open_square(player.y, ghost.x) and can_move(ghost, player.y, ghost.x)

  local dir = pathfind(ghost, player)
  local newx, newy = ghost.x + dir[1], ghost.y + dir[2]

  if x_dist < y_dist and can_chase_x then
    local dx = sgn(player.x - ghost.x)
    move_entity(ghost, dx * 1, 0)
  elseif y_dist == 1 and can_chase_y then
    local dy = sgn(player.y - ghost.y)
    move_entity(ghost, 0, dy * 1)
  elseif dir and projectile_at(newx, newy) then
    -- if shortest path would  walk into projectile, stand still instead of
    -- walking around it
  elseif dir and can_move(ghost, dir[1], dir[2]) then
    move_entity(ghost, dir[1], dir[2])
  end

  if is_wall(ghost.x, ghost.y) then
    ghost.sprites = sprites.ghostwall
  else
    ghost.sprites = sprites.ghost
  end
end

function vampire_tick(vampire)
  if vampire.projectile_cooldown > 0 then
    vampire.projectile_cooldown -= 1
  end

  if can_attack_player(vampire) then
    attack_player(vampire)
    return
  end

  local clear_shot = clear_shot_at_player(vampire)

  if clear_shot and #vampire.projectiles == 0 and vampire.projectile_cooldown == 0 then
    -- vampire has to spend a turn rotating if not already facing player

    if clear_shot[1] == 0 and clear_shot[2] == 1 and vampire.facing ~= "d" then
      vampire.facing = "d"
      return
    elseif clear_shot[1] == 0 and clear_shot[2] == -1 and vampire.facing ~= "u" then
      vampire.facing = "u"
      return
    elseif clear_shot[1] == 1 and clear_shot[2] == 0 and vampire.facing ~= "r" then
      vampire.facing = "r"
      return
    elseif clear_shot[1] == -1 and clear_shot[2] == 0 and vampire.facing ~= "l" then
      vampire.facing = "l"
      return
    end

    local projectile = {
      x = vampire.x + clear_shot[1],
      y = vampire.y + clear_shot[2],
      offset = { x = 0, y = 0 },
      dx = clear_shot[1],
      dy = clear_shot[2],
      speed = 2,
      anim_speed = 10,
      frame = 0,
      tick = projectile_tick,
      shooter = vampire,
      luminosity = 5
    }

    if clear_shot[1] == 0 then
      projectile.sprites = sprites.blood_orb_vertical
    else
      projectile.sprites = sprites.blood_orb_horizontal
    end

    add(vampire.projectiles, projectile)
    sfx(19)

    return
  end

  hug_side(vampire, "right")
end

function hug_side(m, side)
  pdirs = {
    l = { m.patrol_dir[2], -m.patrol_dir[1] },
    r = { -m.patrol_dir[2], m.patrol_dir[1] },
    f = { m.patrol_dir[1], m.patrol_dir[2] },
    b = { -m.patrol_dir[1], -m.patrol_dir[2] }
  }

  local dir = nil
  local turn_dir = side == "right" and pdirs.r or pdirs.l
  local turn_dir_reverse = side == "right" and pdirs.l or pdirs.r

  -- these check for a corner we just passed and may want to turn towards
  local check_x = m.x + pdirs.b[1] + turn_dir[1]
  local check_y = m.y + pdirs.b[2] + turn_dir[2]

  if can_move_or_projectile(m, turn_dir) and not open_square(check_x, check_y) then
    -- move to the right if open and there's a wall to monster's back-right
    dir = turn_dir
  elseif can_move_or_projectile(m, pdirs.f) then
    dir = pdirs.f
  elseif can_move_or_projectile(m, turn_dir_reverse) and not open_square(m.x + pdirs.f[1], m.y + pdirs.f[2]) then
    -- move to the left if open and there's a wall in front of monster
    dir = turn_dir_reverse
  elseif can_move(m, pdirs.b[1], pdirs.b[2]) then
    dir = pdirs.b
  end

  if not dir then
    return
  end

  local newx, newy = m.x + dir[1], m.y + dir[2]

  if projectile_at(newx, newy) then
    -- if _would_ walk into projectile, stand still instead of walking
    -- around it
  else
    m.patrol_dir = dir
    move_entity(m, dir[1], dir[2])
  end
end

function can_move_or_projectile(entity, dir)
  return can_move(entity, dir[1], dir[2]) or projectile_at(entity.x + dir[1], entity.y + dir[2])
end

function relative_dirs(dir)
  if dir == { 1, 0 } then
    return { l = { 0, -1 }, r = { 0, 1 }, b = { -1, 0 } }
  elseif dir == { 0, 1 } then
    return { l = { 1, 0 }, r = { -1, 0 }, b = { -1, 0 } }
  end
end

function projectile_tick(p)
  for _ = 1, p.speed do
    subt = projectile_subtick(p)

    if not subt then
      break
    end
  end
end

-- returns true if projectile is intact after this subtick
function projectile_subtick(p)
  local newx, newy = p.x + p.dx, p.y + p.dy

  if open_square(newx, newy) then
    p.x += p.dx
    p.y += p.dy
    return true
  elseif player.x == newx and player.y == newy then
    projectile_despawn(p)
    damage_player()
    return false
  elseif monster_at(newx, newy) then
    projectile_despawn(p)
    damage_monster(monster_at(newx, newy))
    return false
  else
    projectile_despawn(p)
    return false
  end
end

function projectile_despawn(p)
  sfx(20)
  p.shooter.projectile_cooldown = 3
  add(
    explosions, {
      x = p.x,
      y = p.y,
      frame = 0
    }
  )
  del(p.shooter.projectiles, p)
  lightmap_is_stale = true
end

function can_attack_player(monster)
  local dirs = { { 0, 1 }, { -1, 0 }, { 0, -1 }, { 1, 0 } }

  for dir in all(dirs) do
    if monster.x + dir[1] == player.x and monster.y + dir[2] == player.y then
      return true
    end
  end

  return false
end

function is_wall(x, y)
  return fget(curmget(x, y), 0)
end

-- returns either false or a direction to fire in
-- a clear shot must be a straight line
function clear_shot_at_player(monster)
  local dx = player.x - monster.x
  local dy = player.y - monster.y
  local has_los = line_of_sight(monster.x, monster.y, player.x, player.y)

  if dx == 0 and has_los then
    return dy > 0 and { 0, 1 } or { 0, -1 }
  elseif dy == 0 and has_los then
    return dx > 0 and { 1, 0 } or { -1, 0 }
  end

  return false
end

function attack_player(monster)
  local dx = player.x - monster.x
  local dy = player.y - monster.y

  sfx(6)

  if monster.x == player.x then
    monster.facing = dy > 0 and "d" or "u"
  else
    monster.facing = dx > 0 and "r" or "l"
  end

  monster.offset.x += dx * 5
  monster.offset.y += dy * 5
  monster.bumping = true

  damage_player()
end

function damage_player()
  -- prevents bug where player gets attacked twice while they have 1 hp,
  -- respawns, then plays the taking damage animation
  if player.hp > 0 then
    pause_input("attack", 10)
  end

  if not cfg.god_mode then
    bleeding_idx = player.hp
    bleeding_start = time()
    player.hp -= 1
  end

  if player.hp == 0 then
    pause_input("death", 150)
    player.facing = "u"
    resets += 1
    change_track(-1)
  end
end

function damage_monster(monster)
  pause_input("damage monster", 10, { monster = monster })
end

function player_sees_monster(m)
  return lightmap[m.x + 1][m.y + 1] > 0 and line_of_sight(player.x, player.y, m.x, m.y) and not is_wall(m.x, m.y)
end

function pause_input(name, duration, data)
  local pause = {
    name = name,
    frame = 0,
    duration = duration,
    data = data
  }

  if input_pause then
    add(input_pause_queue, pause)
  else
    input_pause = pause
  end
end

function can_move(entity, dx, dy)
  local newx = entity.x + dx
  local newy = entity.y + dy
  local cassette_at_dest = cassette_at(newx, newy)
  local box_at_dest = box_at(newx, newy)

  if entity.type ~= "player" and door.x == newx and door.y == newy then
    return false
  elseif open_square(newx, newy, entity.type == "player") then
    return true
  elseif cassette_at_dest and entity.type == "player" then
    return can_move(cassette_at_dest, dx, dy)
  elseif box_at_dest and entity.type == "player" then
    return can_move(box_at_dest, dx, dy)
  elseif entity.type == "cassette" then
    local tv = tv_at(newx, newy)
    return tv and not tv.on
  elseif entity.type == "ghost" then
    local is_monster = monster_at(newx, newy)
    local is_player = player.x == newx and player.y == newy
    return not is_monster and not is_player
  end

  return false
end

function open_square(x, y, can_enter_door)
  local is_tv = tv_at(x, y)
  local is_cassette = cassette_at(x, y)
  local is_box = box_at(x, y)
  local is_door = door.x == x and door.y == y

  if x < 0 or x > 10 or y < 0 or y > 10 then
    return false
  end

  if is_wall(x, y) or is_tv or is_cassette or is_box then
    return false
  end

  if is_door then
    return door.open and can_enter_door
  end

  if player.x == x and player.y == y then
    return false
  end

  local is_monster = monster_at(x, y)
  local is_projectile = projectile_at(x, y)

  if is_monster or is_projectile then
    return false
  end

  return true
end

function try_player_move(dx, dy)
  set_facing(player, dx, dy)

  if can_move(player, dx, dy) then
    player_move(dx, dy)
  else
    player.offset.x += dx * 4
    player.offset.y += dy * 4
    player.bumping = true
    sfx(5)

    local cassette = cassette_at(player.x + dx, player.y + dy)

    if cassette then
      cassette.offset.x += dx * 4
      cassette.offset.y += dy * 4
      cassette.bumping = true
    end

    local box = box_at(player.x + dx, player.y + dy)

    if box then
      box.offset.x += dx * 4
      box.offset.y += dy * 4
      box.bumping = true
    end

    local projectile = projectile_at(player.x + dx, player.y + dy)

    if projectile then
      projectile_despawn(projectile)
      damage_player()
    end

    update_func = wait_for_player_movement
  end
end

function set_facing(entity, dx, dy)
  if dx < 0 then
    entity.facing = "l"
  elseif dx > 0 then
    entity.facing = "r"
  elseif dy < 0 then
    entity.facing = "u"
  elseif dy > 0 then
    entity.facing = "d"
  end
end

function player_move(dx, dy)
  local cassette = cassette_at(player.x + dx, player.y + dy)
  local box = box_at(player.x + dx, player.y + dy)

  move_entity(player, dx, dy)
  steps += 1
  player.idle = 0

  if player.x == door.x and player.y == door.y then
    sfx(3)
    enter_door()
  end

  if cassette then
    sfx(2)
    player.pushing = true
    move_entity(cassette, dx, dy)

    if tv_at(cassette.x, cassette.y) then
      load_cassette(cassette, tv_at(cassette.x, cassette.y))
      pause_input("load_cassette", 8, { dx, dy })
    end
  end

  if box then
    sfx(2)
    player.pushing = true
    move_entity(box, dx, dy)
  end

  if not won then
    game_tick()
  end

  update_func = wait_for_player_movement
  lightmap_is_stale = true
end

function load_cassette(cassette, tv)
  sfx(18)
  tv.booting = true
  tv.on = true
  tv.lum = 3
  tv.lum_idle = 0
  tv.cas_color = cassette.color
  tv.change_lum_in = 16
  tv.change_frame_in = 30

  if all_tvs_on() then
    door.open = true
    door.frame = 0
    change_track(tracks.dungeon)
  end
end

function game_tick()
  -- ticking the projectiles first avoids the awkward situation of a monster
  -- moving into a space that's already occupied by a projectile
  for monster in all(monsters) do
    if monster.projectiles then
      for projectile in all(monster.projectiles) do
        projectile:tick()
      end
    end
  end

  for monster in all(monsters) do
    monster:tick()
  end

  for tv in all(tvs) do
    tv:tick()
  end

  lightmap_is_stale = true
end

function tv_tick(self)
  local monster_type = color_to_monster[self.cas_color]

  if self.on then
    if self.spawned == false then
      -- clockwise starting in front of the TV
      local dirs = { { 0, 1 }, { -1, 0 }, { 0, -1 }, { 1, 0 } }

      for dir in all(dirs) do
        local mx = self.x + dir[1]
        local my = self.y + dir[2]

        if monster_can_spawn(monster_type, mx, my) then
          spawn_monster(monster_type, mx, my)
          self.spawned = true
          return
        end
      end
    end
  end
end

function monster_can_spawn(type, x, y)
  if open_square(x, y) then
    return true
  elseif type == "ghost" then
    return is_wall(x, y) and not monster_at(x, y)
  end
end

function move_entity(entity, dx, dy)
  entity.bumping = false
  entity.x += dx
  entity.y += dy
  entity.offset.x = dx * -11
  entity.offset.y = dy * -11

  if entity.facing then
    set_facing(entity, dx, dy)
  end
end

function cassette_at(x, y)
  return item_at(x, y, cassettes)
end

function tv_at(x, y)
  return item_at(x, y, tvs)
end

function monster_at(x, y)
  return item_at(x, y, monsters)
end

function box_at(x, y)
  return item_at(x, y, boxes)
end

function item_at(x, y, collection)
  for item in all(collection) do
    if item.x == x and item.y == y then
      return item
    end
  end

  return false
end

function projectile_at(x, y)
  for monster in all(monsters) do
    if monster.projectiles then
      for projectile in all(monster.projectiles) do
        if projectile.x == x and projectile.y == y then
          return projectile
        end
      end
    end
  end

  return false
end

function curmget(x, y)
  curx = levels[cur_level]["x"]
  cury = levels[cur_level]["y"]
  return mget(curx + x, cury + y)
end

function load_level()
  wall_tiles = {}

  for x = 0, 10 do
    wall_tiles[x + 1] = {}

    for y = 0, 10 do
      local msprite = curmget(x, y)

      if msprite == mk.player then
        player.x = x
        player.y = y
      elseif msprite == mk.cassette_red then
        add_cassette(x, y, "red")
      elseif msprite == mk.cassette_green then
        add_cassette(x, y, "green")
      elseif msprite == mk.cassette_blue then
        add_cassette(x, y, "blue")
      elseif msprite == mk.tv then
        add(
          tvs, {
            x = x,
            y = y,
            on = false,
            spawned = false,
            lum = 5,
            tick = tv_tick,
            cas_color = nil,
            change_lum_in = 0,
            current_sprite_idx = rnd({ 1, 2, 3, 4 }),
            booting = false,
            change_frame_in = 0
          }
        )
      elseif msprite == mk.box then
        add(
          boxes, {
            x = x,
            y = y,
            offset = { x = 0, y = 0 },
            sprite = sprites.box
          }
        )
      elseif msprite == mk.door then
        set_door(x, y)
      elseif fget(msprite, 0) then
        wall_tiles[x + 1][y + 1] = wall_tile_for(x, y)
      end
    end
  end
end

function wall_tile_for(x, y)
  local sprite = 0
  local flipx = false
  local flipy = false
  local msprite = curmget(x, y)

  if msprite == mk.wall.flat_e then
    return { sprite = sprites.wall_vertical, flipx = true, flipy = false }
  elseif msprite == mk.wall.flat_w then
    return { sprite = sprites.wall_vertical, flipx = false, flipy = false }
  elseif msprite == mk.wall.flat_n then
    return { sprite = sprites.wall_horizontal, flipx = false, flipy = true }
  elseif msprite == mk.wall.flat_s then
    return { sprite = sprites.wall_horizontal, flipx = false, flipy = false }
  elseif msprite == mk.wall.concave_ne then
    return { sprite = sprites.wall_concave, flipx = true, flipy = true }
  elseif msprite == mk.wall.concave_se then
    return { sprite = sprites.wall_concave, flipx = true, flipy = false }
  elseif msprite == mk.wall.concave_sw then
    return { sprite = sprites.wall_concave, flipx = false, flipy = false }
  elseif msprite == mk.wall.concave_nw then
    return { sprite = sprites.wall_concave, flipx = false, flipy = true }
  elseif msprite == mk.wall.convex_ne then
    return { sprite = sprites.wall_convex, flipx = true, flipy = true }
  elseif msprite == mk.wall.convex_se then
    return { sprite = sprites.wall_convex, flipx = true, flipy = false }
  elseif msprite == mk.wall.convex_sw then
    return { sprite = sprites.wall_convex, flipx = false, flipy = false }
  elseif msprite == mk.wall.convex_nw then
    return { sprite = sprites.wall_convex, flipx = false, flipy = true }
  elseif msprite == mk.wall.invisible then
    return false
  else
    -- try to guess
    if is_floor_tile(x + 1, y) then
      return { sprite = sprites.wall_vertical, flipx = true, flipy = false }
    elseif is_floor_tile(x - 1, y) then
      return { sprite = sprites.wall_vertical, flipx = false, flipy = false }
    elseif is_floor_tile(x, y + 1) then
      return { sprite = sprites.wall_horizontal, flipx = false, flipy = false }
    elseif is_floor_tile(x, y - 1) then
      return { sprite = sprites.wall_horizontal, flipx = false, flipy = true }
    else
      return { sprite = sprites.wall_horizontal, flipx = false, flipy = false }
    end
  end
end

function is_floor_tile(x, y)
  if x < 0 or x > 10 or y < 0 or y > 10 then
    return false
  end

  local msprite = curmget(x, y)
  return not fget(msprite, 0) and msprite ~= mk.door
end

function add_cassette(x, y, color)
  add(
    cassettes, {
      x = x,
      y = y,
      offset = { x = 0, y = 0 },
      sprite = sprites["cassette_" .. color],
      type = "cassette",
      color = color
    }
  )
end

function next_static_idx(idx)
  return idx % 4 + 1
end

function next_movie_idx(idx)
  return idx % 3 + 1
end

function update_animations(entity)
  -- update idle animations if entity has them
  if entity.frame then
    local n_sprites = entity.facing and #entity.sprites.u or #entity.sprites

    if entity.frame >= entity.anim_speed * n_sprites - 1 then
      entity.frame = 0
    else
      entity.frame += 1
    end
  end

  if entity.spawning_frame and entity.spawning then
    entity.spawning_frame += 1
  end

  -- update offsets if entity has them
  if entity.offset then
    local speed = entity.bumping and 1 or 1.5

    if entity.offset.x > 0 then
      entity.offset.x = max(0, entity.offset.x - speed)
    elseif entity.offset.x < 0 then
      entity.offset.x = min(0, entity.offset.x + speed)
    end

    if entity.offset.y > 0 then
      entity.offset.y = max(0, entity.offset.y - speed)
    elseif entity.offset.y < 0 then
      entity.offset.y = min(0, entity.offset.y + speed)
    end
  end
end

function draw_tv(tv)
  if tv.booting then
    bigspr(sprites.tv_booting, tv.x, tv.y)
  elseif tv.on then
    bigspr(sprites.tv_movies[tv.cas_color][tv.current_sprite_idx], tv.x, tv.y)
  else
    bigspr(sprites.tv_static[tv.current_sprite_idx], tv.x, tv.y)
  end
end

function draw_entity(entity)
  if entity.spawning then
    if entity.spawning_frame < cfg.spawn_time / 4 then
      entity.facing = "d"
    elseif entity.spawning_frame < cfg.spawn_time / 2 then
      entity.facing = "r"
    elseif entity.spawning_frame < cfg.spawn_time / 4 * 3 then
      entity.facing = "u"
    elseif entity.spawning_frame < cfg.spawn_time then
      entity.facing = "l"
    else
      entity.facing = "d"
    end

    for i = 1, 15 do
      if min(entity.spawning_frame, cfg.spawn_time) < rnd(cfg.spawn_time * 1.25) then
        pal(i, rnd({ 2, 3 }))
      end
    end
  elseif input_pause and input_pause.name == "attack" and entity.type == "player" then
    for i = 1, 15 do
      pal(i, rnd({ 9, 11, 13, 14 }))
    end
  elseif input_pause and input_pause.name == "damage monster" and entity == input_pause.data.monster then
    for i = 1, 15 do
      pal(i, rnd({ 9, 11, 13, 14 }))
    end
  end

  if entity.spawning and entity.spawning_frame <= cfg.spawn_time then
    risingspr(sprite_for(entity), entity.x, entity.y, entity.facing == "r", entity.spawning_frame, cfg.spawn_time)
  else
    bigspr(sprite_for(entity), entity.x, entity.y, entity.offset.x, entity.offset.y, entity.facing == "r")
  end

  pal()
end

function draw_projectile(p)
  bigspr(sprite_for(p), p.x, p.y, p.offset.x, p.offset.y, p.dx > 0, p.dy > 0)
end

function sprite_for(entity)
  local entity_sprites = {}

  if entity.facing then
    local face = (entity.facing == "l" or entity.facing == "r") and "lr" or entity.facing

    if entity.pushing_sprites and (entity.pushing or entity.bumping) then
      entity_sprites = entity.pushing_sprites[face]
    else
      entity_sprites = entity.sprites[face]
    end
  else
    entity_sprites = entity.sprites or { entity.sprite }
  end

  if entity.frame then
    return entity_sprites[flr(entity.frame / entity.anim_speed) + 1]
  else
    return entity_sprites[1]
  end
end

function draw_title_logo(x, y)
  sspr(
    sprites.title_logo[1],
    sprites.title_logo[2],
    107,
    48,
    x,
    y
  )
end

function bigspr(sprite, x, y, offx, offy, flipx, flipy)
  offx = offx or 0
  offy = offy or 0

  sspr(
    sprite[1], sprite[2],
    11, 11,
    x * 11 + offx, y * 11 + offy,
    11, 11,
    flipx, flipy
  )
end

-- spite for a monster rising out of the ground
function risingspr(sprite, x, y, flipx, frame, total_frames)
  local h = frame / total_frames * 11
  sspr(
    sprite[1], sprite[2],
    11, h,
    x * 11,
    y * 11 + 11 - h,
    11, h,
    flipx, flipy
  )
end

function reset_level(player_reset)
  lightmap_is_stale = true
  los_cache = {}
  fogmap = {}
  lightmap = {}
  for x = 1, 11 do
    fogmap[x] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    lightmap[x] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
  end
  cassettes = {}
  tvs = {}
  monsters = {}
  boxes = {}
  explosions = {}
  door.open = false
  cls()
  won = false
  player.facing = "d"
  player.hp = cfg.starting_hp
  load_level()
  pause_input("fade in", 50, { start_music = cur_track == tracks.dungeon or not player_reset })
end

function all_tvs_on()
  for tv in all(tvs) do
    if tv.on == false then
      return false
    end
  end
  return true
end

function change_track(n)
  music(n)
  cur_track = n
end

function pathfind(froment, toent)
  local dirs = { { -1, 0 }, { 1, 0 }, { 0, 1 }, { 0, -1 } }

  for dir in all(dirs) do
    add(dir, dist(froment.x + dir[1], froment.y + dir[2], toent.x, toent.y))
  end

  -- sort by distance
  for i = 1, #dirs do
    for j = i + 1, #dirs do
      if dirs[j][3] < dirs[i][3] then
        dirs[i], dirs[j] = dirs[j], dirs[i]
      end
    end
  end

  for dir in all(dirs) do
    if can_move(froment, dir[1], dir[2]) then
      return dir
    end
  end

  return nil
end

function shuffle(array)
  for i = 1, #array do
    local j = flr(rnd(#array - 1) + 1)
    local temp = array[i]
    array[i] = array[j]
    array[j] = temp
  end

  return array
end

-- pythagoras <3
function dist(ax, ay, bx, by)
  local dx, dy = ax - bx, ay - by
  return sqrt(dx * dx + dy * dy)
end

function enter_door()
  change_track(-1)
  won = true
end

function iclamp(val, lower, upper)
  return flr(max(min(val, upper), lower))
end

function draw_cpu()
  local color = 11
  local cpu = flr(stat(1) * 100)

  if cpu > 100 then
    color = 8
  elseif cpu > 50 then
    color = 9
  end

  print("cpu: " .. cpu .. "%", 85, 120, color)
end

function update_tv_sprite(tv)
  -- get the next sprite's idx
  if tv.change_frame_in <= 0 then
    if tv.booting then
      tv.current_sprite_idx = 1
      tv.booting = false
      tv.change_frame_in = cfg.movie_refresh_rate
    elseif tv.on then
      tv.current_sprite_idx = next_movie_idx(tv.current_sprite_idx)
      tv.change_frame_in = cfg.movie_refresh_rate
    else
      -- pick the next static frame
      tv.current_sprite_idx = next_static_idx(tv.current_sprite_idx)
      tv.change_frame_in = cfg.static_refresh_rate
    end
  end

  tv.change_frame_in -= 1
end

-- lighting code below

function refresh_lightmap()
  lightmap = {}

  if cfg.global_illumination then
    local b = cfg.max_brightness - 1

    for x = 1, 11 do
      lightmap[x] = { b, b, b, b, b, b, b, b, b, b, b }
    end

    return
  end

  for x = 1, 11 do
    lightmap[x] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
  end

  add_light_source(player.luminosity, player.x, player.y)

  -- a tv with static should oscillate between 4 and 5, mostly 5
  -- a tv with a cassette should oscillate between 3 and 5, and sometimes turn off
  local on_length = function()
    return flr(rnd(10) + 12)
  end

  -- shorter than on_length
  local off_length = function()
    return flr(rnd(2) + 2)
  end

  for tv in all(tvs) do
    if not tv.change_lum_in then
      tv.change_lum_in = on_length()
    end

    if tv.change_lum_in <= 0 then
      if not tv.on then
        -- flicker between 3 and 5
        if tv.lum == 5 then
          -- ~33% chance to flicker
          if rnd(3) < 2 then
            tv.lum = 5
            tv.change_lum_in = on_length()
          else
            tv.lum = 3
            tv.change_lum_in = off_length()
          end
        else
          tv.lum = 5
          tv.change_lum_in = on_length()
        end
        tv.change_frame_in = 0
      else
        if tv.lum == 0 then
          tv.lum = rnd({ 3, 4, 5 })
          tv.change_lum_in = on_length()
        else
          -- ~33% chance to turn off
          if rnd(3) < 2 then
            tv.lum = rnd({ 3, 3, 3, 4, 4, 5 })
            tv.change_lum_in = on_length()
          else
            tv.lum = 0
            tv.change_lum_in = off_length()
          end
        end
      end
    end

    if tv.lum > 0 then
      add_light_source(tv.lum, tv.x, tv.y)
    end
    tv.change_lum_in -= 1
  end

  if door.open and door.frame and door.frame == 50 then
    add_light_source(3, door.x, door.y)
  elseif door.open then
    add_light_source(2, door.x, door.y)
  end

  for monster in all(monsters) do
    if monster.projectiles then
      for projectile in all(monster.projectiles) do
        add_light_source(projectile.luminosity, projectile.x, projectile.y)
      end
    end
  end

  for explosion in all(explosions) do
    add_light_source(10, explosion.x, explosion.y)
  end

  for x = 0, 10 do
    for y = 0, 10 do
      if line_of_sight(player.x, player.y, x, y) then
        local newfog = min(cfg.fog_light, lightmap[x + 1][y + 1])
        fogmap[x + 1][y + 1] = max(newfog, fogmap[x + 1][y + 1])
      else
        lightmap[x + 1][y + 1] = 0
      end
    end
  end

  lightmap_is_stale = false
end

function add_light_source(luminosity, lumx, lumy)
  if input_pause and input_pause.name == "death" then
    local max_bri = cfg.max_brightness - input_pause.frame / 30
    luminosity = iclamp(luminosity, 0, max_bri)
  elseif input_pause and (input_pause.name == "reset" or input_pause.name == "won") then
    local max_bri = cfg.max_brightness - input_pause.frame / 10
    luminosity = iclamp(luminosity, 0, max_bri)
  elseif input_pause and input_pause.name == "fade in" then
    local max_bri = 0 + input_pause.frame / 10
    luminosity = iclamp(luminosity, 0, max_bri)
  end

  local losx1, losx2 = max(0, lumx - luminosity - 1), min(10, lumx + luminosity + 1)
  local losy1, losy2 = max(0, lumy - luminosity - 1), min(10, lumy + luminosity + 1)

  for x = losx1, losx2 do
    for y = losy1, losy2 do
      local has_los = line_of_sight(lumx, lumy, x, y)

      if has_los then
        local lumdist = dist(lumx, lumy, x, y)
        local bri = max(0, min(ceil(luminosity - lumdist), cfg.max_brightness))

        lightmap[x + 1][y + 1] = max(bri, lightmap[x + 1][y + 1])
      else
        lightmap[x + 1][y + 1] = max(0, lightmap[x + 1][y + 1])
      end
    end
  end
end

-- light layer 0
-- acitvely lit map tiles
function draw_ll0()
  local lastpal = 0

  for x = 0, 10 do
    for y = 0, 10 do
      local bri = lightmap[x + 1][y + 1]

      if bri > 0 then
        if lastpal ~= bri then
          swap_pal(bri)
        end

        draw_map_sprite(x, y)
      end
    end
  end

  pal()
end

-- light layer 1
-- entities and objects
function draw_ll1()
  for cassette in all(cassettes) do
    swap_pal(lightmap[cassette.x + 1][cassette.y + 1])
    draw_entity(cassette)
  end

  for box in all(boxes) do
    swap_pal(lightmap[box.x + 1][box.y + 1])
    draw_entity(box, box.x, box.y)
  end

  for tv in all(tvs) do
    swap_pal(lightmap[tv.x + 1][tv.y + 1])
    draw_tv(tv)
  end

  swap_pal(lightmap[player.x + 1][player.y + 1])
  draw_entity(player)

  for monster in all(monsters) do
    swap_pal(lightmap[monster.x + 1][monster.y + 1])
    draw_entity(monster)

    for projectile in all(monster.projectiles) do
      swap_pal(lightmap[projectile.x + 1][projectile.y + 1])
      draw_projectile(projectile)
    end
  end

  pal()
end

-- light layer 2
-- obscure tiles with brightness 0
-- use dim light for previously seen tiles, pitch black for unseen tiles
function draw_ll2()
  local lastpal = 0

  for x = 0, 10 do
    for y = 0, 10 do
      local bri = lightmap[x + 1][y + 1]

      if bri == 0 then
        local fogbri = fogmap[x + 1][y + 1]

        if fogbri == 0 then
          rectfill(x * 11, y * 11, x * 11 + 11, y * 11 + 11, 1)
        else
          if lastpal ~= fogbri then
            swap_pal(fogbri)
          end
          draw_map_sprite(x, y)
        end
      end
    end
  end

  pal()
end

-- light layer 3
-- objects and entities visible in fog of war
function draw_ll3()
  local show_entity = function(e)
    return lightmap[e.x + 1][e.y + 1] == 0 and fogmap[e.x + 1][e.y + 1] > 0
  end

  for cassette in all(cassettes) do
    if show_entity(cassette) then
      swap_pal(1)
      draw_entity(cassette)
    end
  end

  for box in all(boxes) do
    if show_entity(box) then
      swap_pal(1)
      bigspr(sprites.box, box.x, box.y)
    end
  end

  for tv in all(tvs) do
    if show_entity(tv) then
      swap_pal(1)
      draw_tv(tv)
    end
  end

  for monster in all(monsters) do
    if show_entity(monster) then
      swap_pal(1)
      draw_entity(monster)
    end
  end

  pal()
end

function build_alt_pal(n, offset)
  local gxy = sprites.lighting_gradient

  alt_pals[n] = {}

  for y = 0, 16 do
    local orig = sget(gxy[1] + 1, gxy[2] + y)
    local alt = sget(gxy[1] + offset, gxy[2] + y)

    if orig ~= alt then
      add(alt_pals[n], { orig, alt })
    end
  end
end

function swap_pal(n)
  pal()

  if n == cfg.max_brightness - 1 then
    return
  end

  for swap_pair in all(alt_pals[n]) do
    pal(swap_pair[1], swap_pair[2])
  end
end

function line_of_sight(x1, y1, x2, y2)
  local cache_key = x1 .. "," .. y1 .. "," .. x2 .. "," .. y2

  if los_cache[cache_key] then
    return los_cache[cache_key] == 1 and true or false
  end

  local x3 = x2 + 0.5 * sgn(x1 - x2)
  local y3 = y2 + 0.5 * sgn(y1 - y2)
  local dx, dy = x3 - x1, y3 - y1
  local steps = max(abs(dx), abs(dy))
  local sx, sy = dx / steps, dy / steps
  local x, y = x1, y1

  for i = 1, steps do
    x += sx
    y += sy

    if is_wall(x, y) then
      if flr(x) == x3 and flr(y) == y3 then
        los_cache[cache_key] = 1
        return true
      else
        los_cache[cache_key] = 0
        return false
      end
    end
  end

  los_cache[cache_key] = 1
  return true
end

-- for debugging
function draw_lightmap()
  local colors = { 2, 2, 3, 3, 4 }

  for x = 0, 10 do
    for y = 0, 10 do
      local bri = lightmap[x + 1][y + 1]

      if not bri then
        break
      end

      print(bri, x * 11 + 4, y * 11 + 3, colors[bri + 1])
    end
  end
end

__gfx__
11161115111777777777775516657677777777777777777777777777777777777777777777777000000388007777777777755166576777000000000000000000
11951111591777777777775656517677777777777777777777777777777777777777777777777878835388877777777777756565176777000000000011110000
991151165197777777777759166576777777777777777111eee11177115eee51177511eee1157888835389887777777777759166576777000000000032790000
111151616116666667666659165176777666666677775111ddd11355115ddd51351511ddd1151888835389886666667666659165176777000000000043290000
11111111111777777777775656657677777777776777513315133155135111531515111111151899935388887777777777756566576777000000000044430000
61111911111515151551515516517677751511576777631176311766316111617656111111165888885388885151511515155165176777000000000065910000
61519111115656565669655656657777765665176777617716177166176111671656111111165899935388886565651696556511177777000000000076590000
15111919116666666666665516657677766666576777671116711166716111611656111111165888835558886666661666655166576777000000000087690000
51111191111151151515155656917677711165176777611116111166116111611656111111165777786877771511515151556569176777000000000038790000
191611115115699656565655166576777651665767775111151111551161116115151111111510677757776056996565656551665767770000000000a9110000
111161151115555555555556565176777565651767771555515555115519991551119999999110055555550055555555555565651767770000000000aaa20000
007666661000076666610000766666100007666661000076666610000000000000000000000000000000000000000000000000000000000000000000bb990000
076611111100766111111007661111110076611111100766111111000440004400004400044000044000440000440004400004400044000000000000cccb0000
777777777777777777777777777777777777777777777777777777704ee404ee40041140411400411404114004114041140041140411400000000000eddf0000
71145545117711545541177114554511771154545117711cceea1174e4ee4eeee4411114111144e11141111441111411114411114111140000000000eeed0000
71464664617716466466177146646461771466464617714cceeaa174eeeedeeee8411119111184eeeed1111841111911118411119111180000000000dff60000
61466646616616464664166164646641661446464416614cceeaa168deeeeeeed8891111111988deeeeeeed889111111ed889111111118000000000000000000
61664666416616646666166166466461661664664616614cceeaa1608ddeeedd80089911199800eddeeedd800e9911edd8008991111180000000000000000000
614666466166146646461661646446616616464466166166223311600e6dddde00008699998000de6dddde000deddddde000d869111800000000000000000000
661454541666615454516666145554166661545541666614477116600d86d6ed00000869680000dd8dd6ed000dd8dd6ed0000d86d6e000000000000000000000
166666666611666666666116666666661166666666611666666666100d0868d0000000868000000d0e68dd000dd0e68dd000000e68d000000000000000000000
01111111110011111111100111111111001111111110011111111100000080d0000000080000000d0080dd000dd0d80dd0000d0d80d000000000000000000000
0000000000000766666100007666661000076666610000a11111a0000a11111a0000a11111a0000a11111a0000a11111a0000a11111a00001444441000000000
777777777770766111111007661111110076611111100a1111111a00a1111111a00a1111111a00a1111111a00a1111199a00a1111199a0014276654100000000
761666661667777777777777777777777777777777770a9999999a00a9999999a00a9991199a00a9911999a00a9119911a00a9119911a014337765e410000000
111111111117119199911771191999117711919991170a1119411a00a1119911a00a1119911a0a211991112a0a1941111a00a1991111a04234275eca40000000
6731aaa13767911999191779119991917791199919170a1112911a00a1112911a0a211111112aa211111112a0a1291111a00a1291111a04672346ca540000000
1313a22313661111911116611119aaa16611199aaa16a311222113a0a1122211a0a211111112aa311111113a0a1122111a00a1122111a0466541456640000000
17313331376619191aaa1661aa9a111a6611a9a111a6a221323122aa311323113aa311111113a0a1111111a0a22333111a00a1133111a045ac64327640000000
1666666666661aa1a111166132a11191661a3a111916a221333122aa221333122a0a1111111a00a1111111a00a2333111a0a22333111a04ace57243240000000
111111111116633a11116666122119966663221194660a1133311a0a221333122a0a1111111a00a1111111a00a1333111a00a2333111a014e567733410000000
011111111101666666666116666166661166221199610a1133311a00a1133311a00a1111111a00a1111111a00a13131113a0a13331113a014566724100000000
000000000000111111111001111111110011121111100a1333311a00a1333311a00a1111111a00a1111111a00a1113111330a131311133001444441000000000
000000000000076c6661000076c6661000076c6661000000000000000091111900009111190000091111900000011111000000001111100000de000000000000
77777777777076c111111007661c11110076c1111110000911119900011111119009111111100091111111000111111100000011111110000feee00000000000
761666661667777c777777777777c77777777c77777700111111110001bbbbb1100111111110001111111100011bbbb110000011bbbb11000fded00000000000
11111111111711bcb99117711bbcbb117711bbcbb117001bbbbb100001bbbbb1000011111110000111111100000bbbbb10000000bbbbb10000ddf00000000000
6731bbb13767199b99991771bbcccbb1771bbcccbb17001bbbbb10092bbbbbbb29b211111112bb211111112bbb6b44b250000bb6bbbb250000ff000000000000
1313bcb31366199111991661bc111cb1661bc111cb1692b44b44b2967cbbbbbc76cbc11111cbccbc11111cbc995cbccc50000995cbccb50000f0000000000000
1731ccc13766199111991661bc111cb1661bc111cb1667cbbbbbc76bb5cbccc5bb095ccccc590095ccccc590bb6666666500bb66666650000000000000000000
166666666666191111191661b11111b1661b14141b16665cbccc566cc6555556cc0065555560000655555600cc5555665500cc555665500000e0000000000000
1111111111166111111166661c111c166661c111c166bb9666669bb00966666900009666669000096666690000000555550000005555500000d0000000000000
01111111110166666666611666666666116666666661cc0110110cc0009909900000011011000000110990000000099099000000990990000000000000000000
00000000000011111111100111111111001111111110000000000000001101100000000000000000000110000000110011000001100110000000000000000000
000bbbbb000000bbbbb000000000000000000000000000000000000088bbbbb880000bbbbbb00000bbbbbb0000bbbbbb000000000000000000de000000000000
00bb99bbb0000bb99bbb00000bbbbb000000bbbbb000000bbbbb00007bb99bbb7000bbbbb9bb000bbbbb9bb00bbbbb9bb0000000000000000feee00000000000
0bbbbbbbbb00bbbbbbbbb000bb99bbb0000bb99bbb0000bb99bbb000bbbbbbbbb00bbbbbbb9b00bbbbbbb9b0bbbbbbb9b0000000000000000fded00000000000
09bbbbbbbb009bbbbbbbb00bbbbbbbbb00bbbbbbbbb00bbbbbbbbb00bbbbbbbbb00bbbbbbbbb00bbbbbbbbb0bbb9bbbbb00000000000000000fdf00000000000
08999b99bb008999b99bb0099bbbbb9b00bbbbbbbbb00bbbbbbbb800bbbbbbbb800b9997778b00b9997778b0b9997778b000edf00000000000fd000000000000
07713713b9007731731b9008999b99bb00bbbbbbbb800bbbbbbbb7009bbbbbb97009b1388879009b138887909b138887900eeeddf0ed0000000f000000000000
097888889000078888890007713713b9009bbbbbb97009bbbbbb990019bb999110009888771000098887710079888770000dedff000000000000000000000000
088199917800091999190000788888900019bb999110019bb999110001911111000000111190000711111900811111900000ff0000000000000e000000000000
0009999900000799999780091999991900719111117001191111110000199990000007998790000009911900779999900000000000000000000d000000000000
00011011000000110110000181101181000019999000077199997700001101100000011999000000119870000011991000000000000000000000000000000000
00000000000000000000000870000078000011011000000110110000000000000000000110000000001100000000110000000000000000000000000000000000
00000000000007666661000076666610000766666100000822280000008222800000082228000000822280000022228000000222280000000000000000000000
77777777777076611111100766111111007661111110008222228000082222280000822222800008222228000033322800000333228000000000000000000000
76166666166777777777777777777777777777777777002622262000026222620000322222300003222223000366232330003662323300000000000000000000
11111111111713666231177113333311771133337117006f13f160000611311600002222222000022222220003f1623700003116237000000000000000000000
673166613767162556631771366663317717623333170023333320000233333200007eeeee700007eeeee70003332332000033323320000edf00000000000000
1313e6e3136618355253166183552631661f46662316fee24242eef0ee23332ee0ffefffffeff0eefffffee00046227eef00032227ee00eeedf0000000000000
1731fef137661de883871661d7883871661ed8f467160ffe222eff0fffe222efff0fffffffff0fffffffffff00227eeff0000227eefff0deddff0ed000000000
166666666666178888e816617e8d7d81661de88ed8160011f6f11000011f6f11000011fff11000011fff1100006ffff1000006ffff10000ff000000000000000
1111111111166188888166661e888e166661e88e8166009111119000091111190000911111900009111119000011111900000111119000000000000000000000
011111111101666666666116666666661166e66e6661091911991900919119919009191199190091911991900099191190000991911900000000000000000000
00000000000011111111100111111111001fddfdf110111111111111111111111111111111111111111111110111111111001111111110000000000000000000
5516657677715666655777156666557771155551177700a55555a0000a55555a0000a55555a0000a55555a0000a55555a0000a55555a00001444441000000000
565651767775117131117751171311177156666555770a5555555a00a5555555a00a5555555a00a5555555a00a5555566a00a5555566a0014234324100000000
591665767775111713117751117131177911111111770a6666666a00a6666666a00a6665566a00a6655666a00a6556655a00a6556655a0147724277410000000
565651776665111713117716666655577911111111770a5556455a00a5556655a00a5556655a0a355665553a0a5645555a00a5665555a0456623276540000000
551665777775111171de779111111de779111111de770a5553655a00a5553655a0a355555553aa355555553a0a5365555a00a5365555a04baa6475ed40000000
565651151511566665de779111111de779111111de77a855333558a0a5533355a0a355555553aa855555558a0a5533555a00a5533555a04ccc414ccc40000000
551619565655117131de779111111de779111111de77a335838533aa855838558aa855555558a0a5555555a0a33888555a00a5588555a04de5746aab40000000
56566666666511171311771666665557791111111177a335888533aa335888533a0a5555555a00a5555555a00a3888555a0a33888555a0456723266540000000
565151515155111713117751117131177911111111770a5588855a0a335888533a0a5555555a00a5555555a00a5888555a00a3888555a0147724277410000000
516565656565111171317751111713177156666555770a5588855a00a5588855a00a5555555a00a5555555a00a58585558a0a58885558a014234324100000000
555555555551566665577715666655777115555117770a5888855a00a5888855a00a5555555a00a5555555a00a5558555880a585855588001444441000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaa9000000000000000001444441000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaa9000000000000000014a56624100000000
00000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa90000000000000014eca6733410000000
444444444444444444444444444444444444444444440000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaccccccc90000000000000455ec5243240000000
400000000000000000000000000000000000000000040aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaacccccccccccaaaaaaa90000000000000466564327740000000
400000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaacccccccccccccaaaaaaaaaaaaaaaaaa90000000000000467741477640000000
400444440000444044440000444400000444444aaaaaaaaaaaaaaacccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa9000000000000477234656640000000
400044440000044044440000444400044444400aaaaaacccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa9000000000000423425ce5540000000
400044440000044044440000444400444300000aaaaaccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaacccccccaaa900000000000143376ace410000000
400004444000044044440000444400444000000aaaaacaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaccaaaacccccccccaaa9000000000000142665a4100000000
400004444000440044440000444404444000000aaaaacaaaaaaaaaaaaaaaaaaaaaaaaccaaaacccaacccaaaccccccccaaaa900000000000001444441000000000
400004444000440044440000444404444000000aaaaaacaaaaaaaaaccaaaacccaaaaacccaaacccaacccaaaccccccaaaaa9000000000000001444441000000000
400004444000440044440000444404444300000aaaaaacaaccaaaacccaaacccccaaaacccaaacccaacccaaaaaacccaaaaaa9000000000000145dcb54100000000
400000444400440044440000444404444444444aaaaaacaacccaaacccaaccccccaaaacccaaacccaacccaaaaaacccaaaaaa9000000000001476eca67410000000
40000044440044004444000044440044444444499aaaacaacccaaacccaacccacccaaacccaaacccaacccaaaaaacccaaaaaa90000000000042775ca67240000000
4000004444004400444400004444000444444444499aacaacccaaaccaaacccacccaaacccaaacccaacccaaaaaacccaaaaaa900000000000432274622340000000
40000004440440004444444444440000000034444009acaaacccacccaaacccacccaaacccaaacccaacccaaaaaacccaaaaa9000000000000444341434440000000
40000004440440044444444444440000000004444009acaaacccacccaaacccccccaaacccaaacccaaccccaaaaacccaaaaa9000000000000432264722340000000
40000004444440003444000044440000000004444009acaaacccacccaaaccccccccaaccccaacccaacccccccaacccaaaaa90000000000004276ac577240000000
40000004444430004444000044440000000004440009acaaacccacccaaacccaacccaacccccccccaacccccccaacccaaaa900000000000001476ace67410000000
4000000044430000444400004444000000003944000aacaaaaccccccaacccaaacccaaacccccccaaacc9ccccaaaaaaaaa900000000000000145bcd54100000000
4000000044444000444400004444044444449e9000aaacaaaacccccaaacc99aacccaaaaaccccaaaaa9e9aaaaaaaaaaaa00000000000000001444441000000000
4000000044449999994400004444000444449e90aaaaaacaaaaccccaaac9ee99cccaaaaaaaaaaaaa9eee9aaaaaaaaaaaa0900000000000000000000000000000
400000000009eeeee90000099000000000009e90aaaaaac999aaccaa999effee9aaaaaaaaaaaaaaa9e9e9aaaaaaaaaaaa9e90000000000000000000000000000
40000000009eeff99000009ee900000000099e909999aa9eee9aaaa9ee9e99fe9aaaaaa99aaaaaaa9eae9aaaaacccccc9efe9000000000000000000000000000
4444444449eef9944444449de94444444449eee9eee9a9ee9ee9aa9efdef99fe9aaaaa9ee9aaaaac9ecf9ccccca9aaa9ef9e9000090000000000000000000000
0000000009ef90000000009de909e9099e09edeef9fe99ef9ee9aa9e9dd9aa9e9acccc9e9e9cccca9eaf9aaaaa9e9aa9e99e90009e9000000000000000000000
000000009ed900000000009de99edf9eefe9efef9a9e9ef99de9a9ef9dd9cc9e9caaaa9e9e9aaaaa9e9f9aaaa9efe999e90e90009e9000000000000000000000
000000009ed900000000009de9eff90ef9fee9ef9a9e9ef9cdd9c9e9a9d9aa9d9aaaaa9e9e9aaaa999ee999999e9e909e90e9009ef9000000000000000000000
000000009ed999900099909fdef9909e909ef9e90a9e9de99efe99e9a9f9aa9dd999999e9e999990909e9eee09e9e909f90fe99ef90000000000000000000000
000000009eeeeee909eee909dde909ee909ed9d909ed9de9effdeed999f9999fdee9009e0e90099ee99e9f9fe9eff90e9009feff900000000000000000000000
000000009fdeeee909effe99dffe99ee909ed9de0edfdddef99ddd9000900009ff90009e0e909eefff9ee999e09e999f9009fff9000000000000000000000000
0000000009ffffde9ef99e99d99fd9ddd99df9fdddf999fff9099900099900099900909e0f909ef9990fe909e09eeef900009990000000000000000000000000
00000000009999de9e909e99d909ddd9d9dd909fff9000999000000099ee999e9009e909ef909ef90099e909feef999000000000000000000000000000000000
00000000000009dd9e909d99d909fd90fddf90099900099ee90099909efffe9e9009e909ef909ef909e9e909fff9000000000000000000000000000000000000
00000000000009dd9e909d99d9009f909ff9000000009efffe99eee9ee999e9e9009e909e9009e9009efe9009990000000000000000000000000000000000000
0000000090009dd99d999d99f9000900099000000009ef999f9ef9e99e909e9e9009e909ee99efe99efff9000000000000000000000000000000000000000000
00000009d9999dd99ddddf9090000000000000000009e900099e99e99e909e9e9009ee9effeef9feef9990000000000000000000000000000000000000000000
00000009fddddf9009fff90000000000000000000009e900009e9ef99e909e9ee99eefef99ff909ff90000000000000000000000000000000000000000000000
000000009ffff9000099900000000000000000000009ee90009eef909e999e9feeeef99900990009900000000000000000000000000000000000000000000000
000000000999900000000000000000000000000000009fe9009f99009feeef99ffff900000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000009fe909e90099fef99009999000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000009ee909e99e99e900000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000990009ee9009ee909e900000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000009ee9009ef900099009e900000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000009fe99ef900000009ff900000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000009feef9000000009ff900000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000099990000000009f9000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000hhhhhhhhhhhhhhhhhhhhhh5555555555555555555555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh0000
00000000000000hhhhhhhhhhhhhhhhhhhhhh5555555555555555555555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh0000
00000000000000hhhhhhhhhhhhhhhhhhhhhh5555555555555555555555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhssssshhhhhhhhhhhhhhhhh0000
00000000000000hhhhhhhhhhhhhhhhhhhhhhllllll5llllllllll5llllhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhsssssssssssssssshhhhhhhhhhhhhhhhh0000
00000000000000hhhhhhhhhhhhhhhhhhhhhh5555555555555555555555hhhhhhhhhhhhhhhhhhhhsssssssssssssssssssssssssssssshhhhhhhhhhhhhhhh0000
0000000000000777777777777777777777777777777777777777777770000000000sssssssssssssssssssssssssssssssssssbbbbbbbh000000000hhhhh0000
00000000000007hhhhh00hh0hh0h0h0hh0h0lglglgllhlglglglgllh7gsssssssssssssssssssssssssssssssssbbbbbbbbbbbsssssssh0h0h0hh00hhhhh0000
00000000000007hhhhh0hhhhhhhhhhhhhhhhllllllllllllllllssssssssssssssssssssssssssbbbbbbbbbbbbbsssssssssssssssssshhhhhhhhh0hhhhh0000
00000000000007hh77777h00077707777000077770g0g0777777sssssssssssssssbbbbbbbbbbbssssssssssssssssssssssssssssssssh00000h00hhhhh0000
00000000000007hhh7777h00h07707777h0hg7777glg777777hlssssssbbbbbbbbbsssssssssssssssssssssssssssssssssssssssssssh0hh00hh0hhhhh0000
00000000000007hhh7777h0h007707777000g7777gg7776gggggsssssbbssssssssssssssssssssssssssssssssssssssssssbbbbbbbsssh00h0h00hhhhh0000
00000000000007hhhh7777000077h77770000777700777000m55sssssbsssssssssssssssssssssssssssssssssssbbssssbbbbbbbbbsssh000000000hhh0000
00000000000007hhhh77770h077007777000077770777700m550sssssbssssssssssssssssssssssssbbssssbbbssbbbsssbbbbbbbbssssh000hhhh000hh0000
00000000000007hhhh77770007700777700007777077770mmmmmssssssbsssssssssbbssssbbbsssssbbbsssbbbssbbbsssbbbbbbsssssh00000000000hh0000
00000000000007hhhh777700077007777h0007777077776m00s0ssssssbssbbssssbbbsssbbbbbssssbbbsssbbbssbbbssssssbbbssssssh0000000000hh0000
00000000000007hhhhh7777h0770077770000777707777777777ssssssbssbbbsssbbbssbbbbbbssssbbbsssbbbssbbbssssssbbbssssssh000000002ohh0000
00000000000007hhhhh77770077007777000h777700777777777hhssssbssbbbsssbbbssbbbsbbbsssbbbsssbbbssbbbssssssbbbssssssh000000002ohh0000
00000000000007hhhhh7777h077007777000h77770007777777777hhssbssbbbsssbbsssbbbsbbbsssbbbsssbbbssbbbssssssbbbssssssh000000002ohh0000
00000000000007hhhhh077707700077777777777700000h506777700hsbsssbbbsbbbsssbbbsbbbsssbbbsssbbbssbbbssssssbbbsssssh0h000000000hh0000
00000000000007hhhhh0777h77007777777777777000000557777700hsbsssbbbsbbbsssbbbbbbbsssbbbsssbbbssbbbbsssssbbbsssssh00000000000hh0000
00000000000007hhhhh077777700h677700007777000000055777755hsbsssbbbsbbbsssbbbbbbbbssbbbbssbbbssbbbbbbbssbbbsssssh0000hhhh000hh0000
00000000000007hhhhh0777776000777700007777000000000777000hsbsssbbbsbbbsssbbbssbbbssbbbbbbbbbssbbbbbbbssbbbssssh00000000000hhh0000
000hhhhhhhhhh7hhhhh0h7776000h777700007777000000006h770g0ssbssssbbbbbbssbbbsssbbbsssbbbbbbbsssbbhbbbbsssssssssh000000hh0hhhhh0000
000hhhhhhhhhh7hhhhh007777700077770000777707777777h8h000sssbssssbbbbbsssbbhhssbbbsssssbbbbsssssh8hssssssssssss00000h0h00hhhhh0000
000hhhhhhhhhh7hhhhh0h7777hhhhhh770000777700h77777h8h0ssssssbssssbbbbsssbh88hhbbbsssssssssssssh888hssssssssssss0h0000hh0hhhhh0000
000hhhhhhhhhh7hhhhh00h0hh88888hh0h00hh0000h0h0000h8h0ssssssbhhhssbbsshhh82288hsssssssssssssssh8h8hssssssssssssh8h000h00hhhhh0000
000hhhhhhhhhh7hhhhh0hh0h8822hh00000h88h000000000hh8h0hhhhssh888hssssh88h8hh28hsssssshhsssssssh8s8hsssssbbbbbbh828hh0hh0hhhhh0000
000hhhhh00000777777777h882hh7777777ho8h777777777h888h888hsh88h88hssh82o82hh28hsssssh88hsssssbh8b2hbbbbbshsssh82h8h00h0hhhhhh0000
000hhhhh00hh0h0h0h000hh82h000000000ho8h0h8h0hh8lh8o882h28hh82h88hssh8hoohssh8hsbbbbh8h8hbbbbsh8s2hsssssh8hssh8hh8hh0hh8hhhhh0000
000hhhhh0hhhhhhhhhhhhh8oh0000000000ho8hh8o2h8828h8282hsh8h82hho8hsh82hoohbbh8hbssssh8h8hsssssh8h2hssssh828hhh8h08h00hh8hhhhh0000
000hhhhh00h0000000000h8oh0000000000ho8h822h082h288h82hsh8h82hboohbh8hshohsshohsssssh8h8hsssshhh88hhhhhh8h8h0h8h08hh0h82hhhhh0000
000hhhhh0hh00hh0h0h0hh8ohhhhh00hhh0h2o82hh0h8h0h82h8h0sh8ho8hh828hh8hsh2hsshoohhhhhh8h8hhhhh0hhh8h8880h8h8h0h2h028hh82hhhhhh0000
000hhhhh00h0h00000000h888888hhh888h0hoo8h0h88h0h8ohoh0h8oho8h822o88ohhh2hhhh2o88h00h808h00hh88hh8h2h28h822h08h00h2822h0hhhhh0000
000hhhhh0hh000000h000h2o8888h0h8228hho228hh88hhh8oho808o2ooo82hhooohh00hh000h22h000h808h0h88222h88hhh80h8hhh2h00h222h00hhhhh0000
000hhhhh00h0h000000000h2222o8h82hh8hhohh2ohooohho2h2ooo2hhh222h0hhhhh0hhh000hhh00hhh802hhh82hhhh28hhh80h8882h0h0hhhhhh0hhhhh0000
000hhhhh0hh0000000000h0hhhho8h8hhh8hhohhhooohohooh0h222h000hhhh0hhhhhhh88hhh8h00h8h0h82h0h82h00hh8h0h2882hhh00000000h00hhhhh0000
000hhhhh00h000000000h0h000hooh8h0hohhohhh2ohh2oo2h0hhhhg00hh88h0hhhhhh82228h8h00h8hhh82hhh82hhh8h8hhh222hhhhhhhhhhhhhh0hhhhh0000
000hhhhh0hh0h0000000000000hooh8h0hohhohhhh2hhh22h00000000h82228hh888h88hhh8h8h00h8hhh8hh0h8h0hh828h0hhhhh0h0hh0h0h0hh00hhhhh0000
000hhhhh00h000h000000h000hoohhohhhohh2hh00hhhhhh00000000h82hhh2h82h8hh8h0h8h8h00h8hhh88hh828hh8222h00000000000000000000hhhhh0000
000hhhhh0hh0h0h00000hohhhhoohhoooo2h0h0hh0hhhhhg0h000000h8hh0hhh8hh8hh8h0h8h8h00h88h822882h2882hhhhhhhhhhhhhhhhhhhhhhhhhhhhh0000
000hhhhh0hh000000000h2oooo2h00h222hh000hh0hhhhh0h0000000h8h00hhh8h82hh8h0h8h88hh88282hh22hhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh0000
000hhhhh00h0h00000000h2222h0000hhh000h0h00hhhhhh00000000h88h0h0h882hhh8hhh8h288882hhh0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh0000
000hhhhh0hh000000h0000hhhh00h0000000000hh0hhhhh000g0000h0h28hhhh2hhhhh28882hh2222h0h00hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh0000
000hhhhh00h0h00000h0000000000h0000000h0h00hhhhh0000g00h000h28h0h8hhhhh282hh00hhhh00hh0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh0000
000hhhhh0hh000000h0000000000h0000000000hh0hhhhh000h00000000h88h0h8hh8hh8h0000000000hh0hhhhh0000000000000000000000000000000000000
000hhhhh00h0h000000000000000000000000h0h00hhhhh0000000hh000h88h0hh88h0h8h00000000h0h00hhhhh0000000000000000000000000000000000000
000hhhhh0hh0000000000h0000000000h000000hh0hhhhh000000h88h00h82h0hhhhh0h8h000h000000hh0hhhhh0000000000000000000000000000000000000
000hhhhh00h000000000h0h00000000h0h00000h00hhhhh000000hh28hh82h00hhhhhh22h00h0h00000h00hhhhh0000000000000000000000000000000000000
000hhhhh0hh0h000000000000000000000000h0hh0hhhhh00000000h2882hhh0hhhhhh22h00000000h0hh0hhhhh0000000000000000000000000000000000000
000hhhhh00h000h0000000000h0000000000000h00hhhhhh00000000hhhh0h00hhhhhh2h00000000000h00hhhhh0000000000000000000000000000000000000
000hhhhh0hh0h0h0000000000h00000000000h0hh0hhhhhh00000000000h0hh0hhhhhh00000000000h0hh0hhhhh0000000000000000000000000000000000000
000hhhhh0hh0000000000000h0000000000h000hh0hhhhh0000000000h000hh0hhhhh0000000000h000hh0hhhhh0000000000000000000000000000000000000
000hhhhh00h0h000000000000000000000000h0h00hhhhh000000000000h0h00hhhhh000000000000h0h00hhhhh0000000000000000000000000000000000000
000hhhhh0hh000000h0000000000h0000000000hh0hhhhh000h0000000000hh0hhhhh000h0000000000hh0hhhhh0000000000000000000000000000000000000
000hhhhh00h0h00000h0000000000h0000000h0h00hhhhh0000h0000000h0h00hhhhh0000h0000000h0h00hhhhh0000000000000000000000000000000000000
000hhhhh0hh000000h000000000hhjhhh000hhshhhhhsll000h0000000000hh0hhhhh000h0000000000hh0hhhhh0000000000000000000000000000000000000
000hhhhh00h0h0000000000000hhj0000000hshhhhhhhsl000000000000h0h00hhhhh000000000000h0h00hhhhh0000000000000000000000000000000000000
000hhhhh0hh0000000000h000hhhhjhhhhhhhsgggggggsl0000000h000000hh0hhhhh0000000h000000hh0hhhhh0000000000000000000000000000000000000
000hhhhh00h000000000h0h00h00hhjhh00hhshhhg7hhsl000000h0h00000h00hhhhh000000h0h00000h00hhhhh0000000000000000000000000000000000000
000hhhhh0hh0h000000000000h0hhjjjhh0hhshhhdghhsl000000000000h0hh0hhhhh000000000000h0hh0hhhhh0000000000000000000000000000000000000
000hhhhh00h000h0000000000h0hj000jh0hs5hhdddhh5sh0000000000000h00hhhhhh0000000000000h00hhhhh0000000000000000000000000000000000000
000hhhhh0hh0h0h0000000000h0hj000jh0hsddh5d5hddsh00000000000h0hh0hhhhhh00000000000h0hh0hhhhh0000000000000000000000000000000000000
000hhhhh0hh0000000000000hh0h06060h0hsddh555hdds0000000000h000hh0hhhhh0000000000h000hh0hhhhh0000000000000000000000000000000000000
000hhhhh00h0h000000000000hh0j000j0hhhshh555hhsl000000000000h0h00hhhhh000000000000h0h00hhhhh0000000000000000000000000000000000000
000hhhhh0hh000000h00000000hhhhhhhhh0hshh555hhsl000h0000000000hh0hhhhh000h0000000000hh0hhhhh0000000000000000000000000000000000000
000hhhhh00h0h00000h00000000000000000hsh5555hhsl0000h0000000h0h00hhhhh0000h0000000h0h00hhhhh0000000000000000000000000000000000000
000hhhhh00h0h00000000000000000000000hghgh0lglll000g000h000000g000h000000g000h000000hh0hhhhh0000000000000000000000000000000000000
000hhhhh0hh00h0h00h0h0h0h0h00h0h0h0hgh0gghlglll000h0000h00000h0000h00000h0000h000h0h00hhhhh0000000000000000000000000000000000000
000hhhhh00h0000000000000000000000000000gh0lglll0000h00gh000000h00gh000000h00gh00000hh0hhhhh0000000000000000000000000000000000000
000hhhhh0hhhhhhhhhhhhhhhhhhhhhhhhhhhggggghlglll0000h0g0g000000h0g0g000000h0g0g00000h00hhhhh0000000000000000000000000000000000000
000hhhhh00hh0hh0h0h0hh0h0h0h0h0hh0h0ghggh0lglll0000000000000000000000000000000000h0hh0hhhhh0000000000000000000000000000000000000
000hhhhh0000000000000000000000000000h0h00hlglllg0000000000g0000000000g0000000000000h00hhhhh0000000000000000000000000000000000000
000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhlllllllglllg0h0000000hg0h0000000hg0h0000000h0h0hh0hhhhh0000000000000000000000000000000000000
000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhgggggggllll0h00000000g0h00000000g0h00000000g000hh0hhhhh0000000000000000000000000000000000000
000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhlllllllllllh0000000000h0000000000h00000000000h0h00hhhhh0000000000000000000000000000000000000
000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhlllllllllll000g0000h00000g0000h00000g0000h00000hh0hhhhh0000000000000000000000000000000000000
000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhlllllllllll0000g00h0000000g00h0000000g00h0000h0h00hhhhh0000000000000000000000000000000000000
000000000000000000000000000000000000hhhhhhhhhhhlllllllllll000jjjjj00000000000000hh0gghlglll0000000000000000000000000000000000000
000000000000000000000000000000000000hhhhhhhhhhhlllllllllll00jjhhjjjh000000000h00hghgh0lglll0000000000000000000000000000000000000
000000000000000000000000000000000000hhhhhhhhhhhlllllllllllhjjjjjjjjjh000hhhh0000h00gghlglll0000000000000000000000000000000000000
000000000000000000000000000000000000hhhhhhhhhhhgggggggllll0hjjjjjjjj0000hhhhh000h00gh0lglll0000000000000000000000000000000000000
000000000000000000000000000000000000hhhhhhhhhhhlllllllglll0mhhhjhhjj0hhgh77h5h00hghgghlglll0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000h0h00hlgllll5506506jh000hbhbbbh00hh0gh0lglll0000000000000000000000000000000000000
000000000000000000000000000000000000h0h0h0hh0h0ghggh0lgllllh5mmmmmh0ghhggggggghhhghgghlllll0000000000000000000000000000000000000
000000000000000000000000000000000000hhhhhhhhhhhggggghlglll0mm0hhh05mlbbhhhhgghhghh0gghlglll0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000gh0lglllg00hhhhh000h0000hhhhh0hghg00lglll0000000000000000000000000000000000000
0000000000000000000000000000000000000h00h0h0h0hgh0gghlglll0h000000g00000g0000000hh0gghlglll0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000hghgh0lglll0000l00g0000000000h000hghgh0lglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000h0gghlgllllllglhgg0hh005lllll000hh0gghlglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ghgh0lgllllllgl0hghgh05ll0000000hghgh0lglll0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000gghlgllllllglhgg00h55555555555h00gghlglll0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000gh0lgllllllgl0hg00h506llld6005h00gh0lglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ghgghlgllllllglhgghgh50ldggll605hghgghlglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000h0gh0lgllllllgl0hg0hhl0m6ggdg60lhh0gh0lglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ghgghllllllllllhgghghl0o8mm6m50lhghgghlllll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000h0gghlgllllllglhgg0hhl05mmmm8m0lhh0gghlglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ghg00lgllllllgl00ghghll0mmmmm0llhghg00lglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000h0gghlgllllllglhgg0hh0lllllllll0hh0gghlglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ghgh0lgllllllgl0hghgh00000000000hghgh0lglll0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000hghgh0lglll0000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000h00h0h0h0hgh0gghlglll0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000gh0lglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000hhhhhhhhhhhggggghlglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000h0h0h0hh0h0ghggh0lglll0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000h0h00hlglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000hhhhhhhhhhhlllllllglll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000hhhhhhhhhhhgggggggllll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000hhhhhhhhhhhlllllllllll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000hhhhhhhhhhhlllllllllll0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000hhhhhhhhhhhlllllllllll0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000sssss000000sss0sss00ss0sss0sss000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ss0s0ss00000s0s0s000s000s0000s0000
0000770007700000000000000077000770000000000000000000000000000000000000000000000000000000000000sss0sss00000ss00ss00sss0ss000s0000
0007887078870007700077000788707887000000000000000000000000000000000000000000000000000000000000ss0s0ss00000s0s0s00000s0s0000s0000
00787887888870788707887078788788887000000000000000000000000000000000000000000000000000000000000sssss000000s0s0sss0ss00sss00s0000
0078888o8888m7878878888778888o8888m000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00mo8888888om78888o8888mmo8888888om000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000moo888oom0mo8888888om0moo888oom00000000000000000000000000000000000000000sssss000sssss000sssss000sssss000000sss00ss0s0s0sss000
00008loooo8000moo888oom0008loooo800000000000000000000000000000000000000000sss0sss0ss000ss0sss00ss0ss00sss00000sss0s0s0s0s0s00000
0000omlol8o00008loooo80000omlol8o00000000000000000000000000000000000000000ss000ss0ss000ss0ss000ss0ss000ss00000s0s0s0s0s0s0ss0000
0000o0mlmo00000omlol8o0000o0mlmo000000000000000000000000000000000000000000ss000ss0sss0sss0sss00ss0ss00sss00000s0s0s0s0sss0s00000
0000000m0o00000o0mlmo00000000m0o0000000000000000000000000000000000000000000sssss000sssss000sssss000sssss000000s0s0ss000s00sss000
000000000000000000m0o00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0001000000000000000000000000000000010101010000000000000000000000000101010100000000000000000000000001010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101221313131323010101220613131313131313132301221313132322131323013535352206132335353535222222131313131313132335353535353535353535353535352213233535353535220101010101221313132335352213131323353535352213130613131313131323000000000000000000000000000000000000
2213320000000012010101111000000000000000001201110000001211000012013535351100001222131323112213131313131313231235353535353522132313233522133202331313132335221313131313110000001222133200000012132335351100000700000007000012221313131313131313132300000000000000
1100000034310012010101110022131313230014142401110032003332000012013535351110033332000012111100000000000402122422131313232232021210063511000000000000100635110000000000110011001211000007050012021235351107050000000700000012110200000000000000001200000000000000
1100341424110012132335110011000000120000332301110000000000000012013535351100030000000012111100141414141414241211000000333200000000122232003400310031001235110034141400050211001211003100000012001235351100070000000000070012211414141414140013001200000000000000
1100120002030012000635110011000300120003021201110000000034073424012213232114310000000012221100000000000000121211003200000004000234241102040407040000001235110033001313131332001211002213320033003313231100000007000007000012223200000000000000001200000000000000
1100120012110012001235110011000000331313132335110000141424003323011102331313320034141424112114141414140000121211000000001204000012352131003300320034142435110000000000000000001206101100040000000200121100070000070005000712061000053414310013001200000000000000
1100120033131313101201110021143100000000001235061000000212000012011100000000070733132335113506001000000000122421310032001200003424353511000000000012353535211431001400341414001211001100000034003400121107000700000007000012110003001200110000001200000000000000
1100000000000000001201110000001100000000001235110014140312000012011100000000000000021235113521141414141414241235110000001214142435353521143102341424353535110011000000121000001211002114141424003300121100000000000700070012110000342400211431021200000000000000
2114141414141414142401110033001100000000001201110000000012000012012114141431000000342435221414141414141414241235211414142435353535353535352114243535353535110021141414240614142411000000000000000000121102070000070007020012211414240000000021142400000000000000
0101010101010101010101110000000000000000021201211414141424141424013535353521141414243535110000000000000000001235353535353535353535353535353535353535353535110000000000353535001221141414141414141414241100000007100700000012000000000000000000000000000000000000
0101010101010101010101211414141414141414142401010101010101010101013535353535353535353535211414141414141414142435353535353535353535353535353535353535353535211414141414141414142435353535353535353535352114141414141414141424000000000000000000000000000000000000
0022131313131313131323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0011000002000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2232100004000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100001200120034141424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100031200120012000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100021200120012000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2114142400050012000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100001323000012000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000012110212000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000211424000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2114141414141414141424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
060803030c7600c7600876008760037600376000760007500075001700181001c1001c1001a100181000f1000d1000d1000d1000f1000f1000f1000f1000f1000d1000f1000d1000f1000f100000000f10000000
d6100000000001f6501b65017650146500f6000a60005600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a60c00003e61400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604
071900000000007020040200c02010000150000000000000060000400002000000000000018000000000000018000180002400018000180001800024000180001800018000000000000000000000000000000000
011000010017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000907005070000701c00018000170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4002000032623306232e6231f6231c623196231562313623116230d6230b623076231660314603126030f6030c6030b60326603006032460322603206031d6031860317603006030060300603006030060300603
051000002c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0064002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
012000000dc650dc550dc450dc351075510745107351072500b5517c5517c4517c3517c2517c2510755107450dc650dc550dc450dc351075510745107351072500b5417c5517c4517c3517c2517c250dc250dc35
011d0c201072519c5519c4519c3519c251005510045100351002517c550f7350f7350f7250f72510725107251072519c3519c3519c2519c250b0250b0350b7350b0250b7250b72517c3517c350f7350f7350f725
0120000012c6512c5512c4512c351575515745157351572500b5510c5510c4510c3510c2510c25157551574512c6512c5512c4512c35157551574500b54157351572519c5519c4519c3519c2519c250dc250dc35
011d0c20107251ec351ec351ec351ec251503515035150251502517c35147351472514725147251572515725157251ec351ec351ec251ec2515025150351573515025157251572519c3519c350f7350f7350f725
0120000019c5519c450dc3501c551405014040147321472223c3523c450bc350bc551505015040157321572219c5519c450dc3501c551705019040197321972223c3523c450bc350bc551c0501e0401e7321e722
012000001ec551ec4512c3506c552105021040217322172228c4528c3528c2520050200521e0401e7321e7221ec551ec4512c3506c552105021040257322572228c5528c4528c3528c251c0401e0301e7221e722
000200000863007631066010560104601066010660112601156051a6011d60510650156501a600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0002000003600016100161002610026100462007620096400d630066000a6000e600156001b600006002060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00090000226301f6201b6101764014640126400d6300a630066300562002610016100060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
__music__
01 08094344
03 0a0b4344
01 0c0d4344
00 0c0d4344
00 0e0f4344
00 0c104344
00 0c104344
02 0e114344
