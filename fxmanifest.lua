--       Licensed under: AGPLv3        --
--  GNU AFFERO GENERAL PUBLIC LICENSE  --
--     Version 3, 19 November 2007     --

-- 해당 스크립트는 es_stockmarket(https://github.com/kanersps/es_stockmarket) 을 수정한 2차 저작물이며
-- AGPL v3 라이센스를 따르고있습니다.
-- 2차 수정 / 상업적 이용 시 인터넷상에 소스 코드를 공개해야 합니다.

fx_version 'bodacious'
games { 'gta5' }

description 'EssentialMode by Kanersps. vRP convert by URA'

ui_page 'client/html/ui.html'

dependencies {
    'mysql-async',
    'vrp'
}

client_scripts {
	'client/client.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'@mysql-async/lib/MySQL.lua',
	'server/server.lua'
}

-- NUI Files
files {
	'client/html/ui.html',
	'client/html/ui.js'
}