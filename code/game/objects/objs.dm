/obj
	animate_movement = SLIDE_STEPS
	speech_span = SPAN_ROBOT
	interaction_flags = INTERACT_OBJ_DEFAULT
	resistance_flags = NONE

	///damage amount to deal when this obj is attacking something
	var/force = 0
	///damage type to deal when this obj is attacking something
	var/damtype = BRUTE
	///The amount of armor penetration the object has when attacking something
	var/penetration = 0
	var/list/materials

	/// %-reduction-based armor.
	var/datum/armor/soft_armor
	/// Flat-damage-reduction-based armor.
	var/datum/armor/hard_armor

	var/obj_integrity	//defaults to max_integrity
	var/max_integrity = 500
	var/integrity_failure = 0 //0 if we have no special broken behavior
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/crit_fail = 0

	///throwforce needs to be at least 1 else it causes runtimes with shields
	var/throwforce = 1

	var/obj_flags = NONE
	var/hit_sound //Sound this object makes when hit, overrides specific item hit sound.
	var/destroy_sound //Sound this object makes when destroyed.

	var/item_fire_stacks = 0	//How many fire stacks it applies
	var/obj/effect/xenomorph/acid/current_acid = null //If it has acid spewed on it

	var/list/req_access = null
	var/list/req_one_access = null

	///Optimization for dynamic explosion block values, for things whose explosion block is dependent on certain conditions.
	var/real_explosion_block

	///Odds of a projectile hitting the object, if the object is dense and has THROWPROJECTILE
	var/coverage = 50

/obj/Initialize()
	. = ..()
	if(islist(soft_armor))
		soft_armor = getArmor(arglist(soft_armor))
	else if (!soft_armor)
		// Default bio armor 100 to avoid sentinels getting free damage on sent
		soft_armor = getArmor(bio = 100) // This is here so that walls don't die from NEUROTOXIN
	else if (!istype(soft_armor, /datum/armor))
		stack_trace("Invalid type [soft_armor.type] found in .soft_armor during /obj Initialize()")

	if(islist(hard_armor))
		hard_armor = getArmor(arglist(hard_armor))
	else if (!hard_armor)
		hard_armor = getArmor()
	else if (!istype(hard_armor, /datum/armor))
		stack_trace("Invalid type [hard_armor.type] found in .hard_armor during /obj Initialize()")

	if(obj_integrity == null)
		obj_integrity = max_integrity

	if(LAZYLEN(req_access))
		var/txt_access = req_access.Join("-")
		if(!GLOB.all_req_access[txt_access])
			GLOB.all_req_access[txt_access] = req_access
		else
			req_access = GLOB.all_req_access[txt_access]

	if(LAZYLEN(req_one_access))
		var/txt_access = req_one_access.Join("-")
		if(!GLOB.all_req_one_access[txt_access])
			GLOB.all_req_one_access[txt_access] = req_one_access
		else
			req_one_access = GLOB.all_req_one_access[txt_access]


/obj/Destroy()
	hard_armor = null
	soft_armor = null
	QDEL_NULL(current_acid)
	return ..()


/obj/proc/setAnchored(anchorvalue)
	SEND_SIGNAL(src, COMSIG_OBJ_SETANCHORED, anchorvalue)
	anchored = anchorvalue

/obj/ex_act()
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	return ..()

/obj/item/proc/is_used_on(obj/O, mob/user)
	return

/obj/process()
	STOP_PROCESSING(SSobj, src)
	return 0


