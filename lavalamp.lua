-- LUALOCALS < ---------------------------------------------------------
local  minetest, nodecore
	= minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local lava = "nc_terrain_lava.png^[verticalframe:32:8"
local pumice = "nc_igneous_pumice.png"
local skin = "nc_lode_annealed.png^[colorize:darkorange:50"
local hot = "nc_lode_hot.png^[colorize:darkorange:50"
local fireface = "(" ..lava.. ")^[mask:wc_naturae_mask_pumpkin.png"
local icemask = "(" ..pumice.. ")^[mask:wc_naturae_mask_pumpkin.png"
local hotface = "(" ..hot.. ")^(" ..fireface.. ")"
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
		snappy = 1
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
		igniter = 1
		},
	stack_max = 1,
	sounds = nodecore.sounds("nc_terrain_bubbly"),
})

