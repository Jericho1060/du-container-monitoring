local list = container.getContent()
screen_data[4] = {}
for k, v in ipairs(list) do
    local quantity = math.floor(v.quantity*100)/100
    local item = system.getItem(v.id)
    local item_data = {
        v.id,
        item.displayNameWithSize,
        quantity
    }
    table.insert(screen_data[4], item_data)
end