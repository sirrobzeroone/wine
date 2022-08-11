--------------------------------------------
--        __    __ _                      --
--       / / /\ \ (_)_ __   ___           --
--       \ \/  \/ / | '_ \ / _ \          --
--        \  /\  /| | | | |  __/          --
--         \/  \/ |_|_| |_|\___|          --
--------------------------------------------
--       MIT License 2016 TenPlus1        --
--  Images CC-By-3.0 by ref License.txt   --
--------------------------------------------

-- Modname and Path
local m_name = minetest.get_current_modname()
local m_path = minetest.get_modpath(m_name)

-- Global table and settings
wine = {}
wine.reg_alcohol = minetest.settings:get("register_alcohol") or true
wine.barrel_water_max = minetest.settings:get("barrel_water_max") or 2000
wine.bucket_refill_amt = minetest.settings:get("bucket_refill_amt") or 400
wine.allow_brew_bottle = minetest.settings:get("allow_brew_bottle") or false
wine.bottle_rec_multi = minetest.settings:get("bottle_rec_multi") or 8
wine.registered_brews = {}


--default
wine.is_default = minetest.get_modpath("default")
wine.barrel_texture = "wine_barrel.png"
wine.snd_d = wine.is_default and default.node_sound_defaults()
wine.snd_g = wine.is_default and default.node_sound_glass_defaults()
wine.snd_l = wine.is_default and default.node_sound_leaves_defaults()
wine.agave_biomes = {"desert"}
wine.sand  = "default:desert_sand"
wine.glass = "default:glass"
wine.paper = "default:paper"
wine.water_refill = {{"bucket:bucket_water", wine.bucket_refill_amt, "bucket:bucket_empty"},
					 {"bucket_wooden:bucket_water", wine.bucket_refill_amt, "bucket_wooden:bucket_empty"}}

--MineClone2
wine.is_mcl = minetest.get_modpath("mcl_core")

if wine.is_mcl then
	-- wine_barrel_mcl.png based on mineclone2 barrel textures
	-- CC BY-SA 4.0 - Pixel Perfection - XSSheep
	-- https://www.planetminecraft.com/texture_pack/131pixel-perfection/
	wine.barrel_texture = "wine_barrel_mcl.png"
	wine.snd_d = mcl_sounds.node_sound_glass_defaults()
	wine.snd_g = mcl_sounds.node_sound_defaults()
	wine.snd_l = mcl_sounds.node_sound_leaves_defaults()
	wine.agave_biomes = {"desert"}
	wine.sand =  "mcl_core:sand"
	wine.glass = "mcl_core:glass"
	wine.paper = "mcl_core:paper"
	wine.water_refill = {}
	wine.water_refill = {{"mcl_buckets:bucket_water", wine.bucket_refill_amt, "mcl_buckets:bucket_empty"}}
end

-- Optional mod checks
wine.is_uninv       = minetest.get_modpath("unified_inventory")
wine.is_thirsty     = minetest.get_modpath("thirsty")
wine.is_vessels     = minetest.get_modpath("vessels")
wine.is_lucky_block = minetest.get_modpath("lucky_block")
wine.is_bonemeal    = minetest.get_modpath("bonemeal")
wine.is_xdecor      = minetest.get_modpath("xdecor")
wine.is_mobs_animal = minetest.get_modpath("mobs_animal")
wine.is_ethereal    = minetest.get_modpath("ethereal")
wine.is_hopper      = minetest.get_modpath("hopper")
wine.is_farming     = minetest.get_modpath("farming")
	-- farming redo
	if minetest.get_modpath("farming") and
	   farming.mod and 
	   (farming.mod == "undo" or farming.mod == "redo") then
		wine.is_farming_redo = minetest.get_modpath("farming")
	end
	
-- Unified Inventory Integration
if wine.is_uninv then
	unified_inventory.register_craft_type("barrel", {
		description = "Barrel",
		icon = 'barrel_icon.png',
		width = 3,
		height = 1
	})
end

-- Hopper Integration
if wine.is_hopper then	
	hopper:add_container({
		{"top", "wine:wine_barrel", "dst"},
		{"bottom", "wine:wine_barrel", "src_1"},
		{"side", "wine:wine_barrel", "src_2"},
		{"void", "wine:wine_barrel", "src_g"}
	})
end

-- files
dofile(m_path .. "/i_functions.lua")
dofile(m_path .. "/i_empty_glass_bottle.lua")
dofile(m_path .. "/i_reg_nodes.lua")
dofile(m_path .. "/i_reg_recipes.lua")
dofile(m_path .. "/i_agave.lua")

if wine.is_lucky_block then
	dofile(m_path .. "/i_lucky_block.lua")
end

-- LBMs to start timers on existing, ABM-driven nodes
minetest.register_lbm({
	name = "wine:barrel_timer_init",
	nodenames = {"wine:wine_barrel"},
	run_at_every_load = false,
	action = function(pos)

		local t = minetest.get_node_timer(pos)

		t:start(5)
	end,
})

minetest.register_lbm({
	name = "wine:agave_timer_init",
	nodenames = {"wine:blue_agave"},
	run_at_every_load = false,
	action = function(pos)

		local t = minetest.get_node_timer(pos)

		t:start(17)
	end,
})

print ("[MOD] Wine loaded")

--minetest.debug(dump(wine.registered_brews))