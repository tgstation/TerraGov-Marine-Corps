#define LIMB_MAX_DAMAGE_SEVER_RATIO 0.8

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
	///Max damage the limb can take. Extremities sever when they have at least LIMB_MAX_DAMAGE_SEVER_RATIO as a fraction of this in brute damage.
	var/max_damage = 0
	///Amount of damage this limb regenerates per tick while treated before multi-limb regen penalty
	var/base_regen = 2
	var/max_size = 0
	var/last_dam = -1
	var/supported = FALSE
	///How many instances of damage the limb can take before its splints fall off
	var/splint_health = 0

	var/datum/armor/soft_armor
	var/datum/armor/hard_armor

	var/display_name
	var/list/wounds = list()
	var/number_wounds = 0 // cache the number of wounds, which is NOT length(wounds)!

	var/min_broken_damage = 30

	var/datum/limb/parent
	var/list/datum/limb/children

	///List of Internal organs of this body part
	var/list/datum/internal_organ/internal_organs

	/// Message that displays when you feel pain from this limb
	var/damage_msg = span_warning("You feel an intense pain")
	var/broken_description

	var/surgery_open_stage = 0
	var/bone_repair_stage = 0
	var/limb_replacement_stage = 0
	var/necro_surgery_stage = 0
	var/cavity = 0

	///Whether someone is currently doing surgery on this limb
	var/in_surgery_op = FALSE

	var/encased       // Needs to be opened with a saw to access the organs.

	var/obj/item/hidden = null
	///[/obj/item/implant] Implants contained within this specific limb
	var/list/implants = list()

	///how often wounds should be updated, a higher number means less often
	var/wound_update_accuracy = 1
	var/limb_status = NONE //limb status flags
	var/limb_wound_status = NONE //for wound treatment flags

	///Human owner mob of this limb
	var/mob/living/carbon/human/owner = null
	///Whether this limb is vital, if true you die on losing it (todo make a flag)
	var/vital = FALSE
	///INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE
	var/germ_level = 0
	///Keeps track of the last time the limb bothered its owner about infection to prevent spam.
	COOLDOWN_DECLARE(next_infection_message)
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
		RegisterSignal(owner, COMSIG_QDELETING, PROC_REF(clean_owner))
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

///Signal handler to clean owner and prevent hardel
/datum/limb/proc/clean_owner()
	SIGNAL_HANDLER
	owner = null

//Germs
/datum/limb/proc/handle_antibiotics()
	var/spaceacillin = owner.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin)
	var/polyhexanide = owner.reagents.get_reagent_amount(/datum/reagent/medicine/polyhexanide)

	var/spaceacillin_curve = list(0,4,3,2)
	var/polyhexanide_curve = list(0,1,1,10)

	if (!germ_level || (spaceacillin + polyhexanide) < MIN_ANTIBIOTICS)
		return

	var/infection_level = 1
	switch(germ_level)
		if(-INFINITY to 10)
			germ_level = 0
			return // cure instantly
		if(11 to INFECTION_LEVEL_ONE)
			infection_level = 2
		if(INFECTION_LEVEL_ONE - 1 to INFECTION_LEVEL_TWO)
			infection_level = 3
		if(INFECTION_LEVEL_TWO - 1 to INFINITY)
			infection_level = 4

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
	if(owner.status_flags & GODMODE)
		return FALSE
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

	if(limb_status & LIMB_ROBOT && !(owner.species.species_flags & ROBOTIC_LIMBS))
		brute *= 0.50 // half damage for ROBOLIMBS if you weren't born with them
		burn *= 0.50

	if(limb_status & LIMB_BIOTIC)
		brute *= 1.3 // 130% damage for biotic limbs
		burn *= 1.3

	//High brute damage or sharp objects may damage internal organs
	if(internal_organs && ((sharp && brute >= 10) || brute >= 20) && prob(5))
		//Damage an internal organ
		var/datum/internal_organ/I = pick(internal_organs)
		I.take_damage(brute / 2)
		brute -= brute / 2

	if(limb_status & LIMB_BROKEN && prob(40) && brute)
		if(!(owner.species && (owner.species.species_flags & NO_PAIN)))
			owner.emote("scream") //Getting hit on broken hand hurts

	//Possibly trigger an internal wound, too.
	var/local_damage = brute_dam + burn_dam + brute
	if(brute > 15 && local_damage > 30 && prob(brute*0.5) && !(limb_status & LIMB_ROBOT) && !(SSticker.mode?.flags_round_type & MODE_NO_PERMANENT_WOUNDS))
		new /datum/wound/internal_bleeding(min(brute - 15, 15), src)
		owner.custom_pain("You feel something rip in your [display_name]!", 1)

	//If they have it splinted and no splint health, the splint won't hold.
	if(limb_status & LIMB_SPLINTED)
		if(splint_health <= 0)
			remove_limb_flags(LIMB_SPLINTED)
			to_chat(owner, span_userdanger("The splint on your [display_name] comes apart!"))
			playsound(owner, 'sound/items/splint_break.ogg', 100, sound_range = 1, falloff = 5)
		else
			splint_health = max(splint_health - (brute + burn), 0)


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
		var/can_inflict = max_damage - (brute_dam + burn_dam)
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
			if(length(possible_points))
				//And pass the damage around, but not the chance to cut the limb off.
				var/datum/limb/target = pick(possible_points)
				target.take_damage_limb(remain_brute, remain_burn, sharp, edge, blocked, FALSE, forbidden_limbs + src)


	//Sync the organ's damage with its wounds
	update_bleeding()

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
	if(CONFIG_GET(flag/limbs_can_break) && brute_dam >= max_damage * LIMB_MAX_DAMAGE_SEVER_RATIO)
		droplimb()
		if(!(owner.species && (owner.species.species_flags & NO_PAIN)))
			owner.emote("scream")
		return

	if(updating_health)
		owner.updatehealth()

	var/result = update_icon()
	return result


