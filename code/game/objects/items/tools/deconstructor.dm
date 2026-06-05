/obj/item/tool/deconstructor
	name = "\improper Rapid Field Disassembler"
	desc = "The RFD is an engineering tool employed to rapidly deconstruct fortified positions, storing all harvested materials on your person. \
	Allows for efficient repositioning of resources or speedy penetration of hostile defences."
	icon_state = "deconstructor"
	atom_flags = CONDUCT
	equip_slot_flags = ITEM_SLOT_BELT
	force = 20
	throwforce = 20
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacks", "smashes", "bludgeons", "batters", "bashes", "beats")
	hitsound = 'sound/weapons/heavyhit.ogg'
	move_resist = MOVE_FORCE_NORMAL
	///Construction skill to use this properly
	var/skill_level = SKILL_CONSTRUCTION_PLASTEEL

/obj/item/tool/deconstructor/preattack(atom/target, mob/user, params)
	if(!isstructure(target))
		return FALSE
	var/obj/structure/decon_target = target
	if(!decon_target.is_deconstructor_target(src, user))
		return FALSE
	if(!COOLDOWN_FINISHED(decon_target, tool_cooldown))
		return FALSE

	COOLDOWN_START(decon_target, tool_cooldown, 1 SECONDS)
	if(user.skills.getRating(SKILL_CONSTRUCTION) < skill_level)
		var/fumbling_time = 5 SECONDS * (skill_level - user.skills.getRating(SKILL_CONSTRUCTION))
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE
		if(QDELETED(decon_target))
			return FALSE

	balloon_alert_to_viewers("disassembling...")
	playsound(loc, 'sound/items/jaws_pry.ogg', 25, 1)
	if(!do_after(user, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return TRUE
	if(QDELETED(decon_target))
		return FALSE

	user.visible_message(span_notice("[user] takes [decon_target] apart."),
	span_notice("You take [decon_target] apart."))
	playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
	var/list/stack_list = decon_target.deconstruct(!get_self_acid(), user)
	if(!ishuman(user))
		return TRUE

	var/mob/living/carbon/human/human_user = user
	for(var/obj/item/stack/stack in stack_list)
		if(human_user.s_active?.on_attackby(human_user.s_active, stack, human_user))
			continue
		human_user.equip_to_appropriate_slot(stack, FALSE)
	return TRUE

///Can be deconstructed by the deconstructor
/obj/structure/proc/is_deconstructor_target()
	return FALSE

/obj/structure/barricade/is_deconstructor_target()
	return TRUE

/obj/structure/razorwire/is_deconstructor_target()
	return TRUE
