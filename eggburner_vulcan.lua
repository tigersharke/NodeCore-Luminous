-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, setmetatable, vector
	= ItemStack, math, minetest, nodecore, pairs, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
-------------------------------------------------------------------------------
local base = "nc_igneous_pumice.png^[colorize:black:80"
local boxy = "nc_concrete_pattern_boxy.png^[opacity:40"
local horzy = "nc_concrete_pattern_horzy.png^[opacity:40"
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
	minetest.register_node(modname .. ":incense_pumcrete_" ..id, {
		description = "Vulcan Egg Burner",
		tiles = tile,
		drawtype = "nodebox",
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.25, -0.5, -0.25, 0.25, -0.4375, 0.25},			-- Bowl_1
				{-0.375, -0.4375, -0.375, 0.375, -0.375, 0.375},	-- Bowl_2
				{-0.4375, -0.375, -0.4375, 0.4375, -0.25, 0.4375},	-- Bowl_3
				{-0.5, -0.25, -0.5, 0.5, 0, 0.5},				-- Bowl_4
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
			incense_pumcrete = 1
		},
		stack_max = 1,
		sounds = nodecore.sounds("nc_optics_glassy")
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
		label = "ignite eggburner_pumcrete",
		interval = 10,
		chance = 2,
		nodenames = {modname.. ":incense_pumcrete_unlit"},
		neighbors = {"group:igniter", "group:torch_pumcrete_lit", "group:candle_pumcrete_lit"},
--		action_delay = true,
		action = function(pos)
			if not nodecore.quenched(pos) then
			minetest.set_node(pos, {name = modname.. ":incense_pumcrete_lit"})
			end
		end
	})
----------------QUENCHING-----------------
nodecore.register_abm({
		label = "Incense_pumcrete Quenching",
		interval = 0.1,
		chance = 1,
		nodenames = {modname .. ":incense_pumcrete_lit"},
		action = function(pos)
			if nodecore.quenched(pos) then
				nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
				return minetest.set_node(pos, {name = modname.. ":incense_pumcrete_ashy"})
			end
		end
	})
nodecore.register_aism({
				label = "Held Incense_pumcrete Quenching",
				interval = 0.1,
				chance = 1,
				itemnames = {modname .. ":incense_pumcrete_lit"},
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
							stack:set_name(modname .. ":incense_pumcrete_ashy")
							return stack
						end
				end
})
------------BURNING UP------------
nodecore.register_abm({
		label = "Incense_pumcrete Use",
		interval = 950,
		chance = 1,
		nodenames = {modname .. ":incense_pumcrete_lit"},
		action = function(pos)
			return minetest.set_node(pos, {name = modname .. ":incense_pumcrete_ashy"})
		end
	})
nodecore.register_aism({
				label = "Held Incense_pumcrete Use",
				interval = 90,
				chance = 10,
				itemnames = {modname .. ":incense_pumcrete_lit"},
				action = function(stack, data)
						stack:set_name(modname .. ":incense_pumcrete_ashy")
						return stack
				end
		})
------------REFILL BURNER------------
nodecore.register_craft({
		label = "refill eggburner_pumcrete",
		action = "pummel",
		wield = {name = "nc_tree:eggcorn"},
		after = rfcall,
		nodes = {
				{match = modname .. ":incense_pumcrete_empty", replace = modname .. ":incense_pumcrete_unlit"}
			}
	})
------------ASH DUMPING------------
nodecore.register_craft({
		label = "empty incense_pumcrete",
		action = "pummel",
		duration = 1,
		nodes = {
			{
				match = modname.. ":incense_pumcrete_ashy",
				replace = modname.. ":incense_pumcrete_empty"
			}
		},
		items = {
			{name = "nc_fire:lump_ash", count = 1}
		}
	})
------------EGG DUMPING------------
nodecore.register_craft({
		label = "remove incense_pumcrete",
		action = "pummel",
		nodes = {
			{
				match = modname.. ":incense_pumcrete_unlit",
				replace = modname.. ":incense_pumcrete_empty"
			}
		},
		items = {
			{name = "nc_tree:eggcorn", count = 1}
		}
	})
------------Break Burner-----------
nodecore.register_craft({
		label = "break incense_pumcrete apart",
		action = "pummel",
		duration = 2,
		toolgroups = {thumpy = 3, cracky = 3, choppy = 3},
		nodes = {
			{
				match = {groups = {incense = true}},
				replace = "nc_terrain:gravel"
			}
		},
		items = {
			{name = "nc_stonework:chip", count = 3, scatter = 2},
			{name = "nc_fire:lump_ash", count = 1, scatter = 2},
		},
		itemscatter = 2
	})
------------CRAFT INCENSE------------
nodecore.register_craft({
	label = "chisel eggburner_pumcrete",
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
			match = "nc_concrete:wc_vulcan_pumcrete_boxy",
			replace = modname .. ":incense_pumcrete_empty"
		}
	}
})
----------------------------------------
------------Incense Ambiance------------
nodecore.register_ambiance({
		label = "Incense_pumcrete Ambiance",
		nodenames = {modname.. ":incense_pumcrete_lit"},
		interval = 1,
		chance = 2,
		sound_name = "nc_fire_flamy",
		sound_gain = 0.1
	})

