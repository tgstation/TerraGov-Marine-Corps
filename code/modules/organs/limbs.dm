/****************************************************
				EXTERNAL ORGANS
****************************************************/
/datum/limb
	///Actual name of the limb
	var/name = "limb"
	var/icon_name = null
	var/body_part = null
	///Whether the icon created for this limb is LEFT, RIGHT or 0. Currently utilised for legs and feet
	var/icon_position = 0
	var/damage_state = "00"
	///brute damage this limb has taken as a part
	var/brute_dam = 0
	///burn damage this limb has taken as a part
	var/burn_dam = 0
	///Max damage the limb can take before being destroyed
	var/max_damage = 0
	var/max_size = 0
	var/last_dam = -1
	var/supported = FALSE
	///How many instances of damage the limb can take before its splints fall off
	var/splint_health = 0

	var/datum/armor/soft_armor
	var/datum/armor/hard_armor

	var/display_name
	var/list/wounds = list()
	var/number_wounds = 0 // cache the number of wounds, which is NOT wounds.len!

	var/min_broken_damage = 30

	var/datum/limb/parent
	var/list/datum/limb/children

	///List of Internal organs of this body part
	var/list/datum/internal_organ/internal_organs

	/// Message that displays when you feel pain from this limb
	var/damage_msg = "<span class='warning'> You feel an intense pain</span>"
	var/broken_description

	var/surgery_open_stage = 0
	var/bone_repair_stage = 0
	var/limb_replacement_stage = 0
	var/necro_surgery_stage = 0
	var/cavity = 0

	///Whether someone is currently doing surgery on this limb
	var/in_surgery_op = FALSE
	var/surgery_organ //name of the organ currently being surgically worked on (detach/remove/etc)

	var/encased       // Needs to be opened with a saw to access the organs.

	var/obj/item/hidden = null
	///[/obj/item/implant] Implants contained within this specific limb
	var/list/implants = list()

	///how often wounds should be updated, a higher number means less often
	var/wound_update_accuracy = 1
	var/limb_status = NONE //limb status flags

	///Human owner mob of this limb
	var/mob/living/carbon/human/owner = null
	///Whether this limb is vital, if true you die on losing it (todo make a flag)
	var/vital = FALSE
	///INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE
	var/germ_level = 0

	///What % of the body does this limb cover. Make sure that the sum is always 100.
	var/cover_index = 0


/datum/limb/New(datum/limb/P, mob/mob_owner)
	if(P)
		parent = P
		if(!parent.children)
			parent.children = list()
		parent.children.Add(src)
	if(mob_owner)
		owner = mob_owner
	soft_armor = getArmor()
	hard_armor = getArmor()
	return ..()

/datum/limb/Destroy()
	QDEL_NULL(hidden)
	owner = null
	parent = null
	children = null
	soft_armor = null
	hard_armor = null
	return ..()

/*
/datum/limb/proc/get_icon(icon/race_icon, icon/deform_icon)
	return icon('icons/mob/human.dmi',"blank")
*/


//Germs
/datum/limb/proc/handle_antibiotics()
	var/spaceacillin = owner.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin)
	var/polyhexanide = owner.reagents.get_reagent_amount(/datum/reagent/medicine/polyhexanide)

	var/spaceacillin_curve = list(0,4,3,2)
	var/polyhexanide_curve = list(0,1,1,10)

	if (!germ_level || (spaceacillin + polyhexanide) < MIN_ANTIBIOTICS)
		return

	var/infection_level = 0
	switch(germ_level)
		if(-INFINITY to 10)
			germ_level = 0
			return // cure instantly
		if(11 to INFECTION_LEVEL_ONE)
			infection_level = 1
		if(INFECTION_LEVEL_ONE - 1 to INFECTION_LEVEL_TWO)
			infection_level = 2
		if(INFECTION_LEVEL_TWO - 1 to INFINITY)
			infection_level = 3

	if (spaceacillin >= MIN_ANTIBIOTICS)
		germ_level -= spaceacillin_curve[infection_level]

	if (polyhexanide >= MIN_ANTIBIOTICS)
		germ_level -= polyhexanide_curve[infection_level]





/****************************************************
			DAMAGE PROCS
****************************************************/

/datum/limb/proc/emp_act(severity)
	if(!(limb_status & LIMB_ROBOT))	//meatbags do not care about EMP
		return
	var/probability = 30
	var/damage = 15
	if(severity == 2)
		probability = 1
		damage = 3
	if(prob(probability))
		droplimb()
	else
		take_damage_limb(damage, 0, TRUE, TRUE)


