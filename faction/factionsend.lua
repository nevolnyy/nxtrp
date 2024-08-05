local factionPanel = {}
local isFactionPanelVisible = false


function createFactionPanel()
    if isElement(factionPanel.window) then return end

    local screenW, screenH = guiGetScreenSize()
    local windowW, windowH = 600, 400
    local posX, posY = (screenW - windowW) / 2, (screenH - windowH) / 2

    factionPanel.window = guiCreateWindow(posX, posY, windowW, windowH, "Управление фракцией", false)
    guiWindowSetSizable(factionPanel.window, false)

    factionPanel.tabPanel = guiCreateTabPanel(0.02, 0.08, 0.96, 0.9, true, factionPanel.window)



    factionPanel.membersTab = guiCreateTab("Список участников", factionPanel.tabPanel)
    factionPanel.cityManagementTab = guiCreateTab("Управление городом", factionPanel.tabPanel)

    -- Список участников
    factionPanel.membersList = guiCreateGridList(0.02, 0.05, 0.95, 0.8, true, factionPanel.membersTab)
    guiGridListAddColumn(factionPanel.membersList, "ID", 0.2)
    guiGridListAddColumn(factionPanel.membersList, "Имя", 0.7)

    factionPanel.fireButton = guiCreateButton(0.02, 0.87, 0.3, 0.1, "Уволить", true, factionPanel.membersTab)
    factionPanel.inviteEdit = guiCreateEdit(0.35, 0.87, 0.3, 0.1, "", true, factionPanel.membersTab)
    factionPanel.inviteButton = guiCreateButton(0.68, 0.87, 0.3, 0.1, "Пригласить", true, factionPanel.membersTab)

    -- Управление городом
    factionPanel.cityNameLabel = guiCreateLabel(0.02, 0.05, 0.4, 0.1, "Название города:", true, factionPanel.cityManagementTab)
    factionPanel.cityNameEdit = guiCreateEdit(0.45, 0.05, 0.5, 0.1, "", true, factionPanel.cityManagementTab)
    factionPanel.changeCityNameButton = guiCreateButton(0.02, 0.17, 0.95, 0.1, "Изменить название города", true, factionPanel.cityManagementTab)

    factionPanel.taxList = guiCreateGridList(0.02, 0.3, 0.75, 0.6, true, factionPanel.cityManagementTab)
    guiGridListAddColumn(factionPanel.taxList, "Налог", 0.6)
    guiGridListAddColumn(factionPanel.taxList, "Процент", 0.2)
    guiGridListAddColumn(factionPanel.taxList, "Управление", 0.2)

    factionPanel.taxPointsLabel = guiCreateLabel(0.8, 0.3, 0.2, 0.1, "Очки: 0", true, factionPanel.cityManagementTab)
    factionPanel.applyButton = guiCreateButton(0.8, 0.4, 0.2, 0.1, "Применить", true, factionPanel.cityManagementTab)
    factionPanel.resetButton = guiCreateButton(0.8, 0.55, 0.2, 0.1, "Сбросить", true, factionPanel.cityManagementTab)

    guiSetVisible(factionPanel.window, false)

    addEventHandler("onClientGUIClick", factionPanel.fireButton, onFireButtonClick, false)
    addEventHandler("onClientGUIClick", factionPanel.inviteButton, onInviteButtonClick, false)
    addEventHandler("onClientGUIClick", factionPanel.changeCityNameButton, onChangeCityNameClick, false)
    addEventHandler("onClientGUIClick", factionPanel.applyButton, onApplyButtonClick, false)
    addEventHandler("onClientGUIClick", factionPanel.resetButton, onResetButtonClick, false)
end

-- Обработка нажатия на кнопку "Уволить"
function onFireButtonClick()
    local selectedRow, selectedCol = guiGridListGetSelectedItem(factionPanel.membersList)
    if selectedRow ~= -1 then
        local playerId = guiGridListGetItemData(factionPanel.membersList, selectedRow, 1)
        triggerServerEvent("fireFactionMember", resourceRoot, playerId)
    end
end

-- Обработка нажатия на кнопку "Пригласить"
function onInviteButtonClick()
    local playerId = tonumber(guiGetText(factionPanel.inviteEdit))
    if playerId then
        triggerServerEvent("inviteFactionMember", resourceRoot, playerId)
    end
end

-- Обработка нажатия на кнопку "Изменить название города"
function onChangeCityNameClick()
    local newCityName = guiGetText(factionPanel.cityNameEdit)
    triggerServerEvent("changeCityName", resourceRoot, newCityName)
end

-- Обработка нажатия на кнопку "Применить"
function onApplyButtonClick()
    for row = 0, guiGridListGetRowCount(factionPanel.taxList) - 1 do
        local taxType = guiGridListGetItemText(factionPanel.taxList, row, 1)
        local change = guiGridListGetItemData(factionPanel.taxList, row, 3)
        if change ~= 0 then
            triggerServerEvent("changeTax", resourceRoot, taxType, change)
        end
    end
end

