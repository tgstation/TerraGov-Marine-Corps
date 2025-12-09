/obj/structure/bed/chair/kz
	name = "Suspicious device"
	desc = "You shouldn't be seeing this."
	icon = 'ntf_modular/icons/obj/structures/kz_stuff.dmi'
	icon_state = "kz_pod"
	base_icon_state = "kz_pod"
	resistance_flags = RESIST_ALL
	max_integrity = 1000000
	max_buckled_mobs = 1
	var/mob/living/carbon/human/current_mob = null
	var/obj/item/disk/kz_neurodisk/stored_disk

/obj/structure/bed/chair/kz/Destroy()
	if(current_mob)
		if(current_mob.handcuffed)
			current_mob.handcuffed.dropped(current_mob)

		current_mob.update_abstract_handcuffed()

	unbuckle_all_mobs(TRUE)
	return ..()

/obj/structure/bed/chair/kz/attack_tk(mob/user)
	return FALSE

/obj/structure/bed/chair/kz/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(!buckled_mob)
		return FALSE

	if(buckled_mob != user)
		if(!do_after(user, 5 SECONDS, buckled_mob))
			to_chat(user, span_warning("You fail to unbuckle [buckled_mob] from [src]."))
			return FALSE

		buckled_mob.visible_message(span_notice("[user] unbuckles [buckled_mob] from [src]."),\
			span_notice("[user] unbuckles you from [src]."),\
			span_hear("You hear metal clanking."))

	else
		if(!do_after(user, 10 SECONDS, buckled_mob))
			to_chat(user, span_warning("You fail to unbuckle yourself from [src]."))
			return FALSE

		user.visible_message(span_notice("You unbuckle yourself from [src]."),\
			span_hear("You hear metal clanking."))

	unbuckle_mob(buckled_mob)

	add_fingerprint(user, "unbuckle")
	if(isliving(buckled_mob.pulledby))
		var/mob/living/pulling_mob = buckled_mob.pulledby
		pulling_mob.set_pull_offsets(buckled_mob, buckled_mob.grab_state)

	return buckled_mob

/obj/structure/bed/chair/kz/user_buckle_mob(mob/living/affected_mob, mob/user, check_loc = TRUE)

	add_fingerprint(user, "buckle")

	if(affected_mob == user)
		if(!do_after(user, 10 SECONDS, affected_mob))
			to_chat(user, span_warning("You fail to buckle yourself to [src]!"))
			return FALSE

		if(buckle_mob(affected_mob, check_loc = check_loc))
			user.visible_message(span_warning("You buckle yourself to [src]!"),\
				span_hear("You hear metal clanking."))

		return TRUE

	affected_mob.visible_message(span_warning("[user] starts buckling [affected_mob] to [src]!"),\
		span_userdanger("[user] starts buckling you to [src]!"),\
		span_hear("You hear metal clanking."))

	if(!do_after(user, 5 SECONDS, affected_mob))
		to_chat(user, span_warning("You fail to buckle [affected_mob] to [src]!"))
		return FALSE

	if(!buckle_mob(affected_mob, check_loc = check_loc))
		return FALSE

	affected_mob.visible_message(span_warning("[user] buckled [affected_mob] to [src]!"),\
		span_userdanger("[user] buckled you to [src]!"),\
		span_hear("You hear metal clanking."))

	return TRUE

/obj/structure/bed/chair/kz/post_buckle_mob(mob/living/affected_mob)
	affected_mob.layer = BELOW_MOB_LAYER

	if(LAZYLEN(buckled_mobs))
		if(ishuman(buckled_mobs[1]))
			current_mob = buckled_mobs[1]

	if(!current_mob)
		return FALSE

	if(current_mob.handcuffed)
		current_mob.handcuffed.forceMove(loc)
		current_mob.handcuffed.dropped(current_mob)
		current_mob.update_handcuffed()

	var/obj/item/restraints/handcuffs/milker/cuffs = new(current_mob)
	current_mob.equip_to_slot_if_possible(cuffs, SLOT_HANDCUFFED, 1, 0, 1, 1)
	cuffs.parent_chair = WEAKREF(src)
	current_mob.update_abstract_handcuffed()

