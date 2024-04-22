// Tomato
/obj/item/seeds/tomato
	name = "pack of tomato seeds"
	desc = ""
	icon_state = "seed"
	species = "tomato"
	plantname = "Tomato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/tomato
	maturation = 8
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "tomato-grow"
	icon_dead = "tomato-dead"
	genes = list(/datum/plant_gene/trait/squash, /datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/tomato/blue, /obj/item/seeds/tomato/blood, /obj/item/seeds/tomato/killer)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/tomato
	seed = /obj/item/seeds/tomato
	name = "tomato"
	desc = ""
	icon_state = "tomato"
	splat_type = /obj/effect/decal/cleanable/food/tomato_smudge
	filling_color = "#FF6347"
	bitesize_mod = 2
	foodtype = FRUIT
	grind_results = list(/datum/reagent/consumable/ketchup = 0)
	juice_results = list(/datum/reagent/consumable/tomatojuice = 0)
	distill_reagent = /datum/reagent/consumable/enzyme

// Blood Tomato
/obj/item/seeds/tomato/blood
	name = "pack of blood-tomato seeds"
	desc = ""
	icon_state = "seed"
	species = "bloodtomato"
	plantname = "Blood-Tomato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/tomato/blood
	mutatelist = list()
	reagents_add = list(/datum/reagent/blood = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/tomato/blood
	seed = /obj/item/seeds/tomato/blood
	name = "blood-tomato"
	desc = ""
	icon_state = "bloodtomato"
	splat_type = /obj/effect/gibspawner/generic
	filling_color = "#FF0000"
	foodtype = FRUIT | GROSS
	grind_results = list(/datum/reagent/consumable/ketchup = 0, /datum/reagent/blood = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/bloody_mary

// Blue Tomato
/obj/item/seeds/tomato/blue
	name = "pack of blue-tomato seeds"
	desc = ""
	icon_state = "seed"
	species = "bluetomato"
	plantname = "Blue-Tomato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/tomato/blue
	yield = 2
	icon_grow = "bluetomato-grow"
	mutatelist = list(/obj/item/seeds/tomato/blue/bluespace)
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/lube = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/tomato/blue
	seed = /obj/item/seeds/tomato/blue
	name = "blue-tomato"
	desc = ""
	icon_state = "bluetomato"
	splat_type = /obj/effect/decal/cleanable/oil
	filling_color = "#0000FF"
	distill_reagent = /datum/reagent/consumable/laughter

// Bluespace Tomato
/obj/item/seeds/tomato/blue/bluespace
	name = "pack of bluespace tomato seeds"
	desc = ""
	icon_state = "seed"
	species = "bluespacetomato"
	plantname = "Bluespace Tomato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/tomato/blue/bluespace
	yield = 2
	mutatelist = list()
	genes = list(/datum/plant_gene/trait/squash, /datum/plant_gene/trait/slip, /datum/plant_gene/trait/teleport, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/lube = 0.2, /datum/reagent/bluespace = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 50

/obj/item/reagent_containers/food/snacks/grown/tomato/blue/bluespace
	seed = /obj/item/seeds/tomato/blue/bluespace
	name = "bluespace tomato"
	desc = ""
	icon_state = "bluespacetomato"
	distill_reagent = null
	wine_power = 80

// Killer Tomato
/obj/item/seeds/tomato/killer
	name = "pack of killer-tomato seeds"
	desc = ""
	icon_state = "seed"
	species = "killertomato"
	plantname = "Killer-Tomato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/tomato/killer
	yield = 2
	genes = list(/datum/plant_gene/trait/squash)
	growthstages = 2
	icon_grow = "killertomato-grow"
	icon_harvest = "killertomato-harvest"
	icon_dead = "killertomato-dead"
	mutatelist = list()
	rarity = 30

/obj/item/reagent_containers/food/snacks/grown/tomato/killer
	seed = /obj/item/seeds/tomato/killer
	name = "killer-tomato"
	desc = ""
	icon_state = "killertomato"
	var/awakening = 0
	filling_color = "#FF0000"
	distill_reagent = /datum/reagent/consumable/ethanol/demonsblood

/obj/item/reagent_containers/food/snacks/grown/tomato/killer/attack(mob/M, mob/user, def_zone)
	if(awakening)
		to_chat(user, "<span class='warning'>The tomato is twitching and shaking, preventing you from eating it.</span>")
		return
	..()

/obj/item/reagent_containers/food/snacks/grown/tomato/killer/attack_self(mob/user)
	if(awakening || isspaceturf(user.loc))
		return
	to_chat(user, "<span class='notice'>I begin to awaken the Killer Tomato...</span>")
	awakening = TRUE
	addtimer(CALLBACK(src, PROC_REF(awaken)), 3 SECONDS)
	log_game("[key_name(user)] awakened a killer tomato at [AREACOORD(user)].")

/obj/item/reagent_containers/food/snacks/grown/tomato/killer/proc/awaken()
	if(QDELETED(src))
		return
	var/mob/living/simple_animal/hostile/killertomato/K = new /mob/living/simple_animal/hostile/killertomato(get_turf(src.loc))
	K.maxHealth += round(seed.endurance / 3)
	K.melee_damage_lower += round(seed.potency / 10)
	K.melee_damage_upper += round(seed.potency / 10)
	K.move_to_delay -= round(seed.production / 50)
	K.health = K.maxHealth
	K.visible_message("<span class='notice'>The Killer Tomato growls as it suddenly awakens.</span>")
	qdel(src)