-- Обработка нажатия на кнопку "Сбросить"
function onResetButtonClick()
    triggerServerEvent("resetTaxes", resourceRoot)
end

-- Обработка получения данных фракции
addEvent("receiveFactionData", true)
addEventHandler("receiveFactionData", resourceRoot, function(membersData, isLeader, taxes, taxPoints)
    guiGridListClear(factionPanel.membersList)
    for _, member in ipairs(membersData) do
        local row = guiGridListAddRow(factionPanel.membersList)
        guiGridListSetItemText(factionPanel.membersList, row, 1, tostring(member.id), false, false)
        guiGridListSetItemText(factionPanel.membersList, row, 2, member.name, false, false)
        guiGridListSetItemData(factionPanel.membersList, row, 1, member.id)
    end

    guiSetVisible(factionPanel.fireButton, isLeader)
    guiSetVisible(factionPanel.inviteEdit, isLeader)
    guiSetVisible(factionPanel.inviteButton, isLeader)

    guiGridListClear(factionPanel.taxList)
    for taxType, percent in pairs(taxes) do
        local row = guiGridListAddRow(factionPanel.taxList)
        guiGridListSetItemText(factionPanel.taxList, row, 1, taxType, false, false)
        guiGridListSetItemText(factionPanel.taxList, row, 2, tostring(percent) .. "%", false, false)
        guiGridListSetItemData(factionPanel.taxList, row, 3, 0)

        local decreaseButton = guiCreateButton(0, 0, 0.5, 1, "-", true, factionPanel.taxList)
        addEventHandler("onClientGUIClick", decreaseButton, function()
            local currentChange = guiGridListGetItemData(factionPanel.taxList, row, 3)
            if currentChange > -taxPoints then
                guiGridListSetItemData(factionPanel.taxList, row, 3, currentChange - 1)
                guiGridListSetItemText(factionPanel.taxList, row, 2, tostring(percent + currentChange - 1) .. "%", false, false)
            end
        end, false)

        local increaseButton = guiCreateButton(0.5, 0, 0.5, 1, "+", true, factionPanel.taxList)
        addEventHandler("onClientGUIClick", increaseButton, function()
            local currentChange = guiGridListGetItemData(factionPanel.taxList, row, 3)
            if currentChange < taxPoints then
                guiGridListSetItemData(factionPanel.taxList, row, 3, currentChange + 1)
                guiGridListSetItemText(factionPanel.taxList, row, 2, tostring(percent + currentChange + 1) .. "%", false, false)
            end
        end, false)
    end

    guiSetText(factionPanel.taxPointsLabel, "Очки: " .. tostring(taxPoints))
end)

-- Обработка получения обновленных данных налогов
addEvent("updateTaxData", true)
addEventHandler("updateTaxData", resourceRoot, function(taxes, taxPoints)
    for row = 0, guiGridListGetRowCount(factionPanel.taxList) - 1 do
        local taxType = guiGridListGetItemText(factionPanel.taxList, row, 1)
        guiGridListSetItemText(factionPanel.taxList, row, 2, tostring(taxes[taxType]) .. "%", false, false)
    end
    guiSetText(factionPanel.taxPointsLabel, "Очки: " .. tostring(taxPoints))
end)

-- Показ панели управления фракцией
function showFactionPanel()
    if not isElement(factionPanel.window) then
        createFactionPanel()
    end
    guiSetVisible(factionPanel.window, true)
    showCursor(true)
    triggerServerEvent("sendFactionDataToClient", resourceRoot)
end

-- Скрытие панели управления фракцией
function hideFactionPanel()
    if isElement(factionPanel.window) then
        guiSetVisible(factionPanel.window, false)
    end
    showCursor(false)
end

-- Обработка команды открытия панели управления фракцией
addCommandHandler("faction_panel", function()
    if isFactionPanelVisible then
        hideFactionPanel()
    else
        showFactionPanel()
   ```lua
    end
    isFactionPanelVisible = not isFactionPanelVisible
end)

-- Обработка приглашения во фракцию
addEvent("receiveFactionInvite", true)
addEventHandler("receiveFactionInvite", resourceRoot, function(invitingPlayer, factionId)
    local window = guiCreateWindow(0.4, 0.4, 0.2, 0.2, "Приглашение во фракцию", true)
    local label = guiCreateLabel(0.1, 0.2, 0.8, 0.2, "Вы были приглашены во фракцию.", true, window)
    guiLabelSetHorizontalAlign(label, "center", true)
    local acceptButton = guiCreateButton(0.1, 0.5, 0.35, 0.3, "Принять", true, window)
    local declineButton = guiCreateButton(0.55, 0.5, 0.35, 0.3, "Отклонить", true, window)

    addEventHandler("onClientGUIClick", acceptButton, function()
        triggerServerEvent("acceptFactionInvite", resourceRoot, invitingPlayer, factionId)
        destroyElement(window)
    end, false)

    addEventHandler("onClientGUIClick", declineButton, function()
        destroyElement(window)
    end, false)
end)
