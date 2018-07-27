/****************************************************
				EXTERNAL ORGANS
****************************************************/
/datum/limb
	var/name = "limb"
	var/icon_name = null
	var/body_part = null
	var/icon_position = 0
	var/damage_state = "00"
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/max_size = 0
	var/last_dam = -1

	var/display_name
	var/list/wounds = list()
	var/number_wounds = 0 // cache the number of wounds, which is NOT wounds.len!

	var/tmp/perma_injury = 0

	var/min_broken_damage = 30

	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() // traces of chemicals in the organ,
									  // links chemical IDs to number of ticks for which they'll stay in the blood

	var/datum/limb/parent
	var/list/datum/limb/children

	// Internal organs of this body part
	var/list/datum/internal_organ/internal_organs

	var/damage_msg = "\red You feel an intense pain"
	var/broken_description

	var/surgery_open_stage = 0
	var/bone_repair_stage = 0
	var/limb_replacement_stage = 0
	var/necro_surgery_stage = 0
	var/cavity = 0

	var/in_surgery_op = FALSE //whether someone is currently doing a surgery step to this limb
	var/surgery_organ //name of the organ currently being surgically worked on (detach/remove/etc)

	var/encased       // Needs to be opened with a saw to access the organs.

	var/obj/item/hidden = null
	var/list/implants = list()

	// how often wounds should be updated, a higher number means less often
	var/wound_update_accuracy = 1
	var/status //limb status flags

	var/mob/living/carbon/human/owner = null
	var/vital //Lose a vital limb, die immediately.
	var/germ_level = 0		// INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE


/datum/limb/New(datum/limb/P, mob/mob_owner)
	if(P)
		parent = P
		if(!parent.children)
			parent.children = list()
		parent.children.Add(src)
	if(mob_owner)
		owner = mob_owner
	return ..()



/*
/datum/limb/proc/get_icon(var/icon/race_icon, var/icon/deform_icon)
	return icon('icons/mob/human.dmi',"blank")
*/

/datum/limb/proc/process()
		return 0

//Germs
/datum/limb/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (!germ_level || antibiotics < MIN_ANTIBIOTICS)
		return

	if (germ_level < 10)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_ONE)
		germ_level -= 4
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 3	//at germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //at germ_level == 1000, this will cure the infection in 5 minutes





//Autopsy stuff

//Handles chem traces
/mob/living/carbon/human/proc/handle_trace_chems()
	//New are added for reagents to random organs.
	for(var/datum/reagent/A in reagents.reagent_list)
		var/datum/limb/O = pick(limbs)
		O.trace_chemicals[A.name] = 100

