--------------------------------------------
--        __    __ _                      --
--       / / /\ \ (_)_ __   ___           --
--       \ \/  \/ / | '_ \ / _ \          --
--        \  /\  /| | | | |  __/          --
--         \/  \/ |_|_| |_|\___|          --
--------------------------------------------
--            Register Nodes              --
--------------------------------------------
local S = wine.intllib()

----------------------------------
-- Register Glass and Bottle Nodes
-- Create Table
local beverages = {}

-- list of beverages (name, desc, has bottle, hunger, thirst)
table.insert(beverages,	{"tequila", "Tequila", true, 2, 3, 1})
table.insert(beverages, {"sparkling_agave_juice", "Sparkling Agave Juice", true, 1, 4, 0})
	
if wine.is_default then
	table.insert(beverages,{"cider", "Cider", true, 2, 6, 1})
	table.insert(beverages,{"sparkling_apple_juice", "Sparkling Apple Juice", true, 2, 5, 0})
	table.insert(beverages,{"rum", "Rum", true, 2, 5, 1})
end

if wine.is_mcl then
	table.insert(beverages,{"cider", "Cider", true, 2, 6, 1})
	table.insert(beverages,{"sparkling_apple_juice", "Sparkling Apple Juice", true, 2, 5, 0})
	table.insert(beverages,{"rum", "Rum", true, 2, 5, 1})
	table.insert(beverages,{"wheat_beer", "Wheat Beer", true, 2, 8, 1})
	table.insert(beverages,{"vodka", "Vodka", true, 2, 3, 1})
	table.insert(beverages,{"sparkling_carrot_juice", "Sparkling Carrot Juice", true, 3, 4, 0})	
end

if wine.is_farming then
	table.insert(beverages,{"wheat_beer", "Wheat Beer", true, 2, 8, 1})
end

if wine.is_farming_redo then
	table.insert(beverages,{"wine", "Wine", true, 2, 5, 1})
	table.insert(beverages,{"brandy", "Brandy", true, 3, 4, 1})
	table.insert(beverages,{"beer", "Beer", true, 2, 8, 1})
	table.insert(beverages,{"sake", "Sake", true, 2, 3, 1})
	table.insert(beverages,{"bourbon", "Bourbon", true, 2, 3, 1})
	table.insert(beverages,{"vodka", "Vodka", true, 2, 3, 1})
	table.insert(beverages,{"coffee_liquor", "Coffee Liquor", true, 3, 4, 1})
	table.insert(beverages,{"champagne", "Champagne", true, 4, 5, 1})
	table.insert(beverages,{"sparkling_carrot_juice", "Sparkling Carrot Juice", true, 3, 4, 0})	
	table.insert(beverages,{"sparkling_blackberry_juice", "Sparkling Blackberry Juice", true, 2, 4, 0})
	table.insert(beverages,{"mint", "Mint Julep", true, 4, 3, 1})
end

if wine.is_mobs_animal then
	table.insert(beverages,{"mead", "Honey-Mead", true, 4, 5, 1})
	table.insert(beverages,{"kefir", "Kefir", true, 4, 4, 0})
end

if wine.is_xdecor and not wine.is_mobs then
	table.insert(beverages,{"mead", "Honey-Mead", true, 4, 5, 1})
end

-- Register glasses and bottles
for n = 1, #beverages do

	local name = beverages[n][1]
	local desc = beverages[n][2]
	local has_bottle = beverages[n][3]
	local num_hunger = beverages[n][4]
	local num_thirst = beverages[n][5]
	local alcoholic = beverages[n][6]
	
	wine:add_drink(name, desc, has_bottle, num_hunger, num_thirst, alcoholic)
end

---------------------------------------
-- Register Fermentation/Brewing Barrel

