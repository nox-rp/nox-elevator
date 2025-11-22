fx_version 'cerulean'
game 'gta5'

name 'nox-elevator'
description 'NOX Elevator System'
version '0.1.0'

ui_page 'ui/dist/index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

files {
    'ui/dist/index.html',
    'ui/dist/assets/*.js',
    'ui/dist/assets/*.css'
}
