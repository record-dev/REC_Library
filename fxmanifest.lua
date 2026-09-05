
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
version '1.5.0'
lua54 'yes'

author 'Ⓒ RE:CORD | @Nazu'
description 'Ⓒ RE:CORD Library'

shared_script {
    'init.lua',
    'shared/class/**/*.lua',
    'shared/*.lua',
}

client_scripts {
    'client/class/**/*.lua',
    'client/ui/cl_alert.lua',
    'client/ui/cl_input.lua',
    'client/ui/cl_context.lua',
    'client/ui/cl_progress.lua',
    'client/ui/cl_textUI.lua',
    'client/ui/cl_text.lua',
    'client/ui/cl_helpText.lua',
    'client/*.lua'
}

server_scripts {
    'server/class/**/*.lua',
    'server/*.lua',
}

ui_page 'web/build/index.html'

---[[
---     init.lua and lib/ run inside the resources that load them, so every client
---     has to be able to download them.
---]]
files {
    'init.lua',
    'lib/**/*.lua',
    'client/ui/cl_nui.lua',
    'locales/web/*.json',
    'web/build/index.html',
    'web/build/assets/*',
}
