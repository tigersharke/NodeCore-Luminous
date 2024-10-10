-- LUALOCALS < ---------------------------------------------------------
local  minetest, nodecore, ItemStack, math
	= minetest, nodecore, ItemStack, math
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local lava = "nc_terrain_lava.png^[verticalframe:32:8"
local pumice = "nc_igneous_pumice.png"
local skin = "nc_lode_annealed.png^[colorize:darkorange:50"
local hot = "nc_lode_hot.png^[colorize:darkorange:50"
local firemask = "(" ..lava.. ")^[mask:wc_naturae_mask_pumpkin.png"
local icemask = "(" ..pumice.. ")^[mask:wc_naturae_mask_pumpkin.png"
local hotface = "(" ..hot.. ")^(" ..firemask.. ")"
local coolface = "(" ..skin.. ")^(" ..icemask.. ")"
------------------------------------------------------------------------
----------Cooled----------
minetest.register_node(modname.. ":lavalamp_cool", {
	description = "Pumlamp",
		tiles = {
			skin,
			skin,
			coolface
		},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.4375, -0.5, 0.5, 0.1875, 0.5}, -- Middle
			{-0.375, -0.5, -0.375, 0.375, 0.25, 0.375}, -- Core
			{-0.25, 0.25, -0.25, 0.25, 0.3125, 0.25}, -- Top
			{-0.0625, 0.25, -0.0625, 0.0625, 0.5, 0.0625}, -- Stem
			{-0.125, 0.3125, -0.125, 0.125, 0.375, 0.125}, -- StemBase
		}
	},
	sunlight_propagates = true,
	groups = {
		stack_as_node = 1,
		snappy = 1,
		pumlamp = 1,
		falling_node = 1,
	},
	stack_max = 1,
	sounds = nodecore.sounds("nc_optics_glassy"),
})
----------Hot----------
minetest.register_node(modname.. ":lavalamp_hot", {
	description = "Pumlamp",
		tiles = {
			hot,
			hot,
			hotface
		},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.4375, -0.5, 0.5, 0.1875, 0.5}, -- Middle
			{-0.375, -0.5, -0.375, 0.375, 0.25, 0.375}, -- Core
			{-0.25, 0.25, -0.25, 0.25, 0.3125, 0.25}, -- Top
			{-0.0625, 0.25, -0.0625, 0.0625, 0.5, 0.0625}, -- Stem
			{-0.125, 0.3125, -0.125, 0.125, 0.375, 0.125}, -- StemBase
		}
	},
	sunlight_propagates = true,
	light_source = 8,
	groups = {
		stack_as_node = 1,
		snappy = 1,
		igniter = 1,
		pumlamp = 1,
		falling_node = 1,
		},
	stack_max = 1,
	sounds = nodecore.sounds("nc_tree_woody"),
})
----------Craft----------
local rfcall = function(pos, data)
	local ref = minetest.get_player_by_name(data.pname)
	local wield = ref:get_wielded_item()
	wield:take_item(1)
	ref:set_wielded_item(wield)
end

nodecore.register_craft({
		label = "create pumlamp",
		action = "pummel",
		wield = {groups = {amalgam = true}},
		after = rfcall,
		nodes = {
				{match = "wc_naturae:pumpkin_carved", replace = modname .. ":lavalamp_hot"}
			}
	})
----------Reheat----------
nodecore.register_abm({
		label = "Heat Pumlamp",
		nodenames = {modname.. ":lavalamp_cool"},
		neighbors = {"group:lava"},
		interval = 10,
		chance = 2,
		action = function(pos)
			nodecore.set_loud(pos, {name = modname.. ":lavalamp_hot"})
		end
	})
----------Quench----------
nodecore.register_abm({
		label = "Pumlamp Quenching",
		interval = 0.1,
		chance = 1,
		nodenames = {modname .. ":lavalamp_hot"},
		action = function(pos)
			if nodecore.quenched(pos) then
				nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
				return minetest.set_node(pos, {name = modname .. ":lavalamp_cool"})
			end
		end
	})
nodecore.register_aism({
				label = "Pumlamp Quenching",
				interval = 0.1,
				chance = 1,
				itemnames = {modname .. ":lavalamp_hot"},
				action = function(stack, data)
						local pos = data.pos
						local player = data.player
						ext = true
						if player then
							if data.list ~= "main" or player:get_wield_index()
							~= data.slot then ext = false end
							pos = vector.add(pos, vector.multiply(player:get_look_dir(), 0.5))
						end

						if ext and nodecore.quenched(pos, data.node and 1 or 0.3) then
							nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
							stack:set_name(modname .. ":lavalamp_cool")
							return stack
						end
				end
})
----------Recycling----------
nodecore.register_craft({
		label = "break lavalamp apart",
		action = "pummel",
		duration = 2,
		toolgroups = {choppy = 3, thumpy = 3, cracky = 3},
		nodes = {
			{
				match = {groups = {pumlamp = true}},
				replace = "nc_igneous:pumice"
			}
		},
		items = {
			{name = "nc_fire:lump_coal", count = math_random(1, 4), scatter = math_random(1, 4)},
			{name = "nc_fire:lump_ash", count = math_random(1, 4), scatter = math_random(1, 4)}
		},
		itemscatter = math_random(1, 4)
	})
----------Ambiance----------
nodecore.register_ambiance({
		label = "lavalamp ambiance",
		nodenames = {modname.. ":lavalamp_hot"},
		neighbors = {"air"},
		interval = 10,
		chance = 25,
		sound_name = "nc_terrain_bubbly",
		sound_gain = 0.2
	})
----------Spill----------
nodecore.register_aism({
	label = "Accidental Spill",
	interval = 30,
	chance = 5,
	itemnames = {modname.. ":lavalamp_hot"},
	action = function(stack, data)
		nodecore.item_eject(data.pos,"nc_terrain:lava_flowing",math_random(1, 3),math_random(1, 3))
	end
})
nodecore.register_aism({
	label = "Accidental Catastrophe",
	interval = 120,
	chance = 20,
	itemnames = {modname.. ":lavalamp_hot"},
	action = function(stack, data)
		nodecore.item_eject(data.pos,"nc_terrain:lava_flowing", math_random(1, 6), math_random(4, 8))
		nodecore.item_eject(data.pos,"nc_igneous:pumice", math_random(1, 6), math_random(1, 4))
		return "nc_fire:ember"..math_random(1, 8)
	end
})

