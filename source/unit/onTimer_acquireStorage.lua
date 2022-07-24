request_time = container.updateContent()
screen_data[1] = container.getMaxVolume()
screen_data[2] = container.getItemsVolume()
screen_data[3] = request_time
for _,s in pairs(screens) do
    s.setScriptInput(json.encode(screen_data))
end