QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback("origen_fuel:server:hasMoney", function(source, cb, price)
    local Player = QBCore.Functions.GetPlayer(source)

    local bankCount = Player.Functions.GetMoney('bank') - price
    local moneyCount = Player.Functions.GetMoney('cash') - price

    if bankCount > 0 then
        Player.Functions.RemoveMoney('bank', price)
        cb(true)
    elseif moneyCount > 0 then
        Player.Functions.RemoveMoney('cash', price)
        cb(true)
    else
        cb(false)
    end
end)

-- LoyaltyDevelopment.es
