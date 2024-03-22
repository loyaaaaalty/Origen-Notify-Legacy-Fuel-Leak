fx_version 'adamant'

game 'gta5'


author 'LoyaltyDevelopment.es'
description 'Origen Notification System'

version '1.0.1'

ui_page 'html/ui.html'

files {

    'html/logo.png',
    'html/noty.css',
    'html/noty.css.map',
    'html/noty.min.js',
    'html/noty.min.js.map',
    'html/script.js',
    'html/style.css',
    'html/newstyle.css',
    'html/ui.html',
    'html/bankgothic.ttf',
    'html/helptext.ogg',
    'html/pop.ogg',
    'html/bell.gif',
    'html/TweenMax.min.js'
}

client_scripts {
    '@sent-utils/timer.lua',
    'client/origen_3d.lua',
    'client/main.lua',
}

export {
	'Notify',
    "ShowHelpNotification",
    "RemoveHelpNotification"
}