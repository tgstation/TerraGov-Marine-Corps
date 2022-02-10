/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return
	if(interactee)// moving stops any kind of interaction
		unset_interaction()
	if(shoes && !buckled)
		var/obj/item/clothing/shoes/S = shoes
		S.step_action()


/mob/living/carbon/human/proc/Process_Cloaking_Router(mob/living/carbon/human/user)
	if(!user.cloaking)
		return
	if(istype(back, /obj/item/storage/backpack/marine/satchel/scout_cloak/scout) )
		Process_Cloaking_Scout(user)
	else if(istype(back, /obj/item/storage/backpack/marine/satchel/scout_cloak/sniper) )
		Process_Cloaking_Sniper(user)

/mob/living/carbon/human/proc/Process_Cloaking_Scout(mob/living/carbon/human/user)
	var/obj/item/storage/backpack/marine/satchel/scout_cloak/scout/S = back
	if(!S.camo_active)
		return
	if(S.camo_last_shimmer > world.time - SCOUT_CLOAK_STEALTH_DELAY) //Shimmer after taking aggressive actions
		alpha = SCOUT_CLOAK_RUN_ALPHA //50% invisible
		S.camo_adjust_energy(src, SCOUT_CLOAK_RUN_DRAIN)
	else if(S.camo_last_stealth > world.time - SCOUT_CLOAK_STEALTH_DELAY) //We have an initial reprieve at max invisibility allowing us to reposition, albeit at a high drain rate
		alpha = SCOUT_CLOAK_STILL_ALPHA //95% invisible
		S.camo_adjust_energy(src, SCOUT_CLOAK_RUN_DRAIN)
	//Walking stealth
	else if(m_intent == MOVE_INTENT_WALK)
		alpha = SCOUT_CLOAK_WALK_ALPHA //80% invisible
		S.camo_adjust_energy(src, SCOUT_CLOAK_WALK_DRAIN)
	//Running and post-attack stealth
	else
		alpha = SCOUT_CLOAK_RUN_ALPHA //50% invisible
		S.camo_adjust_energy(src, SCOUT_CLOAK_RUN_DRAIN)

/mob/living/carbon/human/proc/Process_Cloaking_Sniper(mob/living/carbon/human/user)
	var/obj/item/storage/backpack/marine/satchel/scout_cloak/sniper/S = back
	if(!S.camo_active)
		return
	alpha = initial(alpha) //Sniper variant has *no* mobility stealth, but no drain on movement either

/mob/living/carbon/human/Process_Spacemove()
	if(restrained())
		return FALSE

	return ..()


/mob/living/carbon/human/Process_Spaceslipping(prob_slip = 5)
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.

	if(stat)
		prob_slip = 0 // Changing this to zero to make it line up with the comment, and also, make more sense.

	//Do we have magboots or such on if so no slip
	if(istype(shoes, /obj/item/clothing/shoes/magboots) && (shoes.flags_inventory & NOSLIPPING))
		prob_slip = 0

	//Check hands and mod slip
	if(!l_hand)	prob_slip -= 2
	else if(l_hand.w_class <= 2)	prob_slip -= 1
	if (!r_hand)	prob_slip -= 2
	else if(r_hand.w_class <= 2)	prob_slip -= 1

	prob_slip = round(prob_slip)
	return(prob_slip)


/mob/living/carbon/human/Moved(atom/oldloc, direction)
	Process_Cloaking_Router(src)
	return ..()