/obj/proc/updateUsrDialog()
	if(!CHECK_BITFIELD(obj_flags, IN_USE))
		return
	var/is_in_use = FALSE

	var/mob/living/silicon/ai/AI
	if(isAI(usr))
		AI = usr
		if(AI.client && AI.interactee == src)
			is_in_use = TRUE
			if(interaction_flags & INTERACT_UI_INTERACT)
				ui_interact(AI)
			else
				interact(AI)

	for(var/mob/M in view(1, src))
		if(!M.client || M.interactee != src || M == AI)
			continue
		is_in_use = TRUE
		if(interaction_flags & INTERACT_UI_INTERACT)
			ui_interact(M)
		else
			interact(M)

	if(ismob(loc))
		var/mob/M = loc
		is_in_use = TRUE
		if(interaction_flags & INTERACT_UI_INTERACT)
			ui_interact(M)
		else
			interact(M)

	if(!is_in_use)
		DISABLE_BITFIELD(obj_flags, IN_USE)


/obj/proc/hide(h) // TODO: Fix all children
	return



/obj/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		var/turf/T = get_turf(src)
		if(!(T?.intact_tile) || level != 1) //not hidden under the floor
			S.reagents?.reaction(src, VAPOR, S.fraction)


/obj/on_set_interaction(mob/user)
	. = ..()
	ENABLE_BITFIELD(obj_flags, IN_USE)

/mob/proc/unset_machine()
	if(machine)
		machine.on_unset_machine(src)
		machine = null

//called when the user unsets the machine.
/atom/movable/proc/on_unset_machine(mob/user)
	return

/mob/proc/set_machine(obj/O)
	if(machine)
		unset_machine()
	machine = O
	if(istype(O))
		O.obj_flags |= IN_USE

/obj/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("anchored")
			setAnchored(var_value)
			return TRUE
	return ..()

///Called to return an internally stored item, currently for the deployable element
/obj/proc/get_internal_item()
	return

///Called to clear a stored item var, currently for the deployable element
/obj/proc/clear_internal_item()
	return

///Handles welder based repair of objects, normally called by welder_act
/obj/proc/welder_repair_act(mob/living/user, obj/item/I, repair_amount = 150, repair_time = 5 SECONDS, repair_threshold = 0, skill_required = SKILL_ENGINEER_DEFAULT, fuel_req = 2, fumble_time)
	if(user.do_actions)
		balloon_alert(user, "busy")
		return FALSE

	if(user.a_intent == INTENT_HARM)
		return FALSE

	var/obj/item/tool/weldingtool/welder = I

	if(!welder.tool_use_check(user, fuel_req))
		return FALSE

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			balloon_alert(user, "It's melting")
			return TRUE

	if(obj_integrity <= max_integrity * repair_threshold)
		return BELOW_INTEGRITY_THRESHOLD

	if(obj_integrity >= max_integrity)
		balloon_alert(user, "already repaired")
		return TRUE

	if(user.skills.getRating("engineer") < skill_required)
		user.visible_message(span_notice("[user] fumbles around figuring out how to repair [src]."),
		span_notice("You fumble around figuring out how to repair [src]."))
		if(!do_after(user, (fumble_time ? fumble_time : repair_time) * (skill_required - user.skills.getRating("engineer")), TRUE, src, BUSY_ICON_BUILD))
			return TRUE

	repair_time *= welder.toolspeed
	balloon_alert_to_viewers("starting repair...")
	handle_weldingtool_overlay()
	while(obj_integrity < max_integrity)
		playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
		welder.eyecheck(user)
		if(!do_after(user, repair_time, TRUE, src, BUSY_ICON_FRIENDLY))
			cut_overlay(GLOB.welding_sparks)
			balloon_alert(user, "interrupted!")
			return TRUE

		if(obj_integrity <= max_integrity * repair_threshold || obj_integrity >= max_integrity)
			handle_weldingtool_overlay(TRUE)
			return TRUE

		if(!welder.remove_fuel(fuel_req))
			balloon_alert(user, "not enough fuel")
			handle_weldingtool_overlay(TRUE)
			return TRUE

		repair_damage(repair_amount)
		update_icon()

	balloon_alert_to_viewers("repaired")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	handle_weldingtool_overlay(TRUE)
	return TRUE
