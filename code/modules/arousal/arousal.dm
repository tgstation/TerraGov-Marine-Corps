/mob/living
	var/mb_cd_length = 5 SECONDS						//5 second cooldown for masturbating because fuck spam.
	var/mb_cd_timer = 0									//The timer itself

/mob/living/carbon/human
	var/saved_underwear = ""//saves their underwear so it can be toggled later
	var/saved_undershirt = ""
	var/saved_socks = ""
	var/hidden_underwear = FALSE
	var/hidden_undershirt = FALSE
	var/hidden_socks = FALSE

//Mob procs
/*mob/living/carbon/human/proc/underwear_toggle()
	set name = "Toggle undergarments"
	set category = "IC"

	var/confirm = input(src, "Select what part of your form to alter", "Undergarment Toggling") as null|anything in list("Top", "Bottom", "Socks", "All")
	if(!confirm)
		return
	switch(confirm)
		if("Top")
			hidden_undershirt = !hidden_undershirt
		if("Bottom")
			hidden_underwear = !hidden_underwear
		if("Socks")
			hidden_socks = !hidden_socks
		if("All")
			var/on_off = (hidden_undershirt || hidden_underwear || hidden_socks) ? FALSE : TRUE
			hidden_undershirt = on_off
			hidden_underwear = on_off
			hidden_socks = on_off

	update_body(TRUE)
*/

/mob/living/carbon/human/proc/adjust_arousal(strength, aphro = FALSE, maso = FALSE) // returns all genitals that were adjusted
	var/list/datum/internal_organ/genital/genit_list = list()
	//if(!client?.prefs.arousable || (aphro && (client?.prefs.cit_toggles & NO_APHRO)) || (maso && !HAS_TRAIT(src, TRAIT_MASO)))
	//	return // no adjusting made here
	for(var/datum/internal_organ/genital/G in internal_organs)
		if((G.genital_flags & GENITAL_CAN_AROUSE) && !G.aroused_state && prob(strength * G.sensitivity))
			G.set_aroused_state(strength > 0)
			G.update_appearance()
			if(G.aroused_state)
				genit_list += G
	return genit_list

/mob/living/carbon/human/proc/do_climax(datum/reagents/R, atom/target, datum/internal_organ/genital/G, spill = TRUE)
	if(!G)
		return
	if(!target || !R)
		return
	var/turfing = isturf(target)
	G.generate_fluid(R)
	if(spill && R.total_volume >= 5)
		R.reaction(turfing ? target : target.loc, TOUCH, 1, FALSE)
	if(!turfing)
		R.trans_to(target, R.total_volume * (spill ? G.fluid_transfer_factor : 1))
	G.time_since_last_orgasm = 0
	R.clear_reagents()

/mob/living/carbon/human/proc/mob_climax_outside(datum/internal_organ/genital/G, mb_time = 3 SECONDS) //This is used for forced orgasms and other hands-free climaxes
	var/datum/reagents/fluid_source = G.climaxable(src, TRUE)
	if(!fluid_source)
		to_chat(src, "<span class='userdanger'>Your [G.name] cannot cum.</span>")
		return
	if(mb_time) //as long as it's not instant, give a warning
		to_chat(src, "<span class='userlove'>You feel yourself about to orgasm.</span>")
		if(!do_after(src, mb_time, target = src) || !G.climaxable(src, TRUE))
			return
	to_chat(src, "<span class='userlove'>You climax[isturf(loc) ? " onto [loc]" : ""] with your [G.name].</span>")
	do_climax(fluid_source, loc, G)

/mob/living/carbon/human/proc/mob_climax_partner(datum/internal_organ/genital/G, mob/living/L, spillage = TRUE, mb_time = 3 SECONDS) //Used for climaxing with any living thing
	var/datum/reagents/fluid_source = G.climaxable(src)
	if(!fluid_source)
		return
	if(mb_time) //Skip warning if this is an instant climax
		to_chat(src, "<span class='userlove'>You're about to climax with [L]!</span>")
		to_chat(L, "<span class='userlove'>[src] is about to climax with you!</span>")
		if(!do_after(src, mb_time, target = src) || !in_range(src, L) || !G.climaxable(src, TRUE))
			return
	if(spillage)
		to_chat(src, "<span class='userlove'>You orgasm with [L], spilling out of them, using your [G.name].</span>")
		to_chat(L, "<span class='userlove'>[src] climaxes with you, overflowing and spilling, using [p_their()] [G.name]!</span>")
	else //knots and other non-spilling orgasms
		to_chat(src, "<span class='userlove'>You climax with [L], your [G.name] spilling nothing.</span>")
		to_chat(L, "<span class='userlove'>[src] climaxes with you, [p_their()] [G.name] spilling nothing!</span>")
	do_climax(fluid_source, spillage ? loc : L, G, spillage)