/datum/limb/proc/take_damage_limb(brute, burn, sharp, edge, blocked = 0, updating_health = FALSE, list/forbidden_limbs = list())
	var/hit_percent = (100 - blocked) * 0.01

	if(hit_percent <= 0) //total negation
		return FALSE

	if(brute)
		brute *= CLAMP01(hit_percent) //Percentage reduction
	if(burn)
		burn *= CLAMP01(hit_percent) //Percentage reduction

	if((brute <= 0) && (burn <= 0))
		return 0

	if(limb_status & LIMB_DESTROYED)
		return 0

	if(limb_status & LIMB_ROBOT)
		if(issynth(owner))
			brute *= owner.species.brute_mod
			burn *= owner.species.burn_mod
		else
			brute *= 0.50 // half damage for ROBOLIMBS
			burn *= 0.50 // half damage for ROBOLIMBS

	//High brute damage or sharp objects may damage internal organs
	if(internal_organs && ((sharp && brute >= 10) || brute >= 20) && prob(5))
		//Damage an internal organ
		var/datum/internal_organ/I = pick(internal_organs)
		I.take_damage(brute / 2)
		brute -= brute / 2

	if(limb_status & LIMB_BROKEN && prob(40) && brute)
		if(!(owner.species && (owner.species.species_flags & NO_PAIN)))
			owner.emote("scream") //Getting hit on broken hand hurts

	var/can_cut = (prob(brute*2) || sharp) && !(limb_status & LIMB_ROBOT)
	// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	if((brute_dam + burn_dam + brute + burn) < max_damage || !CONFIG_GET(flag/limbs_can_break))
		if(brute)
			if(can_cut)
				createwound(CUT, brute)
			else
				createwound(BRUISE, brute)
		if(burn)
			createwound(BURN, burn)
	else
		//If we can't inflict the full amount of damage, spread the damage in other ways
		//How much damage can we actually cause?
		var/can_inflict = max_damage * CONFIG_GET(number/organ_health_multiplier) - (brute_dam + burn_dam)
		var/remain_brute = brute
		var/remain_burn = burn
		if(can_inflict)
			if(brute > 0)
				//Inflict all brute damage we can
				if(can_cut)
					createwound(CUT, min(brute, can_inflict))
				else
					createwound(BRUISE, min(brute, can_inflict))
				var/temp = can_inflict
				//How much more damage can we inflict
				can_inflict = max(0, can_inflict - brute)
				//How much brute damage is left to inflict
				remain_brute = max(0, brute - temp)

			if(burn > 0 && can_inflict)
				//Inflict all burn damage we can
				createwound(BURN, min(burn,can_inflict))
				//How much burn damage is left to inflict
				remain_burn = max(0, burn - can_inflict)

		//If there are still hurties to dispense
		if(remain_burn || remain_brute)
			//List organs we can pass it to
			var/list/datum/limb/possible_points = list()
			if(parent)
				possible_points += parent
			if(children)
				possible_points += children
			if(length(forbidden_limbs))
				possible_points -= forbidden_limbs
			if(possible_points.len)
				//And pass the damage around, but not the chance to cut the limb off.
				var/datum/limb/target = pick(possible_points)
				target.take_damage_limb(remain_brute, remain_burn, sharp, edge, blocked, FALSE, forbidden_limbs + src)


	//Sync the organ's damage with its wounds
	update_damages()

	//If limb took enough damage, try to cut or tear it off

	if(body_part == CHEST || body_part == GROIN)
		if(updating_health)
			owner.updatehealth()
		return update_icon()
	var/obj/item/clothing/worn_helmet = owner.head
	if(body_part == HEAD && worn_helmet && (worn_helmet.flags_armor_features & ARMOR_NO_DECAP)) //Early return if the body part is a head but target is wearing decap-protecting headgear.
		if(updating_health)
			owner.updatehealth()
		return update_icon()
	if(CONFIG_GET(flag/limbs_can_break) && brute_dam >= max_damage * CONFIG_GET(number/organ_health_multiplier))
		droplimb() //Reached max damage threshold through brute damage, that limb is going bye bye
		return

	if(updating_health)
		owner.updatehealth()

	var/result = update_icon()
	return result


/datum/limb/proc/heal_limb_damage(brute, burn, internal = FALSE, robo_repair = FALSE, updating_health = FALSE)
	if(limb_status & LIMB_ROBOT && !robo_repair)
		return

	//Heal damage on the individual wounds
	for(var/datum/wound/W in wounds)
		if(brute == 0 && burn == 0)
			break

		// heal brute damage
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute = W.heal_wound_damage(brute)
		else if(W.damage_type == BURN)
			burn = W.heal_wound_damage(burn)
		else if(internal)
			brute = W.heal_wound_damage(brute)

	//Sync the organ's damage with its wounds
	update_damages()
	if(updating_health)
		owner.updatehealth()

	var/result = update_icon()
	return result

/**
 * This proc completely restores a damaged organ to perfect condition.
 */
/datum/limb/proc/rejuvenate(updating_health = FALSE, updating_icon = FALSE)
	damage_state = "00"
	remove_limb_flags(LIMB_BROKEN | LIMB_BLEEDING | LIMB_SPLINTED | LIMB_STABILIZED | LIMB_AMPUTATED | LIMB_DESTROYED | LIMB_NECROTIZED | LIMB_MUTATED | LIMB_REPAIRED)
	brute_dam = 0
	burn_dam = 0
	germ_level = 0
	wounds.Cut()
	number_wounds = 0

	// heal internal organs
	for(var/o in internal_organs)
		var/datum/internal_organ/current_organ = o
		current_organ.rejuvenate()

	// remove embedded objects and drop them on the floor
	for(var/o in implants)
		if(istype(o, /obj/item/implant)) // We don't want to remove REAL implants. Just shrapnel etc.
			continue
		var/obj/implanted_object = o
		implanted_object.forceMove(get_turf(owner))
		implants -= implanted_object

	reset_limb_surgeries()

	if(updating_icon)
		update_icon()

	if(updating_health)
		owner.updatehealth()

/datum/limb/head/rejuvenate(updating_health = FALSE)
	. = ..()
	disfigured = FALSE
	if(owner)
		owner.name = owner.get_visible_name()


/datum/limb/proc/createwound(type = CUT, damage)
	if(!damage)
		return

	//moved this before the open_wound check so that having many small wounds for example doesn't somehow protect you from taking internal damage (because of the return)
	//Possibly trigger an internal wound, too.
	var/local_damage = brute_dam + burn_dam + damage
	if(damage > 15 && type != BURN && local_damage > 30 && prob(damage*0.5) && !(limb_status & LIMB_ROBOT))
		var/datum/wound/internal_bleeding/I = new (min(damage - 15, 15))
		wounds += I
		owner.custom_pain("You feel something rip in your [display_name]!", 1)

	if(limb_status & LIMB_SPLINTED) //If they have it splinted and no splint health, the splint won't hold.
		if(splint_health <= 0)
			remove_limb_flags(LIMB_SPLINTED)
			to_chat(owner, "<span class='userdanger'>The splint on your [display_name] comes apart!</span>")
		else
			splint_health = max(splint_health - damage, 0)

	// first check whether we can widen an existing wound
	var/datum/wound/W
	if(wounds.len > 0 && prob(max(50+(number_wounds-1)*10,90)))
		if((type == CUT || type == BRUISE) && damage >= 5)
			//we need to make sure that the wound we are going to worsen is compatible with the type of damage...
			var/list/compatible_wounds = list()
			for(W in wounds)
				if(W.can_worsen(type, damage))
					compatible_wounds += W

			if(compatible_wounds.len)
				W = pick(compatible_wounds)
				W.open_wound(damage)
				if(prob(25))
					//maybe have a separate message for BRUISE type damage?
					owner.visible_message("<span class='warning'>The wound on [owner.name]'s [display_name] widens with a nasty ripping noise.</span>",
					"<span class='warning'>The wound on your [display_name] widens with a nasty ripping noise.</span>",
					"<span class='warning'>You hear a nasty ripping noise, as if flesh is being torn apart.</span>")
				return

	//Creating wound
	var/wound_type = get_wound_type(type, damage)

	if(wound_type)
		W = new wound_type(damage)

		//Check whether we can add the wound to an existing wound
		for(var/datum/wound/other in wounds)
			if(other.can_merge(W))
				other.merge_wound(W)
				W = null // to signify that the wound was added
				break
		if(W) wounds += W


