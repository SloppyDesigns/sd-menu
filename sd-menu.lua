--            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
--                    Version 2, December 2004
--
--      Copyright (C) 2022 Sloppy Designs <https://discord.gg/xea3U8HH47>
--
--      Everyone is permitted to copy and distribute verbatim or modified
--      copies of this license document, and changing it is allowed as long
--      as the name is changed.
--
--                DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
--      TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
--
--              0. You just DO WHAT THE FUCK YOU WANT TO.


sdmenu = sdmenu or {}
sdmenu.autodetect = Config.SDAutoVersion or false
local ResourceName = GetCurrentResourceName()

local function tPrint(tbl, indent)
    indent = indent or 0
    if type(tbl) == 'table' then
        for k, v in pairs(tbl) do
            local tblType = type(v)
            local formatting = ("%s ^3%s:^0"):format(string.rep("  ", indent), k)

            if tblType == "table" then
                print(formatting)
                tPrint(v, indent + 1)
            elseif tblType == 'boolean' then
                print(("%s^1 %s ^0"):format(formatting, v))
            elseif tblType == "function" then
                print(("%s^9 %s ^0"):format(formatting, v))
            elseif tblType == 'number' then
                print(("%s^5 %s ^0"):format(formatting, v))
            elseif tblType == 'string' then
                print(("%s ^2'%s' ^0"):format(formatting, v))
            else
                print(("%s^2 %s ^0"):format(formatting, v))
            end
        end
    else
        print(("%s ^0%s"):format(string.rep("  ", indent), tbl))
    end
end

local function exportHandler(resource, exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format(resource, exportName), function(cb)
        cb(func)
    end)
end

local function GetMenuVersion()
    if GetResourceState('nh-context') == "started" then
        if pcall(function() exports["nh-context"]:CancelMenu() end) then
            return 'v2'
        else
            return 'v1'
        end
    elseif GetResourceState('zf_context') == "started" then
        return 'zf'
    elseif GetResourceState('qb-menu') == "started" then
        return 'qb'
    elseif GetResourceState('ox_lib') == "started" then
        return 'ox'
    end
end

local function GetInputVersion()
    if GetResourceState('nh-keyboard') == "started" then
        if pcall(function() exports["nh-keyboard"]:CancelKeyboard() end) then
            return 'v2'
        else
            return 'v1'
        end
    elseif GetResourceState('zf_dialog') == "started" then
        return 'zf'
    elseif GetResourceState('qb-input') == "started" then
        return 'qb'
    elseif GetResourceState('ox_lib') == "started" then
        return 'ox'
    end
end

sdmenu.menuVersion = (sdmenu.autodetect and GetMenuVersion() or Config.SDMenuVersion)
sdmenu.inputVersion = (sdmenu.autodetect and GetInputVersion() or Config.SDInputVersion)

local function FontAwesomeIcon(icon)
    result = {};
    for match in (icon.." "):gmatch("(.-)".." ") do
        table.insert(result, match);
    end

    if sdmenu.icons[result[1]] and sdmenu.icons[result[1]][result[2]] then
        return sdmenu.icons[result[1]][result[2]]
    else
        print(('^3Warning: Icon was not found: "%s"'):format(icon))
        return ""
    end
end

local function Unpack(arguments, i)
    if not arguments then return end
    local index = i or 1

    if index <= #arguments then
        return arguments[index], Unpack(arguments, index + 1)
    end
end

local function UnpackInput(arguments, i)
    if not arguments then return end
    local index = i or 1
    
    if index <= #arguments then
        return arguments[index].input, UnpackInput(arguments, index + 1)
    end
end

-- Create Menu
local function CreateMenu(data)
    local menuData = {}
    local menuHeader = nil
    for _, v in pairs(data) do
        local menuId = #menuData+1
        if v.icon and v.icon ~= "" and sdmenu.menuVersion ~= 'qb' and sdmenu.menuVersion ~= 'ox' then
            menuData[menuId] = {
                header = '<img style="'..sdmenu.iconColor..'" width="'..sdmenu.iconSize..'" height="'..sdmenu.iconSize..'" src="'..FontAwesomeIcon(v.icon)..'"</img>&nbsp;&nbsp;'..(v.header or ''),
            }
        elseif sdmenu.menuVersion ~= 'ox' then
            menuData[menuId] = {
                header = v.header or '',
            }
        end
        if sdmenu.menuVersion == 'v1' then
            menuData[menuId].id = menuId
            menuData[menuId].txt = v.txt or ''

            if v.params then
                menuData[menuId].params = {}
                menuData[menuId].params.arg1 = {}
                if v.params and v.params.event then
                    menuData[menuId].params.event = ResourceName .. ':interceptor'
                    menuData[menuId].params.arg1.event = v.params.event
                end

                if v.params and v.params.server then
                    menuData[menuId].params.arg1.server = v.params.server
                end

                if v.params and v.params.args then
                    menuData[menuId].params.arg1.arguments = v.params.args
                else
                    menuData[menuId].params.arg1.arguments = {}
                end
            end
        elseif sdmenu.menuVersion == 'zf' then
            menuData[menuId].id = menuId
            menuData[menuId].txt = v.txt or ''

            menuData[menuId].params = {}
            menuData[menuId].params.args = {}
            if v.params and v.params.event then
                menuData[menuId].params.event = ResourceName .. ':interceptor'
                menuData[menuId].params.args.event = v.params.event
            end

            if v.params and v.params.server then
                 menuData[menuId].params.args.server = v.params.server
            end

            if v.params and v.params.args then
                menuData[menuId].params.args.arguments = {}
                menuData[menuId].params.args.arguments = v.params.args
            else
                menuData[menuId].params.args.arguments = {}
            end
        elseif sdmenu.menuVersion == 'v2' then
            menuData[menuId].context = v.txt or ''
            menuData[menuId].server = v.params and v.params.server or false
            menuData[menuId].event = v.params and v.params.event or ''
            if v.disabled then menuData[menuId].disabled = true end
            if v.params and v.params.args then
                menuData[menuId].args = v.params.args
            end
        elseif sdmenu.menuVersion == 'qb' then
            menuData[menuId].txt = v.txt or ''
            menuData[menuId].icon = v.icon or ''
             if v.disabled then menuData[menuId].disabled = true end

            menuData[menuId].params = {}
            menuData[menuId].params.args = {}
            if v.params and v.params.event then
                menuData[menuId].params.event = ResourceName .. ':interceptor'
                menuData[menuId].params.args.event = v.params.event
            end

            if v.params and v.params.server then
                menuData[menuId].params.args.server = v.params.server
            end

            if v.params and v.params.args then
                menuData[menuId].params.args.arguments = v.params.args
            else
                menuData[menuId].params.args.arguments = {}
            end
        elseif sdmenu.menuVersion == 'ox' then
            if v.header and not v.params and menuHeader == nil then
                menuHeader = v.header
            else
                if v.header and v.txt then
                    menuData[menuId] = {
                        title = v.header,
                        description = v.txt
                    }
                elseif v.header and not v.txt then
                    menuData[menuId] = {
                        title = v.header,
                    }
                elseif not v.header and v.txt then
                    menuData[menuId] = {
                        title = v.txt,
                    }
                end
                menuData[menuId].args = {}
                if v.params and v.params.event then
                    menuData[menuId].event = ResourceName .. ':interceptor'
                    menuData[menuId].args.event = v.params.event
                end
                if v.params and v.params.server then
                    menuData[menuId].args.server = v.params.server
                end
                if v.params and v.params.args then
                    menuData[menuId].args.arguments = v.params.args
                else
                    menuData[menuId].args.arguments = {}
                end
                if v.icon then
                    menuData[menuId].icon = v.icon
                end
            end
        end
    end
    if sdmenu.menuVersion == 'v1' then TriggerEvent('nh-context:sendMenu', menuData) end
    if sdmenu.menuVersion == 'zf' then TriggerEvent('zf_context:openMenu', menuData) end
    if sdmenu.menuVersion == 'v2' then TriggerEvent('nh-context:createMenu', menuData) return end
    if sdmenu.menuVersion == 'qb' then exports['qb-menu']:openMenu(menuData) end
    if sdmenu.menuVersion == 'ox' then
        exports.ox_lib:registerContext({ id = 'sd-menu', title = menuHeader, options = menuData })
        exports.ox_lib:showContext('sd-menu')
    end
end

-- Menu Interceptor 
RegisterNetEvent(ResourceName .. ':interceptor', function(data)
    if data.server then
        if not next(data.arguments) then
            TriggerServerEvent(data.event, {})
        else
            TriggerServerEvent(data.event, Unpack(data.arguments))
        end
    else
        if not next(data.arguments) then
            TriggerEvent(data.event, {})
        else
            TriggerEvent(data.event, Unpack(data.arguments))
        end
    end
end)

-- Create Input
local function CreateInput(data)
    local inputData = {}
    if sdmenu.inputVersion == 'v1' then
        inputData.header = data.header
        inputData.rows = {}
        local index = 0
        for k, v in pairs(data.inputs) do
            table.insert(inputData.rows, {
                id = index,
                txt = v.text
            })
            index = index + 1
        end
    elseif sdmenu.inputVersion == 'zf' then
        inputData.header = data.header
        inputData.rows = {}
        local index = 0
        for k, v in pairs(data.inputs) do
            table.insert(inputData.rows, {
                id = index,
                txt = v.text
            })
            index = index + 1
        end
    elseif sdmenu.inputVersion == 'v2' then
        inputData.header = data.header
        inputData.rows = {}
        for k, v in pairs(data.inputs) do
            table.insert(inputData.rows, v.text)
        end
    elseif sdmenu.inputVersion == 'qb' then
        inputData.header = data.header
        inputData.inputs = {}
        for k, v in pairs(data.inputs) do
            table.insert(inputData.inputs, {
                text = v.text,
                type = "text",
                name = k
            })
        end
    elseif sdmenu.inputVersion == 'ox' then
        inputData.rows = {}
        for k, v in pairs(data.inputs) do
            table.insert(inputData.rows, v.text)
        end
    end
    if sdmenu.inputVersion == 'v1' then 
        local input = exports["nh-keyboard"]:KeyboardInput(inputData)
        return input and true or false, UnpackInput(input)
    end
    if sdmenu.inputVersion == 'zf' then 
        local dialog = exports['zf_dialog']:DialogInput(inputData)
        return dialog and true or false, UnpackInput(dialog)
    end
    if sdmenu.inputVersion == 'v2' then
        return exports["nh-keyboard"]:Keyboard(inputData)
    end
    if sdmenu.inputVersion == 'qb' then
        local input = exports["qb-input"]:ShowInput(inputData)
        if input == nil then return end
        local converted_input = {}
        for k, v in pairs(input) do
            converted_input[tonumber(k)] = v
        end
        local args = {}
        for k, v in ipairs(converted_input) do
            table.insert(args, { input = v })
        end
        return input and true or false, UnpackInput(args)
    end
    if sdmenu.inputVersion == 'ox' then
        local input = exports.ox_lib:inputDialog(data.header, inputData.rows)
        if input == nil then return end
        local args = {}
        for k, v in ipairs(input) do
            table.insert(args, { input = v })
        end
        return input and true or false, UnpackInput(args)
    end
end

-- Convert Only Works Running sd-menu standalone
if ResourceName == 'sd-menu' then

    -- Convert nh-context v1
    if sdmenu.menuVersion ~= 'v1' and sdmenu.menuVersion ~= 'zf' then
        RegisterNetEvent('nh-context:sendMenu', function(data)
            local menuData = {}
            for _, v in pairs(data) do
                local menuId = #menuData+1
                menuData[menuId] = {}
                if v.header then menuData[menuId].header = v.header end
                if v.txt then menuData[menuId].txt = v.txt end
                if v.params then
                    menuData[menuId].params = {}
                    menuData[menuId].params.event = v.params.event
                    if v.params.arg1 then
                        menuData[menuId].params.args = {}
                        table.insert(menuData[menuId].params.args, v.params.arg1)
                    end
                end
            end
            CreateMenu(menuData)
        end)
    end

    -- Convert nh-keyboard v1
    if sdmenu.inputVersion ~= 'v1' then
        exportHandler('nh-keyboard', 'KeyboardInput', function(data)
            local inputData = {}
            inputData.header = data.header
            inputData.inputs = {}
            for _, v in pairs(data.rows) do
                inputData.inputs[#inputData.inputs+1] = {
                    text = v.txt
                }
            end
            local inputs = table.pack(CreateInput(inputData))
            table.remove(inputs, 1)
            local returninputs = {}
            for _, v in ipairs(inputs) do
                table.insert(returninputs, { input  = v })
            end
            return returninputs
        end)
    end

    -- Convert zf_context
    if sdmenu.menuVersion ~= 'zf' and sdmenu.menuVersion ~= 'v1' then
        RegisterNetEvent('zf_context:openMenu', function(data)
            local menuData = {}
            for _, v in pairs(data) do
                local menuId = #menuData + 1
                menuData[menuId] = {}
                if v.header then menuData[menuId].header = v.header end
                if v.txt then menuData[menuId].txt = v.txt end
                if v.params then
                    menuData[menuId].params = {}
                    menuData[menuId].params.event = v.params.event
                    if v.params.isServer then menuData[menuId].params.server = v.params.isServer end
                    if v.params.args then
                        menuData[menuId].params.args = {}
                        table.insert(menuData[menuId].params.args, v.params.args)
                    end
                end
            end
            CreateMenu(menuData)
        end)

        exportHandler('zf_context', 'openMenu', function(data)
            local menuData = {}
            for _, v in pairs(data) do
                local menuId = #menuData + 1
                menuData[menuId] = {}
                if v.header then menuData[menuId].header = v.header end
                if v.txt then menuData[menuId].txt = v.txt end
                if v.params then
                    menuData[menuId].params = {}
                    menuData[menuId].params.event = v.params.event
                    if v.params.isServer then menuData[menuId].params.server = v.params.isServer end
                    if v.params.args then
                        menuData[menuId].params.args = {}
                        table.insert(menuData[menuId].params.args, v.params.args)
                    end
                end
            end
            CreateMenu(menuData)
        end)
    end

    -- Convert zf_dialog
    if sdmenu.inputVersion ~= 'zf' then
        exportHandler('zf_dialog', 'DialogInput', function(data)
            local inputData = {}
            inputData.header = data.header
            inputData.inputs = {}
            for _, v in pairs(data.rows) do
                inputData.inputs[#inputData.inputs + 1] = {
                    text = v.txt
                }
            end
            local inputs = table.pack(CreateInput(inputData))
            table.remove(inputs, 1)
            local returninputs = {}
            for _, v in ipairs(inputs) do
                table.insert(returninputs, { input = v })
            end
            return returninputs
        end)
    end

    -- Convert nh-context v2
    if sdmenu.menuVersion ~= 'v2' then
        
        RegisterNetEvent('nh-context:createMenu', function(data)
            local menuData = {}
            for _, v in pairs(data) do
                local menuId = #menuData + 1
                menuData[menuId] = {}
                if v.header then menuData[menuId].header = v.header end
                if v.context then menuData[menuId].txt = v.context end
                if v.event then
                    menuData[menuId].params = {}
                    menuData[menuId].params.event = v.event 
                end
                if v.server then menuData[menuId].params.server = v.server end
                if v.args and next(v.args) then
                    menuData[menuId].params.args = v.args
                end
            end
            CreateMenu(menuData)
        end)

        exportHandler('nh-context', 'ContextMenu', function(data)
            local menuData = {}
            for _, v in pairs(data) do
                local menuId = #menuData + 1
                menuData[menuId] = {}
                if v.header then menuData[menuId].header = v.header end
                if v.context then menuData[menuId].txt = v.context end
                if v.event then
                    menuData[menuId].params = {}
                    menuData[menuId].params.event = v.event
                end
                if v.server then menuData[menuId].params.server = v.server end
                if v.args and next(v.args) then
                    menuData[menuId].params.args = v.args
                end
            end
            CreateMenu(menuData)
        end)
    end

    -- Convert nh-keyboard v2
    if sdmenu.inputVersion ~= 'v2' then
        exportHandler('nh-keyboard', 'Keyboard', function(data)
            local inputData = {}
            inputData.header = data.header
            inputData.inputs = {}
            for _, v in pairs(data.rows) do
                inputData.inputs[#inputData.inputs + 1] = {
                    text = v
                }
            end
            return CreateInput(inputData)
        end)
    end

    -- Convert qb-menu
    if sdmenu.menuVersion ~= 'qb' then
        exportHandler('qb-menu', 'openMenu', function(data)
            local menuData = {}
            for _, v in pairs(data) do
                local menuId = #menuData + 1
                menuData[menuId] = {}
                if v.header then menuData[menuId].header = v.header end
                if v.txt then menuData[menuId].txt = v.txt end
                if v.params then
                    menuData[menuId].params = {}
                    menuData[menuId].params.event = v.params.event
                    if v.params.isServer then menuData[menuId].params.server = v.params.isServer end
                    if v.icon then menuData[menuId].icon = v.icon end
                    if v.params.args then
                        menuData[menuId].params.args = {}
                        table.insert(menuData[menuId].params.args, v.params.args)
                    end
                end
            end
            CreateMenu(menuData)
        end)
    end

    -- Convert qb-input
    if sdmenu.inputVersion ~= 'qb' then
        exportHandler('qb-input', 'ShowInput', function(data)
            local inputData = {}
            inputData.header = data.header
            inputData.inputs = {}
            tPrint(data)
            for _, v in pairs(data.inputs) do
                inputData.inputs[#inputData.inputs + 1] = {
                    text = v.text
                }
            end
            return CreateInput(inputData)
        end)
    end

    -- Convert ox_lib
    if sdmenu.menuVersion ~= 'ox' then
        local menus = {}
        exportHandler('ox_lib', 'registerContext', function(data)
            local menuData = {}
            menuData[#menuData+1] = {
                header = data.title
            }
            for _, v in pairs(data.options) do
                local menuId = #menuData + 1
                menuData[menuId] = {}
                if v.title then menuData[menuId].header = v.title end
                if v.description then menuData[menuId].txt = v.description end
                if v.args and next(v.args) then
                    menuData[menuId].params = {}
                    menuData[menuId].params.event = v.event
                    if v.serverEvent then menuData[menuId].params.server = true end
                    if v.icon then menuData[menuId].icon = v.icon end
                    menuData[menuId].params.args = {}
                    table.insert(menuData[menuId].params.args, v.args)
                end
            end
            menus[data.id] = menuData
        end)
        exportHandler('ox_lib', 'showContext', function(id)
            CreateMenu(menus[id])
        end)
    end
