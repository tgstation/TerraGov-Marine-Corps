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
	name = "poppy seed"
	seed_type = "poppies"

/obj/item/seeds/chiliseed
	name = "chili seed"
	seed_type = "chili"

/obj/item/seeds/plastiseed
	name = "plastic seed"
	seed_type = "plastic"

/obj/item/seeds/grapeseed
	name = "grape seed"
	seed_type = "grapes"

/obj/item/seeds/greengrapeseed
	name = "green grape seed"
	seed_type = "greengrapes"

/obj/item/seeds/peanutseed
	name = "peanut seed"
	seed_type = "peanut"

/obj/item/seeds/cabbageseed
	name = "cabbage seed"
	seed_type = "cabbage"

/obj/item/seeds/berryseed
	name = "berry seed"
	seed_type = "berries"

/obj/item/seeds/glowberryseed
	name = "glowberry seed"
	seed_type = "glowberries"

/obj/item/seeds/bananaseed
	name = "banana seed"
	seed_type = "banana"

/obj/item/seeds/eggplantseed
	name = "eggplant seed"
	seed_type = "eggplant"

/obj/item/seeds/eggyseed
	name = "eggplant seed"
	seed_type = "realeggplant"

/obj/item/seeds/bloodtomatoseed
	name = "blood tomato seed"
	seed_type = "bloodtomato"

/obj/item/seeds/tomatoseed
	name = "tomato seed"
	seed_type = "tomato"

/obj/item/seeds/killertomatoseed
	name = "tomato seed"
	seed_type = "killertomato"

/obj/item/seeds/bluetomatoseed
	name = "blue tomato seed"
	seed_type = "bluetomato"

/obj/item/seeds/bluespacetomatoseed
	name = "bluespace tomato seed"
	seed_type = "bluespacetomato"

/obj/item/seeds/cornseed
	name = "corn seed"
	seed_type = "corn"

/obj/item/seeds/potatoseed
	name = "potato seed"
	seed_type = "potato"

/obj/item/seeds/icepepperseed
	name = "ice chili seed"
	seed_type = "icechili"

/obj/item/seeds/soyaseed
	name = "soybean seed"
	seed_type = "soybean"

/obj/item/seeds/wheatseed
	name = "wheat seed"
	seed_type = "wheat"

/obj/item/seeds/riceseed
	name = "rice seed"
	seed_type = "rice"

/obj/item/seeds/carrotseed
	name = "carrot seed"
	seed_type = "carrot"

/obj/item/seeds/reishimycelium
	name = "reishi mycelium seed"
	seed_type = "reishi"

/obj/item/seeds/amanitamycelium
	name = "amanita seed"
	seed_type = "amanita"

/obj/item/seeds/angelmycelium
	name = "angel mycelium seed"
	seed_type = "destroyingangel"

/obj/item/seeds/libertymycelium
	name = "liberty cap seed"
	seed_type = "libertycap"

/obj/item/seeds/chantermycelium
	name = "mushroom seed"
	seed_type = "mushrooms"

/obj/item/seeds/towermycelium
	name = "tower-cap seed"
	seed_type = "towercap"

/obj/item/seeds/glowshroom
	name = "glowshroom seed"
	seed_type = "glowshroom"

/obj/item/seeds/plumpmycelium
	name = "plumphelmet seed"
	seed_type = "plumphelmet"

/obj/item/seeds/walkingmushroommycelium
	name = "walking mushroom seed"
	seed_type = "walkingmushroom"

/obj/item/seeds/nettleseed
	name = "nettle seed"
	seed_type = "nettle"

/obj/item/seeds/deathnettleseed
	name = "deathnettle seed"
	seed_type = "deathnettle"

/obj/item/seeds/weeds
	seed_type = "weeds"

/obj/item/seeds/harebell
	seed_type = "harebells"

/obj/item/seeds/sunflowerseed
	name = "sunflower seed"
	seed_type = "sunflowers"

/obj/item/seeds/brownmold
	name = "brownmold seed"
	seed_type = "mold"

/obj/item/seeds/appleseed
	name = "apple seed"
	seed_type = "apple"

/obj/item/seeds/poisonedappleseed
	seed_type = "poisonapple"

/obj/item/seeds/goldappleseed
	name = "goldenapple seed"
	seed_type = "goldapple"

/obj/item/seeds/ambrosiavulgarisseed
	seed_type = "ambrosia"

/obj/item/seeds/ambrosiadeusseed
	seed_type = "ambrosiadeus"

/obj/item/seeds/whitebeetseed
	name = "whitebeet seed"
	seed_type = "whitebeet"

/obj/item/seeds/sugarcaneseed
	name = "sugarcane seed"
	seed_type = "sugarcane"

/obj/item/seeds/watermelonseed
	name = "watermelon seed"
	seed_type = "watermelon"

/obj/item/seeds/pumpkinseed
	name = "pumpkin seed"
	seed_type = "pumpkin"

/obj/item/seeds/limeseed
	name = "lime seed"
	seed_type = "lime"

/obj/item/seeds/lemonseed
	name = "lemon seed"
	seed_type = "lemon"

/obj/item/seeds/orangeseed
	name = "orange seed"
	seed_type = "orange"

/obj/item/seeds/poisonberryseed
	seed_type = "poisonberries"

/obj/item/seeds/deathberryseed
	seed_type = "deathberries"

/obj/item/seeds/grassseed
	name = "grass seed"
	seed_type = "grass"

/obj/item/seeds/cocoapodseed
	name = "cocoa seed"
	seed_type = "cocoa"

/obj/item/seeds/cherryseed
	name = "cherry seed"
	seed_type = "cherry"

/obj/item/seeds/kudzuseed
	seed_type = "kudzu"