/****************************************************
			PROCESSING & UPDATING
****************************************************/

//Determines if we even need to process this organ.

/datum/limb/proc/need_process()
	if(limb_status & LIMB_DESTROYED)	//Missing limb is missing
		return 0
	if(limb_status && !(limb_status & LIMB_ROBOT)) // Any status other than destroyed or robotic requires processing
		return 1
	if(brute_dam || burn_dam)
		return 1
	if(last_dam != brute_dam + burn_dam) // Process when we are fully healed up.
		last_dam = brute_dam + burn_dam
		return 1
	else
		last_dam = brute_dam + burn_dam
	if(germ_level)
		return 1
	return 0

/datum/limb/process()

	// Process wounds, doing healing etc. Only do this every few ticks to save processing power
	if(owner.life_tick % wound_update_accuracy == 0)
		update_wounds()

	//Bone fractures
	if(CONFIG_GET(flag/bones_can_break) && brute_dam > min_broken_damage * CONFIG_GET(number/organ_health_multiplier) && !(limb_status & LIMB_ROBOT))
		fracture()

	//Infections
	update_germs()

//Updating germ levels. Handles organ germ levels and necrosis.
/*
The INFECTION_LEVEL values defined in setup.dm control the time it takes to reach the different
infection levels. Since infection growth is exponential, you can adjust the time it takes to get
from one germ_level to another using the rough formula:

desired_germ_level = initial_germ_level*e^(desired_time_in_seconds/1000)

So if I wanted it to take an average of 15 minutes to get from level one (100) to level two
I would set INFECTION_LEVEL_TWO to 100*e^(15*60/1000) = 245. Note that this is the average time,
the actual time is dependent on RNG.

INFECTION_LEVEL_ONE		below this germ level nothing happens, and the infection doesn't grow
INFECTION_LEVEL_TWO		above this germ level the infection will start to spread to internal and adjacent organs
INFECTION_LEVEL_THREE	above this germ level the player will take additional toxin damage per second, and will die in minutes without
						antitox. also, above this germ level you will need to overdose on spaceacillin to reduce the germ_level.

Note that amputating the affected organ does in fact remove the infection from the player's body.
*/
/datum/limb/proc/update_germs()

	if(limb_status & (LIMB_ROBOT|LIMB_DESTROYED) || (owner.species && owner.species.species_flags & IS_PLANT)) //Robotic limbs shouldn't be infected, nor should nonexistant limbs.
		germ_level = 0
		return

	if(owner.bodytemperature >= 170 && !HAS_TRAIT(owner, TRAIT_STASIS))	//cryo stops germs from moving and doing their bad stuffs
		//** Syncing germ levels with external wounds
		handle_germ_sync()

		//** Handle the effects of infections
		handle_germ_effects()

	//** Handle antibiotics and curing infections
	handle_antibiotics()

/datum/limb/proc/handle_germ_sync()
	var/antibiotics = owner.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin)
	for(var/datum/wound/W in wounds)
		//Open wounds can become infected
		if (owner.germ_level > W.germ_level && W.infection_check() && W.damage)
			W.germ_level += min(1,round(W.damage/20)) //The bigger the wound, the more germs will enter

		if (antibiotics < MIN_ANTIBIOTICS)
			//Infected wounds raise the organ's germ level.
			if (W.germ_level)
				germ_level += min(1,round(W.germ_level/35))
		else if (W.germ_level && prob(80)) //Antibiotics wont be very effective it the wound is still open
			germ_level++

/datum/limb/proc/handle_germ_effects()
	var/spaceacillin = owner.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin)
	var/polyhexanide = owner.reagents.get_reagent_amount(/datum/reagent/medicine/polyhexanide)
//LEVEL 0
	if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE && prob(60))	//this could be an else clause, but it looks cleaner this way
		germ_level--	//since germ_level increases at a rate of 1 per second with dirty wounds, prob(60) should give us about 5 minutes before level one.
