-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore
    = ItemStack, math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local firedirs = {
	{x = 0, y = 1, z = 0},

	{x = 1, y = 0, z = 0},
	{x = 1, y = 0, z = 0},

	{x = -1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},

	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = 1},

	{x = 0, y = 0, z = -1},
	{x = 0, y = 0, z = -1},

	{x = 0, y = -1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 0, y = -1, z = 0},
}

nodecore.register_craft({
		label = "spark lode",
		action = "pummel",
		wield = {
			groups = {lode_temper_annealed = true}
		},
		indexkeys = {"group:lode_temper_annealed"},
		nodes = {
			{match = {groups = {lode_temper_annealed = true}}}
		},
--		consumewield = 1,
		duration = 5,
		before = function(pos, data)
			local w = data.wield and ItemStack(data.wield):get_name() or ""
			local wd = minetest.registered_items[w] or {}
			local wg = wd.groups or {}
			local fs = wg.lode_temper_annealed or 1
			local nd = minetest.registered_items[data.node.name] or {}
			local ng = nd.groups or {}
			fs = fs * (ng.lode_temper_annealed or 1)
				local sparkfx = minetest.add_particlespawner({
					amount = 50,
					time = 0.02,
					minpos = {x = pos.x, y = pos.y - 0.25, z = pos.z},
					maxpos = {x = pos.x, y = pos.y + 0.5, z = pos.z},
					minvel = {x = -2, y = -3, z = -2},
					maxvel = {x = 2, y = 1, z = 2},
					minacc = {x = 0, y = -0.5, z = 0},
					maxacc = {x = 0, y = -0.5, z = 0},
					minxeptime = 0.4,
					maxexptime = 0.5,
					minsize = 0.4,
					maxsize = 0.5,
					texture = "nc_fire_spark.png",
					collisiondetection = true,
					glow = 7
				})

			local r = math_random(1, 4)
			if r > fs then
--				nodecore.s(pos, 1, 5 + fs - r)
				nodecore.sound_play("nc_api_toolbreak", {pos = pos, gain = 1})
				return
			end

			nodecore.fire_ignite(pos)
			minetest.add_particlespawner({
					amount = 50,
					time = 0.02,
					minpos = {x = pos.x, y = pos.y - 0.25, z = pos.z},
					maxpos = {x = pos.x, y = pos.y + 0.5, z = pos.z},
					minvel = {x = -2, y = -3, z = -2},
					maxvel = {x = 2, y = 1, z = 2},
					minacc = {x = 0, y = -0.5, z = 0},
					maxacc = {x = 0, y = -0.5, z = 0},
					minxeptime = 0.4,
					maxexptime = 0.5,
					minsize = 0.4,
					maxsize = 0.5,
					texture = "nc_fire_spark.png",
					collisiondetection = true,
					glow = 7
				})

			if math_random(1, 4) > fs then return end
			local dir = firedirs[math_random(1, #firedirs)]
			return nodecore.fire_check_ignite({
					x = pos.x + dir.x,
					y = pos.y + dir.y,
					z = pos.z + dir.z
				})
		end
	})
