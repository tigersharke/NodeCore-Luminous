-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
	= minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------

local glass = "nc_optics_glass_edges.png^(nc_tree_tree_side.png^[mask:nc_optics_tank_mask.png)"

local fungus = "wc_naturae_mycelium.png"

local glow = "nc_lux_base.png^[colorize:springgreen:150"

local final =  "(" ..glow.. ")^(" ..fungus.. ")^(" ..glass.. ")"

minetest.register_node(modname .. ":jar", {
		description = "Aeterna Jar",
		drawtype = "normal",
		tiles = {final},
		selection_box = nodecore.fixedbox(),
		collision_box = nodecore.fixedbox(),
		groups = {
			snappy = 1,
			totable = 1,
			scaling_time = 50
		},
		paramtype = "light",
		light_source = 3,
		sounds = nodecore.sounds("nc_optics_glassy"),
	})
----------------------------------------
nodecore.register_craft({
		label = "assemble jar",
		action = "stackapply",
		indexkeys = {"nc_optics:shelf_float"},
		wield = {name = "wc_naturae:mushroom_lux", count = 100},
		consumewield = 100,
		nodes = {
			{
				match = {name = "nc_optics:shelf_float", empty = true},
				replace = modname .. ":jar"
			},
		}
	})
----------------------------------------

