//Seed packet object/procs.
/obj/item/seeds
	name = "packet of seeds"
	icon = 'icons/obj/items/seeds.dmi'
	icon_state = "seed"
	flags_atom = NONE
	w_class = WEIGHT_CLASS_TINY

	var/seed_type
	var/datum/seed/seed
	var/modified = FALSE

/obj/item/seeds/Initialize(mapload, update = TRUE)
	. = ..()
	if(update)
		update_seed()

//Grabs the appropriate seed datum from the global list.
/obj/item/seeds/proc/update_seed()
	seed = GLOB.seed_types[seed_type]
	update_appearance()

//Updates strings and icon appropriately based on seed datum.
/obj/item/seeds/proc/update_appearance()
	icon_state = seed.packet_icon
	name = "packet of [seed.seed_name] [seed.seed_noun]"
	desc = "It has a picture of [seed.display_name] on the front."


/obj/item/seeds/poppyseed
	name = "Poppy Seed"
	seed_type = "poppies"

/obj/item/seeds/chiliseed
	name = "Chili Seed"
	seed_type = "chili"

/obj/item/seeds/plastiseed
	name = "Plastic Seed"
	seed_type = "plastic"

/obj/item/seeds/grapeseed
	name = "Grape Seed"
	seed_type = "grapes"

/obj/item/seeds/greengrapeseed
	name = "Green Grape Seed"
	seed_type = "greengrapes"

/obj/item/seeds/peanutseed
	name = "Peanut Seed"
	seed_type = "peanut"

/obj/item/seeds/cabbageseed
	name = "Cabbage Seed"
	seed_type = "cabbage"

/obj/item/seeds/berryseed
	name = "Berry Seed"
	seed_type = "berries"

/obj/item/seeds/glowberryseed
	name = "Glowberry Seed"
	seed_type = "glowberries"

/obj/item/seeds/bananaseed
	name = "Banana Seed"
	seed_type = "banana"

/obj/item/seeds/eggplantseed
	name = "Eggplant Seed"
	seed_type = "eggplant"

/obj/item/seeds/eggyseed
	name = "Eggplant Seed"
	seed_type = "realeggplant"

/obj/item/seeds/bloodtomatoseed
	name = "Blood Tomato Seed"
	seed_type = "bloodtomato"

/obj/item/seeds/tomatoseed
	name = "Tomato Seed"
	seed_type = "tomato"

/obj/item/seeds/killertomatoseed
	name = "Tomato Seed"
	seed_type = "killertomato"

/obj/item/seeds/bluetomatoseed
	name = "Blue Tomato Seed"
	seed_type = "bluetomato"

/obj/item/seeds/bluespacetomatoseed
	name = "Bluespace Tomato Seed"
	seed_type = "bluespacetomato"

/obj/item/seeds/cornseed
	name = "Corn Seed"
	seed_type = "corn"

/obj/item/seeds/potatoseed
	name = "Potato Seed"
	seed_type = "potato"

/obj/item/seeds/icepepperseed
	name = "Ice Chili Seed"
	seed_type = "icechili"

/obj/item/seeds/soyaseed
	name = "Soybean Seed"
	seed_type = "soybean"

/obj/item/seeds/wheatseed
	name = "Wheat Seed"
	seed_type = "wheat"

/obj/item/seeds/riceseed
	name = "Rice Seed"
	seed_type = "rice"

/obj/item/seeds/carrotseed
	name = "Carrot Seed"
	seed_type = "carrot"

/obj/item/seeds/reishimycelium
	name = "Reishi Mycelium Seed"
	seed_type = "reishi"

/obj/item/seeds/amanitamycelium
	name = "Amanita Seed"
	seed_type = "amanita"

/obj/item/seeds/angelmycelium
	name = "Angel Mycelium Seed"
	seed_type = "destroyingangel"

/obj/item/seeds/libertymycelium
	name = "Liberty Cap Seed"
	seed_type = "libertycap"

/obj/item/seeds/chantermycelium
	name = "Mushroom Seed"
	seed_type = "mushrooms"

/obj/item/seeds/towermycelium
	name = "Tower Cap Seed"
	seed_type = "towercap"

/obj/item/seeds/glowshroom
	name = "Glowshroom Seed"
	seed_type = "glowshroom"

/obj/item/seeds/plumpmycelium
	name = "Plumphelmet Seed"
	seed_type = "plumphelmet"

/obj/item/seeds/walkingmushroommycelium
	name = "Walking Mushroom Seed"
	seed_type = "walkingmushroom"

/obj/item/seeds/nettleseed
	name = "Nettle Seed"
	seed_type = "nettle"

/obj/item/seeds/deathnettleseed
	name = "Deathnettle Seed"
	seed_type = "deathnettle"

/obj/item/seeds/weeds
	seed_type = "weeds"

/obj/item/seeds/harebell
	seed_type = "harebells"

/obj/item/seeds/sunflowerseed
	name = "Sunflower Seed"
	seed_type = "sunflowers"

/obj/item/seeds/brownmold
	name = "Brownmold Seed"
	seed_type = "mold"

/obj/item/seeds/appleseed
	name = "Apple Seed"
	seed_type = "apple"

/obj/item/seeds/poisonedappleseed
	seed_type = "poisonapple"

/obj/item/seeds/goldappleseed
	name = "Goldenapple Seed"
	seed_type = "goldapple"

/obj/item/seeds/ambrosiavulgarisseed
	seed_type = "ambrosia"

/obj/item/seeds/ambrosiadeusseed
	seed_type = "ambrosiadeus"

/obj/item/seeds/whitebeetseed
	name = "Whitebeet Seed"
	seed_type = "whitebeet"

/obj/item/seeds/sugarcaneseed
	name = "Sugarcane Seed"
	seed_type = "sugarcane"

/obj/item/seeds/watermelonseed
	name = "Watermelon Seed"
	seed_type = "watermelon"

/obj/item/seeds/pumpkinseed
	name = "Pumpkin Seed"
	seed_type = "pumpkin"

/obj/item/seeds/limeseed
	name = "Lime Seed"
	seed_type = "lime"

/obj/item/seeds/lemonseed
	name = "Lemon Seed"
	seed_type = "lemon"

/obj/item/seeds/orangeseed
	name = "Orange Seed"
	seed_type = "orange"

/obj/item/seeds/poisonberryseed
	seed_type = "poisonberries"

/obj/item/seeds/deathberryseed
	seed_type = "deathberries"

/obj/item/seeds/grassseed
	name = "Grass Seed"
	seed_type = "grass"

/obj/item/seeds/cocoapodseed
	name = "Cocoa Seed"
	seed_type = "cocoa"

/obj/item/seeds/cherryseed
	name = "Cherry Seed"
	seed_type = "cherry"

/obj/item/seeds/kudzuseed
	seed_type = "kudzu"
