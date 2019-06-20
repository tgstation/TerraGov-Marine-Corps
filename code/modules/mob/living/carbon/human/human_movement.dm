/mob/living/carbon/human/movement_delay()
	. = ..()

	if(interactee)// moving stops any kind of interaction
		unset_interaction()

	if(species.slowdown)
		. += species.slowdown

	if(embedded_flag)
		handle_embedded_objects() //Moving with objects stuck in you can cause bad times.

	var/reducible_tally = 0 //Tally elements that can be reduced are put here, then we apply hyperzine effects

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 40)
		reducible_tally += round(health_deficiency / 25)

	if(!(species && (species.species_flags & NO_PAIN)))
		if(halloss >= 10)
			reducible_tally += round(halloss / 15) //halloss shouldn't slow you down if you can't even feel it

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if(hungry >= 50) //Level where a yellow food pip shows up, aka hunger level 3 at 250 nutrition and under
		reducible_tally += hungry/50 //Goes from a slowdown of 1 all the way to 2 for total starvation

	//Equipment slowdowns
	if(w_uniform)
		reducible_tally += w_uniform.slowdown

	if(wear_suit)
		reducible_tally += wear_suit.slowdown

	if(shock_stage >= 10)
		reducible_tally += 3

	if(bodytemperature < species.cold_level_1)
		reducible_tally += 2 //Major slowdown if you're freezing

	if(temporary_slowdown)
		temporary_slowdown = max(temporary_slowdown - 1, 0)
		reducible_tally += 2 //Temporary slowdown slows hard

	//Compile reducible tally and send it to total tally. Cannot go more than 1 units faster from the reducible tally!
	. += max(-0.7, reducible_tally)

	if(istype(get_active_held_item(), /obj/item/weapon/gun))
		var/obj/item/weapon/gun/G = get_active_held_item() //If wielding, it will ALWAYS be on the active hand
		. += G.slowdown

	if(istype(buckled, /obj/structure/bed/chair/wheelchair))
		for(var/organ_name in list("l_hand","r_hand","l_arm","r_arm","chest","groin","head"))
			var/datum/limb/E = get_limb(organ_name)
			if(!E || (E.limb_status & LIMB_DESTROYED))
				. += 4
			if(E.limb_status & LIMB_SPLINTED || E.limb_status & LIMB_STABILIZED)
				. += 0.65
			else if(E.limb_status & LIMB_BROKEN)
				. += 1.5
	else
		if(shoes)
			var/obj/item/clothing/shoes/S = shoes
			S.step_action()
			. += shoes.slowdown

		for(var/organ_name in list("l_foot","r_foot","l_leg","r_leg","chest","groin","head"))
			var/datum/limb/E = get_limb(organ_name)
			if(!E || (E.limb_status & LIMB_DESTROYED))
				. += 4
			if(E.limb_status & LIMB_SPLINTED || E.limb_status & LIMB_STABILIZED)
				. += 0.75
			else if(E.limb_status & LIMB_BROKEN)
				. += 1.5

	if(slowdown)
		. += slowdown

	if(mobility_aura)
		. -= 0.1 + 0.1 * mobility_aura

	. += CONFIG_GET(number/outdated_movedelay/human_delay)

	. = max(-2.5, . + reagent_move_delay_modifier) //hyperzine and ultrazine

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

	if(species.species_flags & NO_SLIP)
		return

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