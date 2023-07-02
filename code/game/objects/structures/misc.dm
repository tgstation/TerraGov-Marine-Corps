/obj/structure/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = TRUE
	anchored = TRUE
	coverage = 15

/obj/structure/showcase/two
	icon_state = "showcase_2"

/obj/structure/showcase/three
	icon_state = "showcase_3"

/obj/structure/showcase/four
	icon_state = "showcase_4"
	desc = "A stand with the empty shell of a mech bolted to it."

/obj/structure/showcase/five
	icon_state = "showcase_5"
	desc = "A stand with the empty shell of a mech bolted to it."

/obj/structure/showcase/six
	icon_state = "showcase_6"

/obj/structure/showcase/coinpress
	icon_state = "coinpress0"

/obj/machinery/showcase/mulebot
	name = "Mulebot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"

/obj/structure/showcase/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)

/obj/structure/showcase/yaut
	name = "alien sarcophagus"
	desc = "An ancient, dusty tomb with strange alien writing. It's best not to touch it."
	icon_state = "yaut"

/obj/structure/monorail
	name = "monorail track"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "monorail"
	density = FALSE
	anchored = TRUE
	layer = ATMOS_PIPE_LAYER + 0.01

/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	anchored = FALSE
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 40
	var/amount_per_transfer_from_this = 5 //Shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/Initialize(mapload)
	. = ..()
	create_reagents(100, OPENCONTAINER)

/obj/structure/mopbucket/examine(mob/user)
	. = ..()
	. += "It contains [reagents.total_volume] unit\s of water!"

/obj/structure/mopbucket/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/mop))
		if(reagents.total_volume < 1)
			to_chat(user, span_warning("[src] is out of water!"))
			return

		reagents.trans_to(I, 5)
		to_chat(user, span_notice("You wet [I] in [src]."))
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

/obj/structure/shipmast
	name = "\the Ships Mast"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "shipmast" //Thank you to Spyroshark and Arachnidnexus
	desc = "A piece of old earth that was. The plaque reads<br><br><span class='name'>HMS Victory Sailed 1765 to 1922.</span><br><span class='name'>Relaunched 2393.</span><br><span class='name'>On loan from the First Sea Lord.</span><br><br>"
	layer = ABOVE_MOB_LAYER
	density = TRUE
	anchored = TRUE

/obj/structure/shipmast/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	switch(user.a_intent)
		if(INTENT_HELP)
			visible_message("[usr] rubs the [src] for good luck.")
		if(INTENT_DISARM)
			visible_message("[usr] pushes the [src]. It's surprisingly solid.")
		if(INTENT_GRAB)
			visible_message("[usr] hugs the [src].")
		if(INTENT_HARM)
			visible_message("[usr] punches the [src] while letting out a muttered curse.")

//ICE COLONY RESEARCH DECORATION-----------------------//
//Most of icons made by ~Morrinn
/obj/structure/xenoautopsy
	name = "Research thingies"
	icon = 'icons/obj/alien_autopsy.dmi'
	icon_state = "jarshelf_9"

/obj/structure/xenoautopsy/jar_shelf
	name = "jar shelf"
	icon_state = "jarshelf_0"
	var/randomise = 1 //Random icon

/obj/structure/xenoautopsy/jar_shelf/Initialize(mapload)
	. = ..()
	if(randomise)
		icon_state = "jarshelf_[rand(0,9)]"

/obj/structure/xenoautopsy/tank
	name = "cryo tank"
	icon_state = "tank_empty"
	desc = "It is empty."
	density = TRUE
	max_integrity = 100
	resistance_flags = UNACIDABLE
	hit_sound = 'sound/effects/Glasshit.ogg'
	destroy_sound = "shatter"
	///Whatever is contained in the tank
	var/obj/occupant
	///What this tank is replaced by when broken
	var/obj/structure/broken_state = /obj/structure/xenoautopsy/tank/escaped


/obj/structure/xenoautopsy/tank/deconstruct(disassembled = TRUE)
	if(!broken_state)
		return ..()

	new broken_state(loc)
	new /obj/item/shard(loc)

	release_occupant()

	return ..()

