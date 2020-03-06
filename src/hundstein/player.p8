function init_player()
  player = {
    pos = {},
    dir = {},
    score = 0,
    ammo = 10
  }
end

function move()
  oldDir = player.dir
  oldPlane = plane

  if btn(0) and not btn(4) then rotate_left()   end
  if btn(1) and not btn(4) then rotate_right()  end
  if btn(2)                then walk_forward()  end
  if btn(3)                then walk_backward() end
  if btn(0) and btn(4)     then strafe_left()   end
  if btn(1) and btn(4)     then strafe_right()  end
end

function rotate_left()
  player.dir = { x = oldDir.x * cos(-rotSpeed) - oldDir.y * sin(-rotSpeed),
                 y = oldDir.x * sin(-rotSpeed) + oldDir.y * cos(-rotSpeed) }
  plane = { x = oldPlane.x * cos(-rotSpeed) - oldPlane.y * sin(-rotSpeed),
            y = oldPlane.x * sin(-rotSpeed) + oldPlane.y * cos(-rotSpeed) }
end

function rotate_right()
  player.dir = { x = oldDir.x * cos(rotSpeed) - oldDir.y * sin(rotSpeed),
                 y = oldDir.x * sin(rotSpeed) + oldDir.y * cos(rotSpeed) }
  plane = { x = oldPlane.x * cos(rotSpeed) - oldPlane.y * sin(rotSpeed),
            y = oldPlane.x * sin(rotSpeed) + oldPlane.y * cos(rotSpeed) }
end

function walk_forward()
  if world[flr(player.pos.x + player.dir.x * moveSpeed)][flr(player.pos.y)] == 0 then player.pos.x += player.dir.x * moveSpeed end
  if world[flr(player.pos.x)][flr(player.pos.y + player.dir.y * moveSpeed)] == 0 then player.pos.y += player.dir.y * moveSpeed end
end

function walk_backward()
  if world[flr(player.pos.x - player.dir.x * moveSpeed)][flr(player.pos.y)] == 0 then player.pos.x -= player.dir.x * moveSpeed end
  if world[flr(player.pos.x)][flr(player.pos.y - player.dir.y * moveSpeed)] == 0 then player.pos.y -= player.dir.y * moveSpeed end
end

function strafe_left()
  moveDir = { x = player.dir.x * cos(0.25) - player.dir.y * sin(0.25),
              y = player.dir.x * sin(0.25) + player.dir.y * cos(0.25) }

  if world[flr(player.pos.x - moveDir.x * moveSpeed)][flr(player.pos.y)] == 0 then player.pos.x -= moveDir.x * moveSpeed end
  if world[flr(player.pos.x)][flr(player.pos.y - moveDir.y * moveSpeed)] == 0 then player.pos.y -= moveDir.y * moveSpeed end
end

function strafe_right()
  moveDir = { x = player.dir.x * cos(0.25) - player.dir.y * sin(0.25),
              y = player.dir.x * sin(0.25) + player.dir.y * cos(0.25) }

  if world[flr(player.pos.x + moveDir.x * moveSpeed)][flr(player.pos.y)] == 0 then player.pos.x += moveDir.x * moveSpeed end
  if world[flr(player.pos.x)][flr(player.pos.y + moveDir.y * moveSpeed)] == 0 then player.pos.y += moveDir.y * moveSpeed end
end

function give_treat()
  giveTreatSpeed = 4

  if btn(5) then
    treatY = max(80, treatY - giveTreatSpeed)
  else
    if treatY < 90 then
      -- treat successfully given
      for spriteInstance in all(spriteInstances) do
        if spriteInstance.sprite == sprites.dogAngry then
          distance = (player.pos.x - spriteInstance.x) * (player.pos.x - spriteInstance.x) + (player.pos.y - spriteInstance.y) * (player.pos.y - spriteInstance.y)
          if distance < 7 then
            spriteInstance.sprite = sprites.dogHappy
            player.ammo -= 1
            player.score += 50
            showInstructions = false
          end
        end
      end
    end

    treatY = 128
  end
end

function draw_treat()
  sspr(64, 64, 32, 32, 48, treatY, 32, 32)
end

function get_treasure()
  for spriteInstance in all(spriteInstances) do
    if spriteInstance.sprite == sprites.chest and flr(spriteInstance.x) == flr(player.pos.x) and flr(spriteInstance.y) == flr(player.pos.y) then
      player.score += 50
      del(spriteInstances, spriteInstance)
    end
  end
end
