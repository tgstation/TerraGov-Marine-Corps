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

/datum/component/jump/Initialize(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, _jump_flags, _jumper_allow_pass_flags)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	set_vars(_jump_duration, _jump_cooldown, _stamina_cost, _jump_height, _jump_sound, _jump_flags, _jumper_allow_pass_flags)

/datum/component/jump/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_KB_LIVING_JUMP_DOWN, COMSIG_MOB_THROW))

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

	UnregisterSignal(parent, list(COMSIG_KB_LIVING_JUMP_DOWN))
	if(jump_flags & JUMP_CHARGEABLE)
		RegisterSignal(parent, COMSIG_KB_LIVING_JUMP_DOWN, PROC_REF(charge_jump))
		RegisterSignal(parent, COMSIG_KB_LIVING_JUMP_UP, PROC_REF(do_jump))
	else
		RegisterSignal(parent, COMSIG_KB_LIVING_JUMP_DOWN, PROC_REF(do_jump))

///Starts charging the jump
/datum/component/jump/proc/charge_jump(mob/living/jumper)
	jump_start_time = world.timeofday

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
	var/original_pass_flags = jumper.pass_flags

	SEND_SIGNAL(jumper, COMSIG_ELEMENT_JUMP_STARTED, effective_jump_height, effective_jump_duration)
	jumper.adjustStaminaLoss(stamina_cost)
	jumper.pass_flags |= effective_jumper_allow_pass_flags
	ADD_TRAIT(jumper, TRAIT_SILENT_FOOTSTEPS, JUMP_COMPONENT)
	RegisterSignal(parent, COMSIG_MOB_THROW, PROC_REF(jump_throw))

	jumper.add_filter(JUMP_COMPONENT, 2, drop_shadow_filter(color = COLOR_TRANSPARENT_SHADOW, size = 0.9))
	var/shadow_filter = jumper.get_filter(JUMP_COMPONENT)

	if(jump_flags & JUMP_SPIN)
		var/spin_number = ROUND_UP(effective_jump_duration * 0.1)
		jumper.animation_spin(effective_jump_duration / spin_number, spin_number, jumper.dir == WEST ? FALSE : TRUE)

	animate(jumper, pixel_y = jumper.pixel_y + effective_jump_height, layer = MOB_JUMP_LAYER, time = effective_jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = jumper.pixel_y - effective_jump_height, layer = original_layer, time = effective_jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	if(jump_flags & JUMP_SHADOW)
		animate(shadow_filter, y = -effective_jump_height, size = 4, time = effective_jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
		animate(y = 0, size = 0.9, time = effective_jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(end_jump), jumper, original_pass_flags), effective_jump_duration)

	TIMER_COOLDOWN_START(jumper, JUMP_COMPONENT_COOLDOWN, jump_cooldown)

///Ends the jump
/datum/component/jump/proc/end_jump(mob/living/jumper, original_pass_flags)
	jumper.remove_filter(JUMP_COMPONENT)
	jumper.pass_flags = original_pass_flags
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
