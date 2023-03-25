#define LEFT_HIT "Left Hit"
#define RIGHT_HIT "Right Hit"
#define COMBO_STEPS "steps"
#define COMBO_PROC "proc"
#define ATTACK_BASH "Bash"

/obj/item/weapon/twohanded/martialstaff
	name = "Martial Arts Staff"
	desc = "A martial arts staff, made out of the most pristine wood imaginable."
	icon_state = "martialstaff"
	item_state = "martialstaff"
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	flags_item = TWOHANDED
	force_wielded = 25
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	attack_speed = 3
	attack_speed_alternate = 11

	hitsound = 'sound/weapons/wood_hit.ogg'

	///How much time has passed since the last time the user hit a mob
	var/last_hit_time
	///Tracks what hits the user has used
	var/list/input_list = list()
	///Used to update description when combos are added to combo_list
	var/list/combo_strings = list()
	///List of all combos that are possible to perform
	var/static/list/combo_list = list(
		ATTACK_BASH = list(COMBO_STEPS = list(LEFT_HIT, LEFT_HIT, LEFT_HIT), COMBO_PROC = PROC_REF(jab)),
	)

/obj/item/weapon/twohanded/martialstaff/Initialize()
	. = ..()
	for(var/combo in combo_list)
		var/list/combo_specifics = combo_list[combo]
		var/step_string = english_list(combo_specifics[COMBO_STEPS])
		combo_strings += span_notice("<b>[combo]</b> - [step_string]")

/obj/item/weapon/twohanded/martialstaff/examine(mob/user)
	. = ..()
	. += combo_strings

/obj/item/weapon/twohanded/martialstaff/attack(mob/living/carbon/xenomorph/target, mob/user, has_proximity, click_parameters)
	if(target.stat == DEAD || target == user)
		return ..()

	combo_status(user)
	input_list += LEFT_HIT

	if(check_input(target, user))
		reset_inputs(null, TRUE)
		return TRUE
	else
		last_hit_time = addtimer(CALLBACK(src, PROC_REF(reset_inputs), user, FALSE), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return ..()

/obj/item/weapon/twohanded/martialstaff/attack_alternate(mob/living/carbon/xenomorph/target, mob/user, has_proximity, click_parameters)
	if(target.stat == DEAD || target == user)
		return ..()

	combo_status(user)
	last_hit_time = world.time
	input_list += RIGHT_HIT

	if(check_input(target, user))
		reset_inputs(null, TRUE)
		return TRUE
	else
		last_hit_time = addtimer(CALLBACK(src, PROC_REF(reset_inputs), user, FALSE), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return ..()

///Update manually to the maximum combo chain. Checks if you've gone over the maximum combo
/obj/item/weapon/twohanded/martialstaff/proc/combo_status(mob/user)
	if(length(input_list) > 3)
		reset_inputs(user, TRUE)

/obj/item/weapon/twohanded/martialstaff/proc/check_input(mob/living/target, mob/user)
	for(var/combo in combo_list)
		var/list/combo_specifics = combo_list[combo]
		if(compare_list(input_list,combo_specifics[COMBO_STEPS]))
			INVOKE_ASYNC(src, combo_specifics[COMBO_PROC], target, user)
			return TRUE
	return FALSE

/obj/item/weapon/twohanded/martialstaff/proc/reset_inputs(mob/user, deltimer)
	input_list.Cut()
	if(user)
		balloon_alert(user, "you return to neutral stance")
	if(deltimer && last_hit_time)
		deltimer(last_hit_time)

/obj/item/weapon/twohanded/martialstaff/unique_action(mob/user, special_treatment)
	. = ..()
	reset_inputs(user, TRUE)


/obj/item/weapon/twohanded/martialstaff/proc/jab(mob/living/target, mob/user)
	balloon_alert(user, "Jab Attack")
	target.apply_damage(damage = 25)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	playsound(src, "sound/weapons/punch3.ogg", 40)


