/datum/component/parasitic_clothing
	var/implant_delay = 4 MINUTES
	var/hivenumber = XENO_HIVE_NORMAL
	var/fixed_hole = null
	var/mob/living/carbon/human/wearer = null
	var/atom/origin = null
	COOLDOWN_DECLARE(implant_cooldown)

/datum/component/parasitic_clothing/Destroy(force, silent)
	QDEL_NULL(implant_cooldown)
	wearer = null
	return ..()

/datum/component/parasitic_clothing/Initialize(_hivenumber, _fixed_hole)
	. = ..()
	hiveify(_hivenumber, _fixed_hole)
	STOP_PROCESSING(SSslowprocess, src)

/datum/component/parasitic_clothing/proc/hiveify(_hivenumber, _fixed_hole)
	if(_hivenumber)
		hivenumber = _hivenumber
	if(_fixed_hole)
		fixed_hole = _fixed_hole
	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	if(isclothing(parent))
		var/obj/item/clothing/cparent = parent
		cparent.color = hive.color
		cparent.update_icon(UPDATE_ICON)

/datum/component/parasitic_clothing/RegisterWithParent()
	. = ..()
	START_PROCESSING(SSslowprocess, src)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(dropped))

/datum/component/parasitic_clothing/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNEQUIPPED)

/datum/component/parasitic_clothing/proc/equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	wearer = equipper
	if(!(slot &= SLOT_L_HAND) || !(slot &= SLOT_R_HAND))
		wearer.visible_message(span_warning("[parent] attaches itself to [wearer]!"),
				span_warning("[parent] attaches itself to you!"),
				span_notice("You hear rustling."))
		ADD_TRAIT(parent, TRAIT_NODROP, "parasite_trait")
		START_PROCESSING(SSslowprocess, src)
	RegisterSignal(wearer, COMSIG_HUMAN_BURN_DAMAGE, PROC_REF(burn_moment))

/datum/component/parasitic_clothing/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	wearer = null
	REMOVE_TRAIT(parent, TRAIT_NODROP, "parasite_trait")
	UnregisterSignal(wearer, COMSIG_HUMAN_BURN_DAMAGE, PROC_REF(burn_moment))
	STOP_PROCESSING(SSslowprocess, src)

/datum/component/parasitic_clothing/proc/burn_moment(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	wearer.visible_message(span_warning("[parent] emits a screech and detaches from [wearer]!"),
			span_warning("[parent] screeches detaches from you!"),
			span_notice("You hear screeching."))
	REMOVE_TRAIT(parent, TRAIT_NODROP, "parasite_trait")
	wearer.UnEquip(parent, TRUE)

/datum/component/parasitic_clothing/process()
	. = ..()
	if(!wearer)
		STOP_PROCESSING(SSslowprocess, src)
		return
	process_sex(wearer)

/datum/component/parasitic_clothing/proc/process_sex()
	if(wearer.stat == DEAD)
		return
	//wheel of fuck
	var/targethole = rand(5)
	var/targetholename = "mouth"
	switch(targethole)
		if(HOLE_MOUTH)
			targetholename = "mouth"
		if(HOLE_ASS)
			targetholename = "ass"
		if(HOLE_VAGINA)
			targetholename = "pussy"
		if(HOLE_NIPPLE)
			targetholename = "nipples"
		if(HOLE_EAR)
			targetholename = "ears"
	if(fixed_hole)
		targethole = fixed_hole
	if(targethole == HOLE_VAGINA || targethole == HOLE_NIPPLE)
		if(wearer.gender != FEMALE)
			targethole = HOLE_ASS
			targetholename = "ass"
	if(COOLDOWN_FINISHED(src, implant_cooldown))
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
			wearer.visible_message(span_love("[src]'s tentacle pumps globs slightly acidic cum into [wearer]'s [targetholename]!"),
			span_love("[src] tentacle pumps globs of slightly acidic cum into your [targetholename]!"),
			span_love("You hear spurting."))
			wearer.reagents.add_reagent(/datum/reagent/consumable/nutriment, 5)
			wearer.reagents.add_reagent(/datum/reagent/toxin/acid, 2)
	else
		wearer.visible_message(span_love("[parent] roughly thrusts a tentacle into [wearer]'s [targetholename]!"),
		span_love("[parent] roughly thrusts a tentacle into your [targetholename]!"),
		span_love("You hear squelching."))
