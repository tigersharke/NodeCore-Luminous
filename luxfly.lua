-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()

---------------------------------------
----------------Registry---------------
---------------------------------------
minetest.register_node(modname .. ":bug", {
	description = ("Luxfly"),
	drawtype = "plantlike",
	tiles = {{
		name = modname .. "_torchbug_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1.5
		},
	}},
	inventory_image = modname .. "_torchbug.png",
	wield_image =  modname .. "_torchbug.png",
	waving = 1,
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	walkable = false,
	groups = {torchbug = 1},
	selection_box = {
		type = "fixed",
		fixed = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	},
	light_source = 2
})
---------------------------------------
minetest.register_node(modname .. ":bug_hidden", {
	description = ("Hidden Luxfly"),
	drawtype = "airlike",
	inventory_image = modname .. "_torchbug.png",
	wield_image =  modname .. "_torchbug.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	groups = {torchbug = 1},
	floodable = true
	})

---------------------------------------
-----------Spawn on WorldGen-----------
---------------------------------------
minetest.register_decoration({
		name = {modname .. ":bug_hidden"},
		deco_type = "simple",
		place_on = {"group:flora", "group:flora_sedges", "group:flower_living", "group:soil"},
		sidelen = 16,
		fill_ratio = 0.01,
--		noise_params = {
--			offset = -0.008,
--			scale = 0.016,
--			spread = {x = 120, y = 120, z = 120},
--			seed = 7,
--			octaves = 3,
--			persist = 0.66
--		},
--		biomes = {"unknown"},
		y_max = 100,
		y_min = -10,
		decoration = {modname .. ":bug_hidden"},
	})

---------------------------------------
-----------Blinking Behavior-----------
---------------------------------------
nodecore.register_limited_abm({
		label = "Torchbug Hide",
		nodenames = {modname .. ":bug"},
		interval = 2,
		chance = 10,
		action = function(pos)
			nodecore.set_node(pos, {name = modname .. ":bug_hidden"})
		end
	})

nodecore.register_limited_abm({
		label = "Torchbug Light",
		nodenames = {modname .. ":bug_hidden"},
		interval = 2,
		chance = 10,
		action = function(pos)
			nodecore.set_node(pos, {name = modname .. ":bug"})
		end
	})

---------------------------------------
-----------Movement Behavior-----------
---------------------------------------

