/obj/structure/flora
	anchored = TRUE
	var/health = 25
	var/health_max = 25
	var/on_fire = FALSE

/obj/structure/flora/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(70))
				qdel(src)
		if(3)
			if(prob(50))
				qdel(src)

/obj/structure/flora/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/flora/attackby(obj/item/W, mob/living/user)
	if(!W || !user || (W.flags_item & NOBLUDGEON))
		return FALSE

	var/damage = W.force
	if(W.w_class < 3 || !W.sharp || W.force < 20) //only big strong sharp weapon are adequate
		damage *= 0.25

	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W

		if(WT.remove_fuel(5))
			damage = 25
			playsound(loc, 'sound/items/Welder.ogg', 25, 1)

	else
		playsound(loc, "alien_resin_break", 25)
	user.animation_attack_on(src)

	var/multiplier = 1
	if(W.damtype == "fire") //Burn damage deals extra
		multiplier += 1

/obj/structure/flora/update_icon()
	return

/obj/structure/flora/flamer_fire_act()
	if(on_fire)
		return
	on_fire = TRUE
	START_PROCESSING(SSobj, src)

/obj/structure/flora/process()
	if(health <= 0)
		qdel(src)
	if(!on_fire)
		STOP_PROCESSING(SSobj, src)
	else
		health -= 25

//TREES

/obj/structure/flora/tree
	name = "tree"
	desc = "A large tree."
	density = TRUE
	pixel_x = -16
	health = 500
	health_max = 500
	layer = ABOVE_FLY_LAYER
	var/log_amount = 10

/obj/structure/flora/tree/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= 500
		if(2.0)
			health -= (rand(140, 300))
		if(3.0)
			health -= (rand(50, 100))
	START_PROCESSING(SSobj, src)
	return

/obj/structure/flora/tree/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage * 0.5
	. = ..()
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/structure/flora/tree/attackby(obj/item/W, mob/user, params)
	if(W.sharp && W.force > 0)
		if(W.hitsound)
			playsound(get_turf(src), W.hitsound, 100, 0, 0)
		user.visible_message("<span class='notice'>[user] begins to cut down [src] with [W].</span>","<span class='notice'>You begin to cut down [src] with [W].</span>", "You hear the sound of sawing.")
		var/cut_force = min(1, W.force)
		var/cutting_time = CLAMP(10, 20, 100/cut_force) SECONDS
		if(do_after(usr, cutting_time , TRUE, 5, BUSY_ICON_BUILD))
			user.visible_message("<span class='notice'>[user] fells [src] with the [W].</span>","<span class='notice'>You fell [src] with the [W].</span>", "You hear the sound of a tree falling.")
			playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 60 , 0, 0)
			for(var/i=1 to log_amount)
				new /obj/item/grown/log(get_turf(src))

			var/obj/structure/flora/stump/S = new(loc)
			S.name = "[name] stump"

			qdel(src)

	else
		return ..()

/obj/structure/flora/tree/flamer_fire_act()
	if(on_fire == FALSE)
		on_fire = TRUE
		SetLuminosity(5)
	START_PROCESSING(SSobj, src)
	update_icon()


/obj/structure/flora/tree/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "fire"

/obj/structure/flora/tree/process()
	if(health <= 0)
		density = 0
		var/obj/structure/flora/stump/S = new(loc)
		S.name = "[name] stump"
		STOP_PROCESSING(SSobj, src)
		qdel(src)
	if(!on_fire)
		STOP_PROCESSING(SSobj, src)
	else
		health -= 5
	return ..()

/obj/structure/flora/stump
	name = "stump"
	desc = "This represents our promise to cut down as many trees as possible."
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_stump"
	density = FALSE
	pixel_x = -16

/obj/structure/flora/stump/flamer_fire_act()
	return

/obj/structure/flora/tree/pine
	name = "pine tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine"

/obj/structure/flora/tree/pine/New()
	..()
	icon_state = "[icon_state][rand(1, 3)]"

/obj/structure/flora/tree/xmas
	icon = 'icons/obj/flora/pinetrees.dmi'
	name = "xmas tree"
	icon_state = "pine_c"

/obj/structure/flora/tree/xmas/presents
	icon_state = "pinepresents"
	desc = "A wondrous decorated Christmas tree. It has presents!"
	var/gift_type = /obj/item/m_gift
	var/list/ckeys_that_took = list()

/obj/structure/flora/tree/xmas/presents/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!user.ckey)
		return

	if(ckeys_that_took[user.ckey])
		to_chat(user, "<span class='warning'>There are no presents with your name on.</span>")
		return
	to_chat(user, "<span class='warning'>After a bit of rummaging, you locate a gift with your name on it!</span>")
	ckeys_that_took[user.ckey] = TRUE
	var/obj/item/G = new gift_type(src)
	user.put_in_hands(G)

/obj/structure/flora/tree/dead
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree"

/obj/structure/flora/tree/dead/New()
	..()
	icon_state = "[icon_state][rand(1, 6)]"

/obj/structure/flora/tree/joshua
	name = "joshua tree"
	desc = "A tall tree covered in spiky-like needles, covering it's trunk."
	icon = 'icons/obj/flora/joshuatree.dmi'
	icon_state = "joshua"
	pixel_x = 0

/obj/structure/flora/tree/joshua/New()
	..()
	icon_state = "[icon_state][rand(1,4)]"

/obj/structure/flora/tree/jungle
	name = "tree"
	icon_state = "tree"
	desc = "It's seriously hampering your view of the jungle."
	icon = 'icons/obj/flora/jungletrees.dmi'
	pixel_x = -48
	pixel_y = -20

