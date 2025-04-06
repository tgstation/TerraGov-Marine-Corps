#define JUMP_COMPONENT "jump_component"

#define JUMP_COMPONENT_COOLDOWN "jump_component_cooldown"

///Time to max out a charged jump
#define MAX_JUMP_CHARGE_TIME 0.4 SECONDS
#define JUMP_CHARGE_DURATION_MULT 1.2
#define JUMP_CHARGE_HEIGHT_MULT 2

#define JUMP_SHADOW (1<<0)
#define JUMP_SPIN (1<<1)
#define JUMP_CHARGEABLE (1<<2)

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
	///When the jump started. Only relevant for charged jumps
	var/jump_start_time = null
	///A 3rd party that controls the jumping of parent. Probably a vehicle driver
	var/external_user

/datum/component/jump/Initialize(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, _jump_flags, _jumper_allow_pass_flags)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	set_vars(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, _jump_flags, _jumper_allow_pass_flags)
	RegisterSignal(parent, COMSIG_VEHICLE_GRANT_CONTROL_FLAG, PROC_REF(set_external_user))

/datum/component/jump/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_KB_LIVING_JUMP_UP, COMSIG_KB_LIVING_JUMP_DOWN, COMSIG_MOB_THROW, COMSIG_VEHICLE_GRANT_CONTROL_FLAG, COMSIG_AI_JUMP, COMSIG_LIVING_CAN_JUMP))
	if(external_user)
		remove_external_user()

/datum/component/jump/InheritComponent(datum/component/new_component, original_component, _jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, _jump_flags, _jumper_allow_pass_flags)
	set_vars(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, _jump_flags, _jumper_allow_pass_flags)

///Actually sets the jump vars
/datum/component/jump/proc/set_vars(_jump_duration = 0.5 SECONDS, _jump_cooldown = 1 SECONDS, _stamina_cost = 8, _jump_height = 16, _jump_sound = null, _jump_flags = JUMP_SHADOW, _jumper_allow_pass_flags = PASS_LOW_STRUCTURE|PASS_FIRE|PASS_TANK)
	jump_duration = _jump_duration
	jump_cooldown = _jump_cooldown
	stamina_cost = _stamina_cost
	jump_height = _jump_height
	jump_sound = _jump_sound
	jump_flags = _jump_flags
	jumper_allow_pass_flags = _jumper_allow_pass_flags

	UnregisterSignal(parent, list(COMSIG_KB_LIVING_JUMP_DOWN, COMSIG_KB_LIVING_JUMP_UP, COMSIG_AI_JUMP, COMSIG_LIVING_CAN_JUMP))
	RegisterSignal(parent, COMSIG_LIVING_CAN_JUMP, PROC_REF(can_jump))
	if(jump_flags & JUMP_CHARGEABLE)
		RegisterSignal(parent, COMSIG_KB_LIVING_JUMP_DOWN, PROC_REF(charge_jump))
		RegisterSignals(parent, list(COMSIG_KB_LIVING_JUMP_UP, COMSIG_AI_JUMP), PROC_REF(start_jump))
	else
		RegisterSignals(parent, list(COMSIG_KB_LIVING_JUMP_DOWN, COMSIG_AI_JUMP), PROC_REF(start_jump))

///Sets an external controller, such as a vehicle driver
/datum/component/jump/proc/set_external_user(datum/source, mob/new_user, control_flags = VEHICLE_CONTROL_DRIVE)
	SIGNAL_HANDLER
	if(!(control_flags & VEHICLE_CONTROL_DRIVE))
		return
	if(external_user) //I don't know how you have 2 drivers, and I don't want to know
		remove_external_user()
	if(new_user)
		external_user = new_user
		RegisterSignal(external_user, COMSIG_KB_LIVING_JUMP_DOWN, PROC_REF(start_jump))
		RegisterSignal(parent, COMSIG_VEHICLE_REVOKE_CONTROL_FLAG, PROC_REF(remove_external_user))

///Unsets an external controller
/datum/component/jump/proc/remove_external_user(datum/source, mob/old_user, control_flags = VEHICLE_CONTROL_DRIVE)
	SIGNAL_HANDLER
	if(!(control_flags & VEHICLE_CONTROL_DRIVE))
		return
	UnregisterSignal(external_user, COMSIG_KB_LIVING_JUMP_DOWN)
	UnregisterSignal(parent, COMSIG_VEHICLE_REVOKE_CONTROL_FLAG)
	external_user = null

///Starts charging the jump
/datum/component/jump/proc/charge_jump(atom/movable/jumper)
	jump_start_time = world.timeofday

