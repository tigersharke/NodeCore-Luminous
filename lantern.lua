-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, setmetatable, vector
	= ItemStack, math, minetest, nodecore, pairs, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
local checkdirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
	{x = 0, y = 1, z = 0}
}
----------------------------------------
nodecore.lantern_life_base = 120
nodecore.max_lantern_fuel = 10
-------------------------------------------------------------------------------
local globe = "nc_optics_glass_glare.png^[mask:" ..modname.. "_mask_globe.png"
local plate = "nc_lode_annealed.png^[mask:" ..modname.. "_mask_lantern.png"
local fslot = modname.. "_fuel_slot.png^[opacity:65"
local ftile = modname.. "_fire.png"
-------------------------------------------------------------------------------
local flame = {
	name = modname.. "_fire_anim.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 4
	}
}
-------------------------------------------------------------------------------
----------EMPTY LANTERN----------
minetest.register_node(modname .. ":lantern_empty", {
	description = "Coal Lantern",
		tiles = {
		"nc_lode_annealed.png",
		"nc_lode_annealed.png",
		"(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")",
		"(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")",
		"(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")",
		"(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},				-- BasePlate
			{-0.5, 0.25, -0.5, 0.5, 0.375, 0.5},				-- TopPlate
			{-0.375, 0.375, -0.375, 0.375, 0.4375, 0.375},		-- TopRiser
			{-0.25, 0.4375, -0.25, 0.25, 0.5, 0.25},			-- TopCap
			{-0.4375, -0.3125, -0.4375, 0.4375, -0.25, 0.4375},	-- BasePlate
			{-0.375, -0.25, -0.375, 0.375, 0.25, 0.375},			-- Globe
		}
	},
		sunlight_propagates = true,
--		light_source = light,
		groups = {
			stack_as_node = 1,
			snappy = 1,
			lantern = 1,
			lantern_fuel = 0,
			lantern_off =1,
			totable = 1
		},
		stack_max = 1,
		sounds = nodecore.sounds("nc_lode_annealed"),
	})
----------------------------------------
------------Lantern Crafting------------
nodecore.register_craft({
		label = "assemble lantern",
		action = "stackapply",
		indexkeys = {"nc_lode:form"},
		wield = {name = "nc_optics:glass"},
		consumewield = 1,
		nodes = {
			{match = "nc_lode:form", replace = "air"},
			{y = -1, match = "nc_lode:block_annealed", replace = modname .. ":lantern_empty"},
		}
	})
----------------------------------------
-----------FUELED LANTERN OFF-----------
local lnodes = {}
----------------------------------------
local function lantern (fuel) -- Kimapr: deleted these redundant arguments (fuel, burn, energy, light, refill)
----------------------------------------
local burn = fuel-1
local aburns = burn == 0 and "empty" or "lit_"..burn -- nodename suffix after burn
local aburn = burn == 0 and "empty" or burn
local light = fuel + 6
----------------------------------------
minetest.register_node(modname .. ":lantern_" .. fuel, {
	description = "Coal Lantern",
		tiles = {
		"nc_lode_annealed.png",
		"nc_lode_annealed.png",
		"(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")^(" ..modname.. "_fuel_" ..fuel.. ".png)",
		"(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")^(" ..modname.. "_fuel_" ..fuel.. ".png)",
		"(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")^(" ..modname.. "_fuel_" ..fuel.. ".png)",
		"(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")^(" ..modname.. "_fuel_" ..fuel.. ".png)"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},				-- BasePlate
			{-0.5, 0.25, -0.5, 0.5, 0.375, 0.5},				-- TopPlate
			{-0.375, 0.375, -0.375, 0.375, 0.4375, 0.375},		-- TopRiser
			{-0.25, 0.4375, -0.25, 0.25, 0.5, 0.25},			-- TopCap
			{-0.4375, -0.3125, -0.4375, 0.4375, -0.25, 0.4375},	-- BasePlate
			{-0.375, -0.25, -0.375, 0.375, 0.25, 0.375},			-- Globe
		}
	},
		sunlight_propagates = true,
--		light_source = light,
		groups = {
			falling = 1,
			flammable = 1,
			stack_as_node = 1,
			snappy = 1,
			lantern_off = 1,
			lantern_fuel = fuel,
			lantern = 1,
			totable = 1
		},
		stack_max = 1,
		sounds = nodecore.sounds("nc_lode_annealed"),
		on_ignite = function(pos, node)
			minetest.set_node(pos, {name = modname .. ":lantern_lit_" .. fuel})
			minetest.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
			return true
			end
	})