/datum/limb/proc/heal_limb_damage(brute, burn, robo_repair = FALSE, updating_health = FALSE)
	if(limb_status & LIMB_ROBOT && !robo_repair)
		return

	brute_dam = max(0, brute_dam - brute)
	burn_dam = max(0, burn_dam - burn)

	//Sync the organ's damage with its wounds
	update_bleeding()
	if(updating_health)
		owner.updatehealth()

	var/result = update_icon()
	return result

/**
 * This proc completely restores a damaged organ to perfect condition.
 */
/datum/limb/proc/rejuvenate(updating_health = FALSE, updating_icon = FALSE)
	damage_state = "00"
	remove_limb_flags(LIMB_BROKEN | LIMB_BLEEDING | LIMB_SPLINTED | LIMB_STABILIZED | LIMB_AMPUTATED | LIMB_DESTROYED | LIMB_NECROTIZED | LIMB_REPAIRED)
	brute_dam = 0
	burn_dam = 0
	germ_level = 0
	QDEL_LIST(wounds)
	number_wounds = 0
	limb_wound_status = NONE

	// heal internal organs
	for(var/o in internal_organs)
		var/datum/internal_organ/current_organ = o
		current_organ.heal_organ_damage(current_organ.damage)

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

///Actually applies the damage to the limb. Use this directly to bypass 'hitting' the limb with regard to splints, internal wounds, and dismemberment.
/datum/limb/proc/createwound(type = CUT, damage)
	if(damage <= 0)
		return

	//Apply damage, remove relevant treatment flags
	if(type == BURN)
		burn_dam += damage
		limb_wound_status &= !(LIMB_WOUND_SALVED | LIMB_WOUND_DISINFECTED)
	else if(type == CUT || type == BRUISE)
		brute_dam += damage
		limb_wound_status &= !(LIMB_WOUND_BANDAGED | LIMB_WOUND_DISINFECTED)

///For testing convenience. Adds one internal_bleeding wound to the limb.
/datum/limb/proc/add_internal_bleeding()
	new /datum/wound/internal_bleeding(15, src)

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
	if(length(wounds))
		return 1
	return 0

//TODO limbs should probably be on slow process
/datum/limb/process(limb_regen_penalty)

	// Process wounds, doing healing etc. Only do this every few ticks to save processing power
	if(owner.life_tick % wound_update_accuracy == 0)
		update_wounds(limb_regen_penalty)

	//Bone fractures
	if(CONFIG_GET(flag/bones_can_break) && brute_dam > min_broken_damage && !(limb_status & LIMB_ROBOT))
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

	if(limb_status & (LIMB_ROBOT|LIMB_DESTROYED)) //Robotic limbs shouldn't be infected, nor should nonexistant limbs.
		germ_level = 0
		return

	if(owner.bodytemperature >= 170 && !HAS_TRAIT(owner, TRAIT_STASIS))	//cryo stops germs from moving and doing their bad stuffs
		//** Syncing germ levels with external wounds
		handle_germ_sync()

		//** Handle the effects of infections
		handle_germ_effects()

	//** Handle antibiotics and curing infections
	handle_antibiotics()

