--       Licensed under: AGPLv3        --
--  GNU AFFERO GENERAL PUBLIC LICENSE  --
--     Version 3, 19 November 2007     --

-- 해당 스크립트는 es_stockmarket(https://github.com/kanersps/es_stockmarket) 을 수정한 2차 저작물이며
-- AGPL v3 라이센스를 따르고있습니다.
-- 2차 수정 / 상업적 이용 시 인터넷상에 소스 코드를 공개해야 합니다.

local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_stockmarket")

local ready = false

stocks = {}

local config = {
    pricingTimer = GetConvarInt("vrp_stockmarket_pricingTimer", 30000),
    minRandom = GetConvarInt("vrp_stockmarket_minRandom", 2),
    maxRandom = GetConvarInt("vrp_stockmarket_maxRandom", 20),
    divider = GetConvarInt("vrp_stockmarket_divider", 10),
    lowestBasePercent = GetConvarInt("vrp_stockmarket_lowestBasePercent", 70),
    highestBacePercent = GetConvarInt("vrp_stockmarket_highestBasePercent", 200),
    addDefault = GetConvarInt("vrp_stockmarket_addDefault", 1),
    maxStocks = GetConvarInt("vrp_stockmarket_maxStocks", 99999999),
}

local userStockCache = {}

function shallowCopy(target, source)
    for k,v in pairs(source) do
        target[k] = v
    end
end

-- Randomize pricing based on baseWorth
Citizen.CreateThread(function()
    while true do
        math.randomseed(os.time())

        for i=1,#stocks do
            if(stocks[i].worth == 0)then
                stocks[i].worth = math.ceil(stocks[i].baseWorth * (math.random(config.minRandom, config.maxRandom) / config.divider))
            else
                stocks[i].worth = math.ceil(stocks[i].worth * (math.random(config.minRandom, config.maxRandom) / config.divider))

                if(stocks[i].worth < ((stocks[i].baseWorth / 100) * config.lowestBasePercent))then
                    stocks[i].worth = math.ceil((stocks[i].baseWorth / 100) * config.lowestBasePercent)
                end

                if(stocks[i].worth > ((stocks[i].baseWorth / 100) * config.highestBacePercent))then
                    stocks[i].worth = math.ceil((stocks[i].baseWorth / 100) * config.highestBacePercent)
                end
            end
        end

        TriggerClientEvent("vrp_stockmarket:setClientToUpdate", -1)
        Citizen.Wait(config.pricingTimer)
    end
end)

AddEventHandler("vrp_stockmarket:addStock", function(abr, name, baseWorth)
    table.insert(stocks, {abr = abr, name = name, worth = 0, baseWorth = baseWorth})
end)

if(config.addDefault)then
    TriggerEvent("vrp_stockmarket:addStock", "AUA", "AURA", 100000)
    TriggerEvent("vrp_stockmarket:addStock", "FIM", "FiveM", 100000)
    TriggerEvent("vrp_stockmarket:addStock", "APL", "Apple", 100000)
end

RegisterServerEvent("vrp_stockmarket:updateStocks")
AddEventHandler("vrp_stockmarket:updateStocks", function()
    local _source = source
	local user = vRP.getUserId({_source})

    if(user)then
        userStockCache[user] = {}

        shallowCopy(userStockCache[user], stocks)

        for i=1,#userStockCache[user] do
        userStockCache[user][i].owned = 0
        end

        MySQL.Async.fetchAll('SELECT * FROM vrp_stockmarket WHERE owner=@owner', {['@owner'] = user}, function(ostocks)
            for j=1,#ostocks do
                for i=1,#userStockCache[user] do
                    if(userStockCache[user] and ostocks[j].stock)then
                        if(userStockCache[user][i].abr == ostocks[j].stock)then
                            userStockCache[user][i].owned = ostocks[j].amount
                        end
                    end
                end
            end

            TriggerClientEvent("vrp_stockmarket:updateStocks", _source, userStockCache[user])
        end)
    end
end)

RegisterServerEvent('vrp_stockmarket:buyStock')
AddEventHandler('vrp_stockmarket:buyStock', function(stock, amount, test)
    local _source = source
    local user = vRP.getUserId({_source})
    
    if(not user)then
        return
    end

    if(not ready)then
        return
    end

    local _stock = {}

    for i=1,#stocks do
        if stocks[i].abr == stock then
            _stock = stocks[i]
            break
        end
    end

    
    if(_stock.abr)then
        if(vRP.getBankMoney({user}) >= (_stock.worth * amount))then
            vRP.setBankMoney({user,vRP.getBankMoney({user}) - (_stock.worth * amount)})
            MySQL.Async.fetchAll('SELECT * FROM vrp_stockmarket WHERE owner=@owner', {['@owner'] = user}, function(ostocks)
                local done = false
                local newOwned = 0

                userStockCache[user] = {}

                for k,v in pairs(stocks)do
                    userStockCache[user][k] = v
                    userStockCache[user][k].owned = 0
                end

                for j=1,#ostocks do
                    for i=1,#userStockCache[user] do
                        if(userStockCache[user][i] and ostocks[j])then
                            if(userStockCache[user][i].abr == ostocks[j].stock)then
                                userStockCache[user][i].owned = ostocks[j].amount
                            end
                            
                            if(userStockCache[user][i].abr == ostocks[j].stock and ostocks[j].stock == stock)then
                                if(config.maxStocks < (ostocks[j].amount + amount))then
                                    newOwned = ostocks[j].amount
                                    done = true
                                    user.addMoney(_stock.worth * amount)
                                else
                                    userStockCache[user][i].owned = ostocks[j].amount + amount
                                    newOwned = userStockCache[user][i].owned
                                    done = true
                                end
                            end
                        end
                    end
                end
        
                if(done)then
                    MySQL.Async.execute("UPDATE vrp_stockmarket SET amount=@amount WHERE owner=@owner AND stock=@stock", {['@stock'] = _stock.abr, ['@owner'] = user, ['@amount'] = newOwned}, function()
                        TriggerClientEvent("vrp_stockmarket:setClientToUpdate", _source)
                    end)
                else
                    MySQL.Async.execute("INSERT INTO vrp_stockmarket(stock, owner, amount) VALUES (@stock, @owner, @amount)", {['@stock'] = _stock.abr, ['@owner'] = user, ['@amount'] = amount}, function()
                        TriggerClientEvent("vrp_stockmarket:setClientToUpdate", _source)
                    end)
                end
            end)
        end
    else
        print("[vrp_stockmarket] Unknowk stock " .. tostring(stock))
    end
end)

RegisterServerEvent('vrp_stockmarket:sellStock')
AddEventHandler('vrp_stockmarket:sellStock', function(stock, amount)
    local _source = source
    local user = vRP.getUserId({_source})
    
    if(not user)then
        return
    end

    if(not ready)then
        return
    end

    local _stock = {}

    for i=1,#stocks do
        if stocks[i].abr == stock then
            _stock = stocks[i]
            break
        end
    end

    
    if(_stock.abr)then
        MySQL.Async.fetchAll('SELECT * FROM vrp_stockmarket WHERE owner=@owner', {['@owner'] = user}, function(ostocks)
            local done = false
            local sold = 0
            local newOwned = 0

            userStockCache[user] = {}

            shallowCopy(userStockCache[user], stocks)
        
            for i=1,#userStockCache[user] do
               userStockCache[user][i].owned = 0
            end

            for j=1,#ostocks do
                for i=1,#userStockCache[user] do
                    if(userStockCache[user][i] and ostocks[j].stock)then
                        if(userStockCache[user][i].abr == ostocks[j].stock and stock == ostocks[j].stock) then
                            if(ostocks[j].amount >= amount)then
                                userStockCache[user][i].owned = ostocks[j].amount - amount
                                newOwned = userStockCache[user][i].owned
                                sold = amount
                                done = true
                            end

                            break
                        end
                    end
                end
            end
        
            if(done)then
                MySQL.Async.execute("UPDATE vrp_stockmarket SET amount=@amount WHERE owner=@owner AND stock=@stock", {['@stock'] = _stock.abr, ['@owner'] = user, ['@amount'] = newOwned}, function()
					vRP.setBankMoney({user,vRP.getBankMoney({user}) + (sold * _stock.worth)})
                    TriggerClientEvent("vrp_stockmarket:setClientToUpdate", _source)
                end)
            end
        end)
    else
        print("[vrp_stockmarket] Unknowk stock " .. tostring(stock))
    end
end)

MySQL.ready(function ()
    ready = true
    print("[vrp_stockmarket] Ready to accept queries!")
end)

local ch_openstocks = {function(player,choice)
	TriggerClientEvent("vrp_stockmarket:openStocks", player)
end, "Open Stock Menu."}

vRP.registerMenuBuilder({"main", function(add, data)
	local user_id = vRP.getUserId({data.player})
	
	if user_id ~= nil then
		local choices = {}
		choices["📊 [STOCK]"] = ch_openstocks
		
		add(choices)
	end
end})