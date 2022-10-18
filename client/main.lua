-- SD Menu
--[[
    exports['sd-menu']:CreateMenu({
        {
            disabled = true,                                        -- Button Disabled                      [Optional]
            header = 'My Apple Menu',                               -- Button Header Text                   [Optional]
            icon = 'fa-solid fa-apple-whole',                       -- Header Icon (Font Awesome v6)        [Optional]
            txt = 'My Awesome Text'                                 -- Buton Text                           [Optional]
            params = {                                              -- Parameters                           [Optional]
                server = true,                                      -- Call Event Server Side               [Optional]
                event = data.event.confirm,                         -- Button Event                         [Required]
                args = {                                            -- Args To Send                         [Optional]
                    'MyFirstArg',
                    'MySecondArg'   
                }                         
            }
        },
    })
]]--

-- SD Input
--[[
    local input, amount = exports['sd-menu']:CreateInput({          -- Input Menu (Input Menu Returns), Input1, Input2, Input3, ...etc  [Required]
        header = 'You Selected '..type..' Apples',                  -- Header Text                                                      [Required]
        inputs = {                                                  -- Inputs                                                           [Required]
            {
                text = 'Amount'                                     -- Input Text                                                       [Required]
            }
        }
    })
]]--

RegisterCommand('sdmenu', function(source, args, rawCommand)
    exports['sd-menu']:CreateMenu({
        {
            disabled = true,
            header = 'My Apple Menu',
            icon = 'fa-solid fa-apple-whole',
        },
        {
            txt = 'Get Some Green Apples',
            params = {
                event = 'sdmenu-apples',
                args = {
                    'Green'
                }
            }
        },
        {
            txt = 'Get Some Red Apples',
            params = {
                event = 'sdmenu-apples',
                args = {
                    'Red'
                }
            }
        },
    })
end, false)

RegisterNetEvent('sdmenu-apples', function(type)
    local input, amount = exports['sd-menu']:CreateInput({
        header = 'You Selected '..type..' Apples',
        inputs = {
            {
                text = 'Amount'
            }
        }
    })
    if input then
        if tonumber(amount) ~= nil then
            print('You Requested '..amount..'x '..type..' Apples')
        end
    end
end)