/obj/structure/bed/chair/kz/post_unbuckle_mob(mob/living/affected_mob)
	affected_mob.layer = initial(affected_mob.layer)

	if(!current_mob)
		return FALSE

	if(current_mob.handcuffed)
		current_mob.handcuffed.dropped(current_mob)

	current_mob.update_abstract_handcuffed()
	current_mob = null

/obj/structure/bed/chair/kz/extractor
	name = "Unknown industrial frame"
	desc = "A bulky metal assembly with inactive interfaces."

/obj/structure/bed/chair/kz/extractor/examine(mob/user)
	. = ..()
	if(user.faction == FACTION_VSD)
		. += "<br><b>KZ Neural Extractor</b><br>Kaizoku Covert Division prototype for neural harvesting. Designed to capture and encode cortical skill structures onto NS-92 neurodisks."
		. += "<br><i>Unauthorized disclosure of this device or its operational parameters may result in immediate contract termination and or asset liquidation.</i><br>"

/obj/structure/bed/chair/kz/extractor/attack_hand(mob/living/user)
	if(user.faction == FACTION_VSD && user.a_intent == INTENT_HARM && stored_disk)
		to_chat(user, span_notice("You carefully lift the neurodisk from the extractor."))
		if(!do_after(user, 7 SECONDS, src))
			to_chat(user, span_warning("You are interrupted! The neurodisk stays put as you step back."))
			return TRUE
		var/obj/item/disk/kz_neurodisk/new_disk = new /obj/item/disk/kz_neurodisk(src.loc)
		new_disk.stored_name = stored_disk.stored_name
		new_disk.stored_skills = stored_disk.stored_skills
		qdel(stored_disk)
		stored_disk = null
		to_chat(user, span_notice("You smoothly remove the neurodisk from the extractor, ready for use."))
		return TRUE

	if(LAZYLEN(buckled_mobs))
		user_unbuckle_mob(buckled_mobs[1], user)
		return TRUE

	var/mob/living/affected_mob = locate() in loc
	if(!affected_mob)
		return TRUE

	user_buckle_mob(affected_mob, user, check_loc = TRUE)

/obj/structure/bed/chair/kz/extractor/attack_hand_alternate(mob/living/user)
	if(!current_mob)
		return FALSE

	if(user.faction == FACTION_VSD && user.a_intent == INTENT_HARM && stored_disk)
		if(current_mob.stat == DEAD)
			to_chat(user, span_warning("[current_mob] is dead. No neural activity is detected, extraction is not possible."))
			return TRUE
		if(current_mob.faction == FACTION_VSD)
			to_chat(user, span_warning("[current_mob]'s neural implant engages a fail-safe. Extraction cannot proceed."))
			return TRUE
		if(HAS_TRAIT(current_mob, TRAIT_SKILLS_EXTRACTED))
			to_chat(user, span_warning("Their neural lattice was already harvested. They’ll need cryotube recovery and proper rest before another extraction."))
			return TRUE
		if(current_mob.extract_count >= 2)
			to_chat(user, span_warning("[current_mob]'s neural links has already been extracted twice and are temporarily too distorted. Further extraction is not possible this week."))
			return TRUE

		to_chat(user, span_notice("You carefully start extracting the neurodisk from [current_mob]."))
		if(!do_after(user, 60 SECONDS, current_mob))
			to_chat(user, span_warning("Your extraction is interrupted!"))
			return TRUE
		stored_disk = new /obj/item/disk/kz_neurodisk
		stored_disk.stored_name = current_mob
		stored_disk.stored_skills = current_mob.skills

		current_mob.set_skills(current_mob.skills.modifyAllRatings(-1))

		current_mob.extract_count++

		if(!HAS_TRAIT(current_mob, TRAIT_SKILLS_EXTRACTED))
			ADD_TRAIT(current_mob, TRAIT_SKILLS_EXTRACTED, TRAIT_GENERIC)
			addtimer(CALLBACK(src, PROC_REF(restore_skills), current_mob), 5 MINUTES)

		current_mob.adjustBrainLoss(25)
		current_mob.adjustCloneLoss(25)

		to_chat(user, span_notice("An empty neurodisk is now ready inside the extractor."))
		to_chat(current_mob, span_userdanger("Your mind feels wrong... distorted... You should rest and spend some time in a cryotube to recover."))
		to_chat(user, span_notice("[current_mob] will need to rest and recover in a cryotube before another extraction can be performed."))
		return TRUE

