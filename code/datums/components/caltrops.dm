//Ouch my toes!
#define CALTROP_BYPASS_SHOES 1
#define CALTROP_IGNORE_WALKERS 2
#define CALTROP_SILENT 3

/datum/component/caltrop
	var/min_damage
	var/max_damage
	var/probability
	var/flags
	// COOLDOWN_DECLARE(caltrop_cooldown)


/datum/component/caltrop/Initialize(_min_damage = 0, _max_damage = 0, _probability = 100,  _flags = NONE)
	min_damage = _min_damage
	max_damage = max(_min_damage, _max_damage)
	probability = _probability
	flags = _flags

	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED), .proc/Crossed)

/datum/component/caltrop/proc/Crossed(datum/source, atom/movable/AM)
	if(!prob(probability))
		return

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		// if(HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
		// 	return

		if((flags & CALTROP_IGNORE_WALKERS) && H.m_intent == MOVE_INTENT_WALK)
			return

		if(H.buckled) //if they're buckled to something, that something should be checked instead.
			return
		if(!(H.lying_angle)) //if were not standing we cant step on the caltrop
			return

		var/picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/datum/limb/O = H.get_limb(picked_def_zone)
		if(!istype(O))
			return
		if(O.limb_status == LIMB_ROBOT)
			return

		var/feetCover = (H.wear_suit && (H.wear_suit.flags_armor_protection & FEET)) || (H.w_uniform && (H.w_uniform.flags_armor_protection & FEET))

		if(!(flags & CALTROP_BYPASS_SHOES) && (H.shoes || feetCover))
			return

		var/damage = rand(min_damage, max_damage)

		if(!(flags & CALTROP_SILENT) && COOLDOWN_CHECK(src, COOLDOWN_ARMOR_ACTION))
			COOLDOWN_START(src, COOLDOWN_ARMOR_ACTION, 1 SECONDS) //cooldown to avoid message spam.
			var/atom/A = parent
			if(!H.incapacitated(ignore_restrained = TRUE))
				H.visible_message("<span class='danger'>[H] steps on [A].</span>", \
						"<span class='userdanger'>You step on [A]!</span>")
			else
				H.visible_message("<span class='danger'>[H] slides on [A]!</span>", \
						"<span class='userdanger'>You slide on [A]!</span>")

		H.apply_damage(damage, BRUTE, picked_def_zone)
		// H.Paralyze(60)