//LEVEL I
	if(germ_level >= INFECTION_LEVEL_ONE)
		//having an infection raises your body temperature
		var/fever_temperature = (owner.species.heat_level_1 - owner.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.species.body_temperature
		//need to make sure we raise temperature fast enough to get around environmental cooling preventing us from reaching fever_temperature
		owner.adjust_bodytemperature((fever_temperature - T20C)/BODYTEMP_COLD_DIVISOR + 1, 0, fever_temperature - owner.bodytemperature)
		if(prob(round(germ_level/10)))
			if (spaceacillin < MIN_ANTIBIOTICS)
				germ_level++

			if (prob(15))	//adjust this to tweak how fast people take toxin damage from infections
				owner.adjustToxLoss(1)
			if (prob(1) && (germ_level <= INFECTION_LEVEL_TWO))
				to_chat(owner, "<span class='notice'>You have a slight fever...</span>")
//LEVEL II
	if(germ_level >= INFECTION_LEVEL_TWO && spaceacillin < 3)
		//spread the infection to internal organs
		var/datum/internal_organ/target_organ = null	//make internal organs become infected one at a time instead of all at once
		for (var/datum/internal_organ/I in internal_organs)
			if (I.germ_level > 0 && I.germ_level < min(germ_level, INFECTION_LEVEL_TWO))	//once the organ reaches whatever we can give it, or level two, switch to a different one
				if (!target_organ || I.germ_level > target_organ.germ_level)	//choose the organ with the highest germ_level
					target_organ = I

		if(prob(round(germ_level/10)))
			if (spaceacillin < MIN_ANTIBIOTICS)
				germ_level++
		if (prob(1) && (germ_level <= INFECTION_LEVEL_THREE))
			to_chat(owner, "<span class='notice'>Your infected wound itches and badly hurts!</span>")

		if (prob(25))	//adjust this to tweak how fast people take toxin damage from infections
			owner.adjustToxLoss(1)

		if (!target_organ)
			//figure out which organs we can spread germs to and pick one at random
			var/list/candidate_organs = list()
			for (var/datum/internal_organ/I in internal_organs)
				if (I.germ_level < germ_level)
					candidate_organs += I
			if (candidate_organs.len)
				target_organ = pick(candidate_organs)

		if (target_organ)
			target_organ.germ_level++

		//spread the infection to child and parent organs
		if (children)
			for (var/datum/limb/child in children)
				if (child.germ_level < germ_level && !(child.limb_status & LIMB_ROBOT))
					if (child.germ_level < INFECTION_LEVEL_ONE*2 || prob(30))
						child.germ_level++

		if (parent)
			if (parent.germ_level < germ_level && !(parent.limb_status & LIMB_ROBOT))
				if (parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30))
					parent.germ_level++
//LEVEL III
	if(germ_level >= INFECTION_LEVEL_THREE && spaceacillin < 25 && polyhexanide <2)	//overdosing is necessary to stop severe infections, or a doc-only chem
		if (!(limb_status & LIMB_NECROTIZED))
			add_limb_flags(LIMB_NECROTIZED)
			to_chat(owner, "<span class='notice'>You can't feel your [display_name] anymore...</span>")
			owner.update_body(1)

		germ_level++
		if (prob(50))	//adjust this to tweak how fast people take toxin damage from infections
			owner.adjustToxLoss(1)
		if (prob(1))
			to_chat(owner, "<span class='notice'>You have a high fever!</span>")
//Updating wounds. Handles wound natural I had some free spachealing, internal bleedings and infections
/datum/limb/proc/update_wounds()

	if((limb_status & LIMB_ROBOT)) //Robotic limbs don't heal or get worse.
		return

	for(var/datum/wound/W in wounds)
		// wounds can disappear after 10 minutes at the earliest
		if(W.damage <= 0 && W.created + 10 * 10 * 60 <= world.time)
			wounds -= W
			continue
			// let the GC handle the deletion of the wound

		// Internal wounds get worse over time. Low temperatures (cryo) stop them.
		if(W.internal && owner.bodytemperature >= 170 && !HAS_TRAIT(owner, TRAIT_STASIS))
			var/bicardose = owner.reagents.get_reagent_amount(/datum/reagent/medicine/bicaridine)
			var/inaprovaline = owner.reagents.get_reagent_amount(/datum/reagent/medicine/inaprovaline)
			var/old_qc = owner.reagents.get_reagent_amount(/datum/reagent/medicine/quickclotplus)
			if(!(W.can_autoheal() || (bicardose && inaprovaline) || owner.reagents.get_reagent_amount(/datum/reagent/medicine/quickclot)))	//bicaridine and inaprovaline stop internal wounds from growing bigger with time, unless it is so small that it is already healing
				W.open_wound(0.1 * wound_update_accuracy)
			if(bicardose >= 30)	//overdose of bicaridine begins healing IB
				W.damage = max(0, W.damage - 0.2)
			if(old_qc >= 5)	//overdose of QC+ heals IB extremely fast.
				W.damage = max(0, W.damage - 5)

			if(W.damage <= 0)
				wounds -= W // otherwise we are stuck with a 0 damage IB for a while
				continue

			if(!owner.reagents.get_reagent_amount(/datum/reagent/medicine/quickclot)) //Quickclot stops bleeding, magic!
				owner.blood_volume = max(0, owner.blood_volume - wound_update_accuracy * W.damage/40) //line should possibly be moved to handle_blood, so all the bleeding stuff is in one place.
				if(prob(1 * wound_update_accuracy))
					owner.custom_pain("You feel a stabbing pain in your [display_name]!", 1)

		// slow healing
		var/heal_amt = 0

		// if damage >= 50 AFTER treatment then it's probably too severe to heal within the timeframe of a round.
		if (W.can_autoheal() && W.wound_damage() < 50 && prob(35) && owner.health >= 0 && !W.is_treated() && owner.bodytemperature > owner.species.cold_level_1)
			heal_amt += 0.3 //They can't autoheal if in critical
		else if (W.is_treated() && W.wound_damage() < 50 && prob(75))
			heal_amt += 0.5 //Treated wounds heal faster

		if(heal_amt)
			//we only update wounds once in [wound_update_accuracy] ticks so have to emulate realtime
			heal_amt = heal_amt * wound_update_accuracy
			//configurable regen speed woo, no-regen hardcore or instaheal hugbox, choose your destiny
			heal_amt = heal_amt * CONFIG_GET(number/organ_regeneration_multiplier)
			// amount of healing is spread over all the wounds
			heal_amt = heal_amt / (wounds.len + 1)
			// making it look prettier on scanners
			heal_amt = round(heal_amt,0.1)
			W.heal_wound_damage(heal_amt)

		// Salving also helps against infection, but only if it is small enoough
		if((W.germ_level > 0 && W.germ_level < 50) && W.salved && prob(2))
			W.disinfected = 1
			W.germ_level = 0

	// sync the organ's damage with its wounds
	src.update_damages()
	if (update_icon())
		owner.UpdateDamageIcon(1)

