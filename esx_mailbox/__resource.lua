resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

server_scripts {
    '@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	'locales/yourlanguage.lua',
    'locales/en.lua',
    'config.lua',
	'server.lua'
}

client_scripts {
    '@es_extended/locale.lua',
	'locales/yourlanguage.lua',
    'locales/en.lua',
    'config.lua',
	'client.lua'
}

ui_page('html/ui.html')

files({
    'html/ui.html',
    'html/script.js',
    'html/bg.png'
})

dependency 'es_extended'