/obj/structure/flora/tree/jungle/small
	pixel_y = 0
	pixel_x = -32
	icon = 'icons/obj/flora/jungletreesmall.dmi'

/obj/structure/flora/tree/jungle/New()
	icon_state = "[icon_state][rand(1, 6)]"
	. = ..()

//GRASS

/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	anchored = 1

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/flora/grass/brown/New()
	icon_state = "snowgrass[rand(1, 3)]bb"
	. = ..()

/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/structure/flora/grass/green/New()
	icon_state = "snowgrass[rand(1, 3)]gb"
	. = ..()

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"

/obj/structure/flora/grass/both/New()
	icon_state = "snowgrassall[rand(1, 3)]"
	. = ..()

//bushes
/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	anchored = 1

/obj/structure/flora/bush/New()
	icon_state = "snowbush[rand(1, 6)]"
	. = ..()

/obj/structure/flora/pottedplant
	name = "potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-26"

/obj/structure/flora/pottedplant/ten
	icon_state = "plant-10"
	
//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	anchored = 1

/obj/structure/flora/ausbushes/New()
	icon_state = "firstbush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush_1"

/obj/structure/flora/ausbushes/reedbush/New()
	icon_state = "reedbush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/New()
	icon_state = "leafybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/New()
	icon_state = "palebush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/New()
	icon_state = "stalkybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/New()
	icon_state = "grassybush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/New()
	icon_state = "fernybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/New()
	icon_state = "sunnybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/New()
	icon_state = "genericbush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/New()
	icon_state = "pointybush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass_1"

/obj/structure/flora/ausbushes/lavendergrass/New()
	icon_state = "lavendergrass_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers_1"

/obj/structure/flora/ausbushes/ywflowers/New()
	icon_state = "ywflowers_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers_1"

/obj/structure/flora/ausbushes/brflowers/New()
	icon_state = "brflowers_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers_1"

/obj/structure/flora/ausbushes/ppflowers/New()
	icon_state = "ppflowers_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass_1"

/obj/structure/flora/ausbushes/sparsegrass/New()
	icon_state = "sparsegrass_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/New()
	icon_state = "fullgrass_[rand(1, 3)]"
	. = ..()


//Desert (Desert Dam)
//*********************//
// Generic undergrowth //
//*********************//
/obj/structure/flora/desert
	anchored = 1
	icon = 'icons/obj/flora/dam.dmi'
	var/icon_tag = null
	var/variations = null

/obj/structure/flora/desert/New()
	..()
	icon_state = "[icon_tag]_[rand(1,variations)]"

//GRASS
/obj/structure/flora/desert/grass
	name = "grass"
	icon_state = "lightgrass_1"
	icon_tag = "lightgrass"
	variations = 12

/obj/structure/flora/desert/grass/heavy
	icon_state = "heavygrass_1"
	icon_tag = "heavygrass"
	variations = 16

//BUSHES
/obj/structure/flora/desert/bush
	name = "bush"
	desc = "A small, leafy bush."
	icon_state = "tree_1"
	icon_tag = "tree"
	variations = 4

//CACTUS
/obj/structure/flora/desert/cactus
	name = "cactus"
	desc = "It's a small, spiky cactus."
	icon_state = "cactus_1"
	icon_tag = "cactus"
	variations = 12

/obj/structure/flora/desert/cactus/multiple
	name = "cacti"
	icon_state = "cactus_1"
	icon_tag = "cacti"


//Jungle (Whiskey Outpost)

//*********************//
// Generic undergrowth //
//*********************//

/obj/structure/jungle
	name = "jungle foliage"
	icon = 'icons/turf/ground_map.dmi'
	density = 0
	anchored = 1
	unacidable = 1 // can toggle it off anyway
	layer = ABOVE_MOB_LAYER

/obj/structure/jungle/shrub
	name = "jungle foliage"
	desc = "Pretty thick scrub, it'll take something sharp and a lot of determination to clear away."
	icon_state = "grass4"

/obj/structure/jungle/plantbot1
	name = "strange tree"
	desc = "Some kind of bizarre alien tree. It oozes with a sickly yellow sap."
	icon_state = "plantbot1"

/obj/structure/jungle/plantbot1/alien
	icon_state = "alienplant1"
	luminosity = 2

/obj/structure/jungle/planttop1
	name = "strange tree"
	desc = "Some kind of bizarre alien tree. It oozes with a sickly yellow sap."
	icon_state = "planttop1"

/obj/structure/jungle/vines
	name = "vines"
	desc = "A mass of twisted vines."
	icon = 'icons/effects/spacevines.dmi'

/obj/structure/jungle/vines/attackby(obj/item/W, mob/living/user)
	if(W.sharp == IS_SHARP_ITEM_BIG)
		to_chat(user, "<span class='warning'>You cut \the [src] away with \the [W].</span>")
		user.animation_attack_on(src)
		playsound(src, 'sound/effects/vegetation_hit.ogg', 25, 1)
		qdel(src)
	else
		. = ..()

/obj/structure/jungle/vines/Initialize()
	. = ..()
	icon_state = pick("Light1","Light2","Light3")

/obj/structure/jungle/vines/heavy
	desc = "A thick, coiled mass of twisted vines."
	opacity = 1

/obj/structure/jungle/vines/heavy/Initialize()
	. = ..()
	icon_state = pick("Hvy1","Hvy2","Hvy3","Med1","Med2","Med3")

/obj/structure/jungle/tree/grasscarpet
	name = "thick grass"
	desc = "A thick mat of dense grass."
	icon_state = "grasscarpet"
	layer = BELOW_MOB_LAYER
