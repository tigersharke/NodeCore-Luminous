-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, math
    = minetest, nodecore, math
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local function smokey(posa, posb)
	posb=posb or posa 
	local minpos = {
		x = (posa.x < posb.x and posa.x or posb.x) - 0.25,
		y = (posa.y < posb.y and posa.y or posb.y) - 0,
		z = (posa.z < posb.z and posa.z or posb.z) - 0.25
	}
	local maxpos = {
		x = (posa.x > posb.x and posa.x or posb.x) + 0.25,
		y = (posa.y > posb.y and posa.y or posb.y) + 0,
		z = (posa.z > posb.z and posa.z or posb.z) + 0.25
	}
	local volume = (maxpos.x - minpos.x + 1) * (maxpos.y - minpos.y + 1)
	* (maxpos.z - minpos.z + 1)
	minetest.add_particlespawner({
			amount = 3 * volume,
			time = 10,
			minpos = minpos,
			maxpos = maxpos,
			minvel = {x = -0.1, y = 0.25, z = -0.1},
			maxvel = {x = 0.1, y = 0.75, z = 0.1},
			texture = "nc_api_craft_smoke.png^[opacity:150",
			minexptime = 2,
			maxexptime = 12,
			collisiondetection = true,
			minsize = 1,
			maxsize = 4
		})
end
------------------------------------------------------------------------
nodecore.register_abm({
		label = "particles:incense",
		interval = 10,
		chance = 1,
		nodenames = {
		modname.. ":incense_stone_lit",
		modname.. ":incense_adobe_lit",
		modname.. ":incense_sandstone_lit",
		modname.. ":incense_coalstone_lit",
		modname.. ":incense_cloudstone_lit",
		modname.. ":incense_shellstone_lit",
		modname.. ":incense_ceramic_lit",

		},
		action = function(pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			local abnod = minetest.get_node(above)
			local top = {x = pos.x, y = pos.y + 0.5, z = pos.z}
			     if abnod.name == "air" then
					smokey(top)
			end
		end
})


