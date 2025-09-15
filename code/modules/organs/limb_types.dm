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
	. = ..()
	process_grasp(owner.l_hand, "left hand")

/datum/limb/r_arm
	name = "r_arm"
	display_name = "right arm"
	icon_name = "r_arm"
	max_damage = 150
	min_broken_damage = 50
	body_part = ARM_RIGHT
	cover_index = 7

/datum/limb/r_arm/process()
	. = ..()
	process_grasp(owner.r_hand, "right hand")

/datum/limb/l_leg
	name = "l_leg"
	display_name = "left leg"
	icon_name = "l_leg"
	max_damage = 125
	min_broken_damage = 50
	body_part = LEG_LEFT
	cover_index = 14
	icon_position = LEFT

/datum/limb/r_leg
	name = "r_leg"
	display_name = "right leg"
	icon_name = "r_leg"
	max_damage = 125
	min_broken_damage = 50
	body_part = LEG_RIGHT
	cover_index = 14
	icon_position = RIGHT

/datum/limb/foot
	max_damage = 100
	min_broken_damage = 37
	cover_index = 4

/datum/limb/foot/remove_limb_flags(to_remove_flags)
	. = ..()
	if(isnull(.))
		return
	var/changed_flags = . & to_remove_flags
	if((changed_flags & LIMB_DESTROYED) && owner.has_legs())
		REMOVE_TRAIT(owner, TRAIT_LEGLESS, TRAIT_LEGLESS)

/datum/limb/foot/add_limb_flags(to_add_flags)
	. = ..()
	if(isnull(.))
		return
	var/changed_flags = ~(. & to_add_flags) & to_add_flags
	if((changed_flags & LIMB_DESTROYED) && !owner.has_legs())
		ADD_TRAIT(owner, TRAIT_LEGLESS, TRAIT_LEGLESS)

/datum/limb/foot/l_foot
	name = "l_foot"
	display_name = "left foot"
	icon_name = "l_foot"
	body_part = FOOT_LEFT
	icon_position = LEFT

/datum/limb/foot/r_foot
	name = "r_foot"
	display_name = "right foot"
	icon_name = "r_foot"
	body_part = FOOT_RIGHT
	icon_position = RIGHT

/datum/limb/hand
	max_damage = 100
	min_broken_damage = 37
	cover_index = 2

/datum/limb/hand/r_hand
	name = "r_hand"
	display_name = "right hand"
	icon_name = "r_hand"
	body_part = HAND_RIGHT

/datum/limb/hand/r_hand/process()
	. = ..()
	process_grasp(owner.r_hand, "right hand")

/datum/limb/hand/l_hand
	name = "l_hand"
	display_name = "left hand"
	icon_name = "l_hand"
	body_part = HAND_LEFT

/datum/limb/hand/l_hand/process()
	. = ..()
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
	if(!disfigured)
		if(brute_dam > 40)
			if(prob(50))
				disfigure(BRUTE)
		if(burn_dam > 40)
			disfigure(BURN)

/datum/limb/head/proc/disfigure(type = BRUTE)
	if(disfigured)
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
	. = ..()
	face_surgery_stage = 0

/datum/limb/head/drop_limb(amputation, delete_limb = FALSE, silent = FALSE)
	. = ..()
	if(!.)
		return
	if(!(owner.species.species_flags & DETACHABLE_HEAD) && vital)
		owner.set_undefibbable()

/datum/limb/head/owner_pre_death()
	if(owner.species.species_flags & DETACHABLE_HEAD)
		return
	if(!vital)
		return
	owner.remove_organ_slot(ORGAN_SLOT_BRAIN)
	owner.remove_organ_slot(ORGAN_SLOT_EYES)
