/obj
	animate_movement = SLIDE_STEPS
	speech_span = SPAN_ROBOT
	interaction_flags = INTERACT_OBJ_DEFAULT

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

	///odds of a projectile hitting the object, if throwpass is true and the object is dense
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
