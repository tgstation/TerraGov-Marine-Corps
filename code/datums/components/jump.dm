#define JUMP_COMPONENT "jump_component"

#define JUMP_COMPONENT_COOLDOWN "jump_component_cooldown"

#define JUMP_SHADOW (1<<0)
#define JUMP_SPIN (1<<1)

/datum/component/jump
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///air time
	var/jump_duration
	///time between jumps
	var/jump_cooldown
	///how much stamina jumping takes
	var/stamina_cost
	///the how high the jumper visually jumps
	var/jump_height
	///the sound of the jump
	var/jump_sound
	///Special jump behavior flags
	var/jump_flags
	///allow_pass_flags flags applied to the jumper on jump
	var/jumper_allow_pass_flags

	var/external_user

/datum/component/jump/Initialize(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, _jump_flags, _jumper_allow_pass_flags, mob/living/_external_user)
	. = ..()
	//if(!isliving(parent))
	//	return COMPONENT_INCOMPATIBLE

	if(_external_user)
		set_external_user(new_user = _external_user)

	set_vars(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, _jump_flags, _jumper_allow_pass_flags)
	RegisterSignal(parent, COMSIG_KB_LIVING_JUMP, PROC_REF(do_jump))
	RegisterSignal(parent, COMSIG_KB_VEHICLE_NEW_OCCUPANT, PROC_REF(set_external_user))

/datum/component/jump/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_KB_LIVING_JUMP, COMSIG_MOB_THROW, COMSIG_KB_VEHICLE_NEW_OCCUPANT))
	set_external_user()

/datum/component/jump/InheritComponent(datum/component/new_component, original_component, _jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, _jump_flags, _jumper_allow_pass_flags)
	set_vars(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, _jump_flags, _jumper_allow_pass_flags)

///Actually sets the jump vars
/datum/component/jump/proc/set_vars(_jump_duration = 0.5 SECONDS, _jump_cooldown = 1 SECONDS, _stamina_cost = 8, _jump_height = 16, _jump_sound = null, _jump_flags = JUMP_SHADOW, _jumper_allow_pass_flags = PASS_LOW_STRUCTURE|PASS_FIRE)
	jump_duration = _jump_duration
	jump_cooldown = _jump_cooldown
	stamina_cost = _stamina_cost
	jump_height = _jump_height
	jump_sound = _jump_sound
	jump_flags = _jump_flags
	jumper_allow_pass_flags = _jumper_allow_pass_flags

///Sets an external controller, such as a vehicle driver
/datum/component/jump/proc/set_external_user(datum/source, mob/living/new_user)
	SIGNAL_HANDLER
	if(external_user)
		remove_external_user()
	if(new_user)
		external_user = new_user
		RegisterSignal(external_user, COMSIG_KB_LIVING_JUMP, PROC_REF(do_jump))
		RegisterSignal(external_user, COMSIG_KB_VEHICLE_OCCUPANT_LEFT, PROC_REF(remove_external_user))

///Unsets an external controller
/datum/component/jump/proc/remove_external_user(datum/source, mob/living/old_user)
	SIGNAL_HANDLER
	UnregisterSignal(external_user, list(COMSIG_KB_LIVING_JUMP, COMSIG_KB_VEHICLE_OCCUPANT_LEFT))
	external_user = null

///Performs the jump
/datum/component/jump/proc/do_jump(atom/movable/jumper)
	SIGNAL_HANDLER
	if(jumper == external_user)
		jumper = parent
	if(TIMER_COOLDOWN_CHECK(jumper, JUMP_COMPONENT_COOLDOWN))
		return
	if(isliving(jumper))
		var/mob/living/living_jumper = jumper
		if(living_jumper.buckled)
			return
		if(living_jumper.incapacitated())
			return

		if(stamina_cost && (living_jumper.getStaminaLoss() > -stamina_cost))
			to_chat(living_jumper, span_warning("Catch your breath!"))
			return

		living_jumper.adjustStaminaLoss(stamina_cost)

	if(jump_sound)
		playsound(jumper, jump_sound, 65)

	jumper.layer = ABOVE_MOB_LAYER
	SEND_SIGNAL(jumper, COMSIG_ELEMENT_JUMP_STARTED)
	jumper.pass_flags |= jumper_allow_pass_flags
	ADD_TRAIT(jumper, TRAIT_SILENT_FOOTSTEPS, JUMP_COMPONENT)
	RegisterSignal(parent, COMSIG_MOB_THROW, PROC_REF(jump_throw))

	jumper.add_filter(JUMP_COMPONENT, 2, drop_shadow_filter(color = COLOR_TRANSPARENT_SHADOW, size = 0.9))
	var/shadow_filter = jumper.get_filter(JUMP_COMPONENT)

	if(jump_flags & JUMP_SPIN)
		var/spin_number = ROUND_UP(jump_duration * 0.1)
		jumper.animation_spin(jump_duration / spin_number, spin_number, jumper.dir == WEST ? FALSE : TRUE)

	animate(jumper, pixel_y = jumper.pixel_y + jump_height, layer = ABOVE_MOB_LAYER, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = jumper.pixel_y - jump_height, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	if(jump_flags & JUMP_SHADOW)
		animate(shadow_filter, y = -jump_height, size = 4, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
		animate(y = 0, size = 0.9, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(end_jump), jumper), jump_duration)

	TIMER_COOLDOWN_START(jumper, JUMP_COMPONENT_COOLDOWN, jump_cooldown)

///Ends the jump
/datum/component/jump/proc/end_jump(atom/movable/jumper)
	jumper.remove_filter(JUMP_COMPONENT)
	jumper.layer = initial(jumper.layer)
	jumper.pass_flags = initial(jumper.pass_flags)
	REMOVE_TRAIT(jumper, TRAIT_SILENT_FOOTSTEPS, JUMP_COMPONENT)
	SEND_SIGNAL(jumper, COMSIG_ELEMENT_JUMP_ENDED, TRUE, 1.5, 2)
	SEND_SIGNAL(jumper.loc, COMSIG_TURF_JUMP_ENDED_HERE, jumper)
	UnregisterSignal(parent, COMSIG_MOB_THROW)

///Jump throw bonuses
/datum/component/jump/proc/jump_throw(atom/movable/thrower, target, thrown_thing, list/throw_modifiers)
	SIGNAL_HANDLER
	var/obj/item/throw_item = thrown_thing
	if(!istype(throw_item))
		return
	if(throw_item.w_class > WEIGHT_CLASS_NORMAL)
		return
	throw_modifiers["targetted_throw"] = FALSE
	throw_modifiers["speed_modifier"] -= 1
	throw_modifiers["range_modifier"] += 4