//Adds autopsy data for used_weapon.
/datum/limb/proc/add_autopsy_data(var/used_weapon, var/damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time



/****************************************************
			   DAMAGE PROCS
****************************************************/

/datum/limb/proc/emp_act(severity)
	if(!(status & LIMB_ROBOT))	//meatbags do not care about EMP
		return
	var/probability = 30
	var/damage = 15
	if(severity == 2)
		probability = 1
		damage = 3
	if(prob(probability))
		droplimb()
	else
		take_damage(damage, 0, 1, 1, used_weapon = "EMP")

/datum/limb/proc/take_damage(brute, burn, sharp, edge, used_weapon = null, list/forbidden_limbs = list(), no_limb_loss)
	if((brute <= 0) && (burn <= 0))
		return 0

	if(status & LIMB_DESTROYED)
		return 0
	if(status & LIMB_ROBOT)

		var/brmod = 0.66
		var/bumod = 0.66

		if(istype(owner,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = owner
			if(H.species && H.species.flags & IS_SYNTHETIC)
				brmod = H.species.brute_mod
				bumod = H.species.burn_mod

		brute *= brmod //~2/3 damage for ROBOLIMBS
		burn *= bumod //~2/3 damage for ROBOLIMBS

	//High brute damage or sharp objects may damage internal organs
	if(internal_organs && ((sharp && brute >= 10) || brute >= 20) && prob(5))
		//Damage an internal organ
		var/datum/internal_organ/I = pick(internal_organs)
		I.take_damage(brute / 2)
		brute -= brute / 2

	if(status & LIMB_BROKEN && prob(40) && brute)
		if(!(owner.species && (owner.species.flags & NO_PAIN)))
			owner.emote("scream") //Getting hit on broken hand hurts
	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)

	var/can_cut = (prob(brute*2) || sharp) && !(status & LIMB_ROBOT)
	// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	if((brute_dam + burn_dam + brute + burn) < max_damage || !config.limbs_can_break)
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
		var/can_inflict = max_damage * config.organ_health_multiplier - (brute_dam + burn_dam)
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
			if(forbidden_limbs.len)
				possible_points -= forbidden_limbs
			if(possible_points.len)
				//And pass the damage around, but not the chance to cut the limb off.
				var/datum/limb/target = pick(possible_points)
				target.take_damage(remain_brute, remain_burn, sharp, edge, used_weapon, forbidden_limbs + src, TRUE)


	//Sync the organ's damage with its wounds
	src.update_damages()

	//If limb took enough damage, try to cut or tear it off
	if(body_part != UPPER_TORSO && body_part != LOWER_TORSO && !no_limb_loss)
		if(config.limbs_can_break && brute_dam >= max_damage * config.organ_health_multiplier)
			var/cut_prob = brute/max_damage * 10
			if(prob(cut_prob))
				droplimb()
				return

	owner.updatehealth()

	var/result = update_icon()
	return result

/datum/limb/proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	if(status & LIMB_ROBOT && !robo_repair)
		return

	//Heal damage on the individual wounds
	for(var/datum/wound/W in wounds)
		if(brute == 0 && burn == 0)
			break

		// heal brute damage
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute = W.heal_damage(brute)
		else if(W.damage_type == BURN)
			burn = W.heal_damage(burn)

	if(internal)
		status &= ~LIMB_BROKEN
		status |= LIMB_REPAIRED
		perma_injury = 0

	//Sync the organ's damage with its wounds
	src.update_damages()
	owner.updatehealth()

	var/result = update_icon()
	return result

/*
This function completely restores a damaged organ to perfect condition.
*/
/datum/limb/proc/rejuvenate()
	damage_state = "00"
	if(status & LIMB_ROBOT)	//Robotic organs stay robotic.  Fix because right click rejuvinate makes IPC's organs organic.
		status = LIMB_ROBOT
	else
		status = 0
	perma_injury = 0
	brute_dam = 0
	burn_dam = 0
	germ_level = 0
	wounds.Cut()
	number_wounds = 0

	// heal internal organs
	for(var/datum/internal_organ/current_organ in internal_organs)
		current_organ.rejuvenate()

	// remove embedded objects and drop them on the floor
	for(var/obj/implanted_object in implants)
		if(!istype(implanted_object,/obj/item/implant))	// We don't want to remove REAL implants. Just shrapnel etc.
			implanted_object.loc = owner.loc
			implants -= implanted_object

	owner.updatehealth()


/datum/limb/proc/createwound(var/type = CUT, var/damage)
	if(!damage) return

	//moved this before the open_wound check so that having many small wounds for example doesn't somehow protect you from taking internal damage (because of the return)
	//Possibly trigger an internal wound, too.
	var/local_damage = brute_dam + burn_dam + damage
	if(damage > 15 && type != BURN && local_damage > 30 && prob(damage*0.5) && !(status & LIMB_ROBOT))
		var/datum/wound/internal_bleeding/I = new (min(damage - 15, 15))
		wounds += I
		owner.custom_pain("You feel something rip in your [display_name]!", 1)

	if(status & LIMB_SPLINTED && damage > 5 && prob(50 + damage * 2.5)) //If they have it splinted, the splint won't hold.
		status &= ~LIMB_SPLINTED
		owner << "<span class='danger'>The splint on your [display_name] comes apart!</span>"

	// first check whether we can widen an existing wound
	var/datum/wound/W
	if(wounds.len > 0 && prob(max(50+(number_wounds-1)*10,90)))
		if((type == CUT || type == BRUISE) && damage >= 5)
			//we need to make sure that the wound we are going to worsen is compatible with the type of damage...
			var/compatible_wounds[] = new
			for(W in wounds)
				if(W.can_worsen(type, damage)) compatible_wounds += W

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
	if(status & LIMB_DESTROYED)	//Missing limb is missing
		return 0
	if(status && !(status & LIMB_ROBOT)) // Any status other than destroyed or robotic requires processing
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

	//Chem traces slowly vanish
	if(owner.life_tick % 10 == 0)
		for(var/chemID in trace_chemicals)
			trace_chemicals[chemID] = trace_chemicals[chemID] - 1
			if(trace_chemicals[chemID] <= 0)
				trace_chemicals.Remove(chemID)

	//Bone fracurtes
	if(config.bones_can_break && brute_dam > min_broken_damage * config.organ_health_multiplier && !(status & LIMB_ROBOT))
		fracture()
	if(!(status & LIMB_BROKEN))
		perma_injury = 0

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

	if(status & (LIMB_ROBOT|LIMB_DESTROYED) || (owner.species && owner.species.flags & IS_PLANT)) //Robotic limbs shouldn't be infected, nor should nonexistant limbs.
		germ_level = 0
		return

	if(owner.bodytemperature >= 170 && !owner.in_stasis)	//cryo stops germs from moving and doing their bad stuffs
		//** Syncing germ levels with external wounds
		handle_germ_sync()

		//** Handle the effects of infections
		handle_germ_effects()

	//** Handle antibiotics and curing infections
	handle_antibiotics()

/datum/limb/proc/handle_germ_sync()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")
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
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")
//LEVEL 0
	if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE && prob(60))	//this could be an else clause, but it looks cleaner this way
		germ_level--	//since germ_level increases at a rate of 1 per second with dirty wounds, prob(60) should give us about 5 minutes before level one.
//LEVEL I
	if(germ_level >= INFECTION_LEVEL_ONE)
		//having an infection raises your body temperature
		var/fever_temperature = (owner.species.heat_level_1 - owner.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.species.body_temperature
		//need to make sure we raise temperature fast enough to get around environmental cooling preventing us from reaching fever_temperature
		owner.bodytemperature += between(0, (fever_temperature - T20C)/BODYTEMP_COLD_DIVISOR + 1, fever_temperature - owner.bodytemperature)

		if(prob(round(germ_level/10)))
			if (antibiotics < MIN_ANTIBIOTICS)
				germ_level++

			if (prob(15))	//adjust this to tweak how fast people take toxin damage from infections
				owner.adjustToxLoss(1)
			if (prob(1) && (germ_level <= INFECTION_LEVEL_TWO))
				owner << "<span class='notice'>You have a slight fever...</span>"
//LEVEL II
	if(germ_level >= INFECTION_LEVEL_TWO && antibiotics < 3)
		//spread the infection to internal organs
		var/datum/internal_organ/target_organ = null	//make internal organs become infected one at a time instead of all at once
		for (var/datum/internal_organ/I in internal_organs)
			if (I.germ_level > 0 && I.germ_level < min(germ_level, INFECTION_LEVEL_TWO))	//once the organ reaches whatever we can give it, or level two, switch to a different one
				if (!target_organ || I.germ_level > target_organ.germ_level)	//choose the organ with the highest germ_level
					target_organ = I

		if(prob(round(germ_level/10)))
			if (antibiotics < MIN_ANTIBIOTICS)
				germ_level++
		if (prob(1) && (germ_level <= INFECTION_LEVEL_THREE))
			owner << "<span class='notice'>Your infected wound itches and badly hurts!</span>"

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
				if (child.germ_level < germ_level && !(child.status & LIMB_ROBOT))
					if (child.germ_level < INFECTION_LEVEL_ONE*2 || prob(30))
						child.germ_level++

		if (parent)
			if (parent.germ_level < germ_level && !(parent.status & LIMB_ROBOT))
				if (parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30))
					parent.germ_level++
//LEVEL III
	if(germ_level >= INFECTION_LEVEL_THREE && antibiotics < 25)	//overdosing is necessary to stop severe infections
		if (!(status & LIMB_NECROTIZED))
			status |= LIMB_NECROTIZED
			owner << "<span class='notice'>You can't feel your [display_name] anymore...</span>"
			owner.update_body(1)

		germ_level++
		if (prob(50))	//adjust this to tweak how fast people take toxin damage from infections
			owner.adjustToxLoss(1)
		if (prob(1))
			owner << "<span class='notice'>You have a high fever!</span>"
//Updating wounds. Handles wound natural I had some free spachealing, internal bleedings and infections
/datum/limb/proc/update_wounds()

	if((status & LIMB_ROBOT)) //Robotic limbs don't heal or get worse.
		return

	for(var/datum/wound/W in wounds)
		// wounds can disappear after 10 minutes at the earliest
		if(W.damage <= 0 && W.created + 10 * 10 * 60 <= world.time)
			wounds -= W
			continue
			// let the GC handle the deletion of the wound

		// Internal wounds get worse over time. Low temperatures (cryo) stop them.
		if(W.internal && owner.bodytemperature >= 170 && !(owner.in_stasis == STASIS_IN_BAG))
			var/bicardose = owner.reagents.get_reagent_amount("bicaridine")
			var/inaprovaline = owner.reagents.get_reagent_amount("inaprovaline")
			if(!(W.can_autoheal() || (bicardose && inaprovaline) || owner.reagents.get_reagent_amount("quickclot")))	//bicaridine and inaprovaline stop internal wounds from growing bigger with time, unless it is so small that it is already healing
				W.open_wound(0.1 * wound_update_accuracy)
			if(bicardose >= 30)	//overdose of bicaridine begins healing IB
				W.damage = max(0, W.damage - 0.2)

			if(!owner.reagents.get_reagent_amount("quickclot")) //Quickclot stops bleeding, magic!
				owner.blood_volume = max(0, owner.blood_volume - wound_update_accuracy * W.damage/40) //line should possibly be moved to handle_blood, so all the bleeding stuff is in one place.
				if(prob(1 * wound_update_accuracy))
					owner.custom_pain("You feel a stabbing pain in your [display_name]!", 1)

		if(owner.reagents.get_reagent_amount("thwei") >= 0.05) //Note: This used to turn internal wounds into external wounds, for QC's effect
			W.internal = 0

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
			heal_amt = heal_amt * config.organ_regeneration_multiplier
			// amount of healing is spread over all the wounds
			heal_amt = heal_amt / (wounds.len + 1)
			// making it look prettier on scanners
			heal_amt = round(heal_amt,0.1)
			W.heal_damage(heal_amt)

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
	status &= ~LIMB_BLEEDING
	var/clamped = 0

	var/mob/living/carbon/human/H
	if(istype(owner,/mob/living/carbon/human))
		H = owner

	for(var/datum/wound/W in wounds)
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute_dam += W.damage
		else if(W.damage_type == BURN)
			burn_dam += W.damage

		if(!(status & LIMB_ROBOT) && W.bleeding() && (H && !(H.species.flags & NO_BLOOD)))
			W.bleed_timer--
			status |= LIMB_BLEEDING

		clamped |= W.clamped

		number_wounds += W.amount

	if (surgery_open_stage && !clamped && (H && !(H.species.flags & NO_BLOOD)))	//things tend to bleed if they are CUT OPEN
		status |= LIMB_BLEEDING



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
	if(status & LIMB_DESTROYED)
		return "--"

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
	for(var/datum/limb/O in children)
		O.status |= LIMB_AMPUTATED
		O.setAmputatedTree()

/mob/living/carbon/human/proc/remove_random_limb(var/delete_limb = 0)
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
/datum/limb/proc/droplimb(amputation, var/delete_limb = 0)
	if(status & LIMB_DESTROYED)
		return
	else
		if(body_part == UPPER_TORSO)
			return

		if(status & LIMB_ROBOT)
			status = LIMB_DESTROYED|LIMB_ROBOT
		else
			status = LIMB_DESTROYED
		for(var/i in implants)
			implants -= i
			cdel(i)

		germ_level = 0
		if(hidden)
			hidden.forceMove(owner.loc)
			hidden = null

		// If any organs are attached to this, destroy them
		for(var/datum/limb/O in children) O.droplimb(amputation, delete_limb)

		//Replace all wounds on that arm with one wound on parent organ.
		wounds.Cut()
		if(parent && !amputation)
			var/datum/wound/W
			if(max_damage < 50) W = new/datum/wound/lost_limb/small(max_damage)
			else 				W = new/datum/wound/lost_limb(max_damage)

			parent.wounds += W
			parent.update_damages()
		update_damages()

		//we reset the surgery related variables
		reset_limb_surgeries()

		var/obj/organ	//Dropped limb object
		switch(body_part)
			if(HEAD)
				if(owner.species.flags & IS_SYNTHETIC) //special head for synth to allow brainmob to talk without an MMI
					organ= new /obj/item/limb/head/synth(owner.loc, owner)
				else
					organ= new /obj/item/limb/head(owner.loc, owner)
				owner.drop_inv_item_on_ground(owner.glasses, null, TRUE)
				owner.drop_inv_item_on_ground(owner.head, null, TRUE)
				owner.drop_inv_item_on_ground(owner.wear_ear, null, TRUE)
				owner.drop_inv_item_on_ground(owner.wear_mask, null, TRUE)
			if(ARM_RIGHT)
				if(status & LIMB_ROBOT) 	organ = new /obj/item/robot_parts/r_arm(owner.loc)
				else 						organ = new /obj/item/limb/r_arm(owner.loc, owner)
			if(ARM_LEFT)
				if(status & LIMB_ROBOT) 	organ = new /obj/item/robot_parts/l_arm(owner.loc)
				else 						organ = new /obj/item/limb/l_arm(owner.loc, owner)
			if(LEG_RIGHT)
				if(status & LIMB_ROBOT) 	organ = new /obj/item/robot_parts/r_leg(owner.loc)
				else 						organ = new /obj/item/limb/r_leg(owner.loc, owner)
			if(LEG_LEFT)
				if(status & LIMB_ROBOT) 	organ = new /obj/item/robot_parts/l_leg(owner.loc)
				else 						organ = new /obj/item/limb/l_leg(owner.loc, owner)
			if(HAND_RIGHT)
				if(!(status & LIMB_ROBOT)) organ= new /obj/item/limb/r_hand(owner.loc, owner)
				owner.drop_inv_item_on_ground(owner.gloves, null, TRUE)
				owner.drop_inv_item_on_ground(owner.r_hand, null, TRUE)
			if(HAND_LEFT)
				if(!(status & LIMB_ROBOT)) organ= new /obj/item/limb/l_hand(owner.loc, owner)
				owner.drop_inv_item_on_ground(owner.gloves, null, TRUE)
				owner.drop_inv_item_on_ground(owner.l_hand, null, TRUE)
			if(FOOT_RIGHT)
				if(!(status & LIMB_ROBOT)) organ= new /obj/item/limb/r_foot/(owner.loc, owner)
				owner.drop_inv_item_on_ground(owner.shoes, null, TRUE)
			if(FOOT_LEFT)
				if(!(status & LIMB_ROBOT)) organ = new /obj/item/limb/l_foot(owner.loc, owner)
				owner.drop_inv_item_on_ground(owner.shoes, null, TRUE)

		if(delete_limb)
			cdel(organ)
		else
			owner.visible_message("<span class='warning'>[owner.name]'s [display_name] flies off in an arc!</span>",
			"<span class='highdanger'><b>Your [display_name] goes flying off!</b></span>",
			"<span class='warning'>You hear a terrible sound of ripping tendons and flesh!</span>", 3)

			if(organ)
				//Throw organs around
				var/lol = pick(cardinal)
				step(organ,lol)

		owner.update_body(1, 1)

		// OK so maybe your limb just flew off, but if it was attached to a pair of cuffs then hooray! Freedom!
		release_restraints()

		if(vital) owner.death()

/****************************************************
			   HELPERS
****************************************************/

/datum/limb/proc/release_restraints()
	if (owner.handcuffed && body_part in list(ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT))
		owner.visible_message(\
			"\The [owner.handcuffed.name] falls off of [owner.name].",\
			"\The [owner.handcuffed.name] falls off you.")

		owner.drop_inv_item_on_ground(owner.handcuffed)

	if (owner.legcuffed && body_part in list(FOOT_LEFT, FOOT_RIGHT, LEG_LEFT, LEG_RIGHT))
		owner.visible_message(\
			"\The [owner.legcuffed.name] falls off of [owner.name].",\
			"\The [owner.legcuffed.name] falls off you.")

		owner.drop_inv_item_on_ground(owner.legcuffed)

/datum/limb/proc/bandage()
	var/rval = 0
	status &= ~LIMB_BLEEDING
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

/datum/limb/proc/clamp()
	var/rval = 0
	src.status &= ~LIMB_BLEEDING
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
	var/rval = 1
	for(var/datum/wound/W in wounds)
		rval |= !W.salved
	return rval

/datum/limb/proc/fracture()

	if(status & (LIMB_BROKEN|LIMB_DESTROYED|LIMB_ROBOT) )
		return

	owner.visible_message(\
		"<span class='warning'>You hear a loud cracking sound coming from [owner]!</span>",
		"<span class='highdanger'>Something feels like it shattered in your [display_name]!</span>",
		"<span class='warning'>You hear a sickening crack!<span>")
	var/F = pick('sound/effects/bone_break1.ogg','sound/effects/bone_break2.ogg','sound/effects/bone_break3.ogg','sound/effects/bone_break4.ogg','sound/effects/bone_break5.ogg','sound/effects/bone_break6.ogg','sound/effects/bone_break7.ogg')
	playsound(owner,F, 45, 1)
	if(owner.species && !(owner.species.flags & NO_PAIN))
		owner.emote("scream")

	status |= LIMB_BROKEN
	status &= ~LIMB_REPAIRED
	broken_description = pick("broken","fracture","hairline fracture")
	perma_injury = brute_dam

	// Fractures have a chance of getting you out of restraints
	if (prob(25))
		release_restraints()

	// This is mostly for the ninja suit to stop ninja being so crippled by breaks.
	// TODO: consider moving this to a suit proc or process() or something during
	// hardsuit rewrite.
	if(!(status & LIMB_SPLINTED) && istype(owner,/mob/living/carbon/human))

		var/mob/living/carbon/human/H = owner

		if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))

			var/obj/item/clothing/suit/space/suit = H.wear_suit

			if(isnull(suit.supporting_limbs))
				return

			owner << "You feel [suit] constrict about your [display_name], supporting it."
			status |= LIMB_SPLINTED
			suit.supporting_limbs |= src
	return