//Handles germ input from current untreated damage
/datum/limb/proc/handle_germ_sync()
	//Disinfected limbs don't build germs here, only in handle_germ_effects
	if(limb_wound_status & LIMB_WOUND_DISINFECTED)
		return

	if(brute_dam >= 20)
		if(prob((brute_dam - (limb_wound_status & LIMB_WOUND_BANDAGED ? 50 : 0)) * 4))
			germ_level++
	if(burn_dam >= 20)
		if(prob(burn_dam - (limb_wound_status & LIMB_WOUND_SALVED ? 50 : 0) * 2))
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
				if (COOLDOWN_CHECK(src, next_infection_message) && (germ_level <= INFECTION_LEVEL_TWO) && !(limb_status & LIMB_NECROTIZED))
					to_chat(owner, span_notice("Your [display_name] itches and feels warm..."))
					COOLDOWN_START(src, next_infection_message, rand(60 SECONDS, 90 SECONDS))

			if (prob(15))	//adjust this to tweak how fast people take toxin damage from infections
				owner.adjustToxLoss(1)
//LEVEL II
	if(germ_level >= INFECTION_LEVEL_TWO && spaceacillin < 3)

		if(prob(round(germ_level/10)))
			if (spaceacillin < MIN_ANTIBIOTICS)
				germ_level++
				if (COOLDOWN_CHECK(src, next_infection_message) && (germ_level <= INFECTION_LEVEL_THREE) && !(limb_status & LIMB_NECROTIZED))
					to_chat(owner, span_warning("Your infected [display_name] is turning off-color and stings like hell!"))
					COOLDOWN_START(src, next_infection_message, rand(25 SECONDS, 40 SECONDS))

		if (prob(25))	//adjust this to tweak how fast people take toxin damage from infections
			owner.adjustToxLoss(1)

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
	if(germ_level >= INFECTION_LEVEL_THREE && !polyhexanide)	//Need a chem with real drawbacks to stay safe at this point
		if (!(limb_status & LIMB_NECROTIZED))
			add_limb_flags(LIMB_NECROTIZED)
			to_chat(owner, span_notice("You can't feel your [display_name] anymore..."))
			owner.update_body(1)

		germ_level++
		if (prob(50))	//adjust this to tweak how fast people take toxin damage from infections
			owner.adjustToxLoss(1)
		if (prob(1))
			to_chat(owner, span_notice("You have a high fever!"))
//Not technically a germ effect, but derived from it
	if(limb_status & LIMB_NECROTIZED)
		for(var/datum/internal_organ/organ AS in internal_organs)
			organ.take_damage(0.2, silent = TRUE) //1 point every 10 seconds, 100 seconds to bruise, five minutes to broken.


///Updating wounds. Handles natural damage healing from limb treatments and processes internal wounds
/datum/limb/proc/update_wounds(limb_regen_penalty = 1)

	if((limb_status & LIMB_ROBOT)) //Robotic limbs don't heal or get worse.
		return
	if(brute_dam || burn_dam)
		var/damage_ratio = brute_dam / (brute_dam + burn_dam)
		if(limb_wound_status & LIMB_WOUND_BANDAGED)
			brute_dam = brute_dam - base_regen * damage_ratio * limb_regen_penalty
		if(burn_dam && limb_wound_status & LIMB_WOUND_SALVED)
			burn_dam = burn_dam - base_regen * (1 - damage_ratio) * limb_regen_penalty

	if(brute_dam < 0.1)
		brute_dam = 0
	if(burn_dam < 0.1)
		burn_dam = 0

	if(owner.bodytemperature >= 170 && !HAS_TRAIT(owner, TRAIT_STASIS))
		for(var/datum/wound/W in wounds)
			W.process()

	// sync the organ's bleeding-ness and icon
	update_bleeding()
	if (update_icon())
		owner.UpdateDamageIcon(1)

