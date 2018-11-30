//Seed packet object/procs.
/obj/item/seeds
	name = "packet of seeds"
	icon = 'icons/obj/items/seeds.dmi'
	icon_state = "seed"
	flags_atom = NOFLAGS
	w_class = 1

	var/seed_type
	var/datum/seed/seed
	var/modified = FALSE

/obj/item/seeds/New()
	update_seed()
	return ..()

//Grabs the appropriate seed datum from the global list.
/obj/item/seeds/proc/update_seed()
	if(!seed && seed_type && !isnull(seed_types) && seed_types[seed_type])
		to_chat(world, "Seed found!")
		seed = seed_types[seed_type]
	update_appearance()

//Updates strings and icon appropriately based on seed datum.
/obj/item/seeds/proc/update_appearance()
	if(!seed) 
		to_chat(world, "no seed?")
		return
	icon_state = seed.packet_icon
	name = "packet of [seed.seed_name] [seed.seed_noun]"
	desc = "It has a picture of [seed.display_name] on the front."

/obj/item/seeds/examine(mob/user)
	. = ..()
	if(seed && !seed.roundstart)
		to_chat(user, "It's tagged as variety #[seed.uid].")

/obj/item/seeds/cutting
	name = "cuttings"
	desc = "Some plant cuttings."

/obj/item/seeds/cutting/update_appearance()
	. = ..()
	name = "packet of [seed.seed_name] cuttings"
/*
/obj/item/seeds/random
	seed_type = null

/obj/item/seeds/random/New()
	seed = new()
	seed.randomize()

	seed.uid = seed_types.len + 1
	seed.name = "[seed.uid]"
	seed_types[seed.name] = seed

	update_seed()
*/
/obj/item/seeds/poppyseed
	name = "packet of poppy seeds"
	seed_type = "poppies"

/obj/item/seeds/chiliseed
	name = "packet of chili seeds"
	seed_type = "chili"

/obj/item/seeds/plastiseed
	name = "packet of plastic seeds"
	seed_type = "plastic"

/obj/item/seeds/grapeseed
	name = "packet of grape seeds"
	seed_type = "grapes"

/obj/item/seeds/greengrapeseed
	name = "packet of green grape seeds"
	seed_type = "greengrapes"

/obj/item/seeds/peanutseed
	name = "packet of peanut seeds"
	seed_type = "peanut"

/obj/item/seeds/cabbageseed
	name = "packet of cabbage seeds"
	seed_type = "cabbage"

/obj/item/seeds/shandseed
	name = "packet of shand seeds"
	seed_type = "shand"

/obj/item/seeds/mtearseed
	name = "packet of Messa's tear seeds"
	seed_type = "mtear"

/obj/item/seeds/berryseed
	name = "packet of berry seeds"
	seed_type = "berries"

/obj/item/seeds/glowberryseed
	name = "packet of glowberry seeds"
	seed_type = "glowberries"

/obj/item/seeds/bananaseed
	name = "packet of banana seeds"
	seed_type = "banana"

/obj/item/seeds/eggplantseed
	name = "packet of eggplant seeds"
	seed_type = "eggplant"

/obj/item/seeds/eggyseed
	name = "packet of egg plant seeds"
	seed_type = "realeggplant"

/obj/item/seeds/bloodtomatoseed
	name = "packet of blood tomato seeds"
	seed_type = "bloodtomato"

/obj/item/seeds/tomatoseed
	name = "packet of tomato seeds"
	seed_type = "tomato"

/obj/item/seeds/killertomatoseed
	name = "packet of killer tomato seeds"
	seed_type = "killertomato"

/obj/item/seeds/bluetomatoseed
	name = "packet of blue tomato seeds"
	seed_type = "bluetomato"

/obj/item/seeds/bluespacetomatoseed
	name = "packet of bluespace tomato seeds"
	seed_type = "bluespacetomato"

/obj/item/seeds/cornseed
	name = "packet of corn seeds"
	seed_type = "corn"

/obj/item/seeds/poppyseed
	name = "packet of poppy seeds"
	seed_type = "poppies"

/obj/item/seeds/potatoseed
	name = "packet of potato seeds"
	seed_type = "potato"

/obj/item/seeds/icepepperseed
	name = "packet of ice chilli seeds"
	seed_type = "icechili"

