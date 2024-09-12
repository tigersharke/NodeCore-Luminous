-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
	= minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()

local txr_sides = "(nc_lode_annealed.png^[mask:nc_tote_sides.png)"
local txr_handle = "(nc_lode_annealed.png^nc_tote_knurl.png)"
local txr_top = txr_handle .. "^[transformFX^[mask:nc_tote_top.png^[transformR90^" .. txr_sides
local txr_core = "(wc_crystals.png^[colorize:#00a86b:180)^wc_naturae_mycelium.png"
------------------------------------------------------------------------

minetest.register_node(modname .. ":lantern_shroomite", {
	description = "Shroomite Lantern",
	drawtype = "mesh",
	visual_scale = nodecore.z_fight_ratio,
	mesh = "nc_tote_handle.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {
		txr_sides,
		txr_sides,
		txr_top,
		txr_handle,
		txr_core
	},
	backface_culling = true,
	use_texture_alpha = "clip",
	groups = {
		snappy = 1,
		totable = 1,
		scaling_time = 50,
		lux_absorb = 30,
		lux_emit = 1,
		stack_as_node = 1,
		falling_node = 1,
	},
	light_source = 12,
	stack_max = 1,
	sunlight_propagates = true,
	sounds = nodecore.sounds("nc_lode_annealed")
})

------------------------------------------------------------------------

nodecore.register_craft({
		label = "assemble shroomite lantern",
		normal = {x = 1},
		indexkeys = {"wc_crystals:shroomite"},
		nodes = {
			{match =  "wc_crystals:shroomite", replace = "air"},
			{x = -1, match = "nc_tote:handle", replace = modname .. ":lantern_shroomite"},
		}
	})

nodecore.register_craft({
		label = "break apart shroomite lantern",
		action = "pummel",
		toolgroups = {choppy = 5},
		indexkeys = {"wc_luminous:lantern_shroomite"},
		nodes = {
			{match = "wc_luminous:lantern_shroomite", replace = "air"}
		},
		items = {
			{name = "nc_lode:bar_annealed 2", count = 4, scatter = 5},
			{name = "wc_crystals:shroomite_crystal", count = 3, scatter = 5}
		}
	})
