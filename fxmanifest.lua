fx_version 'cerulean'
game 'gta5'

author 'Siku Studio'
description 'A modern and flexible targeting system for the SIKU ecosystem — built for immersive player interactions, contextual actions, dynamic menus, and seamless world integration. Designed with performance, extensibility, and clean architecture in mind.'
version '0.0.1'

name 'siku_target'

lua54 'yes'

shared_scripts {
  '@siku_core/init.lua',
  'config/translation.lua',
  'config/target.lua',
  'config/reticle.lua',
  'config/menu.lua',
  'shared/locale.lua',
}

server_scripts {
  'server/init.lua',
}

client_scripts {
  'client/modules/registry.lua',
  'client/modules/ray.lua',
  'client/modules/resolve.lua',
  'client/modules/options.lua',
  'client/modules/menu.lua',
  'client/modules/nui.lua',
  'client/modules/input.lua',
  'client/modules/api.lua',
}

ui_page 'web/dist/index.html'

files {
  'translations/*.lua',
  'web/dist/**/*',
}

dependencies {
  'siku_core',
}