end

-- Color Filters (https://codepen.io/sosuke/pen/Pjoqqp)
sdmenu.iconColor = 'filter: invert(100%) sepia(0%) saturate(0%) hue-rotate(142deg) brightness(105%) contrast(101%);'

-- Icon Size
sdmenu.iconSize = '16px'

-- Font Awesome Icons (Hosted @ https://github.com/SloppyDesigns/font-awesome)
sdmenu.icons = {
    ['fa-solid'] = {
        ['fa-0'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/0.svg',
        ['fa-1'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/1.svg',
        ['fa-2'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/2.svg',
        ['fa-3'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/3.svg',
        ['fa-4'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/4.svg',
        ['fa-5'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/5.svg',
        ['fa-6'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/6.svg',
        ['fa-7'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/7.svg',
        ['fa-8'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/8.svg',
        ['fa-9'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/9.svg',
        ['fa-a'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/a.svg',
        ['fa-address-book'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/address-book.svg',
        ['fa-address-card'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/address-card.svg',
        ['fa-align-center'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/align-center.svg',
        ['fa-align-justify'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/align-justify.svg',
        ['fa-align-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/align-left.svg',
        ['fa-align-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/align-right.svg',
        ['fa-anchor-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/anchor-circle-check.svg',
        ['fa-anchor-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/anchor-circle-exclamation.svg',
        ['fa-anchor-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/anchor-circle-xmark.svg',
        ['fa-anchor-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/anchor-lock.svg',
        ['fa-anchor'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/anchor.svg',
        ['fa-angle-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angle-down.svg',
        ['fa-angle-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angle-left.svg',
        ['fa-angle-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angle-right.svg',
        ['fa-angle-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angle-up.svg',
        ['fa-angles-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angles-down.svg',
        ['fa-angles-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angles-left.svg',
        ['fa-angles-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angles-right.svg',
        ['fa-angles-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angles-up.svg',
        ['fa-ankh'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ankh.svg',
        ['fa-apple-whole'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/apple-whole.svg',
        ['fa-archway'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/archway.svg',
        ['fa-arrow-down-1-9'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-down-1-9.svg',
        ['fa-arrow-down-9-1'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-down-9-1.svg',
        ['fa-arrow-down-a-z'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-down-a-z.svg',
        ['fa-arrow-down-long'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-down-long.svg',
        ['fa-arrow-down-short-wide'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-down-short-wide.svg',
        ['fa-arrow-down-up-across-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-down-up-across-line.svg',
        ['fa-arrow-down-up-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-down-up-lock.svg',
        ['fa-arrow-down-wide-short'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-down-wide-short.svg',
        ['fa-arrow-down-z-a'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-down-z-a.svg',
        ['fa-arrow-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-down.svg',
        ['fa-arrow-left-long'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-left-long.svg',
        ['fa-arrow-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-left.svg',
        ['fa-arrow-pointer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-pointer.svg',
        ['fa-arrow-right-arrow-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-right-arrow-left.svg',
        ['fa-arrow-right-from-bracket'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-right-from-bracket.svg',
        ['fa-arrow-right-long'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-right-long.svg',
        ['fa-arrow-right-to-bracket'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-right-to-bracket.svg',
        ['fa-arrow-right-to-city'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-right-to-city.svg',
        ['fa-arrow-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-right.svg',
        ['fa-arrow-rotate-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-rotate-left.svg',
        ['fa-arrow-rotate-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-rotate-right.svg',
        ['fa-arrow-trend-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-trend-down.svg',
        ['fa-arrow-trend-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-trend-up.svg',
        ['fa-arrow-turn-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-turn-down.svg',
        ['fa-arrow-turn-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-turn-up.svg',
        ['fa-arrow-up-1-9'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-1-9.svg',
        ['fa-arrow-up-9-1'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-9-1.svg',
        ['fa-arrow-up-a-z'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-a-z.svg',
        ['fa-arrow-up-from-bracket'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-from-bracket.svg',
        ['fa-arrow-up-from-ground-water'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-from-ground-water.svg',
        ['fa-arrow-up-from-water-pump'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-from-water-pump.svg',
        ['fa-arrow-up-long'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-long.svg',
        ['fa-arrow-up-right-dots'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-right-dots.svg',
        ['fa-arrow-up-right-from-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-right-from-square.svg',
        ['fa-arrow-up-short-wide'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-short-wide.svg',
        ['fa-arrow-up-wide-short'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-wide-short.svg',
        ['fa-arrow-up-z-a'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up-z-a.svg',
        ['fa-arrow-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrow-up.svg',
        ['fa-arrows-down-to-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-down-to-line.svg',
        ['fa-arrows-down-to-people'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-down-to-people.svg',
        ['fa-arrows-left-right-to-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-left-right-to-line.svg',
        ['fa-arrows-left-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-left-right.svg',
        ['fa-arrows-rotate'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-rotate.svg',
        ['fa-arrows-spin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-spin.svg',
        ['fa-arrows-split-up-and-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-split-up-and-left.svg',
        ['fa-arrows-to-circle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-to-circle.svg',
        ['fa-arrows-to-dot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-to-dot.svg',
        ['fa-arrows-to-eye'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-to-eye.svg',
        ['fa-arrows-turn-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-turn-right.svg',
        ['fa-arrows-turn-to-dots'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-turn-to-dots.svg',
        ['fa-arrows-up-down-left-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-up-down-left-right.svg',
        ['fa-arrows-up-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-up-down.svg',
        ['fa-arrows-up-to-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/arrows-up-to-line.svg',
        ['fa-asterisk'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/asterisk.svg',
        ['fa-at'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/at.svg',
        ['fa-atom'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/atom.svg',
        ['fa-audio-description'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/audio-description.svg',
        ['fa-austral-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/austral-sign.svg',
        ['fa-award'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/award.svg',
        ['fa-b'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/b.svg',
        ['fa-baby-carriage'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/baby-carriage.svg',
        ['fa-baby'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/baby.svg',
        ['fa-backward-fast'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/backward-fast.svg',
        ['fa-backward-step'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/backward-step.svg',
        ['fa-backward'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/backward.svg',
        ['fa-bacon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bacon.svg',
        ['fa-bacteria'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bacteria.svg',
        ['fa-bacterium'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bacterium.svg',
        ['fa-bag-shopping'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bag-shopping.svg',
        ['fa-bahai'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bahai.svg',
        ['fa-baht-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/baht-sign.svg',
        ['fa-ban-smoking'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ban-smoking.svg',
        ['fa-ban'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ban.svg',
        ['fa-bandage'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bandage.svg',
        ['fa-barcode'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/barcode.svg',
        ['fa-bars-progress'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bars-progress.svg',
        ['fa-bars-staggered'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bars-staggered.svg',
        ['fa-bars'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bars.svg',
        ['fa-baseball-bat-ball'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/baseball-bat-ball.svg',
        ['fa-baseball'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/baseball.svg',
        ['fa-basket-shopping'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/basket-shopping.svg',
        ['fa-basketball'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/basketball.svg',
        ['fa-bath'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bath.svg',
        ['fa-battery-empty'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/battery-empty.svg',
        ['fa-battery-full'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/battery-full.svg',
        ['fa-battery-half'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/battery-half.svg',
        ['fa-battery-quarter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/battery-quarter.svg',
        ['fa-battery-three-quarters'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/battery-three-quarters.svg',
        ['fa-bed-pulse'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bed-pulse.svg',
        ['fa-bed'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bed.svg',
        ['fa-beer-mug-empty'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/beer-mug-empty.svg',
        ['fa-bell-concierge'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bell-concierge.svg',
        ['fa-bell-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bell-slash.svg',
        ['fa-bell'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bell.svg',
        ['fa-bezier-curve'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bezier-curve.svg',
        ['fa-bicycle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bicycle.svg',
        ['fa-binoculars'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/binoculars.svg',
        ['fa-biohazard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/biohazard.svg',
        ['fa-bitcoin-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bitcoin-sign.svg',
        ['fa-blender-phone'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/blender-phone.svg',
        ['fa-blender'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/blender.svg',
        ['fa-blog'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/blog.svg',
        ['fa-bold'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bold.svg',
        ['fa-bolt-lightning'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bolt-lightning.svg',
        ['fa-bolt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bolt.svg',
        ['fa-bomb'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bomb.svg',
        ['fa-bone'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bone.svg',
        ['fa-bong'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bong.svg',
        ['fa-book-atlas'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/book-atlas.svg',
        ['fa-book-bible'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/book-bible.svg',
        ['fa-book-bookmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/book-bookmark.svg',
        ['fa-book-journal-whills'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/book-journal-whills.svg',
        ['fa-book-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/book-medical.svg',
        ['fa-book-open-reader'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/book-open-reader.svg',
        ['fa-book-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/book-open.svg',
        ['fa-book-quran'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/book-quran.svg',
        ['fa-book-skull'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/book-skull.svg',
        ['fa-book'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/book.svg',
        ['fa-bookmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bookmark.svg',
        ['fa-border-all'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/border-all.svg',
        ['fa-border-none'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/border-none.svg',
        ['fa-border-top-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/border-top-left.svg',
        ['fa-bore-hole'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bore-hole.svg',
        ['fa-bottle-droplet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bottle-droplet.svg',
        ['fa-bottle-water'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bottle-water.svg',
        ['fa-bowl-food'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bowl-food.svg',
        ['fa-bowl-rice'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bowl-rice.svg',
        ['fa-bowling-ball'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bowling-ball.svg',
        ['fa-box-archive'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/box-archive.svg',
        ['fa-box-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/box-open.svg',
        ['fa-box-tissue'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/box-tissue.svg',
        ['fa-box'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/box.svg',
        ['fa-boxes-packing'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/boxes-packing.svg',
        ['fa-boxes-stacked'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/boxes-stacked.svg',
        ['fa-braille'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/braille.svg',
        ['fa-brain'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/brain.svg',
        ['fa-brazilian-real-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/brazilian-real-sign.svg',
        ['fa-bread-slice'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bread-slice.svg',
        ['fa-bridge-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bridge-circle-check.svg',
        ['fa-bridge-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bridge-circle-exclamation.svg',
        ['fa-bridge-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bridge-circle-xmark.svg',
        ['fa-bridge-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bridge-lock.svg',
        ['fa-bridge-water'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bridge-water.svg',
        ['fa-bridge'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bridge.svg',
        ['fa-briefcase-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/briefcase-medical.svg',
        ['fa-briefcase'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/briefcase.svg',
        ['fa-broom-ball'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/broom-ball.svg',
        ['fa-broom'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/broom.svg',
        ['fa-brush'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/brush.svg',
        ['fa-bucket'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bucket.svg',
        ['fa-bug-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bug-slash.svg',
        ['fa-bug'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bug.svg',
        ['fa-bugs'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bugs.svg',
        ['fa-building-circle-arrow-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-circle-arrow-right.svg',
        ['fa-building-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-circle-check.svg',
        ['fa-building-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-circle-exclamation.svg',
        ['fa-building-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-circle-xmark.svg',
        ['fa-building-columns'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-columns.svg',
        ['fa-building-flag'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-flag.svg',
        ['fa-building-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-lock.svg',
        ['fa-building-ngo'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-ngo.svg',
        ['fa-building-shield'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-shield.svg',
        ['fa-building-un'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-un.svg',
        ['fa-building-user'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-user.svg',
        ['fa-building-wheat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building-wheat.svg',
        ['fa-building'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building.svg',
        ['fa-bullhorn'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bullhorn.svg',
        ['fa-bullseye'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bullseye.svg',
        ['fa-burger'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/burger.svg',
        ['fa-burst'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/burst.svg',
        ['fa-bus-simple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bus-simple.svg',
        ['fa-bus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bus.svg',
        ['fa-business-time'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/business-time.svg',
        ['fa-c'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/c.svg',
        ['fa-cake-candles'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cake-candles.svg',
        ['fa-calculator'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calculator.svg',
        ['fa-calendar-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-check.svg',
        ['fa-calendar-day'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-day.svg',
        ['fa-calendar-days'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-days.svg',
        ['fa-calendar-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-minus.svg',
        ['fa-calendar-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-plus.svg',
        ['fa-calendar-week'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-week.svg',
        ['fa-calendar-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-xmark.svg',
        ['fa-calendar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar.svg',
        ['fa-camera-retro'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/camera-retro.svg',
        ['fa-camera-rotate'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/camera-rotate.svg',
        ['fa-camera'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/camera.svg',
        ['fa-campground'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/campground.svg',
        ['fa-candy-cane'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/candy-cane.svg',
        ['fa-cannabis'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cannabis.svg',
        ['fa-capsules'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/capsules.svg',
        ['fa-car-battery'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/car-battery.svg',
        ['fa-car-burst'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/car-burst.svg',
        ['fa-car-crash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/car-crash.svg',
        ['fa-car-on'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/car-on.svg',
        ['fa-car-rear'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/car-rear.svg',
        ['fa-car-side'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/car-side.svg',
        ['fa-car-tunnel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/car-tunnel.svg',
        ['fa-car'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/car.svg',
        ['fa-caravan'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/caravan.svg',
        ['fa-caret-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/caret-down.svg',
        ['fa-caret-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/caret-left.svg',
        ['fa-caret-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/caret-right.svg',
        ['fa-caret-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/caret-up.svg',
        ['fa-carrot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/carrot.svg',
        ['fa-cart-arrow-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cart-arrow-down.svg',
        ['fa-cart-flatbed-suitcase'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cart-flatbed-suitcase.svg',
        ['fa-cart-flatbed'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cart-flatbed.svg',
        ['fa-cart-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cart-plus.svg',
        ['fa-cart-shopping'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cart-shopping.svg',
        ['fa-cash-register'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cash-register.svg',
        ['fa-cat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cat.svg',
        ['fa-cedi-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cedi-sign.svg',
        ['fa-cent-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cent-sign.svg',
        ['fa-certificate'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/certificate.svg',
        ['fa-chair'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chair.svg',
        ['fa-chalkboard-user'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chalkboard-user.svg',
        ['fa-chalkboard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chalkboard.svg',
        ['fa-champagne-glasses'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/champagne-glasses.svg',
        ['fa-charging-station'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/charging-station.svg',
        ['fa-chart-area'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chart-area.svg',
        ['fa-chart-bar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chart-bar.svg',
        ['fa-chart-column'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chart-column.svg',
        ['fa-chart-gantt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chart-gantt.svg',
        ['fa-chart-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chart-line.svg',
        ['fa-chart-pie'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chart-pie.svg',
        ['fa-chart-simple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chart-simple.svg',
        ['fa-check-double'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/check-double.svg',
        ['fa-check-to-slot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/check-to-slot.svg',
        ['fa-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/check.svg',
        ['fa-cheese'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cheese.svg',
        ['fa-chess-bishop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-bishop.svg',
        ['fa-chess-board'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-board.svg',
        ['fa-chess-king'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-king.svg',
        ['fa-chess-knight'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-knight.svg',
        ['fa-chess-pawn'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-pawn.svg',
        ['fa-chess-queen'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-queen.svg',
        ['fa-chess-rook'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-rook.svg',
        ['fa-chess'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess.svg',
        ['fa-chevron-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chevron-down.svg',
        ['fa-chevron-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chevron-left.svg',
        ['fa-chevron-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chevron-right.svg',
        ['fa-chevron-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chevron-up.svg',
        ['fa-child-dress'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/child-dress.svg',
        ['fa-child-reaching'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/child-reaching.svg',
        ['fa-child-rifle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/child-rifle.svg',
        ['fa-child'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/child.svg',
        ['fa-children'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/children.svg',
        ['fa-church'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/church.svg',
        ['fa-circle-arrow-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-arrow-down.svg',
        ['fa-circle-arrow-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-arrow-left.svg',
        ['fa-circle-arrow-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-arrow-right.svg',
        ['fa-circle-arrow-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-arrow-up.svg',
        ['fa-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-check.svg',
        ['fa-circle-chevron-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-chevron-down.svg',
        ['fa-circle-chevron-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-chevron-left.svg',
        ['fa-circle-chevron-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-chevron-right.svg',
        ['fa-circle-chevron-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-chevron-up.svg',
        ['fa-circle-dollar-to-slot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-dollar-to-slot.svg',
        ['fa-circle-dot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-dot.svg',
        ['fa-circle-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-down.svg',
        ['fa-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-exclamation.svg',
        ['fa-circle-h'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-h.svg',
        ['fa-circle-half-stroke'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-half-stroke.svg',
        ['fa-circle-info'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-info.svg',
        ['fa-circle-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-left.svg',
        ['fa-circle-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-minus.svg',
        ['fa-circle-nodes'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-nodes.svg',
        ['fa-circle-notch'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-notch.svg',
        ['fa-circle-pause'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-pause.svg',
        ['fa-circle-play'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-play.svg',
        ['fa-circle-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-plus.svg',
        ['fa-circle-question'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-question.svg',
        ['fa-circle-radiation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-radiation.svg',
        ['fa-circle-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-right.svg',
        ['fa-circle-stop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-stop.svg',
        ['fa-circle-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-up.svg',
        ['fa-circle-user'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-user.svg',
        ['fa-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-xmark.svg',
        ['fa-circle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle.svg',
        ['fa-city'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/city.svg',
        ['fa-clapperboard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clapperboard.svg',
        ['fa-clipboard-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clipboard-check.svg',
        ['fa-clipboard-list'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clipboard-list.svg',
        ['fa-clipboard-question'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clipboard-question.svg',
        ['fa-clipboard-user'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clipboard-user.svg',
        ['fa-clipboard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clipboard.svg',
        ['fa-clock-rotate-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clock-rotate-left.svg',
        ['fa-clock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clock.svg',
        ['fa-clone'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clone.svg',
        ['fa-closed-captioning'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/closed-captioning.svg',
        ['fa-cloud-arrow-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-arrow-down.svg',
        ['fa-cloud-arrow-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-arrow-up.svg',
        ['fa-cloud-bolt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-bolt.svg',
        ['fa-cloud-meatball'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-meatball.svg',
        ['fa-cloud-moon-rain'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-moon-rain.svg',
        ['fa-cloud-moon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-moon.svg',
        ['fa-cloud-rain'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-rain.svg',
        ['fa-cloud-showers-heavy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-showers-heavy.svg',
        ['fa-cloud-showers-water'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-showers-water.svg',
        ['fa-cloud-sun-rain'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-sun-rain.svg',
        ['fa-cloud-sun'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud-sun.svg',
        ['fa-cloud'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloud.svg',
        ['fa-clover'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clover.svg',
        ['fa-code-branch'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/code-branch.svg',
        ['fa-code-commit'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/code-commit.svg',
        ['fa-code-compare'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/code-compare.svg',
        ['fa-code-fork'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/code-fork.svg',
        ['fa-code-merge'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/code-merge.svg',
        ['fa-code-pull-request'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/code-pull-request.svg',
        ['fa-code'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/code.svg',
        ['fa-coins'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/coins.svg',
        ['fa-colon-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/colon-sign.svg',
        ['fa-comment-dollar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comment-dollar.svg',
        ['fa-comment-dots'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comment-dots.svg',
        ['fa-comment-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comment-medical.svg',
        ['fa-comment-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comment-slash.svg',
        ['fa-comment-sms'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comment-sms.svg',
        ['fa-comment'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comment.svg',
        ['fa-comments-dollar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comments-dollar.svg',
        ['fa-comments'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comments.svg',
        ['fa-compact-disc'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/compact-disc.svg',
        ['fa-compass-drafting'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/compass-drafting.svg',
        ['fa-compass'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/compass.svg',
        ['fa-compress'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/compress.svg',
        ['fa-computer-mouse'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/computer-mouse.svg',
        ['fa-computer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/computer.svg',
        ['fa-cookie-bite'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cookie-bite.svg',
        ['fa-cookie'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cookie.svg',
        ['fa-copy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/copy.svg',
        ['fa-copyright'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/copyright.svg',
        ['fa-couch'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/couch.svg',
        ['fa-cow'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cow.svg',
        ['fa-credit-card'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/credit-card.svg',
        ['fa-crop-simple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/crop-simple.svg',
        ['fa-crop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/crop.svg',
        ['fa-cross'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cross.svg',
        ['fa-crosshairs'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/crosshairs.svg',
        ['fa-crow'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/crow.svg',
        ['fa-crown'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/crown.svg',
        ['fa-crutch'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/crutch.svg',
        ['fa-cruzeiro-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cruzeiro-sign.svg',
        ['fa-cube'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cube.svg',
        ['fa-cubes-stacked'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cubes-stacked.svg',
        ['fa-cubes'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cubes.svg',
        ['fa-d'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/d.svg',
        ['fa-database'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/database.svg',
        ['fa-delete-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/delete-left.svg',
        ['fa-democrat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/democrat.svg',
        ['fa-desktop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/desktop.svg',
        ['fa-dharmachakra'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dharmachakra.svg',
        ['fa-diagram-next'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/diagram-next.svg',
        ['fa-diagram-predecessor'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/diagram-predecessor.svg',
        ['fa-diagram-project'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/diagram-project.svg',
        ['fa-diagram-successor'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/diagram-successor.svg',
        ['fa-diamond-turn-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/diamond-turn-right.svg',
        ['fa-diamond'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/diamond.svg',
        ['fa-dice-d20'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dice-d20.svg',
        ['fa-dice-d6'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dice-d6.svg',
        ['fa-dice-five'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dice-five.svg',
        ['fa-dice-four'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dice-four.svg',
        ['fa-dice-one'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dice-one.svg',
        ['fa-dice-six'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dice-six.svg',
        ['fa-dice-three'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dice-three.svg',
        ['fa-dice-two'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dice-two.svg',
        ['fa-dice'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dice.svg',
        ['fa-disease'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/disease.svg',
        ['fa-display'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/display.svg',
        ['fa-divide'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/divide.svg',
        ['fa-dna'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dna.svg',
        ['fa-dog'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dog.svg',
        ['fa-dollar-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dollar-sign.svg',
        ['fa-dolly'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dolly.svg',
        ['fa-dong-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dong-sign.svg',
        ['fa-door-closed'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/door-closed.svg',
        ['fa-door-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/door-open.svg',
        ['fa-dove'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dove.svg',
        ['fa-down-left-and-up-right-to-center'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/down-left-and-up-right-to-center.svg',
        ['fa-down-long'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/down-long.svg',
        ['fa-download'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/download.svg',
        ['fa-dragon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dragon.svg',
        ['fa-draw-polygon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/draw-polygon.svg',
        ['fa-droplet-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/droplet-slash.svg',
        ['fa-droplet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/droplet.svg',
        ['fa-drum-steelpan'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/drum-steelpan.svg',
        ['fa-drum'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/drum.svg',
        ['fa-drumstick-bite'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/drumstick-bite.svg',
        ['fa-dumbbell'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dumbbell.svg',
        ['fa-dumpster-fire'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dumpster-fire.svg',
        ['fa-dumpster'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dumpster.svg',
        ['fa-dungeon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dungeon.svg',
        ['fa-e'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/e.svg',
        ['fa-ear-deaf'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ear-deaf.svg',
        ['fa-ear-listen'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ear-listen.svg',
        ['fa-earth-africa'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/earth-africa.svg',
        ['fa-earth-americas'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/earth-americas.svg',
        ['fa-earth-asia'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/earth-asia.svg',
        ['fa-earth-europe'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/earth-europe.svg',
        ['fa-earth-oceania'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/earth-oceania.svg',
        ['fa-egg'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/egg.svg',
        ['fa-eject'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/eject.svg',
        ['fa-elevator'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/elevator.svg',
        ['fa-ellipsis-vertical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ellipsis-vertical.svg',
        ['fa-ellipsis'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ellipsis.svg',
        ['fa-envelope-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/envelope-circle-check.svg',
        ['fa-envelope-open-text'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/envelope-open-text.svg',
        ['fa-envelope-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/envelope-open.svg',
        ['fa-envelope'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/envelope.svg',
        ['fa-envelopes-bulk'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/envelopes-bulk.svg',
        ['fa-equals'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/equals.svg',
        ['fa-eraser'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/eraser.svg',
        ['fa-ethernet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ethernet.svg',
        ['fa-euro-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/euro-sign.svg',
        ['fa-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/exclamation.svg',
        ['fa-expand'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/expand.svg',
        ['fa-explosion'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/explosion.svg',
        ['fa-eye-dropper'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/eye-dropper.svg',
        ['fa-eye-low-vision'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/eye-low-vision.svg',
        ['fa-eye-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/eye-slash.svg',
        ['fa-eye'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/eye.svg',
        ['fa-f'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/f.svg',
        ['fa-face-angry'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-angry.svg',
        ['fa-face-dizzy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-dizzy.svg',
        ['fa-face-flushed'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-flushed.svg',
        ['fa-face-frown-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-frown-open.svg',
        ['fa-face-frown'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-frown.svg',
        ['fa-face-grimace'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grimace.svg',
        ['fa-face-grin-beam-sweat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-beam-sweat.svg',
        ['fa-face-grin-beam'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-beam.svg',
        ['fa-face-grin-hearts'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-hearts.svg',
        ['fa-face-grin-squint-tears'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-squint-tears.svg',
        ['fa-face-grin-squint'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-squint.svg',
        ['fa-face-grin-stars'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-stars.svg',
        ['fa-face-grin-tears'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-tears.svg',
        ['fa-face-grin-tongue-squint'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-tongue-squint.svg',
        ['fa-face-grin-tongue-wink'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-tongue-wink.svg',
        ['fa-face-grin-tongue'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-tongue.svg',
        ['fa-face-grin-wide'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-wide.svg',
        ['fa-face-grin-wink'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-wink.svg',
        ['fa-face-grin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin.svg',
        ['fa-face-kiss-beam'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-kiss-beam.svg',
        ['fa-face-kiss-wink-heart'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-kiss-wink-heart.svg',
        ['fa-face-kiss'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-kiss.svg',
        ['fa-face-laugh-beam'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-laugh-beam.svg',
        ['fa-face-laugh-squint'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-laugh-squint.svg',
        ['fa-face-laugh-wink'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-laugh-wink.svg',
        ['fa-face-laugh'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-laugh.svg',
        ['fa-face-meh-blank'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-meh-blank.svg',
        ['fa-face-meh'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-meh.svg',
        ['fa-face-rolling-eyes'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-rolling-eyes.svg',
        ['fa-face-sad-cry'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-sad-cry.svg',
        ['fa-face-sad-tear'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-sad-tear.svg',
        ['fa-face-smile-beam'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-smile-beam.svg',
        ['fa-face-smile-wink'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-smile-wink.svg',
        ['fa-face-smile'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-smile.svg',
        ['fa-face-surprise'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-surprise.svg',
        ['fa-face-tired'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-tired.svg',
        ['fa-fan'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fan.svg',
        ['fa-faucet-drip'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/faucet-drip.svg',
        ['fa-faucet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/faucet.svg',
        ['fa-fax'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fax.svg',
        ['fa-feather-pointed'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/feather-pointed.svg',
        ['fa-feather'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/feather.svg',
        ['fa-ferry'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ferry.svg',
        ['fa-file-arrow-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-arrow-down.svg',
        ['fa-file-arrow-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-arrow-up.svg',
        ['fa-file-audio'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-audio.svg',
        ['fa-file-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-circle-check.svg',
        ['fa-file-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-circle-exclamation.svg',
        ['fa-file-circle-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-circle-minus.svg',
        ['fa-file-circle-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-circle-plus.svg',
        ['fa-file-circle-question'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-circle-question.svg',
        ['fa-file-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-circle-xmark.svg',
        ['fa-file-code'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-code.svg',
        ['fa-file-contract'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-contract.svg',
        ['fa-file-csv'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-csv.svg',
        ['fa-file-excel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-excel.svg',
        ['fa-file-export'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-export.svg',
        ['fa-file-image'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-image.svg',
        ['fa-file-import'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-import.svg',
        ['fa-file-invoice-dollar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-invoice-dollar.svg',
        ['fa-file-invoice'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-invoice.svg',
        ['fa-file-lines'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-lines.svg',
        ['fa-file-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-medical.svg',
        ['fa-file-pdf'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-pdf.svg',
        ['fa-file-pen'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-pen.svg',
        ['fa-file-powerpoint'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-powerpoint.svg',
        ['fa-file-prescription'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-prescription.svg',
        ['fa-file-shield'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-shield.svg',
        ['fa-file-signature'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-signature.svg',
        ['fa-file-video'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-video.svg',
        ['fa-file-waveform'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-waveform.svg',
        ['fa-file-word'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-word.svg',
        ['fa-file-zipper'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-zipper.svg',
        ['fa-file'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file.svg',
        ['fa-fill-drip'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fill-drip.svg',
        ['fa-fill'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fill.svg',
        ['fa-film'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/film.svg',
        ['fa-filter-circle-dollar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/filter-circle-dollar.svg',
        ['fa-filter-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/filter-circle-xmark.svg',
        ['fa-filter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/filter.svg',
        ['fa-fingerprint'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fingerprint.svg',
        ['fa-fire-burner'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fire-burner.svg',
        ['fa-fire-extinguisher'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fire-extinguisher.svg',
        ['fa-fire-flame-curved'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fire-flame-curved.svg',
        ['fa-fire-flame-simple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fire-flame-simple.svg',
        ['fa-fire'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fire.svg',
        ['fa-fish-fins'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fish-fins.svg',
        ['fa-fish'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fish.svg',
        ['fa-flag-checkered'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/flag-checkered.svg',
        ['fa-flag-usa'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/flag-usa.svg',
        ['fa-flag'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/flag.svg',
        ['fa-flask-vial'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/flask-vial.svg',
        ['fa-flask'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/flask.svg',
        ['fa-floppy-disk'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/floppy-disk.svg',
        ['fa-florin-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/florin-sign.svg',
        ['fa-folder-closed'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/folder-closed.svg',
        ['fa-folder-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/folder-minus.svg',
        ['fa-folder-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/folder-open.svg',
        ['fa-folder-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/folder-plus.svg',
        ['fa-folder-tree'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/folder-tree.svg',
        ['fa-folder'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/folder.svg',
        ['fa-font-awesome'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/font-awesome.svg',
        ['fa-font'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/font.svg',
        ['fa-football'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/football.svg',
        ['fa-forward-fast'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/forward-fast.svg',
        ['fa-forward-step'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/forward-step.svg',
        ['fa-forward'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/forward.svg',
        ['fa-franc-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/franc-sign.svg',
        ['fa-frog'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/frog.svg',
        ['fa-futbol'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/futbol.svg',
        ['fa-g'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/g.svg',
        ['fa-gamepad'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gamepad.svg',
        ['fa-gas-pump'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gas-pump.svg',
        ['fa-gauge-high'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gauge-high.svg',
        ['fa-gauge-simple-high'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gauge-simple-high.svg',
        ['fa-gauge-simple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gauge-simple.svg',
        ['fa-gauge'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gauge.svg',
        ['fa-gavel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gavel.svg',
        ['fa-gear'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gear.svg',
        ['fa-gears'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gears.svg',
        ['fa-gem'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gem.svg',
        ['fa-genderless'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/genderless.svg',
        ['fa-ghost'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ghost.svg',
        ['fa-gift'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gift.svg',
        ['fa-gifts'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gifts.svg',
        ['fa-glass-water-droplet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/glass-water-droplet.svg',
        ['fa-glass-water'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/glass-water.svg',
        ['fa-glasses'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/glasses.svg',
        ['fa-globe'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/globe.svg',
        ['fa-golf-ball-tee'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/golf-ball-tee.svg',
        ['fa-gopuram'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gopuram.svg',
        ['fa-graduation-cap'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/graduation-cap.svg',
        ['fa-greater-than-equal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/greater-than-equal.svg',
        ['fa-greater-than'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/greater-than.svg',
        ['fa-grip-lines-vertical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/grip-lines-vertical.svg',
        ['fa-grip-lines'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/grip-lines.svg',
        ['fa-grip-vertical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/grip-vertical.svg',
        ['fa-grip'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/grip.svg',
        ['fa-group-arrows-rotate'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/group-arrows-rotate.svg',
        ['fa-guarani-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/guarani-sign.svg',
        ['fa-guitar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/guitar.svg',
        ['fa-gun'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gun.svg',
        ['fa-h'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/h.svg',
        ['fa-hammer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hammer.svg',
        ['fa-hamsa'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hamsa.svg',
        ['fa-hand-back-fist'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-back-fist.svg',
        ['fa-hand-dots'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-dots.svg',
        ['fa-hand-fist'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-fist.svg',
        ['fa-hand-holding-dollar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-holding-dollar.svg',
        ['fa-hand-holding-droplet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-holding-droplet.svg',
        ['fa-hand-holding-hand'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-holding-hand.svg',
        ['fa-hand-holding-heart'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-holding-heart.svg',
        ['fa-hand-holding-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-holding-medical.svg',
        ['fa-hand-holding'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-holding.svg',
        ['fa-hand-lizard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-lizard.svg',
        ['fa-hand-middle-finger'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-middle-finger.svg',
        ['fa-hand-peace'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-peace.svg',
        ['fa-hand-point-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-point-down.svg',
        ['fa-hand-point-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-point-left.svg',
        ['fa-hand-point-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-point-right.svg',
        ['fa-hand-point-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-point-up.svg',
        ['fa-hand-pointer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-pointer.svg',
        ['fa-hand-scissors'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-scissors.svg',
        ['fa-hand-sparkles'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-sparkles.svg',
        ['fa-hand-spock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-spock.svg',
        ['fa-hand'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand.svg',
        ['fa-handcuffs'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/handcuffs.svg',
        ['fa-hands-asl-interpreting'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hands-asl-interpreting.svg',
        ['fa-hands-bound'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hands-bound.svg',
        ['fa-hands-bubbles'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hands-bubbles.svg',
        ['fa-hands-clapping'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hands-clapping.svg',
        ['fa-hands-holding-child'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hands-holding-child.svg',
        ['fa-hands-holding-circle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hands-holding-circle.svg',
        ['fa-hands-holding'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hands-holding.svg',
        ['fa-hands-praying'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hands-praying.svg',
        ['fa-hands'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hands.svg',
        ['fa-handshake-angle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/handshake-angle.svg',
        ['fa-handshake-simple-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/handshake-simple-slash.svg',
        ['fa-handshake-simple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/handshake-simple.svg',
        ['fa-handshake-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/handshake-slash.svg',
        ['fa-handshake'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/handshake.svg',
        ['fa-hanukiah'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hanukiah.svg',
        ['fa-hard-drive'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hard-drive.svg',
        ['fa-hashtag'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hashtag.svg',
        ['fa-hat-cowboy-side'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hat-cowboy-side.svg',
        ['fa-hat-cowboy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hat-cowboy.svg',
        ['fa-hat-wizard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hat-wizard.svg',
        ['fa-head-side-cough-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/head-side-cough-slash.svg',
        ['fa-head-side-cough'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/head-side-cough.svg',
        ['fa-head-side-mask'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/head-side-mask.svg',
        ['fa-head-side-virus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/head-side-virus.svg',
        ['fa-heading'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heading.svg',
        ['fa-headphones-simple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/headphones-simple.svg',
        ['fa-headphones'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/headphones.svg',
        ['fa-headset'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/headset.svg',
        ['fa-heart-circle-bolt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heart-circle-bolt.svg',
        ['fa-heart-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heart-circle-check.svg',
        ['fa-heart-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heart-circle-exclamation.svg',
        ['fa-heart-circle-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heart-circle-minus.svg',
        ['fa-heart-circle-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heart-circle-plus.svg',
        ['fa-heart-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heart-circle-xmark.svg',
        ['fa-heart-crack'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heart-crack.svg',
        ['fa-heart-pulse'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heart-pulse.svg',
        ['fa-heart'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heart.svg',
        ['fa-helicopter-symbol'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/helicopter-symbol.svg',
        ['fa-helicopter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/helicopter.svg',
        ['fa-helmet-safety'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/helmet-safety.svg',
        ['fa-helmet-un'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/helmet-un.svg',
        ['fa-highlighter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/highlighter.svg',
        ['fa-hill-avalanche'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hill-avalanche.svg',
        ['fa-hill-rockslide'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hill-rockslide.svg',
        ['fa-hippo'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hippo.svg',
        ['fa-hockey-puck'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hockey-puck.svg',
        ['fa-holly-berry'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/holly-berry.svg',
        ['fa-horse-head'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/horse-head.svg',
        ['fa-horse'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/horse.svg',
        ['fa-hospital-user'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hospital-user.svg',
        ['fa-hospital'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hospital.svg',
        ['fa-hot-tub-person'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hot-tub-person.svg',
        ['fa-hotdog'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hotdog.svg',
        ['fa-hotel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hotel.svg',
        ['fa-hourglass-empty'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hourglass-empty.svg',
        ['fa-hourglass-end'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hourglass-end.svg',
        ['fa-hourglass-start'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hourglass-start.svg',
        ['fa-hourglass'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hourglass.svg',
        ['fa-house-chimney-crack'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-chimney-crack.svg',
        ['fa-house-chimney-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-chimney-medical.svg',
        ['fa-house-chimney-user'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-chimney-user.svg',
        ['fa-house-chimney-window'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-chimney-window.svg',
        ['fa-house-chimney'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-chimney.svg',
        ['fa-house-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-circle-check.svg',
        ['fa-house-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-circle-exclamation.svg',
        ['fa-house-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-circle-xmark.svg',
        ['fa-house-crack'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-crack.svg',
        ['fa-house-fire'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-fire.svg',
        ['fa-house-flag'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-flag.svg',
        ['fa-house-flood-water-circle-arrow-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-flood-water-circle-arrow-right.svg',
        ['fa-house-flood-water'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-flood-water.svg',
        ['fa-house-laptop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-laptop.svg',
        ['fa-house-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-lock.svg',
        ['fa-house-medical-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-medical-circle-check.svg',
        ['fa-house-medical-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-medical-circle-exclamation.svg',
        ['fa-house-medical-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-medical-circle-xmark.svg',
        ['fa-house-medical-flag'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-medical-flag.svg',
        ['fa-house-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-medical.svg',
        ['fa-house-signal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-signal.svg',
        ['fa-house-tsunami'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-tsunami.svg',
        ['fa-house-user'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house-user.svg',
        ['fa-house'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/house.svg',
        ['fa-hryvnia-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hryvnia-sign.svg',
        ['fa-hurricane'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hurricane.svg',
        ['fa-i-cursor'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/i-cursor.svg',
        ['fa-i'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/i.svg',
        ['fa-ice-cream'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ice-cream.svg',
        ['fa-icicles'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/icicles.svg',
        ['fa-icons'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/icons.svg',
        ['fa-id-badge'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/id-badge.svg',
        ['fa-id-card-clip'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/id-card-clip.svg',
        ['fa-id-card'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/id-card.svg',
        ['fa-igloo'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/igloo.svg',
        ['fa-image-portrait'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/image-portrait.svg',
        ['fa-image'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/image.svg',
        ['fa-images'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/images.svg',
        ['fa-inbox'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/inbox.svg',
        ['fa-indent'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/indent.svg',
        ['fa-indian-rupee-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/indian-rupee-sign.svg',
        ['fa-industry'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/industry.svg',
        ['fa-infinity'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/infinity.svg',
        ['fa-info'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/info.svg',
        ['fa-italic'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/italic.svg',
        ['fa-j'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/j.svg',
        ['fa-jar-wheat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/jar-wheat.svg',
        ['fa-jar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/jar.svg',
        ['fa-jedi'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/jedi.svg',
        ['fa-jet-fighter-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/jet-fighter-up.svg',
        ['fa-jet-fighter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/jet-fighter.svg',
        ['fa-joint'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/joint.svg',
        ['fa-jug-detergent'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/jug-detergent.svg',
        ['fa-k'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/k.svg',
        ['fa-kaaba'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/kaaba.svg',
        ['fa-key'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/key.svg',
        ['fa-keyboard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/keyboard.svg',
        ['fa-khanda'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/khanda.svg',
        ['fa-kip-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/kip-sign.svg',
        ['fa-kit-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/kit-medical.svg',
        ['fa-kitchen-set'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/kitchen-set.svg',
        ['fa-kiwi-bird'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/kiwi-bird.svg',
        ['fa-l'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/l.svg',
        ['fa-land-mine-on'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/land-mine-on.svg',
        ['fa-landmark-dome'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/landmark-dome.svg',
        ['fa-landmark-flag'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/landmark-flag.svg',
        ['fa-landmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/landmark.svg',
        ['fa-language'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/language.svg',
        ['fa-laptop-code'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/laptop-code.svg',
        ['fa-laptop-file'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/laptop-file.svg',
        ['fa-laptop-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/laptop-medical.svg',
        ['fa-laptop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/laptop.svg',
        ['fa-lari-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lari-sign.svg',
        ['fa-layer-group'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/layer-group.svg',
        ['fa-leaf'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/leaf.svg',
        ['fa-left-long'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/left-long.svg',
        ['fa-left-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/left-right.svg',
        ['fa-lemon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lemon.svg',
        ['fa-less-than-equal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/less-than-equal.svg',
        ['fa-less-than'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/less-than.svg',
        ['fa-life-ring'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/life-ring.svg',
        ['fa-lightbulb'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lightbulb.svg',
        ['fa-lines-leaning'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lines-leaning.svg',
        ['fa-link-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/link-slash.svg',
        ['fa-link'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/link.svg',
        ['fa-lira-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lira-sign.svg',
        ['fa-list-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/list-check.svg',
        ['fa-list-ol'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/list-ol.svg',
        ['fa-list-ul'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/list-ul.svg',
        ['fa-list'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/list.svg',
        ['fa-litecoin-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/litecoin-sign.svg',
        ['fa-location-arrow'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/location-arrow.svg',
        ['fa-location-crosshairs'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/location-crosshairs.svg',
        ['fa-location-dot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/location-dot.svg',
        ['fa-location-pin-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/location-pin-lock.svg',
        ['fa-location-pin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/location-pin.svg',
        ['fa-lock-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lock-open.svg',
        ['fa-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lock.svg',
        ['fa-locust'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/locust.svg',
        ['fa-lungs-virus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lungs-virus.svg',
        ['fa-lungs'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lungs.svg',
        ['fa-m'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/m.svg',
        ['fa-magnet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/magnet.svg',
        ['fa-magnifying-glass-arrow-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/magnifying-glass-arrow-right.svg',
        ['fa-magnifying-glass-chart'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/magnifying-glass-chart.svg',
        ['fa-magnifying-glass-dollar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/magnifying-glass-dollar.svg',
        ['fa-magnifying-glass-location'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/magnifying-glass-location.svg',
        ['fa-magnifying-glass-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/magnifying-glass-minus.svg',
        ['fa-magnifying-glass-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/magnifying-glass-plus.svg',
        ['fa-magnifying-glass'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/magnifying-glass.svg',
        ['fa-manat-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/manat-sign.svg',
        ['fa-map-location-dot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/map-location-dot.svg',
        ['fa-map-location'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/map-location.svg',
        ['fa-map-pin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/map-pin.svg',
        ['fa-map'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/map.svg',
        ['fa-marker'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/marker.svg',
        ['fa-mars-and-venus-burst'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mars-and-venus-burst.svg',
        ['fa-mars-and-venus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mars-and-venus.svg',
        ['fa-mars-double'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mars-double.svg',
        ['fa-mars-stroke-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mars-stroke-right.svg',
        ['fa-mars-stroke-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mars-stroke-up.svg',
        ['fa-mars-stroke'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mars-stroke.svg',
        ['fa-mars'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mars.svg',
        ['fa-martini-glass-citrus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/martini-glass-citrus.svg',
        ['fa-martini-glass-empty'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/martini-glass-empty.svg',
        ['fa-martini-glass'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/martini-glass.svg',
        ['fa-mask-face'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mask-face.svg',
        ['fa-mask-ventilator'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mask-ventilator.svg',
        ['fa-mask'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mask.svg',
        ['fa-masks-theater'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/masks-theater.svg',
        ['fa-mattress-pillow'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mattress-pillow.svg',
        ['fa-maximize'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/maximize.svg',
        ['fa-medal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/medal.svg',
        ['fa-memory'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/memory.svg',
        ['fa-menorah'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/menorah.svg',
        ['fa-mercury'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mercury.svg',
        ['fa-message'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/message.svg',
        ['fa-meteor'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/meteor.svg',
        ['fa-microchip'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/microchip.svg',
        ['fa-microphone-lines-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/microphone-lines-slash.svg',
        ['fa-microphone-lines'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/microphone-lines.svg',
        ['fa-microphone-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/microphone-slash.svg',
        ['fa-microphone'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/microphone.svg',
        ['fa-microscope'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/microscope.svg',
        ['fa-mill-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mill-sign.svg',
        ['fa-minimize'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/minimize.svg',
        ['fa-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/minus.svg',
        ['fa-mitten'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mitten.svg',
        ['fa-mobile-button'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mobile-button.svg',
        ['fa-mobile-retro'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mobile-retro.svg',
        ['fa-mobile-screen-button'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mobile-screen-button.svg',
        ['fa-mobile-screen'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mobile-screen.svg',
        ['fa-mobile'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mobile.svg',
        ['fa-money-bill-1-wave'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-bill-1-wave.svg',
        ['fa-money-bill-1'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-bill-1.svg',
        ['fa-money-bill-transfer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-bill-transfer.svg',
        ['fa-money-bill-trend-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-bill-trend-up.svg',
        ['fa-money-bill-wave'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-bill-wave.svg',
        ['fa-money-bill-wheat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-bill-wheat.svg',
        ['fa-money-bill'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-bill.svg',
        ['fa-money-bills'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-bills.svg',
        ['fa-money-check-dollar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-check-dollar.svg',
        ['fa-money-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-check.svg',
        ['fa-monument'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/monument.svg',
        ['fa-moon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/moon.svg',
        ['fa-mortar-pestle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mortar-pestle.svg',
        ['fa-mosque'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mosque.svg',
        ['fa-mosquito-net'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mosquito-net.svg',
        ['fa-mosquito'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mosquito.svg',
        ['fa-motorcycle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/motorcycle.svg',
        ['fa-mound'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mound.svg',
        ['fa-mountain-city'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mountain-city.svg',
        ['fa-mountain-sun'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mountain-sun.svg',
        ['fa-mountain'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mountain.svg',
        ['fa-mug-hot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mug-hot.svg',
        ['fa-mug-saucer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mug-saucer.svg',
        ['fa-music'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/music.svg',
        ['fa-n'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/n.svg',
        ['fa-naira-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/naira-sign.svg',
        ['fa-network-wired'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/network-wired.svg',
        ['fa-neuter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/neuter.svg',
        ['fa-newspaper'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/newspaper.svg',
        ['fa-not-equal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/not-equal.svg',
        ['fa-note-sticky'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/note-sticky.svg',
        ['fa-notes-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/notes-medical.svg',
        ['fa-o'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/o.svg',
        ['fa-object-group'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/object-group.svg',
        ['fa-object-ungroup'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/object-ungroup.svg',
        ['fa-oil-can'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/oil-can.svg',
        ['fa-oil-well'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/oil-well.svg',
        ['fa-om'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/om.svg',
        ['fa-otter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/otter.svg',
        ['fa-outdent'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/outdent.svg',
        ['fa-p'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/p.svg',
        ['fa-pager'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pager.svg',
        ['fa-paint-roller'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/paint-roller.svg',
        ['fa-paintbrush'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/paintbrush.svg',
        ['fa-palette'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/palette.svg',
        ['fa-pallet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pallet.svg',
        ['fa-panorama'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/panorama.svg',
        ['fa-paper-plane'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/paper-plane.svg',
        ['fa-paperclip'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/paperclip.svg',
        ['fa-parachute-box'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/parachute-box.svg',
        ['fa-paragraph'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/paragraph.svg',
        ['fa-passport'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/passport.svg',
        ['fa-paste'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/paste.svg',
        ['fa-pause'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pause.svg',
        ['fa-paw'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/paw.svg',
        ['fa-peace'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/peace.svg',
        ['fa-pen-clip'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pen-clip.svg',
        ['fa-pen-fancy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pen-fancy.svg',
        ['fa-pen-nib'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pen-nib.svg',
        ['fa-pen-ruler'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pen-ruler.svg',
        ['fa-pen-to-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pen-to-square.svg',
        ['fa-pen'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pen.svg',
        ['fa-pencil'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pencil.svg',
        ['fa-people-arrows-left-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/people-arrows-left-right.svg',
        ['fa-people-carry-box'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/people-carry-box.svg',
        ['fa-people-group'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/people-group.svg',
        ['fa-people-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/people-line.svg',
        ['fa-people-pulling'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/people-pulling.svg',
        ['fa-people-robbery'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/people-robbery.svg',
        ['fa-people-roof'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/people-roof.svg',
        ['fa-pepper-hot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pepper-hot.svg',
        ['fa-percent'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/percent.svg',
        ['fa-person-arrow-down-to-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-arrow-down-to-line.svg',
        ['fa-person-arrow-up-from-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-arrow-up-from-line.svg',
        ['fa-person-biking'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-biking.svg',
        ['fa-person-booth'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-booth.svg',
        ['fa-person-breastfeeding'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-breastfeeding.svg',
        ['fa-person-burst'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-burst.svg',
        ['fa-person-cane'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-cane.svg',
        ['fa-person-chalkboard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-chalkboard.svg',
        ['fa-person-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-circle-check.svg',
        ['fa-person-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-circle-exclamation.svg',
        ['fa-person-circle-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-circle-minus.svg',
        ['fa-person-circle-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-circle-plus.svg',
        ['fa-person-circle-question'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-circle-question.svg',
        ['fa-person-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-circle-xmark.svg',
        ['fa-person-digging'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-digging.svg',
        ['fa-person-dots-from-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-dots-from-line.svg',
        ['fa-person-dress-burst'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-dress-burst.svg',
        ['fa-person-dress'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-dress.svg',
        ['fa-person-drowning'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-drowning.svg',
        ['fa-person-falling-burst'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-falling-burst.svg',
        ['fa-person-falling'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-falling.svg',
        ['fa-person-half-dress'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-half-dress.svg',
        ['fa-person-harassing'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-harassing.svg',
        ['fa-person-hiking'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-hiking.svg',
        ['fa-person-military-pointing'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-military-pointing.svg',
        ['fa-person-military-rifle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-military-rifle.svg',
        ['fa-person-military-to-person'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-military-to-person.svg',
        ['fa-person-praying'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-praying.svg',
        ['fa-person-pregnant'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-pregnant.svg',
        ['fa-person-rays'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-rays.svg',
        ['fa-person-rifle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-rifle.svg',
        ['fa-person-running'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-running.svg',
        ['fa-person-shelter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-shelter.svg',
        ['fa-person-skating'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-skating.svg',
        ['fa-person-skiing-nordic'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-skiing-nordic.svg',
        ['fa-person-skiing'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-skiing.svg',
        ['fa-person-snowboarding'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-snowboarding.svg',
        ['fa-person-swimming'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-swimming.svg',
        ['fa-person-through-window'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-through-window.svg',
        ['fa-person-walking-arrow-loop-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-walking-arrow-loop-left.svg',
        ['fa-person-walking-arrow-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-walking-arrow-right.svg',
        ['fa-person-walking-dashed-line-arrow-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-walking-dashed-line-arrow-right.svg',
        ['fa-person-walking-luggage'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-walking-luggage.svg',
        ['fa-person-walking-with-cane'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-walking-with-cane.svg',
        ['fa-person-walking'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person-walking.svg',
        ['fa-person'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/person.svg',
        ['fa-peseta-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/peseta-sign.svg',
        ['fa-peso-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/peso-sign.svg',
        ['fa-phone-flip'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/phone-flip.svg',
        ['fa-phone-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/phone-slash.svg',
        ['fa-phone-volume'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/phone-volume.svg',
        ['fa-phone'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/phone.svg',
        ['fa-photo-film'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/photo-film.svg',
        ['fa-piggy-bank'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/piggy-bank.svg',
        ['fa-pills'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pills.svg',
        ['fa-pizza-slice'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pizza-slice.svg',
        ['fa-place-of-worship'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/place-of-worship.svg',
        ['fa-plane-arrival'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plane-arrival.svg',
        ['fa-plane-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plane-circle-check.svg',
        ['fa-plane-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plane-circle-exclamation.svg',
        ['fa-plane-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plane-circle-xmark.svg',
        ['fa-plane-departure'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plane-departure.svg',
        ['fa-plane-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plane-lock.svg',
        ['fa-plane-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plane-slash.svg',
        ['fa-plane-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plane-up.svg',
        ['fa-plane'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plane.svg',
        ['fa-plant-wilt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plant-wilt.svg',
        ['fa-plate-wheat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plate-wheat.svg',
        ['fa-play'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/play.svg',
        ['fa-plug-circle-bolt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plug-circle-bolt.svg',
        ['fa-plug-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plug-circle-check.svg',
        ['fa-plug-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plug-circle-exclamation.svg',
        ['fa-plug-circle-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plug-circle-minus.svg',
        ['fa-plug-circle-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plug-circle-plus.svg',
        ['fa-plug-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plug-circle-xmark.svg',
        ['fa-plug'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plug.svg',
        ['fa-plus-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plus-minus.svg',
        ['fa-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/plus.svg',
        ['fa-podcast'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/podcast.svg',
        ['fa-poo-storm'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/poo-storm.svg',
        ['fa-poo'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/poo.svg',
        ['fa-poop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/poop.svg',
        ['fa-power-off'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/power-off.svg',
        ['fa-prescription-bottle-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/prescription-bottle-medical.svg',
        ['fa-prescription-bottle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/prescription-bottle.svg',
        ['fa-prescription'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/prescription.svg',
        ['fa-print'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/print.svg',
        ['fa-pump-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pump-medical.svg',
        ['fa-pump-soap'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pump-soap.svg',
        ['fa-puzzle-piece'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/puzzle-piece.svg',
        ['fa-q'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/q.svg',
        ['fa-qrcode'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/qrcode.svg',
        ['fa-question'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/question.svg',
        ['fa-quote-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/quote-left.svg',
        ['fa-quote-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/quote-right.svg',
        ['fa-r'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/r.svg',
        ['fa-radiation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/radiation.svg',
        ['fa-radio'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/radio.svg',
        ['fa-rainbow'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rainbow.svg',
        ['fa-ranking-star'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ranking-star.svg',
        ['fa-receipt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/receipt.svg',
        ['fa-record-vinyl'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/record-vinyl.svg',
        ['fa-rectangle-ad'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rectangle-ad.svg',
        ['fa-rectangle-list'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rectangle-list.svg',
        ['fa-rectangle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rectangle-xmark.svg',
        ['fa-recycle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/recycle.svg',
        ['fa-registered'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/registered.svg',
        ['fa-repeat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/repeat.svg',
        ['fa-reply-all'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/reply-all.svg',
        ['fa-reply'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/reply.svg',
        ['fa-republican'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/republican.svg',
        ['fa-restroom'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/restroom.svg',
        ['fa-retweet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/retweet.svg',
        ['fa-ribbon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ribbon.svg',
        ['fa-right-from-bracket'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/right-from-bracket.svg',
        ['fa-right-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/right-left.svg',
        ['fa-right-long'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/right-long.svg',
        ['fa-right-to-bracket'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/right-to-bracket.svg',
        ['fa-ring'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ring.svg',
        ['fa-road-barrier'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/road-barrier.svg',
        ['fa-road-bridge'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/road-bridge.svg',
        ['fa-road-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/road-circle-check.svg',
        ['fa-road-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/road-circle-exclamation.svg',
        ['fa-road-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/road-circle-xmark.svg',
        ['fa-road-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/road-lock.svg',
        ['fa-road-spikes'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/road-spikes.svg',
        ['fa-road'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/road.svg',
        ['fa-robot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/robot.svg',
        ['fa-rocket'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rocket.svg',
        ['fa-rotate-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rotate-left.svg',
        ['fa-rotate-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rotate-right.svg',
        ['fa-rotate'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rotate.svg',
        ['fa-route'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/route.svg',
        ['fa-rss'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rss.svg',
        ['fa-ruble-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ruble-sign.svg',
        ['fa-rug'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rug.svg',
        ['fa-ruler-combined'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ruler-combined.svg',
        ['fa-ruler-horizontal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ruler-horizontal.svg',
        ['fa-ruler-vertical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ruler-vertical.svg',
        ['fa-ruler'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ruler.svg',
        ['fa-rupee-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rupee-sign.svg',
        ['fa-rupiah-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rupiah-sign.svg',
        ['fa-s'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/s.svg',
        ['fa-sack-dollar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sack-dollar.svg',
        ['fa-sack-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sack-xmark.svg',
        ['fa-sailboat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sailboat.svg',
        ['fa-satellite-dish'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/satellite-dish.svg',
        ['fa-satellite'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/satellite.svg',
        ['fa-scale-balanced'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/scale-balanced.svg',
        ['fa-scale-unbalanced-flip'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/scale-unbalanced-flip.svg',
        ['fa-scale-unbalanced'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/scale-unbalanced.svg',
        ['fa-school-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/school-circle-check.svg',
        ['fa-school-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/school-circle-exclamation.svg',
        ['fa-school-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/school-circle-xmark.svg',
        ['fa-school-flag'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/school-flag.svg',
        ['fa-school-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/school-lock.svg',
        ['fa-school'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/school.svg',
        ['fa-scissors'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/scissors.svg',
        ['fa-screwdriver-wrench'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/screwdriver-wrench.svg',
        ['fa-screwdriver'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/screwdriver.svg',
        ['fa-scroll-torah'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/scroll-torah.svg',
        ['fa-scroll'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/scroll.svg',
        ['fa-sd-card'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sd-card.svg',
        ['fa-section'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/section.svg',
        ['fa-seedling'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/seedling.svg',
        ['fa-server'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/server.svg',
        ['fa-shapes'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shapes.svg',
        ['fa-share-from-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/share-from-square.svg',
        ['fa-share-nodes'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/share-nodes.svg',
        ['fa-share'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/share.svg',
        ['fa-sheet-plastic'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sheet-plastic.svg',
        ['fa-shekel-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shekel-sign.svg',
        ['fa-shield-blank'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shield-blank.svg',
        ['fa-shield-cat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shield-cat.svg',
        ['fa-shield-dog'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shield-dog.svg',
        ['fa-shield-halved'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shield-halved.svg',
        ['fa-shield-heart'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shield-heart.svg',
        ['fa-shield-virus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shield-virus.svg',
        ['fa-shield'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shield.svg',
        ['fa-ship'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ship.svg',
        ['fa-shirt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shirt.svg',
        ['fa-shoe-prints'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shoe-prints.svg',
        ['fa-shop-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shop-lock.svg',
        ['fa-shop-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shop-slash.svg',
        ['fa-shop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shop.svg',
        ['fa-shower'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shower.svg',
        ['fa-shrimp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shrimp.svg',
        ['fa-shuffle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shuffle.svg',
        ['fa-shuttle-space'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shuttle-space.svg',
        ['fa-sign-hanging'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sign-hanging.svg',
        ['fa-signal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/signal.svg',
        ['fa-signature'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/signature.svg',
        ['fa-signs-post'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/signs-post.svg',
        ['fa-sim-card'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sim-card.svg',
        ['fa-sink'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sink.svg',
        ['fa-sitemap'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sitemap.svg',
        ['fa-skull-crossbones'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/skull-crossbones.svg',
        ['fa-skull'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/skull.svg',
        ['fa-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/slash.svg',
        ['fa-sleigh'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sleigh.svg',
        ['fa-sliders'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sliders.svg',
        ['fa-smog'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/smog.svg',
        ['fa-smoking'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/smoking.svg',
        ['fa-snowflake'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/snowflake.svg',
        ['fa-snowman'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/snowman.svg',
        ['fa-snowplow'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/snowplow.svg',
        ['fa-soap'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/soap.svg',
        ['fa-socks'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/socks.svg',
        ['fa-solar-panel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/solar-panel.svg',
        ['fa-sort-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sort-down.svg',
        ['fa-sort-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sort-up.svg',
        ['fa-sort'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sort.svg',
        ['fa-spa'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/spa.svg',
        ['fa-spaghetti-monster-flying'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/spaghetti-monster-flying.svg',
        ['fa-spell-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/spell-check.svg',
        ['fa-spider'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/spider.svg',
        ['fa-spinner'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/spinner.svg',
        ['fa-splotch'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/splotch.svg',
        ['fa-spoon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/spoon.svg',
        ['fa-spray-can-sparkles'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/spray-can-sparkles.svg',
        ['fa-spray-can'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/spray-can.svg',
        ['fa-square-arrow-up-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-arrow-up-right.svg',
        ['fa-square-caret-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-caret-down.svg',
        ['fa-square-caret-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-caret-left.svg',
        ['fa-square-caret-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-caret-right.svg',
        ['fa-square-caret-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-caret-up.svg',
        ['fa-square-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-check.svg',
        ['fa-square-envelope'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-envelope.svg',
        ['fa-square-full'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-full.svg',
        ['fa-square-h'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-h.svg',
        ['fa-square-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-minus.svg',
        ['fa-square-nfi'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-nfi.svg',
        ['fa-square-parking'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-parking.svg',
        ['fa-square-pen'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-pen.svg',
        ['fa-square-person-confined'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-person-confined.svg',
        ['fa-square-phone-flip'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-phone-flip.svg',
        ['fa-square-phone'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-phone.svg',
        ['fa-square-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-plus.svg',
        ['fa-square-poll-horizontal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-poll-horizontal.svg',
        ['fa-square-poll-vertical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-poll-vertical.svg',
        ['fa-square-root-variable'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-root-variable.svg',
        ['fa-square-rss'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-rss.svg',
        ['fa-square-share-nodes'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-share-nodes.svg',
        ['fa-square-up-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-up-right.svg',
        ['fa-square-virus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-virus.svg',
        ['fa-square-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-xmark.svg',
        ['fa-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square.svg',
        ['fa-staff-aesculapius'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/staff-aesculapius.svg',
        ['fa-stairs'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stairs.svg',
        ['fa-stamp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stamp.svg',
        ['fa-star-and-crescent'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/star-and-crescent.svg',
        ['fa-star-half-stroke'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/star-half-stroke.svg',
        ['fa-star-half'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/star-half.svg',
        ['fa-star-of-david'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/star-of-david.svg',
        ['fa-star-of-life'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/star-of-life.svg',
        ['fa-star'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/star.svg',
        ['fa-sterling-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sterling-sign.svg',
        ['fa-stethoscope'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stethoscope.svg',
        ['fa-stop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stop.svg',
        ['fa-stopwatch-20'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stopwatch-20.svg',
        ['fa-stopwatch'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stopwatch.svg',
        ['fa-store-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/store-slash.svg',
        ['fa-store'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/store.svg',
        ['fa-street-view'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/street-view.svg',
        ['fa-strikethrough'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/strikethrough.svg',
        ['fa-stroopwafel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stroopwafel.svg',
        ['fa-subscript'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/subscript.svg',
        ['fa-suitcase-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/suitcase-medical.svg',
        ['fa-suitcase-rolling'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/suitcase-rolling.svg',
        ['fa-suitcase'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/suitcase.svg',
        ['fa-sun-plant-wilt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sun-plant-wilt.svg',
        ['fa-sun'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sun.svg',
        ['fa-superscript'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/superscript.svg',
        ['fa-swatchbook'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/swatchbook.svg',
        ['fa-synagogue'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/synagogue.svg',
        ['fa-syringe'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/syringe.svg',
        ['fa-t'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/t.svg',
        ['fa-table-cells-large'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/table-cells-large.svg',
        ['fa-table-cells'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/table-cells.svg',
        ['fa-table-columns'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/table-columns.svg',
        ['fa-table-list'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/table-list.svg',
        ['fa-table-tennis-paddle-ball'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/table-tennis-paddle-ball.svg',
        ['fa-table'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/table.svg',
        ['fa-tablet-button'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tablet-button.svg',
        ['fa-tablet-screen-button'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tablet-screen-button.svg',
        ['fa-tablet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tablet.svg',
        ['fa-tablets'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tablets.svg',
        ['fa-tachograph-digital'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tachograph-digital.svg',
        ['fa-tag'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tag.svg',
        ['fa-tags'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tags.svg',
        ['fa-tape'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tape.svg',
        ['fa-tarp-droplet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tarp-droplet.svg',
        ['fa-tarp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tarp.svg',
        ['fa-taxi'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/taxi.svg',
        ['fa-teeth-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/teeth-open.svg',
        ['fa-teeth'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/teeth.svg',
        ['fa-temperature-arrow-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/temperature-arrow-down.svg',
        ['fa-temperature-arrow-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/temperature-arrow-up.svg',
        ['fa-temperature-empty'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/temperature-empty.svg',
        ['fa-temperature-full'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/temperature-full.svg',
        ['fa-temperature-half'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/temperature-half.svg',
        ['fa-temperature-high'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/temperature-high.svg',
        ['fa-temperature-low'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/temperature-low.svg',
        ['fa-temperature-quarter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/temperature-quarter.svg',
        ['fa-temperature-three-quarters'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/temperature-three-quarters.svg',
        ['fa-tenge-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tenge-sign.svg',
        ['fa-tent-arrow-down-to-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tent-arrow-down-to-line.svg',
        ['fa-tent-arrow-left-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tent-arrow-left-right.svg',
        ['fa-tent-arrow-turn-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tent-arrow-turn-left.svg',
        ['fa-tent-arrows-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tent-arrows-down.svg',
        ['fa-tent'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tent.svg',
        ['fa-tents'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tents.svg',
        ['fa-terminal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/terminal.svg',
        ['fa-text-height'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/text-height.svg',
        ['fa-text-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/text-slash.svg',
        ['fa-text-width'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/text-width.svg',
        ['fa-thermometer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/thermometer.svg',
        ['fa-thumbs-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/thumbs-down.svg',
        ['fa-thumbs-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/thumbs-up.svg',
        ['fa-thumbtack'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/thumbtack.svg',
        ['fa-ticket-simple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ticket-simple.svg',
        ['fa-ticket'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ticket.svg',
        ['fa-timeline'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/timeline.svg',
        ['fa-toggle-off'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/toggle-off.svg',
        ['fa-toggle-on'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/toggle-on.svg',
        ['fa-toilet-paper-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/toilet-paper-slash.svg',
        ['fa-toilet-paper'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/toilet-paper.svg',
        ['fa-toilet-portable'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/toilet-portable.svg',
        ['fa-toilet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/toilet.svg',
        ['fa-toilets-portable'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/toilets-portable.svg',
        ['fa-toolbox'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/toolbox.svg',
        ['fa-tooth'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tooth.svg',
        ['fa-torii-gate'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/torii-gate.svg',
        ['fa-tornado'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tornado.svg',
        ['fa-tower-broadcast'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tower-broadcast.svg',
        ['fa-tower-cell'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tower-cell.svg',
        ['fa-tower-observation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tower-observation.svg',
        ['fa-tractor'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tractor.svg',
        ['fa-trademark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trademark.svg',
        ['fa-traffic-light'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/traffic-light.svg',
        ['fa-trailer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trailer.svg',
        ['fa-train-subway'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/train-subway.svg',
        ['fa-train-tram'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/train-tram.svg',
        ['fa-train'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/train.svg',
        ['fa-transgender'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/transgender.svg',
        ['fa-trash-arrow-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trash-arrow-up.svg',
        ['fa-trash-can-arrow-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trash-can-arrow-up.svg',
        ['fa-trash-can'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trash-can.svg',
        ['fa-trash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trash.svg',
        ['fa-tree-city'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tree-city.svg',
        ['fa-tree'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tree.svg',
        ['fa-triangle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/triangle-exclamation.svg',
        ['fa-trophy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trophy.svg',
        ['fa-trowel-bricks'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trowel-bricks.svg',
        ['fa-trowel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trowel.svg',
        ['fa-truck-arrow-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-arrow-right.svg',
        ['fa-truck-droplet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-droplet.svg',
        ['fa-truck-fast'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-fast.svg',
        ['fa-truck-field-un'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-field-un.svg',
        ['fa-truck-field'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-field.svg',
        ['fa-truck-front'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-front.svg',
        ['fa-truck-medical'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-medical.svg',
        ['fa-truck-monster'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-monster.svg',
        ['fa-truck-moving'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-moving.svg',
        ['fa-truck-pickup'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-pickup.svg',
        ['fa-truck-plane'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-plane.svg',
        ['fa-truck-ramp-box'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck-ramp-box.svg',
        ['fa-truck'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/truck.svg',
        ['fa-tty'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tty.svg',
        ['fa-turkish-lira-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/turkish-lira-sign.svg',
        ['fa-turn-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/turn-down.svg',
        ['fa-turn-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/turn-up.svg',
        ['fa-tv'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tv.svg',
        ['fa-u'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/u.svg',
        ['fa-umbrella-beach'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/umbrella-beach.svg',
        ['fa-umbrella'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/umbrella.svg',
        ['fa-underline'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/underline.svg',
        ['fa-universal-access'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/universal-access.svg',
        ['fa-unlock-keyhole'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/unlock-keyhole.svg',
        ['fa-unlock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/unlock.svg',
        ['fa-up-down-left-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/up-down-left-right.svg',
        ['fa-up-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/up-down.svg',
        ['fa-up-long'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/up-long.svg',
        ['fa-up-right-and-down-left-from-center'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/up-right-and-down-left-from-center.svg',
        ['fa-up-right-from-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/up-right-from-square.svg',
        ['fa-upload'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/upload.svg',
        ['fa-user-astronaut'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-astronaut.svg',
        ['fa-user-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-check.svg',
        ['fa-user-clock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-clock.svg',
        ['fa-user-doctor'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-doctor.svg',
        ['fa-user-gear'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-gear.svg',
        ['fa-user-graduate'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-graduate.svg',
        ['fa-user-group'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-group.svg',
        ['fa-user-injured'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-injured.svg',
        ['fa-user-large-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-large-slash.svg',
        ['fa-user-large'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-large.svg',
        ['fa-user-lock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-lock.svg',
        ['fa-user-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-minus.svg',
        ['fa-user-ninja'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-ninja.svg',
        ['fa-user-nurse'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-nurse.svg',
        ['fa-user-pen'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-pen.svg',
        ['fa-user-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-plus.svg',
        ['fa-user-secret'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-secret.svg',
        ['fa-user-shield'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-shield.svg',
        ['fa-user-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-slash.svg',
        ['fa-user-tag'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-tag.svg',
        ['fa-user-tie'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-tie.svg',
        ['fa-user-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user-xmark.svg',
        ['fa-user'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user.svg',
        ['fa-users-between-lines'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/users-between-lines.svg',
        ['fa-users-gear'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/users-gear.svg',
        ['fa-users-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/users-line.svg',
        ['fa-users-rays'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/users-rays.svg',
        ['fa-users-rectangle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/users-rectangle.svg',
        ['fa-users-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/users-slash.svg',
        ['fa-users-viewfinder'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/users-viewfinder.svg',
        ['fa-users'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/users.svg',
        ['fa-utensils'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/utensils.svg',
        ['fa-v'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/v.svg',
        ['fa-van-shuttle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/van-shuttle.svg',
        ['fa-vault'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vault.svg',
        ['fa-vector-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vector-square.svg',
        ['fa-venus-double'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/venus-double.svg',
        ['fa-venus-mars'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/venus-mars.svg',
        ['fa-venus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/venus.svg',
        ['fa-vest-patches'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vest-patches.svg',
        ['fa-vest'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vest.svg',
        ['fa-vial-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vial-circle-check.svg',
        ['fa-vial-virus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vial-virus.svg',
        ['fa-vial'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vial.svg',
        ['fa-vials'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vials.svg',
        ['fa-video-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/video-slash.svg',
        ['fa-video'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/video.svg',
        ['fa-vihara'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vihara.svg',
        ['fa-virus-covid-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/virus-covid-slash.svg',
        ['fa-virus-covid'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/virus-covid.svg',
        ['fa-virus-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/virus-slash.svg',
        ['fa-virus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/virus.svg',
        ['fa-viruses'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/viruses.svg',
        ['fa-voicemail'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/voicemail.svg',
        ['fa-volcano'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/volcano.svg',
        ['fa-volleyball'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/volleyball.svg',
        ['fa-volume-high'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/volume-high.svg',
        ['fa-volume-low'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/volume-low.svg',
        ['fa-volume-off'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/volume-off.svg',
        ['fa-volume-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/volume-xmark.svg',
        ['fa-vr-cardboard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vr-cardboard.svg',
        ['fa-w'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/w.svg',
        ['fa-walkie-talkie'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/walkie-talkie.svg',
        ['fa-wallet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wallet.svg',
        ['fa-wand-magic-sparkles'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wand-magic-sparkles.svg',
        ['fa-wand-magic'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wand-magic.svg',
        ['fa-wand-sparkles'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wand-sparkles.svg',
        ['fa-warehouse'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/warehouse.svg',
        ['fa-water-ladder'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/water-ladder.svg',
        ['fa-water'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/water.svg',
        ['fa-wave-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wave-square.svg',
        ['fa-weight-hanging'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/weight-hanging.svg',
        ['fa-weight-scale'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/weight-scale.svg',
        ['fa-wheat-awn-circle-exclamation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wheat-awn-circle-exclamation.svg',
        ['fa-wheat-awn'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wheat-awn.svg',
        ['fa-wheelchair-move'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wheelchair-move.svg',
        ['fa-wheelchair'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wheelchair.svg',
        ['fa-whiskey-glass'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/whiskey-glass.svg',
        ['fa-wifi'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wifi.svg',
        ['fa-wind'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wind.svg',
        ['fa-window-maximize'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/window-maximize.svg',
        ['fa-window-minimize'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/window-minimize.svg',
        ['fa-window-restore'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/window-restore.svg',
        ['fa-wine-bottle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wine-bottle.svg',
        ['fa-wine-glass-empty'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wine-glass-empty.svg',
        ['fa-wine-glass'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wine-glass.svg',
        ['fa-won-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/won-sign.svg',
        ['fa-worm'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/worm.svg',
        ['fa-wrench'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wrench.svg',
        ['fa-x-ray'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/x-ray.svg',
        ['fa-x'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/x.svg',
        ['fa-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/xmark.svg',
        ['fa-xmarks-lines'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/xmarks-lines.svg',
        ['fa-y'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/y.svg',
        ['fa-yen-sign'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/yen-sign.svg',
        ['fa-yin-yang'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/yin-yang.svg',
        ['fa-z'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/z.svg',
    },
    ['fa-regular'] = {
        ['fa-address-book'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/address-book.svg',
        ['fa-address-card'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/address-card.svg',
        ['fa-bell-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bell-slash.svg',
        ['fa-bell'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bell.svg',
        ['fa-bookmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bookmark.svg',
        ['fa-building'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/building.svg',
        ['fa-calendar-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-check.svg',
        ['fa-calendar-days'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-days.svg',
        ['fa-calendar-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-minus.svg',
        ['fa-calendar-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-plus.svg',
        ['fa-calendar-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar-xmark.svg',
        ['fa-calendar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/calendar.svg',
        ['fa-chart-bar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chart-bar.svg',
        ['fa-chess-bishop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-bishop.svg',
        ['fa-chess-king'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-king.svg',
        ['fa-chess-knight'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-knight.svg',
        ['fa-chess-pawn'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-pawn.svg',
        ['fa-chess-queen'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-queen.svg',
        ['fa-chess-rook'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chess-rook.svg',
        ['fa-circle-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-check.svg',
        ['fa-circle-dot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-dot.svg',
        ['fa-circle-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-down.svg',
        ['fa-circle-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-left.svg',
        ['fa-circle-pause'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-pause.svg',
        ['fa-circle-play'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-play.svg',
        ['fa-circle-question'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-question.svg',
        ['fa-circle-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-right.svg',
        ['fa-circle-stop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-stop.svg',
        ['fa-circle-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-up.svg',
        ['fa-circle-user'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-user.svg',
        ['fa-circle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle-xmark.svg',
        ['fa-circle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/circle.svg',
        ['fa-clipboard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clipboard.svg',
        ['fa-clock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clock.svg',
        ['fa-clone'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/clone.svg',
        ['fa-closed-captioning'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/closed-captioning.svg',
        ['fa-comment-dots'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comment-dots.svg',
        ['fa-comment'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comment.svg',
        ['fa-comments'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/comments.svg',
        ['fa-compass'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/compass.svg',
        ['fa-copy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/copy.svg',
        ['fa-copyright'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/copyright.svg',
        ['fa-credit-card'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/credit-card.svg',
        ['fa-envelope-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/envelope-open.svg',
        ['fa-envelope'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/envelope.svg',
        ['fa-eye-slash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/eye-slash.svg',
        ['fa-eye'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/eye.svg',
        ['fa-face-angry'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-angry.svg',
        ['fa-face-dizzy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-dizzy.svg',
        ['fa-face-flushed'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-flushed.svg',
        ['fa-face-frown-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-frown-open.svg',
        ['fa-face-frown'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-frown.svg',
        ['fa-face-grimace'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grimace.svg',
        ['fa-face-grin-beam-sweat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-beam-sweat.svg',
        ['fa-face-grin-beam'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-beam.svg',
        ['fa-face-grin-hearts'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-hearts.svg',
        ['fa-face-grin-squint-tears'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-squint-tears.svg',
        ['fa-face-grin-squint'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-squint.svg',
        ['fa-face-grin-stars'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-stars.svg',
        ['fa-face-grin-tears'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-tears.svg',
        ['fa-face-grin-tongue-squint'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-tongue-squint.svg',
        ['fa-face-grin-tongue-wink'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-tongue-wink.svg',
        ['fa-face-grin-tongue'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-tongue.svg',
        ['fa-face-grin-wide'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-wide.svg',
        ['fa-face-grin-wink'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin-wink.svg',
        ['fa-face-grin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-grin.svg',
        ['fa-face-kiss-beam'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-kiss-beam.svg',
        ['fa-face-kiss-wink-heart'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-kiss-wink-heart.svg',
        ['fa-face-kiss'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-kiss.svg',
        ['fa-face-laugh-beam'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-laugh-beam.svg',
        ['fa-face-laugh-squint'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-laugh-squint.svg',
        ['fa-face-laugh-wink'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-laugh-wink.svg',
        ['fa-face-laugh'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-laugh.svg',
        ['fa-face-meh-blank'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-meh-blank.svg',
        ['fa-face-meh'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-meh.svg',
        ['fa-face-rolling-eyes'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-rolling-eyes.svg',
        ['fa-face-sad-cry'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-sad-cry.svg',
        ['fa-face-sad-tear'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-sad-tear.svg',
        ['fa-face-smile-beam'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-smile-beam.svg',
        ['fa-face-smile-wink'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-smile-wink.svg',
        ['fa-face-smile'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-smile.svg',
        ['fa-face-surprise'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-surprise.svg',
        ['fa-face-tired'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/face-tired.svg',
        ['fa-file-audio'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-audio.svg',
        ['fa-file-code'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-code.svg',
        ['fa-file-excel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-excel.svg',
        ['fa-file-image'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-image.svg',
        ['fa-file-lines'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-lines.svg',
        ['fa-file-pdf'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-pdf.svg',
        ['fa-file-powerpoint'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-powerpoint.svg',
        ['fa-file-video'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-video.svg',
        ['fa-file-word'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-word.svg',
        ['fa-file-zipper'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file-zipper.svg',
        ['fa-file'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/file.svg',
        ['fa-flag'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/flag.svg',
        ['fa-floppy-disk'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/floppy-disk.svg',
        ['fa-folder-closed'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/folder-closed.svg',
        ['fa-folder-open'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/folder-open.svg',
        ['fa-folder'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/folder.svg',
        ['fa-font-awesome'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/font-awesome.svg',
        ['fa-futbol'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/futbol.svg',
        ['fa-gem'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gem.svg',
        ['fa-hand-back-fist'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-back-fist.svg',
        ['fa-hand-lizard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-lizard.svg',
        ['fa-hand-peace'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-peace.svg',
        ['fa-hand-point-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-point-down.svg',
        ['fa-hand-point-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-point-left.svg',
        ['fa-hand-point-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-point-right.svg',
        ['fa-hand-point-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-point-up.svg',
        ['fa-hand-pointer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-pointer.svg',
        ['fa-hand-scissors'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-scissors.svg',
        ['fa-hand-spock'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand-spock.svg',
        ['fa-hand'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hand.svg',
        ['fa-handshake'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/handshake.svg',
        ['fa-hard-drive'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hard-drive.svg',
        ['fa-heart'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/heart.svg',
        ['fa-hospital'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hospital.svg',
        ['fa-hourglass'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hourglass.svg',
        ['fa-id-badge'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/id-badge.svg',
        ['fa-id-card'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/id-card.svg',
        ['fa-image'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/image.svg',
        ['fa-images'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/images.svg',
        ['fa-keyboard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/keyboard.svg',
        ['fa-lemon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lemon.svg',
        ['fa-life-ring'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/life-ring.svg',
        ['fa-lightbulb'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lightbulb.svg',
        ['fa-map'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/map.svg',
        ['fa-message'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/message.svg',
        ['fa-money-bill-1'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/money-bill-1.svg',
        ['fa-moon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/moon.svg',
        ['fa-newspaper'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/newspaper.svg',
        ['fa-note-sticky'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/note-sticky.svg',
        ['fa-object-group'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/object-group.svg',
        ['fa-object-ungroup'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/object-ungroup.svg',
        ['fa-paper-plane'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/paper-plane.svg',
        ['fa-paste'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/paste.svg',
        ['fa-pen-to-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pen-to-square.svg',
        ['fa-rectangle-list'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rectangle-list.svg',
        ['fa-rectangle-xmark'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rectangle-xmark.svg',
        ['fa-registered'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/registered.svg',
        ['fa-share-from-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/share-from-square.svg',
        ['fa-snowflake'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/snowflake.svg',
        ['fa-square-caret-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-caret-down.svg',
        ['fa-square-caret-left'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-caret-left.svg',
        ['fa-square-caret-right'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-caret-right.svg',
        ['fa-square-caret-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-caret-up.svg',
        ['fa-square-check'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-check.svg',
        ['fa-square-full'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-full.svg',
        ['fa-square-minus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-minus.svg',
        ['fa-square-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-plus.svg',
        ['fa-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square.svg',
        ['fa-star-half-stroke'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/star-half-stroke.svg',
        ['fa-star-half'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/star-half.svg',
        ['fa-star'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/star.svg',
        ['fa-sun'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sun.svg',
        ['fa-thumbs-down'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/thumbs-down.svg',
        ['fa-thumbs-up'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/thumbs-up.svg',
        ['fa-trash-can'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trash-can.svg',
        ['fa-user'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/user.svg',
        ['fa-window-maximize'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/window-maximize.svg',
        ['fa-window-minimize'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/window-minimize.svg',
        ['fa-window-restore'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/window-restore.svg',
    },
    ['fa-brands'] = {
        ['fa-42-group'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/42-group.svg',
        ['fa-500px'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/500px.svg',
        ['fa-accessible-icon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/accessible-icon.svg',
        ['fa-accusoft'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/accusoft.svg',
        ['fa-adn'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/adn.svg',
        ['fa-adversal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/adversal.svg',
        ['fa-affiliatetheme'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/affiliatetheme.svg',
        ['fa-airbnb'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/airbnb.svg',
        ['fa-algolia'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/algolia.svg',
        ['fa-alipay'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/alipay.svg',
        ['fa-amazon-pay'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/amazon-pay.svg',
        ['fa-amazon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/amazon.svg',
        ['fa-amilia'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/amilia.svg',
        ['fa-android'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/android.svg',
        ['fa-angellist'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angellist.svg',
        ['fa-angrycreative'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angrycreative.svg',
        ['fa-angular'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/angular.svg',
        ['fa-app-store-ios'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/app-store-ios.svg',
        ['fa-app-store'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/app-store.svg',
        ['fa-apper'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/apper.svg',
        ['fa-apple-pay'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/apple-pay.svg',
        ['fa-apple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/apple.svg',
        ['fa-artstation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/artstation.svg',
        ['fa-asymmetrik'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/asymmetrik.svg',
        ['fa-atlassian'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/atlassian.svg',
        ['fa-audible'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/audible.svg',
        ['fa-autoprefixer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/autoprefixer.svg',
        ['fa-avianex'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/avianex.svg',
        ['fa-aviato'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/aviato.svg',
        ['fa-aws'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/aws.svg',
        ['fa-bandcamp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bandcamp.svg',
        ['fa-battle-net'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/battle-net.svg',
        ['fa-behance-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/behance-square.svg',
        ['fa-behance'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/behance.svg',
        ['fa-bilibili'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bilibili.svg',
        ['fa-bimobject'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bimobject.svg',
        ['fa-bitbucket'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bitbucket.svg',
        ['fa-bitcoin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bitcoin.svg',
        ['fa-bity'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bity.svg',
        ['fa-black-tie'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/black-tie.svg',
        ['fa-blackberry'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/blackberry.svg',
        ['fa-blogger-b'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/blogger-b.svg',
        ['fa-blogger'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/blogger.svg',
        ['fa-bluetooth-b'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bluetooth-b.svg',
        ['fa-bluetooth'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bluetooth.svg',
        ['fa-bootstrap'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bootstrap.svg',
        ['fa-bots'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/bots.svg',
        ['fa-btc'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/btc.svg',
        ['fa-buffer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/buffer.svg',
        ['fa-buromobelexperte'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/buromobelexperte.svg',
        ['fa-buy-n-large'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/buy-n-large.svg',
        ['fa-buysellads'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/buysellads.svg',
        ['fa-canadian-maple-leaf'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/canadian-maple-leaf.svg',
        ['fa-cc-amazon-pay'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cc-amazon-pay.svg',
        ['fa-cc-amex'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cc-amex.svg',
        ['fa-cc-apple-pay'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cc-apple-pay.svg',
        ['fa-cc-diners-club'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cc-diners-club.svg',
        ['fa-cc-discover'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cc-discover.svg',
        ['fa-cc-jcb'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cc-jcb.svg',
        ['fa-cc-mastercard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cc-mastercard.svg',
        ['fa-cc-paypal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cc-paypal.svg',
        ['fa-cc-stripe'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cc-stripe.svg',
        ['fa-cc-visa'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cc-visa.svg',
        ['fa-centercode'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/centercode.svg',
        ['fa-centos'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/centos.svg',
        ['fa-chrome'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chrome.svg',
        ['fa-chromecast'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/chromecast.svg',
        ['fa-cloudflare'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloudflare.svg',
        ['fa-cloudscale'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloudscale.svg',
        ['fa-cloudsmith'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloudsmith.svg',
        ['fa-cloudversify'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cloudversify.svg',
        ['fa-cmplid'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cmplid.svg',
        ['fa-codepen'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/codepen.svg',
        ['fa-codiepie'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/codiepie.svg',
        ['fa-confluence'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/confluence.svg',
        ['fa-connectdevelop'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/connectdevelop.svg',
        ['fa-contao'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/contao.svg',
        ['fa-cotton-bureau'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cotton-bureau.svg',
        ['fa-cpanel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cpanel.svg',
        ['fa-creative-commons-by'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-by.svg',
        ['fa-creative-commons-nc-eu'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-nc-eu.svg',
        ['fa-creative-commons-nc-jp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-nc-jp.svg',
        ['fa-creative-commons-nc'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-nc.svg',
        ['fa-creative-commons-nd'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-nd.svg',
        ['fa-creative-commons-pd-alt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-pd-alt.svg',
        ['fa-creative-commons-pd'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-pd.svg',
        ['fa-creative-commons-remix'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-remix.svg',
        ['fa-creative-commons-sa'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-sa.svg',
        ['fa-creative-commons-sampling-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-sampling-plus.svg',
        ['fa-creative-commons-sampling'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-sampling.svg',
        ['fa-creative-commons-share'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-share.svg',
        ['fa-creative-commons-zero'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons-zero.svg',
        ['fa-creative-commons'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/creative-commons.svg',
        ['fa-critical-role'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/critical-role.svg',
        ['fa-css3-alt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/css3-alt.svg',
        ['fa-css3'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/css3.svg',
        ['fa-cuttlefish'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/cuttlefish.svg',
        ['fa-d-and-d-beyond'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/d-and-d-beyond.svg',
        ['fa-d-and-d'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/d-and-d.svg',
        ['fa-dailymotion'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dailymotion.svg',
        ['fa-dashcube'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dashcube.svg',
        ['fa-deezer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/deezer.svg',
        ['fa-delicious'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/delicious.svg',
        ['fa-deploydog'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/deploydog.svg',
        ['fa-deskpro'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/deskpro.svg',
        ['fa-dev'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dev.svg',
        ['fa-deviantart'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/deviantart.svg',
        ['fa-dhl'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dhl.svg',
        ['fa-diaspora'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/diaspora.svg',
        ['fa-digg'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/digg.svg',
        ['fa-digital-ocean'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/digital-ocean.svg',
        ['fa-discord'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/discord.svg',
        ['fa-discourse'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/discourse.svg',
        ['fa-dochub'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dochub.svg',
        ['fa-docker'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/docker.svg',
        ['fa-draft2digital'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/draft2digital.svg',
        ['fa-dribbble-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dribbble-square.svg',
        ['fa-dribbble'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dribbble.svg',
        ['fa-dropbox'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dropbox.svg',
        ['fa-drupal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/drupal.svg',
        ['fa-dyalog'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/dyalog.svg',
        ['fa-earlybirds'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/earlybirds.svg',
        ['fa-ebay'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ebay.svg',
        ['fa-edge-legacy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/edge-legacy.svg',
        ['fa-edge'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/edge.svg',
        ['fa-elementor'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/elementor.svg',
        ['fa-ello'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ello.svg',
        ['fa-ember'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ember.svg',
        ['fa-empire'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/empire.svg',
        ['fa-envira'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/envira.svg',
        ['fa-erlang'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/erlang.svg',
        ['fa-ethereum'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ethereum.svg',
        ['fa-etsy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/etsy.svg',
        ['fa-evernote'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/evernote.svg',
        ['fa-expeditedssl'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/expeditedssl.svg',
        ['fa-facebook-f'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/facebook-f.svg',
        ['fa-facebook-messenger'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/facebook-messenger.svg',
        ['fa-facebook-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/facebook-square.svg',
        ['fa-facebook'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/facebook.svg',
        ['fa-fantasy-flight-games'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fantasy-flight-games.svg',
        ['fa-fedex'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fedex.svg',
        ['fa-fedora'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fedora.svg',
        ['fa-figma'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/figma.svg',
        ['fa-firefox-browser'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/firefox-browser.svg',
        ['fa-firefox'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/firefox.svg',
        ['fa-first-order-alt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/first-order-alt.svg',
        ['fa-first-order'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/first-order.svg',
        ['fa-firstdraft'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/firstdraft.svg',
        ['fa-flickr'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/flickr.svg',
        ['fa-flipboard'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/flipboard.svg',
        ['fa-fly'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fly.svg',
        ['fa-font-awesome'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/font-awesome.svg',
        ['fa-fonticons-fi'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fonticons-fi.svg',
        ['fa-fonticons'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fonticons.svg',
        ['fa-fort-awesome-alt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fort-awesome-alt.svg',
        ['fa-fort-awesome'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fort-awesome.svg',
        ['fa-forumbee'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/forumbee.svg',
        ['fa-foursquare'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/foursquare.svg',
        ['fa-free-code-camp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/free-code-camp.svg',
        ['fa-freebsd'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/freebsd.svg',
        ['fa-fulcrum'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/fulcrum.svg',
        ['fa-galactic-republic'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/galactic-republic.svg',
        ['fa-galactic-senate'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/galactic-senate.svg',
        ['fa-get-pocket'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/get-pocket.svg',
        ['fa-gg-circle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gg-circle.svg',
        ['fa-gg'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gg.svg',
        ['fa-git-alt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/git-alt.svg',
        ['fa-git-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/git-square.svg',
        ['fa-git'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/git.svg',
        ['fa-github-alt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/github-alt.svg',
        ['fa-github-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/github-square.svg',
        ['fa-github'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/github.svg',
        ['fa-gitkraken'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gitkraken.svg',
        ['fa-gitlab'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gitlab.svg',
        ['fa-gitter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gitter.svg',
        ['fa-glide-g'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/glide-g.svg',
        ['fa-glide'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/glide.svg',
        ['fa-gofore'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gofore.svg',
        ['fa-golang'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/golang.svg',
        ['fa-goodreads-g'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/goodreads-g.svg',
        ['fa-goodreads'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/goodreads.svg',
        ['fa-google-drive'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/google-drive.svg',
        ['fa-google-pay'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/google-pay.svg',
        ['fa-google-play'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/google-play.svg',
        ['fa-google-plus-g'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/google-plus-g.svg',
        ['fa-google-plus-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/google-plus-square.svg',
        ['fa-google-plus'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/google-plus.svg',
        ['fa-google-wallet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/google-wallet.svg',
        ['fa-google'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/google.svg',
        ['fa-gratipay'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gratipay.svg',
        ['fa-grav'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/grav.svg',
        ['fa-gripfire'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gripfire.svg',
        ['fa-grunt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/grunt.svg',
        ['fa-guilded'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/guilded.svg',
        ['fa-gulp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/gulp.svg',
        ['fa-hacker-news-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hacker-news-square.svg',
        ['fa-hacker-news'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hacker-news.svg',
        ['fa-hackerrank'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hackerrank.svg',
        ['fa-hashnode'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hashnode.svg',
        ['fa-hips'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hips.svg',
        ['fa-hire-a-helper'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hire-a-helper.svg',
        ['fa-hive'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hive.svg',
        ['fa-hooli'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hooli.svg',
        ['fa-hornbill'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hornbill.svg',
        ['fa-hotjar'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hotjar.svg',
        ['fa-houzz'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/houzz.svg',
        ['fa-html5'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/html5.svg',
        ['fa-hubspot'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/hubspot.svg',
        ['fa-ideal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ideal.svg',
        ['fa-imdb'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/imdb.svg',
        ['fa-instagram-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/instagram-square.svg',
        ['fa-instagram'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/instagram.svg',
        ['fa-instalod'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/instalod.svg',
        ['fa-intercom'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/intercom.svg',
        ['fa-internet-explorer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/internet-explorer.svg',
        ['fa-invision'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/invision.svg',
        ['fa-ioxhost'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ioxhost.svg',
        ['fa-itch-io'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/itch-io.svg',
        ['fa-itunes-note'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/itunes-note.svg',
        ['fa-itunes'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/itunes.svg',
        ['fa-java'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/java.svg',
        ['fa-jedi-order'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/jedi-order.svg',
        ['fa-jenkins'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/jenkins.svg',
        ['fa-jira'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/jira.svg',
        ['fa-joget'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/joget.svg',
        ['fa-joomla'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/joomla.svg',
        ['fa-js-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/js-square.svg',
        ['fa-js'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/js.svg',
        ['fa-jsfiddle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/jsfiddle.svg',
        ['fa-kaggle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/kaggle.svg',
        ['fa-keybase'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/keybase.svg',
        ['fa-keycdn'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/keycdn.svg',
        ['fa-kickstarter-k'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/kickstarter-k.svg',
        ['fa-kickstarter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/kickstarter.svg',
        ['fa-korvue'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/korvue.svg',
        ['fa-laravel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/laravel.svg',
        ['fa-lastfm-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lastfm-square.svg',
        ['fa-lastfm'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lastfm.svg',
        ['fa-leanpub'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/leanpub.svg',
        ['fa-less'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/less.svg',
        ['fa-line'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/line.svg',
        ['fa-linkedin-in'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/linkedin-in.svg',
        ['fa-linkedin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/linkedin.svg',
        ['fa-linode'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/linode.svg',
        ['fa-linux'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/linux.svg',
        ['fa-lyft'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/lyft.svg',
        ['fa-magento'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/magento.svg',
        ['fa-mailchimp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mailchimp.svg',
        ['fa-mandalorian'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mandalorian.svg',
        ['fa-markdown'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/markdown.svg',
        ['fa-mastodon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mastodon.svg',
        ['fa-maxcdn'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/maxcdn.svg',
        ['fa-mdb'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mdb.svg',
        ['fa-medapps'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/medapps.svg',
        ['fa-medium'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/medium.svg',
        ['fa-medrt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/medrt.svg',
        ['fa-meetup'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/meetup.svg',
        ['fa-megaport'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/megaport.svg',
        ['fa-mendeley'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mendeley.svg',
        ['fa-microblog'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/microblog.svg',
        ['fa-microsoft'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/microsoft.svg',
        ['fa-mix'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mix.svg',
        ['fa-mixcloud'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mixcloud.svg',
        ['fa-mixer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mixer.svg',
        ['fa-mizuni'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/mizuni.svg',
        ['fa-modx'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/modx.svg',
        ['fa-monero'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/monero.svg',
        ['fa-napster'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/napster.svg',
        ['fa-neos'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/neos.svg',
        ['fa-nfc-directional'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/nfc-directional.svg',
        ['fa-nfc-symbol'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/nfc-symbol.svg',
        ['fa-nimblr'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/nimblr.svg',
        ['fa-node-js'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/node-js.svg',
        ['fa-node'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/node.svg',
        ['fa-npm'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/npm.svg',
        ['fa-ns8'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ns8.svg',
        ['fa-nutritionix'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/nutritionix.svg',
        ['fa-octopus-deploy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/octopus-deploy.svg',
        ['fa-odnoklassniki-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/odnoklassniki-square.svg',
        ['fa-odnoklassniki'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/odnoklassniki.svg',
        ['fa-old-republic'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/old-republic.svg',
        ['fa-opencart'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/opencart.svg',
        ['fa-openid'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/openid.svg',
        ['fa-opera'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/opera.svg',
        ['fa-optin-monster'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/optin-monster.svg',
        ['fa-orcid'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/orcid.svg',
        ['fa-osi'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/osi.svg',
        ['fa-padlet'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/padlet.svg',
        ['fa-page4'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/page4.svg',
        ['fa-pagelines'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pagelines.svg',
        ['fa-palfed'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/palfed.svg',
        ['fa-patreon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/patreon.svg',
        ['fa-paypal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/paypal.svg',
        ['fa-perbyte'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/perbyte.svg',
        ['fa-periscope'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/periscope.svg',
        ['fa-phabricator'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/phabricator.svg',
        ['fa-phoenix-framework'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/phoenix-framework.svg',
        ['fa-phoenix-squadron'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/phoenix-squadron.svg',
        ['fa-php'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/php.svg',
        ['fa-pied-piper-alt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pied-piper-alt.svg',
        ['fa-pied-piper-hat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pied-piper-hat.svg',
        ['fa-pied-piper-pp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pied-piper-pp.svg',
        ['fa-pied-piper-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pied-piper-square.svg',
        ['fa-pied-piper'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pied-piper.svg',
        ['fa-pinterest-p'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pinterest-p.svg',
        ['fa-pinterest-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pinterest-square.svg',
        ['fa-pinterest'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pinterest.svg',
        ['fa-pix'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pix.svg',
        ['fa-playstation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/playstation.svg',
        ['fa-product-hunt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/product-hunt.svg',
        ['fa-pushed'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/pushed.svg',
        ['fa-python'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/python.svg',
        ['fa-qq'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/qq.svg',
        ['fa-quinscape'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/quinscape.svg',
        ['fa-quora'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/quora.svg',
        ['fa-r-project'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/r-project.svg',
        ['fa-raspberry-pi'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/raspberry-pi.svg',
        ['fa-ravelry'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ravelry.svg',
        ['fa-react'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/react.svg',
        ['fa-reacteurope'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/reacteurope.svg',
        ['fa-readme'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/readme.svg',
        ['fa-rebel'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rebel.svg',
        ['fa-red-river'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/red-river.svg',
        ['fa-reddit-alien'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/reddit-alien.svg',
        ['fa-reddit-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/reddit-square.svg',
        ['fa-reddit'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/reddit.svg',
        ['fa-redhat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/redhat.svg',
        ['fa-renren'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/renren.svg',
        ['fa-replyd'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/replyd.svg',
        ['fa-researchgate'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/researchgate.svg',
        ['fa-resolving'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/resolving.svg',
        ['fa-rev'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rev.svg',
        ['fa-rocketchat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rocketchat.svg',
        ['fa-rockrms'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rockrms.svg',
        ['fa-rust'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/rust.svg',
        ['fa-safari'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/safari.svg',
        ['fa-salesforce'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/salesforce.svg',
        ['fa-sass'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sass.svg',
        ['fa-schlix'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/schlix.svg',
        ['fa-screenpal'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/screenpal.svg',
        ['fa-scribd'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/scribd.svg',
        ['fa-searchengin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/searchengin.svg',
        ['fa-sellcast'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sellcast.svg',
        ['fa-sellsy'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sellsy.svg',
        ['fa-servicestack'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/servicestack.svg',
        ['fa-shirtsinbulk'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shirtsinbulk.svg',
        ['fa-shopify'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shopify.svg',
        ['fa-shopware'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/shopware.svg',
        ['fa-simplybuilt'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/simplybuilt.svg',
        ['fa-sistrix'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sistrix.svg',
        ['fa-sith'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sith.svg',
        ['fa-sitrox'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sitrox.svg',
        ['fa-sketch'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sketch.svg',
        ['fa-skyatlas'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/skyatlas.svg',
        ['fa-skype'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/skype.svg',
        ['fa-slack'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/slack.svg',
        ['fa-slideshare'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/slideshare.svg',
        ['fa-snapchat-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/snapchat-square.svg',
        ['fa-snapchat'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/snapchat.svg',
        ['fa-soundcloud'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/soundcloud.svg',
        ['fa-sourcetree'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sourcetree.svg',
        ['fa-speakap'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/speakap.svg',
        ['fa-speaker-deck'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/speaker-deck.svg',
        ['fa-spotify'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/spotify.svg',
        ['fa-square-font-awesome-stroke'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-font-awesome-stroke.svg',
        ['fa-square-font-awesome'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/square-font-awesome.svg',
        ['fa-squarespace'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/squarespace.svg',
        ['fa-stack-exchange'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stack-exchange.svg',
        ['fa-stack-overflow'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stack-overflow.svg',
        ['fa-stackpath'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stackpath.svg',
        ['fa-staylinked'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/staylinked.svg',
        ['fa-steam-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/steam-square.svg',
        ['fa-steam-symbol'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/steam-symbol.svg',
        ['fa-steam'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/steam.svg',
        ['fa-sticker-mule'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/sticker-mule.svg',
        ['fa-strava'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/strava.svg',
        ['fa-stripe-s'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stripe-s.svg',
        ['fa-stripe'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stripe.svg',
        ['fa-studiovinari'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/studiovinari.svg',
        ['fa-stumbleupon-circle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stumbleupon-circle.svg',
        ['fa-stumbleupon'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/stumbleupon.svg',
        ['fa-superpowers'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/superpowers.svg',
        ['fa-supple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/supple.svg',
        ['fa-suse'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/suse.svg',
        ['fa-swift'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/swift.svg',
        ['fa-symfony'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/symfony.svg',
        ['fa-teamspeak'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/teamspeak.svg',
        ['fa-telegram'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/telegram.svg',
        ['fa-tencent-weibo'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tencent-weibo.svg',
        ['fa-the-red-yeti'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/the-red-yeti.svg',
        ['fa-themeco'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/themeco.svg',
        ['fa-themeisle'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/themeisle.svg',
        ['fa-think-peaks'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/think-peaks.svg',
        ['fa-tiktok'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tiktok.svg',
        ['fa-trade-federation'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trade-federation.svg',
        ['fa-trello'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/trello.svg',
        ['fa-tumblr-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tumblr-square.svg',
        ['fa-tumblr'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/tumblr.svg',
        ['fa-twitch'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/twitch.svg',
        ['fa-twitter-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/twitter-square.svg',
        ['fa-twitter'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/twitter.svg',
        ['fa-typo3'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/typo3.svg',
        ['fa-uber'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/uber.svg',
        ['fa-ubuntu'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ubuntu.svg',
        ['fa-uikit'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/uikit.svg',
        ['fa-umbraco'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/umbraco.svg',
        ['fa-uncharted'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/uncharted.svg',
        ['fa-uniregistry'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/uniregistry.svg',
        ['fa-unity'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/unity.svg',
        ['fa-unsplash'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/unsplash.svg',
        ['fa-untappd'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/untappd.svg',
        ['fa-ups'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ups.svg',
        ['fa-usb'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/usb.svg',
        ['fa-usps'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/usps.svg',
        ['fa-ussunnah'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/ussunnah.svg',
        ['fa-vaadin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vaadin.svg',
        ['fa-viacoin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/viacoin.svg',
        ['fa-viadeo-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/viadeo-square.svg',
        ['fa-viadeo'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/viadeo.svg',
        ['fa-viber'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/viber.svg',
        ['fa-vimeo-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vimeo-square.svg',
        ['fa-vimeo-v'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vimeo-v.svg',
        ['fa-vimeo'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vimeo.svg',
        ['fa-vine'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vine.svg',
        ['fa-vk'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vk.svg',
        ['fa-vnv'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vnv.svg',
        ['fa-vuejs'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/vuejs.svg',
        ['fa-watchman-monitoring'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/watchman-monitoring.svg',
        ['fa-waze'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/waze.svg',
        ['fa-weebly'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/weebly.svg',
        ['fa-weibo'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/weibo.svg',
        ['fa-weixin'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/weixin.svg',
        ['fa-whatsapp-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/whatsapp-square.svg',
        ['fa-whatsapp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/whatsapp.svg',
        ['fa-whmcs'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/whmcs.svg',
        ['fa-wikipedia-w'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wikipedia-w.svg',
        ['fa-windows'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/windows.svg',
        ['fa-wirsindhandwerk'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wirsindhandwerk.svg',
        ['fa-wix'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wix.svg',
        ['fa-wizards-of-the-coast'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wizards-of-the-coast.svg',
        ['fa-wodu'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wodu.svg',
        ['fa-wolf-pack-battalion'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wolf-pack-battalion.svg',
        ['fa-wordpress-simple'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wordpress-simple.svg',
        ['fa-wordpress'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wordpress.svg',
        ['fa-wpbeginner'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wpbeginner.svg',
        ['fa-wpexplorer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wpexplorer.svg',
        ['fa-wpforms'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wpforms.svg',
        ['fa-wpressr'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/wpressr.svg',
        ['fa-xbox'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/xbox.svg',
        ['fa-xing-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/xing-square.svg',
        ['fa-xing'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/xing.svg',
        ['fa-y-combinator'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/y-combinator.svg',
        ['fa-yahoo'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/yahoo.svg',
        ['fa-yammer'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/yammer.svg',
        ['fa-yandex-international'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/yandex-international.svg',
        ['fa-yandex'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/yandex.svg',
        ['fa-yarn'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/yarn.svg',
        ['fa-yelp'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/yelp.svg',
        ['fa-yoast'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/yoast.svg',
        ['fa-youtube-square'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/youtube-square.svg',
        ['fa-youtube'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/youtube.svg',
        ['fa-zhihu'] = 'https://raw.githubusercontent.com/SloppyDesigns/font-awesome/main/solid/zhihu.svg',
    }
}

exports('CreateMenu', CreateMenu)

exports('CreateInput', CreateInput)