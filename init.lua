-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------
--------------------------------------
include("lantern")
--------------------------------------
include("luxlamp")
--------------------------------------
include("lavalamp")
--------------------------------------
include("rushlight")
--------------------------------------
include("eggburner_adobe")
include("eggburner_stone")
include("eggburner_sandstone")
include("eggburner_tarstone")
--------------------------------------
if minetest.get_modpath("wc_naturae") then
	include("aeterna_jar")
	include("lavalamp")
end
--------------------------------------
include("smoke")
include("sparks")
--include("")
--------------------------------------
include("conversion")
--------------------------------------
----------Let There Be Light----------
---A mod for NodeCore that adds new---
---light sources while maintaining----
---game balance-----By WintersKnight--
--------------------------------------
