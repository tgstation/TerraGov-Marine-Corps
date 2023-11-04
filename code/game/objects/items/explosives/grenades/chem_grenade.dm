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
	var/list/obj/item/reagent_containers/glass/beakers = list()
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/glass/bottle)
	var/list/banned_containers = list(/obj/item/reagent_containers/glass/beaker/bluespace) //Containers to exclude from specific grenade subtypes
	var/affected_area = 3
	var/obj/item/assembly_holder/nadeassembly = null
	var/assemblyattacher
	var/ignition_temp = 10 // The amount of heat added to the reagents when this grenade goes off.
	var/threatscale = 1 // Used by advanced grenades to make them slightly more worthy.
	var/no_splash = FALSE //If the grenade deletes even if it has no reagents to splash with. Used for slime core reactions.
	var/casedesc = "This basic model accepts both beakers and bottles. It heats contents by 10°K upon ignition." // Appears when examining empty casings.


/obj/item/explosive/grenade/chem_grenade/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	stage_change() // If no argument is set, it will change the stage to the current stage, useful for stock grenades that start READY.

/obj/item/explosive/grenade/chem_grenade/Destroy()
	QDEL_LIST(beakers)
	QDEL_NULL(nadeassembly)
	return ..()

/obj/item/explosive/grenade/chem_grenade/attack_self(mob/user)
	if(stage == CG_READY && !active)
		if(nadeassembly)
			nadeassembly.attack_self(user)
		else
			return ..()

/obj/item/explosive/grenade/chem_grenade/razorburn_smol/attackby(obj/item/I, mob/user, params)
	to_chat(user, span_notice("The [initial(name)] is hermetically sealed, and does not open."))
	return

/obj/item/explosive/grenade/chem_grenade/razorburn_large/attackby(obj/item/I, mob/user, params)
	to_chat(user, span_notice("The [initial(name)] is hermetically sealed, and does not open."))
	return

/obj/item/explosive/grenade/chem_grenade/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(stage == CG_WIRED)
			if(!length(beakers))
				to_chat(user, span_warning("You need to add at least one beaker before locking the [initial(name)] assembly!"))
			else
				stage_change(CG_READY)
				to_chat(user, span_notice("You lock the [initial(name)] assembly."))
				I.play_tool_sound(src, 25)

		else if(stage == CG_READY && !nadeassembly)
			det_time = det_time == 50 ? 30 : 50	//toggle between 30 and 50
			to_chat(user, span_notice("You modify the time delay. It's set for [DisplayTimeText(det_time)]."))
		else if(stage == CG_EMPTY)
			to_chat(user, span_warning("You need to add an activation mechanism!"))

	else if(stage == CG_WIRED && is_type_in_list(I, allowed_containers))
		. = TRUE //no afterattack
		if(is_type_in_list(I, banned_containers))
			to_chat(user, span_warning("[src] is too small to fit [I]!")) // this one hits home huh anon?
			return
		if(length(beakers) == 2)
			to_chat(user, span_warning("[src] can not hold more containers!"))
			return
		else
			if(I.reagents.total_volume)
				if(!user.transferItemToLoc(I, src))
					return
				to_chat(user, span_notice("You add [I] to the [initial(name)] assembly."))
				beakers += I
				var/reagent_list = pretty_string_from_reagent_list(I.reagents)
				user.log_message("inserted [I] ([reagent_list]) into [src]",LOG_GAME)
			else
				to_chat(user, span_warning("[I] is empty!"))

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
		to_chat(user, span_notice("You add [A] to the [initial(name)] assembly."))

	else if(stage == CG_EMPTY && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if (C.use(1))
			det_time = 50 // In case the cable_coil was removed and readded.
			stage_change(CG_WIRED)
			to_chat(user, span_notice("You rig the [initial(name)] assembly."))
		else
			to_chat(user, span_warning("You need one length of coil to wire the assembly!"))
			return

	else if(stage == CG_READY && I.tool_behaviour == TOOL_WIRECUTTER && !active)
		to_chat(user, span_notice("Patented marine-proof Dura-Cable prevents you from taking apart the grenade."))
		return

	else if(stage == CG_WIRED && I.tool_behaviour == TOOL_WRENCH)
		if(length(beakers))
			for(var/obj/O in beakers)
				O.forceMove(drop_location())
				if(!O.reagents)
					continue
				var/reagent_list = pretty_string_from_reagent_list(O.reagents)
				user.log_message("removed [O] ([reagent_list]) from [src]", LOG_GAME)
			beakers = list()
			to_chat(user, span_notice("You open the [initial(name)] assembly and remove the payload."))
			return // First use of the wrench remove beakers, then use the wrench to remove the activation mechanism.
		if(nadeassembly)
			nadeassembly.forceMove(drop_location())
			nadeassembly.master = null
			nadeassembly = null
		else // If "nadeassembly = null && stage == CG_WIRED", then it most have been cable_coil that was used.
			new /obj/item/stack/cable_coil(get_turf(src),1)
		stage_change(CG_EMPTY)
		to_chat(user, span_notice("You remove the activation mechanism from the [initial(name)] assembly."))
	else
		return ..()


/obj/item/explosive/grenade/chem_grenade/examine(mob/user)
	display_timer = (stage == CG_READY && !nadeassembly)	//show/hide the timer based on assembly state
	. = ..()
	if(user.skills.getRating(SKILL_MEDICAL) > SKILL_MEDICAL_NOVICE)
		if(length(beakers))
			. += span_notice("You scan the grenade and detect the following reagents:")
			for(var/obj/item/reagent_containers/glass/G in beakers)
				for(var/datum/reagent/R in G.reagents.reagent_list)
					. += span_notice("[R.volume] units of [R.name] in the [G.name].")
			if(length(beakers) == 1)
				. += span_notice("You detect no second beaker in the grenade.")
		else
			. += span_notice("You scan the grenade, but detect nothing.")
	else if(stage != CG_READY && length(beakers))
		if(length(beakers) == 2 && beakers[1].name == beakers[2].name)
			. += span_notice("You see two [beakers[1].name]s inside the grenade.")
		else
			for(var/obj/item/reagent_containers/glass/G in beakers)
				. += span_notice("You see a [G.name] inside the grenade.")


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


/obj/item/explosive/grenade/chem_grenade/prime()
	if(stage != CG_READY)
		return

	var/list/datum/reagents/reactants = list()
	for(var/obj/item/reagent_containers/glass/G in beakers)
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

		log_bomber(M, "primed", src)

	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)

	qdel(src)


