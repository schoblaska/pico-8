function move()
  oldDir = dir
  oldPlane = plane

  if btn(0) and not btn(4) then rotate_left()   end
  if btn(1) and not btn(4) then rotate_right()  end
  if btn(2)                then walk_forward()  end
  if btn(3)                then walk_backward() end
  if btn(0) and btn(4)     then strafe_left()   end
  if btn(1) and btn(4)     then strafe_right()  end
end

function rotate_left()
  dir = { x = oldDir.x * cos(-rotSpeed) - oldDir.y * sin(-rotSpeed),
          y = oldDir.x * sin(-rotSpeed) + oldDir.y * cos(-rotSpeed) }
  plane = { x = oldPlane.x * cos(-rotSpeed) - oldPlane.y * sin(-rotSpeed),
            y = oldPlane.x * sin(-rotSpeed) + oldPlane.y * cos(-rotSpeed) }
end

function rotate_right()
  dir = { x = oldDir.x * cos(rotSpeed) - oldDir.y * sin(rotSpeed),
          y = oldDir.x * sin(rotSpeed) + oldDir.y * cos(rotSpeed) }
  plane = { x = oldPlane.x * cos(rotSpeed) - oldPlane.y * sin(rotSpeed),
            y = oldPlane.x * sin(rotSpeed) + oldPlane.y * cos(rotSpeed) }
end

function walk_forward()
  if world[flr(pos.x + dir.x * moveSpeed)][flr(pos.y)] == 0 then pos.x += dir.x * moveSpeed end
  if world[flr(pos.x)][flr(pos.y + dir.y * moveSpeed)] == 0 then pos.y += dir.y * moveSpeed end
end

function walk_backward()
  if world[flr(pos.x - dir.x * moveSpeed)][flr(pos.y)] == 0 then pos.x -= dir.x * moveSpeed end
  if world[flr(pos.x)][flr(pos.y - dir.y * moveSpeed)] == 0 then pos.y -= dir.y * moveSpeed end
end

function strafe_left()
  moveDir = { x = dir.x * cos(0.25) - dir.y * sin(0.25),
              y = dir.x * sin(0.25) + dir.y * cos(0.25) }

  if world[flr(pos.x - moveDir.x * moveSpeed)][flr(pos.y)] == 0 then pos.x -= moveDir.x * moveSpeed end
  if world[flr(pos.x)][flr(pos.y - moveDir.y * moveSpeed)] == 0 then pos.y -= moveDir.y * moveSpeed end
end

function strafe_right()
  moveDir = { x = dir.x * cos(0.25) - dir.y * sin(0.25),
              y = dir.x * sin(0.25) + dir.y * cos(0.25) }

  if world[flr(pos.x + moveDir.x * moveSpeed)][flr(pos.y)] == 0 then pos.x += moveDir.x * moveSpeed end
  if world[flr(pos.x)][flr(pos.y + moveDir.y * moveSpeed)] == 0 then pos.y += moveDir.y * moveSpeed end
end

function give_treat()
  giveTreatSpeed = 4

  if btn(5) then
    treatY = max(80, treatY - giveTreatSpeed)
  else
    if treatY < 90 then
      -- treat successfully given
      for doggo in all(doggos) do
        doggoDistance = (pos.x - doggo.x) * (pos.x - doggo.x) + (pos.y - doggo.y) * (pos.y - doggo.y)
        if doggoDistance < 5 then doggo.spriteY = 32 end
      end
    end

    treatY = 128
  end
end

function draw_treat()
  sspr(64, 64, 32, 32, 48, treatY, 32, 32)
end
