fx_version 'cerulean'
game "gta5"
author "QBCore Framework"
version '1.0.0'

lua54 'yes'

ui_page 'web/build/index.html'

client_script {
  "@PolyZone/client.lua",
  "@PolyZone/BoxZone.lua",
  "client/**/*"
}

files {
  'web/build/index.html',
  'web/build/**/*'
}
