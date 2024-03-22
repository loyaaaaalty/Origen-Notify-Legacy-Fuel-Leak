local timer = 5000 -- tiempo de notisss
local loadingScreenFinished = false
local openIdcard = false
local statusNotify = false

local current_help_notification = {
	text = nil,
	timer = nil
}

local is_thread_running = false

local help_notification_thread = function ()
	is_thread_running = true

	while true do
		if current_help_notification.text ~= nil then
			if current_help_notification.timer + 0.1 <= timer.Get() then
				RemoveHelpNotification()
				break
			end
		end

		Citizen.Wait(100)
	end

	is_thread_running = false
end

ShowHelpNotification = function(text, is_new)
	current_help_notification.timer = GetInternalTimer() -- Intervalo de tiempo por help

	if current_help_notification.text ~= text then
		current_help_notification.text = text

		if not is_new and not is_thread_running then
			Citizen.CreateThread(help_notification_thread)
		end

		SendNUIMessage(
			{
				action = "SendHelpNotification",
				text = text
			}
		)
	end
end

RemoveHelpNotification = function ()
	current_help_notification.text = nil

	SendNUIMessage({
		action = "RemoveHelpNotification"
	})
end

RegisterNetEvent("origen_notify:ShowNotification")
AddEventHandler(
	"origen_notify:ShowNotification",
	function(text, title, business)
		if statusNotify == true then
			while true do
				Wait(100)

				if statusNotify == false then
					break
				end
			end
		end

		if title == nil then
			title = "Notificación"
		end

		SendNUIMessage(
			{
				action = "SendNotification",
				text = text,
				title = title,
				business = business
			}
		)
	end
)

RegisterNetEvent("notify:client:statusNotify")
AddEventHandler(
	"notify:client:statusNotify",
	function(bool)
		statusNotify = bool
	end
)

RegisterCommand(
	"loyalty",
	function()
		TriggerEvent("origen_notify:ShowNotification", "¡TEST!", "LoyaltyDevelopment manda zorras") -- Dependencia de Comando prueba notifyyy
	end,
	false
)

RegisterNetEvent("origen_notify:SendNotification")
AddEventHandler(
	"origen_notify:SendNotification",
	function(options)
		if statusNotify == true then
			while true do
				Wait(100)
				if statusNotify == false then
					break
				end
			end
		end
		SendNUIMessage(
			{
				action = "SendNotification",
				text = options.text,
				type = options.type,
				queue = options.queue,
				timeout = options.timeout,
				layout = options.layout
			}
		)
	end
)

RegisterNetEvent("origen_notify:SetQueueMax")
AddEventHandler(
	"origen_notify:SetQueueMax",
	function(queue, value)
		SendNUIMessage(
			{
				action = "SetQueueMax",
				queue = queue,
				value = value
			}
		)
	end
)