//Updates brute_damn and burn_damn from wound damages. Updates BLEEDING status.
/datum/limb/proc/update_damages()
	number_wounds = 0
	brute_dam = 0
	burn_dam = 0
	var/is_bleeding = FALSE
	var/clamped = FALSE

	var/mob/living/carbon/human/H
	if(istype(owner,/mob/living/carbon/human))
		H = owner

	for(var/datum/wound/W in wounds)
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute_dam += W.damage
		else if(W.damage_type == BURN)
			burn_dam += W.damage

		if(!(limb_status & LIMB_ROBOT) && W.bleeding() && (H && !(H.species.species_flags & NO_BLOOD)))
			W.bleed_timer--
			is_bleeding = TRUE

		clamped |= W.clamped

		number_wounds += W.amount

	if(surgery_open_stage && !clamped && (H && !(H.species.species_flags & NO_BLOOD)))	//things tend to bleed if they are CUT OPEN
		is_bleeding = TRUE

	if(is_bleeding)
		add_limb_flags(LIMB_BLEEDING)
	else
		remove_limb_flags(LIMB_BLEEDING)


/datum/limb/proc/set_limb_flags(flags_to_set)
	if(flags_to_set == limb_status)
		return
	. = limb_status
	var/flags_to_change = . & ~flags_to_set //Flags to remove
	if(flags_to_change)
		remove_limb_flags(flags_to_change)
	flags_to_change = flags_to_set & ~(flags_to_set & .) //Flags to add
	if(flags_to_change)
		add_limb_flags(flags_to_change)


/datum/limb/proc/remove_limb_flags(flags_to_remove)
	if(!(limb_status & flags_to_remove))
		return //Nothing old to remove.
	. = limb_status
	limb_status &= ~flags_to_remove
	var/changed_flags = . & flags_to_remove
	if((changed_flags & LIMB_DESTROYED))
		SEND_SIGNAL(src, COMSIG_LIMB_UNDESTROYED)


/datum/limb/proc/add_limb_flags(flags_to_add)
	if(flags_to_add == (limb_status & flags_to_add))
		return //Nothing new to add.
	. = limb_status
	limb_status |= flags_to_add
	var/changed_flags = ~(. & flags_to_add) & flags_to_add
	if((changed_flags & LIMB_DESTROYED))
		SEND_SIGNAL(src, COMSIG_LIMB_DESTROYED)


/datum/limb/foot/remove_limb_flags(flags_to_remove)
	. = ..()
	if(isnull(.))
		return
	var/changed_flags = . & flags_to_remove
	if((changed_flags & LIMB_DESTROYED) && owner.has_legs())
		REMOVE_TRAIT(owner, TRAIT_LEGLESS, TRAIT_LEGLESS)

/datum/limb/foot/add_limb_flags(flags_to_add)
	. = ..()
	if(isnull(.))
		return
	var/changed_flags = ~(. & flags_to_add) & flags_to_add
	if((changed_flags & LIMB_DESTROYED) && !owner.has_legs())
		ADD_TRAIT(owner, TRAIT_LEGLESS, TRAIT_LEGLESS)


// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)
/datum/limb/proc/update_icon()
	var/n_is = damage_state_text()
	if (n_is != damage_state)
		damage_state = n_is
		return 1
	return 0

// new damage icon system
// returns just the brute/burn damage code
/datum/limb/proc/damage_state_text()
	if(limb_status & LIMB_DESTROYED)
		return "00"

	var/tburn = 0
	var/tbrute = 0

	if(burn_dam ==0)
		tburn =0
	else if (burn_dam < (max_damage * 0.25 / 2))
		tburn = 1
	else if (burn_dam < (max_damage * 0.75 / 2))
		tburn = 2
	else
		tburn = 3

	if (brute_dam == 0)
		tbrute = 0
	else if (brute_dam < (max_damage * 0.25 / 2))
		tbrute = 1
	else if (brute_dam < (max_damage * 0.75 / 2))
		tbrute = 2
	else
		tbrute = 3
	return "[tbrute][tburn]"

/****************************************************
			DISMEMBERMENT
****************************************************/

//Recursive setting of all child organs to amputated
/datum/limb/proc/setAmputatedTree()
	for(var/c in children)
		var/datum/limb/O = c
		O.add_limb_flags(LIMB_AMPUTATED)
		O.setAmputatedTree()

/mob/living/carbon/human/proc/remove_random_limb(delete_limb = 0)
	var/list/limbs_to_remove = list()
	for(var/datum/limb/E in limbs)
		if(istype(E, /datum/limb/chest) || istype(E, /datum/limb/groin) || istype(E, /datum/limb/head))
			continue
		limbs_to_remove += E
	if(limbs_to_remove.len)
		var/datum/limb/L = pick(limbs_to_remove)
		var/limb_name = L.display_name
		L.droplimb(0,delete_limb)
		return limb_name
	return null

