-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, setmetatable, vector
	= ItemStack, math, minetest, nodecore, pairs, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
-------------------------------------------------------------------------------
local rfcall = function(pos, data)
	local ref = minetest.get_player_by_name(data.pname)
	local wield = ref:get_wielded_item()
	wield:take_item(1)
	ref:set_wielded_item(wield)
end
-- <>=====================================================================<> --
local stone			= "nc_terrain_stone.png"
local adobe			= "nc_concrete_adobe.png"
local sandstone		= "nc_concrete_sandstone.png"
local coalstone		= "nc_terrain_stone.png^[colorize:#000000:160"
local cloudstone	= "nc_concrete_cloudstone.png"

local ceramic		= "wc_pottery_ceramic.png"
local pumcrete		= "nc_igneous_pumice.png^[colorize:black:80"
local shellstone	= "wc_naturae_shellstone.png"

local topdesign		= "nc_concrete_pattern_boxy.png^[opacity:50"
local sidedesign	= "nc_concrete_pattern_horzy.png^[opacity:50"

local bowlempty		= "(nc_fire_coal_4.png^[mask:" ..modname.. "_mask_pit.png)^[opacity:75"
local bowlfull		= "(nc_terrain_gravel.png^[colorize:darkgoldenrod:100)^[mask:" ..modname.. "_mask_pit.png"
local bowlember		= "(nc_fire_coal_4.png^(nc_fire_ember_3.png^[opacity:150))^[mask:" ..modname.. "_mask_pit.png"
local bowlash		= "nc_fire_ash.png^[mask:" ..modname.. "_mask_pit.png"
-- <>=====================================================================<> --
local function register_slowburner(material, desc, texture, sound, makefrom, breakto, shard)

	local function burner(id, light, tile)
		minetest.register_node(modname .. ":incense_" ..material.. "_" ..id, {
			description = desc.. " Slowburner",
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
				incense = 1
			},
			stack_max = 1,
			sounds = nodecore.sounds(sound)
		})
	end
-------------------------------------------------------------------------------
burner("empty",	0,
	{
		"(" ..texture.. ")^(" ..topdesign.. ")^(" ..bowlempty.. ")",
		texture,
		"(" ..texture.. ")^(" ..sidedesign.. ")"
	}
)
burner("unlit",	0,
	{
		"(" ..texture.. ")^(" ..topdesign.. ")^(" ..bowlempty.. ")^(" ..bowlfull.. ")",
		texture,
		"(" ..texture.. ")^(" ..sidedesign.. ")"
	}
)
burner("lit",		4,
	{
		"(" ..texture.. ")^(" ..topdesign.. ")^(" ..bowlempty.. ")^(" ..bowlember.. ")",
		texture,
		"(" ..texture.. ")^(" ..sidedesign.. ")"
	}
)
burner("ashy",		0,
	{
		"(" ..texture.. ")^(" ..topdesign.. ")^(" ..bowlempty.. ")^(" ..bowlash.. ")",
		texture,
		"(" ..texture.. ")^(" ..sidedesign.. ")"
	}
)
-------------------------------------------------------------------------------
----------------IGNITION-----------------
	minetest.register_abm({
		label = "Ignite " ..desc.. " Slowburner",
		interval = 10,
		chance = 2,
		nodenames = {modname.. ":incense_" ..material.. "_unlit"},
		neighbors = {"group:igniter", "group:torch_lit", "group:candle_lit"},
--		action_delay = true,
		action = function(pos)
			if not nodecore.quenched(pos) then
			minetest.set_node(pos, {name = modname.. ":incense_" ..material.. "_lit"})
			end
		end
	})
----------------QUENCHING-----------------
	nodecore.register_abm({
		label = "Incense " ..desc.. " Quenching",
		interval = 0.1,
		chance = 1,
		nodenames = {modname .. ":incense_" ..material.. "_lit"},
		action = function(pos)
			if nodecore.quenched(pos) then
				nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
				return minetest.set_node(pos, {name = modname.. ":incense_" ..material.. "_ashy"})
			end
		end
	})
	nodecore.register_aism({
				label = "Held Incense " ..desc.. " Quenching",
				interval = 0.1,
				chance = 1,
				itemnames = {modname .. ":incense_" ..material.. "_lit"},
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
							stack:set_name(modname .. ":incense_" ..material.. "_ashy")
							return stack
						end
				end
})
------------BURNING UP------------
	nodecore.register_abm({
		label = "Incense " ..desc.. " Use",
		interval = 900,
		chance = 1,
		nodenames = {modname .. ":incense_" ..material.. "_lit"},
		action = function(pos)
			return minetest.set_node(pos, {name = modname .. ":incense_" ..material.. "_ashy"})
		end
	})
	nodecore.register_aism({
				label = "Held Incense " ..desc.. " Use",
				interval = 90,
				chance = 10,
				itemnames = {modname .. ":incense_" ..material.. "_lit"},
				action = function(stack, data)
						stack:set_name(modname .. ":incense_" ..material.. "_ashy")
						return stack
				end
		})