/obj/item/seeds/soyaseed
	name = "packet of soybean seeds"
	seed_type = "soybean"

/obj/item/seeds/wheatseed
	name = "packet of wheat seeds"
	seed_type = "wheat"

/obj/item/seeds/riceseed
	name = "packet of rice seeds"
	seed_type = "rice"

/obj/item/seeds/carrotseed
	name = "packet of carrot seeds"
	seed_type = "carrot"

/obj/item/seeds/reishimycelium
	name = "packet of reishi seeds"
	seed_type = "reishi"

/obj/item/seeds/amanitamycelium
	name = "packet of amanita seeds"
	seed_type = "amanita"

/obj/item/seeds/angelmycelium
	name = "packet of destroying angel seeds"
	seed_type = "destroyingangel"

/obj/item/seeds/libertymycelium
	name = "packet of liberty cap seeds"
	seed_type = "libertycap"

/obj/item/seeds/chantermycelium
	name = "packet of mushrooms seeds"
	seed_type = "mushrooms"

/obj/item/seeds/towermycelium
	name = "packet of towercap seeds"
	seed_type = "towercap"

/obj/item/seeds/glowshroom
	name = "packet of glowshroom seeds"
	seed_type = "glowshroom"

/obj/item/seeds/plumpmycelium
	name = "packet of plump helmet seeds"
	seed_type = "plumphelmet"

/obj/item/seeds/walkingmushroommycelium
	name = "packet of walking mushroom seeds"
	seed_type = "walkingmushroom"

/obj/item/seeds/nettleseed
	name = "packet of nettle seeds"
	seed_type = "nettle"

/obj/item/seeds/deathnettleseed
	name = "packet of deathnettle seeds"
	seed_type = "deathnettle"

/obj/item/seeds/weeds
	name = "packet of weeds seeds"
	seed_type = "weeds"

/obj/item/seeds/harebell
	name = "packet of harebell seeds"
	seed_type = "harebells"

/obj/item/seeds/sunflowerseed
	name = "packet of sunflower seeds"
	seed_type = "sunflowers"

/obj/item/seeds/brownmold
	name = "packet of mold seeds"
	seed_type = "mold"

/obj/item/seeds/appleseed
	name = "packet of apple seeds"
	seed_type = "apple"

/obj/item/seeds/poisonedappleseed
	name = "packet of poison apple seeds"
	seed_type = "poisonapple"

/obj/item/seeds/goldappleseed
	name = "packet of gold apple seeds"
	seed_type = "goldapple"

/obj/item/seeds/ambrosiavulgarisseed
	name = "packet of ambrosia seeds"
	seed_type = "ambrosia"

/obj/item/seeds/ambrosiadeusseed
	name = "packet of ambrosia deus seeds"
	seed_type = "ambrosiadeus"

/obj/item/seeds/whitebeetseed
	name = "packet of white beet seeds"
	seed_type = "whitebeet"

/obj/item/seeds/sugarcaneseed
	name = "packet of sugarcane seeds"
	seed_type = "sugarcane"

/obj/item/seeds/watermelonseed
	name = "packet of watermelon seeds"
	seed_type = "watermelon"

/obj/item/seeds/pumpkinseed
	name = "packet of pumpkin seeds"
	seed_type = "pumpkin"

/obj/item/seeds/limeseed
	name = "packet of lime seeds"
	seed_type = "lime"

/obj/item/seeds/lemonseed
	name = "packet of lemon seeds"
	seed_type = "lemon"

/obj/item/seeds/orangeseed
	name = "packet of orange seeds"
	seed_type = "orange"

/obj/item/seeds/poisonberryseed
	name = "packet of poison berry seeds"
	seed_type = "poisonberries"

/obj/item/seeds/deathberryseed
	name = "packet of death berry seeds"
	seed_type = "deathberries"

/obj/item/seeds/grassseed
	name = "packet of grass seeds"
	seed_type = "grass"

/obj/item/seeds/cocoapodseed
	name = "packet of cocoa seeds"
	seed_type = "cocoa"

/obj/item/seeds/cherryseed
	name = "packet of cherry seeds"
	seed_type = "cherry"

/obj/item/seeds/kudzuseed
	name = "packet of kudzu seeds"
	seed_type = "kudzu"