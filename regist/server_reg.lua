local mysql = require("mysql")

local db = mysql.connect("host", "user", "password", "database")

addEvent("registerPlayer", true)
addEventHandler("registerPlayer", root, function(email, password, serial)
    local query = string.format("SELECT COUNT(*) AS count FROM accounts WHERE serial='%s'", serial)
    local result = db:query(query)
    if result and result[1].count < 3 then
        local query = string.format("INSERT INTO accounts (email, password, serial) VALUES ('%s', '%s', '%s')", email, password, serial)
        db:exec(query)
        triggerClientEvent(source, "onRegistrationSuccess", source)
    else
        triggerClientEvent(source, "onRegistrationFailed", source, "Вы можете зарегистрировать не более 3 аккаунтов на один серийный номер.")
    end
end)

addEvent("loginPlayer", true)
addEventHandler("loginPlayer", root, function(email, password)
    local query = string.format("SELECT * FROM accounts WHERE email='%s' AND password='%s'", email, password)
    local result = db:query(query)
    if result and #result > 0 then
        setElementData(source, "account_id", result[1].id)
        setElementData(source, "faction_id", result[1].faction_id)
        setElementData(source, "is_leader", result[1].is_leader)
        setElementData(source, "is_admin", result[1].is_admin)
        triggerClientEvent(source, "onLoginSuccess", source)
    else
        triggerClientEvent(source, "onLoginFailed", source, "Неверный email или пароль.")
    end
end)


addEventHandler("onPlayerQuit", root, function()
    local accountId = getElementData(source, "account_id")
    if accountId then
        local query = string.format("UPDATE accounts SET faction_id=NULL, is_leader=FALSE WHERE id=%d", accountId)
        db:exec(query)
    end
end)

addEventHandler("onResourceStop", resourceRoot, function()
    db:disconnect()
end)