----------------------------------------
-----------FUELED LANTERN LIT-----------
minetest.register_node(modname .. ":lantern_lit_" .. fuel, {
	description = "Coal Lantern",
	tiles = {
		"nc_lode_annealed.png",
		"nc_lode_annealed.png",
		"(" ..ftile.. ")^(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")^(" ..modname.. "_fuel_" ..fuel.. ".png)",
		"(" ..ftile.. ")^(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")^(" ..modname.. "_fuel_" ..fuel.. ".png)",
		"(" ..ftile.. ")^(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")^(" ..modname.. "_fuel_" ..fuel.. ".png)",
		"(" ..ftile.. ")^(" ..globe.. ")^(" ..plate.. ")^(" ..fslot.. ")^(" ..modname.. "_fuel_" ..fuel.. ".png)",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},				-- BasePlate
			{-0.5, 0.25, -0.5, 0.5, 0.375, 0.5},				-- TopPlate
			{-0.375, 0.375, -0.375, 0.375, 0.4375, 0.375},		-- TopRiser
			{-0.25, 0.4375, -0.25, 0.25, 0.5, 0.25},			-- TopCap
			{-0.4375, -0.3125, -0.4375, 0.4375, -0.25, 0.4375},	-- BasePlate
			{-0.375, -0.25, -0.375, 0.375, 0.25, 0.375},			-- Globe
		}
	},
		sunlight_propagates = true,
		light_source = light,
		groups = {
			falling = 1,
			stack_as_node = 1,
			snappy = 1,
			lantern_lit = 1,
			lantern_fuel = fuel,
			lantern = 1,
			totable = 1
		},
		stack_max = 1,
		sounds = nodecore.sounds("nc_lode_annealed")
	})	
--lnodes[light] = nodecore.dynamic_light_node(light)
--lnodes[light-2] = nodecore.dynamic_light_node(light-2)
----------------------------------------
------------Fuel Consumption------------
-----Placed-----
nodecore.register_abm({
		label = "Lantern Quenching",
		interval = 0.1,
		chance = 1,
		nodenames = {modname .. ":lantern_lit_" .. fuel},
		action = function(pos)
			if nodecore.quenched(pos) then
				nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
				return minetest.set_node(pos, {name = modname .. ":lantern_"..fuel})
			end
		end
	})
nodecore.register_abm({
		label = "Lantern Fuel Use",
		interval = 100,
		chance = 1,
		nodenames = {modname .. ":lantern_lit_" .. fuel},
		action = function(pos)
			nodecore.sound_play("nc_fire_ignite", {gain = 0.4, pos = pos})
			return minetest.set_node(pos, {name = modname .. ":lantern_" .. aburns})
		end
	})
-- Kimapr: merged two ABMs into one
-----Carried-----
nodecore.register_aism({
				label = "Lantern Quenching",
				interval = 0.1,
				chance = 1,
				itemnames = {modname .. ":lantern_lit_" .. fuel},
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
							stack:set_name(modname .. ":lantern_"..fuel)
							return stack
						end
				end
})
nodecore.register_aism({
				label = "Held Fuel Use",
				interval = 100,
				chance = 1,
				itemnames = {modname .. ":lantern_lit_" .. fuel},
				action = function(stack, data)
						minetest.sound_play("nc_fire_ignite", {gain = 0.4, pos = data.pos})
						stack:set_name(modname .. ":lantern_" .. aburns)
						return stack
				end
		})
----------------------------------------
-------------Lantern Refill-------------
local rfcall = function(pos, data)
	local ref = minetest.get_player_by_name(data.pname)
	local wield = ref:get_wielded_item()
	wield:take_item(1)
	ref:set_wielded_item(wield)
end

nodecore.register_craft({
		label = "refill lantern",
		action = "pummel",
		wield = {name = "nc_fire:lump_coal"},
		after = rfcall,
		nodes = {
				{match = modname .. ":lantern_"..aburn, replace = modname .. ":lantern_"..fuel}
			}
	})
	
if fuel > 1 then

nodecore.register_craft({
		label = "refill lit lantern",
		action = "pummel",
		wield = {name = "nc_fire:lump_coal"},
		after = rfcall,
		nodes = {
			{
				match = modname .. ":lantern_"..aburns,
				replace = modname .. ":lantern_lit_"..fuel
			}
		}
	})
end

----------------------------------------
------------Lantern Emptying------------
nodecore.register_craft({
		label = "empty lantern",
		action = "pummel",
		duration = 1,
--		toolgroups = {thumpy = 1},
		nodes = {
			{
				match = modname.. ":lantern_" ..fuel,
				replace = modname.. ":lantern_empty"
			}
		},
		items = {
			{name = "nc_fire:lump_coal", count = fuel, scatter = 2}
--			{name = "nc_fire:lump_ash", count = ashes, scatter = ashes}
		},
		itemscatter = 2
	})

