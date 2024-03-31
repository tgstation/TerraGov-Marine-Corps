// Citrus - base type
/obj/item/reagent_containers/food/snacks/grown/citrus
	seed = /obj/item/seeds/lime
	name = "citrus"
	desc = ""
	icon_state = "lime"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 30

// Lime
/obj/item/seeds/lime
	name = "pack of lime seeds"
	desc = ""
	icon_state = "seed"
	species = "lime"
	plantname = "Lime Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/lime
	lifespan = 55
	endurance = 50
	yield = 4
	potency = 15
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/orange)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/citrus/lime
	seed = /obj/item/seeds/lime
	name = "lime"
	desc = ""
	icon_state = "lime"
	filling_color = "#00FF00"
	juice_results = list(/datum/reagent/consumable/limejuice = 0)

// Orange
/obj/item/seeds/orange
	name = "pack of orange seeds"
	desc = ""
	icon_state = "seed"
	species = "orange"
	plantname = "Orange Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/orange
	lifespan = 60
	endurance = 50
	yield = 5
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/lime, /obj/item/seeds/orange_3d)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/citrus/orange
	seed = /obj/item/seeds/orange
	name = "orange"
	desc = ""
	icon_state = "orange"
	filling_color = "#FFA500"
	juice_results = list(/datum/reagent/consumable/orangejuice = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/triple_sec

// Lemon
/obj/item/seeds/lemon
	name = "pack of lemon seeds"
	desc = ""
	icon_state = "seed"
	species = "lemon"
	plantname = "Lemon Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	lifespan = 55
	endurance = 45
	yield = 4
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/firelemon)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	seed = /obj/item/seeds/lemon
	name = "lemon"
	desc = ""
	icon_state = "lemon"
	filling_color = "#FFD700"
	juice_results = list(/datum/reagent/consumable/lemonjuice = 0)

// Combustible lemon
/obj/item/seeds/firelemon //combustible lemon is too long so firelemon
	name = "pack of combustible lemon seeds"
	desc = ""
	icon_state = "seed"
	species = "firelemon"
	plantname = "Combustible Lemon Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/firelemon
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	lifespan = 55
	endurance = 45
	yield = 4
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/firelemon
	seed = /obj/item/seeds/firelemon
	name = "Combustible Lemon"
	desc = ""
	icon_state = "firelemon"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 70

/obj/item/reagent_containers/food/snacks/grown/firelemon/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] primes [src]!</span>", "<span class='danger'>I prime [src]!</span>")
	log_bomber(user, "primed a", src, "for detonation")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()
	icon_state = "firelemon_active"
	playsound(loc, 'sound/blank.ogg', 75, TRUE, -3)
	addtimer(CALLBACK(src, .proc/prime), rand(10, 60))

/obj/item/reagent_containers/food/snacks/grown/firelemon/burn()
	prime()
	..()

/obj/item/reagent_containers/food/snacks/grown/firelemon/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)

/obj/item/reagent_containers/food/snacks/grown/firelemon/ex_act(severity)
	qdel(src) //Ensuring that it's deleted by its own explosion

/obj/item/reagent_containers/food/snacks/grown/firelemon/proc/prime()
	switch(seed.potency) //Combustible lemons are alot like IEDs, lots of flame, very little bang.
		if(0 to 30)
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 1)
			qdel(src)
		if(31 to 50)
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 2)
			qdel(src)
		if(51 to 70)
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 3)
			qdel(src)
		if(71 to 90)
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 4)
			qdel(src)
		else
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 5)
			qdel(src)

//3D Orange
/obj/item/seeds/orange_3d
	name = "pack of extradimensional orange seeds"
	desc = ""
	icon_state = "seed"
	species = "orange"
	plantname = "Extradimensional Orange Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/orange_3d
	lifespan = 60
	endurance = 50
	yield = 5
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/medicine/haloperidol = 0.15) //insert joke about the effects of haloperidol and our glorious headcoder here

/obj/item/reagent_containers/food/snacks/grown/citrus/orange_3d
	seed = /obj/item/seeds/orange_3d
	name = "extradimensional orange"
	desc = ""
	icon_state = "orang"
	filling_color = "#FFA500"
	juice_results = list(/datum/reagent/consumable/orangejuice = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/triple_sec
	tastes = list("polygons" = 1, "oranges" = 1)

/obj/item/reagent_containers/food/snacks/grown/citrus/orange_3d/pickup(mob/user)
	. = ..()
	icon_state = "orange"

/obj/item/reagent_containers/food/snacks/grown/citrus/orange_3d/dropped(mob/user)
	. = ..()
	icon_state = "orang"
