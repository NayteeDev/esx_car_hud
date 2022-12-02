resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'Car Hud UI'

ui_page 'html/ui.html'

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client.lua',
}

server_scripts {
    'html/lib.lua'
}

files {
	-- Main Images
	'html/ui.html',
	'html/style.css',
	'html/grid.css',
	'html/main.js',
	-- Vehicle Images
	'html/img/vehicle/fuel.png',
	'html/img/vehicle/locked.png',
	'html/img/vehicle/unlocked.png',
	'html/img/vehicle/off.png',
	'html/img/vehicle/on.png',
	-- Voice Images
	'html/img/speaker1.png',
	'html/img/speaker2.png',
	'html/img/speaker3.png'
}
