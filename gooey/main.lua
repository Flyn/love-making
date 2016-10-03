function create_static(x, y)
    local obj = {}
    obj = {}
    obj.body = love.physics.newBody(world, x, y, "static")
    obj.shape = love.physics.newRectangleShape(0, 0, 100, 50)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 2)

    table.insert(objects, obj)
    table.insert(blocks, obj)

    return obj
end

function create_ball(x,y)
    local obj = {}
    obj.body = love.physics.newBody(world, x, y, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
    obj.shape = love.physics.newCircleShape(20) --the ball's shape has a radius of 20
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 0.5) -- Attach fixture to body and give it a density of 1.
    obj.fixture:setRestitution(0.9) --let the ball bounce

    table.insert(objects, obj)
    table.insert(balls, obj)

    return obj
end

function join_objects(obj1, obj2)
    local joint = {}
    joint = love.physics.newDistanceJoint( obj1.body, obj2.body, obj1.body:getX(), obj1.body:getY(), obj2.body:getX(), obj2.body:getY(), true )
    joint:setFrequency(5)
    joint:setDampingRatio(0.005)

    table.insert(joints, joint)

    return joint
end

function detect_nearest_objects(x, y)
    local near1, near2
    local dist1 = math.huge
    local dist2 = math.huge
    for idx, obj in ipairs(objects) do
      local x2, y2 = obj.body:getX(), obj.body:getY()
      local dist = math.sqrt(math.pow(x2 - x, 2) + math.pow(y2 - y, 2))

      if (dist < dist1) then
        dist1 = dist
        near1 = obj
      elseif (dist < dist2) then
        dist2 = dist
        near2 = obj
      end
      if (dist1 < dist2) then
        near1, dist1, near2, dist2 = near2, dist2, near1, dist1
      end
    end

    if ((dist1 + dist2) / 2) > 150 then return nil end
    return near1, near2
end

function love.load()
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

    objects = {} -- table to hold all our physical objects
    balls = {}
    blocks = {}
    joints = {}

    --let's create a ball
    local ball = create_ball(650/2, 650/2)

    --let's create a ball
    local ball2 = create_ball(650/2+100, 650/2-100)

    --let's create a ball
    local ball3 = create_ball(650/2+200, 650/2-50)

    --let's create a couple blocks to play around with

    local block = create_static(200,500)

    local block2 = create_static(400,500)

    d = join_objects(ball, block)
    d2 = join_objects(ball, block2)
    d3 = join_objects(ball, ball2)
    d4 = join_objects(ball2, block2)
    d5 = join_objects(ball2, ball3)
    d6 = join_objects(block2, ball3)

    --initial graphics setup
    love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
    love.window.setMode(850, 650, {}) --set the window dimensions to 650 by 650
end


function love.update(dt)
    world:update(dt) --this puts the world into motion

    --here we are going to create some keyboard events
    if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
        balls[1].body:applyForce(400, 0)
    elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
        balls[1].body:applyForce(-400, 0)
    end

end

function love.mousepressed(x, y, button)
  if button == 1 then
    local near1, near2 = detect_nearest_objects(love.mouse.getPosition())
    if near1 and near2 then
      local ball = create_ball(x, y)
      join_objects(ball, near1)
      join_objects(ball, near2)
    end
  end
end

function love.draw()

    love.graphics.setColor(50,50,50) --set the drawing color to red for the ball
    love.graphics.setLineWidth(10)
    for idx, joint in ipairs(joints) do
      love.graphics.line(joint:getAnchors())
    end

    love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
    for idx, ball in ipairs(balls) do
      love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
    end

    love.graphics.setColor(50, 50, 50)
    for idx, block in ipairs(blocks) do
      love.graphics.polygon("fill", block.body:getWorldPoints(block.shape:getPoints()))
    end

    love.graphics.setColor(100, 150, 50)
    local near1, near2 = detect_nearest_objects(love.mouse.getPosition())
    if near1 and near2 then
      love.graphics.circle("fill", near1.body:getX(), near1.body:getY(), 10)
      love.graphics.circle("fill", near2.body:getX(), near2.body:getY(), 10)
    end

end
