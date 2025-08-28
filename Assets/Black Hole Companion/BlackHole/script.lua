
-- APIs
local confetti = require("BlackHole/confetti")

-- Variables
local MODEL = models.BlackHole.model.World
local frame = 0;
local colorType = "orange"

-- Custom HSV Color is default 0.1, 1, 1 (orange)
local CUSTOM_HSV_COLOR = vec(0.1, 1, 1)
local centerColor   = vec(1, 1, 1)
local outlineColor  = vec(1, 1, 1)
local ringColor     = vec(1, 1, 1)
local particleColor = vec(1, 1, 1)

-- Register black hole particle
confetti.registerMesh("black_hole", models.BlackHole.particles.black_hole, 15)

-- Just makes a random vector then scales it by an amount
function randomVec(scale)
    return vec(math.random()-0.5,math.random()-0.5,math.random()-0.5)*scale 
end

function clampVec(vec, a, b)
    return vec(math.clamp(vec.x, a, b),math.clamp(vec.y, a, b),math.clamp(vec.z, a, b))
end

-- Events
function events.tick()
    
    if world:getTime() % 2 ~= 0 then return end

    -- Particle Spawning
    local r, g, b = vectors.hsvToRGB(frame, 1, 1)
    local vector = randomVec(1)

    -- Uses one of the examples from confetti
    -- I had to modify confetti a little to remove a white flicker for the first frame the particle existed
    confetti.newParticle(
        "black_hole",
        vector * 2,
        -vector*0.03,
        {
            emissive=true,
            friction=1.0,
            color=particleColor,
            ticker=function(particle)
                confetti.defaultTicker(particle)
                particle.mesh:setColor(particleColor)
                particle.velocity = particle.velocity * 1.2
                particle.scale = math.clamp(math.map(particle.lifetime, particle.options.lifetime, 1, 1, 0), 0, 1)
            end
        }
    )

    -- Sync
    if world:getTime() % 20 ~= 0 then return end
    MODEL.outline:setPrimaryRenderType("CUTOUT_CULL")
    models.BlackHole.particles.black_hole:setPrimaryRenderType("CUTOUT_CULL")
    animations["BlackHole.model"].rotate:play()
    renderer:setShadowRadius(0)
end

function events.render(delta)

    -- Time counter im too lazy to rename to time
    frame = frame + 0.002*delta

    -- Update Colors
    local color = nil
    if colorType == "orange" then
        color = vectors.hsvToRGB(CUSTOM_HSV_COLOR.x, CUSTOM_HSV_COLOR.y, CUSTOM_HSV_COLOR.z)
        centerColor = vec(0, 0, 0)
        outlineColor = color
        ringColor = color
        particleColor = color
    elseif colorType == "blue" then
        color = vectors.hsvToRGB(0.561, 0.5, 1)
        centerColor = vec(0, 0, 0)
        outlineColor = color
        ringColor = color
        particleColor = color
    elseif colorType == "rainbow" then
        color = vectors.hsvToRGB(frame, 1, 1)
        centerColor = vec(0, 0, 0)
        outlineColor = color
        ringColor = color
        particleColor = color
    elseif colorType == "white" then
        color = vectors.hsvToRGB(0, 0, 1)
        centerColor = vec(0, 0, 0)
        outlineColor = color
        ringColor = color
        particleColor = color
    elseif colorType == "black" then
        centerColor = vec(1, 1, 1)
        outlineColor = vec(0, 0, 0)
        ringColor = vec(0, 0, 0)
        particleColor = vec(0, 0, 0)
    end

    -- Set Colors
    MODEL.center:setColor(centerColor)
    MODEL.outline:setColor(outlineColor)
    MODEL.ring:setColor(ringColor)

    -- Move Companion
    local restPosition = player:getPos() * 16 + vec(0, 32, 0)
    local offset = restPosition - MODEL:getPos()
    local target = restPosition - (offset/offset:length())*32
    MODEL:setPos(math.lerp(MODEL:getPos(), target, 0.1))

    -- Anchor particles to the black hole
    confetti.modelinstances:setPos(MODEL:getPos())
end





local nameTagMode = "black hole"
local colorTypeAction = nil

function pings.switchColorType()
    if colorType == "orange" then
        colorType = "blue"
        colorTypeAction:title('[{"text":"Color Mode\n"},{"text":"- Custom HSV Color (Set at the top of script.lua)\n"},{"text":"- Blue\n", "bold":true},{"text":"- Rainbow\n"},{"text":"- White\n"},{"text":"- Black"}]')
    elseif colorType == "blue" then
        colorType = "rainbow"
        colorTypeAction:title('[{"text":"Color Mode\n"},{"text":"- Custom HSV Color (Set at the top of script.lua)\n"},{"text":"- Blue\n"},{"text":"- Rainbow\n", "bold":true},{"text":"- White\n"},{"text":"- Black"}]')
    elseif colorType == "rainbow" then
        colorType = "white"
        colorTypeAction:title('[{"text":"Color Mode\n"},{"text":"- Custom HSV Color (Set at the top of script.lua)\n"},{"text":"- Blue\n"},{"text":"- Rainbow\n"},{"text":"- White\n", "bold":true},{"text":"- Black"}]')
    elseif colorType == "white" then
        colorType = "black"
        colorTypeAction:title('[{"text":"Color Mode\n"},{"text":"- Custom HSV Color (Set at the top of script.lua)\n"},{"text":"- Blue\n"},{"text":"- Rainbow\n"},{"text":"- White\n"},{"text":"- Black", "bold":true}]')
    elseif colorType == "black" then
        colorType = "orange"
        colorTypeAction:title('[{"text":"Color Mode\n"},{"text":"- Custom HSV Color (Set at the top of script.lua)\n", "bold":true},{"text":"- Blue\n"},{"text":"- Rainbow\n"},{"text":"- White\n"},{"text":"- Black"}]')
    end
end

local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

colorTypeAction = mainPage:newAction()
    :title('[{"text":"Color Mode\n"},{"text":"- Custom HSV Color (Set at the top of script.lua)\n", "bold":true},{"text":"- Blue\n"},{"text":"- Rainbow\n"},{"text":"- White\n"},{"text":"- Black"}]')
    :item("minecraft:black_concrete")
    :onLeftClick(function()
        pings.switchColorType()
        sounds:playSound("ui.button.click", player:getPos()*16, 1, 2)
    end)
