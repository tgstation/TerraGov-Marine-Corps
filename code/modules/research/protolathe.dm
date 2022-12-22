/obj/machinery/rnd/protolathe
	name = "Protolathe"
	icon_state = "protolathe"
	desc = "Makes researched and prototype items with materials and energy."
	layer = BELOW_OBJ_LAYER

	/// The material storage used by this fabricator. There is not much use for a complete material_container component so materials shall be hardcoded like in the autolathe.
	var/list/stored_material =  list(/datum/material/psi = 0, /datum/material/metal = 0, /datum/material/glass = 0)

	/// What's flick()'d on print.
	var/production_animation = "protolathe_n"

	/// All designs that can be fabricated by this machine.
	var/list/datum/design/cached_designs = null

	/// The department this fabricator is assigned to.
	var/department_tag = "Science"

	/// What color is this machine's stripe? Leave null to not have a stripe.
	var/stripe_color = "#D381C9"

/obj/machinery/rnd/protolathe/Initialize(mapload)
	. = ..()
	// should this be a global list?
	cached_designs = typesof(/datum/design/research)
	create_reagents(0, OPENCONTAINER)
	update_overlays()

/obj/machinery/rnd/protolathe/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Fabricator")
		ui.open()

/obj/machinery/rnd/protolathe/ui_static_data(mob/user)
	var/list/data = list()
	var/list/designs = list()

	for(var/datum/design/design AS in cached_designs)
		var/cost = list()
		for(var/datum/material/material in design.materials)
			cost[material.name] = design.materials[material]

		designs[REF(design)] = list(
			"name" = design.name,
			"desc" = design.get_description(),
			"cost" = cost
		)

	data["designs"] = designs
	data["fabName"] = name
	return data

/obj/machinery/rnd/protolathe/ui_data(mob/user)
	var/list/data = list()
	var/list/storage = list()
	
	for(var/datum/material/material AS in stored_material)
		storage += list(list(
			"name" = material.name,
			"amount" = stored_material[material]
		))

	data["materials"] = storage
	data["busy"] = busy
	return data

/obj/machinery/rnd/protolathe/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if("build")
		build(params["ref"])
	return TRUE

/obj/machinery/rnd/protolathe/proc/build(datum/design/request)
	if(!istype(request))//no href shenanigans
		return FALSE

	if(locked && !hacked && !allowed(usr))
		balloon_alert_to_viewers("Build rights restricted by Research Personnel.")
		return FALSE

	if(busy)
		balloon_alert_to_viewers("Warning: fabricator is busy!")
		return FALSE
	
	for(var/material in request.materials)
		if(!stored_material[material] && stored_material[material] >= request.materials[material])
			balloon_alert_to_viewers("Not enough materials to complete prototype.")
			return FALSE

	for(var/reagent in request.reagents_list)
		if(!reagents.has_reagent(reagent, request.reagents_list[reagent]))
			balloon_alert_to_viewers("Not enough reagents to complete prototype.")
			return FALSE

	//is there a race condition on stored material with multiple users? busy can be made atomic or only one user can be allowed to use this machine. minor bug since it can only be exploited once.
	busy = TRUE

	use_power(active_power_usage)
	for(var/material in request.materials)
		materials[material] -= request.materials[material]
	for(var/reagent in request.reagents_list)
		reagents.remove_reagent(reagent, request.reagents_list[reagent])

	flick(production_animation, src)
	addtimer(CALLBACK(src, .proc/do_print, request.build_path, request.dangerous_construction), request.construction_time)
	return TRUE

/obj/machinery/rnd/protolathe/proc/do_print(path, notify_admins) //ignoring admin notification
	busy = FALSE
	new path(get_turf(src))
	playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)

// Stuff for the stripe on the department machines
/obj/machinery/rnd/protolathe/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	update_overlays()

/obj/machinery/rnd/protolathe/update_overlays()
	. = ..()
	if(!stripe_color)
		return
	var/mutable_appearance/stripe = mutable_appearance('icons/obj/machines/research.dmi', "protolate_stripe")
	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		stripe.icon_state = "protolathe_stripe"
	else
		stripe.icon_state = "protolathe_stripe_t"
	stripe.color = stripe_color
	. += stripe

//
///Available designs
//
/datum/design/research
	build_type = PROTOLATHE
	construction_time = 5 SECONDS

/datum/design/research/armor_targeting
	name="Shoulder mount weapon module"
	desc="Interfaces a weapon with the wearer's mind to allow one to multitask while shooting"
	build_path=/obj/item/attachable/shoulder_mount
	materials = list(/datum/material/psi = 20, /datum/material/metal = 200)
	
/datum/design/research/blood_implant
	name="Blood regen implant"
	build_path=/obj/item/implanter/chem/blood
	reagents_list = list(/datum/reagent/virilyth = 40)

/datum/design/research/cloak_implant
	name="Clock implant"
	build_path=/obj/item/implanter/cloak
	materials = list(/datum/material/psi = 40)
	reagents_list = list(/datum/reagent/virilyth = 20)

/datum/design/research/blade_implant
	name="Blade implant"
	build_path=/obj/item/implanter/blade
	materials = list(/datum/material/psi = 5)
	reagents_list = list(/datum/reagent/virilyth = 80)
