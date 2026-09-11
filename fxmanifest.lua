
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
version '1.7.0'
lua54 'yes'

author 'Ⓒ RE:CORD | @Nazu'
description 'Ⓒ RE:CORD Library'

shared_script {
    'init.lua',
    'shared/*.lua',
}

client_scripts {
    'client/ui/cl_alert.lua',
    'client/ui/cl_input.lua',
    'client/ui/cl_context.lua',
    'client/ui/cl_progress.lua',
    'client/ui/cl_textUI.lua',
    'client/ui/cl_text.lua',
    'client/ui/cl_helpText.lua',
    'client/ui/cl_subtitle.lua',
    'client/ui/cl_gauge.lua',
    'client/*.lua'
}

server_scripts {
    'server/*.lua',
}

ui_page 'web/build/index.html'

---[[
---     init.lua, lib/ and the classes run inside the resources that load them, so every
---     client has to be able to download them. They are not scripts of this resource:
---     sh_api / cl_api require them, and listing them here instead of in the script
---     lists stops every class from being loaded a second time in this resource.
---     server/class/ is left out on purpose, the server reads it straight from disk.
---]]
files {
    'init.lua',
    'lib/**/*.lua',
    'shared/class/**/*.lua',
    'client/class/**/*.lua',
    'client/ui/cl_nui.lua',
    'locales/web/*.json',
    'web/build/index.html',
    'web/build/assets/*',
}
