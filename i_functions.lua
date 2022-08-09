--------------------------------------------
--        __    __ _                      --
--       / / /\ \ (_)_ __   ___           --
--       \ \/  \/ / | '_ \ / _ \          --
--        \  /\  /| | | | |  __/          --
--         \/  \/ |_|_| |_|\___|          --
--------------------------------------------
--               Functions                --
--------------------------------------------
-----------------------------
-- Intllib support
function wine.intllib()
	local intllib
	if minetest.get_translator then
		intllib = minetest.get_translator("wine")
	elseif minetest.get_modpath("intllib") then
		intllib = intllib.Getter()
	else
		intllib = function(s, a, ...)
			if a == nil then
				return s
			end
			a = {a, ...}
			return s:gsub("(@?)@(%(?)(%d+)(%)?)",
				function(e, o, n, c)
					if e == ""then
						return a[tonumber(n)] .. (o == "" and c or "")
					else
						return "@" .. o .. n .. c
					end
				end)
		end
	end
	return intllib
end

-----------------------------
-- Wine barrel formspec
function wine.winebarrel_formspec(pos)
	
	local meta          = minetest.get_meta(pos)
	local brewing       = meta:get_string("brewing")
	local brewing_des   = ""
	local mcl_m_inv_c   = ""						-- mineclone normal inventory slot color
	local mcl_b_inv_c   = ""						-- mineclone barrel inventory slot color
	local mcl_cont_off  = 0
	local main_inv_loc  = "0.25,5;8,1;0"
	local main_inv_loc2 = "0.25,6.5;8,3;8"
	local cur_cnt       = meta:get_int("cur_cnt") or 0
	local cur_cnt_end   = meta:get_int("cur_cnt_end") or 0
	local inv           = meta:get_inventory()	
	local water_max     = wine.barrel_water_max
	local water_store   = meta:get_int("water_store")
	local fin_per       = math.floor((cur_cnt/cur_cnt_end)*100)
	local water_per     = math.ceil((water_store/water_max)*100)
	
	-- catch "nan" - nan never equals nan	
	if fin_per ~= fin_per then fin_per = 0 end
	
	-- get brewing name
	if minetest.registered_nodes[brewing] then
		brewing_des = minetest.registered_nodes[brewing].description
	end
	
	-- tooltip text
	local S               = wine.intllib()
	local tt_ing_1 		  = S("Ingredient One")
	local tt_ing_2 		  = S("Ingredient Two \n    (Optional)")
	local tt_water_stored = S("Avaliable Water")
	local tt_empty_bg     = S("Empty Glass or Bottle")
	local tt_finish_p     = S("Fermenting Barrel (@1% Done)", fin_per)
	local cur_brew        = S("Brewing: ")..brewing_des
	
	-- mineclone2 
	if wine.is_mcl then
		-- listcolors[<slot_bg_normal>;<slot_bg_hover>;<slot_border>]
		mcl_m_inv_c      = "listcolors[#9d9d9d;#FFF7;#474747]"
		mcl_b_inv_c      = "listcolors[#3a2e1a;#876b3e;#222222]"
		mcl_cont_off     = 0.65
		main_inv_loc     = "0.25,9;9,1;0"
		main_inv_loc2    = "0.25,5;9,3;9"
	end
	
	local form = "formspec_version[4]"
		.. "size[".. (10.25 + (mcl_cont_off*2)) ..",10.25]"
		.. "container["..mcl_cont_off..",0]"
		.. "image[0.25,0.25;5.5,4.25;wine_barrel_fs_bg.png]"
		.. "style_type[list;size=0.85,0.85;spacing=0.25,0.1]"
		.. mcl_b_inv_c
		.. "list[current_name;src_1;1.7,0.85;1,2;0]"
		.. "list[current_name;src_2;3.5,0.85;1,2;0]"
		.. "style_type[list;size=1,1;spacing=0.25,0.25]"
		.. mcl_m_inv_c
		.. "list[current_name;src_g;6.1,2;1,1;0]"
		.. "list[current_name;dst;8.7,2;1,1;0]"
		.. "image[1.26,2.8;3.495,1.45;wine_barrel_water.png^[colorize:#261c0e:175^[opacity:125" --
		.. "^[lowpart:"..water_per..":wine_barrel_water.png]"
		.. "image[7.4,2;1,1;barrel_icon_bg.png^[lowpart:"..fin_per..":barrel_icon.png]"
		.. "tooltip[1.7,0.65;1,2.2;"..tt_ing_1.."]"
		.. "tooltip[3.5,0.65;1,2.2;"..tt_ing_2.."]"		
		.. "tooltip[1.26,2.8;3.495,1.45;"..tt_water_stored..": "..water_per.."%]"
		.. "tooltip[6.1,2;1,1;"..tt_empty_bg.."]"		
		.. "tooltip[7.35,2;1,1;"..cur_brew.."\n"..tt_finish_p.."]"
		.. "container_end[]"
		.. "list[current_player;main;"..main_inv_loc.."]"
		.. "list[current_player;main;"..main_inv_loc2.."]"
		
	return form
