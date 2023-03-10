-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, math, string, tonumber, pairs, vector
    = minetest, nodecore, math, string, tonumber, pairs, vector
local math_ceil, math_log, math_random, string_sub
    = math.ceil, math.log, math.random, string.sub
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
local checkdirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
	{x = 0, y = 1, z = 0}
}
----------------------------------------------------------------------
nodecore.saplight_life_base = 480 	-- 4x longer than regular torch
function nodecore.get_saplight_expire(meta, name)
	local expire = meta:get_float("expire") or 0
	if expire > 0 then return expire end
	local ttl = nodecore.saplight_life_base
	* (nodecore.boxmuller() * 0.1 + 1)
	if name then
		local id = tonumber(string_sub(name, -1))
		if id and id > 1 then
			ttl = ttl * 0.5 ^ (id - 1)
		end
	end
	expire = nodecore.gametime + ttl
	meta:set_float("expire", expire)
	return expire, true
end
----------------------------------------------------------------------
local resin = "nc_fire_coal_4.png^(wc_noditions_sap.png^[opacity:100)"
minetest.register_alias(modname .. ":saplight_lit", modname .. ":saplight_lit_1")
-- ================================================================ --
minetest.register_node(modname .. ":saplight", {
		description = "Resinated Rushlight",
		drawtype = "mesh",
		mesh = "nc_torch_torch.obj",
		tiles = {
			resin,
			"nc_flora_wicker.png",
			resin.. "^[lowpart:50:nc_flora_wicker.png",
			"[combine:1x1"
		},
		backface_culling = true,
		use_texture_alpha = "clip",
		selection_box = nodecore.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
		collision_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			snappy = 1,
			falling_node = 1,
			flammable = 1,
			firestick = 4,
			stack_as_node = 1
		},
		sounds = nodecore.sounds("nc_tree_sticky"),
		on_ignite = function(pos, node)
			minetest.set_node(pos, {name = modname.. ":saplight_lit"})
			nodecore.get_saplight_expire(minetest.get_meta(pos))
			nodecore.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
			if node and node.count and node.count > 1 then
				nodecore.item_disperse(pos, node.name, node.count - 1)
			end
			return true
		end
	})
nodecore.register_craft({
		label = "assemble saplight",
		normal = {y = 1},
		indexkeys = {"wc_noditions:lump_sap"},
		nodes = {
			{match = "wc_noditions:lump_sap", replace = "air"},
			{y = -1, match = modname.. ":rushlight", replace = modname .. ":saplight"},
		}
	})
----------------------------------------------------------------------
nodecore.saplight_life_stages = 4
for i = 1, nodecore.saplight_life_stages do
	local alpha = (i - 1) * (256 / nodecore.saplight_life_stages)
	if alpha > 255 then alpha = 255 end
	local txr = resin.. "^nc_fire_ember_4.png^(nc_fire_ash.png^[opacity:"
	.. alpha .. ")"
	minetest.register_node(modname .. ":saplight_lit_" .. i, {
			description = "Lit Resinated Rushlight",
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
			backface_culling = true,
			use_texture_alpha = "clip",
			selection_box = nodecore.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
			collision_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
			paramtype = "light",
			sunlight_propagates = true,
			light_source = 8 - i,
			groups = {
				snappy = 1,
				falling_node = 1,
				stack_as_node = 1,
				saplight_lit = 1,
				flame_ambiance = 1
			},
			stack_max = 1,
			sounds = nodecore.sounds("nc_tree_sticky"),
			preserve_metadata = function(_, _, oldmeta, drops)
				drops[1]:get_meta():from_table({fields = oldmeta})
			end,
			after_place_node = function(pos, _, itemstack)
				minetest.get_meta(pos):from_table(itemstack:get_meta():to_table())
			end,
			node_dig_prediction = nodecore.dynamic_light_node(16 - i),
			after_destruct = function(pos)
				nodecore.dynamic_light_add(pos, 16 - i)
			end
		})
end
------------------------------------------------------------------------
minetest.register_abm({
		label = "saplight ignite",
		interval = 2,
		chance = 1,
		nodenames = {"group:saplight_lit"},
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
local function saplightlife(expire, pos)
	local max = nodecore.saplight_life_stages
	if expire <= nodecore.gametime then return max end
	local life = (expire - nodecore.gametime) / nodecore.saplight_life_base
	if life > 1 then return 1 end
	local stage = 1 - math_ceil(math_log(life) / log2)
	if stage < 1 then return 1 end
	if stage > max then return max end
	if pos and (stage >= 2) then
		nodecore.smokefx(pos, {
				time = 1,
				rate = (stage - 1) / 2,
				scale = 0.25
			})
	end
	return stage
end

local function snufffx(pos)
	nodecore.smokeburst(pos, 4)
	return nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
end
------------------------------------------------------------------------
minetest.register_abm({
		label = "saplight snuff",
		interval = 1,
		chance = 1,
		nodenames = {"group:saplight_lit"},
		action = function(pos, node)
			local expire = nodecore.get_saplight_expire(minetest.get_meta(pos), node.name)
			if nodecore.quenched(pos) or nodecore.gametime > expire then
				minetest.remove_node(pos)
				minetest.add_item(pos, {name = "nc_fire:lump_ash"})
				snufffx(pos)
				return
			end
			local nn = modname .. ":saplight_lit_" .. saplightlife(expire, pos)
			if node.name ~= nn then
				node.name = nn
				return minetest.swap_node(pos, node)
			end
		end
	})
------------------------------------------------------------------------
nodecore.register_aism({
		label = "saplight stack interact",
		itemnames = {"group:saplight_lit"},
		action = function(stack, data)
			local pos = data.pos
			local player = data.player
			local wield
			if player and data.list == "main"
			and player:get_wield_index() == data.slot then
				wield = true
				pos = vector.add(pos, vector.multiply(player:get_look_dir(), 0.5))
			end

			local expire, dirty = nodecore.get_saplight_expire(stack:get_meta(), stack:get_name())
			if (expire < nodecore.gametime)
			or nodecore.quenched(pos, data.node and 1 or 0.3) then
				snufffx(pos)
				return "nc_fire:lump_ash"
			end

			if wield and math_random() < 0.1 then nodecore.fire_check_ignite(pos) end

			local nn = modname .. ":saplight_lit_" .. saplightlife(expire, pos)
			if stack:get_name() ~= nn then
				stack:set_name(nn)
				return stack
			elseif dirty then
				return stack
			end
		end
	})
-- ================================================================ --
