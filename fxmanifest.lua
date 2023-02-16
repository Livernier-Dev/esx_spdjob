

-- ======================================== FiveM Script: ========================================
--                                 esx_spdjob
-- ======================================== Developed By: ========================================
--                                 Livernier Dev
-- ======================================== License: =============================================
--                                 You are not allowed to sell this script or edit
-- ===============================================================================================

fx_version 'adamant'

game "gta5"

description 'ESX spd Job'

version '1.3.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/de.lua',
	'locales/en.lua',
	'locales/pl.lua',
	'locales/fr.lua',
	'locales/fi.lua',
	'locales/es.lua',
	'locales/sv.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/de.lua',
	'locales/en.lua',
	'locales/pl.lua',
	'locales/fr.lua',
	'locales/fi.lua',
	'locales/es.lua',
	'locales/sv.lua',
	'config.lua',
	'client/main.lua'
}

dependencies {
	'es_extended',
	---'esx_billing'
}