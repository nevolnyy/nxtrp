-- Определение таблицы фракций
local factions = {
    ["city_mayor"] = {
        name = "Мэрия города",
        members = {},
        leader = nil
    }
}

local factions = {}
local players = {}

-- Создание таблицы для хранения информации о фракциях
function createFaction(name, leader)
    local faction = {
        name = name,
        leader = leader,
        members = {},
        taxes = {
            ["Налог на прибыль с бизнесов"] = 5,
            ["Налог на доход рабочих"] = 5,
            ["Налог на доход фракций"] = 5,
            ["Налог на продажу ТС"] = 5,
            ["Налог на покупку ТС"] = 5
        },
        taxPoints = 0
    }
    table.insert(factions, faction)
    return faction
end

-- Получение игрока по ID
function getPlayerFromId(id)
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "playerId") == id then
            return player
        end
    end
    return nil
end

-- Получение фракции по ID
function getFactionById(factionId)
    return factions[factionId]
end

-- Команда для назначения игрока в фракцию
addCommandHandler("set_player_faction",
    function(player, command, targetPlayerId, factionId)
        if not hasObjectPermissionTo(player, "command.set_player_faction", false) then
            outputChatBox("У вас нет доступа к этой команде.", player)
            return
        end

        local targetPlayer = getPlayerFromId(tonumber(targetPlayerId))
        if targetPlayer and factions[tonumber(factionId)] then
            setElementData(targetPlayer, "faction", tonumber(factionId))
            table.insert(factions[tonumber(factionId)].members, targetPlayer)
            outputChatBox("Игрок добавлен во фракцию.", player)
        else
            outputChatBox("Неверный ID игрока или фракции.", player)
        end
    end
)

-- Команда для назначения игрока лидером фракции
addCommandHandler("set_player_faction_leader",
    function(player, command, targetPlayerId, factionId)
        if not hasObjectPermissionTo(player, "command.set_player_faction_leader", false) then
            outputChatBox("У вас нет доступа к этой команде.", player)
            return
        end

        local targetPlayer = getPlayerFromId(tonumber(targetPlayerId))
        if targetPlayer and factions[tonumber(factionId)] then
            factions[tonumber(factionId)].leader = targetPlayer
            setElementData(targetPlayer, "isFactionLeader", true)
            outputChatBox("Игрок назначен лидером фракции.", player)
        else
            outputChatBox("Неверный ID игрока или фракции.", player)
        end
    end
)

-- Событие для увольнения игрока из фракции
addEvent("fireFactionMember", true)
addEventHandler("fireFactionMember", root, function(playerId)
    local player = client
    local factionId = getElementData(player, "faction")
    if factions[factionId] and factions[factionId].leader == player then
        local targetPlayer = getPlayerFromId(playerId)
        if targetPlayer then
            setElementData(targetPlayer, "faction", nil)
            setElementData(targetPlayer, "isFactionLeader", false)
            for i, member in ipairs(factions[factionId].members) do
                if member == targetPlayer then
                    table.remove(factions[factionId].members, i)
                    break
                }
            end
            outputChatBox("Игрок уволен из фракции.", player)
        end
    end
end)

-- Событие для приглашения игрока в фракцию
addEvent("inviteFactionMember", true)
addEventHandler("inviteFactionMember", root, function(targetPlayerId)
    local player = client
    local factionId = getElementData(player, "faction")
    if factions[factionId] and factions[factionId].leader == player then
        local targetPlayer = getPlayerFromId(targetPlayerId)
        if targetPlayer then
            triggerClientEvent(targetPlayer, "receiveFactionInvite", targetPlayer, player, factionId)
        end
    end
end)

-- Событие для принятия приглашения во фракцию
addEvent("acceptFactionInvite", true)
addEventHandler("acceptFactionInvite", root, function(invitingPlayer, factionId)
    local player = client
    if factions[factionId] then
        setElementData(player, "faction", factionId)
        table.insert(factions[factionId].members, player)
        outputChatBox("Вы вступили во фракцию.", player)
        outputChatBox(getPlayerName(player) .. " вступил во фракцию.", invitingPlayer)
    end
end)

-- Обработка выхода игрока из игры
addEventHandler("onPlayerQuit", root, function()
    local player = source
    local factionId = getElementData(player, "faction")
    if factionId then
        if factions[factionId].leader == player then
            factions[factionId].leader = nil
        end
        for i, member in ipairs(factions[factionId].members) do
            if member == player then
                table.remove(factions[factionId].members, i)
                break
            end
        end
    end
end)

-- Функция для отправки данных о фракции клиентам
function sendFactionDataToClient(player)
    local factionId = getElementData(player, "faction")
    if factionId and factions[factionId] then
        local membersData = {}
        for _, member in ipairs(factions[factionId].members) do
            table.insert(membersData, { id = getElementData(member, "playerId"), name = getPlayerName(member) })
        end
        triggerClientEvent(player, "receiveFactionData", resourceRoot, membersData, factions[factionId].leader == player, factions[factionId].taxes, factions[factionId].taxPoints)
    end
end

-- Событие для изменения налогов
addEvent("changeTax", true)
addEventHandler("changeTax", root, function(taxType, change)
    local player = client
    local factionId = getElementData(player, "faction")
    if factions[factionId] and factions[factionId].leader == player and factions[factionId].taxPoints >= math.abs(change) then
        factions[factionId].taxes[taxType] = factions[factionId].taxes[taxType] + change
        factions[factionId].taxPoints = factions[factionId].taxPoints - math.abs(change)
        triggerClientEvent(root, "updateTaxData", resourceRoot, factions[factionId].taxes, factions[factionId].taxPoints)
    end
end)

-- Событие для сброса налогов
addEvent("resetTaxes", true)
addEventHandler("resetTaxes", root, function()
    local player = client
    local factionId = getElementData(player, "faction")
    if factions[factionId] and factions[factionId].leader == player then
        for taxType, _ in pairs(factions[factionId].taxes) do
            factions[factionId].taxes[taxType] = 5
        end
        factions[factionId].taxPoints = 0
        triggerClientEvent(root, "updateTaxData", resourceRoot, factions[factionId].taxes, factions[factionId].taxPoints)
    end
end)

-- Создание фракции "Мэрия города"
addCommandHandler("create_mayor_faction", function(player, command, name)
    if not hasObjectPermissionTo(player, "command.create_mayor_faction", false) then
        outputChatBox("У вас нет доступа к этой команде.", player)
        return
    end

    if name then
        local faction = createFaction(name, nil)
        outputChatBox("Фракция 'Мэрия города' создана.", player)
    else
        outputChatBox("Укажите название фракции.", player)
    end
end)

-- Обработка запроса данных фракции
addEvent("sendFactionDataToClient", true)
addEventHandler("sendFactionDataToClient", root, function()
    sendFactionDataToClient(client)
end)