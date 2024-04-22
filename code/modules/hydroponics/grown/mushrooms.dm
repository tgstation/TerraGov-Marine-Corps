/obj/item/reagent_containers/food/snacks/grown/mushroom
	name = "mushroom"
	bitesize_mod = 2
	foodtype = VEGETABLES
	wine_power = 40

// Reishi
/obj/item/seeds/reishi
	name = "pack of reishi mycelium"
	desc = ""
	icon_state = "mycelium-reishi"
	species = "reishi"
	plantname = "Reishi"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/reishi
	lifespan = 35
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 15
	growthstages = 4
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/medicine/morphine = 0.35, /datum/reagent/medicine/C2/multiver = 0.35, /datum/reagent/consumable/nutriment = 0)

/obj/item/reagent_containers/food/snacks/grown/mushroom/reishi
	seed = /obj/item/seeds/reishi
	name = "reishi"
	desc = ""
	icon_state = "reishi"
	filling_color = "#FF4500"


// Fly Amanita
/obj/item/seeds/amanita
	name = "pack of fly amanita mycelium"
	desc = ""
	icon_state = "mycelium-amanita"
	species = "amanita"
	plantname = "Fly Amanitas"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/amanita
	lifespan = 50
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	mutatelist = list(/obj/item/seeds/angel)
	reagents_add = list(/datum/reagent/drug/mushroomhallucinogen = 0.04, /datum/reagent/toxin/amatoxin = 0.35, /datum/reagent/consumable/nutriment = 0, /datum/reagent/growthserum = 0.1)

/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita
	seed = /obj/item/seeds/amanita
	name = "fly amanita"
	desc = ""
	icon_state = "amanita"
	filling_color = "#FF0000"

// Destroying Angel
/obj/item/seeds/angel
	name = "pack of destroying angel mycelium"
	desc = ""
	icon_state = "mycelium-angel"
	species = "angel"
	plantname = "Destroying Angels"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/angel
	lifespan = 50
	endurance = 35
	maturation = 12
	production = 5
	yield = 2
	potency = 35
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/drug/mushroomhallucinogen = 0.04, /datum/reagent/toxin/amatoxin = 0.1, /datum/reagent/consumable/nutriment = 0, /datum/reagent/toxin/amanitin = 0.2)
	rarity = 30

/obj/item/reagent_containers/food/snacks/grown/mushroom/angel
	seed = /obj/item/seeds/angel
	name = "destroying angel"
	desc = ""
	icon_state = "angel"
	filling_color = "#C0C0C0"
	wine_power = 60

// Liberty Cap
/obj/item/seeds/liberty
	name = "pack of liberty-cap mycelium"
	desc = ""
	icon_state = "mycelium-liberty"
	species = "liberty"
	plantname = "Liberty-Caps"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap
	maturation = 7
	production = 1
	yield = 5
	potency = 15
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/drug/mushroomhallucinogen = 0.25, /datum/reagent/consumable/nutriment = 0.02)

/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap
	seed = /obj/item/seeds/liberty
	name = "liberty-cap"
	desc = ""
	icon_state = "libertycap"
	filling_color = "#DAA520"
	wine_power = 80

// Plump Helmet
/obj/item/seeds/plump
	name = "pack of plump-helmet mycelium"
	desc = ""
	icon_state = "mycelium-plump"
	species = "plump"
	plantname = "Plump-Helmet Mushrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	maturation = 8
	production = 1
	yield = 4
	potency = 15
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	mutatelist = list(/obj/item/seeds/plump/walkingmushroom)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	seed = /obj/item/seeds/plump
	name = "plump-helmet"
	desc = ""
	icon_state = "plumphelmet"
	filling_color = "#9370DB"
	distill_reagent = /datum/reagent/consumable/ethanol/manly_dorf

// Walking Mushroom
/obj/item/seeds/plump/walkingmushroom
	name = "pack of walking mushroom mycelium"
	desc = ""
	icon_state = "mycelium-walkingmushroom"
	species = "walkingmushroom"
	plantname = "Walking Mushrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	lifespan = 30
	endurance = 30
	maturation = 5
	yield = 1
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	mutatelist = list()
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.05, /datum/reagent/consumable/nutriment = 0.15)
	rarity = 30

/obj/item/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	seed = /obj/item/seeds/plump/walkingmushroom
	name = "walking mushroom"
	desc = ""
	icon_state = "walkingmushroom"
	filling_color = "#9370DB"
	can_distill = FALSE

/obj/item/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/attack_self(mob/user)
	if(isspaceturf(user.loc))
		return
	var/mob/living/simple_animal/hostile/mushroom/M = new /mob/living/simple_animal/hostile/mushroom(user.loc)
	M.maxHealth += round(seed.endurance / 4)
	M.melee_damage_lower += round(seed.potency / 20)
	M.melee_damage_upper += round(seed.potency / 20)
	M.move_to_delay -= round(seed.production / 50)
	M.health = M.maxHealth
	qdel(src)
	to_chat(user, "<span class='notice'>I plant the walking mushroom.</span>")


// Chanterelle
/obj/item/seeds/chanter
	name = "pack of chanterelle mycelium"
	desc = ""
	icon_state = "mycelium-chanter"
	species = "chanter"
	plantname = "Chanterelle Mushrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle
	lifespan = 35
	endurance = 20
	maturation = 7
	production = 1
	yield = 5
	potency = 15
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1)
	mutatelist = list(/obj/item/seeds/chanterelle/jupitercup)

