--[[
	LUA PARAMETERS
]]
fontSize = 20 --export: the size of the text for all the screen
maxVolumeForHub = 0 --export: the max volume from a hub (can't get it from the lua) if 0, the content volume will be displayed on the screen
--vertical mode code based on a suggestion by Merl
verticalMode = false --export: rotate the screen 90deg (bottom on right)
--[[
	INIT
]]

local version = '1.3.1'

system.print("------------------------------------")
system.print("DU-Container-Monitoring version " .. version)
system.print("------------------------------------")

local renderScript = [[
local json = require('dkjson')
local data = json.decode(getInput()) or {}
local vmode = ]] .. tostring(verticalMode) .. [[

if items == nil or data[1] then items = {} end
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

function renderHeader(title)
    local h_factor = 12
    local h = 35
    if subtitle ~= nil and subtitle ~= "" and subtitle ~= "-" then
        h = 50
    end
    addLine( back,0,h+12,rx,h+12)
    addBox(front,0,12,rx,h)
    addText(front,small,"Next query possible in " .. round(data[4]) .. ' seconds',rx-250,35)
    addText(front,smallBold,title,44,35)
end

local storageBar = createLayer()
setDefaultFillColor(storageBar,Shape_Text,110/255,166/255,181/255,1)
setDefaultFillColor(storageBar,Shape_Box,0.075,0.125,0.156,1)
setDefaultFillColor(storageBar,Shape_Line,1,1,1,1)

local colorLayer = createLayer()
local imagesLayer = createLayer()
if vmode then
    local from_top = 10
    setLayerTranslation(back, ry-from_top,0)
    setLayerRotation(back, math.rad(90))
    setLayerTranslation(front, ry-from_top,0)
    setLayerRotation(front, math.rad(90))
    setLayerTranslation(storageBar, ry-from_top,0)
    setLayerRotation(storageBar, math.rad(90))
    setLayerTranslation(colorLayer, ry-from_top,0)
    setLayerRotation(colorLayer, math.rad(90))
    setLayerTranslation(imagesLayer, ry-from_top,0)
    setLayerRotation(imagesLayer, math.rad(90))
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

function renderProgressBar(percent)
    if data[2] > 0 then
        addText(colorLayer, itemName, format_number(round(percent*100)/100) .."%", rx/2, 90)
        local w=(rx-90)*(percent)/100
        local x=44
        local y=55
        local h=25
        addBox(storageBar,x,y,rx-88,h)
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
        addText(storageBar, small, "QUANTITY", x+w-15, y-5)
    end
    if item_id and tonumber(item_id) > 0 and images[item_id] and withIcon then
        addImage(imagesLayer, images[item_id], x+10, y+font_size*.1, font_size*1.3, font_size*1.2)
    end

    local pos_y = y+(h/2)-2

    setNextTextAlign(storageBar, AlignH_Left, AlignV_Middle)
    addText(storageBar, itemName, title, x+20+font_size, pos_y)

    setNextTextAlign(storageBar, AlignH_Right, AlignV_Middle)
    addText(storageBar, itemName, format_number(quantity), w+30, pos_y)
end

renderHeader('Container Monitoring v]] .. version .. [[')

start_h = 100


local h = font_size + font_size / 2
for i,item in ipairs(items) do
    renderResistanceBar(item[2], item[3], item[4], 44, start_h, rx-88, h, i==1, i<=16)
    start_h = start_h+h+5
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
        if slot.getClass():lower() == 'screenunit' then
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
