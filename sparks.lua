-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_craft({
		label = "flint&steel",
		action = "pummel",
		wield = {name = "nc_stonework:chip"},
		indexkeys = {"group:chisel"},
		nodes = {
			{match = {groups = {chisel = true}}}
		},
		consumewield = 1,
		duration = -1,
		after = function(pos)
			nodecore.firestick_spark_ignite(pos,true)
			nodecore.sound_play("nc_api_toolbreak", {pos = pos, gain = 1})
		end
	})