//Handles dismemberment
/datum/limb/proc/droplimb(amputation, delete_limb = FALSE)
	if(limb_status & LIMB_DESTROYED)
		return FALSE

	if(body_part == CHEST)
		return FALSE

	set_limb_flags(LIMB_DESTROYED)

	for(var/i in implants)
		var/obj/item/embedded_thing = i
		embedded_thing.unembed_ourself(TRUE)

	germ_level = 0
	if(hidden)
		hidden.forceMove(owner.loc)
		hidden = null

	// If any organs are attached to this, destroy them
	for(var/c in children)
		var/datum/limb/appendage = c
		appendage.droplimb(amputation, delete_limb)

	//Replace all wounds on that arm with one wound on parent organ.
	wounds.Cut()
	if(parent && !amputation)
		var/datum/wound/W
		if(max_damage < 50)
			W = new/datum/wound/lost_limb/small(max_damage * 0.25)
		else
			W = new/datum/wound/lost_limb(max_damage * 0.25)

		parent.wounds += W
		parent.update_damages()
	update_damages()

	//we reset the surgery related variables
	reset_limb_surgeries()

	var/obj/organ	//Dropped limb object
	switch(body_part)
		if(HEAD)
			if(owner.species.species_flags & IS_SYNTHETIC) //special head for synth to allow brainmob to talk without an MMI
				organ = new /obj/item/limb/head/synth(owner.loc, owner)
			else
				organ = new /obj/item/limb/head(owner.loc, owner)
			owner.dropItemToGround(owner.glasses, force = TRUE)
			owner.dropItemToGround(owner.head, force = TRUE)
			owner.dropItemToGround(owner.wear_ear, force = TRUE)
			owner.dropItemToGround(owner.wear_mask, force = TRUE)
			owner.update_hair()
		if(ARM_RIGHT)
			if(limb_status & LIMB_ROBOT)
				organ = new /obj/item/robot_parts/r_arm(owner.loc)
			else
				organ = new /obj/item/limb/r_arm(owner.loc, owner)
		if(ARM_LEFT)
			if(limb_status & LIMB_ROBOT)
				organ = new /obj/item/robot_parts/l_arm(owner.loc)
			else
				organ = new /obj/item/limb/l_arm(owner.loc, owner)
		if(LEG_RIGHT)
			if(limb_status & LIMB_ROBOT)
				organ = new /obj/item/robot_parts/r_leg(owner.loc)
			else
				organ = new /obj/item/limb/r_leg(owner.loc, owner)
		if(LEG_LEFT)
			if(limb_status & LIMB_ROBOT)
				organ = new /obj/item/robot_parts/l_leg(owner.loc)
			else
				organ = new /obj/item/limb/l_leg(owner.loc, owner)
		if(HAND_RIGHT)
			if(!(limb_status & LIMB_ROBOT))
				organ= new /obj/item/limb/r_hand(owner.loc, owner)
			owner.dropItemToGround(owner.gloves, force = TRUE)
			owner.dropItemToGround(owner.r_hand, force = TRUE)
		if(HAND_LEFT)
			if(!(limb_status & LIMB_ROBOT))
				organ= new /obj/item/limb/l_hand(owner.loc, owner)
			owner.dropItemToGround(owner.gloves, force = TRUE)
			owner.dropItemToGround(owner.l_hand, force = TRUE)
		if(FOOT_RIGHT)
			if(!(limb_status & LIMB_ROBOT))
				organ= new /obj/item/limb/r_foot/(owner.loc, owner)
			owner.dropItemToGround(owner.shoes, force = TRUE)
		if(FOOT_LEFT)
			if(!(limb_status & LIMB_ROBOT))
				organ = new /obj/item/limb/l_foot(owner.loc, owner)
			owner.dropItemToGround(owner.shoes, force = TRUE)

	if(delete_limb)
		QDEL_NULL(organ)
	else
		owner.visible_message("<span class='warning'>[owner.name]'s [display_name] flies off in an arc!</span>",
		"<span class='highdanger'><b>Your [display_name] goes flying off!</b></span>",
		"<span class='warning'>You hear a terrible sound of ripping tendons and flesh!</span>", 3)

	if(organ)
		//Throw organs around
		var/lol = pick(GLOB.cardinals)
		step(organ, lol)

	owner.update_body(1, 1)

	// OK so maybe your limb just flew off, but if it was attached to a pair of cuffs then hooray! Freedom!
	release_restraints()

	if(vital)
		owner.death()
	return TRUE

/datum/limb/hand/l_hand/droplimb(amputation, delete_limb = FALSE)
	. = ..()
	if(!.)
		return
	owner.update_inv_gloves()


/****************************************************
			HELPERS
****************************************************/

/datum/limb/proc/release_restraints()
	if (owner.handcuffed && (body_part in list(ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT)))
		owner.visible_message(\
			"\The [owner.handcuffed.name] falls off of [owner.name].",\
			"\The [owner.handcuffed.name] falls off you.")

		owner.dropItemToGround(owner.handcuffed)


/datum/limb/proc/bandage()
	var/rval = 0
	remove_limb_flags(LIMB_BLEEDING)
	for(var/datum/wound/W in wounds)
		if(W.internal) continue
		rval |= !W.bandaged
		W.bandaged = 1
	return rval

/datum/limb/proc/is_bandaged()
	if(!(surgery_open_stage == 0))
		return 1
	var/rval = 0
	for(var/datum/wound/W in wounds)
		if(W.internal) continue
		rval |= !W.bandaged
	return rval

/datum/limb/proc/disinfect()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		if(W.internal) continue
		rval |= !W.disinfected
		W.disinfected = 1
		W.germ_level = 0
	return rval

/datum/limb/proc/is_disinfected()
	if(!(surgery_open_stage == 0))
		return 1
	var/rval = 0
	for(var/datum/wound/W in wounds)
		if(W.internal) continue
		rval |= !W.disinfected
	return rval

/datum/limb/proc/clamp_bleeder()
	var/rval = 0
	remove_limb_flags(LIMB_BLEEDING)
	for(var/datum/wound/W in wounds)
		if(W.internal) continue
		rval |= !W.clamped
		W.clamped = 1
	return rval

/datum/limb/proc/salve()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		rval |= !W.salved
		W.salved = 1
	return rval

/datum/limb/proc/is_salved()
	if(!(surgery_open_stage == 0))
		return 1
	var/rval = FALSE
	for(var/datum/wound/W in wounds)
		rval |= !W.salved
	return rval

