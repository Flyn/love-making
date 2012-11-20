function create_static(x, y)
    local obj = {}
    obj = {}
    obj.body = love.physics.newBody(world, x, y, "static")
    obj.shape = love.physics.newRectangleShape(0, 0, 100, 50)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 2)
    return obj
end

function create_ball(x,y)
    local obj = {}
    obj.body = love.physics.newBody(world, x, y, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
    obj.shape = love.physics.newCircleShape(20) --the ball's shape has a radius of 20
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 1) -- Attach fixture to body and give it a density of 1.
    obj.fixture:setRestitution(0.9) --let the ball bounce
    return obj
end

function join_objects(obj1, obj2)
    local join = {}
    join = love.physics.newDistanceJoint( obj1.body, obj2.body, obj1.body:getX(), obj1.body:getY(), obj2.body:getX(), obj2.body:getY(), true )
    join:setFrequency(2)
    join:setDampingRatio(0.005)
    return join
end

function love.load()
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

    objects = {} -- table to hold all our physical objects
    
    --let's create the ground
    objects.ground = {}
    objects.ground.body = love.physics.newBody(world, 850/2, 650-50/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    objects.ground.shape = love.physics.newRectangleShape(850, 50) --make a rectangle with a width of 650 and a height of 50
    --objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape); --attach shape to body
    
    --let's create a ball
    objects.ball = create_ball(650/2, 650/2)

    --let's create a ball
    objects.ball2 = create_ball(650/2+100, 650/2-100)

    --let's create a ball
    objects.ball3 = create_ball(650/2+200, 650/2-50)

    --let's create a couple blocks to play around with

    objects.block3 = create_static(200,500)
    
    objects.block4 = create_static(400,500)
    
    d = join_objects(objects.ball, objects.block3)
    d2 = join_objects(objects.ball, objects.block4)
    d3 = join_objects(objects.ball, objects.ball2)
    d4 = join_objects(objects.ball2, objects.block4)
    d5 = join_objects(objects.ball2, objects.ball3)
    d6 = join_objects(objects.block4, objects.ball3)

    --initial graphics setup
    love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
    love.graphics.setMode(850, 650, false, true, 0) --set the window dimensions to 650 by 650
end


function love.update(dt)
    world:update(dt) --this puts the world into motion
    
    --here we are going to create some keyboard events
    if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
        objects.ball.body:applyForce(400, 0)
    elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
        objects.ball.body:applyForce(-400, 0)
    elseif love.keyboard.isDown("up") then --press the up arrow key to set the ball in the air
        --objects.ball.body:setPosition(650/2, 650/2)
        --objects.ball3.body:applyForce(0, -1400)
        if d3 then
            d3:destroy()
            d3 = nil
        end
    end
end

function love.draw()

    love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
    love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates

    love.graphics.setColor(50,50,50) --set the drawing color to red for the ball
    love.graphics.setLineWidth(10)
    love.graphics.line(d:getAnchors())
    love.graphics.line(d2:getAnchors())
    if d3 then
        love.graphics.line(d3:getAnchors())
    end
    love.graphics.line(d4:getAnchors())
    love.graphics.line(d5:getAnchors())
    love.graphics.line(d6:getAnchors())

    love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
    love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())
    love.graphics.circle("fill", objects.ball2.body:getX(), objects.ball2.body:getY(), objects.ball2.shape:getRadius())
    love.graphics.circle("fill", objects.ball3.body:getX(), objects.ball3.body:getY(), objects.ball3.shape:getRadius())

    love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the blocks
    love.graphics.polygon("fill", objects.block3.body:getWorldPoints(objects.block3.shape:getPoints()))
    love.graphics.polygon("fill", objects.block4.body:getWorldPoints(objects.block4.shape:getPoints()))
    
end