///Updates LIMB_BLEEDING limb flag
/datum/limb/proc/update_bleeding()
	if(limb_status & LIMB_ROBOT || owner.species.species_flags & NO_BLOOD)
		return
	var/is_bleeding = FALSE

	if(brute_dam > 5 && !(limb_wound_status & LIMB_WOUND_BANDAGED))
		is_bleeding = TRUE

	if(surgery_open_stage && !(limb_wound_status & LIMB_WOUND_CLAMPED))	//things tend to bleed if they are CUT OPEN
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
	if(length(limbs_to_remove))
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

	if(amputation)
		set_limb_flags(LIMB_AMPUTATED|LIMB_DESTROYED)
	else
		set_limb_flags(LIMB_DESTROYED)

	if(owner.species.species_flags & ROBOTIC_LIMBS)
		limb_status |= LIMB_ROBOT

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

	//Clear out any internal and external wounds, damage the parent limb
	QDEL_LIST(wounds)
	if(parent && !amputation)
		parent.createwound(CUT, max_damage * 0.25)
	brute_dam = 0
	burn_dam = 0
	limb_wound_status = NONE
	update_bleeding()

	//we reset the surgery related variables
	reset_limb_surgeries()

	var/obj/organ	//Dropped limb object
	switch(body_part)
		if(HEAD)
			if(issynth(owner)) //special head for synth to allow brainmob to talk without an MMI
				organ = new /obj/item/limb/head/synth(owner.loc, owner)
			else if(isrobot(owner))
				organ = new /obj/item/limb/head/robotic(owner.loc, owner)
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
		owner.visible_message(span_warning("[owner.name]'s [display_name] flies off in an arc!"),
		span_highdanger("<b>Your [display_name] goes flying off!</b>"),
		span_warning("You hear a terrible sound of ripping tendons and flesh!"), 3)

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
	if(limb_wound_status & LIMB_WOUND_BANDAGED || !brute_dam)
		return FALSE
	limb_wound_status ^= LIMB_WOUND_BANDAGED
	return TRUE

/datum/limb/proc/is_bandaged()
	if(!(surgery_open_stage == 0))
		return TRUE
	return limb_wound_status & LIMB_WOUND_BANDAGED || !brute_dam

/datum/limb/proc/disinfect()
	if(limb_wound_status & LIMB_WOUND_DISINFECTED || (burn_dam < 20 && brute_dam < 20))
		return FALSE
	limb_wound_status ^= LIMB_WOUND_DISINFECTED
	return TRUE

/datum/limb/proc/is_disinfected()
	if(!(surgery_open_stage == 0))
		return TRUE
	return (limb_wound_status & LIMB_WOUND_DISINFECTED || (burn_dam < 20 && brute_dam < 20))

/datum/limb/proc/clamp_bleeder()
	if(limb_wound_status & LIMB_WOUND_CLAMPED)
		return FALSE
	remove_limb_flags(LIMB_BLEEDING)
	limb_wound_status ^= LIMB_WOUND_CLAMPED
	return TRUE

/datum/limb/proc/salve()
	if(limb_wound_status & LIMB_WOUND_SALVED || !burn_dam)
		return FALSE
	limb_wound_status ^= LIMB_WOUND_SALVED
	return TRUE

/datum/limb/proc/is_salved()
	if(!(surgery_open_stage == 0))
		return TRUE
	return limb_wound_status & LIMB_WOUND_SALVED || !burn_dam

/datum/limb/proc/fracture()

	if(limb_status & (LIMB_BROKEN|LIMB_DESTROYED|LIMB_ROBOT) )
		return

	owner.visible_message(\
		span_warning("You hear a loud cracking sound coming from [owner]!"),
		span_highdanger("Something feels like it shattered in your [display_name]!"),
		"<span class='warning'>You hear a sickening crack!<span>")
	var/soundeffect = pick('sound/effects/bone_break1.ogg','sound/effects/bone_break2.ogg','sound/effects/bone_break3.ogg','sound/effects/bone_break4.ogg','sound/effects/bone_break5.ogg','sound/effects/bone_break6.ogg','sound/effects/bone_break7.ogg')
	playsound(owner,soundeffect, 45, 1)
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


/datum/limb/proc/robotize()
	rejuvenate()
	add_limb_flags(LIMB_ROBOT)
	for(var/c in children)
		var/datum/limb/child_limb = c
		child_limb.robotize()

/// used to give LIMB_BIOTIC flag to the limb
/datum/limb/proc/biotize()
	rejuvenate()
	add_limb_flags(LIMB_BIOTIC)
	for(var/c in children)
		var/datum/limb/child_limb = c
		child_limb.biotize()

/datum/limb/proc/get_damage()	//returns total damage
	return brute_dam + burn_dam	//could use health?

///True if the limb has any damage on it
/datum/limb/proc/has_external_wound()
	return brute_dam || burn_dam