/obj/structure/xenoautopsy/tank/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			take_damage(100, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(50, BRUTE, BOMB)

///Releases whatever is inside the tank
/obj/structure/xenoautopsy/tank/proc/release_occupant()
	if(occupant)
		new occupant(loc)

/obj/structure/xenoautopsy/tank/escaped
	name = "broken cryo tank"
	icon_state = "tank_escaped"
	desc = "Something broke it..."
	broken_state = null

/obj/structure/xenoautopsy/tank/broken
	icon_state = "tank_broken"
	desc = "Something broke it..."
	broken_state = null

/obj/structure/xenoautopsy/tank/alien
	icon_state = "tank_alien"
	desc = "There is something big inside..."
	occupant = /obj/item/alien_embryo

/obj/structure/xenoautopsy/tank/hugger
	icon_state = "tank_hugger"
	desc = "There is something spider-like inside..."
	occupant = /obj/item/clothing/mask/facehugger

/obj/structure/xenoautopsy/tank/hugger/release_occupant()
	var/obj/item/clothing/mask/facehugger/hugger = new occupant(loc)
	hugger.go_active()

/obj/structure/xenoautopsy/tank/larva
	icon_state = "tank_larva"
	desc = "There is something worm-like inside..."
	occupant = /obj/item/alien_embryo
	broken_state = /obj/structure/xenoautopsy/tank/broken

/obj/item/alienjar
	name = "sample jar"
	icon = 'icons/obj/alien_autopsy.dmi'
	icon_state = "jar_sample"
	desc = "Used to store organic samples inside for preservation."

/obj/item/alienjar/Initialize(mapload)
	. = ..()

	var/image/sample_image = image('icons/obj/alien_autopsy.dmi', "sample_[rand(0,11)]")
	sample_image.layer = layer - 0.1
	add_overlay(sample_image)
	pixel_x += rand(-3,3)
	pixel_y += rand(-3,3)




//stairs

/obj/structure/stairs
	name = "Stairs"
	icon = 'icons/obj/structures/structures.dmi'
	desc = "Stairs.  You walk up and down them."
	icon_state = "rampbottom"
	layer = TURF_LAYER
	density = FALSE
	opacity = FALSE

/obj/structure/stairs/seamless
	icon_state = "stairs_seamless"

/obj/structure/stairs/seamless/platform
	icon_state = "railstairs_seamless"

/obj/structure/stairs/seamless/platform/alt
	icon_state = "railstairs_seamless_vert"

/obj/structure/stairs/seamless/platform/adobe //west and east
	icon_state = "adobe_stairs"

/obj/structure/stairs/seamless/platform/adobe/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/stairs/seamless/platform/adobe/update_overlays()
	. = ..()
	if(dir == WEST || dir == EAST)
		var/image/new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, dir)
		new_overlay.layer = ABOVE_MOB_PLATFORM_LAYER
		. += new_overlay

/obj/structure/stairs/seamless/platform/adobe/straight
	icon_state = "adobe_stairs_straight"

/obj/structure/stairs/seamless/platform/adobe_vert //north and west
	icon_state = "adobe_stairs_vertical"

/obj/structure/stairs/seamless/platform/adobe_vert/straight
	icon_state = "adobe_stairs_vertical_straight"

/obj/structure/stairs/corner
	icon_state = "staircorners"

/obj/structure/stairs/cornerdark //darker version for the darkened ramp bottoms
	icon_state = "staircornersdark"

/obj/structure/stairs/cornerdark/seamless //darker version for the darkened ramp bottoms
	icon_state = "staircorners_seamless"

/obj/structure/stairs/railstairs
	icon = 'icons/obj/structures/railstairs.dmi'
	icon_state = "stairdownrailright"

/obj/structure/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "\improper plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = FALSE
	anchored = TRUE
	layer = MOB_LAYER
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 100

/obj/structure/plasticflaps/CanAllowThrough(atom/movable/mover, turf/T)
	if(istype(mover) && CHECK_BITFIELD(mover.pass_flags, PASS_GLASS))
		return prob(60)

	var/obj/structure/bed/B = mover
	if(istype(B) && LAZYLEN(B.buckled_mobs))//if it's a bed/chair and someone is buckled, it will not pass
		return FALSE

	if(istype(mover, /obj/vehicle))	//no vehicles
		return FALSE

	if(isliving(mover)) // You Shall Not Pass!
		var/mob/living/M = mover
		if(!M.lying_angle && !istype(M, /mob/living/simple_animal/mouse) && !istype(M, /mob/living/carbon/xenomorph/larva) && !istype(M, /mob/living/carbon/xenomorph/runner))  //If your not laying down, or a small creature, no pass. //todo kill shitcode
			return FALSE

	return ..()

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)
		if (3)
			if (prob(5))
				qdel(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "\improper Airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

/obj/structure/plasticflaps/sturdy //Anti-unga flaps
	desc = "Plastic flaps for transporting supplies."
	obj_flags = null
	resistance_flags = XENO_DAMAGEABLE


	//Magmoor Cryopods

/obj/structure/cryopods
	name = "hypersleep chamber"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scanner_0"
	desc = "A large automated capsule with LED displays intended to put anyone inside into 'hypersleep'."
	density = TRUE
	anchored = TRUE
	coverage = 15
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/tankholder
	name = "tank holder"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "holder"
	desc = "A metallic frame that can hold tanks and extinguishers."
	density = TRUE
	anchored = TRUE
	coverage = 15
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/tankholder/oxygen
	icon_state = "holder_oxygen"

/obj/structure/tankholder/oxygentwo
	icon_state = "holder_oxygen_f"

/obj/structure/tankholder/oxygenthree
	icon_state = "holder_oxygen_fr"

/obj/structure/tankholder/generic
	icon_state = "holder_generic"

/obj/structure/tankholder/extinguisher
	icon_state = "holder_extinguisher"

/obj/structure/tankholder/foamextinguisher
	icon_state = "holder_foam_extinguisher"

/obj/structure/tankholder/anesthetic
	icon_state = "holder_anesthetic"

/obj/structure/tankholder/emergencyoxygen
	icon_state = "holder_anesthetic"

/obj/structure/tankholder/emergencyoxygentwo
	icon_state = "holder_emergency_engi"

