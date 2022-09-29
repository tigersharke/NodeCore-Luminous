-- LUALOCALS < ---------------------------------------------------------

local minetest, nodecore

    = minetest, nodecore

-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()


nodecore.register_hint("use a staff to craft a rushlight",

	{"nc_flora:rush_dry","assemble rushlight"}

)

nodecore.register_hint("chisel etched concrete into an eggburner",
	
	{true,

	"chisel eggburne_stoner",

	"chisel eggburner_stone",

	"chisel eggburner_adobe",

	"chisel adobe eggburner",

	"chisel eggburner_sandstone",

	"chisel eggburner_coalstone"

	}

)

nodecore.register_hint("assemble a lantern from a lode cube, form, and glass",

	"assemble lantern"

)

nodecore.register_hint("assemble a luxlamp from lode parts and two shaped chromatic glass",

	"assemble luxlamp"

)
