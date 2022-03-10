
import 'CoreLibs/sprites'
import 'CoreLibs/graphics'

gfx = playdate.graphics

local ballSprite = nil
local radius = 5
local wallbounce = 0.95
local dx,dy = math.random(-10,10), math.random(-10,10)

local dpadPlayerSprite = nil
local crankPlayerSprite = nil

local DPAD_SPEED = 10
local MAX_CRANK_SPEED = 20
local CRANK_SCALE = 1

function playdate.update()
  -- everything is a sprite... so update them
	gfx.sprite.update()
end

-- paints the whole background white
gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0, 0, 400, 240)
gfx.setBackgroundColor(gfx.kColorWhite)

-- Create ball sprite, and set up drawing functions
ballSprite = gfx.sprite:new()
ballSprite:setSize(2*radius+1, 2*radius+1)
ballSprite:moveTo(200,120)
ballSprite:addSprite()

ballSprite.draw = function()
  gfx.setColor(gfx.kColorBlack)

  if ballSprite.collided then
    gfx.fillCircleAtPoint(radius, radius, radius)
    ballSprite.collided = false
  else
    gfx.drawCircleAtPoint(radius, radius, radius)
  end
end

ballSprite.update = function()
  -- bounce off the walls

  -- compute new position of sprite based on speeds
  local newx = ballSprite.x + dx
  local newy = ballSprite.y + dy

  -- compute position of left/right walls relative to center of sprite
  local left = radius
  local right = 400 - radius

  -- assuming wallbounce<0, reverses and reduces speed after hitting walls
  -- hit the left wall
  if newx < left and dx < 0
  then
    newx = left
    dx *= -wallbounce
    ballSprite.collided = true

  -- hit right wall
  elseif newx > right and dx > 0
  then
    newx = right
    dx *= -wallbounce
    ballSprite.collided = true
  end

  -- compute position of top/left walls relative to center of sprite
  local top = radius
  local bottom = 240 - radius

  -- hit top wall
  if newy < top and dy < 0
  then
    newy = top
    dy *= -wallbounce
    ballSprite.collided = true

  -- hit bottom wall
  elseif newy > bottom and dy > 0
  then
    newy = bottom
    dy *= -wallbounce
    ballSprite.collided = true
  end

  -- move to new position
  ballSprite:moveTo(newx, newy)
end

-- Create dpad-player sprite, and set up drawing functions
dpadPlayerSprite = gfx.sprite:new()
dpadPlayerSprite:setSize(radius, 10*radius)
dpadPlayerSprite:moveTo(20,120)
dpadPlayerSprite:addSprite()

dpadPlayerSprite.draw = function()
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(0, 0, radius, 10*radius)
end

dpadPlayerSprite.update = function()
  if playdate.buttonIsPressed( playdate.kButtonUp ) then
    if dpadPlayerSprite.y > 20 then
      -- TODO could this be animated to be more smooth?
      -- would I need a higher framerate?
      dpadPlayerSprite:moveBy( 0, -DPAD_SPEED )
    end
  elseif playdate.buttonIsPressed( playdate.kButtonDown ) then
    if dpadPlayerSprite.y < 220 then
      dpadPlayerSprite:moveBy( 0, DPAD_SPEED )
    end
  end
end


-- Create crank-player sprite, and set up drawing functions
crankPlayerSprite = gfx.sprite:new()
crankPlayerSprite:setSize(radius, 10*radius)
crankPlayerSprite:moveTo(380,120)
crankPlayerSprite:addSprite()

crankPlayerSprite.draw = function()
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(0, 0, radius, 10*radius)
end

crankPlayerSprite.update = function()
  local change = playdate.getCrankChange()
  local normalizedCrankInput = math.floor(change * CRANK_SCALE)
  normalizedCrankInput = math.min(MAX_CRANK_SPEED, normalizedCrankInput)
  normalizedCrankInput = math.max(-MAX_CRANK_SPEED, normalizedCrankInput)
  if crankPlayerSprite.y < 20 then
    normalizedCrankInput = math.max(0, normalizedCrankInput)
  elseif crankPlayerSprite.y > 220 then
    normalizedCrankInput = math.min(0, normalizedCrankInput)
  end
  crankPlayerSprite:moveBy( 0, normalizedCrankInput )
end