/obj/structure/bed/chair/kz/extractor/attackby(obj/item/I, mob/living/user)
	. = ..()
	if(.)
		return
	if(istype(I, /obj/item/disk/kz_neurodisk) && !stored_disk)
		if(user.faction != FACTION_VSD)
			return
		var/obj/item/disk/kz_neurodisk/initial_disk = I
		if(initial_disk.stored_name)
			to_chat(user, span_warning("You can't load encoded neurodisks into the extractor!"))
			return
		to_chat(user, span_notice("You start loading the empty neurodisk inside the extractor."))
		if(!do_after(user, 7 SECONDS, src))
			to_chat(user, span_warning("Your neurodisk loading is interrupted!"))
			return
		stored_disk = I
		to_chat(user, span_notice("You load the empty neurodisk into the extractor."))
		user.drop_held_item()
		qdel(I)

/obj/structure/bed/chair/kz/imprinter
	name = "Unknown diagnostic station"
	desc = "A compact stand with concealed wiring and sealed panels."

/obj/structure/bed/chair/kz/imprinter/examine(mob/user)
	. = ..()
	if(user.faction == FACTION_VSD)
		. += "<br><b>KZ Neural Imprinter</b><br>Kaizoku Covert Division prototype imprinting platform. Transfers encoded NS-92 neural architectures directly into the operator's cortex."
		. += "<br><i>Unauthorized disclosure of this device or its operational parameters may result in immediate contract termination and or asset liquidation.</i><br>"

/obj/structure/bed/chair/kz/imprinter/attack_hand(mob/living/user)
	if(user.faction == FACTION_VSD && user.a_intent == INTENT_HARM && stored_disk)
		to_chat(user, span_notice("You carefully lift the neurodisk from the imprinter."))
		if(!do_after(user, 7 SECONDS, src))
			to_chat(user, span_warning("You are interrupted! The neurodisk stays put as you step back."))
			return TRUE
		var/obj/item/disk/kz_neurodisk/new_disk = new /obj/item/disk/kz_neurodisk(src.loc)
		new_disk.stored_name = stored_disk.stored_name
		new_disk.stored_skills = stored_disk.stored_skills
		qdel(stored_disk)
		stored_disk = null
		to_chat(user, span_notice("You smoothly remove the neurodisk from the imprinter, ready for use."))
		return TRUE

	if(LAZYLEN(buckled_mobs))
		user_unbuckle_mob(buckled_mobs[1], user)
		return TRUE

	var/mob/living/affected_mob = locate() in loc
	if(!affected_mob)
		return TRUE

	user_buckle_mob(affected_mob, user, check_loc = TRUE)