/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle
	seed = /obj/item/seeds/chanter
	name = "chanterelle cluster"
	desc = ""
	icon_state = "chanterelle"
	filling_color = "#FFA500"

//Jupiter Cup
/obj/item/seeds/chanterelle/jupitercup
	name = "pack of jupiter cup mycelium"
	desc = ""
	icon_state = "mycelium-jupitercup"
	species = "jupitercup"
	plantname = "Jupiter Cups"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/jupitercup
	lifespan = 40
	production = 4
	endurance = 8
	yield = 4
	growthstages = 2
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/reagent/liquidelectricity, /datum/plant_gene/trait/plant_type/carnivory)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1)

/obj/item/seeds/chanterelle/jupitercup/Initialize(mapload,nogenes)
	. = ..()
	if(!nogenes)
		unset_mutability(/datum/plant_gene/reagent/liquidelectricity, PLANT_GENE_EXTRACTABLE)
		unset_mutability(/datum/plant_gene/trait/plant_type/carnivory, PLANT_GENE_REMOVABLE)

/obj/item/reagent_containers/food/snacks/grown/mushroom/jupitercup
	seed = /obj/item/seeds/chanterelle/jupitercup
	name = "jupiter cup"
	desc = ""
	icon_state = "jupitercup"
	filling_color = "#B5003D"

// Glowshroom
/obj/item/seeds/glowshroom
	name = "pack of glowshroom mycelium"
	desc = ""
	icon_state = "mycelium-glowshroom"
	species = "glowshroom"
	plantname = "Glowshrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom
	lifespan = 100 //ten times that is the delay
	endurance = 30
	maturation = 15
	production = 1
	yield = 3 //-> spread
	potency = 30 //-> brightness
	growthstages = 4
	rarity = 20
	genes = list(/datum/plant_gene/trait/glow, /datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	mutatelist = list(/obj/item/seeds/glowshroom/glowcap, /obj/item/seeds/glowshroom/shadowshroom)
	reagents_add = list(/datum/reagent/uranium/radium = 0.1, /datum/reagent/phosphorus = 0.1, /datum/reagent/consumable/nutriment = 0.04)

/obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom
	seed = /obj/item/seeds/glowshroom
	name = "glowshroom cluster"
	desc = ""
	icon_state = "glowshroom"
	filling_color = "#00FA9A"
	var/effect_path = /obj/structure/glowshroom
	wine_power = 50

/obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user)
	if(isspaceturf(user.loc))
		return FALSE
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>I need more space to plant [src].</span>")
		return FALSE
	var/count = 0
	var/maxcount = 1
	for(var/tempdir in GLOB.cardinals)
		var/turf/closed/wall = get_step(user.loc, tempdir)
		if(istype(wall))
			maxcount++
	for(var/obj/structure/glowshroom/G in user.loc)
		count++
	if(count >= maxcount)
		to_chat(user, "<span class='warning'>There are too many shrooms here to plant [src].</span>")
		return FALSE
	new effect_path(user.loc, seed)
	to_chat(user, "<span class='notice'>I plant [src].</span>")
	qdel(src)
	return TRUE


// Glowcap
/obj/item/seeds/glowshroom/glowcap
	name = "pack of glowcap mycelium"
	desc = ""
	icon_state = "mycelium-glowcap"
	species = "glowcap"
	icon_harvest = "glowcap-harvest"
	plantname = "Glowcaps"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom/glowcap
	genes = list(/datum/plant_gene/trait/glow/red, /datum/plant_gene/trait/cell_charge, /datum/plant_gene/trait/plant_type/fungal_metabolism)
	mutatelist = list()
	reagents_add = list(/datum/reagent/teslium = 0.1, /datum/reagent/consumable/nutriment = 0.04)
	rarity = 30

/obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom/glowcap
	seed = /obj/item/seeds/glowshroom/glowcap
	name = "glowcap cluster"
	desc = ""
	icon_state = "glowcap"
	filling_color = "#00FA9A"
	effect_path = /obj/structure/glowshroom/glowcap
	tastes = list("glowcap" = 1)


//Shadowshroom
/obj/item/seeds/glowshroom/shadowshroom
	name = "pack of shadowshroom mycelium"
	desc = ""
	icon_state = "mycelium-shadowshroom"
	species = "shadowshroom"
	icon_grow = "shadowshroom-grow"
	icon_dead = "shadowshroom-dead"
	plantname = "Shadowshrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom/shadowshroom
	genes = list(/datum/plant_gene/trait/glow/shadow, /datum/plant_gene/trait/plant_type/fungal_metabolism)
	mutatelist = list()
	reagents_add = list(/datum/reagent/uranium/radium = 0.2, /datum/reagent/consumable/nutriment = 0.04)
	rarity = 30

/obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom/shadowshroom
	seed = /obj/item/seeds/glowshroom/shadowshroom
	name = "shadowshroom cluster"
	desc = ""
	icon_state = "shadowshroom"
	effect_path = /obj/structure/glowshroom/shadowshroom
	tastes = list("shadow" = 1, "mushroom" = 1)
	wine_power = 60

/obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom/shadowshroom/attack_self(mob/user)
	. = ..()
	if(.)
		investigate_log("was planted by [key_name(user)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