/datum/limb/proc/get_icon(icon/race_icon, gender="")
	if(limb_status & LIMB_ROBOT && !(owner.species.species_flags & LIMB_ROBOT)) //if race set the flag then we just let the race handle this
		return icon('icons/mob/human_races/robotic.dmi', "[icon_name][gender ? "_[gender]" : ""]")

	var/datum/ethnicity/E = GLOB.ethnicities_list[owner.ethnicity]

	var/e_icon

	if (!E)
		e_icon = "western"
	else
		e_icon = E.icon_name

	return icon(race_icon, "[get_limb_icon_name(owner.species, owner.gender, icon_name, e_icon)]")


/datum/limb/proc/is_usable()
	return !(limb_status & (LIMB_DESTROYED|LIMB_NECROTIZED))

/datum/limb/proc/is_broken()
	return ((limb_status & LIMB_BROKEN) && !(limb_status & LIMB_SPLINTED) && !(limb_status & LIMB_STABILIZED))

/datum/limb/proc/is_malfunctioning()
	return ((limb_status & LIMB_ROBOT) && (get_damage() > min_broken_damage))

// todo this proc sucks lmao just redo it from scratch
//for arms and hands
/datum/limb/proc/process_grasp(obj/item/c_hand, hand_name)
	if (!c_hand)
		return

	if(!is_usable())
		owner.dropItemToGround(c_hand)
		owner.emote("me", 1, "drop[owner.p_s()] what [owner.p_they()] [owner.p_were()] holding in [owner.p_their()] [hand_name], [owner.p_their()] [display_name] unresponsive!")
		return
	if(is_broken())
		if(prob(15))
			owner.dropItemToGround(c_hand)
			var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
			owner.emote("me", 1, "[(owner.species && owner.species.species_flags & NO_PAIN) ? "" : emote_scream ] drops what [owner.p_they()] [owner.p_were()] holding in their [hand_name]!")
			return
	if(is_malfunctioning())
		if(prob(20))
			owner.dropItemToGround(c_hand)
			owner.emote("me", 1, "drops what they were holding, [owner.p_their()] [hand_name] malfunctioning!")
			new /datum/effect_system/spark_spread(owner, owner, 5, 0, TRUE, 1 SECONDS)

///applies a splint stack to this limb. should probably be more generic but #notit
/datum/limb/proc/apply_splints(obj/item/stack/medical/splint/S, applied_health, mob/living/user, mob/living/carbon/human/target)
	if(!istype(user))
		return

	if(limb_status & LIMB_DESTROYED)
		target.balloon_alert(user, "limb missing")
		return FALSE

	if(limb_status & LIMB_SPLINTED && applied_health <= splint_health)
		target.balloon_alert(user, "current splint is better")
		return FALSE

	var/delay = SKILL_TASK_AVERAGE - (1 SECONDS + user.skills.getRating(SKILL_MEDICAL) * 5)
	if(target == user)
		delay *= 3

	target.balloon_alert_to_viewers("Splinting [display_name]...")

	if(!do_after(user, delay, NONE, target, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL, extra_checks = CALLBACK(src, PROC_REF(extra_splint_checks), applied_health)))
		return FALSE

	target.balloon_alert_to_viewers("Splinted [display_name]")
	add_limb_flags(LIMB_SPLINTED)
	splint_health = applied_health
	return TRUE

///extra checks to perform during [/proc/apply_splints] do_after
/datum/limb/proc/extra_splint_checks(applied_health)
	if(limb_status & LIMB_SPLINTED && applied_health <= splint_health)
		return FALSE
	return !(limb_status & LIMB_DESTROYED)


///called when limb is removed or robotized, any ongoing surgery and related vars are reset
/datum/limb/proc/reset_limb_surgeries()
	surgery_open_stage = 0
	bone_repair_stage = 0
	limb_replacement_stage = 0
	necro_surgery_stage = 0
	cavity = 0


/datum/limb/proc/add_limb_soft_armor(datum/armor/added_armor)
	soft_armor = soft_armor.attachArmor(added_armor)
	var/datum/armor/scaled_armor = added_armor.scaleAllRatings(cover_index * 0.01, 1)
	owner.soft_armor = owner.soft_armor.attachArmor(scaled_armor)


/datum/limb/proc/remove_limb_soft_armor(datum/armor/removed_armor)
	soft_armor = soft_armor.detachArmor(removed_armor)
	var/datum/armor/scaled_armor = removed_armor.scaleAllRatings(cover_index * 0.01, 1)
	if(owner)
		owner.soft_armor = owner.soft_armor.detachArmor(scaled_armor)