/obj/structure/bed/chair/kz/imprinter/attack_hand_alternate(mob/living/user)
	if(!current_mob)
		return FALSE

	if(user.faction == FACTION_VSD && user.a_intent == INTENT_HARM && stored_disk)
		if(current_mob.stat == DEAD)
			return TRUE
		if(HAS_TRAIT(current_mob, TRAIT_SKILLS_IMPRINTED))
			to_chat(user, span_warning("Their neural lattice is still destabilized from the last imprint. They'll need cryotube recovery and time to stabilize before another transfer."))
			return TRUE
		to_chat(user, span_notice("You place the neurodisk against [current_mob]'s interface, feeling the neural patterns align."))
		if(!do_after(user, 60 SECONDS, current_mob))
			to_chat(user, span_warning("The imprinting is interrupted!"))
			return TRUE

		current_mob.original_skills_type = current_mob.skills.type

		imprint_skills()

		stored_disk.stored_name = null
		stored_disk.stored_skills = null

		if(!HAS_TRAIT(current_mob, TRAIT_SKILLS_IMPRINTED))
			ADD_TRAIT(current_mob, TRAIT_SKILLS_IMPRINTED, TRAIT_GENERIC)
			ADD_TRAIT(current_mob, TRAIT_SKILLS_EDITED, TRAIT_GENERIC)
			addtimer(CALLBACK(src, PROC_REF(restore_skills), current_mob), 5 MINUTES)

		current_mob.adjustBrainLoss(25)
		current_mob.adjustCloneLoss(25)

		to_chat(user, span_notice("The neural data transfers successfully into [current_mob]'s cortex, the imprint complete."))
		to_chat(current_mob, span_danger("A wave of disorientation washes over you. You should rest and stabilize in a cryotube."))
		to_chat(user, span_notice("[current_mob] will need time in a cryotube to stabilize after receiving the imprint."))
		return TRUE

/obj/structure/bed/chair/kz/proc/imprint_skills()
	if(stored_disk.stored_skills.unarmed > current_mob.skills.unarmed)
		current_mob.set_skills(current_mob.skills.setRating(unarmed = stored_disk.stored_skills.unarmed))
	if(stored_disk.stored_skills.melee_weapons > current_mob.skills.melee_weapons)
		current_mob.set_skills(current_mob.skills.setRating(melee_weapons = stored_disk.stored_skills.melee_weapons))
	if(stored_disk.stored_skills.combat > current_mob.skills.combat)
		current_mob.set_skills(current_mob.skills.setRating(combat = stored_disk.stored_skills.combat))
	if(stored_disk.stored_skills.pistols > current_mob.skills.pistols)
		current_mob.set_skills(current_mob.skills.setRating(pistols = stored_disk.stored_skills.pistols))
	if(stored_disk.stored_skills.shotguns > current_mob.skills.shotguns)
		current_mob.set_skills(current_mob.skills.setRating(shotguns = stored_disk.stored_skills.shotguns))
	if(stored_disk.stored_skills.rifles > current_mob.skills.rifles)
		current_mob.set_skills(current_mob.skills.setRating(rifles = stored_disk.stored_skills.rifles))
	if(stored_disk.stored_skills.smgs > current_mob.skills.smgs)
		current_mob.set_skills(current_mob.skills.setRating(smgs = stored_disk.stored_skills.smgs))
	if(stored_disk.stored_skills.heavy_weapons > current_mob.skills.heavy_weapons)
		current_mob.set_skills(current_mob.skills.setRating(heavy_weapons = stored_disk.stored_skills.heavy_weapons))
	if(stored_disk.stored_skills.smartgun > current_mob.skills.smartgun)
		current_mob.set_skills(current_mob.skills.setRating(smartgun = stored_disk.stored_skills.smartgun))
	if(stored_disk.stored_skills.engineer > current_mob.skills.engineer)
		current_mob.set_skills(current_mob.skills.setRating(engineer = stored_disk.stored_skills.engineer))
	if(stored_disk.stored_skills.construction > current_mob.skills.construction)
		current_mob.set_skills(current_mob.skills.setRating(construction = stored_disk.stored_skills.construction))
	if(stored_disk.stored_skills.leadership > current_mob.skills.leadership)
		current_mob.set_skills(current_mob.skills.setRating(leadership = stored_disk.stored_skills.leadership))
	if(stored_disk.stored_skills.medical > current_mob.skills.medical)
		current_mob.set_skills(current_mob.skills.setRating(medical = stored_disk.stored_skills.medical))
	if(stored_disk.stored_skills.surgery > current_mob.skills.surgery)
		current_mob.set_skills(current_mob.skills.setRating(surgery = stored_disk.stored_skills.surgery))
	if(stored_disk.stored_skills.pilot > current_mob.skills.pilot)
		current_mob.set_skills(current_mob.skills.setRating(pilot = stored_disk.stored_skills.pilot))
	if(stored_disk.stored_skills.police > current_mob.skills.police)
		current_mob.set_skills(current_mob.skills.setRating(police = stored_disk.stored_skills.police))
	if(stored_disk.stored_skills.powerloader > current_mob.skills.powerloader)
		current_mob.set_skills(current_mob.skills.setRating(powerloader = stored_disk.stored_skills.powerloader))
	if(stored_disk.stored_skills.large_vehicle > current_mob.skills.large_vehicle)
		current_mob.set_skills(current_mob.skills.setRating(large_vehicle = stored_disk.stored_skills.large_vehicle))
	if(stored_disk.stored_skills.mech > current_mob.skills.mech)
		current_mob.set_skills(current_mob.skills.setRating(mech = stored_disk.stored_skills.mech))
	if(stored_disk.stored_skills.stamina > current_mob.skills.stamina)
		current_mob.set_skills(current_mob.skills.setRating(stamina = stored_disk.stored_skills.stamina))

