#define CG_EMPTY 1
#define CG_WIRED 2
#define CG_READY 3

/obj/item/explosive/grenade/chem_grenade
	name = "chemical grenade"
	desc = "A custom made grenade."
	icon_state = "chemg"
	item_state = "flashbang"
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	var/stage = CG_EMPTY
	var/display_timer = FALSE
	var/list/obj/item/reagent_container/glass/beakers = list()
	var/list/allowed_containers = list(/obj/item/reagent_container/glass/beaker, /obj/item/reagent_container/glass/bottle)
	var/list/banned_containers = list(/obj/item/reagent_container/glass/beaker/bluespace) //Containers to exclude from specific grenade subtypes
	var/affected_area = 3
	var/obj/item/assembly_holder/nadeassembly = null
	var/assemblyattacher
	var/ignition_temp = 10 // The amount of heat added to the reagents when this grenade goes off.
	var/threatscale = 1 // Used by advanced grenades to make them slightly more worthy.
	var/no_splash = FALSE //If the grenade deletes even if it has no reagents to splash with. Used for slime core reactions.
	var/casedesc = "This basic model accepts both beakers and bottles. It heats contents by 10°K upon ignition." // Appears when examining empty casings.


/obj/item/explosive/grenade/chem_grenade/Initialize()
	. = ..()
	create_reagents(1000)
	stage_change() // If no argument is set, it will change the stage to the current stage, useful for stock grenades that start READY.


/obj/item/explosive/grenade/chem_grenade/attack_self(mob/user)
	if(stage == CG_READY && !active)
		if(nadeassembly)
			nadeassembly.attack_self(user)
		else
			return ..()


