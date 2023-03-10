-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, setmetatable, vector
	= ItemStack, math, minetest, nodecore, pairs, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
-------------------------------------------------------------------------------
local base = "nc_concrete_sandstone.png"
local boxy = "nc_concrete_pattern_boxy.png^[opacity:50"
local horzy = "nc_concrete_pattern_horzy.png^[opacity:50"
local pit = "(nc_fire_coal_4.png^[mask:" ..modname.. "_mask_pit.png)^[opacity:75"
local egg = "[combine:24x24:4,4=nc_tree_eggcorn.png\\^[resize\\:8x8"
local ember = "(nc_fire_coal_4.png^(nc_fire_ember_3.png^[opacity:150))^[mask:" ..modname.. "_mask_pit.png"
local ash = "nc_fire_ash.png^[mask:" ..modname.. "_mask_pit.png"
-------------------------------------------------------------------------------
local rfcall = function(pos, data)
	local ref = minetest.get_player_by_name(data.pname)
	local wield = ref:get_wielded_item()
	wield:take_item(1)
	ref:set_wielded_item(wield)
end
-------------------------------------------------------------------------------
----------------INCENSE-----------------
local function burner(id, light, tile)
	minetest.register_node(modname .. ":incense_sandstone_" ..id, {
		description = "Sandstone Egg Burner",
		tiles = tile,
		drawtype = "nodebox",
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.25, -0.5, -0.25, 0.25, -0.4375, 0.25},			-- Bowl_1
				{-0.375, -0.4375, -0.375, 0.375, -0.375, 0.375},		-- Bowl_2
				{-0.4375, -0.375, -0.4375, 0.4375, -0.25, 0.4375},	-- Bowl_3
				{-0.5, -0.25, -0.5, 0.5, 0, 0.5},					-- Bowl_4
				{-0.4375, 0, -0.4375, 0.4375, 0.0625, 0.4375},		-- Bowl_5
				{-0.375, 0.0625, -0.375, 0.375, 0.125, 0.375},		-- Bowl_6
			}
		},
		sunlight_propagates = true,
		light_source = light,
		groups = {
			stack_as_node = 1,
			snappy = 1,
			incense = 1,
			incense_sandstone = 1
		},
		stack_max = 1,
		sounds = nodecore.sounds("nc_terrain_stony")
	})
end
-------------------------------------------------------------------------------
burner("empty",	0,
	{
		"(" ..base.. ")^(" ..boxy.. ")^(" ..pit.. ")",
		base,
		"(" ..base.. ")^(" ..horzy.. ")"
	}
)
burner("unlit",	0,
	{
		"(" ..base.. ")^(" ..boxy.. ")^(" ..pit.. ")^(" ..egg.. ")",
		base,
		"(" ..base.. ")^(" ..horzy.. ")"
	}
)
burner("lit",		4,
	{
		"(" ..base.. ")^(" ..boxy.. ")^(" ..pit.. ")^(" ..ember.. ")",
		base,
		"(" ..base.. ")^(" ..horzy.. ")"
	}
)
burner("ashy",		0,
	{
		"(" ..base.. ")^(" ..boxy.. ")^(" ..pit.. ")^(" ..ash.. ")",
		base,
		"(" ..base.. ")^(" ..horzy.. ")"
	}
)
----------------IGNITION-----------------
minetest.register_abm({
		label = "ignite _sandstone eggburner",
		interval = 10,
		chance = 2,
		nodenames = {modname.. ":incense_sandstone_unlit"},
		neighbors = {"group:igniter", "group:torch_lit", "group:candle_lit"},
--		action_delay = true,
		action = function(pos)
			if not nodecore.quenched(pos) then
			minetest.set_node(pos, {name = modname.. ":incense_sandstone_lit"})
			end
		end
	})
----------------QUENCHING-----------------
nodecore.register_abm({
		label = "Incense _sandstone Quenching",
		interval = 0.1,
		chance = 1,
		nodenames = {modname .. ":incense_sandstone_lit"},
		action = function(pos)
			if nodecore.quenched(pos) then
				nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
				return minetest.set_node(pos, {name = modname.. ":incense_sandstone_ashy"})
			end
		end
	})
nodecore.register_aism({
				label = "Held Incense_sandstone Quenching",
				interval = 0.1,
				chance = 1,
				itemnames = {modname .. ":incense_sandstone_lit"},
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
							stack:set_name(modname .. ":incense_sandstone_ashy")
							return stack
						end
				end
})
------------BURNING UP------------
nodecore.register_abm({
		label = "Incense_sandstone Use",
		interval = 900,
		chance = 1,
		nodenames = {modname .. ":incense_sandstone_lit"},
		action = function(pos)
			return minetest.set_node(pos, {name = modname .. ":incense_sandstone_ashy"})
		end
	})
nodecore.register_aism({
				label = "Held Incense_sandstone Use",
				interval = 90,
				chance = 10,
				itemnames = {modname .. ":incense_sandstone_lit"},
				action = function(stack, data)
						stack:set_name(modname .. ":incense_sandstone_ashy")
						return stack
				end
		})
------------REFILL BURNER------------
nodecore.register_craft({
		label = "refill eggburner_sandstone",
		action = "pummel",
		wield = {name = "nc_tree:eggcorn"},
		after = rfcall,
		nodes = {
				{match = modname .. ":incense_sandstone_empty", replace = modname .. ":incense_sandstone_unlit"}
			}
	})
------------ASH DUMPING------------
nodecore.register_craft({
		label = "empty incense_sandstone",
		action = "pummel",
		duration = 1,
		nodes = {
			{
				match = modname.. ":incense_sandstone_ashy",
				replace = modname.. ":incense_sandstone_empty"
			}
		},
		items = {
			{name = "nc_fire:lump_ash", count = 1}
		}
	})
------------EGG DUMPING------------
nodecore.register_craft({
		label = "remove incense_sandstone",
		action = "pummel",
		nodes = {
			{
				match = modname.. ":incense_sandstone_unlit",
				replace = modname.. ":incense_sandstone_empty"
			}
		},
		items = {
			{name = "nc_tree:eggcorn", count = 1}
		}
	})
------------Break Burner-----------
nodecore.register_craft({
		label = "break incense_sandstone apart",
		action = "pummel",
		duration = 2,
		toolgroups = {thumpy = 3, cracky = 3, choppy = 3},
		nodes = {
			{
				match = {groups = {incense = true}},
				replace = "nc_terrain:sand"
			}
		},
		items = {
--			{name = "nc_stonework:chip", count = 3, scatter = 2},
			{name = "nc_fire:lump_ash", count = 1, scatter = 2},
		},
		itemscatter = 2
	})
------------CRAFT INCENSE------------
nodecore.register_craft({
	label = "chisel eggburner_sandstone",
	action = "pummel",
	duration = 2,
	toolgroups = {thumpy = 3},
	normal = {y = 1},
	indexkeys = {"group:chisel"},
	nodes = {
		{
		match = {
			lode_temper_cool = true,
			groups = {chisel = true}
			},
		dig = true
		},
		{
			y = -1,
			match = "nc_concrete:concrete_sandstone_boxy",
			replace = modname .. ":incense_sandstone_empty"
		}
	}
})
----------------------------------------
------------Incense Ambiance------------
nodecore.register_ambiance({
		label = "Incense_sandstone Ambiance",
		nodenames = {modname.. ":incense_sandstone_lit"},
		interval = 1,
		chance = 2,
		sound_name = "nc_fire_flamy",
		sound_gain = 0.1
	})

