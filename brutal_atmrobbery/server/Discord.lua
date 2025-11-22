RegisterServerEvent("brutal_atm_robbery:server:SendToDiscord")
AddEventHandler("brutal_atm_robbery:server:SendToDiscord", function()
    local time = os.date("%Y/%m/%d %X")

    sendToDiscord("**Identifier:** ".. GetIdentifierFunction(source) .."\n **Started robbing an ATM!**\n**Time:** ".. time .."")
end)

function sendToDiscord(message)
    local embed = {
            {
              	["color"] = 15105570,
                ["title"] =  "Brutal ATM Robbery",
                ["description"] = message,
            }
        }
    PerformHttpRequest(GetWebhook(), function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