/obj/item/explosive/grenade/chem_grenade/large
	name = "Large Chem Grenade"
	desc = "An oversized grenade that affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/reagent_containers/glass)
	affected_area = 4


/obj/item/explosive/grenade/chem_grenade/metalfoam
	name = "Metal-Foam Grenade"
	desc = "Used for emergency sealing of air breaches."
	dangerous = FALSE
	stage = CG_READY


/obj/item/explosive/grenade/chem_grenade/metalfoam/Initialize(mapload, ...)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/aluminum, 30)
	B2.reagents.add_reagent(/datum/reagent/foaming_agent, 10)
	B2.reagents.add_reagent(/datum/reagent/toxin/acid/polyacid, 10)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/razorburn_smol
	name = "Razorburn Grenade"
	desc = "Contains construction nanites ready to turn a small area into razorwire after a few seconds. DO NOT ENTER AREA WHILE ACTIVE."
	icon_state = "grenade_razorburn"
	item_state = "grenade_razorburn"
	hud_state = "grenade_razor"
	stage = CG_READY
	icon_state_mini = "grenade_chem_yellow"


/obj/item/explosive/grenade/chem_grenade/razorburn_smol/Initialize(mapload, ...)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/toxin/nanites, 10) // 1 tile radius
	B2.reagents.add_reagent(/datum/reagent/foaming_agent, 5)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/obj/item/explosive/grenade/chem_grenade/razorburn_large
	name = "Razorburn Canister"
	desc = "Contains construction nanites ready to turn a large area into razorwire after a few seconds. DO NOT ENTER AREA WHILE ACTIVE."
	icon_state = "grenade_large_razorburn"
	stage = CG_READY
	icon_state_mini = "grenade_chem_yellow"


/obj/item/explosive/grenade/chem_grenade/razorburn_large/Initialize(mapload, ...)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/toxin/nanites, 40) // 3 tile radius
	B2.reagents.add_reagent(/datum/reagent/foaming_agent, 30)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"





/obj/item/explosive/grenade/chem_grenade/incendiary
	name = "Incendiary Grenade"
	desc = "Used for clearing rooms of living things."
	stage = CG_READY


/obj/item/explosive/grenade/chem_grenade/incendiary/Initialize(mapload, ...)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/aluminum, 30)
	B1.reagents.add_reagent(/datum/reagent/toxin/acid,30)
	B2.reagents.add_reagent(/datum/reagent/toxin/phoron, 60)

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
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/toxin/plantbgone, 25)
	B1.reagents.add_reagent(/datum/reagent/potassium, 25)
	B2.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	B2.reagents.add_reagent(/datum/reagent/consumable/sugar, 25)

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
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/fluorosurfactant, 40)
	B2.reagents.add_reagent(/datum/reagent/water, 40)
	B2.reagents.add_reagent(/datum/reagent/space_cleaner, 10)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/teargas
	name = "\improper M66 teargas grenade"
	desc = "Tear gas grenade used for nonlethal riot control. Please wear adequate gas protection."
	stage = CG_READY


/obj/item/explosive/grenade/chem_grenade/teargas/Initialize(mapload, ...)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/consumable/capsaicin/condensed, 25)
	B1.reagents.add_reagent(/datum/reagent/potassium, 25)
	B2.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	B2.reagents.add_reagent(/datum/reagent/consumable/sugar, 25)

	beakers += B1
	beakers += B2

	icon_state = initial(icon_state) +"_locked"


/obj/item/explosive/grenade/chem_grenade/teargas/attack_self(mob/user)
	if(user.skills.getRating(SKILL_POLICE) < SKILL_POLICE_MP)
		to_chat(user, span_warning("You don't seem to know how to use [src]..."))
		return
	return ..()


#undef CG_READY
#undef CG_WIRED
#undef CG_EMPTY
