
/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/

/mob/living/carbon/human/RestrainedClickOn(atom/A) //chewing your handcuffs
	if (A != src) return ..()
	var/mob/living/carbon/human/H = A

	if(cooldowns[COOLDOWN_CHEW])
		to_chat(H, "<span class='warning'>You can't bite your hand again yet...</span>")
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

	var/s = "<span class='warning'>[H.name] chews on [H.p_their()] [O.display_name]!</span>"
	H.visible_message(s, "<span class='warning'>You chew on your [O.display_name]!</span>")
	H.log_message("[s] ([key_name(H)])", LOG_ATTACK)

	if(O.take_damage_limb(1, 0, TRUE, TRUE))
		H.UpdateDamageIcon()

	cooldowns[COOLDOWN_CHEW] = addtimer(VARSET_LIST_CALLBACK(cooldowns, COOLDOWN_CHEW, null), 7.5 SECONDS)


/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)
	if(lying) //No attacks while laying down
		return FALSE

	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	if(proximity && istype(G) && G.Touch(A, 1))
		return

	var/datum/limb/temp = get_limb(hand ? "l_hand" : "r_hand")
	if(temp && !temp.is_usable())
		to_chat(src, "<span class='notice'>You try to move your [temp.display_name], but cannot!")
		return

	changeNext_move(CLICK_CD_MELEE)
	SEND_SIGNAL(src, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, A)
	A.attack_hand(src)


/atom/proc/attack_hand(mob/living/user)
	. = FALSE
	if(QDELETED(src))
		CRASH("attack_hand on a qdeleted atom")
	add_fingerprint(user, "attack_hand")
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