/mob/living/carbon/human/proc/mob_fill_container(datum/internal_organ/genital/G, obj/item/reagent_containers/container, mb_time = 3 SECONDS) //For beaker-filling, beware the bartender
	var/datum/reagents/fluid_source = G.climaxable(src)
	if(!fluid_source)
		return
	if(mb_time)
		to_chat(src,"<span class='userlove'>You start to [G.masturbation_verb] your [G.name] over [container].</span>")
		if(!do_after(src, mb_time, target = src) || !in_range(src, container) || !G.climaxable(src, TRUE))
			return
	to_chat(src,"<span class='userlove'>You used your [G.name] to fill [container].</span>")
	do_climax(fluid_source, container, G, FALSE)

/mob/living/carbon/human/proc/pick_climax_genitals(silent = FALSE)
	var/list/genitals_list

	for(var/datum/internal_organ/genital/G in internal_organs)
		if((G.genital_flags & CAN_CLIMAX_WITH) && G.is_exposed()) //filter out what you can't masturbate with
			LAZYADD(genitals_list, G)
	if(LAZYLEN(genitals_list))
		var/datum/internal_organ/genital/ret_organ = input(src, "With what?", "Climax") as null|anything in genitals_list
		return ret_organ
	else if(!silent)
		to_chat(src, "<span class='warning'>You cannot climax without available genitals.</span>")

/mob/living/carbon/human/proc/pick_partner(silent = FALSE)
	var/list/partners = list()
	if(pulling)
		partners += pulling
	if(pulledby)
		partners += pulledby
	//Now we got both of them, let's check if they're a proper
	for(var/mob/living/L in partners)
		if(!L.client || !L.mind) // can't consent, not a partner
			partners -= L
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if(!length(C.exposed_genitals) && !C.is_groin_exposed() && !C.is_chest_exposed()) //Nothing through_clothing, no proper partner.
				partners -= C
	//NOW the list should only contain correct partners
	if(!length(partners))
		if(!silent)
			to_chat(src, "<span class='warning'>You cannot do this alone.</span>")
		return //No one left.
	var/mob/living/target = input(src, "With whom?", "Sexual partner") as null|anything in partners //pick one, default to null
	if(target && in_range(src, target))
		to_chat(src, "<span class='notice'>Waiting for consent...</span>")
		var/consenting = input(target, "Do you want [src] to climax with you?", "Climax mechanics", "No") in list("Yes", "No")
		if(consenting == "Yes")
			return target
		else
			message_admins("[src] tried to climax with [target], but [target] did not consent.")
			//log_consent("[src] tried to climax with [target], but [target] did not consent.")

/mob/living/carbon/human/proc/pick_climax_container(silent = FALSE)
	var/list/containers_list = list()

	var/obj/item/reagent_containers/held_c = get_held_item()
	if(istype(held_c) && (held_c.is_open_container() || istype(held_c, /obj/item/reagent_containers/food/snacks)))
		containers_list += held_c
	for(var/obj/item/reagent_containers/C in range(1, src))
		if((C.is_open_container() || istype(C, /obj/item/reagent_containers/food/snacks)) && CanReach(C))
			containers_list += C

	if(length(containers_list))
		var/obj/item/reagent_containers/SC = input(src, "Into or onto what? (Cancel for nowhere)", null) as null|obj in containers_list
		if(SC && CanReach(SC))
			return SC
	else if(!silent)
		to_chat(src, "<span class='warning'>You cannot do this without an appropriate container.</span>")

/mob/living/carbon/human/proc/available_rosie_palms(silent = FALSE, list/whitelist_typepaths = list(/obj/item/dildo))
	if(restrained(TRUE)) //TRUE ignores grabs
		if(!silent)
			to_chat(src, "<span class='warning'>You can't do that while restrained!</span>")
		return FALSE
	if(!(has_limb(HAND_LEFT) && has_limb(HAND_RIGHT)))
		return FALSE
	if(get_item_by_slot(SLOT_L_HAND) && get_item_by_slot(SLOT_R_HAND)) //No free hands
		if(whitelist_typepaths)
			if(!islist(whitelist_typepaths))
				whitelist_typepaths = list(whitelist_typepaths)
			for(var/path in whitelist_typepaths)
				if(is_item_in_hands(path))
					return TRUE
		if(!silent)
			to_chat(src, "<span class='warning'>You need at least one free arm.</span>")
		return FALSE
	return TRUE


