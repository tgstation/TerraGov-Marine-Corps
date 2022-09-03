
/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/

/mob/living/carbon/human/RestrainedClickOn(atom/A) //chewing your handcuffs
	if (A != src) return ..()
	var/mob/living/carbon/human/H = A

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CHEW))
		to_chat(H, span_warning("You can't bite your hand again yet..."))
		return

	if (!H.handcuffed)
		return
	if (H.a_intent != INTENT_HARM)
		return
	if (H.zone_selected != "mouth")
		return
	if (H.wear_mask)
		return
	if (istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket))
		return

	var/datum/limb/O = H.get_limb(H.hand?"l_hand":"r_hand")
	if (!O) return

	var/s = span_warning("[H.name] chews on [H.p_their()] [O.display_name]!")
	H.visible_message(s, span_warning("You chew on your [O.display_name]!"))
	H.log_message("[s] ([key_name(H)])", LOG_ATTACK)

	if(O.take_damage_limb(1, 0, TRUE, TRUE))
		H.UpdateDamageIcon()

	TIMER_COOLDOWN_START(src, COOLDOWN_CHEW, 7.5 SECONDS)


/mob/living/carbon/human/UnarmedAttack(atom/A, proximity, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return

	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines

	// Special glove functions:
	// If the gloves do anything, have them return TRUE to stop the touch
	// normal attack_hand() here.
	if(proximity && istype(G) && G.Touch(A, 1))
		return

	var/datum/limb/temp = get_limb(hand ? "l_hand" : "r_hand")
	if(temp && !temp.is_usable())
		to_chat(src, "<span class='notice'>You try to move your [temp.display_name], but cannot!")
		return

	if(LAZYACCESS(modifiers, "right"))
		A.attack_hand_alternate(src)
		return

	SEND_SIGNAL(src, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, A)

	if(species?.spec_unarmedattack(src, A)) //Because species like monkeys dont use attack hand
		return
	A.attack_hand(src)
