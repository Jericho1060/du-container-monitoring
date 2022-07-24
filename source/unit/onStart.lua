--[[
	LUA PARAMETERS
]]
fontSize = 20 --export: the size of the text for all the screen
--[[
	INIT
]]

local version = '1.0.0'

system.print("------------------------------------")
system.print("DU-Container-Monitoring version " .. version)
system.print("------------------------------------")

local renderScript = [[
local json = require('dkjson')
local data = json.decode(getInput()) or {}

local rx,ry = getResolution()

local back=createLayer()
local front=createLayer()

font_size = ]] .. fontSize .. [[

local mini=loadFont('Play',12)
local small=loadFont('Play',14)
local smallBold=loadFont('Play-Bold',18)
local itemName=loadFont('Play-Bold',font_size)
local medV=loadFont('Play-Bold', 25)
local bigV=loadFont('Play-Bold', 30)
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
    addText(front,small,"Next query possible in " .. round(data[3]) .. ' seconds',rx-250,35)
    addText(front,smallBold,title,44,35)
end

local storageBar = createLayer()
setDefaultFillColor(storageBar,Shape_Text,110/255,166/255,181/255,1)
setDefaultFillColor(storageBar,Shape_Box,0.075,0.125,0.156,1)
setDefaultFillColor(storageBar,Shape_Line,1,1,1,1)

local storageDark = createLayer()
setDefaultFillColor(storageDark,Shape_Text,63/255,92/255,102/255,1)
setDefaultFillColor(storageDark,Shape_Box,13/255,24/255,28/255,1)

local colorLayer = createLayer()

function renderProgressBar(percent)
    local r,g,b = getRGBGradient(percent/100,177/255,42/255,42/255,249/255,212/255,123/255,34/255,177/255,76/255)
    setNextFillColor(colorLayer, r, g, b, 1)
    setNextTextAlign(colorLayer, AlignH_Center, AlignV_Middle)
    addText(colorLayer, itemName, format_number(round(percent*100)/100) .."%", rx/2, 90)
    local w = (rx-90)*(percent)/100
    local x=44
    local y=55
    local h=25
    addBox(storageBar,x,y,rx-88,h)
    setNextFillColor(colorLayer, r, g, b, 1)
    addBox(colorLayer,x+1,y+1,w,h-2)
end

function renderResistanceBar(title, quantity, x, y, w, h, withTitle)

    local quantity_x_pos = font_size * 6.7
    local percent_x_pos = font_size * 2

    addBox(storageBar,x,y,w,h)

    if withTitle then
        addText(storageBar, small, "ITEMS", x, y-5)
        setNextTextAlign(storageBar, AlignH_Right, AlignV_Middle)
        addText(storageBar, small, "QUANTITY", x+w-15, y-5)
    end

    local pos_y = y+(h/2)-2

    setNextTextAlign(storageBar, AlignH_Left, AlignV_Middle)
    addText(storageBar, itemName, title, x+10, pos_y)

    --setNextFillColor(colorLayer, r, g, b, 1)
    setNextTextAlign(storageBar, AlignH_Right, AlignV_Middle)
    addText(storageBar, itemName, format_number(quantity), w+30, pos_y)
end

renderHeader('Container Monitoring v]] .. version .. [[')

start_h = 100


local h = font_size + font_size / 2
for i,container in ipairs(data[4]) do
    renderResistanceBar(container[2], container[3], 44, start_h, rx-88, h, i==1)
    start_h = start_h+h+5
end
renderProgressBar(data[2]*100/data[1])
requestAnimationFrame(10)
]]

screens = {}
for slot_name, slot in pairs(unit) do
    if
    type(slot) == "table"
            and type(slot.export) == "table"
            and slot.getClass
    then
        if slot.getClass():lower() == 'screenunit' then
            slot.slotname = slot_name
            table.insert(screens,slot)
            slot.setRenderScript(renderScript)
        end
    end
end
if #screens == 0 then
    system.print("No Screen Detected")
else
    table.sort(screens, function(a,b) return a.slotname < b.slotname end)
    local plural = ""
    if #screens > 1 then plural = "s" end
    system.print(#screens .. " screen" .. plural .. " Connected")
end
if container == nil then
    system.print('No Container or Hub dectected')
else
    system.print('Storage connected')
end
screen_data={0,0,0,{}}
request_time = container.updateContent()
unit.setTimer("acquireStorage", 1)