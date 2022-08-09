


function wine.timer_valid_meta(pos)
	
	local meta 		  = minetest.get_meta(pos)		
	local cur_cnt     = meta:get_int("cur_cnt")
	local cur_cnt_end = meta:get_int("cur_cnt_end")
	local water_store = meta:get_int("water_store")
	local brewing     = meta:get_string("brewing")
	local formspec    = meta:get_string("formspec")
	local infotext    = meta:get_string("infotext")
	
	if type(cur_cnt)      ~= "number" then meta:set_int("cur_cnt", 0) end
	if type(cur_cnt_end)  ~= "number" then meta:set_int("cur_cnt_end", 0) end
	if type(water_store)  ~= "number" then meta:set_int("water_store", 0) end	
	if type(brewing)      ~= "string" then meta:set_int("brewing", "") end
	if type(formspec)     ~= "string" then meta:set_int("formspec", wine.winebarrel_formspec(pos)) end
	if type(infotext)     ~= "string" then meta:set_int("infotext", S("Fermenting Barrel")) end
end

function wine.get_recipe(node_inv, water_store)
	local recipe

	-- essential ingredient check 
	if not node_inv:is_empty("src_1") and
	   water_store > 0 then
	   
		for _,def in pairs(wine.registered_brews) do		
			-- note inv:contains_item() wont work with tru nil
			-- use workaround string "nil"				
			local src_2_name = node_inv:get_stack("src_2", 1):get_name()					
			if src_2_name == "" then
				src_2_name = node_inv:get_stack("src_2", 2):get_name()
			end
			
			if src_2_name == "" then
				src_2_name = "nil"
			end
					
			if node_inv:contains_item("src_1", def.ing_1) and    -- ingredient 1
			   (node_inv:contains_item("src_2", def.ing_2) or 
				src_2_name == def.ing_2) and                     -- ingredient 2 with string"nil" check
				node_inv:contains_item("src_glass", def.vessel)  -- glass/bottle or nil
			   water_store > def.water then	                     -- enough water		   
			
			   recipe = def
			   break
			end				
		end   
	end

	return recipe
end



on_timer = function(pos)		
	-- Validate the Meta Data
	-- Load Meta values/vars
	-- Are we Brewing 
		-- If Brewing and recipe
			-- If change  brew update
			-- Elseif cnt = cnt_end issue output
			-- Else increment
				
		-- ElseIf  Not Brewing and recipe
			-- Update to Brewing
		
		-- Else (neither)
			-- Update off state
	-- Update Meta Data
	-- Return Timer State
	
	---------------------------
	-- Validate Meta Data
	-- Check for valid Meta data at pos and reset if invalid
	wine.timer_valid_meta(pos)
	
	---------------------------
	-- Load Meta Data/variables
	local meta 		  = minetest.get_meta(pos)	
	local cur_cnt     = meta:get_int("cur_cnt")
	local cur_cnt_end = meta:get_int("cur_cnt_end")
	local water_store = meta:get_int("water_store")
	local brewing     = meta:get_string("brewing")
	local formspec    = meta:get_string("formspec")
	local infotext    = meta:get_string("infotext")
	local node_inv    = meta:get_inventory()
	local recipe 	  = wine.get_recipe(node_inv, water_store)
	local timer       = true
	
	---------------------------
	-- Brewing or not
	
	if brewing ~= "" and recipe then				
		-- Confirm we still have correct Ingredients
		if brewing ~= recipe.ouput then
			cur_cnt = 0
			cur_cnt_end = brew_time
			brewing = recipe.output			
			infotext = S("Fermenting Barrel (@1% Done)", 0)
			
		elseif cur_cnt >= cur_cnt_end then
			-- Check output room:		
			if not inv:room_for_item("dst", recipe.output) then
				cur_cnt = 0
				cur_cnt_end = 0
				brewing = ""
				infotext = S("Fermenting Barrel (FULL)")
				timer = false
		
			else
				inv:remove_item("src_1", recipe.ing_1)
				inv:remove_item("src_2", recipe.ing_2)
				inv:add_item("dst", recipe_def.rec.output)
				
				local new_water_store = water_store - recipe.water_used
				
				if new_water_store < 0 then new_water_store = 0 end
				
				cur_cnt = 0
				cur_cnt_end = 0
				brewing = ""			
				water_store = new_water_store
				infotext = S("Fermenting Barrel")
			end			
		else	
			local fin_per = math.ceil((cur_cnt/cur_cnt_end)*100)		
			-- catch "nan" - nan never equals nan	
			if fin_per ~= fin_per then fin_per = 0 end
				
			cur_cnt = cur_cnt + 5
			infotext = S("Fermenting Barrel (@1% Done)", fin_per)
		end
	
	elseif brewing == "" and recipe then		
		cur_cnt = 0
		cur_cnt_end = recipe.brew_time
		brewing = recipe.output			
		infotext = S("Fermenting Barrel (@1% Done)", 0)
	
	else 
		cur_cnt = 0
		cur_cnt_end = 0
		brewing = ""			
		water_store = new_water_store
		infotext = S("Fermenting Barrel")
		timer = false		
	end
	
	---------------------------
	-- Update Meta Data
	local cur_cnt     = meta:set_int("cur_cnt", cur_cnt)
	local cur_cnt_end = meta:set_int("cur_cnt_end",cur_cnt_end)
	local water_store = meta:set_int("water_store",water_store)
	local brewing     = meta:set_string("brewing",brewing)
	local formspec    = meta:set_string("formspec",wine.winebarrel_formspec(pos))
	local infotext    = meta:gset_string("infotext",infotext)
	
	---------------------------
	-- Return timer state	
	return timer
end,