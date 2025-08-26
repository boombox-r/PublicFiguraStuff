-- This model just kinda works, I havent tested it in multiplayer too much so expect desync (will be fixed at some point)

-- Vanilla Model
vanilla_model.ALL:setVisible(false)
vanilla_model.all:setScale(0)
nameplate.ENTITY:setVisible(false)

local confetti = require("confetti")
local MODEL = models.model
local frame = 0;
local nameplateTask = nil
local viewer = client:getViewer()
local nameText = "Ominous Black Hole"
local colorType = "orange"

-- Custom HSV Color is default 0.1, 1, 1 (orange)
local CUSTOM_HSV_COLOR = vec(0.1, 1, 1)
local centerColor   = vec(1, 1, 1)
local outlineColor  = vec(1, 1, 1)
local ringColor     = vec(1, 1, 1)
local particleColor = vec(1, 1, 1)
local nameColor     = vec(1, 1, 1)

confetti.registerMesh("black_hole", models.particles.black_hole, 15)

-- Helper Functions
function randomVec(scale)
    return vec((math.random()-0.5)*scale,(math.random()-0.5)*scale,(math.random()-0.5)*scale) 
end

function hsvToRgb(h, s, v)
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6

    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    elseif i == 5 then
        r, g, b = v, p, q
    end

    return r, g, b
end

function rgbToHex(vec)
    local r_hex = string.format("%02X", math.floor(vec.x * 255))
    local g_hex = string.format("%02X", math.floor(vec.y * 255))
    local b_hex = string.format("%02X", math.floor(vec.z * 255))

    return "#" .. r_hex .. g_hex .. b_hex
end

function lerp(a, b, x)
    return a + (b - a) * x
end





-- Events
function events.tick()
    
    if world:getTime() % 2 ~= 0 then return end

    -- Particle Spawning
    local r, g, b = hsvToRgb(frame, 1, 1)
    local vector = randomVec(1)

    confetti.newParticle(
        "black_hole",
        MODEL.World.center:partToWorldMatrix():apply() + vector * 2,
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
    MODEL.World.outline:setPrimaryRenderType("CUTOUT_CULL")
    models.particles.black_hole:setPrimaryRenderType("CUTOUT_CULL")
    animations.model.rotate:play()
    renderer:setShadowRadius(0)
end

function events.render(delta)

    -- Create the nameplate if it doesnt exist
    if nameplateTask == nil then
        nameplateTask = MODEL.World.Camera:newText("nameplate")
            :setText('{"text":"Ominous Black Hole","color":"#FF0000"}')
            :setPos(0, 0, 0)
            :setScale(0.3)
            :setAlignment("CENTER")
            :setOutline(true)
            :setLight(15)
    end

    -- Time counter im too lazy to rename to time
    frame = frame + 0.002*delta

    -- Update Colors
    local r, g, b = nil
    if colorType == "orange" then
        r, g, b = hsvToRgb(CUSTOM_HSV_COLOR.x, CUSTOM_HSV_COLOR.y, CUSTOM_HSV_COLOR.z)
        centerColor = vec(0, 0, 0)
        outlineColor = vec(r, g, b)
        ringColor = vec(r, g, b)
        particleColor = vec(r, g, b)
        nameColor = vec(r, g, b)
    elseif colorType == "blue" then
        r, g, b = hsvToRgb(0.561, 0.5, 1)
        centerColor = vec(0, 0, 0)
        outlineColor = vec(r, g, b)
        ringColor = vec(r, g, b)
        particleColor = vec(r, g, b)
        nameColor = vec(r, g, b)
    elseif colorType == "rainbow" then
        r, g, b = hsvToRgb(frame, 1, 1)
        centerColor = vec(0, 0, 0)
        outlineColor = vec(r, g, b)
        ringColor = vec(r, g, b)
        particleColor = vec(r, g, b)
        nameColor = vec(r, g, b)
    elseif colorType == "white" then
        r, g, b = hsvToRgb(0, 0, 1)
        centerColor = vec(0, 0, 0)
        outlineColor = vec(r, g, b)
        ringColor = vec(r, g, b)
        particleColor = vec(r, g, b)
        nameColor = vec(r, g, b)
    elseif colorType == "black" then
        centerColor = vec(1, 1, 1)
        outlineColor = vec(0, 0, 0)
        ringColor = vec(0, 0, 0)
        particleColor = vec(0, 0, 0)
        nameColor = vec(0, 0, 0)
    end

    MODEL.World.center:setColor(centerColor)
    MODEL.World.outline:setColor(outlineColor)
    MODEL.World.ring:setColor(ringColor)
    nameplateTask:setText('{"text":"' .. nameText ..'","color":"' .. rgbToHex(nameColor) .. '"}')

    -- Interpolate position to the player
    MODEL.World:setPos(lerp(MODEL.World:getPos(), player:getPos()*16+vec(0, 16, 0), 0.1*delta))
end





local nameTagMode = "black hole"
local nameTypeAction = nil
local colorTypeAction = nil

function pings.switchNameTagMode()
    if nameTagMode == "black hole" then
        nameTagMode = "username"
        nameTypeAction:title('[{"text":"Name Tag Mode\n"},{"text":"- Ominous Black Hole\n"},{"text":"- Player Name\n","bold":true},{"text":"- Off"}]')
        nameText = player:getName()
    elseif nameTagMode == "username" then
        nameTagMode = "off"
        nameTypeAction:title('[{"text":"Name Tag Mode\n"},{"text":"- Ominous Black Hole\n- Player Name\n"},{"text":"- Off", "bold":true}]')
        nameText = ""
    elseif nameTagMode == "off" then
        nameTagMode = "black hole"
        nameTypeAction:title('[{"text":"Name Tag Mode\n"},{"text":"- Ominous Black Hole\n", "bold":true},{"text":"- Player Name\n- Off"}]')
        nameText = "Ominous Black Hole"
    end
end

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

nameTypeAction = mainPage:newAction()
    :title('[{"text":"Name Tag Mode\n"},{"text":"- Ominous Black Hole\n", "bold":true},{"text":"- Player Name\n- Off"}]')
    :item("minecraft:name_tag")
    :onLeftClick(function()
        pings.switchNameTagMode()
        sounds:playSound("ui.button.click", player:getPos()*16, 1, 2)
    end)

colorTypeAction = mainPage:newAction()
    :title('[{"text":"Color Mode\n"},{"text":"- Custom HSV Color (Set at the top of script.lua)\n", "bold":true},{"text":"- Blue\n"},{"text":"- Rainbow\n"},{"text":"- White\n"},{"text":"- Black"}]')
    :item("minecraft:black_concrete")
    :onLeftClick(function()
        pings.switchColorType()
        sounds:playSound("ui.button.click", player:getPos()*16, 1, 2)
    end)
