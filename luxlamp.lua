-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, math
    = minetest, nodecore, math
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local function luxlamp (desc, id, power, light)
local delum	= power-1
local flux	= power+1
local charge	= power*100
local vlux	= power*60
local time	= 1000/power
------------------------------------------------------------------------
local particle = "nc_lux_base.png^[mask:nc_lux_dot_mask.png^[opacity:32"
------------------------------------------------------------------------
minetest.register_node(modname .. ":luxlamp_" .. id, {
	description = desc.. " Luxlamp",
	tiles = {
		"nc_optics_glass_frost.png^(nc_lux_base.png^[opacity:" .. vlux .. ")^(nc_lode_annealed.png^[mask:" .. modname .. "_mask_lamp_top.png)",
		"nc_lode_annealed.png",
		"nc_optics_glass_frost.png^(nc_lux_base.png^[opacity:" .. vlux .. ")^(nc_lode_annealed.png^[mask:" .. modname .. "_mask_lamp_side.png)",
	},
	drawtype = "nodebox",
	paramtype = "light",
	light_source = light,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.3125, -0.3125, 0.3125, 0.25, 0.3125},	-- Core
			{-0.5, -0.375, -0.5, 0.5, -0.25, 0.5},				-- Plate_Large
			{-0.375, -0.4375, -0.375, 0.375, -0.375, 0.375},		-- Plate_Med
			{-0.25, -0.5, -0.25, 0.25, -0.4375, 0.25},			-- Plate_Small
			{-0.375, 0.25, -0.375, 0.375, 0.3125, 0.375},		-- Cap_Large
			{-0.25, 0.3125, -0.25, 0.25, 0.375, 0.25},			-- Cap_Med
			{-0.125, 0.375, -0.125, 0.125, 0.4375, 0.125},		-- Cap_Small
			{-0.0625, 0.4375, -0.0625, 0.0625, 0.5, 0.0625},		-- Cap_Peak
		}
	},
	sunlight_propagates = true,
	groups = {
		stack_as_node = 1,
		snappy = 1,
		luxlamp = 1
	},
	stack_max = 1,
	sounds = nodecore.sounds("nc_optics_glassy"),
})
---------------------------------------
-----------Luxlamp Recycling-----------
nodecore.register_craft({
		label = "break luxlamp apart",
		action = "pummel",
		toolgroups = {choppy = 1, thumpy = 1, cracky = 1},
		nodes = {
			{
				match = {groups = {luxlamp = true}},
				replace = "nc_optics:glass_crude"
			}
		},
		items = {
			{name = "nc_lode:rod_tempered", count = 4, scatter = 4},
			{name = "nc_lux:flux_flowing", count = 10, scatter = 4}
		},
		itemscatter = 4
	})

---------------------------------------
----------Luxlamp Diminishing----------
nodecore.register_abm({
		label = "Luxlamp Delumination",
		interval = charge,
		chance = 1,
		nodenames = {modname .. ":luxlamp_" .. id},
		action = function(pos)
			if minetest.find_node_near(pos,
				1, {"nc_lux:flux_flowing"}) then
				return false
			end
			if power > 0 then
				return minetest.set_node(pos, {name = modname .. ":luxlamp_" .. delum})
			end
		end
	})
---------------------------------------
nodecore.register_aism({
		label = "Held Delumination",
		interval = charge,
		chance = 1,
		itemnames = {modname .. ":luxlamp_" .. id},
		action = function(stack, data)
			if power > 0 then
				stack:set_name(modname .. ":luxlamp_" .. delum)
				return stack
			end
		end
	})

----------------------------------------
end
luxlamp("Dull",		"0",	0,	1)
luxlamp("Dim",			"1",	1,	4)
luxlamp("Lambent",		"2",	2,	8)
luxlamp("Radiant",		"3",	3,	12)
luxlamp("Brilliant",	"4",	4,	16)
luxlamp("Fulgent",		"5", 5,	20)
