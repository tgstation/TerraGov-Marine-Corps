/mob/living/proc/do_resist()
	if(next_move > world.time)
		return FALSE

	if(incapacitated(TRUE))
		to_chat(src, "<span class='warning'>You can't resist in your current state.</span>")
		return FALSE

	changeNext_move(CLICK_CD_RESIST)

	SEND_SIGNAL(src, COMSIG_LIVING_DO_RESIST, src)


/mob/living/carbon/proc/resist_handcuffs()
	if(last_special >= world.time)
		return FALSE

	changeNext_move(CLICK_CD_BREAKOUT)
	last_special = world.time + CLICK_CD_BREAKOUT

	var/obj/item/restraints/handcuffs/cuffs = handcuffed

	resist_cuffs(cuffs)


/mob/living/carbon/proc/resist_legcuffs()
	if(last_special >= world.time)
		return FALSE

	changeNext_move(CLICK_CD_RANGE)
	last_special = world.time + CLICK_CD_RANGE

	var/obj/item/cuffs = legcuffed

	resist_cuffs(cuffs)


/mob/living/carbon/proc/resist_cuffs(obj/item/cuffs)
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

	dropItemToGround(cuffs) //This will call doUnEquip() > update_handcuffed() > UnregisterSignal()