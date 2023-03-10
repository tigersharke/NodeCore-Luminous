-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
------------------------------------------------------------------------
nodecore.register_hint("use a staff to craft a rushlight",
	{"nc_flora:rush_dry","assemble rushlight"}
)
------------------------------------------------------------------------
nodecore.register_hint("chisel etched concrete into an eggburner",
	{true,
	"chisel eggburne_stoner",
	"chisel eggburner_stone",
	"chisel eggburner_adobe",
	"chisel adobe eggburner",
	"chisel eggburner_sandstone",
	"chisel eggburner_coalstone",
	"chisel eggburner_cloudstone",
	"chisel eggburner_shellstone",
	"chisel eggburner_ceramic"
	}
)
------------------------------------------------------------------------
nodecore.register_hint("assemble a lantern from lode cube, form, and glass",
	"assemble coal lantern",
	{"nc_lode:form", "nc_optics:glass_clear"}
)
------------------------------------------------------------------------
nodecore.register_hint("assemble a luxbulb from lode cube, form and two shaped glass",
	"assemble luxbulb",
	{"nc_lode:form", "nc_optics:prism"}
)
------------------------------------------------------------------------
nodecore.register_hint("connect luxbulb to power node to illuminate it",
	{"place:wc_luminous:luxlamp_0",
	"look:wc_luminous:luxlamp_1"}
)
------------------------------------------------------------------------
nodecore.register_hint("illuminate a bulb to its maximum",
	{"place:wc_luminous:luxlamp_0",
	"look:wc_luminous:luxlamp_3"}
)