/datum/limb/proc/fracture()

	if(limb_status & (LIMB_BROKEN|LIMB_DESTROYED|LIMB_ROBOT) )
		return

	owner.visible_message(\
		"<span class='warning'>You hear a loud cracking sound coming from [owner]!</span>",
		"<span class='highdanger'>Something feels like it shattered in your [display_name]!</span>",
		"<span class='warning'>You hear a sickening crack!<span>")
	var/F = pick('sound/effects/bone_break1.ogg','sound/effects/bone_break2.ogg','sound/effects/bone_break3.ogg','sound/effects/bone_break4.ogg','sound/effects/bone_break5.ogg','sound/effects/bone_break6.ogg','sound/effects/bone_break7.ogg')
	playsound(owner,F, 45, 1)
	if(owner.species && !(owner.species.species_flags & NO_PAIN))
		owner.emote("scream")

	add_limb_flags(LIMB_BROKEN)
	remove_limb_flags(LIMB_REPAIRED)
	broken_description = pick("broken","fracture","hairline fracture")

	// Fractures have a chance of getting you out of restraints
	if (prob(25))
		release_restraints()

	/// Emit a signal for autodoc to support the life if available
	SEND_SIGNAL(owner, COMSIG_HUMAN_LIMB_FRACTURED, src)

	return


/datum/limb/proc/robotize()
	rejuvenate()
	add_limb_flags(LIMB_ROBOT)
	for(var/c in children)
		var/datum/limb/child_limb = c
		child_limb.robotize()


/datum/limb/proc/mutate()
	add_limb_flags(LIMB_MUTATED)
	owner.update_body()

/datum/limb/proc/unmutate()
	remove_limb_flags(LIMB_MUTATED)
	owner.update_body()

/datum/limb/proc/get_damage()	//returns total damage
	return brute_dam + burn_dam	//could use health?

/datum/limb/proc/has_infected_wound()
	for(var/datum/wound/W in wounds)
		if(W.germ_level > INFECTION_LEVEL_ONE)
			return 1
	return 0

///Returns the first non-internal wound at non-zero damage if any exist
/datum/limb/proc/has_external_wound()
	for(var/datum/wound/wound_to_check AS in wounds)
		if(wound_to_check.internal)
			continue
		if(!wound_to_check.damage)
			continue
		return wound_to_check

/datum/limb/proc/get_icon(icon/race_icon, icon/deform_icon,gender="")

	if (limb_status & LIMB_ROBOT && !(owner.species && owner.species.species_flags & IS_SYNTHETIC))
		return new /icon('icons/mob/human_races/robotic.dmi', "[icon_name][gender ? "_[gender]" : ""]")

	if (limb_status & LIMB_MUTATED)
		return new /icon(deform_icon, "[icon_name][gender ? "_[gender]" : ""]")

	var/datum/ethnicity/E = GLOB.ethnicities_list[owner.ethnicity]
	var/datum/body_type/B = GLOB.body_types_list[owner.body_type]

	var/e_icon
	var/b_icon

	if (!E)
		e_icon = "western"
	else
		e_icon = E.icon_name

	if (!B)
		b_icon = "mesomorphic"
	else
		b_icon = B.icon_name

	return new /icon(race_icon, "[get_limb_icon_name(owner.species, b_icon, owner.gender, icon_name, e_icon)]")

	//return new /icon(race_icon, "[icon_name][gender ? "_[gender]" : ""]")


/datum/limb/proc/is_usable()
	return !(limb_status & (LIMB_DESTROYED|LIMB_NECROTIZED))

/datum/limb/proc/is_broken()
	return ((limb_status & LIMB_BROKEN) && !(limb_status & LIMB_SPLINTED) && !(limb_status & LIMB_STABILIZED))

/datum/limb/proc/is_malfunctioning()
	return ((limb_status & LIMB_ROBOT) && (get_damage() > min_broken_damage))

//for arms and hands
/datum/limb/proc/process_grasp(obj/item/c_hand, hand_name)
	if (!c_hand)
		return

	if(is_broken())
		if(prob(15))
			owner.dropItemToGround(c_hand)
			var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
			owner.emote("me", 1, "[(owner.species && owner.species.species_flags & NO_PAIN) ? "" : emote_scream ] drops what they were holding in their [hand_name]!")
	if(is_malfunctioning())
		if(prob(5))
			owner.dropItemToGround(c_hand)
			owner.emote("me", 1, "drops what they were holding, their [hand_name] malfunctioning!")
			new /datum/effect_system/spark_spread(owner, owner, 5, 0, TRUE, 1 SECONDS)


