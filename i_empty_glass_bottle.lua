--------------------------------------------
--        __    __ _                      --
--       / / /\ \ (_)_ __   ___           --
--       \ \/  \/ / | '_ \ / _ \          --
--        \  /\  /| | | | |  __/          --
--         \/  \/ |_|_| |_|\___|          --
--------------------------------------------
--        Empty Glasses and Bottles       --
--------------------------------------------

local S = wine.intllib()
local glass = wine.glass

--  Vessels/mcl support or use internal bottle/drink glass
if wine.is_vessels then
	wine.empty_bottle = "vessels:glass_bottle"
	wine.empty_glass = "vessels:drinking_glass"	
else
	if wine.is_mcl then
		-- note mcl has no empty_glass
		wine.empty_bottle = "mcl_potions:glass_bottle"	
	else
		wine.empty_bottle = "vessels:glass_bottle"
		
		-- register bottle - use vessels override mod name, saves an alias
			minetest.register_node(":vessels:glass_bottle", {
			description = S("Empty Glass Bottle"),
			drawtype = "plantlike",
			tiles = {"wine_glass_bottle.png"},
			inventory_image = "wine_glass_bottle.png",
			wield_image = "wine_glass_bottle.png",
			paramtype = "light",
			is_ground_content = false,
			walkable = false,
			selection_box = {
				type = "fixed",
				fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
			},
			groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
			sounds = default.node_sound_glass_defaults(),
		})

		minetest.register_craft( {
			output = "vessels:glass_bottle 10",
			recipe = {
				{glass, ""   , glass},
				{glass, ""   , glass},
				{""   , glass, ""   }
			}
		})
	end	
	
	wine.empty_glass = "vessels:drinking_glass"
	-- register empty_glass - use vessels override mod name, saves an alias
	
		minetest.register_node(":vessels:drinking_glass", {
		description = S("Empty Drinking Glass"),
		drawtype = "plantlike",
		tiles = {"wine_drinking_glass.png"},
		inventory_image = "wine_drinking_glass.png",
		wield_image = "wine_drinking_glass.png",
		paramtype = "light",
		is_ground_content = false,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
		},
		groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
		sounds = wine.snd_g,
		})

	minetest.register_craft( {
		output = "vessels:drinking_glass 14",
		recipe = {
			{glass, ""  ,glass},
			{glass, ""  ,glass},
			{glass,glass,glass}
		}
		})
end