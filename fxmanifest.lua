
--[[
--
--                       ________ __________      ________________ ________ ________                
--                       ___  __ \___  ____/_____ __  ____/__  __ \___  __ \___  __ \               
--        ________       __  /_/ /__  __/   ___(_)_  /     _  / / /__  /_/ /__  / / /       ________
--        _/_____/       _  _, _/ _  /___   ___   / /___   / /_/ / _  _, _/ _  /_/ /        _/_____/
--                       /_/ |_|  /_____/   _(_)  \____/   \____/  /_/ |_|  /_____/                 
--                                                                                                  
---]]

fx_version 'cerulean'
game 'gta5'
version 'v1.7.2'
lua54 'yes'

author 'Ⓒ RE:CORD | @Nazu'
description 'Ⓒ RE:CORD Library'

dependencies {
    'ox_lib',
}

shared_script {
    '@ox_lib/init.lua',
    'shared/class/**/*.lua',
    'shared/*.lua',
}

client_scripts {
    'client/class/**/*.lua',
    'client/*.lua'
}

server_scripts {
    'server/class/**/*.lua',
    'server/*.lua',
}