//Here's the main proc itself
//skyrat edit - forced partner and spillage
/mob/living/carbon/human/proc/mob_climax(forced_climax = FALSE, mob/living/forced_partner = null, forced_spillage = TRUE) //Forced is instead of the other proc, makes you cum if you have the tools for it, ignoring restraints
	if(mb_cd_timer > world.time)
		if(!forced_climax) //Don't spam the message to the victim if forced to come too fast
			to_chat(src, "<span class='warning'>You need to wait [DisplayTimeText((mb_cd_timer - world.time), TRUE)] before you can do that again!</span>")
		return

	//if(!client?.prefs.arousable)
	//	return
	if(stat == DEAD)
		if(!forced_climax)
			to_chat(src, "<span class='warning'>You can't do that while dead!</span>")
		return
	if(forced_climax)
		for(var/datum/internal_organ/genital/G in internal_organs)
			if(G.genital_flags & CAN_CLIMAX_WITH) //Skip things like wombs and testicles
				continue
			var/mob/living/partner
			var/check_target

			if(G.is_exposed())
				if(pulling) //Are we pulling someone? Priority target, we can't be making option menus for this, has to be quick
					if(isliving(pulling)) //Don't fuck objects
						check_target = pulling
				if(pulledby && !check_target) //prioritise pulled over pulledby
					if(isliving(pulledby))
						check_target = pulledby
				//Now we should have a partner, or else we have to come alone
				if(check_target)
					if(iscarbon(check_target)) //carbons can have clothes
						var/mob/living/carbon/C = check_target
						if(length(C.exposed_genitals) || C.is_groin_exposed() || C.is_chest_exposed()) //Are they naked enough?
							partner = C
					else //A cat is fine too
						partner = check_target
				//skyrat edit
				if(forced_partner)
					if(forced_partner == "none" || !istype(forced_partner))
						partner = null
					else
						partner = forced_partner
				//
				if(partner) //Did they pass the clothing checks?
					//skyrat edit
					mob_climax_partner(G, partner, spillage = forced_spillage, mb_time = 0) //Instant climax due to forced
					//
					continue //You've climaxed once with this organ, continue on
			//not exposed OR if no partner was found while exposed, climax alone
			mob_climax_outside(G, mb_time = 0) //removed climax timer for sudden, forced orgasms
		//Now all genitals that could climax, have.
		//Since this was a forced climax, we do not need to continue with the other stuff
		mb_cd_timer = world.time + mb_cd_length
		return
	//If we get here, then this is not a forced climax and we gotta check a few things.

	if(stat == UNCONSCIOUS) //No sleep-masturbation, you're unconscious.
		to_chat(src, "<span class='warning'>You must be conscious to do that!</span>")
		return

	//Ok, now we check what they want to do.
	var/choice = input(src, "Select sexual activity", "Sexual activity:") as null|anything in list("Climax alone", "Climax with partner", "Fill container")
	if(!choice)
		return

	switch(choice)
		if("Climax alone")
			if(!available_rosie_palms())
				return
			var/datum/internal_organ/genital/picked_organ = pick_climax_genitals()
			if(picked_organ && available_rosie_palms())
				mob_climax_outside(picked_organ)
		if("Climax with partner")
			//We need no hands, we can be restrained and so on, so let's pick an organ
			var/datum/internal_organ/genital/picked_organ = pick_climax_genitals()
			if(picked_organ)
				var/mob/living/partner = pick_partner() //Get someone
				if(partner)
					var/spillage = input(src, "Would your fluids spill outside?", "Choose overflowing option", "Yes") as null|anything in list("Yes", "No")
					if(spillage && in_range(src, partner))
						mob_climax_partner(picked_organ, partner, spillage == "Yes" ? TRUE : FALSE)
		if("Fill container")
			//We'll need hands and no restraints.
			if(!available_rosie_palms(FALSE, /obj/item/reagent_containers))
				return
			//We got hands, let's pick an organ
			var/datum/internal_organ/genital/picked_organ = pick_climax_genitals() //Gotta be climaxable, not just masturbation, to fill with fluids.
			if(picked_organ)
				//Good, got an organ, time to pick a container
				var/obj/item/reagent_containers/fluid_container = pick_climax_container()
				if(fluid_container && available_rosie_palms(FALSE, /obj/item/reagent_containers))
					mob_fill_container(picked_organ, fluid_container)

	mb_cd_timer = world.time + mb_cd_length

/mob/living/carbon/human/verb/climax_verb()
	set category = "IC"
	set name = "Climax"
	set desc = "Lets you choose a couple ways to ejaculate."
	mob_climax()
