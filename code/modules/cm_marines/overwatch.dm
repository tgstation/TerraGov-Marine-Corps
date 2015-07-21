/obj/machinery/computer/overwatch
	name = "Overwatch Console"
	desc = "State of the art machinery for giving orders to a squad."
	icon_state = "dummy"
	req_access = list(access_sulaco_bridge)

	var/datum/squad/current_squad = null
	var/mob/living/carbon/human/operator = null
	var/state = 0
	var/mob/living/carbon/human/info_from = null

/obj/machinery/computer/overwatch/attackby(var/obj/I as obj, var/mob/user as mob)  //Can't break or disassemble.
	return

/obj/machinery/computer/overwatch/bullet_act(var/obj/item/projectile/Proj) //Can't shoot it
	return

/obj/machinery/computer/overwatch/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/overwatch/attack_paw(var/mob/user as mob) //why monkey why
	return src.attack_hand(user)

/obj/machinery/computer/overwatch/attack_hand(var/mob/user as mob)
	if(..())  //Checks for power outages
		return

	user.set_machine(src)
	var/dat = "<head><title>Overwatch Console</title></head><body>"

	if(!operator)
		dat += "<BR>Operator: <A href='?src=\ref[src];operation=change_operator'>----------</A><BR>"
	else
		dat += "<BR>Operator: <A href='?src=\ref[src];operation=change_operator'>[operator.name]</A>  (<A href='?src=\ref[src];operation=logout'>{Log Out}</A><BR>"

		switch(src.state)
			if(0)
				if(!current_squad) //No squad has been set yet. Pick one.
					dat += "Current Squad: <A href='?src=\ref[src];operation=pick_squad'>----------</A><BR>"
				else
					dat += "Current Squad: <A href='?src=\ref[src];operation=pick_squad'>[current_squad.name] Squad</A><BR><BR>"
					dat += "----------------------<BR><BR>"
					if(current_squad.squad_leader && istype(current_squad.squad_leader))
						dat += "<B>Squad Leader:</B> <A href='?src=\ref[src];operation=get_info;info_from=\ref[current_squad.squad_leader]'>[current_squad.squad_leader.name]<br>"
					else
						dat += "<B>Squad Leader:</B> <font color=red>NONE</font><br><BR>"
					dat += "<B>Primary Objective:</B> "
					if(current_squad.primary_objective)
						dat += "<A href='?src=\ref[src];operation=check_primary'>\[Check\]</A> <A href='?src=\ref[src];operation=set_primary'>\[Set\]</A><BR>"
					else
						dat += "<B><font color=red>NONE!</font></B> <A href='?src=\ref[src];operation=set_prim'>\[Set\]</A><BR>"
					if(current_squad.secondary_objective)
						dat += "<A href='?src=\ref[src];operation=check_secondary'>\[Check\]</A> <A href='?src=\ref[src];operation=set_secondary'>\[Set\]</A><BR>"
					else
						dat += "<B><font color=red>NONE!</font></B> <A href='?src=\ref[src];operation=set_secondary'>\[Set\]</A><BR>"
					dat += "<BR>"
					if(!current_squad.supply_timer)
						if(!current_squad.sbeacon)
							dat += "<b>Supply Drop Status:</b> No beacon located! <A href='?src=\ref[src];operation=refsbeacon'>\[Locate\]</A><BR>"
						else
							dat += "<b>Supply Drop Status:</b> Available - <A href='?src=\ref[src];operation=dropsupply'>\[Drop\]</A><BR>"
					else
						dat += "<b>Supply Drop Status:</b> Launch Tubes Resetting</A><BR>"

					if(!current_squad.bomb_timer)
						if(!current_squad.bbeacon)
							dat += "<b>Orbital Bombardment Status:</b> No beacon located! <A href='?src=\ref[src];operation=refbbeacon'>\[Locate\]</A><BR>"
						else
							dat += "<b>Orbital Bombardment Status:</b> Available - <A href='?src=\ref[src];operation=dropsupply'>\[FIRE!\]</A><BR>"
					else
						dat += "<b>Orbital Bombardment Status:</b> Orbital Cannon Resetting</A><BR><BR>"

					dat += "<BR><BR>----------------------<BR>"
					for(var/mob/living/carbon/human/H in mob_list)
						var/datum/squad/H_squad = get_squad_data_from_card(H) //Only check cards.
						if(!H || !H_squad || H_squad != current_squad || H.z == 0) continue
						var/area/A = get_area(H)
						if(H.stat == CONSCIOUS && H.mind)
							dat += "A href='?src=\ref[src];operation=get_info;info_from=\ref[H]'>[H.name]</a> - ([H.mind.assigned_role]) - Conscious - [sanitize(A.name)]<BR>"
						else if (H.stat == UNCONSCIOUS && H.mind)
							dat += "A href='?src=\ref[src];operation=get_info;info_from=\ref[H]'>[H.name]</a> - ([H.mind.assigned_role]) - Unconscious - [sanitize(A.name)]<BR>"
						else if (H.stat == DEAD && H.mind)
							dat += "A href='?src=\ref[src];operation=get_info;info_from=\ref[H]'>[H.name]</a> - ([H.mind.assigned_role]) - DEAD - [sanitize(A.name)]<BR>"
					dat += "<BR><BR>----------------------<br></body>"
			if(1)//Info screen.
				dat += "Nothing here yet.<BR>"

