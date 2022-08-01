--[[
	LUA PARAMETERS
]]
fontSize = 20 --export: the size of the text for all the screen
maxVolumeForHub = 0 --export: the max volume from a hub (can't get it from the lua) if 0, the content volume will be displayed on the screen
verticalMode = false --export: rotate the screen 90deg
verticalModeBottomSide = "right" --export: when vertical mode is enabled, on which side the bottom of the screen is positioned ("left" or "right")
--[[
	INIT
]]

local version = '1.6.1'

system.print("------------------------------------")
system.print("DU-Container-Monitoring version " .. version)
system.print("------------------------------------")

local renderScript = [[
local json = require('dkjson')
local data = json.decode(getInput()) or {}
local vmode = ]] .. tostring(verticalMode) .. [[

local vmode_side = "]] .. verticalModeBottomSide .. [["
if items == nil or data[1] then items = {} end
if page == nil or data[1] then page = 1 end
local images = {}

if data[5] ~= nil then
    items[data[5][1] ] = data[5]
    setOutput(data[5][1])
    data[5] = nil
end
local loadedImages = 0
for _,item in ipairs(items) do
    if images[item[2] ] == nil and loadedImages <= 15 then
        loadedImages = loadedImages + 1
        images[item[2] ] = loadImage(item[5])
    end
end

local rx,ry
if vmode then
	ry,rx = getResolution()
else
	rx,ry = getResolution()
end

local back=createLayer()
local front=createLayer()

font_size = ]] .. fontSize .. [[

local small=loadFont('Play',14)
local smallBold=loadFont('Play-Bold',18)
local itemName=loadFont('Play-Bold',font_size)
local big=loadFont('Play',38)

setBackgroundColor( 15/255,24/255,29/255)

setDefaultStrokeColor( back,Shape_Line,0,0,0,0.5)
setDefaultShadow( back,Shape_Line,6,0,0,0,0.5)

setDefaultFillColor( front,Shape_BoxRounded,249/255,212/255,123/255,1)
setDefaultFillColor( front,Shape_Text,0,0,0,1)
setDefaultFillColor( front,Shape_Box,0.075,0.125,0.156,1)
setDefaultFillColor( front,Shape_Text,0.710,0.878,0.941,1)

function format_number(a)local b=a;while true do b,k=string.gsub(b,"^(-?%d+)(%d%d%d)",'%1 %2')if k==0 then break end end;return b end

function round(a,b)if b then return utils.round(a/b)*b end;return a>=0 and math.floor(a+0.5)or math.ceil(a-0.5)end

function getRGBGradient(a,b,c,d,e,f,g,h,i,j)a=-1*math.cos(a*math.pi)/2+0.5;local k=0;local l=0;local m=0;if a>=.5 then a=(a-0.5)*2;k=e-a*(e-h)l=f-a*(f-i)m=g-a*(g-j)else a=a*2;k=b-a*(b-e)l=c-a*(c-f)m=d-a*(d-g)end;return k,l,m end



local storageBar = createLayer()
setDefaultFillColor(storageBar,Shape_Text,110/255,166/255,181/255,1)
setDefaultFillColor(storageBar,Shape_Box,0.075,0.125,0.156,1)
setDefaultFillColor(storageBar,Shape_Line,1,1,1,1)

local buttonHover = createLayer()
setDefaultFillColor(buttonHover,Shape_Box,249/255,212/255,123/255,1)
setDefaultFillColor(buttonHover,Shape_Text,0,0,0,1)

local colorLayer = createLayer()
local imagesLayer = createLayer()

if vmode then
    local r = 90
    local tx = ry
    local ty = 0
    if vmode_side == "left" then
        r = r + 180
        tx = 0
        ty = rx
    end
    setLayerTranslation(back, tx,ty)
    setLayerRotation(back, math.rad(r))
    setLayerTranslation(front, tx, ty)
    setLayerRotation(front, math.rad(r))
    setLayerTranslation(storageBar, tx, ty)
    setLayerRotation(storageBar, math.rad(r))
    setLayerTranslation(colorLayer, tx, ty)
    setLayerRotation(colorLayer, math.rad(r))
    setLayerTranslation(imagesLayer, tx, ty)
    setLayerRotation(imagesLayer, math.rad(r))
    setLayerTranslation(buttonHover, tx, ty)
    setLayerRotation(buttonHover, math.rad(r))
end
local percent_fill = 0
local r = 110/255
local g = 166/255
local b = 181/255
if data[2] > 0 then
    percent_fill = data[3]*100/data[2]
    if percent_fill > 100 then percent_fill = 100 end
    r,g,b = getRGBGradient(percent_fill/100,177/255,42/255,42/255,249/255,212/255,123/255,34/255,177/255,76/255)
end
setDefaultFillColor(colorLayer,Shape_Box,r,g,b,1)
setDefaultFillColor(colorLayer,Shape_Text,r,g,b,1)
setDefaultTextAlign(colorLayer, AlignH_Center, AlignV_Middle)

local from_side = rx*0.05
function renderHeader(title)
    local h = 35
    addLine(back,0,h+12,rx,h+12)
    addBox(front,0,12,rx,h)
    addText(front,smallBold,title,from_side,h)
end
function renderFooter()
    local h = 35
    local y=ry-h-25
    addLine(back,0,y+h+12,rx,y+h+12)
    addBox(front,0,y+12,rx,h)
    setNextTextAlign(front, AlignH_Right, AlignV_Bottom)
    addText(front,small,"Next query possible in " .. round(data[4]) .. ' seconds',rx-from_side,y+h+2)
end
function renderProgressBar(percent)
    if data[2] > 0 then
        addText(colorLayer, itemName, format_number(round(percent*100)/100) .."%", rx/2, 90)
        local w=(rx-2-from_side*2)*(percent)/100
        local x=from_side
        local y=55
        local h=25
        addBox(storageBar,x,y,rx-from_side*2,h)
        addBox(colorLayer,x+1,y+1,w,h-2)
    else
        addText(colorLayer, itemName, format_number(round(data[3]*100)/100) .." L", rx/2, 80)
    end
end
function renderResistanceBar(item_id, title, quantity, x, y, w, h, withTitle, withIcon)
    local quantity_x_pos = font_size * 6.7
    local percent_x_pos = font_size * 2
    addBox(storageBar,x,y,w,h)
    if withTitle then
        addText(storageBar, small, "ITEMS", x, y-5)
        setNextTextAlign(storageBar, AlignH_Right, AlignV_Bottom)
        addText(storageBar, small, "QUANTITY", rx-x, y-5)
    end
    if item_id and tonumber(item_id) > 0 and images[item_id] and withIcon then
        addImage(imagesLayer, images[item_id], x+10, y+font_size*.1, font_size*1.3, font_size*1.2)
    end

    local pos_y = y+(h/2)-2

    setNextTextAlign(storageBar, AlignH_Left, AlignV_Middle)
    addText(storageBar, itemName, title, x+20+font_size, pos_y)

    setNextTextAlign(storageBar, AlignH_Right, AlignV_Middle)
    addText(storageBar, itemName, format_number(quantity), rx-from_side-10, pos_y)
end

renderHeader('Container Monitoring v]] .. version .. [[')

renderFooter()

start_h = 100

local h = font_size + font_size / 2
local byPage = math.floor((ry-180)/(h+5))
local max_pages = math.ceil(#items/byPage)
local end_index = page * byPage
local start_index = end_index - byPage + 1

local item_to_display = {}
for index = start_index, end_index do
    table.insert(item_to_display, items[index])
end

for i,item in ipairs(item_to_display) do
    renderResistanceBar(item[2], item[3], item[4], from_side, start_h, rx-from_side*2, h, i==1, i<=16)
    start_h = start_h+h+5
    if i >= byPage then
        break
    end
end
if #items > byPage then
    setNextTextAlign(storageBar, AlignH_Center, AlignV_Middle)
    local paginationText = 'page ' .. page .. '/' .. max_pages
    if rx > ry then
        paginationText = paginationText .. " (from " .. start_index .. " to " .. end_index .. " on " .. #items .. ")"
    end
    addText(storageBar, itemName, paginationText , rx/2, ry-70)
    local cx, cy = getCursor()
    if vmode then
        cy, cx = getCursor()
        cx = rx - cx
        if vmode_side == "right" then
            cy = ry - cy
            cx = rx - cx
        end
    end
    if page > 1 then
        local b1_layer = storageBar
        if cx >= from_side and cx <= (from_side+h) and cy >= (ry-85) and cy <= (ry-85+h) then
            if getCursorPressed() then
                page = page - 1
            end
            b1_layer = buttonHover
        end
        addBox(b1_layer, from_side, ry-85, h, h)
        addText(b1_layer, itemName, '<' , from_side+h/4, ry-65)
    end
    if page < max_pages then
        local b2_layer = storageBar
        if cx >= (rx-from_side-h) and cx <= (rx-from_side) and cy >= (ry-85) and cy <= (ry-85+h) then
            if getCursorPressed() then
                page = page + 1
            end
            b2_layer = buttonHover
        end
        addBox(b2_layer, rx-from_side-h, ry-85, h, h)
        addText(b2_layer, itemName, '>' , rx-from_side-h+h/4, ry-65)
    end
end
renderProgressBar(percent_fill)
requestAnimationFrame(100)
]]

screens = {}
databank = nil
for slot_name, slot in pairs(unit) do
    if type(slot) == "table"
            and type(slot.export) == "table"
            and slot.getClass
    then
        if
            slot.getClass():lower() == 'screenunit'
            or slot.getClass():lower() == 'screensignunit'
        then
            slot.slotname = slot_name
            table.insert(screens,slot)
            slot.setRenderScript(renderScript)
        elseif slot.getClass():lower() == 'databankunit' then
            databank = slot
        end
    end
end
if #screens == 0 then
    system.print("No Screen Detected")
    unit.exit()
else
    table.sort(screens, function(a,b) return a.slotname < b.slotname end)
    local plural = ""
    if #screens > 1 then plural = "s" end
    system.print(#screens .. " screen" .. plural .. " Connected")
end
if container == nil then
    system.print('No Container or Hub dectected')
    unit.exit()
else
    system.print('Storage connected')
end

screen_data={0,0,0,{}}
request_time = 0
items = {}
update_screen = false

--[[
    DU-Nested-Coroutines by Jericho
    Permit to easier avoid CPU Load Errors
    Source available here: https://github.com/Jericho1060/du-nested-coroutines
]]--

coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        request_time = math.ceil(container.updateContent())
        local max_vol = container.getMaxVolume()
        if max_vol == 0 then
            max_vol = maxVolumeForHub
        end
        local screen_data = {update_screen, max_vol, container.getItemsVolume(), request_time, nil}
        if update_screen then
            for i,item in ipairs(items) do
                screen_data[5] = {
                    i,
                    item[1],
                    item[2],
                    item[3],
                    item[4]
                }
                for _,s in pairs(screens) do
                    s.setScriptInput(json.encode(screen_data))
                    while tonumber(s.getScriptOutput()) ~= i do
                        coroutine.yield(coroutinesTable[1])
                    end
                end
                update_screen = false
                screen_data[1] = false
            end
            unit.exit()
        else
            for _,s in pairs(screens) do
                s.setScriptInput(json.encode(screen_data))
            end
        end
    end,
}

function initCoroutines()
    for _,f in pairs(MyCoroutines) do
        local co = coroutine.create(f)
        table.insert(coroutinesTable, co)
    end
end

initCoroutines()

runCoroutines = function()
    for i,co in ipairs(coroutinesTable) do
        if coroutine.status(co) == "dead" then
            coroutinesTable[i] = coroutine.create(MyCoroutines[i])
        end
        if coroutine.status(co) == "suspended" then
            assert(coroutine.resume(co))
        end
    end
end

MainCoroutine = coroutine.create(runCoroutines)
