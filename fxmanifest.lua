fx_version "bodacious"
game "gta5"



client_scripts {
	"@vrp/lib/utils.lua",
	"client-side/*"
}



shared_scripts {
	'shared/*.lua'
}
server_scripts {
	"@vrp/lib/utils.lua",
	"server-side/*"
}