------------REFILL BURNER------------
	nodecore.register_craft({
		label = "Refill " ..desc.. " Slowburner Eggcorn",
		action = "pummel",
		wield = {name = "nc_tree:eggcorn"},
		after = rfcall,
		nodes = {
				{match = modname .. ":incense_" ..material.. "_empty", replace = modname .. ":incense_" ..material.. "_unlit"}
			}
	})
	if minetest.get_modpath("wc_noditions") then
		nodecore.register_craft({
			label = "Refill " ..desc.. " Slowburner Sap",
			action = "pummel",
			wield = {name = "wc_noditions:lump_sap"},
			after = rfcall,
			nodes = {
					{match = modname .. ":incense_" ..material.. "_empty", replace = modname .. ":incense_" ..material.. "_unlit"}
				}
		})
	end
------------ASH DUMPING------------
	nodecore.register_craft({
		label = "Empty " ..desc.. " Slowburner",
		action = "pummel",
		duration = 1,
		nodes = {
			{
				match = modname.. ":incense_" ..material.. "_ashy",
				replace = modname.. ":incense_" ..material.. "_empty"
			}
		},
		items = {
			{name = "nc_fire:lump_ash", count = 1}
		}
	})
------------Break Burner-----------
	nodecore.register_craft({
		label = "Break " ..desc.. " Slowburner",
		action = "pummel",
		duration = 2,
		toolgroups = {thumpy = 3, cracky = 3, choppy = 3},
		nodes = {
			{
				match = {groups = {incense = true}},
				replace = breakto
			}
		},
		items = {
			{name = shard, count = 1, scatter = 2},
			{name = "nc_fire:lump_ash", count = 1, scatter = 2},
		},
		itemscatter = 2
	})
------------CRAFT INCENSE------------
	nodecore.register_craft({
		label = "Chisel " ..desc.. " Slowburner",
		action = "pummel",
		duration = 2,
		toolgroups = {thumpy = 3},
		normal = {y = 1},
		indexkeys = {"group:chisel"},
		nodes = {
			{
			match = {
				lode_temper_cool = true,
				groups = {chisel = 1}
				},
			dig = true
			},
			{
				y = -1,
				match = makefrom,
				replace = modname .. ":incense_" ..material.. "_empty"
			}
		}
	})
------------Incense Ambiance------------
	nodecore.register_ambiance({
		label = "Incense " ..desc.. " Ambiance",
		nodenames = {modname.. ":incense_" ..material.. "_lit"},
		interval = 2,
		chance = 2,
		sound_name = "nc_fire_flamy",
		sound_gain = 0.2
	})
-------------------------------------------------------------------------------
end
-- <>=====================================================================<> --
-- register_slowburner(material, desc, texture, sound, makefrom, breakto, shard)
register_slowburner("stone",		"Carved Stone",	stone,		"nc_terrain_stony", "nc_concrete:terrain_stone_boxy",			"nc_terrain:gravel",		"nc_stonework:chip")
register_slowburner("adobe",		"Earthenware",	adobe,		"nc_terrain_stony", "nc_concrete:concrete_adobe_boxy",			"nc_terrain:dirt",			"nc_fire:lump_ash")
register_slowburner("sandstone",	"Sandstone",	sandstone,	"nc_terrain_stony", "nc_concrete:concrete_sandstone_boxy",		"nc_terrain:sand",			"nc_fire:lump_ash")
register_slowburner("coalstone",	"Tarstone",		coalstone,	"nc_terrain_stony", "nc_concrete:concrete_coalstone_boxy",		"nc_terrain:gravel",		"nc_stonework:chip")
register_slowburner("cloudstone",	"Porcelain",	cloudstone,	"nc_optics_glassy", "nc_concrete:concrete_cloudstone_boxy",		"nc_optics:glass_crude",	"nc_stonework:chip")

if minetest.get_modpath("wc_naturae") then
register_slowburner("shellstone",	"Shellstone",	shellstone,	"nc_optics_glassy", "nc_concrete:wc_naturae_shellstone_boxy",	"wc_naturae:coquina",		"wc_naturae:shell")
end

if minetest.get_modpath("wc_pottery") then
	register_slowburner("ceramic",		"Clayware",		ceramic,	"nc_optics_glassy", "nc_concrete:wc_pottery_ceramic_boxy",		"wc_pottery:clay",			"wc_pottery:chip")
end

if minetest.get_modpath("wc_vulcan") then
register_slowburner("pumcrete",		"Vulcan",		pumcrete,	"nc_optics_glassy", "nc_concrete:wc_vulcan_pumcrete_boxy",		"nc_igneous:pumice",		"nc_fire:lump_ash")
end
-- <>=====================================================================<> --


