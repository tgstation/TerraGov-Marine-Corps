/datum/component/parasitic_clothing
	var/implant_delay = 4 MINUTES
	var/hivenumber = XENO_HIVE_NORMAL
	var/fixed_hole = null
	var/mob/living/carbon/human/wearer = null
	COOLDOWN_DECLARE(implant_cooldown)

/datum/component/parasitic_clothing/Destroy(force, silent)
	QDEL_NULL(implant_cooldown)
	wearer = null
	return ..()

/datum/component/parasitic_clothing/New(list/raw_args)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/datum/component/parasitic_clothing/RegisterWithParent()
	. = ..()
	START_PROCESSING(SSobj, src)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(dropped))

/datum/component/parasitic_clothing/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNEQUIPPED)

/datum/component/parasitic_clothing/proc/equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	wearer = equipper
	ADD_TRAIT(parent, TRAIT_NODROP, "parasite_trait")
	RegisterSignal(wearer, COMSIG_LIVING_HANDLE_FIRE, PROC_REF(flaming))
	START_PROCESSING(SSobj, src)

/datum/component/parasitic_clothing/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	wearer = null
	REMOVE_TRAIT(parent, TRAIT_NODROP, "parasite_trait")
	UnregisterSignal(wearer, COMSIG_LIVING_HANDLE_FIRE, PROC_REF(flaming))
	STOP_PROCESSING(SSobj, src)

/datum/component/parasitic_clothing/proc/flaming(datum/source)
	SIGNAL_HANDLER
	wearer.visible_message(span_warning("[src] emits a screech and detaches from [wearer]!"),
			span_warning("[src] screeches detaches from you!"),
			span_notice("You hear screeching."))
	REMOVE_TRAIT(parent, TRAIT_NODROP, "parasite_trait")
	wearer.UnEquip(parent, TRUE)

/datum/component/parasitic_clothing/process()
	. = ..()
	if(!wearer)
		STOP_PROCESSING()
		return
	process_sex(wearer)

/datum/component/parasitic_clothing/proc/process_sex()
	if(wearer.stat == DEAD)
		return
	if(!fixed_hole)
		//wheel of fuck
		var/targethole = rand(3)
		var/targetholename = "mouth"
		switch(targethole)
			if(HOLE_MOUTH)
				targetholename = "mouth"
			if(HOLE_ASS)
				targetholename = "ass"
			if(HOLE_VAGINA)
				targetholename = "pussy"
	else
		targethole = fixed_hole
	if(targethole == HOLE_VAGINA)
		if(wearer.gender = FEMALE)
			targetholename = "pussy"
		else
			targethole = HOLE_ASS
			targetholename = "ass"
	var/implanted_embryos = 0
	for(var/obj/item/alien_embryo/implanted in victim.contents)
		implanted_embryos++
	if(COOLDOWN_FINISHED(src, implant_cooldown) && (implanted_embryos < 3))
		COOLDOWN_START(src, implant_cooldown, implant_delay)
		if(!(wearer.status_flags & XENO_HOST))
			wearer.visible_message(span_xenonotice("[src] roughly thrusts a tentacle into [wearer]'s [targetholename], a round bulge visibly sliding through it as it inserts an egg into [wearer]!"),
			span_xenonotice("[src] roughly thrusts a tentacle into your [targetholename], a round bulge visibly sliding through it as it inserts an egg into you!"),
			span_notice("You hear squelching."))
			var/obj/item/alien_embryo/embryo = new(wearer)
			embryo.hivenumber = hivenumber
			embryo.emerge_target = targethole
			embryo.emerge_target_flavor = targetholename
		else
			wearer.visible_message(span_love("[src] roughly thrusts a tentacle into [wearer]'s [targetholename]!"),
			span_love("[src] roughly thrusts a tentacle into your [targetholename]!"),
			span_love("You hear squelching."))
	else
		wearer.visible_message(span_love("[src] roughly thrusts a tentacle into [wearer]'s [targetholename]!"),
		span_love("[src] roughly thrusts a tentacle into your [targetholename]!"),
		span_love("You hear squelching."))