/datum/limb/proc/apply_splints(obj/item/stack/medical/splint/S, applied_health, mob/living/user, mob/living/carbon/human/target)

	if(!istype(user))
		return

	if(limb_status & LIMB_DESTROYED)
		to_chat(user, "<span class='warning'>There's nothing there to splint!</span>")
		return FALSE

	if(limb_status & LIMB_SPLINTED && applied_health <= splint_health)
		to_chat(user, "<span class='warning'>This limb is already splinted!</span>")
		return FALSE

	var/delay = SKILL_TASK_AVERAGE - (1 SECONDS + user.skills.getRating("medical") * 5)
	var/text1 = "<span class='warning'>[user] finishes applying [S] to [target]'s [display_name].</span>"
	var/text2 = "<span class='notice'>You finish applying [S] to [target]'s [display_name].</span>"

	if(target == user) //If self splinting, multiply delay by 4
		delay *= 4
		text1 = "<span class='warning'>[user] successfully applies [S] to their [display_name].</span>"
		text2 = "<span class='notice'>You successfully apply [S] to your [display_name].</span>"

	if(!do_mob(user, target, delay, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE

	if(!(limb_status & LIMB_DESTROYED) && !(limb_status & LIMB_SPLINTED))
		user.visible_message(
		"[text1]",
		"[text2]")
		add_limb_flags(LIMB_SPLINTED)
		splint_health = applied_health
		return TRUE


//called when limb is removed or robotized, any ongoing surgery and related vars are reset
/datum/limb/proc/reset_limb_surgeries()
	surgery_open_stage = 0
	bone_repair_stage = 0
	limb_replacement_stage = 0
	necro_surgery_stage = 0
	surgery_organ = null
	cavity = 0


/datum/limb/proc/add_limb_soft_armor(datum/armor/added_armor)
	soft_armor = soft_armor.attachArmor(added_armor)
	var/datum/armor/scaled_armor = added_armor.scaleAllRatings(cover_index * 0.01, 1)
	owner.soft_armor = owner.soft_armor.attachArmor(scaled_armor)


/datum/limb/proc/remove_limb_soft_armor(datum/armor/removed_armor)
	soft_armor = soft_armor.detachArmor(removed_armor)
	var/datum/armor/scaled_armor = removed_armor.scaleAllRatings(cover_index * 0.01, 1)
	owner.soft_armor = owner.soft_armor.detachArmor(scaled_armor)


/datum/limb/proc/add_limb_hard_armor(datum/armor/added_armor)
	hard_armor = hard_armor.attachArmor(added_armor)
	var/datum/armor/scaled_armor = added_armor.scaleAllRatings(cover_index * 0.01, 1)
	owner.hard_armor = owner.hard_armor.attachArmor(scaled_armor)


/datum/limb/proc/remove_limb_hard_armor(datum/armor/removed_armor)
	hard_armor = hard_armor.detachArmor(removed_armor)
	var/datum/armor/scaled_armor = removed_armor.scaleAllRatings(cover_index * 0.01, 1)
	owner.hard_armor = owner.hard_armor.detachArmor(scaled_armor)


/****************************************************
			LIMB TYPES
****************************************************/

/datum/limb/chest
	name = "chest"
	icon_name = "torso"
	display_name = "chest"
	max_damage = 200
	min_broken_damage = 60
	body_part = CHEST
	vital = TRUE
	cover_index = 27
	encased = "ribcage"

/datum/limb/groin
	name = "groin"
	icon_name = "groin"
	display_name = "groin"
	max_damage = 200
	min_broken_damage = 60
	body_part = GROIN
	vital = TRUE
	cover_index = 9

/datum/limb/l_arm
	name = "l_arm"
	display_name = "left arm"
	icon_name = "l_arm"
	max_damage = 125
	min_broken_damage = 50
	body_part = ARM_LEFT
	cover_index = 7

	process()
		..()
		process_grasp(owner.l_hand, "left hand")

/datum/limb/l_leg
	name = "l_leg"
	display_name = "left leg"
	icon_name = "l_leg"
	max_damage = 100
	min_broken_damage = 50
	body_part = LEG_LEFT
	cover_index = 14
	icon_position = LEFT

/datum/limb/r_arm
	name = "r_arm"
	display_name = "right arm"
	icon_name = "r_arm"
	max_damage = 125
	min_broken_damage = 50
	body_part = ARM_RIGHT
	cover_index = 7

	process()
		..()
		process_grasp(owner.r_hand, "right hand")

/datum/limb/r_leg
	name = "r_leg"
	display_name = "right leg"
	icon_name = "r_leg"
	max_damage = 100
	min_broken_damage = 50
	body_part = LEG_RIGHT
	cover_index = 14
	icon_position = RIGHT

/datum/limb/foot/l_foot
	name = "l_foot"
	display_name = "left foot"
	icon_name = "l_foot"
	max_damage = 75
	min_broken_damage = 37
	body_part = FOOT_LEFT
	cover_index = 4
	icon_position = LEFT

/datum/limb/foot/r_foot
	name = "r_foot"
	display_name = "right foot"
	icon_name = "r_foot"
	max_damage = 75
	min_broken_damage = 37
	body_part = FOOT_RIGHT
	cover_index = 4
	icon_position = RIGHT

/datum/limb/hand/r_hand
	name = "r_hand"
	display_name = "right hand"
	icon_name = "r_hand"
	max_damage = 75
	min_broken_damage = 37
	body_part = HAND_RIGHT
	cover_index = 2

	process()
		..()
		process_grasp(owner.r_hand, "right hand")

/datum/limb/hand/l_hand
	name = "l_hand"
	display_name = "left hand"
	icon_name = "l_hand"
	max_damage = 75
	min_broken_damage = 37
	body_part = HAND_LEFT
	cover_index = 2

	process()
		..()
		process_grasp(owner.l_hand, "left hand")

/datum/limb/head
	name = "head"
	icon_name = "head"
	display_name = "head"
	max_damage = 100
	min_broken_damage = 40
	body_part = HEAD
	vital = TRUE
	cover_index = 10
	encased = "skull"
	var/disfigured = 0 //whether the head is disfigured.
	var/face_surgery_stage = 0

/*
/datum/limb/head/get_icon(icon/race_icon, icon/deform_icon)
	if (!owner)
		return ..()
	var/g = "m"
	if(owner.gender == FEMALE)	g = "f"
	if (limb_status & LIMB_MUTATED)
		. = new /icon(deform_icon, "[icon_name]_[g]")
	else
		. = new /icon(race_icon, "[icon_name]_[g]")
*/

/datum/limb/head/take_damage_limb(brute, burn, sharp, edge, blocked = 0, updating_health = FALSE, list/forbidden_limbs = list())
	. = ..()
	if (!disfigured)
		if (brute_dam > 40)
			if (prob(50))
				disfigure("brute")
		if (burn_dam > 40)
			disfigure("burn")

/datum/limb/head/proc/disfigure(type = "brute")
	if (disfigured)
		return
	if(type == "brute")
		owner.visible_message("<span class='warning'> You hear a sickening cracking sound coming from \the [owner]'s face.</span>",	\
		"<span class='danger'>Your face becomes an unrecognizible mangled mess!</span>",	\
		"<span class='warning'> You hear a sickening crack.</span>")
	else
		owner.visible_message("<span class='warning'> [owner]'s face melts away, turning into a mangled mess!</span>",	\
		"<span class='danger'>Your face melts off!</span>",	\
		"<span class='warning'> You hear a sickening sizzle.</span>")
	disfigured = 1
	owner.name = owner.get_visible_name()

/datum/limb/head/reset_limb_surgeries()
	..()
	face_surgery_stage = 0


/datum/limb/head/droplimb(amputation, delete_limb = FALSE)
	. = ..()
	if(!.)
		return
	if(!(owner.species.species_flags & DETACHABLE_HEAD))
		owner.set_undefibbable()