/datum/limb/proc/robotize()
	status &= ~LIMB_BROKEN
	status &= ~LIMB_BLEEDING
	status &= ~LIMB_SPLINTED
	status &= ~LIMB_AMPUTATED
	status &= ~LIMB_DESTROYED
	status &= ~LIMB_NECROTIZED
	status &= ~LIMB_MUTATED
	status &= ~LIMB_REPAIRED
	status |= LIMB_ROBOT

	reset_limb_surgeries()

	germ_level = 0
	perma_injury = 0
	for (var/datum/limb/T in children)
		if(T)
			T.robotize()

/datum/limb/proc/mutate()
	src.status |= LIMB_MUTATED
	owner.update_body()

/datum/limb/proc/unmutate()
	src.status &= ~LIMB_MUTATED
	owner.update_body()

/datum/limb/proc/get_damage()	//returns total damage
	return max(brute_dam + burn_dam - perma_injury, perma_injury)	//could use health?

/datum/limb/proc/has_infected_wound()
	for(var/datum/wound/W in wounds)
		if(W.germ_level > INFECTION_LEVEL_ONE)
			return 1
	return 0

/datum/limb/proc/get_icon(var/icon/race_icon, var/icon/deform_icon,gender="")

	if (status & LIMB_ROBOT && !(owner.species && owner.species.flags & IS_SYNTHETIC))
		return new /icon('icons/mob/human_races/robotic.dmi', "[icon_name][gender ? "_[gender]" : ""]")

	if (status & LIMB_MUTATED)
		return new /icon(deform_icon, "[icon_name][gender ? "_[gender]" : ""]")

	var/datum/ethnicity/E = ethnicities_list[owner.ethnicity]
	var/datum/body_type/B = body_types_list[owner.body_type]

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
	return !(status & (LIMB_DESTROYED|LIMB_MUTATED|LIMB_NECROTIZED))