end

-----------------------------
-- legacy wine:add_item() support
function wine:add_item_l(list)	
	for n = 1, #list do
		-- basic data structure check
		if list[n][1] and list[n][2] then
					
			wine.register_brew({ 
				output = list[n][2], 
				recipe = {list[n][1].." 1","nil",true}, 
				water = 25,  
				brew_time  = 100})
				
			minetest.log("warning", "[Wine MOD]: wine:add_item - "
						.. "items added using old format, item: "..list[n][2])
		end
	end
end

-----------------------------
-- register drink and recipe
--[[def_table = {output = reg_wine_node, 
				 recipe = {ing_1,ing_2,glass-bool}, 
				 water = amount,  
				 time  = seconds}
]]
function wine:add_item(def_table)

	local req_glass  = wine.empty_glass
	local req_bottle = wine.empty_bottle
	local bot_multi  = wine.bottle_rec_multi
		
	-- Start old wine:add_item catch
	if not def_table.output then
		wine:add_item_l(def_table)
		return
	end
	
	-- Catch Exceptions
	if type(def_table) ~= "table" then
		minetest.log("warning", "[Wine MOD]: wine:add_item - "
					.. "Incorrect add_item structure")
		return
	end
	
	if not minetest.registered_nodes[def_table.output] then
		-- made this mistake myself at one point (typo) ended 
		-- up with unknown items being outputted - not good.
		minetest.log("warning", "[Wine MOD]: wine:add_item - "
			.. "output not registered: "..def_table.output)
		return
	end
	
	if not wine.reg_alcohol and 
	   minetest.get_item_group(def_table.output, "alcohol") > 0 then
		return
	end
	
	-- Convert not required Glass/Bottle to nil
	if not def_table.recipe[3] then
		req_glass = nil
		req_bottle = nil
	end
	
	-- Convert ingredient_2 from nil or "" to "nil"
	-- Partial workaround so we can still use 
	-- inv:contains_item() in wine.get_recipe()
	if not def_table.recipe[2] or def_table.recipe[2] == "" then
		def_table.recipe[2] = "nil" 
	end
	
	-- Register single glass recipe
	table.insert(wine.registered_brews,{ing_1 = def_table.recipe[1],
										ing_2 = def_table.recipe[2],
										vessel = req_glass,
										water_used = def_table.water,
										brew_time = def_table.brew_time,
										output = def_table.output})

	-- Bottle recipe registration 
	-- calculations essentially 8x glass - 1 free glass for efficency	
	local is_bottle = minetest.registered_nodes[def_table.output:gsub("glass","bottle")]
	local ing_1_bot_fin
	local ing_2_bot_fin
	local reg_bottle = false
	
	-- Check if output bottle is registered
	if is_bottle then
		-- Multiply ingredient_1
		local ing_1_name = ItemStack(def_table.recipe[1]):get_name()
		local ing_1_amt = ItemStack(def_table.recipe[1]):get_count()
		ing_1_bot_fin = ing_1_name.." "..(ing_1_amt*bot_multi)
		
		--Multiply ingredient_2 if present
		if def_table.recipe[2] ~= "nil" then
			local ing_2_name = ItemStack(def_table.recipe[2]):get_name()
			local ing_2_amt = ItemStack(def_table.recipe[2]):get_count()
			ing_2_bot_fin = ing_2_name.." "..(ing_2_amt*bot_multi)
		else
			ing_2_bot_fin = "nil"		
		end
		
		-- check for glass item as ingredient and replace with bottle
		-- As external mod may provide glass ingredient but the mod registers 
		-- no bottle version of the item we need to check that a bottle 
		-- version is registered - example mobs:glass_milk.
		if not req_bottle then			
			if string.find(ing_1_bot_fin, "glass") then
				ing_1_bot_fin = ing_1_bot_fin:gsub("glass","bottle")
				
				if minetest.registered_nodes[ItemStack(ing_1_bot_fin):get_name()] then
					reg_bottle = true
				end
			end
			
			if ing_2_bot_fin and string.find(ing_2_bot_fin, "glass") then
				ing_2_bot_fin = ing_2_bot_fin:gsub("glass","bottle")
				  
				if minetest.registered_nodes[ItemStack(ing_2_bot_fin):get_name()] then
					reg_bottle = true
				end
			end
		else
			reg_bottle = true
		end
		
		if reg_bottle then
			table.insert(wine.registered_brews,{ing_1 = ing_1_bot_fin,
											   ing_2 = ing_2_bot_fin,
											   vessel = req_bottle,
											   water_used = (def_table.water*bot_multi),
											   brew_time = (def_table.brew_time*bot_multi),
											   output = def_table.output:gsub("glass","bottle")})
		end
	end

	-- unified Inventory Support
	if wine.is_uninv then	
		
		-- change text "nil" to real nil
		if def_table.recipe[2] == "nil" then
			def_table.recipe[2] = nil
			ing_2_bot_fin = nil
		end
	
		-- glass
		unified_inventory.register_craft({
			type = "barrel",
			items = {def_table.recipe[1], def_table.recipe[2], req_glass},
			output = def_table.output
		})
		
		--bottle
		-- is_bottle = output, reg_bottle = bottle as ingredient
		if is_bottle and reg_bottle then
			unified_inventory.register_craft({
				type = "barrel",
				items = {ing_1_bot_fin, ing_2_bot_fin, req_bottle},
				output = def_table.output:gsub("glass","bottle")
			})
		end
	end
