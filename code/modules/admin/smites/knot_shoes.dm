/// Ties the target's shoes
/datum/smite/knot_shoes
	name = "Knot Shoes"

/datum/smite/knot_shoes/effect(client/user, mob/living/carbon/human/target)
	. = ..()
	if (!ishuman(target))
		to_chat(user, span_warning("This creature does not have any shoes. Aborting."), confidential = TRUE)
		return
	var/obj/item/clothing/shoes/sick_kicks = target.shoes //our target's shoes
	if (!sick_kicks?.can_be_tied)
		to_chat(user, span_warning("[target] does not have knottable shoes!"), confidential = TRUE)
		return
	if (sick_kicks.tied == SHOES_TIED) //if tied knot the shoes of our victim
		sick_kicks.adjust_laces(SHOES_KNOTTED) 
	else //If we're already knotted, revert them back to being tied. Marines aren't smart enough to unknot their own shoes without divine intervention.
		if (tgui_alert(usr, "Unknot the shoes of [target]?", "Continue?", list("Yes", "No")) != "Yes")
			return
		sick_kicks.adjust_laces(SHOES_TIED)
		to_chat(target, span_warning("Your knotted shoelaces unravel again as a divine force washes over them."), confidential = TRUE)

/obj/item/clothing/shoes/proc/adjust_laces(state, mob/user) //adjust the state of target shoes to be tied/untied 
	if(!can_be_tied)
		return
	tied = state
	if(tied == SHOES_TIED)
		UnregisterSignal(src, COMSIG_SHOES_STEP_ACTION)
	else
		RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, .proc/check_trip, override=TRUE)
		

/obj/item/clothing/shoes/proc/check_trip() //check the state of our shoe laces
	SIGNAL_HANDLER
	var/mob/living/carbon/human/our_guy = loc
	if(!istype(our_guy)) // are they REALLY /our guy/?
		return
	if(tied == SHOES_KNOTTED)
		our_guy.Paralyze(10)
		our_guy.Knockdown(20)
		our_guy.adjustStaminaLoss(10) //smacking into the ground drains energy
		our_guy.visible_message(span_danger("[our_guy] trips on [our_guy.p_their()] knotted shoelaces and falls! What a klutz!"), span_userdanger("You trip on your knotted shoelaces and smack into the ground!"))
