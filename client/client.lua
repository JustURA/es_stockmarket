--       Licensed under: AGPLv3        --
--  GNU AFFERO GENERAL PUBLIC LICENSE  --
--     Version 3, 19 November 2007     --

-- 해당 스크립트는 es_stockmarket(https://github.com/kanersps/es_stockmarket) 을 수정한 2차 저작물이며
-- AGPL v3 라이센스를 따르고있습니다.
-- 2차 수정 / 상업적 이용 시 인터넷상에 소스 코드를 공개해야 합니다.

function buyStock(stock, amount)
    amount = tonumber(amount)
    if(amount > 0 and amount)then
        TriggerServerEvent("vrp_stockmarket:buyStock", stock, amount)
    end
end

function sellStock(stock, amount)
    amount = tonumber(amount)
    if(amount > 0 and amount)then
        TriggerServerEvent("vrp_stockmarket:sellStock", stock, amount)
    end
end

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'close'
    })    
end)

RegisterNUICallback('buy', function(data, cb)
    buyStock(data.stock, data.amount)
end)

RegisterNUICallback('sell', function(data, cb)
    sellStock(data.stock, data.amount)
end)

function enableMenu()
    TriggerServerEvent("vrp_stockmarket:updateStocks")

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'open'
    })
end

RegisterNetEvent("vrp_stockmarket:updateStocks")
AddEventHandler("vrp_stockmarket:updateStocks", function(stocks)
    SendNUIMessage({
        type = 'update',
        stocks = json.encode(stocks)
    })
end)

RegisterNetEvent("vrp_stockmarket:setClientToUpdate")
AddEventHandler("vrp_stockmarket:setClientToUpdate", function()
    TriggerServerEvent("vrp_stockmarket:updateStocks")
end)

function disableMenu()
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'close'
    })
end

RegisterNetEvent("vrp_stockmarket:openStocks")
AddEventHandler("vrp_stockmarket:openStocks", function()
    enableMenu()
end)

RegisterCommand('updatestocks', function(source, args)
    TriggerServerEvent("vrp_stockmarket:updateStocks")
end, false)