fx_version "cerulean"
game "gta5"

author "Donde213"
description "Realistic Standalone Recoil Script"
version "1.0.0"

shared_script "config.lua"
shared_script "@oxmysql/lib/MySQL.lua"

client_scripts {
    "client/main.lua"
}

server_scripts {
    "server/main.lua"
}

dependencies {
    "ox_lib"
}