end 

-----------------------------
-- add drink with bottle
function wine:add_drink(name, desc, has_bottle, num_hunger, num_thirst, alcoholic)
	 
	local S = wine.intllib()
	 -- catch legacy registrations
	if not alcoholic then alcoholic = 1 end
	
	if not wine.reg_alcohol and alcoholic == 1 then
		return
	end
	
	--------------------	
	-- register glass
	minetest.register_node("wine:glass_" .. name, {
		description = S("Glass of " .. desc),
		drawtype = "plantlike",
		visual_scale = 0.5,
		tiles = {"wine_" .. name .. "_glass.png"},
		inventory_image = "wine_" .. name .. "_glass.png",
		wield_image = "wine_" .. name .. "_glass.png",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = {-0.15, -0.5, -0.15, 0.15, 0, 0.15}
		},
		groups = {
			vessel = 1, dig_immediate = 3,
			attached_node = 1, drink = 1, alcohol = alcoholic
		},
		sounds = wine.snd_g,
		on_use = function(itemstack, user, pointed_thing)

			if user then

				if wine.is_thirsty then
					thirsty.drink(user, num_thirst)
				end

				return minetest.do_item_eat(num_hunger, nil,
						itemstack, user, pointed_thing)
			end
		end
	})
	--------------------
	-- register bottle
	if has_bottle then

		minetest.register_node("wine:bottle_" .. name, {
			description = S("Bottle of " .. desc),
			drawtype = "plantlike",
			visual_scale = 0.7,
			tiles = {"wine_" .. name .. "_bottle.png"},
			inventory_image = "wine_" .. name .. "_bottle.png",
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			selection_box = {
				type = "fixed",
				fixed = {-0.15, -0.5, -0.15, 0.15, 0.25, 0.15}
			},
			groups = {dig_immediate = 3, attached_node = 1, vessel = 1},
			sounds = wine.snd_d,
		})

		local glass_n = "wine:glass_" .. name
		
		minetest.register_craft({
			output = "wine:bottle_" .. name,
			recipe = {
				{glass_n, glass_n, glass_n},
				{glass_n, glass_n, glass_n},
				{glass_n, glass_n, glass_n}
			}
		})

		minetest.register_craft({
			output = glass_n .. " 9",
			recipe = {{"wine:bottle_" .. name}}
		})
	end
