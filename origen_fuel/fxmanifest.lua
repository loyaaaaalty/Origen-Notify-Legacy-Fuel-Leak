fx_version 'bodacious'
game 'gta5'

author 'Loyalty'
description 'Origen Legacy Fuel'
version '1.3'

ui_page "ui/index.html"

files {
	"ui/*",
	"ui/**/*",
}

-- What to run
shared_script '@qb-core/import.lua'

client_scripts {
	'config.lua',
	'functions/functions_client.lua',
	'source/fuel_client.lua'
}

server_scripts {
	'config.lua',
	'source/fuel_server.lua'
}

exports {
	'GetFuel',
	'SetFuel'
}
