Wine mod for Minetest

by TenPlus1

Depends: Farming Redo

This mod adds a barrel used to ferment grapes into glasses of wine, 9 of which can then be crafted into a bottle of wine.  It can also ferment honey into mead, barley into beer, wheat into weizen (wheat beer), corn into bourbon and apples into cider.

Change log:

- 0.1 - Initial release
- 0.2 - Added protection checks to barrel
- 0.3 - New barrel model from cottages mod (thanks Napiophelios), also wine glass can be placed
- 0.4 - Added ability to ferment barley from farming redo into beer and also honey from mobs redo into honey mead
- 0.5 - Added apple cider
- 0.6 - Added API so drinks can easily be added, also added wheat beer thanks to h-v-smacker and support for pipeworks/tubelib
- 0.7 - Blue Agave now appears in desert areas and spreads very slowly, can me fermented into tequila
- 0.8 - Barrel and Agave both use node timers now thanks to h-v-smacker, added sake
- 0.9 - Added Glass of Rum and Bottle of Rum thanks to acm :) Added {alcohol=1} groups
- 1.0 - Added glass and bottle or Bourbon made by fermenting corn
- 1.1 - Added glass and bottle of Vodka made by fermenting baked potato, Added MineClone2 support and spanish translation
- 1.2 - Added Unified Inventory support for barrel recipes (thanks to realmicu)
- 1.3 - Translations updated and French added thanks to TheDarkTiger
- 1.4 - Added bottle of beer and bottle of wheat beer (thanks Darkstalker for textures)
- 1.5 - Added bottle of sake (texture by Darkstalker), code tidy & tweaks, resized bottles and glasses, added some new lucky blocks, support for Thirst mod
- 1.6 - Added bottle of Mead, Cider and Mint-Julep (textures by Darkstalker),
re-arranged code, tweaked lucky blocks, updated translations
- 1.7 - Added more uses for blue agave (fuel, paper, food, agave syrup)
- 1.8 - Added glass and bottles for Champagne, Brandy and Coffee Liquor (thanks Felfa)
- 1.9 - Added wine:add_drink() function to create drink glasses and bottles
- 2.0 - Added optional ingredients (upto 4), added water usage for brewing, added Empty Bottle/Glass requried for brewing, Formspec additions, re-arranged code, Supports old wine:add_item() format, addition of setting to only register non-alcholic items, addition of setting to allow brewing by the bottle, 5 non-alcholic brewing recipes/items added and added 5 Lucky Blocks.

Lucky Blocks: 23


Wine Mod API
------------

wine:add_item(def_table)

e.g.
```
wine:add_item({output = "wine:glass_green_stuff",   
			  recipe = {"modname:green_stuff 1","","",""},  
			  e_vessel = true  
			  water = 25,  
		      brew_time  = 100})  
```
			  
 - output = Item recieved at end of brew_time
 - recipe = {ItemStack, "", "", ""} use itemstack format or "" for none.
 - e_vessel = Empty Glass/Bottle required true/false*
 - water  = Units of water used in brewing - Brewing barrel when full has 2000 units
 - brew_time = time in second to brew item.

Inside recipe if empty glass bottle is set to false, item can be brewed without
supplying the glass/bottle. Example of this is Champagne which is brewed from Wine.

If wine:bottle_green_stuff has been registered and allow bottle brewing is set to true then
the above will auto register a brewing recipe for a bottle using 8x the glass values. 
User recieves 1 free glass when brewing by the bottle.  
    
The code automatically does the below e.g.
``` 
	output = "wine:bottle_green_stuff",  
	recipe = {"modname:green_stuff 8","","",""},
	e_vessel = true ,	
	water = 200,    
	brew_time  = 800  
```

There is an additional check in the event empty bottle/glass is not required code will also
check to ensure the glass ingredient has a registered bottle. If no bottle version then 
recipe is not registered - e.g.  	
Milk/Kefir there is not item mobs:bottle_milk so no recipe to brew kefir by the bottle 
just by the glass. Glasses of Kefir can still be crafted into bottles for easier storage.

Note Structure to register changed in 2.0, code supports old format with the below settings:
``` 
	output = output as supplied   
	recipe = {input as supplied.." 1", "", "", ""}   
	e_vessel = true   
	water = 25   
	brew_time = 100   
```

wine:add_drink(name, desc, has_bottle, num_hunger, num_thirst, alcoholic)   

e.g.   
```   
wine:add_drink("beer", "Beer", true, 2, 8, 1)   
wine:add_drink("cider", "Cider", true, 2, 6, 1)   
wine:add_drink("sparkling_apple_juice", "Sparkling Apple Juice", true, 1, 3, 0)   
```

Note:
- Textures used will be wine_beer_glass.png wine_beer_bottle.png
- Num_thirst is only used if thirst mod is active, 
- Alcoholic is used if stamina mod is active for drunk effect.
