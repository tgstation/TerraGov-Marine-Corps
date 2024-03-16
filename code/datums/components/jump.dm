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
	var/flags_jump
	///flags_allow_pass flags applied to the jumper on jump
	var/flags_jumper_allow_pass

/datum/component/jump/Initialize(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, flags__jump, flags__jumper_allow_pass)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	set_vars(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, flags__jump, flags__jumper_allow_pass)
	RegisterSignal(parent, COMSIG_KB_LIVING_JUMP, PROC_REF(do_jump))

/datum/component/jump/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_KB_LIVING_JUMP, COMSIG_MOB_THROW))

/datum/component/jump/InheritComponent(datum/component/new_component, original_component, _jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, flags__jump, flags__jumper_allow_pass)
	set_vars(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, flags__jump, flags__jumper_allow_pass)

///Actually sets the jump vars
/datum/component/jump/proc/set_vars(_jump_duration = 0.5 SECONDS, _jump_cooldown = 1 SECONDS, _stamina_cost = 8, _jump_height = 16, _jump_sound = null, flags__jump = JUMP_SHADOW, flags__jumper_allow_pass = PASS_LOW_STRUCTURE|PASS_FIRE|PASS_TANK)
	jump_duration = _jump_duration
	jump_cooldown = _jump_cooldown
	stamina_cost = _stamina_cost
	jump_height = _jump_height
	jump_sound = _jump_sound
	flags_jump = flags__jump
	flags_jumper_allow_pass = flags__jumper_allow_pass

///Performs the jump
/datum/component/jump/proc/do_jump(mob/living/jumper)
	SIGNAL_HANDLER
	if(TIMER_COOLDOWN_CHECK(jumper, JUMP_COMPONENT_COOLDOWN))
		return
	if(jumper.buckled)
		return
	if(jumper.incapacitated())
		return

	if(stamina_cost && (jumper.getStaminaLoss() > -stamina_cost))
		to_chat(jumper, span_warning("Catch your breath!"))
		return

	if(jump_sound)
		playsound(jumper, jump_sound, 65)

	var/original_layer = jumper.layer
	var/flags_original_pass = jumper.flags_pass

	SEND_SIGNAL(jumper, COMSIG_ELEMENT_JUMP_STARTED)
	jumper.adjustStaminaLoss(stamina_cost)
	jumper.flags_pass |= flags_jumper_allow_pass
	ADD_TRAIT(jumper, TRAIT_SILENT_FOOTSTEPS, JUMP_COMPONENT)
	RegisterSignal(parent, COMSIG_MOB_THROW, PROC_REF(jump_throw))

	jumper.add_filter(JUMP_COMPONENT, 2, drop_shadow_filter(color = COLOR_TRANSPARENT_SHADOW, size = 0.9))
	var/shadow_filter = jumper.get_filter(JUMP_COMPONENT)

	if(flags_jump & JUMP_SPIN)
		var/spin_number = ROUND_UP(jump_duration * 0.1)
		jumper.animation_spin(jump_duration / spin_number, spin_number, jumper.dir == WEST ? FALSE : TRUE)

	animate(jumper, pixel_y = jumper.pixel_y + jump_height, layer = MOB_JUMP_LAYER, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = jumper.pixel_y - jump_height, layer = original_layer, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	if(flags_jump & JUMP_SHADOW)
		animate(shadow_filter, y = -jump_height, size = 4, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
		animate(y = 0, size = 0.9, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(end_jump), jumper, flags_original_pass), jump_duration)

	TIMER_COOLDOWN_START(jumper, JUMP_COMPONENT_COOLDOWN, jump_cooldown)

///Ends the jump
/datum/component/jump/proc/end_jump(mob/living/jumper, flags_original_pass)
	jumper.remove_filter(JUMP_COMPONENT)
	jumper.flags_pass = flags_original_pass
	REMOVE_TRAIT(jumper, TRAIT_SILENT_FOOTSTEPS, JUMP_COMPONENT)
	SEND_SIGNAL(jumper, COMSIG_ELEMENT_JUMP_ENDED, TRUE, 1.5, 2)
	SEND_SIGNAL(jumper.loc, COMSIG_TURF_JUMP_ENDED_HERE, jumper)
	UnregisterSignal(parent, COMSIG_MOB_THROW)

///Jump throw bonuses
/datum/component/jump/proc/jump_throw(mob/living/thrower, target, thrown_thing, list/throw_modifiers)
	SIGNAL_HANDLER
	var/obj/item/throw_item = thrown_thing
	if(!istype(throw_item))
		return
	if(throw_item.w_class > WEIGHT_CLASS_NORMAL)
		return
	throw_modifiers["targetted_throw"] = FALSE
	throw_modifiers["speed_modifier"] -= 1
	throw_modifiers["range_modifier"] += 4
