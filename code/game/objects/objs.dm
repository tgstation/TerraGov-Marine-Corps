/obj
	animate_movement = SLIDE_STEPS
	speech_span = SPAN_ROBOT
	interaction_flags = INTERACT_OBJ_DEFAULT
	resistance_flags = NONE

	/// Icon to use as a 32x32 preview in crafting menus and such
	var/icon_preview
	var/icon_state_preview

	///damage amount to deal when this obj is attacking something
	var/force = 0
	///damage type to deal when this obj is attacking something
	var/damtype = BRUTE
	///The amount of armor penetration the object has when attacking something
	var/penetration = 0

	/// %-reduction-based armor.
	var/datum/armor/soft_armor
	///Modifies the AP of incoming attacks
	var/datum/armor/hard_armor
	///Object HP
	var/obj_integrity
	///Max object HP
	var/max_integrity = 500
	///Integrety below this number causes special behavior
	var/integrity_failure = 0
	///Base throw damage. Throwforce needs to be at least 1 else it causes runtimes with shields
	var/throwforce = 1
	///Object behavior flags
	var/obj_flags = NONE
	///Sound when hit
	var/hit_sound
	///Sound this object makes when destroyed
	var/destroy_sound
	///ID access where all are required to access this object
	var/list/req_access = null
	///ID access where any one is required to access this object
	var/list/req_one_access = null
	///Odds of a projectile hitting the object, if the object is dense
	var/coverage = 50

/obj/Initialize(mapload)
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
	add_debris_element()

/obj/Destroy()
	hard_armor = null
	soft_armor = null
	QDEL_NULL(current_acid)
	return ..()


/obj/proc/setAnchored(anchorvalue)
	SEND_SIGNAL(src, COMSIG_OBJ_SETANCHORED, anchorvalue)
	anchored = anchorvalue

/obj/item/proc/is_used_on(obj/O, mob/user)
	return

/obj/process()
	STOP_PROCESSING(SSobj, src)
	return 0

/obj/get_acid_delay()
	if(density)
		return 4 SECONDS
	return ..()

/obj/get_soft_armor(armor_type, proj_def_zone)
	return soft_armor.getRating(armor_type)

/obj/get_hard_armor(armor_type, proj_def_zone)
	return hard_armor.getRating(armor_type)

/obj/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if((atom_flags & ON_BORDER) && !(get_dir(loc, target) & dir))
		return TRUE
	if((allow_pass_flags & PASS_DEFENSIVE_STRUCTURE) && (mover.pass_flags & PASS_DEFENSIVE_STRUCTURE))
		return TRUE
	if((allow_pass_flags & PASS_GLASS) && (mover.pass_flags & PASS_GLASS))
		return TRUE
	if(mover?.throwing && (allow_pass_flags & PASS_THROW))
		return TRUE
	if((allow_pass_flags & PASS_LOW_STRUCTURE) && (mover.pass_flags & PASS_LOW_STRUCTURE))
		return TRUE
	if((allow_pass_flags & PASS_AIR) && (mover.pass_flags & PASS_AIR))
		return TRUE
	if(!ismob(mover))
		return FALSE
	if((allow_pass_flags & PASS_MOB))
		return TRUE
	if((allow_pass_flags & PASS_WALKOVER) && SEND_SIGNAL(target, COMSIG_OBJ_TRY_ALLOW_THROUGH, mover))
		return TRUE

///Handles extra checks for things trying to exit this objects turf
/obj/proc/on_try_exit(datum/source, atom/movable/mover, direction, list/knownblockers)
	SIGNAL_HANDLER
	if(mover?.throwing && (allow_pass_flags & PASS_THROW))
		return NONE
	if((allow_pass_flags & PASS_DEFENSIVE_STRUCTURE) && (mover.pass_flags & PASS_DEFENSIVE_STRUCTURE))
		return NONE
	if((allow_pass_flags & PASS_LOW_STRUCTURE) && (mover.pass_flags & PASS_LOW_STRUCTURE))
		return NONE
	if((allow_pass_flags & PASS_AIR) && (mover.pass_flags & PASS_AIR))
		return TRUE
	if((allow_pass_flags & PASS_GLASS) && (mover.pass_flags & PASS_GLASS))
		return NONE
	if(!density || !(atom_flags & ON_BORDER) || !(direction & dir) || (mover.status_flags & INCORPOREAL))
		return NONE

	knownblockers += src
	return COMPONENT_ATOM_BLOCK_EXIT

