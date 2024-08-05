local screenWidth, screenHeight = guiGetScreenSize()
local windowWidth, windowHeight = 400, 300
local windowX, windowY = (screenWidth - windowWidth) / 2, (screenHeight - windowHeight) / 2

local loginWindow = guiCreateWindow(windowX, windowY, windowWidth, windowHeight, "Авторизация / Регистрация", false)
local tabPanel = guiCreateTabPanel(10, 30, 380, 260, false, loginWindow)

-- Вкладка Авторизация
local loginTab = guiCreateTab("Авторизация", tabPanel)
local loginEmailLabel = guiCreateLabel(10, 10, 100, 30, "Email:", false, loginTab)
local loginEmailEdit = guiCreateEdit(120, 10, 250, 30, "", false, loginTab)
local loginPasswordLabel = guiCreateLabel(10, 50, 100, 30, "Пароль:", false, loginTab)
local loginPasswordEdit = guiCreateEdit(120, 50, 250, 30, "", false, loginTab)
guiEditSetMasked(loginPasswordEdit, true)
local loginButton = guiCreateButton(10, 90, 360, 30, "Войти", false, loginTab)

-- Вкладка Регистрация
local registerTab = guiCreateTab("Регистрация", tabPanel)
local registerEmailLabel = guiCreateLabel(10, 10, 100, 30, "Email:", false, registerTab)
local registerEmailEdit = guiCreateEdit(120, 10, 250, 30, "", false, registerTab)
local registerPasswordLabel = guiCreateLabel(10, 50, 100, 30, "Пароль:", false, registerTab)
local registerPasswordEdit = guiCreateEdit(120, 50, 250, 30, "", false, registerTab)
guiEditSetMasked(registerPasswordEdit, true)
local registerConfirmPasswordLabel = guiCreateLabel(10, 90, 100, 30, "Подтверждение пароля:", false, registerTab)
local registerConfirmPasswordEdit = guiCreateEdit(120, 90, 250, 30, "", false, registerTab)
guiEditSetMasked(registerConfirmPasswordEdit, true)
local registerButton = guiCreateButton(10, 130, 360, 30, "Зарегистрироваться", false, registerTab)

guiSetVisible(loginWindow, true)
showCursor(true)

addEventHandler("onClientGUIClick", loginButton, function()
    local email = guiGetText(loginEmailEdit)
    local password = guiGetText(loginPasswordEdit)
    if email ~= "" and password ~= "" then
        triggerServerEvent("loginPlayer", resourceRoot, email, password)
    else
        outputChatBox("Пожалуйста, введите email и пароль.")
    end
end, false)

addEventHandler("onClientGUIClick", registerButton, function()
    local email = guiGetText(registerEmailEdit)
    local password = guiGetText(registerPasswordEdit)
    local confirmPassword = guiGetText(registerConfirmPasswordEdit)
    local serial = getPlayerSerial()
    if email ~= "" and password ~= "" and confirmPassword ~= "" then
        if password == confirmPassword then
            triggerServerEvent("registerPlayer", resourceRoot, email, password, serial)
        else
            outputChatBox("Пароли не совпадают.")
        end
    else
        outputChatBox("Пожалуйста, заполните все поля.")
    end
end, false)

addEvent("onRegistrationSuccess", true)
addEventHandler("onRegistrationSuccess", root, function()
    outputChatBox("Регистрация успешна! Вы вошли в систему.")
    guiSetVisible(loginWindow, false)
    showCursor(false)
end)

addEvent("onRegistrationFailed", true)
addEventHandler("onRegistrationFailed", root, function(message)
    outputChatBox(message)
end)

addEvent("onLoginSuccess", true)
addEventHandler("onLoginSuccess", root, function()
    outputChatBox("Авторизация успешна!")
    guiSetVisible(loginWindow, false)
    showCursor(false)
end)

addEvent("onLoginFailed", true)
addEventHandler("onLoginFailed", root, function(message)
    outputChatBox(message)
end)

addCommandHandler("admin", function()
    if getElementData(localPlayer, "is_admin") then
        outputChatBox("У вас есть доступ к административному функционалу.")
    else
        outputChatBox("У вас нет доступа к административному функционалу.")
    end
end)