/datum/limb/proc/is_broken()
	return ((status & LIMB_BROKEN) && !(status & LIMB_SPLINTED))

/datum/limb/proc/is_malfunctioning()
	return ((status & LIMB_ROBOT) && prob(brute_dam + burn_dam))

//for arms and hands
/datum/limb/proc/process_grasp(var/obj/item/c_hand, var/hand_name)
	if (!c_hand)
		return

	if(is_broken())
		if(prob(15))
			owner.drop_inv_item_on_ground(c_hand)
			var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
			owner.emote("me", 1, "[(owner.species && owner.species.flags & NO_PAIN) ? "" : emote_scream ] drops what they were holding in their [hand_name]!")
	if(is_malfunctioning())
		if(prob(10))
			owner.drop_inv_item_on_ground(c_hand)
			owner.emote("me", 1, "drops what they were holding, their [hand_name] malfunctioning!")
			var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
			spark_system.set_up(5, 0, owner)
			spark_system.attach(owner)
			spark_system.start()
			spawn(10)
				cdel(spark_system)
				spark_system = null

/datum/limb/proc/embed(var/obj/item/W, var/silent = 0)
	if(!W || W.disposed || (W.flags_item & (NODROP|DELONDROP)))
		return
	if(!silent)
		owner.visible_message("<span class='danger'>\The [W] sticks in the wound!</span>")
	implants += W
	owner.embedded_flag = 1
	owner.verbs += /mob/proc/yank_out_object
	W.add_mob_blood(owner)
	if(ismob(W.loc))
		var/mob/living/H = W.loc
		H.drop_held_item()
	if(W)
		W.forceMove(owner)

