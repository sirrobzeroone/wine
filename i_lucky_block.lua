--------------------------------------------
--        __    __ _                      --
--       / / /\ \ (_)_ __   ___           --
--       \ \/  \/ / | '_ \ / _ \          --
--        \  /\  /| | | | |  __/          --
--         \/  \/ |_|_| |_|\___|          --
--------------------------------------------
--             Lucky Block                --
--------------------------------------------
-- Lucky Block will filter any unregistered nodes/items
lucky_block:purge_block_list()
	lucky_block:add_blocks({
		{"fal", {"default:water_source"}, 1, true, 4},
		{"dro", {"wine:glass_wine"}, 5},
		{"dro", {"wine:glass_beer"}, 5},
		{"dro", {"wine:glass_wheat_beer"}, 5},
		{"dro", {"wine:glass_mead"}, 5},
		{"dro", {"wine:glass_cider"}, 5},
		{"dro", {"wine:glass_rum"}, 5},
		{"dro", {"wine:glass_sake"}, 5},
		{"dro", {"wine:glass_tequila"}, 5},
		{"dro", {"wine:glass_bourbon"}, 5},
		{"dro", {"wine:glass_vodka"}, 5},
		{"dro", {"wine:glass_mint"}, 5},
		{"dro", {"wine:glass_coffee_liquor"}, 5},
		{"dro", {"wine:glass_brandy"}, 5},
		{"dro", {"wine:glass_champagne"}, 5},
		{"dro", {"wine:glass_sparkling_agave_juice"}, 5},
		{"dro", {"wine:glass_sparkling_apple_juice"}, 5},
		{"dro", {"wine:glass_sparkling_carrot_juice"}, 5},
		{"dro", {"wine:glass_sparkling_blackberry_juice"}, 5},
		{"dro", {"wine:glass_kefir"}, 5},
		{"dro", {"wine:wine_barrel"}, 1},
		{"tel", 5, 1},
		{"nod", "default:chest", 0, {
			{name = "wine:bottle_wine", max = 1},
			{name = "wine:bottle_tequila", max = 1},
			{name = "wine:bottle_rum", max = 1},
			{name = "wine:bottle_cider", max = 1},
			{name = "wine:bottle_bourbon", max = 1},
			{name = "wine:bottle_vodka", max = 1},
			{name = "wine:wine_barrel", max = 1},
			{name = "wine:bottle_sake", max = 1},
			{name = "wine:bottle_mint", max = 1},
			{name = "wine:bottle_mead", max = 1},
			{name = "wine:bottle_beer", max = 1},
			{name = "wine:bottle_wheat_beer", max = 1},
			{name = "wine:bottle_coffee_liquor", max = 1},
			{name = "wine:bottle_brandy", max = 1},
			{name = "wine:bottle_champagne", max = 1},
			{name = "wine:bottle_sparkling_agave_juice", max = 1},
			{name = "wine:bottle_sparkling_apple_juice", max = 1},
			{name = "wine:bottle_sparkling_carrot_juice", max = 1},
			{name = "wine:bottle_sparkling_blackberry_juice", max = 1},
			{name = "wine:bottle_kefir", max = 1},			
			{name = "wine:blue_agave", max = 4}}},
	})