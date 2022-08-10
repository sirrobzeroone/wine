--------------------------------------------
--        __    __ _                      --
--       / / /\ \ (_)_ __   ___           --
--       \ \/  \/ / | '_ \ / _ \          --
--        \  /\  /| | | | |  __/          --
--         \/  \/ |_|_| |_|\___|          --
--------------------------------------------
--           Register recipes             --
--------------------------------------------

-- wine barrel craft recipe (with mineclone2 check)
local ingot = "default:steel_ingot"

if wine.is_mcl then
	ingot = "mcl_core:iron_ingot"
end

minetest.register_craft({
	output = "wine:wine_barrel",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{ingot, "", ingot},
		{"group:wood", "group:wood", "group:wood"},
	},
})

---------------------------
-- Register recipes/brews
-- registers a per glass recipe from below
-- auto registers per bottle recipe as glass values x8
-- Note: very important if second Ingredient not needed use "nil" in quotes
	-- Example Auto Reg Bottle Recipe/Brew for Tequila:
	--
	--					{output = "wine:bottle_tequila", 
	--					 recipe = {"wine:blue_agave 16","nil",true}, 
	--					 water = 200,  
	--					 brew_time  = 800}

--Tequila
wine:add_item({output = "wine:glass_tequila", 
				recipe = {"wine:blue_agave 2","nil",true}, 
				water = 25,  
				brew_time  = 100})	

--Sparkling Agave Juice
wine:add_item({output = "wine:glass_sparkling_agave_juice", 
				recipe = {"wine:blue_agave 1","wine:agave_syrup 1",true}, 
				water = 25,  
				brew_time  = 50})

-- Default
if wine.is_default then
	--Apple Cider
	wine:add_item({output = "wine:glass_cider", 
					recipe = {"default:apple 2","nil",true}, 
					water = 25,  
					brew_time  = 100})
						 
	--Sparkling Apple Juice
	wine:add_item({output = "wine:glass_sparkling_apple_juice", 
					recipe = {"default:apple 2","farming:sugar 1",true}, 
					water = 25,  
					brew_time  = 75})
	
	--Rum
	wine:add_item({output = "wine:glass_rum", 
					recipe = {"default:papyrus 2","nil",true}, 
					water = 25,  
					brew_time  = 100})
end 

-- Mineclone2
if wine.is_mcl then
	--Apple Cider
	wine:add_item({output = "wine:glass_cider", 
					recipe = {"mcl_core:apple 2","nil",true}, 
					water = 25,  
					brew_time  = 100})
			 
	--Sparkling Apple Juice
	wine:add_item({output = "wine:glass_sparkling_apple_juice", 
					recipe = {"mcl_core:apple 2","mcl_core:sugar 1",true}, 
					water = 25,  
					brew_time  = 75})
							 
	--Rum
	wine:add_item({output = "wine:glass_rum", 
					recipe = {"mcl_core:reeds 2","nil",true}, 
					water = 25,  
					brew_time  = 100})
							 
	--Wheat Beer
	wine:add_item({output = "wine:glass_wheat_beer", 
					recipe = {"mcl_farming:wheat_item 1","nil",true}, 
					water = 50,  
					brew_time  = 100})

	--Vodka					 
	wine:add_item({output = "wine:glass_vodka", 
					recipe = {"mcl_farming:potato_item_baked 2","nil",true}, 
					water = 25,  
					brew_time  = 100})
	
	--Sparkling Carrot Juice
	wine:add_item({output = "wine:glass_sparkling_carrot_juice", 
					recipe = {"mcl_farming:carrot_item 1","mcl_core:sugar 1",true}, 
					water = 35,  
					brew_time  = 75})
end

-- Farming
if wine.is_farming then
	--Wheat Beer
	wine:add_item({output = "wine:glass_wheat_beer", 
					recipe = {"farming:wheat 1","nil",true}, 
					water = 50,  
					brew_time  = 100})
end

