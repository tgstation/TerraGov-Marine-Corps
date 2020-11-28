/obj/item/restraints
	breakouttime = 2 MINUTES


/obj/item/restraints/resisted_against(datum/source)
	var/mob/living/carbon/perp = source
	if(TIMER_COOLDOWN_CHECK(perp, COOLDOWN_RESIST))
		return FALSE

	perp.changeNext_move(CLICK_CD_RESIST)

	TIMER_COOLDOWN_START(perp, COOLDOWN_RESIST, CLICK_CD_BREAKOUT)

	perp.resist_restraints(src)


/mob/living/carbon/proc/resist_restraints(obj/item/restraints/cuffs)
	if(CHECK_BITFIELD(cuffs.flags_item, BEING_REMOVED))
		to_chat(src, "<span class='warning'>You're already attempting to remove [cuffs]!</span>")
		return

	ENABLE_BITFIELD(cuffs.flags_item, BEING_REMOVED)

	visible_message("<span class='warning'>[src] attempts to remove [cuffs]!</span>",
	"<span class='notice'>You attempt to remove [cuffs]... (This will take around [DisplayTimeText(cuffs.breakouttime)] and you need to stand still.)</span>")

	if(!do_after(src, cuffs.breakouttime, FALSE, target = src))
		to_chat(src, "<span class='warning'>You fail to remove [cuffs]!</span>")
		DISABLE_BITFIELD(cuffs.flags_item, BEING_REMOVED)
		return FALSE

	visible_message("<span class='danger'>[src] manages to remove [cuffs]!</span>",
	"<span class='notice'>You successfully remove [cuffs].</span>")

	DISABLE_BITFIELD(cuffs.flags_item, BEING_REMOVED)

	dropItemToGround(cuffs) //This will call UnEquip() > update_handcuffed() > UnregisterSignal()
