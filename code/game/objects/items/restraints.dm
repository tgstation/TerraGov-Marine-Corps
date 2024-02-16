/obj/item/restraints
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/security_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/security_right.dmi',
	)
	breakouttime = 2 MINUTES


/obj/item/restraints/resisted_against(datum/source)
	var/mob/living/carbon/perp = source
	if(TIMER_COOLDOWN_CHECK(perp, COOLDOWN_RESIST))
		return FALSE

	perp.changeNext_move(CLICK_CD_RESIST)

	TIMER_COOLDOWN_START(perp, COOLDOWN_RESIST, CLICK_CD_BREAKOUT)

	perp.resist_restraints(src)


/mob/living/carbon/proc/resist_restraints(obj/item/restraints/cuffs)
	if(do_actions)
		balloon_alert(src, "busy")
		return

	visible_message(span_warning("[src] attempts to remove [cuffs]!"),
	span_notice("You attempt to remove [cuffs]... (This will take around [DisplayTimeText(cuffs.breakouttime)] and you need to stand still.)"))

	if(!do_after(src, cuffs.breakouttime, IGNORE_HELD_ITEM, target = src))
		return FALSE

	visible_message(span_danger("[src] manages to remove [cuffs]!"),
	span_notice("You successfully remove [cuffs]."))

	dropItemToGround(cuffs) //This will call UnEquip() > update_handcuffed() > UnregisterSignal()