/datum/limb/proc/add_limb_hard_armor(datum/armor/added_armor)
	hard_armor = hard_armor.attachArmor(added_armor)
	var/datum/armor/scaled_armor = added_armor.scaleAllRatings(cover_index * 0.01, 1)
	owner.hard_armor = owner.hard_armor.attachArmor(scaled_armor)


/datum/limb/proc/remove_limb_hard_armor(datum/armor/removed_armor)
	hard_armor = hard_armor.detachArmor(removed_armor)
	var/datum/armor/scaled_armor = removed_armor.scaleAllRatings(cover_index * 0.01, 1)
	if(owner)
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
	max_damage = 150
	min_broken_damage = 50
	body_part = ARM_LEFT
	cover_index = 7

/datum/limb/l_arm/process()
	..()
	process_grasp(owner.l_hand, "left hand")

/datum/limb/l_leg
	name = "l_leg"
	display_name = "left leg"
	icon_name = "l_leg"
	max_damage = 125
	min_broken_damage = 50
	body_part = LEG_LEFT
	cover_index = 14
	icon_position = LEFT

/datum/limb/r_arm
	name = "r_arm"
	display_name = "right arm"
	icon_name = "r_arm"
	max_damage = 150
	min_broken_damage = 50
	body_part = ARM_RIGHT
	cover_index = 7

/datum/limb/r_arm/process()
	..()
	process_grasp(owner.r_hand, "right hand")

/datum/limb/r_leg
	name = "r_leg"
	display_name = "right leg"
	icon_name = "r_leg"
	max_damage = 125
	min_broken_damage = 50
	body_part = LEG_RIGHT
	cover_index = 14
	icon_position = RIGHT

/datum/limb/foot/l_foot
	name = "l_foot"
	display_name = "left foot"
	icon_name = "l_foot"
	max_damage = 100
	min_broken_damage = 37
	body_part = FOOT_LEFT
	cover_index = 4
	icon_position = LEFT

/datum/limb/foot/r_foot
	name = "r_foot"
	display_name = "right foot"
	icon_name = "r_foot"
	max_damage = 100
	min_broken_damage = 37
	body_part = FOOT_RIGHT
	cover_index = 4
	icon_position = RIGHT

/datum/limb/hand/r_hand
	name = "r_hand"
	display_name = "right hand"
	icon_name = "r_hand"
	max_damage = 100
	min_broken_damage = 37
	body_part = HAND_RIGHT
	cover_index = 2

/datum/limb/hand/r_hand/process()
	..()
	process_grasp(owner.r_hand, "right hand")

/datum/limb/hand/l_hand
	name = "l_hand"
	display_name = "left hand"
	icon_name = "l_hand"
	max_damage = 100
	min_broken_damage = 37
	body_part = HAND_LEFT
	cover_index = 2

/datum/limb/hand/l_hand/process()
	..()
	process_grasp(owner.l_hand, "left hand")

/datum/limb/head
	name = "head"
	icon_name = "head"
	display_name = "head"
	max_damage = 125
	min_broken_damage = 40
	body_part = HEAD
	vital = TRUE
	cover_index = 10
	encased = "skull"
	var/disfigured = 0 //whether the head is disfigured.
	var/face_surgery_stage = 0

/datum/limb/head/take_damage_limb(brute, burn, sharp, edge, blocked = 0, updating_health = FALSE, list/forbidden_limbs = list())
	. = ..()
	if (!disfigured)
		if (brute_dam > 40)
			if (prob(50))
				disfigure(BRUTE)
		if (burn_dam > 40)
			disfigure("burn")

/datum/limb/head/proc/disfigure(type = BRUTE)
	if (disfigured)
		return
	if(type == BRUTE)
		owner.visible_message(span_warning(" You hear a sickening cracking sound coming from \the [owner]'s face."),	\
		span_danger("Your face becomes an unrecognizible mangled mess!"),	\
		span_warning(" You hear a sickening crack."))
	else
		owner.visible_message(span_warning(" [owner]'s face melts away, turning into a mangled mess!"),	\
		span_danger("Your face melts off!"),	\
		span_warning(" You hear a sickening sizzle."))
	disfigured = 1
	owner.name = owner.get_visible_name()

/datum/limb/head/reset_limb_surgeries()
	..()
	face_surgery_stage = 0


/datum/limb/head/droplimb(amputation, delete_limb = FALSE)
	. = ..()
	if(!.)
		return
	if(!(owner.species.species_flags & DETACHABLE_HEAD) && vital)
		owner.set_undefibbable()
