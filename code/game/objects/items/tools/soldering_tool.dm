/obj/item/tool/solderingtool
	name = "soldering tool"
	desc = "A hand tool to fix combat robot's trauma. Very effective in repairing robotic machinery."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "alien_hemostat"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tool/solderingtool/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	if(user.a_intent != INTENT_HELP)
		return ..()

	var/datum/limb/affecting = user.client.prefs.toggles_gameplay & RADIAL_MEDICAL ? radial_medical(H, user) : H.get_limb(user.zone_selected)
	if(!affecting)
		return TRUE

	if(affecting.limb_status != LIMB_ROBOT)
		balloon_alert(user, "Limb not robotic")
		return TRUE

	if(!affecting.burn_dam)
		balloon_alert(user, "Nothing to fix!")
		return TRUE

	if(user.do_actions)
		balloon_alert(user, "Already busy!")
		return TRUE

	var/repair_time = 1 SECONDS
	if(H == user)
		repair_time *= 3

	user.visible_message(span_notice("[user] starts to fix some of the wires in [H == user ? "[H.p_their()]" : "[H]'s"] [affecting.display_name]."),\
		span_notice("You start fixing some of the wires in [H == user ? "your" : "[H]'s"] [affecting.display_name]."))

	while(affecting.burn_dam && do_after(user, repair_time, TRUE, src, BUSY_ICON_BUILD) && use(1))
		user.visible_message(span_warning("\The [user] fixes some wires in [H == user ? "[H.p_their()]" : "[H]'s"] [affecting.display_name] with \the [src]."), \
			span_warning("You patch some wires in [H == user ? "your" : "[H]'s"] [affecting.display_name]."))
		if(affecting.heal_limb_damage(15, 15, robo_repair = TRUE, updating_health = TRUE))
			H.UpdateDamageIcon()
	return TRUE