----------------------------------------
------------Lantern Recycling-----------
nodecore.register_craft({
		label = "break lantern apart",
		action = "pummel",
		duration = 2,
		toolgroups = {choppy = 4},
		nodes = {
			{
				match = {groups = {lantern = true}},
				replace = "nc_lode:form"
			}
		},
		items = {
			{name = "nc_optics:glass_crude", count = 1, scatter = 1},
			{name = "nc_lode:toolhead_mallet_annealed", count = 2, scatter = 3},
			{name = "nc_lode:prill_annealed", count = 2, scatter = 4}
--			{name = "nc_fire:lump_coal", count = fuel, scatter = 6},
--			{name = "nc_fire:lump_ash", count = ashes, scatter = ashes}
		},
		itemscatter = 2
	})

----------------------------------------
------------Lantern Ambiance------------
nodecore.register_ambiance({
		label = "Flame Ambiance",
		nodenames = {modname.. ":lantern_lit_" ..fuel},
		interval = 1,
		chance = 2,
		sound_name = "nc_fire_flamy",
		sound_gain = 0.1
	})

end
----------------------------------------
---------------Falling Ash--------------
-----Placed-----
nodecore.register_abm({
	label = "Lantern Ashing",
	interval = 20,
	chance = 4,
	nodenames = {"group:lantern_lit"},
	action = function(pos)
		nodecore.item_eject(pos, "nc_fire:lump_ash", 1)
	end
})
-----Carried-----
nodecore.register_aism({
	label = "Held Lantern Ashing",
	interval = 20,
	chance = 4,
	itemnames = {"group:lantern_lit"},
	action = function(stack, data)
		nodecore.item_eject(data.pos,"nc_fire:lump_ash",1,1,{x = 1, y = 1, z = 1})
	end
})
----------------------------------------
--------------WHEN WIELDED--------------
local litgroup = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_items) do
			if v.groups.lantern_lit then
				litgroup[k] = true
			end
		end
	end)
local function islit(stack)
	return stack and litgroup[stack:get_name()]
end

local function snuffinv(player, inv, i, fuel)
	minetest.sound_play("nc_fire_snuff", {object = player, gain = 0.5})
	inv:set_stack("main", i, modname .. ":lantern_"..fuel)
end


local ambtimers = {}
minetest.register_globalstep(function()
		local now = nodecore.gametime
		for _, player in pairs(minetest.get_connected_players()) do
			local inv = player:get_inventory()
			local ppos = player:get_pos()

			-- Snuff all lanterns if doused in water.
			local hpos = vector.add(ppos, {x = 0, y = 1, z = 0})
			local head = minetest.get_node(hpos).name
			local wielditem = player:get_wielded_item()
			local wdef = minetest.registered_items[wielditem:get_name()]
			if minetest.get_item_group(head, "water") > 0 then
				for i = 1, inv:get_size("main") do
					local stack = inv:get_stack("main", i)
					if islit(stack) then snuffinv(player, inv, i, minetest.get_item_group(stack:get_name(),"lantern_fuel")) end
				end
			elseif islit(player:get_wielded_item()) then
				local bright = lnodes[wdef.light_source]
				-- Wield light
				local name = player:get_player_name()
--				nodecore.dynamic_light_add(hpos, bright, 0.5)

				-- Wield ambiance
				local t = ambtimers[name] or 0
				if t <= now then
					ambtimers[name] = now + 1
					minetest.sound_play("nc_fire_flamy",
						{object = player, gain = 0.1})
				end
			else
				-- Dimmer non-wielded carry light
				for i = 1, inv:get_size("main") do
					local stack = inv:get_stack("main", i)
					if islit(stack) then
						local def = minetest.registered_items[stack:get_name()]
						local dim = lnodes[def.light_source - 2]
--						nodecore.dynamic_light_add(hpos, dim, 0.5)
					end
				end
			end
		end
	end)

-- Apply wield light to entities as well.
local function entlight(self, ...)
	local stack = ItemStack(self.node and self.node.name or self.itemstring or "")
	local def = minetest.registered_items[stack:get_name()]
	if not islit(stack) then return ... end
	local bright = lnodes[def.light_source]
--	nodecore.dynamic_light_add(self.object:get_pos(), bright, 0.5)
	return ...
end
for _, name in pairs({"item", "falling_node"}) do
	local def = minetest.registered_entities["__builtin:" .. name]
	local ndef = {
		on_step = function(self, ...)
			return entlight(self, def.on_step(self, ...))
		end
	}
	setmetatable(ndef, def)
	minetest.register_entity(":__builtin:" .. name, ndef)
end

--Lantern-Fuel-Burn-Energy-Light-Refill--
for n=1,nodecore.max_lantern_fuel do
	lantern(n)
end


