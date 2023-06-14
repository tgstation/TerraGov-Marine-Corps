#define HUMAN_JUMP_DURATION 1 SECONDS
#define HUMAN_JUMP_COOLDOWN 1.5 SECONDS
#define HUMAN_JUMP_STAMINA_COST 20

/mob/living/carbon/human
	COOLDOWN_DECLARE(jump_cooldown)

/mob/living/carbon/human/proc/do_jump()
	set name = "Jump"
	set category = "IC"

	if(incapacitated(TRUE))
		return

	if(!COOLDOWN_CHECK(src, jump_cooldown))
		return

	if((max_stamina - getStaminaLoss()) < HUMAN_JUMP_STAMINA_COST)
		to_chat(src, span_warning("Catch your breathe!"))
		return

	playsound(src, "jump", 65)
	adjustStaminaLoss(HUMAN_JUMP_STAMINA_COST)
	layer = ABOVE_MOB_LAYER
	flags_pass |= PASSTABLE
	COOLDOWN_START(src, jump_cooldown, HUMAN_JUMP_COOLDOWN)
	animation_spin(5, 2)
	animate(src, pixel_y = pixel_y + 40, layer = ABOVE_MOB_LAYER, time = HUMAN_JUMP_DURATION / 2, \
		easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = initial(pixel_y), time = HUMAN_JUMP_DURATION / 2, easing = CIRCULAR_EASING|EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(end_jump), src), HUMAN_JUMP_DURATION)

/mob/living/carbon/human/proc/end_jump()
	flags_pass &= ~PASSTABLE
