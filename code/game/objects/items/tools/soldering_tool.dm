/obj/item/tool/surgery/solderingtool
	name = "soldering tool"
	desc = "A hand tool to fix combat robot's trauma. You do not need welding goggles for this and you need medical skills for this."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "solderingtool"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tool/surgery/solderingtool/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H) || user.a_intent != INTENT_HELP)
		return ..()

	var/datum/limb/affecting = CHECK_BITFIELD(user.client.prefs.toggles_gameplay, RADIAL_MEDICAL) ? radial_medical(H, user) : H.get_limb(user.zone_selected)
	if(!affecting)
		return TRUE

	if(!CHECK_BITFIELD(affecting.limb_status, LIMB_ROBOT))
		balloon_alert(user, "Limb not robotic")
		return TRUE

	if(!affecting.burn_dam && !affecting.brute_dam)
		balloon_alert(user, "Nothing to fix!")
		return TRUE

	if(user.do_actions)
		balloon_alert(user, "Already busy!")
		return TRUE

	var/repair_time = 1.5 SECONDS
	if(H == user)
		repair_time *= 1.5

	user.visible_message(span_notice("[user] starts to solder the wounds on [H == user ? "[H.p_their()]" : "[H]'s"] [affecting.display_name]."),\
		span_notice("You start soldering the wounds on [H == user ? "your" : "[H]'s"] [affecting.display_name]."))

	while((affecting.burn_dam || affecting.brute_dam) && do_after(user, repair_time, TRUE, H, BUSY_ICON_BUILD))
		user.visible_message(span_warning("\The [user] solders the wounds on [H == user ? "[H.p_their()]" : "[H]'s"] [affecting.display_name] with \the [src]."), \
			span_warning("You solder the wounds on [H == user ? "your" : "[H]'s"] [affecting.display_name]."))
		if(affecting.heal_limb_damage(10, 10, robo_repair = TRUE, updating_health = TRUE))
			H.UpdateDamageIcon()
		if(!(affecting.brute_dam || affecting.burn_dam))
			var/previous_limb = affecting
			for(var/datum/limb/checked_limb AS in H.limbs)
				if(!(checked_limb.limb_status & LIMB_ROBOT))
					continue
				if(!(checked_limb.brute_dam || checked_limb.burn_dam))
					continue
				affecting = checked_limb
				break
			if(previous_limb == affecting)
				balloon_alert(user, "Fully repaired.")
				break
	return TRUE
