function init_sprites()
  sprites = {
    dogAngry = { x = 64, y = 0,  w = 32, h = 32, animated = true,  hScale = 0.75, vScale = 0.75, vMove = 30 },
    dogHappy = { x = 64, y = 32, w = 32, h = 32, animated = true,  hScale = 0.75, vScale = 0.75, vMove = 30 },
    light =    { x = 96, y = 64, w = 32, h = 16, animated = false, hScale = 0.5,  vScale = 0.25, vMove = -50 },
    chest =    { x = 96, y = 80, w = 32, h = 16, animated = false, hScale = 0.5,  vScale = 0.25, vMove = 55 }
  }
end
