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
include("slowburners")
--------------------------------------
if minetest.get_modpath("wc_naturae") then
	include("aeterna_jar")
	include("lavalamp")
end
--------------------------------------
if minetest.get_modpath("wc_gloom") then
	include("shroomite")
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