end

------------------------------------
-- Get Recipe
function wine.get_recipe(node_inv, water_store)
	local recipe

	-- essential ingredient check 
	if not node_inv:is_empty("src_1") and
	   water_store > 0 then
	   
		for _,def in pairs(wine.registered_brews) do		
			-- note inv:contains_item() wont work the way I want 
			-- with real nil or "" use workaround string "nil"				
			local src_2_name = node_inv:get_stack("src_2", 1):get_name()					
			if src_2_name == "" then
				src_2_name = node_inv:get_stack("src_2", 2):get_name()
			end
			
			if src_2_name == "" then
				src_2_name = "nil"
			end
			
			if node_inv:contains_item("src_1", def.ing_1) and    -- ingredient 1
			   (node_inv:contains_item("src_2", def.ing_2) or 
				src_2_name == def.ing_2) and                     -- ingredient 2 with string "nil" check
				node_inv:contains_item("src_g", def.vessel) and  -- glass/bottle or nil
			   water_store > def.water_used then	             -- enough water		   
			
			   recipe = def
			   break
			end				
		end   
	end
	
	return recipe
end

------------------------------------
-- Timer validate meta and reset
function wine.timer_valid_meta(meta)
	
	local rtn = false
	
		local cur_cnt     = meta:get_int("cur_cnt")
		local cur_cnt_end = meta:get_int("cur_cnt_end")
		local water_store = meta:get_int("water_store")
		local brewing     = meta:get_string("brewing")
		local formspec    = meta:get_string("formspec")
		local infotext    = meta:get_string("infotext")
		
		if type(cur_cnt)      ~= "number" then meta:set_int("cur_cnt", 0) rtn = true end
		if type(cur_cnt_end)  ~= "number" then meta:set_int("cur_cnt_end", 0)  rtn = true end
		if type(water_store)  ~= "number" then meta:set_int("water_store", 0)  rtn = true end	
		if type(brewing)      ~= "string" then meta:set_int("brewing", "")  rtn = true end
		
		if rtn then
			meta:set_int("formspec", wine.winebarrel_formspec(pos))
			meta:set_int("infotext", S("Fermenting Barrel"))
		end
	
	-- So we run only once
	meta:set_int("v2", 1)

	return rtn
end

------------------------------------
-- Timer validate inventory and reset
function wine.timer_valid_inv(meta)
	
	local rtn = false	
	local inv_rtn = false

		local node_inv = meta:get_inventory()
		
		local src   = node_inv:get_size("src")       -- old source	
		local src_1 = node_inv:get_size("src_1")     -- new source
		local src_2 = node_inv:get_size("src_2")     -- new source
		local src_g = node_inv:get_size("src_g")     -- new source
		local dst   = node_inv:get_size("dst")       -- nil change 

		if src_1 ~= 2 then node_inv:set_size("src_1", 2) inv_rtn = true end
		if src_2 ~= 2 then node_inv:set_size("src_2", 2) inv_rtn = true end
		if src_g ~= 1 then node_inv:set_size("src_g", 1) inv_rtn = true end
		if dst   ~= 1 then node_inv:set_size("dst", 1)   inv_rtn = true end
		
		if src > 0 then
			-- move contents from old src to new src_1
			if not node_inv:is_empty("src") then
				local src_stack = node_inv:get_stack("src", 1)
				node_inv:set_stack("src_1", 1, src_stack)
			end
			
			-- delete src
			node_inv:set_size("src", 0)
		end

		local timer_rtn = wine.timer_valid_meta(meta)
	
	if inv_rtn or timer_rtn then rtn = true end
		
	return rtn
end