minetest.register_node("wine:wine_barrel", {
	description = S("Fermenting Barrel"),
	tiles = {wine.barrel_texture},
	drawtype = "mesh",
	mesh = "wine_barrel.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {
		choppy = 2, oddly_breakable_by_hand = 1, flammable = 2,
		tubedevice = 1, tubedevice_receiver = 1
	},
	legacy_facedir_simple = true,

	on_place = minetest.rotate_node,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)		
		meta:set_int("cur_cnt", 0)
		meta:set_int("cur_cnt_end", 0)
		meta:set_int("water_store",0)
		meta:set_int("catchup",0)
		meta:set_string("version", wine.version)
		meta:set_string("brewing", "")
		meta:set_string("infotext", S("Fermenting Barrel"))
		meta:set_string("formspec", wine.winebarrel_formspec(pos))
		
		local inv = meta:get_inventory()
		inv:set_size("src", 4)
		inv:set_size("src_g", 1)
		inv:set_size("src_b", 1)
		inv:set_size("dst", 1)
	end,

	can_dig = function(pos,player)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if not inv:is_empty("dst")
		or not inv:is_empty("src") 
		or not inv:is_empty("src_g") 
		or not inv:is_empty("src_b") then
			return false
		end

		return true
	end,

	allow_metadata_inventory_take = function(
			pos, listname, index, stack, player)

		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return stack:get_count()
	end,

	allow_metadata_inventory_put = function(
			pos, listname, index, stack, player)

		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if listname == "src" or 
		   listname == "src_g" then 
		   
			return stack:get_count()
			
		elseif listname == "src_b" then
			local is_water
			for _,def in ipairs(wine.water_refill) do			
				if def[1] == stack:get_name() then
					
					is_water = true			

					break
				end			
			end
			
			if is_water then
				return stack:get_count()
			else
				return 0
			end
			
		elseif listname == "dst" then
			return 0
		
		end
	end,

	allow_metadata_inventory_move = function(
			pos, from_list, from_index, to_list, to_index, count, player)

		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)

		if from_list == "src" or to_list == "src" or
		   from_list == "src_g" or to_list == "src_g" or 
		   from_list == "src_b" or to_list == "src_b"then
			return count
		
		elseif to_list == "dst" then
			return 0
		else
			return 0			
		end
	end,
	
	on_metadata_inventory_put = function(pos)		
		
		local timer = minetest.get_node_timer(pos)		
		local meta = minetest.get_meta(pos)
		local node_inv = meta:get_inventory()
		local is_water = false
		
		for _,def in ipairs(wine.water_refill) do			
			if def[1] == node_inv:get_stack("src_b", 1):get_name() then
				
				is_water = true			

				break
			end			
		end
		
		if is_water then
			local water_store = meta:get_int("water_store")				
			local new_water_store = wine.process_water_bucket(water_store,node_inv,pos)
			
			meta:set_int("water_store",new_water_store)
			meta:set_string("formspec",wine.winebarrel_formspec(pos))
		end
		
		if not timer:is_started() then			
			minetest.get_node_timer(pos):start(5)
		end
	end,

	on_metadata_inventory_move = function(pos)
		local timer = minetest.get_node_timer(pos)
		
		if not timer:is_started() then			
			minetest.get_node_timer(pos):start(5)
		end		
	end,

	on_metadata_inventory_take = function(pos)
		local timer = minetest.get_node_timer(pos)
		
		if not timer:is_started() then			
			minetest.get_node_timer(pos):start(5)
		end	
	end,
	
	tube = (function() if minetest.get_modpath("pipeworks") then return {
		
		-- using a different stack from default when inserting
		insert_object = function(pos, node, stack, direction)
			-- for consistancy I have matched sides with hopper rules (as close as possible) 
			-- so in the case both mods are active we aren't torturing our players.
			-- remeber top/bottom are reversed as in hopper it's relative to hopper
			-- below is relative to our barrel node.
			
			local incoming_side
			
			-- Conversion, more for readability (sorry no void pipes)
			if direction.y == -1 then 
				incoming_side = "top"
				
			elseif math.abs(direction.x) == 1 or 
				   math.abs(direction.z) == 1 then 
				incoming_side = "side"			
			end
			
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local timer = minetest.get_node_timer(pos)

			if not timer:is_started() then
				timer:start(5)
			end
			
			if incoming_side == "top" then
				return inv:add_item("src_g", stack)
				
			elseif incoming_side == "side" then
				return inv:add_item("src", stack)
				
			end
			
		end,

		can_insert = function(pos,node,stack,direction)
			-- for consistancy I have matched sides with hopper rules (as close as possible) 
			-- so in the case both mods are active we aren't torturing our players.
			-- remeber top/bottom are reversed as in hopper it's relative to hopper
			-- below is relative to our barrel node.
			
			local incoming_side
			
			-- Conversion, more for readability
			if direction.y == -1 then 
				incoming_side = "top"
				
			elseif math.abs(direction.x) == 1 or 
				   math.abs(direction.z) == 1 then 
				incoming_side = "side"
			end
			
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			
			if incoming_side == "top" then
				return inv:room_for_item("src_g", stack)
				
			elseif incoming_side == "side" then
				return inv:room_for_item("src", stack)
				
			end			
		end,

		-- the default stack, from which objects will be taken
		input_inventory = "dst",
		connect_sides = {
			left = 1, right = 1, back = 1,
			front = 1, bottom = 1, top = 1}	} end end)(),

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)			
		local meta = minetest.get_meta(pos);		
		local is_water = false
		local refill_amt = 0
		local empty_cont = ""
		
		-- this is(maybe was)the offical way to close node formspec - blank it
		-- https://github.com/minetest/minetest/pull/4675#issuecomment-257179262
		-- still results in a flicker of the underlying formspec before blanking.
		meta:set_string("formspec", "")
		
		-- Convert Check for Wine V2.0
		local barrel_ver = tonumber(meta:get_string("version"))
		if not barrel_ver then
			barrel_ver = 0
		end
		
		if barrel_ver < wine.version then
			wine.timer_valid_inv(meta)		
			-- Refresh meta after update
			meta = minetest.get_meta(pos)
		end
				
		for _ , def in ipairs(wine.water_refill) do			
			if def[1] == itemstack:get_name() then
				is_water = true
				refill_amt = def[2]
				empty_cont = def[3]
				break
			end			
		end
		
		if is_water then
			local cur_water_level = meta:get_int("water_store")			
			local new_water_level = cur_water_level + refill_amt
			
			if new_water_level > wine.barrel_water_max then
				new_water_level = wine.barrel_water_max
			end
				
			meta:set_int("water_store",new_water_level)
			
			-- return empty, supports stackable and non-stackable items
			local s_max = itemstack:get_stack_max()	
			itemstack:take_item()
			
			-- in mineclone2 player:set_wield_item() wont work
			-- conflict with mcl custom bucket code maybe?
			if not wine.is_mcl and s_max == 1 then 				
				
				player:set_wielded_item(empty_cont.." 1")
				
			else 
				local inv = player:get_inventory()
				
				if inv:room_for_item("main", empty_cont.." 1") then
					inv:add_item("main", empty_cont.." 1")						
				else
					minetest.item_drop(empty_cont.." 1", player, player:get_pos())				
				end				
			end
			
			-- Start timer to check if we can brew
			minetest.get_node_timer(pos):start(5)
			
			-- restore the formspec - if it's not done here there 
			-- can be an empty click when next clicking without water item
			minetest.after(0.2, function() 
				meta:set_string("formspec", wine.winebarrel_formspec(pos))
			end)		
		else
			meta:set_string("formspec", wine.winebarrel_formspec(pos))
		end	
	end,

	on_timer = wine.timer_barrel,
})