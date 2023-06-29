#define JUMP_ELEMENT "jump_element"

#define JUMP_ELEMENT_COOLDOWN "jump_element_cooldown"

#define JUMP_SPIN (1<<0)

/datum/element/jump
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
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
	///flags_pass flags applied to the jumper on jump
	var/jumper_flags_pass

/datum/element/jump/Attach(atom/movable/target, _jump_duration = 0.5 SECONDS, _jump_cooldown = 1 SECONDS, _stamina_cost = 8, _jump_height = 16, _jump_sound = null, _jump_flags = null, _jumper_flags_pass = PASSTABLE|PASSFIRE)
	. = ..()
	if(!isliving(target))
		return COMPONENT_INCOMPATIBLE

	jump_duration = _jump_duration
	jump_cooldown = _jump_cooldown
	stamina_cost = _stamina_cost
	jump_height = _jump_height
	jump_sound = _jump_sound
	jump_flags = _jump_flags
	jumper_flags_pass = _jumper_flags_pass

	RegisterSignal(target, COMSIG_KB_LIVING_JUMP, PROC_REF(do_jump))

/datum/element/jump/Detach(datum/target)
	UnregisterSignal(target, COMSIG_KB_LIVING_JUMP)
	return ..()

///Performs the jump
/datum/element/jump/proc/do_jump(mob/living/jumper)
	SIGNAL_HANDLER
	if(jumper.incapacitated(TRUE))
		return

	if(TIMER_COOLDOWN_CHECK(jumper, JUMP_ELEMENT_COOLDOWN))
		return

	if(stamina_cost && (jumper.getStaminaLoss() > -stamina_cost))
		to_chat(jumper, span_warning("Catch your breath!"))
		return

	if(jump_sound)
		playsound(jumper, jump_sound, 65)

	jumper.layer = ABOVE_MOB_LAYER

	jumper.adjustStaminaLoss(stamina_cost)
	jumper.flags_pass |= jumper_flags_pass
	ADD_TRAIT(jumper, TRAIT_SILENT_FOOTSTEPS, JUMP_ELEMENT)

	jumper.add_filter(JUMP_ELEMENT, 2, drop_shadow_filter(color = COLOR_TRANSPARENT_SHADOW, size = 0.9))
	var/shadow_filter = jumper.get_filter(JUMP_ELEMENT)

	if(jump_flags & JUMP_SPIN)
		var/spin_number = ROUND_UP(jump_duration * 0.1)
		jumper.animation_spin(jump_duration / spin_number, spin_number, jumper.dir == WEST ? FALSE : TRUE)

	animate(jumper, pixel_y = jumper.pixel_y + jump_height, layer = ABOVE_MOB_LAYER, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = jumper.pixel_y - jump_height, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)
	animate(shadow_filter, y = -jump_height, size = 4, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(y = 0, size = 0.9, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(end_jump), jumper), jump_duration)

	TIMER_COOLDOWN_START(jumper, JUMP_ELEMENT_COOLDOWN, jump_cooldown)

///Ends the jump
/datum/element/jump/proc/end_jump(mob/living/jumper)
	jumper.remove_filter("jump_element")
	jumper.layer = initial(jumper.layer)
	jumper.flags_pass = initial(jumper.flags_pass)
	REMOVE_TRAIT(jumper, TRAIT_SILENT_FOOTSTEPS, JUMP_ELEMENT)
	SEND_SIGNAL(jumper, COMSIG_ELEMENT_JUMP_ENDED, TRUE, 1.5, 2)
	SEND_SIGNAL(jumper.loc, COMSIG_TURF_JUMP_ENDED_HERE, jumper)
