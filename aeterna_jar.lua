-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, math
	= minetest, nodecore, math
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
-----Node---------------------------------------------------------------
local function jar(charge)
----------------------------------------
local emit	= charge/2
----------------------------------------
local glass = "nc_optics_glass_edges.png^(nc_tree_tree_side.png^[mask:nc_optics_tank_mask.png)"
local fungus = "wc_naturae_mycelium.png"
local glow = "nc_lux_base.png^[colorize:springgreen:150"
local final =  "(" ..glow.. ")^(" ..fungus.. ")^(" ..glass.. ")"
----------------------------------------
	return minetest.register_node(modname .. ":aeterna_" .. charge, {
		description = "Aeterna Jar",
		drawtype = "normal",
		paramtype = "light",
		tiles = {final},
		groups = {
			jar = 1,
			snappy = 1,
			lux_emit = emit,
			stack_as_node = 1,
		},
		stack_max = 1,
		light_source = charge,
		sounds = nodecore.sounds("nc_optics_glassy"),
	})
end
------------------------------------------------------------------------
for i = 0, 4 do jar(i) end
------------------------------------------------------------------------
-----Craft--------------------------------------------------------------
nodecore.register_craft({
		label = "assemble jar",
		action = "stackapply",
		indexkeys = {"nc_optics:shelf_float"},
		wield = {name = "wc_naturae:mushroom_lux", count = 100},
		consumewield = 100,
		nodes = {
			{
				match = {name = "nc_optics:shelf_float", empty = true},
				replace = modname .. ":aeterna_2"
			},
		}
	})
nodecore.register_craft({
		label = "shatter aeterna jar",
		action = "pummel",
		duration = 2,
		toolgroups = {choppy = 4, thumpy = 4, cracky = 4, crumbly = 4},
		nodes = {
			{
				match = {groups = {jar = true}},
				replace = "wc_naturae:compost"
			}
		},
		items = {
			{name = "wc_naturae:shard", count = 8, scatter = 4},
			{name = "nc_tree:stick", count = 4, scatter = 4}
		},
		itemscatter = 4
	})
-----Growth-------------------------------------------------------------
local function power(glow)
local powerup = glow+1
nodecore.register_abm({
		label = "Hydrate Aeterna",
		nodenames = {modname.. ":aeterna_" ..glow},
		neighbors = {"group:moist"},
		interval = 60,
		chance = 10 ,
		action = function(pos)
			minetest.set_node(pos, {name = modname.. ":aeterna_" ..powerup})
		end
	})
end
for i = 0, 3 do power(i) end
-----Overgrowth---------------------------------------------------------
nodecore.register_abm({
		label = "Overload Aeterna",
		nodenames = {modname.. ":aeterna_4"},
		neighbors = {"group:moist"},
		interval = 60,
		chance = 10 ,
		action = function(pos)
			nodecore.set_loud(pos, {name = "wc_naturae:compost"})
			nodecore.sound_play("nc_optics_glassy", {gain = 2.25, pos = pos})
			nodecore.item_eject(pos, "wc_naturae:shard", 8, 8)
			nodecore.item_eject(pos, "nc_lux:flux_flowing", 4, 4)
		end
	})
-----Ambiance-----------------------------------------------------------
nodecore.register_ambiance({
		label = "cracking jar ambiance",
		nodenames = {modname.. ":aeterna_4"},
		neighbors = {"group:moist"},
		interval = 5,
		chance = 5,
		sound_name = "nc_optics_glassy",
		sound_gain = 0.2
	})