-- Farming Redo
if wine.is_farming_redo then
	--Wine
	wine:add_item({output = "wine:glass_wine", 
					recipe = {"farming:grapes 3","nil",true}, 
					water = 10,  
					brew_time  = 75})
	
	if minetest.registered_nodes["wine:glass_wine"] then
		-- Brandy, cooked down from Wine
		minetest.register_craft({
			type = "cooking",
			cooktime = 20,
			output = "wine:glass_brandy",
			recipe = "wine:glass_wine"
		})

		-- Brandy, cooked down from Wine
		minetest.register_craft({
			type = "cooking",
			cooktime = 160,
			output = "wine:bottle_brandy",
			recipe = "wine:bottle_wine"
		})
		
		-- Override to add food group to wine and brandy glass	
			minetest.override_item("wine:glass_wine", {
				groups = {
					food_wine = 1, vessel = 1, dig_immediate = 3,
					attached_node = 1, alcohol = 1, drink = 1
				}
			})

			minetest.override_item("wine:glass_brandy", {
				groups = {
					food_brandy = 1, vessel = 1, dig_immediate = 3,
					attached_node = 1, alcohol = 1, drink = 1
				}
			})		
	end
	
	--Beer
	wine:add_item({output = "wine:glass_beer", 
					recipe = {"farming:barley 1","nil",true}, 
					water = 50,  
					brew_time  = 100})
	--Sake					 
	wine:add_item({output = "wine:glass_sake", 
					recipe = {"farming:rice 2","nil",true}, 
					water = 25,  
					brew_time  = 100})

	--Bourbon					 
	wine:add_item({output = "wine:glass_bourbon", 
					recipe = {"farming:corn 2","farming:sugar 1",true}, 
					water = 10,  
					brew_time  = 75})

	--Vodka					 
	wine:add_item({output = "wine:glass_vodka", 
					recipe = {"farming:baked_potato 2","nil",true}, 
					water = 25,  
					brew_time  = 100})

	--Coffee Liquor					 
	wine:add_item({output = "wine:glass_coffee_liquor", 
					recipe = {"wine:glass_rum 1","farming:coffee_beans 1",false}, 
					water = 10,  
					brew_time  = 75})
						 
	--Champagne					 
	wine:add_item({output = "wine:glass_champagne", 
					recipe = {"wine:glass_wine 1","farming:sugar 1",false}, 
					water = 10,  
					brew_time  = 75})
	
	--Sparkling Carrot Juice
	wine:add_item({output = "wine:glass_sparkling_carrot_juice", 
					recipe = {"farming:carrot_juice 1","farming:sugar 1",false}, 
					water = 10,  
					brew_time  = 50})

	--Sparkling Blackberry Juice
	wine:add_item({output = "wine:glass_sparkling_blackberry_juice", 
					recipe = {"farming:blackberry 2","farming:sugar 1",true}, 
					water = 35,  
					brew_time  = 75})
						 
	-- Mixers 
		-- Mint Julep recipe
		minetest.register_craft({
			output = "wine:glass_mint",
			recipe = {
				{"farming:mint_leaf", "farming:mint_leaf", "farming:mint_leaf"},
				{"wine:glass_bourbon", "farming:sugar", ""}
			}
		})	
end

-- Mobs
if wine.is_mobs_animal then
	--Mead
	wine:add_item({output = "wine:glass_mead", 
					recipe = {"mobs:honey 1","nil",true}, 
					water = 50,  
					brew_time  = 100})
	
	--Kefir (Fermented Milk Drink)
	wine:add_item({output = "wine:glass_kefir", 
					recipe = {"mobs:glass_milk 1","nil",false}, 
					water = 10,  
					brew_time  = 75})
end

-- Xdecor
if wine.is_xdecor then
	--Mead
	wine:add_item({output = "wine:glass_mead", 
					recipe = {"xdecor:honey 1","nil",true}, 
					water = 50,  
					brew_time  = 100})
end