/obj/structure/bed/chair/kz/proc/restore_skills(mob/living/target)
	target.can_restore_skills = TRUE

/obj/structure/bed/chair/kz/imprinter/attackby(obj/item/I, mob/living/user)
	. = ..()
	if(.)
		return
	if(istype(I, /obj/item/disk/kz_neurodisk))
		if(user.faction != FACTION_VSD)
			to_chat(user, span_warning("You have no idea how to operate that kind of device."))
			return
		var/obj/item/disk/kz_neurodisk/initial_disk = I
		if(!stored_disk)
			if(!initial_disk.stored_name)
				to_chat(user, span_warning("That neurodisk is not encoded! You can't load empty disks into the imprinter."))
				return
			to_chat(user, span_notice("You start loading the neurodisk inside the imprinter."))
			if(!do_after(user, 7 SECONDS, src))
				to_chat(user, span_warning("Your neurodisk loading is interrupted!"))
				return TRUE
			stored_disk = initial_disk
			to_chat(user, span_notice("You load the encoded neurodisk into the imprinter."))
			user.drop_held_item()
			qdel(I)

/obj/item/disk/kz_neurodisk
	name = "Unlabeled data disk"
	desc = "A small metallic disk with no markings."
	icon_state = "nucleardisk"
	resistance_flags = RESIST_ALL
	var/stored_name = null
	var/datum/skills/stored_skills = null

/obj/item/disk/kz_neurodisk/examine(mob/user)
	. = ..()
	if(user.faction == FACTION_VSD)
		. += "<br><b>NS-92 Covert Neurodisk</b><br>Kaizoku Covert Division encrypted module containing extracted neural skill architecture."
		. += "<br><i>Unauthorized disclosure of this device or its operational parameters may result in immediate contract termination and or asset liquidation.</i><br>"
		if(stored_name)
			. += "This neurodisk contains <b>[stored_name]'s</b> scan."

/obj/item/disk/kz_neurodisk/attack_self(mob/user)
	. = ..()
	if(user.faction == FACTION_VSD && stored_name)
		to_chat(user, span_notice("You initiate the neurodisk wiping process."))
		if(!do_after(user, 7 SECONDS, src))
			to_chat(user, span_warning("Neurodisk wiping interrupted! You’ll need to start over."))
			return TRUE
		stored_name = null
		stored_skills = null
		to_chat(user, span_notice("Neurodisk successfully wiped."))