///Checks if you can actually jump right now
/datum/component/jump/proc/can_jump(atom/movable/jumper)
	SIGNAL_HANDLER
	if(TIMER_COOLDOWN_RUNNING(jumper, JUMP_COMPONENT_COOLDOWN))
		return FALSE
	var/mob/living/living_jumper
	if(isliving(jumper))
		living_jumper = jumper
		if(living_jumper.buckled)
			return FALSE
		if(living_jumper.incapacitated())
			return FALSE
		if(stamina_cost && (living_jumper.getStaminaLoss() > -stamina_cost))
			if(isrobot(living_jumper) || issynth(living_jumper))
				to_chat(living_jumper, span_warning("Your leg servos do not allow you to jump!"))
				return FALSE
			to_chat(living_jumper, span_warning("Catch your breath!"))
			return FALSE
	return TRUE

///handles pre-jump checks and setup of additional jump behavior.
/datum/component/jump/proc/start_jump(atom/movable/jumper)
	SIGNAL_HANDLER
	if(jumper == external_user)
		jumper = parent
	if(!can_jump(jumper))
		return

	do_jump(jumper)
	if(isliving(jumper))
		var/mob/living/living_jumper = jumper
		living_jumper.adjustStaminaLoss(stamina_cost)
	//Forces all who ride to jump alongside the jumper.
	for(var/mob/buckled_mob AS in jumper.buckled_mobs)
		do_jump(buckled_mob)

///Performs the jump
/datum/component/jump/proc/do_jump(atom/movable/jumper)
	var/effective_jump_duration = jump_duration
	var/effective_jump_height = jump_height
	var/effective_jumper_allow_pass_flags = jumper_allow_pass_flags
	if(jump_start_time)
		var/charge_time = min(abs((world.timeofday - jump_start_time) / (MAX_JUMP_CHARGE_TIME)), 1)
		effective_jump_duration = LERP(jump_duration, jump_duration * JUMP_CHARGE_DURATION_MULT, charge_time)
		effective_jump_height = LERP(jump_height, jump_height * JUMP_CHARGE_HEIGHT_MULT, charge_time)
		if(charge_time == 1)
			effective_jumper_allow_pass_flags |= (PASS_MOB|PASS_DEFENSIVE_STRUCTURE)
		jump_start_time = null

	if(jump_sound)
		playsound(jumper, jump_sound, 65)

	var/original_layer = jumper.layer

	SEND_SIGNAL(jumper, COMSIG_ELEMENT_JUMP_STARTED, effective_jump_height, effective_jump_duration)
	ADD_TRAIT(jumper, TRAIT_SILENT_FOOTSTEPS, JUMP_COMPONENT)
	jumper.add_pass_flags(effective_jumper_allow_pass_flags, JUMP_COMPONENT)
	jumper.add_nosubmerge_trait(JUMP_COMPONENT)
	RegisterSignal(jumper, COMSIG_MOB_THROW, PROC_REF(jump_throw))

	jumper.add_filter(JUMP_COMPONENT, 2, drop_shadow_filter(color = COLOR_TRANSPARENT_SHADOW, size = 0.9))
	var/shadow_filter = jumper.get_filter(JUMP_COMPONENT)

	animate(jumper, pixel_z = jumper.pixel_z + effective_jump_height, layer = max(MOB_UPPER_LAYER, original_layer), time = effective_jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
	animate(pixel_z = jumper.pixel_z - effective_jump_height, layer = original_layer, time = effective_jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)
	if(jump_flags & JUMP_SPIN)
		var/spin_number = ROUND_UP(effective_jump_duration * 0.1)
		jumper.animation_spin(effective_jump_duration / spin_number, spin_number, jumper.dir == WEST ? FALSE : TRUE, anim_flags = ANIMATION_PARALLEL)
	if(jump_flags & JUMP_SHADOW)
		animate(shadow_filter, y = -effective_jump_height, size = 4, time = effective_jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
		animate(y = 0, size = 0.9, time = effective_jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(end_jump), jumper, effective_jumper_allow_pass_flags), effective_jump_duration)

	TIMER_COOLDOWN_START(jumper, JUMP_COMPONENT_COOLDOWN, jump_cooldown)

///Ends the jump
/datum/component/jump/proc/end_jump(atom/movable/jumper, old_pass_flags)
	jumper.remove_filter(JUMP_COMPONENT)
	jumper.remove_pass_flags(old_pass_flags, JUMP_COMPONENT)
	jumper.remove_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_NOSUBMERGE), JUMP_COMPONENT)
	SEND_SIGNAL(jumper, COMSIG_ELEMENT_JUMP_ENDED, TRUE, 1.5, 2)
	SEND_SIGNAL(jumper.loc, COMSIG_TURF_JUMP_ENDED_HERE, jumper)
	UnregisterSignal(jumper, COMSIG_MOB_THROW)

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

///Can this be jumped over
/atom/movable/proc/is_jumpable(mob/living/jumper)
	if(allow_pass_flags & (PASS_LOW_STRUCTURE|PASS_TANK))
		return TRUE

/obj/structure/barricade/is_jumpable(mob/living/jumper)
	if(is_wired)
		return FALSE
	return ..()

///Checks if this mob can jump
/mob/living/proc/can_jump()
	return SEND_SIGNAL(src, COMSIG_LIVING_CAN_JUMP)
