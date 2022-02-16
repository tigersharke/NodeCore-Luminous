-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, setmetatable, vector
	= ItemStack, math, minetest, nodecore, pairs, setmetatable, vector
local math_ceil, math_log, math_random
    = math.ceil, math.log, math.random
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
local checkdirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
	{x = 0, y = 1, z = 0}
}
------------------------------------------------------------------------
nodecore.candle_life_base = 30
------------------------------------------------------------------------
minetest.register_node(modname .. ":rushlight", {
	description = "Rushlight",
	drawtype = "mesh",
	mesh = "nc_torch_torch.obj",
	tiles = {
		"nc_flora_wicker.png"
	},
	backface_culling = false,
	use_texture_alpha = "clip",
	selection_box = nodecore.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
	collision_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
	paramtype = "light",
	sunlight_propagates = true,
	groups = {
		snappy = 1,
		falling_repose = 1,
		flammable = 1,
		firestick = 2,
		stack_as_node = 1
	},
	sounds = nodecore.sounds("nc_terrain_swishy"),
	on_ignite = function(pos, node)
		minetest.set_node(pos, {name = modname .. ":rushlight_lit"})
		nodecore.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
		local expire = nodecore.gametime + nodecore.candle_life_base
		* (nodecore.boxmuller() * 0.1 + 1)
		minetest.get_meta(pos):set_float("expire", expire)
		if node and node.count and node.count > 1 then
			nodecore.item_disperse(pos, node.name, node.count - 1)
		end
		return true
	end
})
------------------------------------------------------------------------
nodecore.register_craft({
		label = "assemble rushlight",
		action = "pummel",
		duration = 2,
		indexkeys = {"nc_flora:rush_dry"},
		wield = {name = "nc_woodwork:staff"},
		consumewield = 1,
		nodes = {
			{match = {name = "nc_flora:rush_dry", count = 2}, replace = "air"}
		},
		items = {
			{name = modname .. ":rushlight"}
		}
	})
------------------------------------------------------------------------
nodecore.candle_life_stages = 4
for i = 1, nodecore.candle_life_stages do
	local alpha = (i - 1) * (256 / nodecore.candle_life_stages)
	if alpha > 255 then alpha = 255 end
	local txr = "nc_flora_wicker.png^nc_fire_ember_4.png^(nc_fire_ash.png^[opacity:"
	.. alpha .. ")"
	minetest.register_node(modname .. ":rushlight_lit_" .. i, {
			description = "Lit Rushlight",
			drawtype = "mesh",
			mesh = "nc_torch_torch.obj",
			tiles = {
				txr,
				"nc_flora_wicker.png",
				txr .. "^[lowpart:50:nc_flora_wicker.png",
				{
					name = "nc_torch_flame.png",
					animation = {
						["type"] = "vertical_frames",
						aspect_w = 3,
						aspect_h = 8,
						length = 0.6
					}
				}
			},
			backface_culling = false,
			use_texture_alpha = "clip",
			selection_box = nodecore.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
			collision_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
			paramtype = "light",
			sunlight_propagates = true,
			light_source = 6 - i,
			groups = {
				snappy = 1,
				falling_repose = 1,
				stack_as_node = 1,
				candle_lit = 1,
				flame_ambiance = 1
				--igniter = 1
			},
			stack_max = 1,
			sounds = nodecore.sounds("nc_terrain_swishy"),
			preserve_metadata = function(_, _, oldmeta, drops)
				drops[1]:get_meta():from_table({fields = oldmeta})
			end,
			after_place_node = function(pos, _, itemstack)
				minetest.get_meta(pos):from_table(itemstack:get_meta():to_table())
			end,
			node_dig_prediction = nodecore.dynamic_light_node(6 - i),
			after_destruct = function(pos)
				nodecore.dynamic_light_add(pos, 6 - i)
			end
		})
end
------------------------------------------------------------------------
minetest.register_abm({
		label = "rushlite ignite",
		interval = 6,
		chance = 1,
		nodenames = {"group:candle_lit"},
		neighbors = {"group:flammable"},
		action_delay = true,
		action = function(pos)
			for _, ofst in pairs(checkdirs) do
				local npos = vector.add(pos, ofst)
				local nbr = minetest.get_node(npos)
				if minetest.get_item_group(nbr.name, "flammable") > 0
				and not nodecore.quenched(npos) then
					nodecore.fire_check_ignite(npos, nbr)
				end
			end
		end
	})
------------------------------------------------------------------------
local log2 = math_log(2)
local function candlelife(expire)
	local max = nodecore.candle_life_stages
	if expire <= nodecore.gametime then return max end
	local life = (expire - nodecore.gametime) / nodecore.candle_life_base
	if life > 1 then return 1 end
	local stage = 1 - math_ceil(math_log(life) / log2)
	if stage < 1 then return 1 end
	if stage > max then return max end
	return stage
end
------------------------------------------------------------------------
minetest.register_abm({
		label = "candle snuff",
		interval = 1,
		chance = 1,
		nodenames = {"group:candle_lit"},
		action = function(pos, node)
			local expire = minetest.get_meta(pos):get_float("expire") or 0
			if nodecore.quenched(pos) or nodecore.gametime > expire then
				minetest.remove_node(pos)
				minetest.add_item(pos, {name = "nc_fire:lump_ash"})
				nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
				return
			end
			local nn = modname .. ":rushlight_lit_" .. candlelife(expire)
			if node.name ~= nn then
				node.name = nn
				return minetest.swap_node(pos, node)
			end
		end
	})
------------------------------------------------------------------------
nodecore.register_aism({
		label = "rushlight stack interact",
		itemnames = {"group:candle_lit"},
		action = function(stack, data)
			local expire = stack:get_meta():get_float("expire") or 0
			if expire < nodecore.gametime then
				nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = data.pos})
				return "nc_fire:lump_ash"
			end

			local pos = data.pos
			local player = data.player
			local wield
			if player and data.list == "main"
			and player:get_wield_index() == data.slot then
				wield = true
				pos = vector.add(pos, vector.multiply(player:get_look_dir(), 0.5))
			end

			if nodecore.quenched(pos, data.node and 1 or 0.3) then
				nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
				return "nc_fire:lump_ash"
			end

			if wield and math_random() < 0.1 then nodecore.fire_check_ignite(pos) end

			local nn = modname .. ":rushlight_lit_" .. candlelife(expire)
			if stack:get_name() ~= nn then
				stack:set_name(nn)
				return stack
			end
		end
	})
------------------------------------------------------------------------
minetest.register_alias(modname .. ":rushlight_lit", modname .. ":rushlight_lit_1")
------------------------------------------------------------------------