///Signal handler to check if you can move from one low object to another
/obj/proc/can_climb_over(datum/source, atom/mover)
	SIGNAL_HANDLER
	if(!(atom_flags & ON_BORDER) && density)
		return TRUE

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

/obj/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_MASS_DEL_TYPE, "Delete all of type")
	VV_DROPDOWN_OPTION(VV_HK_OSAY, "Object Say")

/obj/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_OSAY])
		if(check_rights(R_FUN, FALSE))
			usr.client.object_say(src)

	if(href_list[VV_HK_MASS_DEL_TYPE])
		if(!check_rights(R_DEBUG|R_SERVER))
			return
		var/action_type = tgui_alert(usr, "Strict type ([type]) or type and all subtypes?",,list("Strict type","Type and subtypes","Cancel"))
		if(action_type == "Cancel" || !action_type)
			return

		if(tgui_alert(usr, "Are you really sure you want to delete all objects of type [type]?",,list("Yes","No")) != "Yes")
			return

		if(tgui_alert(usr, "Second confirmation required. Delete?",,list("Yes","No")) != "Yes")
			return

		var/O_type = type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) ")
				message_admins(span_notice("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) "))
			if("Type and subtypes")
				var/i = 0
				for(var/obj/Obj in world)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) ")
				message_admins(span_notice("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) "))

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

	if(user.skills.getRating(SKILL_ENGINEER) < skill_required)
		user.visible_message(span_notice("[user] fumbles around figuring out how to repair [src]."),
		span_notice("You fumble around figuring out how to repair [src]."))
		if(!do_after(user, (fumble_time ? fumble_time : repair_time) * (skill_required - user.skills.getRating(SKILL_ENGINEER)), NONE, src, BUSY_ICON_BUILD))
			return TRUE

	if(user.skills.getRating(SKILL_ENGINEER) > skill_required)
		repair_amount *= (1+(0.1*(user.skills.getRating(SKILL_ENGINEER) - (skill_required + 1))))

	repair_time *= welder.toolspeed
	balloon_alert_to_viewers("starting repair...")
	handle_weldingtool_overlay()
	while(obj_integrity < max_integrity)
		playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
		welder.eyecheck(user)
		if(!do_after(user, repair_time, NONE, src, BUSY_ICON_FRIENDLY))
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

		repair_damage(repair_amount, user)
		update_icon()

	balloon_alert_to_viewers("repaired")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	handle_weldingtool_overlay(TRUE)
	return TRUE

/obj/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	if(isxeno(user))
		return
	if(user.a_intent != INTENT_HARM)
		return
	if(!isliving(grab.grabbed_thing))
		return
	if(user.grab_state <= GRAB_AGGRESSIVE)
		to_chat(user, span_warning("You need a better grip to do that!"))
		return

	var/mob/living/grabbed_mob = grab.grabbed_thing
	if(prob(15))
		grabbed_mob.Paralyze(2 SECONDS)
		user.drop_held_item()
	step_towards(grabbed_mob, src)
	var/damage = base_damage + (user.skills.getRating(SKILL_CQC) * CQC_SKILL_DAMAGE_MOD)
	grabbed_mob.apply_damage(damage, BRUTE, "head", MELEE, is_sharp, updating_health = TRUE)
	user.visible_message(span_danger("[user] slams [grabbed_mob]'s face against [src]!"),
	span_danger("You slam [grabbed_mob]'s face against [src]!"))
	log_combat(user, grabbed_mob, "slammed", "", "against \the [src]")
	take_damage(damage, BRUTE, MELEE)
	return TRUE