/datum/limb/proc/apply_splints(obj/item/stack/medical/splint/S, mob/living/user, mob/living/carbon/human/target)
	if(do_mob(user, target, 50, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		if(!(status & LIMB_DESTROYED) && !(status & LIMB_SPLINTED))
			if(target != user)
				user.visible_message(
				"<span class='warning'>[user] finishes applying [S] to [target]'s [display_name].</span>",
				"<span class='notice'>You finish applying [S] to [target]'s [display_name].</span>")
				status |= LIMB_SPLINTED
				. = 1
			else
				if(prob(25))
					user.visible_message(
					"<span class='warning'>[user] successfully applies [S] to their [display_name].</span>",
					"<span class='notice'>You successfully apply [S] to your [display_name].</span>")
					status |= LIMB_SPLINTED
					. = 1
				else
					user.visible_message(
					"<span class='warning'>[user] fumbles with [S].</span>",
					"<span class='warning'>You fumble with [S].</span>")



//called when limb is removed or robotized, any ongoing surgery and related vars are reset
/datum/limb/proc/reset_limb_surgeries()
	surgery_open_stage = 0
	bone_repair_stage = 0
	limb_replacement_stage = 0
	necro_surgery_stage = 0
	surgery_organ = null
	cavity = 0




/****************************************************
			   LIMB TYPES
****************************************************/

/datum/limb/chest
	name = "chest"
	icon_name = "torso"
	display_name = "chest"
	max_damage = 200
	min_broken_damage = 40
	body_part = UPPER_TORSO
	vital = 1
	encased = "ribcage"

/datum/limb/groin
	name = "groin"
	icon_name = "groin"
	display_name = "groin"
	max_damage = 200
	min_broken_damage = 40
	body_part = LOWER_TORSO
	vital = 1

/datum/limb/l_arm
	name = "l_arm"
	display_name = "left arm"
	icon_name = "l_arm"
	max_damage = 35
	min_broken_damage = 30
	body_part = ARM_LEFT

	process()
		..()
		process_grasp(owner.l_hand, "left hand")

/datum/limb/l_leg
	name = "l_leg"
	display_name = "left leg"
	icon_name = "l_leg"
	max_damage = 35
	min_broken_damage = 30
	body_part = LEG_LEFT
	icon_position = LEFT

/datum/limb/r_arm
	name = "r_arm"
	display_name = "right arm"
	icon_name = "r_arm"
	max_damage = 35
	min_broken_damage = 30
	body_part = ARM_RIGHT

	process()
		..()
		process_grasp(owner.r_hand, "right hand")

/datum/limb/r_leg
	name = "r_leg"
	display_name = "right leg"
	icon_name = "r_leg"
	max_damage = 35
	min_broken_damage = 30
	body_part = LEG_RIGHT
	icon_position = RIGHT

/datum/limb/l_foot
	name = "l_foot"
	display_name = "left foot"
	icon_name = "l_foot"
	max_damage = 30
	min_broken_damage = 25
	body_part = FOOT_LEFT
	icon_position = LEFT

/datum/limb/r_foot
	name = "r_foot"
	display_name = "right foot"
	icon_name = "r_foot"
	max_damage = 30
	min_broken_damage = 25
	body_part = FOOT_RIGHT
	icon_position = RIGHT

/datum/limb/r_hand
	name = "r_hand"
	display_name = "right hand"
	icon_name = "r_hand"
	max_damage = 30
	min_broken_damage = 25
	body_part = HAND_RIGHT

	process()
		..()
		process_grasp(owner.r_hand, "right hand")

/datum/limb/l_hand
	name = "l_hand"
	display_name = "left hand"
	icon_name = "l_hand"
	max_damage = 30
	min_broken_damage = 25
	body_part = HAND_LEFT

	process()
		..()
		process_grasp(owner.l_hand, "left hand")

/datum/limb/head
	name = "head"
	icon_name = "head"
	display_name = "head"
	max_damage = 60
	min_broken_damage = 40
	body_part = HEAD
	vital = 1
	encased = "skull"
	var/disfigured = 0 //whether the head is disfigured.
	var/face_surgery_stage = 0

/*
/datum/limb/head/get_icon(var/icon/race_icon, var/icon/deform_icon)
	if (!owner)
	 return ..()
	var/g = "m"
	if(owner.gender == FEMALE)	g = "f"
	if (status & LIMB_MUTATED)
		. = new /icon(deform_icon, "[icon_name]_[g]")
	else
		. = new /icon(race_icon, "[icon_name]_[g]")
*/

/datum/limb/head/take_damage(brute, burn, sharp, edge, used_weapon = null, list/forbidden_limbs = list())
	. = ..(brute, burn, sharp, edge, used_weapon, forbidden_limbs)
	if (!disfigured)
		if (brute_dam > 40)
			if (prob(50))
				disfigure("brute")
		if (burn_dam > 40)
			disfigure("burn")

/datum/limb/head/proc/disfigure(var/type = "brute")
	if (disfigured)
		return
	if(type == "brute")
		owner.visible_message("\red You hear a sickening cracking sound coming from \the [owner]'s face.",	\
		"\red <b>Your face becomes unrecognizible mangled mess!</b>",	\
		"\red You hear a sickening crack.")
	else
		owner.visible_message("\red [owner]'s face melts away, turning into mangled mess!",	\
		"\red <b>Your face melts off!</b>",	\
		"\red You hear a sickening sizzle.")
	disfigured = 1
	owner.name = owner.get_visible_name()

/datum/limb/head/reset_limb_surgeries()
	..()
	face_surgery_stage = 0