------------------------------------
-- Barrel Timer
function wine.timer_barrel(pos, elapsed)
	-- Validate Inventory Structure/Meta Data
	-- Cond refresh Meta
	-- Load Meta values/vars
		-- If Brewing and recipe
			-- If change recipe brew update
			-- ElseIf Output Full - Stop
			-- Elseif cnt = cnt_end, issue output
			-- Else increment
				
		-- ElseIf Not Brewing and recipe
			-- Update to Brewing
		
		-- Else (neither)
			-- Update off state
	-- Update Meta Data
	-- Return Timer State
	
	---------------------------
	-- Validate Inventory Structure/Meta Data V2.0
	local meta = minetest.get_meta(pos)	
	
	if meta:get_int("v2") == 0 then
		local inv_upd = wine.timer_valid_inv(meta)
		
		-- Refresh meta after update
		meta = minetest.get_meta(pos)
	end

	---------------------------
	-- Load Meta Data/variables
	local cur_cnt     = meta:get_int("cur_cnt")
	local cur_cnt_end = meta:get_int("cur_cnt_end")
	local water_store = meta:get_int("water_store")
	local brewing     = meta:get_string("brewing")
	local formspec    = meta:get_string("formspec")
	local infotext    = meta:get_string("infotext")
	local node_inv    = meta:get_inventory()
	local recipe 	  = wine.get_recipe(node_inv, water_store)
	local S           = wine.intllib()
	local timer       = true
	
	-- saves multiple comment/uncomment for debugging
	-- set true to see debug ouput for end points
	local tdebug      = false 

	---------------------------
	-- Brewing or not	
	if brewing ~= "" and recipe then				
		-- Confirm we still have correct Ingredients
		if brewing ~= recipe.output then
			cur_cnt = 0
			cur_cnt_end = recipe.brew_time
			brewing = recipe.output		
			infotext = S("Fermenting Barrel (@1% Done)", 0)
			if tdebug then minetest.debug("Changed Ingredients") end
			
		-- Check output room:
		elseif not node_inv:room_for_item("dst", recipe.output) then
				cur_cnt = 0
				cur_cnt_end = 0
				brewing = ""
				infotext = S("Fermenting Barrel (FULL)")
				timer = false
				if tdebug then minetest.debug("No Room") end
		
		elseif cur_cnt >= cur_cnt_end then
			node_inv:remove_item("src_1", recipe.ing_1)
			node_inv:remove_item("src_2", recipe.ing_2)
			node_inv:remove_item("src_g", recipe.vessel)
			node_inv:add_item("dst", recipe.output)
			
			local new_water_store = water_store - recipe.water_used
			
			if new_water_store < 0 then new_water_store = 0 end
			
			cur_cnt = 0
			cur_cnt_end = 0
			brewing = ""			
			water_store = new_water_store
			infotext = S("Fermenting Barrel")
			if tdebug then minetest.debug("Give Output") end
						
		else	
			local fin_per = math.ceil((cur_cnt/cur_cnt_end)*100)		
			-- catch "nan" - nan never equals nan	
			if fin_per ~= fin_per then fin_per = 0 end
				
			cur_cnt = cur_cnt + 5
			infotext = S("Fermenting Barrel (@1% Done)", fin_per)
			if tdebug then minetest.debug("Increase Counter") end
		end
	
	elseif brewing == "" and recipe then		
		cur_cnt = 0
		cur_cnt_end = recipe.brew_time
		brewing = recipe.output			
		infotext = S("Fermenting Barrel (@1% Done)", 0)
		if tdebug then minetest.debug("Initial Setup") end
	else 
		cur_cnt = 0
		cur_cnt_end = 0
		brewing = ""
		infotext = S("Fermenting Barrel")
		timer = false
		if tdebug then minetest.debug("Sleep") end	
	end
	
	---------------------------
	-- Update Meta Data
	meta:set_int("cur_cnt", cur_cnt)
	meta:set_int("cur_cnt_end",cur_cnt_end)
	meta:set_int("water_store",water_store)
	meta:set_string("brewing",brewing)
	meta:set_string("formspec",wine.winebarrel_formspec(pos))
	meta:set_string("infotext",infotext)
	
	---------------------------
	-- Return timer state	
	return timer
end