-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_ceil
    = math.ceil
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local particle = "nc_lux_base.png^[mask:nc_lux_dot_mask.png^[opacity:32"
------------------------------------------------------------------------
local function bulb(charge)
----------------------------------------
local vlux	= charge*60
----------------------------------------
	return minetest.register_node(modname .. ":luxlamp_" .. charge, {
		description = "Luxbulb",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},				-- AnchorPlate
				{-0.4375, -0.5, -0.4375, 0.4375, -0.3125, 0.4375},	-- BasePlate
				{-0.3125, -0.375, -0.3125, 0.3125, 0.25, 0.3125},		-- SmallPlate
				{-0.375, 0.25, -0.375, 0.375, 0.3125, 0.375},		-- Crown
				{-0.25, 0.25, -0.25, 0.25, 0.375, 0.25},			-- PeakLg
				{-0.125, 0.3125, -0.125, 0.125, 0.4375, 0.125},		-- PeakMd
				{-0.0625, 0.3125, -0.0625, 0.0625, 0.5, 0.0625},		-- PeakSm
			}
		},
		paramtype = "light",
		paramtype2 = "wallmounted",
		tiles = {
			"nc_optics_glass_frost.png^(nc_lux_base.png^[opacity:" .. vlux .. ")^(nc_lode_annealed.png^[mask:" .. modname .. "_mask_lamp_top.png)",
			"nc_lode_annealed.png",
			"nc_optics_glass_frost.png^(nc_lux_base.png^[opacity:" .. vlux .. ")^(nc_lode_annealed.png^[mask:" .. modname .. "_mask_lamp_side.png)",
		},
		backface_culling = true,
		use_texture_alpha = "clip",
		groups = {
			bulb = 1,
			luxlamp = charge,
			snappy = 1,
			lux_emit = charge,
			stack_as_node = 1,
		},
		stack_max = 1,
		light_source = charge * 8,
		sounds = nodecore.sounds("nc_optics_glassy"),
		drop = modname.. ":luxlamp_0",
	})
end
------------------------------------------------------------------------
for i = 0, 3 do bulb(i) end
------------------------------------------------------------------------

------------------------------------------------------------------------
nodecore.register_abm({
		label = "Illuminate Bulb",
		nodenames = {modname.. ":luxlamp_0"},
		neighbors = {"group:lux_cobble"},
		interval = 2,
		chance = 1,
		action = function(pos, node)
		node.name = modname.. ":luxlamp_1"
		minetest.set_node(pos, node)
		end
	})
nodecore.register_abm({
		label = "Superluminate Bulb",
		nodenames = {modname.. ":luxlamp_1"},
		neighbors = {"group:lux_hot"},
		interval = 2,
		chance = 1,
		action = function(pos, node)
		node.name = modname.. ":luxlamp_2"
		minetest.set_node(pos, node)
		end
	})	
nodecore.register_abm({
		label = "Hyperluminate Bulb",
		nodenames = {modname.. ":luxlamp_2"},
		neighbors = {"group:lux_cobble_max"},
		interval = 2,
		chance = 1,
		action = function(pos, node)
		node.name = modname.. ":luxlamp_3"
		minetest.set_node(pos, node)
		end
	})	

------------------------------------------------------------------------
nodecore.register_craft({
		label = "assemble luxbulb",
		action = "stackapply",
		indexkeys = {"nc_lode:form"},
		wield = {name = "nc_optics:prism"},
		consumewield = 1,
		nodes = {
			{y = 1, match = {name = "nc_optics:lens", param2 = 6}, replace = "air"},
			{match = "nc_lode:form", replace = "air"},
			{y = -1, match = "nc_lode:block_annealed", replace = {name = modname .. ":luxlamp_0", param2 = 1}},
		}
	})