/obj/item/explosive/grenade/chem_grenade/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(stage == CG_WIRED)
			if(!length(beakers))
				to_chat(user, "<span class='warning'>You need to add at least one beaker before locking the [initial(name)] assembly!</span>")
			else
				stage_change(CG_READY)
				to_chat(user, "<span class='notice'>You lock the [initial(name)] assembly.</span>")
				I.play_tool_sound(src, 25)

		else if(stage == CG_READY && !nadeassembly)
			det_time = det_time == 50 ? 30 : 50	//toggle between 30 and 50
			to_chat(user, "<span class='notice'>You modify the time delay. It's set for [DisplayTimeText(det_time)].</span>")
		else if(stage == CG_EMPTY)
			to_chat(user, "<span class='warning'>You need to add an activation mechanism!</span>")

	else if(stage == CG_WIRED && is_type_in_list(I, allowed_containers))
		. = TRUE //no afterattack
		if(is_type_in_list(I, banned_containers))
			to_chat(user, "<span class='warning'>[src] is too small to fit [I]!</span>") // this one hits home huh anon?
			return
		if(length(beakers) == 2)
			to_chat(user, "<span class='warning'>[src] can not hold more containers!</span>")
			return
		else
			if(I.reagents.total_volume)
				if(!user.transferItemToLoc(I, src))
					return
				to_chat(user, "<span class='notice'>You add [I] to the [initial(name)] assembly.</span>")
				beakers += I
				var/reagent_list = pretty_string_from_reagent_list(I.reagents)
				user.log_message("inserted [I] ([reagent_list]) into [src]",LOG_GAME)
			else
				to_chat(user, "<span class='warning'>[I] is empty!</span>")

	else if(stage == CG_EMPTY && istype(I, /obj/item/assembly_holder))
		. = 1 // no afterattack
		var/obj/item/assembly_holder/A = I
		if(isigniter(A.a_left) == isigniter(A.a_right))	//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
			return
		if(!user.transferItemToLoc(I, src))
			return

		nadeassembly = A
		A.master = src
		assemblyattacher = user.ckey

		stage_change(CG_WIRED)
		to_chat(user, "<span class='notice'>You add [A] to the [initial(name)] assembly.</span>")

	else if(stage == CG_EMPTY && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if (C.use(1))
			det_time = 50 // In case the cable_coil was removed and readded.
			stage_change(CG_WIRED)
			to_chat(user, "<span class='notice'>You rig the [initial(name)] assembly.</span>")
		else
			to_chat(user, "<span class='warning'>You need one length of coil to wire the assembly!</span>")
			return

	else if(stage == CG_READY && I.tool_behaviour == TOOL_WIRECUTTER && !active)
		stage_change(CG_WIRED)
		to_chat(user, "<span class='notice'>You unlock the [initial(name)] assembly.</span>")

	else if(stage == CG_WIRED && I.tool_behaviour == TOOL_WRENCH)
		if(length(beakers))
			for(var/obj/O in beakers)
				O.forceMove(drop_location())
				if(!O.reagents)
					continue
				var/reagent_list = pretty_string_from_reagent_list(O.reagents)
				user.log_message("removed [O] ([reagent_list]) from [src]", LOG_GAME)
			beakers = list()
			to_chat(user, "<span class='notice'>You open the [initial(name)] assembly and remove the payload.</span>")
			return // First use of the wrench remove beakers, then use the wrench to remove the activation mechanism.
		if(nadeassembly)
			nadeassembly.forceMove(drop_location())
			nadeassembly.master = null
			nadeassembly = null
		else // If "nadeassembly = null && stage == CG_WIRED", then it most have been cable_coil that was used.
			new /obj/item/stack/cable_coil(get_turf(src),1)
		stage_change(CG_EMPTY)
		to_chat(user, "<span class='notice'>You remove the activation mechanism from the [initial(name)] assembly.</span>")
	else
		return ..()


/obj/item/explosive/grenade/chem_grenade/examine(mob/user)
	display_timer = (stage == CG_READY && !nadeassembly)	//show/hide the timer based on assembly state
	. = ..()
	if(user.mind?.cm_skills && user.mind.cm_skills.medical > SKILL_MEDICAL_NOVICE)
		if(length(beakers))
			to_chat(user, "<span class='notice'>You scan the grenade and detect the following reagents:</span>")
			for(var/obj/item/reagent_container/glass/G in beakers)
				for(var/datum/reagent/R in G.reagents.reagent_list)
					to_chat(user, "<span class='notice'>[R.volume] units of [R.name] in the [G.name].</span>")
			if(length(beakers) == 1)
				to_chat(user, "<span class='notice'>You detect no second beaker in the grenade.</span>")
		else
			to_chat(user, "<span class='notice'>You scan the grenade, but detect nothing.</span>")
	else if(stage != CG_READY && length(beakers))
		if(length(beakers) == 2 && beakers[1].name == beakers[2].name)
			to_chat(user, "<span class='notice'>You see two [beakers[1].name]s inside the grenade.</span>")
		else
			for(var/obj/item/reagent_container/glass/G in beakers)
				to_chat(user, "<span class='notice'>You see a [G.name] inside the grenade.</span>")


/obj/item/explosive/grenade/chem_grenade/proc/stage_change(N)
	if(N)
		stage = N
	if(stage == CG_EMPTY)
		name = "[initial(name)] casing"
		desc = "A do it yourself [initial(name)]! [initial(casedesc)]"
		icon_state = initial(icon_state)
	else if(stage == CG_WIRED)
		name = "unsecured [initial(name)]"
		desc = "An unsecured [initial(name)] assembly."
		icon_state = "[initial(icon_state)]_ass"
	else if(stage == CG_READY)
		name = initial(name)
		desc = initial(desc)
		icon_state = "[initial(icon_state)]_locked"


/obj/item/explosive/grenade/chem_grenade/receive_signal()
	prime()


/obj/item/explosive/grenade/chem_grenade/Crossed(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.Crossed(AM)


/obj/item/explosive/grenade/chem_grenade/prime()
	if(stage != CG_READY)
		return

	var/list/datum/reagents/reactants = list()
	for(var/obj/item/reagent_container/glass/G in beakers)
		reactants += G.reagents

	var/turf/detonation_turf = get_turf(src)

	if(!chem_splash(detonation_turf, affected_area, reactants, ignition_temp, threatscale) && !no_splash)
		playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
		if(length(beakers))
			for(var/obj/O in beakers)
				O.forceMove(drop_location())
			beakers = list()
		stage_change(CG_EMPTY)
		return

	if(nadeassembly)
		var/mob/M = get_mob_by_ckey(assemblyattacher)

		log_explosion("[key_name(M)] primed [src] at [AREACOORD(loc)].")
		log_combat(M, src, "primed")

	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)

	qdel(src)


/obj/item/explosive/grenade/chem_grenade/large
	name = "Large Chem Grenade"
	desc = "An oversized grenade that affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/reagent_container/glass)
	origin_tech = "combat=3;materials=3"
	affected_area = 4


/obj/item/explosive/grenade/chem_grenade/metalfoam
	name = "Metal-Foam Grenade"
	desc = "Used for emergency sealing of air breaches."
	dangerous = FALSE
	stage = CG_READY


/obj/item/explosive/grenade/chem_grenade/metalfoam/Initialize(mapload, ...)
	. = ..()
	var/obj/item/reagent_container/glass/beaker/B1 = new(src)
	var/obj/item/reagent_container/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("aluminum", 30)
	B2.reagents.add_reagent("foaming_agent", 10)
	B2.reagents.add_reagent("pacid", 10)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/incendiary
	name = "Incendiary Grenade"
	desc = "Used for clearing rooms of living things."
	stage = CG_READY


/obj/item/explosive/grenade/chem_grenade/incendiary/Initialize(mapload, ...)
	. = ..()
	var/obj/item/reagent_container/glass/beaker/B1 = new(src)
	var/obj/item/reagent_container/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("aluminum", 15)
	B1.reagents.add_reagent("fuel",20)
	B2.reagents.add_reagent("phoron", 15)
	B2.reagents.add_reagent("sacid", 15)
	B1.reagents.add_reagent("fuel",20)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	dangerous = FALSE
	stage = CG_READY


/obj/item/explosive/grenade/chem_grenade/antiweed/Initialize(mapload, ...)
	. = ..()
	var/obj/item/reagent_container/glass/beaker/B1 = new(src)
	var/obj/item/reagent_container/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("plantbgone", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	dangerous = FALSE
	stage = CG_READY


/obj/item/explosive/grenade/chem_grenade/cleaner/Initialize(mapload, ...)
	. = ..()
	var/obj/item/reagent_container/glass/beaker/B1 = new(src)
	var/obj/item/reagent_container/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 40)
	B2.reagents.add_reagent("water", 40)
	B2.reagents.add_reagent("cleaner", 10)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/teargas
	name = "\improper M66 teargas grenade"
	desc = "Tear gas grenade used for nonlethal riot control. Please wear adequate gas protection."
	stage = CG_READY


/obj/item/explosive/grenade/chem_grenade/teargas/Initialize(mapload, ...)
	. = ..()
	var/obj/item/reagent_container/glass/beaker/B1 = new(src)
	var/obj/item/reagent_container/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("condensedcapsaicin", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2

	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/teargas/attack_self(mob/user)
	if(user.mind?.cm_skills && user.mind.cm_skills.police < SKILL_POLICE_MP)
		to_chat(user, "<span class='warning'>You don't seem to know how to use [src]...</span>")
		return
	return ..()


#undef CG_READY
#undef CG_WIRED
#undef CG_EMPTY