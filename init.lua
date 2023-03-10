-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------
--------------------------------------
include("hint")
--------------------------------------
include("lantern")
--------------------------------------
include("luxlamp")
--------------------------------------
include("rushlight")
--------------------------------------
if minetest.get_modpath("wc_noditions") then
	include("saplight")
end
--------------------------------------

include("eggburner_adobe")
include("eggburner_stone")
include("eggburner_sandstone")
include("eggburner_tarstone")
include("eggburner_cloudstone")
--------------------------------------
if minetest.get_modpath("wc_pottery") then
	include("eggburner_ceramic")
end
--------------------------------------
if minetest.get_modpath("wc_naturae") then
	include("eggburner_shellstone")
	include("aeterna_jar")
	include("lavalamp")
end
--------------------------------------
include("smoke")
include("sparks")
--include("pumice")
--include("")
--------------------------------------
include("conversion")
--------------------------------------
----------Let There Be Light----------
---A mod for NodeCore that adds new---
---light sources while maintaining----
---game balance-----By WintersKnight--
--------------------------------------
