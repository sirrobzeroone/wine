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
	local mcl_m_inv_c   = ""                         -- mineclone normal inventory slot color
	local mcl_b_inv_c   = ""                         -- mineclone barrel inventory slot color
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
	local tt_ing 		  = S("Ingredients")
	local tt_water_stored = S("Avaliable Water")
	local tt_empty_bg     = S("Empty Glass or Bottle")
	local tt_finish_p     = S("Fermenting Barrel (@1% Done)", fin_per)
	local cur_brew        = S("Brewing: ")..brewing_des
	local tt_water_bucket = S("Water Bucket")
	
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
		.. "image[1.26,2.8;3.495,1.45;wine_barrel_water.png^[colorize:#261c0e:175^[opacity:125" --
		.. "^[lowpart:"..water_per..":wine_barrel_water.png]"
		.. "style_type[list;size=0.85,0.85;spacing=0.25,0.1]"
		.. mcl_b_inv_c
		.. "list[current_name;src;2.05,0.85;2,2;0]"
		.. "list[current_name;src_b;2.6,3.00;1,1;0]"		
		.. "style_type[list;size=1,1;spacing=0.25,0.25]"
		.. mcl_m_inv_c
		.. "list[current_name;src_g;6.1,2;1,1;0]"
		.. "list[current_name;dst;8.7,2;1,1;0]"
		.. "image[7.4,2;1,1;barrel_icon_bg.png^[lowpart:"..fin_per..":barrel_icon.png]"
		.. "tooltip[2.05,0.65;1.95,2.2;"..tt_ing.."]"
		.. "tooltip[2.6,3.00;0.85,0.85;"..tt_water_bucket.."]"			
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
				
			local itemstack = ItemStack(list[n][1].." 1")
			
			wine.register_brew({ 
				output = list[n][2], 
				recipe = {itemstack,"","",""},
				e_vessel = true,
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
	local is_brew_bottle = wine.allow_brew_bottle
	local ingredients_g = {}
	local ingredients_b = {}	
	
				
	
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
	
	-- Catch more than 4 Ingredients
	if #def_table.recipe > 4 then
		minetest.log("warning", "[Wine MOD]: wine:add_item - "
				.. "too many ingredients, output not registered: "
				..def_table.output)
		return
	end
	
	if not wine.reg_alcohol and 
	   minetest.get_item_group(def_table.output, "alcohol") > 0 then
		return
	end
	
	-- Convert not required Glass/Bottle to nil
	if not def_table.e_vessel then
		req_glass = nil
		req_bottle = nil
	end
	
	-- Check supplied ingredients are registered			
		for _,ing in pairs(def_table.recipe) do						
			
			if ing then 
				local itemstack = ItemStack(ing)
				if minetest.registered_nodes[itemstack:get_name()] or
				   minetest.registered_items[itemstack:get_name()] then 			
					
					table.insert(ingredients_g,itemstack)

				else
					minetest.log("warning", "[Wine MOD]: wine:add_item - "
					.. "ingredient not registered, output not registered: "
					..def_table.output)
					
					return
				end
			end
		end

	-- Register single glass recipe
	table.insert(wine.registered_brews,{
				ings = ingredients_g,
				vessel = req_glass,
				water_used = def_table.water,
				brew_time = def_table.brew_time,
				output = def_table.output})

	-- Bottle recipe registration 
	-- calculations essentially wine.bottle_rec_multi(default 8) x glass 
	-- 1 free glass for efficency		
	local is_bottle = minetest.registered_nodes[def_table.output:gsub("glass","bottle")]
	
	if is_brew_bottle and is_bottle then
	
			-- Check supplied ingredients are registered				
			for _,ing in ipairs(def_table.recipe) do						
				if ing then 
					local itemstack = ItemStack(ing)
					
					-- if glass used as ingredient swap for bottle:
					if string.find(itemstack:get_name(), "glass") then
						itemstack:get_name():gsub("glass","bottle")
					end
					
					if itemstack:get_name() ~= "" then
						local cnt = itemstack:get_count()*wine.bottle_rec_multi
						itemstack:set_count(cnt)
					end
					
					if minetest.registered_nodes[itemstack:get_name()] or
					   minetest.registered_items[itemstack:get_name()] then 			
												
							table.insert(ingredients_b,itemstack)
					else
						minetest.log("warning", "[Wine MOD]: wine:add_item - "
						.. "ingredient not registered, output not registered: "
						..def_table.output)
						return
					end
				end
			end
			
			-- Register bottle recipe			
			table.insert(wine.registered_brews,{
				ings = ingredients_b,
				vessel = req_bottle,
				water_used = (def_table.water*bot_multi),
				brew_time = (def_table.brew_time*bot_multi),
				output = def_table.output:gsub("glass","bottle")})

	end
	
	-- unified Inventory Support
	if wine.is_uninv then
	
	-- Resorting function so looks nicer inside uninv formspec/ui
	-- ingredients slots 1-2-4-5, glass slot 3
		local function re_sort(ing_list,empty_ves)
			local output = {}
			local i = 1
			
			for _,itemstack in ipairs(ing_list) do
				output[i] = ItemStack(itemstack)
				
				if i == 2 then 
					i = i + 2
				else 
					i = i + 1 
				end		
			end
			
			output[3] = empty_ves						
			return output
		end
	-- glass		
		-- re-sort table so looks nicer
		local uninv_ing_g = re_sort(ingredients_g,req_glass)
		
		unified_inventory.register_craft({
			type = "barrel",
			items = uninv_ing_g,
			output = def_table.output
		})
		
	--bottle
		-- is_brew_bottle = setting to stop bottle brewing 
		-- is_bottle = output bottle
		if is_brew_bottle and is_bottle then
			
			-- re-sort table so looks nicer
			local uninv_ing_b = re_sort(ingredients_b,req_bottle)				
				
			unified_inventory.register_craft({
				type = "barrel",
				items = uninv_ing_b,
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
	if not node_inv:is_empty("src") and
		   water_store > 0 then
		
		-- Note Self: Any ingredient can be in any slot
		
		-- check one ingredients present in greater 
		-- than needed quantity ,returns recipe dosen't
		-- account for extra/un-needed ingredients
		-- see check two
		for k,def in pairs(wine.registered_brews) do                                                                                        
			for i=1,4,1 do
				local ing = def.ings[i]
				
				if def.vessel == nil then
					def.vessel = ""
				end
				
				if ((node_inv:get_stack("src", 1):get_name() == ing:get_name() or ing:get_name() == "") or
				   (node_inv:get_stack("src", 2):get_name() == ing:get_name() or ing:get_name() == "") or
				   (node_inv:get_stack("src", 3):get_name() == ing:get_name() or ing:get_name() == "") or
				   (node_inv:get_stack("src", 4):get_name() == ing:get_name() or ing:get_name() == "")) and 
				   (node_inv:contains_item("src", ing) or ing:get_name() == "") and 
				   water_store >= def.water_used and 
				   node_inv:get_stack("src_g", 1):get_name() == def.vessel then
				  
				   if i == 4 then
						recipe = def
						break
				   end
				else
					break                                                    
				end
			end
		end
		
		-- check two, confirm no extra/un-needed ingredients
		-- problem caused when we have 1x or 2x "" and 1x random ingredient
		if recipe then
			for i=1,4,1 do
				local inv_stack_name = node_inv:get_stack("src", i):get_name()

				if inv_stack_name ~= recipe.ings[1]:get_name() and
				   inv_stack_name ~= recipe.ings[2]:get_name() and
				   inv_stack_name ~= recipe.ings[3]:get_name() and
				   inv_stack_name ~= recipe.ings[4]:get_name() then
				   
				   recipe = nil
				   break
				end                        
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
		local catchup     = meta:get_int("catchup")
		local brewing     = meta:get_string("brewing")
		local formspec    = meta:get_string("formspec")
		local infotext    = meta:get_string("infotext")
		
		if type(cur_cnt)      ~= "number" then meta:set_int("cur_cnt", 0) rtn = true end
		if type(cur_cnt_end)  ~= "number" then meta:set_int("cur_cnt_end", 0)  rtn = true end
		if type(water_store)  ~= "number" then meta:set_int("water_store", 0)  rtn = true end
		if type(water_store)  ~= "number" then meta:set_int("catchup", 0)  rtn = true end		
		if type(brewing)      ~= "string" then meta:set_int("brewing", "")  rtn = true end
		
		if rtn then
			meta:set_int("formspec", wine.winebarrel_formspec(pos))
			meta:set_int("infotext", S("Fermenting Barrel"))
		end

	return rtn
end

------------------------------------
-- Timer validate inventory and reset
function wine.timer_valid_inv(meta)
	
	local rtn = false	
	local inv_rtn = false

		local node_inv = meta:get_inventory()
		
		local src   = node_inv:get_size("src")       -- old source/new source	
		local src_1 = node_inv:get_size("src_1")     -- new source/old source
		local src_2 = node_inv:get_size("src_2")     -- new source/old source
		local src_g = node_inv:get_size("src_g")     -- new source
		local src_b = node_inv:get_size("src_b")     -- new source
		local dst   = node_inv:get_size("dst")       -- nil change 

		if src   ~= 4 then node_inv:set_size("src", 4)   inv_rtn = true end 
		if src_g ~= 1 then node_inv:set_size("src_g", 1) inv_rtn = true end
		if src_b ~= 1 then node_inv:set_size("src_b", 1) inv_rtn = true end
		if dst   ~= 1 then node_inv:set_size("dst", 1)   inv_rtn = true end
		
		-- this code not required in end version 
		-- just jumping test team fwd nicely :)
		if src_1 > 0 or src_2 > 0 then
			-- move contents from src_1 back to src
			if not node_inv:is_empty("src_1") then
				local src_stack_1 = node_inv:get_stack("src_1", 1)
				local src_stack_2 = node_inv:get_stack("src_1", 2)
				node_inv:set_stack("src", 1, src_stack_1)
				node_inv:set_stack("src", 3, src_stack_2)				
			end
			-- move contents from src_2 back to src
			if not node_inv:is_empty("src_2") then
				local src_stack_1 = node_inv:get_stack("src_2", 1)
				local src_stack_2 = node_inv:get_stack("src_2", 2)
				node_inv:set_stack("src", 2, src_stack_1)
				node_inv:set_stack("src", 4, src_stack_2)				
			end			
			-- delete src_1/src_2
			node_inv:set_size("src_1", 0)
			node_inv:set_size("src_2", 0)			
		end

		local timer_rtn = wine.timer_valid_meta(meta)
	
	if inv_rtn or timer_rtn then 
		rtn = true 			
	end
	-- So we run only once per barrel per version
	meta:set_string("version", wine.version)	

	return rtn
end

------------------------------------
-- Barrel - Process Water Bucket
function wine.process_water_bucket(water_store,node_inv,pos)
	
	local water_level = water_store
	
	if not node_inv:is_empty("src_b") and 
		water_level < (wine.barrel_water_max - (wine.bucket_refill_amt/2)) then
		
		local item_name = node_inv:get_stack("src_b", 1):get_name()
		local item_cnt  = node_inv:get_stack("src_b", 1):get_count()
		local is_water
		local is_empty
		local refill_amt
		local empty_cont
			
		for _,def in ipairs(wine.water_refill) do			
			if def[1] == item_name then
				is_water = true
				refill_amt = def[2]
				empty_cont = def[3]
				break
				
			elseif def[3] == item_name then
				is_empty = true
			end			
		end
		
		if is_water then			
			      water_level = water_level + refill_amt
			
			if water_level > wine.barrel_water_max then
				water_level = wine.barrel_water_max
			end
			
			node_inv:remove_item("src_b", item_name.." "..item_cnt)		
			node_inv:add_item("src_b", empty_cont.." 1")	
				
		elseif is_empty then
			-- nothing	
		else
			-- player manages to jam none water item in there we delete it
			node_inv:remove_item("src_b", item_name.." "..item_cnt)
		end
	end
	return water_level
end

------------------------------------
-- Barrel - Timer catchup
	-- Timers don't run when map area that 
	-- contains the node are unloaded.
	-- this is a basic attempt at catchup
	-- similar to the idea of abm catchup
function wine.barrel_timer_catchup(catchup, recipe, node_inv, water_store, tdebug)
		
	local new_catchup = minetest.get_gametime()
	local new_water_store = water_store
	
	if catchup ~= 0 and new_catchup-catchup > 5 then
				
		--------------------
		-- get avaliable supplies
		local avl_ing = {}
		local avl_glass = node_inv:get_stack("src_g", 1):get_count()
		local avl_water = water_store
		local avl_time  = new_catchup-catchup
		
		-- loop through each inv slot and check
		-- for each ingredient and update count
		for i=1,4,1 do
			local proc_stack = node_inv:get_stack("src", i)
			
			-- ingredient check
			for k,stack in pairs(recipe.ings) do			
				-- add count from inventory to same table key as 
				-- recipe ingredient. eg avl_ing = {[1] = 20, [2] = 10} 
				if stack:get_name() == proc_stack:get_name() then
					
					if not avl_ing[k] then avl_ing[k] = 0 end
					
					avl_ing[k] = avl_ing[k] + proc_stack:get_count()
				end			
			end		
		end
				
		----------------------------------
		-- Amount to Produce 1 output
		local use_glass = ItemStack(recipe.vessel):get_count()
		local use_water = recipe.water_used
		local use_time  = recipe.brew_time
		
		
		----------------------------------		
		-- Find Limiting Resource
		--convert to itemstacks
		local stack_ing_1 = ItemStack(recipe.ings[1])
		local stack_ing_2 = ItemStack(recipe.ings[2])	
		local stack_ing_3 = ItemStack(recipe.ings[3])
		local stack_ing_4 = ItemStack(recipe.ings[4])		
		
		local max_cyc_ing_1 = avl_ing[1]/stack_ing_1:get_count()
		local max_cyc_ing_2 = avl_ing[2]/stack_ing_2:get_count()
		local max_cyc_ing_3 = avl_ing[3]/stack_ing_3:get_count()
		local max_cyc_ing_4	= avl_ing[4]/stack_ing_4:get_count()	
		local max_cyc_glass = avl_glass/use_glass
		local max_cyc_water = avl_water/use_water	
		local max_cyc_time  = avl_time/use_time		
		local max_output    = 99 - node_inv:get_stack("dst", 1):get_count()
		
		if not recipe.vessel then
			local max_cyc_glass = 1000 -- set to high number
		end
		
		-- ingedient_1 has to be avaliable but check anyways
		if not recipe.ings[1] then
			max_cyc_ing_1 = 0 
			-- If we have no ingredient 1 set 0 this effectively
			-- stops catchup from running but allows returned values
		end
		
		if not recipe.ings[2] then max_cyc_ing_2 = 1000 end
		if not recipe.ings[3] then max_cyc_ing_3 = 1000 end
		if not recipe.ings[4] then max_cyc_ing_4 = 1000 end
		
		-- -1 from max cycle so the current in-progress cycle has
		-- space and resources to finish.
		local max_cyc = math.floor( math.min(max_cyc_ing_1, 
											 max_cyc_ing_2,
										   	 max_cyc_ing_3,
											 max_cyc_ing_4, 
											 max_cyc_glass, 
											 max_cyc_water, 
											 max_cyc_time, 
											 max_output)-1)		
	
		-----------------------------------
		-- Final Check and Output
		if max_cyc >= 1 then
			
			-- Remove Ingedient 1
			node_inv:remove_item("src", stack_ing_1:get_name().." "..(max_cyc*stack_ing_1:get_count()))
			if tdebug then minetest.debug("ing_1: "..stack_ing_1:get_name().." "..(max_cyc*stack_ing_1:get_count())) end
			
			-- Remove Ingredient 2
			if recipe.ing_2 ~= "nil" then
				node_inv:remove_item("src", stack_ing_2:get_name().." "..(max_cyc*stack_ing_2:get_count()))
				if tdebug then minetest.debug("ing_2: "..stack_ing_2:get_name().." "..(max_cyc*stack_ing_2:get_count())) end
			end
			
			-- Remove Ingredient 3
			if recipe.ing_3 ~= "nil" then
				node_inv:remove_item("src", stack_ing_3:get_name().." "..(max_cyc*stack_ing_3:get_count()))
				if tdebug then minetest.debug("ing_3: "..stack_ing_3:get_name().." "..(max_cyc*stack_ing_3:get_count())) end
			end
			
			-- Remove Ingredient 4
			if recipe.ing_4 ~= "nil" then
				node_inv:remove_item("src", stack_ing_4:get_name().." "..(max_cyc*stack_ing_4:get_count()))
				if tdebug then minetest.debug("ing_4: "..stack_ing_4:get_name().." "..(max_cyc*stack_ing_4:get_count())) end
			end
			
			-- Remove Empty Glass Containers
			if recipe.vessel then
				node_inv:remove_item("src_g", recipe.vessel.." "..(max_cyc*use_glass))
				if tdebug then minetest.debug("src_g: "..recipe.vessel.." "..(max_cyc*use_glass)) end
			end
			
			-- Remove Water_Store
			new_water_store = water_store-(max_cyc*use_water)
			if tdebug then minetest.debug("water: "..water_store-(max_cyc*use_water)) end
			
			-- Add Output
			node_inv:add_item("dst", ItemStack(recipe.output):get_name().." "..max_cyc)
			if tdebug then minetest.debug("dst: "..ItemStack(recipe.output):get_name().." "..max_cyc) end
		end
	end

	return new_catchup, new_water_store
end

------------------------------------
-- Barrel Timer
function wine.timer_barrel(pos, elapsed)
	-- Validate Inventory Structure/Meta Data
	-- Cond refresh Meta
	-- Load Meta values/vars
	-- Check and Process Bucket
		-- If Brewing and recipe
			-- Check for timer catchup
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
	
	if tonumber(meta:get_string("version")) < wine.version then
		local inv_upd = wine.timer_valid_inv(meta)
		
		-- Refresh meta after update
		meta = minetest.get_meta(pos)
	end

	---------------------------
	-- Load Meta Data/variables
	local cur_cnt     = meta:get_int("cur_cnt")
	local cur_cnt_end = meta:get_int("cur_cnt_end")
	local water_store = meta:get_int("water_store")
	local catchup     = meta:get_int("catchup")
	local brewing     = meta:get_string("brewing")
	local formspec    = meta:get_string("formspec")
	local infotext    = meta:get_string("infotext")
	local node_inv    = meta:get_inventory()
	local recipe 	  = wine.get_recipe(node_inv, water_store)
	local S           = wine.intllib()
	local timer       = true
	
	-- saves multiple comment/uncomment for debugging
	-- set true to see debug ouput for end points
	local tdebug      = true
	
	---------------------------
	-- Check and process bucket
	water_store = wine.process_water_bucket(water_store,node_inv,pos)
		
	---------------------------
	-- Brewing or not	
	if brewing ~= "" and recipe then				
		-- Timer catchup check
		catchup, water_store = wine.barrel_timer_catchup(catchup, recipe, node_inv, water_store, tdebug)
		
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
			node_inv:remove_item("src", recipe.ings[1])
			node_inv:remove_item("src", recipe.ings[2])
			node_inv:remove_item("src", recipe.ings[3])
			node_inv:remove_item("src", recipe.ings[4])			
			node_inv:remove_item("src_g", recipe.vessel)
			node_inv:add_item("dst", recipe.output)
			
			-- Start output calculations
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
		catchup = minetest.get_gametime()
		if tdebug then minetest.debug("Initial Setup") end
	else 
		cur_cnt = 0
		cur_cnt_end = 0
		brewing = ""
		infotext = S("Fermenting Barrel")
		timer = false
		catchup = 0
		if tdebug then minetest.debug("Sleep") end	
	end
	
	---------------------------
	-- Update Meta Data
	meta:set_int("cur_cnt", cur_cnt)
	meta:set_int("cur_cnt_end",cur_cnt_end)
	meta:set_int("water_store",water_store)
	meta:set_int("catchup",catchup)	
	meta:set_string("brewing",brewing)
	meta:set_string("formspec",wine.winebarrel_formspec(pos))
	meta:set_string("infotext",infotext)
	
	---------------------------
	-- Return timer state	
	return timer
end