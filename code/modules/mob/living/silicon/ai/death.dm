/mob/living/silicon/ai/death(gibbed)

	if(stat == DEAD)
		return

	icon_state = "ai-crash"

	if(src.eyeobj)
		src.eyeobj.setLoc(get_turf(src))

	remove_ai_verbs(src)

	for(var/obj/machinery/computer/communications/commconsole in machines)
		if(commconsole.z == 2)
			continue
		if(istype(commconsole.loc,/turf))
			break

	for(var/obj/item/circuitboard/computer/communications/commboard in item_list)
		if(commboard.z == 2)
			continue
		if(istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/storage))
			break

	for(var/mob/living/silicon/ai/shuttlecaller in player_list)
		if(shuttlecaller.z == 2)
			continue
		if(!shuttlecaller.stat && shuttlecaller.client && istype(shuttlecaller.loc,/turf))
			break

	if(explosive)
		spawn(10)
			explosion(src.loc, 3, 6, 12, 15)

	for(var/obj/machinery/ai_status_display/O in machines)
		spawn( 0 )
		O.mode = 2
		if (istype(loc, /obj/item/device/aicard))
			loc.icon_state = "aicard-404"

	return ..(gibbed,"gives one shrill beep before falling lifeless.")
