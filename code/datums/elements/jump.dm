/datum/element/jump
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///air time
	var/jump_duration
	///time between jumps
	var/jump_cooldown
	///how much stamina jumping takes
	var/stamina_cost
	COOLDOWN_DECLARE(cooldown_timer)

/datum/element/jump/Attach(atom/movable/target, _jump_duration = 1 SECONDS, _jump_cooldown = 1.5 SECONDS, _stamina_cost = 10)
	. = ..()
	if(!isliving(target))
		return COMPONENT_INCOMPATIBLE

	jump_duration = _jump_duration
	jump_cooldown = _jump_cooldown
	stamina_cost = _stamina_cost

	RegisterSignal(target, COMSIG_KB_LIVING_JUMP, PROC_REF(do_jump))

/datum/element/jump/Detach(datum/target)
	UnregisterSignal(target, COMSIG_KB_LIVING_JUMP)
	return ..()

///Performs the jump
/datum/element/jump/proc/do_jump(mob/living/jumper)
	SIGNAL_HANDLER
	if(jumper.incapacitated(TRUE))
		return

	if(!COOLDOWN_CHECK(src, cooldown_timer))
		return

	if((jumper.getStaminaLoss()) > -stamina_cost)
		to_chat(jumper, span_warning("Catch your breathe!"))
		return

	playsound(jumper, "jump", 65)
	jumper.layer = ABOVE_MOB_LAYER

	jumper.adjustStaminaLoss(stamina_cost)
	jumper.flags_pass |= HOVERING|PASSPROJECTILE

	jumper.animation_spin(5, 2, jumper.dir == WEST ? FALSE : TRUE)
	animate(jumper, pixel_y = jumper.pixel_y + 40, layer = ABOVE_MOB_LAYER, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = initial(jumper.pixel_y), time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(end_jump), jumper), jump_duration)

	COOLDOWN_START(src, cooldown_timer, jump_cooldown)

///Ends the jump
/datum/element/jump/proc/end_jump(mob/living/jumper)
	jumper.flags_pass &= ~HOVERING|PASSPROJECTILE
