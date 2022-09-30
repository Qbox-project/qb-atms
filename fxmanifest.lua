fx_version 'cerulean'
game 'gta5'

description 'https://github.com/QBCore-Remastered'
version '1.0.1'

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_script 'client/main.lua'

ui_page 'nui/index.html'

files {
    'nui/images/logo1.png',
    'nui/images/logo.png',
    'nui/images/visa.png',
    'nui/images/mastercard.png',
    'nui/scripting/jquery-ui.css',
    'nui/scripting/external/jquery/jquery.js',
    'nui/scripting/jquery-ui.js',
    'nui/style.css',
    'nui/index.html',
    'nui/qb-atms.js'
}

lua54 'yes'
use_fxv2_oal 'yes'
