# du-container-monitoring
 A script for Dual Universe that is displaying the content of a single container on up to 9 screens

![Img002](https://github.com/Jericho1060/du-container-monitoring/blob/main/du-container-monitoring-2.png?raw=true)

| Horizontal View | Vertical View                                                                                                      |
|-----------------|--------------------------------------------------------------------------------------------------------------------|
| ![Img001](https://github.com/Jericho1060/du-container-monitoring/blob/main/du-container-monitoring-1.png?raw=true) | ![Img003](https://github.com/Jericho1060/du-container-monitoring/blob/main/du-container-monitoring-3.png?raw=true) |


# Edit the code

[![img](https://du-lua.dev/img/open_in_editor_button.png)](https://du-lua.dev/#/editor/github/Jericho1060/du-container-monitoring)

# Discord Server

You can join me on Discord for help or suggestions or requests by following that link : https://discord.gg/qkdjyqDZQZ

# Installation

### Required elements

- screen: 1 (up to 9)
- programming board: 1
- container: 1

### Links

First link the container to the programming board. IMPORTANT, this must be the first link you are doing, the container MUST be on slot 1.

Then you can connect screens, at least one is required but if you want to display the content on several places, you can link several screens.

### Installing the script

Copy the content of the file config.json then right clik on the board, chose advanced and click on "Paste Lua configuraton from clipboard"

### Options

By rightclicking on the board, advanced, edit lua parameters, you can customize these options:

- `fontSize`: the size of the text for all the screen
- `maxVolumeForHub`: the max volume from a hub (can't get it from the lua) if 0, the content volume will be displayed on the screen
- `verticalMode`: rotate the screen 90deg
- `verticalModeBottomSide`: when vertical mode is enabled, on which side the bottom of the screen is positioned (`left` or `right`)
- `defaultSorting`: The default sorting of items on the screen. Valid options are:
    - `none`: like in the container, 
    - `items-asc`: ascending sorting on the name,
    - `items-desc`: descending sorting on the name,
    - `quantity-asc`: ascending on the quantity, "quantity-desc": descending on the quantity

# Support or donation

if you like it, [<img src="https://github.com/Jericho1060/DU-Industry-HUD/blob/main/ressources/images/ko-fi.png?raw=true" width="150">](https://ko-fi.com/jericho1060)

You can also donate in game by sending credits to `jericho1060`
