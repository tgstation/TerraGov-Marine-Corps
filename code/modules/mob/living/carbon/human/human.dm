//#define DEBUG_HUMAN_ARMOR

/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"
	hud_possible = list(HEALTH_HUD,STATUS_HUD, STATUS_HUD_OOC, STATUS_HUD_XENO_INFECTION,ID_HUD,WANTED_HUD,IMPLOYAL_HUD,IMPCHEM_HUD,IMPTRACK_HUD, SPECIALROLE_HUD, SQUAD_HUD, STATUS_HUD_OBSERVER_INFECTION, ORDER_HUD)
	var/embedded_flag	  //To check if we've need to roll for damage on movement while an item is imbedded in us.


/mob/living/carbon/human/Initialize()
	verbs += /mob/living/proc/lay_down
	b_type = pick(7;"O-", 38;"O+", 6;"A-", 34;"A+", 2;"B-", 9;"B+", 1;"AB-", 3;"AB+")
	blood_type = b_type

	if(!species)
		set_species()

	var/datum/reagents/R = new /datum/reagents(1000)
	reagents = R
	R.my_atom = src

	. = ..()

	GLOB.human_mob_list += src
	GLOB.alive_human_list += src
	round_statistics.total_humans_created++

	var/datum/action/skill/toggle_orders/toggle_orders_action = new
	toggle_orders_action.give_action(src)
	var/datum/action/skill/issue_order/move/issue_order_move = new
	issue_order_move.give_action(src)
	var/datum/action/skill/issue_order/hold/issue_order_hold = new
	issue_order_hold.give_action(src)
	var/datum/action/skill/issue_order/focus/issue_order_focus = new
	issue_order_focus.give_action(src)

	//makes order hud visible
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_ORDER]
	H.add_hud_to(usr)

	randomize_appearance()

	RegisterSignal(src, list(COMSIG_KB_QUICKEQUIP, COMSIG_CLICK_QUICKEQUIP), .proc/do_quick_equip)
	RegisterSignal(src, COMSIG_KB_HOLSTER, .proc/do_holster)
	RegisterSignal(src, COMSIG_KB_UNIQUEACTION, .proc/do_unique_action)

/mob/living/carbon/human/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Set Species"] = "?_src_=vars;[HrefToken()];setspecies=[REF(src)]"
	.["Drop Everything"] = "?_src_=vars;[HrefToken()];dropeverything=[REF(src)]"
	.["Copy Outfit"] = "?_src_=vars;[HrefToken()];copyoutfit=[REF(src)]"


/mob/living/carbon/human/prepare_huds()
	..()
	//updating all the mob's hud images
	med_hud_set_health()
	med_hud_set_status()
	sec_hud_set_ID()
	sec_hud_set_implants()
	sec_hud_set_security_status()
	hud_set_squad()
	hud_set_order()
	//and display them
	add_to_all_mob_huds()



/mob/living/carbon/human/Destroy()
	if(assigned_squad)
		SSdirection.stop_tracking(assigned_squad.tracking_id, src) // failsafe to ensure they're definite not in the list
	assigned_squad?.clean_marine_from_squad(src,FALSE)
	remove_from_all_mob_huds()
	GLOB.human_mob_list -= src
	GLOB.alive_human_list -= src
	GLOB.dead_human_list -= src
	return ..()

/mob/living/carbon/human/Stat()
	. = ..()

	if(statpanel("Stats"))
		var/eta_status = SSevacuation?.get_status_panel_eta()
		if(eta_status)
			stat("Evacuation in:", eta_status)

		if(internal)
			stat("Internal Atmosphere Info", internal.name)
			stat("Tank Pressure", internal.pressure)
			stat("Distribution Pressure", internal.distribute_pressure)

		if(assigned_squad)
			if(assigned_squad.primary_objective)
				stat("Primary Objective: ", assigned_squad.primary_objective)
			if(assigned_squad.secondary_objective)
				stat("Secondary Objective: ", assigned_squad.secondary_objective)

		if(mobility_aura)
			stat(null, "You are affected by a MOVE order.")
		if(protection_aura)
			stat(null, "You are affected by a HOLD order.")
		if(marksman_aura)
			stat(null, "You are affected by a FOCUS order.")

/mob/living/carbon/human/ex_act(severity)
	flash_eyes()

	var/b_loss = null
	var/f_loss = null
	var/armor = max(0, 1 - getarmor(null, "bomb"))
	switch(severity)
		if(1)
			b_loss += rand(160, 200) * armor	//Probably instant death
			f_loss += rand(160, 200) * armor	//Probably instant death

			var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
			throw_at(target, 200, 4)

			if(!istype(wear_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 60 * armor
				ear_deaf += 240 * armor

			adjust_stagger(12 * armor)
			add_slowdown(round(12 * armor,0.1))
			KnockOut(8 * armor) //This should kill you outright, so if you're somehow alive I don't feel too bad if you get KOed

		if(2)
			b_loss += (rand(80, 100) * armor)	//Ouchie time. Armor makes it survivable
			f_loss += (rand(80, 100) * armor)	//Ouchie time. Armor makes it survivable

			if(!istype(wear_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 30 * armor
				ear_deaf += 120 * armor

			adjust_stagger(6 * armor)
			add_slowdown(round(6 * armor,0.1))
			KnockDown(4 * armor)

		if(3)
			b_loss += (rand(40, 50) * armor)
			f_loss += (rand(40, 50) * armor)

			if(!istype(wear_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 10 * armor
				ear_deaf += 30 * armor

			adjust_stagger(3 * armor)
			add_slowdown(round(3 * armor,0.1))
			KnockDown(2 * armor)

	var/update = 0
	#ifdef DEBUG_HUMAN_ARMOR
	to_chat(src, "DEBUG EX_ACT: armor: [armor], b_loss: [b_loss], f_loss: [f_loss]")
	#endif
	//Focus half the blast on one organ
	var/datum/limb/take_blast = pick(limbs)
	update |= take_blast.take_damage_limb(b_loss * 0.5, f_loss * 0.5)

	//Distribute the remaining half all limbs equally
	b_loss *= 0.5
	f_loss *= 0.5

	for(var/datum/limb/temp in limbs)
		switch(temp.name)
			if("head")
				update |= temp.take_damage_limb(b_loss * 0.2, f_loss * 0.2)
			if("chest")
				update |= temp.take_damage_limb(b_loss * 0.4, f_loss * 0.4)
			if("l_arm")
				update |= temp.take_damage_limb(b_loss * 0.05, f_loss * 0.05)
			if("r_arm")
				update |= temp.take_damage_limb(b_loss * 0.05, f_loss * 0.05)
			if("l_leg")
				update |= temp.take_damage_limb(b_loss * 0.05, f_loss * 0.05)
			if("r_leg")
				update |= temp.take_damage_limb(b_loss * 0.05, f_loss * 0.05)
			if("r_foot")
				update |= temp.take_damage_limb(b_loss * 0.05, f_loss * 0.05)
			if("l_foot")
				update |= temp.take_damage_limb(b_loss * 0.05, f_loss * 0.05)
			if("r_arm")
				update |= temp.take_damage_limb(b_loss * 0.05, f_loss * 0.05)
			if("l_arm")
				update |= temp.take_damage_limb(b_loss * 0.05, f_loss * 0.05)
	if(update)	UpdateDamageIcon()
	return 1


/mob/living/carbon/human/attack_animal(mob/living/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 25, 1)
		visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>")
		log_combat(M, src, "attacked")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/datum/limb/affecting = get_limb(ran_zone(dam_zone))
		var/armor = run_armor_check(affecting, "melee")
		apply_damage(damage, BRUTE, affecting, armor)
		if(armor >= 1) //Complete negation
			return


/mob/living/carbon/human/proc/implant_loyalty(mob/living/carbon/human/M, override = FALSE) // Won't override by default.
	var/obj/item/implant/loyalty/L = new/obj/item/implant/loyalty(M)
	L.imp_in = M
	L.implanted = 1
	var/datum/limb/affected = M.get_limb("head")
	affected.implants += L
	L.part = affected

/mob/living/carbon/human/proc/is_loyalty_implanted(mob/living/carbon/human/M)
	for(var/L in M.contents)
		if(istype(L, /obj/item/implant/loyalty))
			for(var/datum/limb/O in M.limbs)
				if(L in O.implants)
					return 1
	return 0



/mob/living/carbon/human/show_inv(mob/living/user)
	var/obj/item/clothing/under/suit
	if(istype(w_uniform, /obj/item/clothing/under))
		suit = w_uniform

	user.set_interaction(src)
	var/dat = {"
	<BR><B>Head(Mask):</B> <A href='?src=[REF(src)];item=[SLOT_WEAR_MASK]'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=[REF(src)];item=[SLOT_L_HAND]'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=[REF(src)];item=[SLOT_R_HAND]'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Gloves:</B> <A href='?src=[REF(src)];item=[SLOT_GLOVES]'>[(gloves ? gloves : "Nothing")]</A>
	<BR><B>Eyes:</B> <A href='?src=[REF(src)];item=[SLOT_GLASSES]'>[(glasses ? glasses : "Nothing")]</A>
	<BR><B>Left Ear:</B> <A href='?src=[REF(src)];item=[SLOT_EARS]'>[(wear_ear ? wear_ear : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=[REF(src)];item=[SLOT_HEAD]'>[(head ? head : "Nothing")]</A>
	<BR><B>Shoes:</B> <A href='?src=[REF(src)];item=[SLOT_SHOES]'>[(shoes ? shoes : "Nothing")]</A>
	<BR><B>Belt:</B> <A href='?src=[REF(src)];item=[SLOT_BELT]'>[(belt ? belt : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(belt, /obj/item/tank) && !internal) ? " <A href='?src=[REF(src)];internal=1'>Set Internal</A>" : "")]
	<BR><B>Uniform:</B> <A href='?src=[REF(src)];item=[SLOT_W_UNIFORM]'>[(w_uniform ? w_uniform : "Nothing")]</A> [(suit) ? ((suit.has_sensor == 1) ? " <A href='?src=[REF(src)];sensor=1'>Sensors</A>" : "") : ""]
	<BR><B>(Exo)Suit:</B> <A href='?src=[REF(src)];item=[SLOT_WEAR_SUIT]'>[(wear_suit ? wear_suit : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=[REF(src)];item=[SLOT_BACK]'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/tank) && !internal) ? " <A href='?src=[REF(src)];internal=1'>Set Internal</A>" : "")]
	<BR><B>ID:</B> <A href='?src=[REF(src)];item=[SLOT_WEAR_ID]'>[(wear_id ? wear_id : "Nothing")]</A>
	<BR><B>Suit Storage:</B> <A href='?src=[REF(src)];item=[SLOT_S_STORE]'>[(s_store ? s_store : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(s_store, /obj/item/tank) && !internal) ? " <A href='?src=[REF(src)];internal=1'>Set Internal</A>" : "")]
	<BR>
	[handcuffed ? "<BR><A href='?src=[REF(src)];item=[SLOT_HANDCUFFED]'>Handcuffed</A>" : ""]
	[legcuffed ? "<BR><A href='?src=[REF(src)];item=[SLOT_LEGCUFFED]'>Legcuffed</A>" : ""]
	[suit?.hastie ? "<BR><A href='?src=[REF(src)];tie=1'>Remove Accessory</A>" : ""]
	[internal ? "<BR><A href='?src=[REF(src)];internal=1'>Remove Internal</A>" : ""]
	<BR><A href='?src=[REF(src)];splints=1'>Remove Splints</A>
	<BR><A href='?src=[REF(src)];pockets=1'>Empty Pockets</A>
	<BR>
	<BR><A href='?src=[REF(user)];refresh=1'>Refresh</A>
	<BR><A href='?src=[REF(user)];mach_close=mob[name]'>Close</A>
	<BR>"}

	var/datum/browser/browser = new(user, "mob[name]", "<div align='center'>[name]</div>", 380, 540)
	browser.set_content(dat)
	browser.open(FALSE)

// called when something steps onto a human
// this handles mulebots and vehicles
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	if(istype(AM, /obj/machinery/bot/mulebot))
		var/obj/machinery/bot/mulebot/MB = AM
		MB.RunOver(src)

	if(istype(AM, /obj/vehicle))
		var/obj/vehicle/V = AM
		V.RunOver(src)


//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/card/id/id = wear_id
	if (istype(id))
		. = id.assignment
	else
		return if_no_id
	if (!.)
		. = if_no_job
	return

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/card/id/id = wear_id
	if (istype(id))
		. = id.registered_name
	else
		return if_no_id
	return

//gets paygrade from ID
//paygrade is a user's actual rank, as defined on their ID.  size 1 returns an abbreviation, size 0 returns the full rank name, the third input is used to override what is returned if no paygrade is assigned.
/mob/living/carbon/human/get_paygrade(size = 1)
	if(species.show_paygrade)
		var/obj/item/card/id/id = wear_id
		if(istype(id))
			return get_paygrades(id.paygrade, size, gender)
	return ""


//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/get_visible_name()
	if( wear_mask && (wear_mask.flags_inv_hide & HIDEFACE) )	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if( head && (head.flags_inv_hide & HIDEFACE) )
		return get_id_name("Unknown")		//Likewise for hats
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/datum/limb/head/head = get_limb("head")
	if( !head || head.disfigured || (head.limb_status & LIMB_DESTROYED) || !real_name )	//disfigured. use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	. = if_no_id
	if(wear_id)
		var/obj/item/card/id/I = wear_id.GetID()
		if(I)
			return I.registered_name
	return

//Gets ID card from a human. If hand_first is false the one in the id slot is prioritized, otherwise inventory slots go first.
/mob/living/carbon/human/get_idcard(hand_first = TRUE)
	//Check hands
	var/obj/item/card/id/id_card
	var/obj/item/held_item
	held_item = get_active_held_item()
	if(held_item) //Check active hand
		id_card = held_item.GetID()
	if(!id_card) //If there is no id, check the other hand
		held_item = get_inactive_held_item()
		if(held_item)
			id_card = held_item.GetID()

	if(id_card)
		if(hand_first)
			return id_card
		else
			. = id_card

	//Check inventory slots
	if(wear_id)
		id_card = wear_id.GetID()
		if(id_card)
			return id_card
	else if(belt)
		id_card = belt.GetID()
		if(id_card)
			return id_card

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/base_siemens_coeff = 1.0, var/def_zone = null)
	if(status_flags & GODMODE)	return 0	//godmode

	if (!def_zone)
		def_zone = pick("l_hand", "r_hand")

	var/datum/limb/affected_organ = get_limb(check_zone(def_zone))
	var/siemens_coeff = base_siemens_coeff * get_siemens_coefficient_organ(affected_organ)

	return ..(shock_damage, source, siemens_coeff, def_zone)


/mob/living/carbon/human/Topic(href, href_list)
	if (href_list["refresh"])
		if(interactee&&(in_range(src, usr)))
			show_inv(interactee)

	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_interaction()
		src << browse(null, t1)


	if (href_list["item"])
		var/slot = text2num(href_list["item"])
		if(!usr.incapacitated() && Adjacent(usr))
			if(slot == SLOT_WEAR_ID)
				if(istype(wear_id, /obj/item/card/id/dogtag))
					var/obj/item/card/id/dogtag/DT = wear_id
					if(!DT.dogtag_taken)
						if(stat == DEAD)
							to_chat(usr, "<span class='notice'>You take [src]'s information tag, leaving the ID tag</span>")
							DT.dogtag_taken = TRUE
							DT.icon_state = "dogtag_taken"
							var/obj/item/dogtag/D = new(loc)
							D.fallen_names = list(DT.registered_name)
							D.fallen_assignements = list(DT.assignment)
							usr.put_in_hands(D)
						else
							to_chat(usr, "<span class='warning'>You can't take a dogtag's information tag while its owner is alive.</span>")
					else
						to_chat(usr, "<span class='warning'>Someone's already taken [src]'s information tag.</span>")
					return
			//police skill lets you strip multiple items from someone at once.
			if(!usr.action_busy || (!usr.mind || !usr.mind.cm_skills || usr.mind.cm_skills.police >= SKILL_POLICE_MP))
				var/obj/item/what = get_item_by_slot(slot)
				if(what)
					usr.stripPanelUnequip(what,src,slot)
				else
					what = usr.get_active_held_item()
					usr.stripPanelEquip(what,src,slot)

	if(href_list["pockets"])

		if(!usr.action_busy)
			var/obj/item/place_item = usr.get_active_held_item() // Item to place in the pocket, if it's empty

			var/placing = FALSE

			if(place_item && !(place_item.flags_item & ITEM_ABSTRACT) && (place_item.mob_can_equip(src, SLOT_L_STORE, TRUE) || place_item.mob_can_equip(src, SLOT_R_STORE, TRUE)))
				to_chat(usr, "<span class='notice'>You try to place [place_item] into [src]'s pocket.</span>")
				placing = TRUE
			else
				to_chat(usr, "<span class='notice'>You try to empty [src]'s pockets.</span>")

			if(do_mob(usr, src, POCKET_STRIP_DELAY))
				if(placing)
					if(place_item && place_item == usr.get_active_held_item())
						if(place_item.mob_can_equip(src, SLOT_R_STORE, TRUE))
							dropItemToGround(place_item)
							equip_to_slot_if_possible(place_item, SLOT_R_STORE, 1, 0, 1)
						if(place_item.mob_can_equip(src, SLOT_L_STORE, TRUE))
							dropItemToGround(place_item)
							equip_to_slot_if_possible(place_item, SLOT_L_STORE, 1, 0, 1)

				else
					if(r_store || l_store)
						if(r_store && !(r_store.flags_item & NODROP))
							dropItemToGround(r_store)
						if(l_store && !(l_store.flags_item & NODROP))
							dropItemToGround(l_store)
					else
						to_chat(usr, "<span class='notice'>[src]'s pockets are empty.</span>")


				// Update strip window
				if(usr.interactee == src && Adjacent(usr))
					show_inv(usr)


	if(href_list["internal"])

		if(!usr.action_busy)
			log_combat(usr, src, "attempted to toggle internals")
			if(internal)
				usr.visible_message("<span class='danger'>[usr] is trying to disable [src]'s internals</span>", null, null, 3)
			else
				usr.visible_message("<span class='danger'>[usr] is trying to enable [src]'s internals.</span>", null, null, 3)

			if(do_mob(usr, src, POCKET_STRIP_DELAY, BUSY_ICON_GENERIC))
				if (internal)
					internal = null
					if (hud_used && hud_used.internals)
						hud_used.internals.icon_state = "internal0"
					visible_message("[src] is no longer running on internals.", null, null, 1)
				else
					if(istype(wear_mask, /obj/item/clothing/mask))
						if (istype(back, /obj/item/tank))
							internal = back
						else if (istype(s_store, /obj/item/tank))
							internal = s_store
						else if (istype(belt, /obj/item/tank))
							internal = belt
						if (internal)
							visible_message("<span class='notice'>[src] is now running on internals.</span>", null, null, 1)
							if (hud_used && hud_used.internals)
								hud_used.internals.icon_state = "internal1"

				// Update strip window
				if(usr.interactee == src && Adjacent(usr))
					show_inv(usr)



	if(href_list["splints"])

		if(!usr.action_busy)
			var/count = 0
			for(var/X in limbs)
				var/datum/limb/E = X
				if(E.limb_status & LIMB_SPLINTED)
					count = 1
					break
			if(count)
				log_combat(usr, src, "attempted to remove splints")

				if(do_mob(usr, src, HUMAN_STRIP_DELAY, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
					var/limbcount = 0
					for(var/organ in list("l_leg","r_leg","l_arm","r_arm","r_hand","l_hand","r_foot","l_foot","chest","head","groin"))
						var/datum/limb/o = get_limb(organ)
						if (o && o.limb_status & LIMB_SPLINTED)
							o.limb_status &= ~LIMB_SPLINTED
							limbcount++
					if(limbcount)
						new /obj/item/stack/medical/splint(loc, limbcount)

	if(href_list["tie"])
		if(!usr.action_busy)
			if(w_uniform && istype(w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = w_uniform
				if(U.hastie)
					log_combat(usr, src, "attempted to remove accessory ([U.hastie])")
					if(istype(U.hastie, /obj/item/clothing/tie/holobadge) || istype(U.hastie, /obj/item/clothing/tie/medal))
						visible_message("<span class='danger'>[usr] tears off \the [U.hastie] from [src]'s [U]!</span>", null, null, 5)
					else
						visible_message("<span class='danger'>[usr] is trying to take off \a [U.hastie] from [src]'s [U]!</span>", null, null, 5)
						if(do_mob(usr, src, HUMAN_STRIP_DELAY, BUSY_ICON_HOSTILE))
							if(U == w_uniform && U.hastie)
								U.remove_accessory(usr)

	if(href_list["sensor"])
		if(!usr.action_busy)

			log_combat(usr, src, "attempted to toggle sensors")
			var/obj/item/clothing/under/U = w_uniform
			if(U.has_sensor >= 2)
				to_chat(usr, "The controls are locked.")
			else
				var/oldsens = U.has_sensor
				visible_message("<span class='danger'>[usr] is trying to modify [src]'s sensors!</span>", null, null, 4)
				if(do_mob(usr, src, HUMAN_STRIP_DELAY, BUSY_ICON_GENERIC, BUSY_ICON_GENERIC))
					if(U == w_uniform)
						if(U.has_sensor >= 2)
							to_chat(usr, "The controls are locked.")
						else if(U.has_sensor == oldsens)
							U.set_sensors(usr)


	if (href_list["squadfireteam"])
		if(!usr.incapacitated() && get_dist(usr, src) <= 7 && hasHUD(usr,"squadleader"))
			var/mob/living/carbon/human/H = usr
			if(mind)
				var/obj/item/card/id/ID = get_idcard()
				if(ID && (ID.rank in JOBS_MARINES))//still a marine, with an ID.
					if(assigned_squad == H.assigned_squad) //still same squad
						var/newfireteam = input(usr, "Assign this marine to a fireteam.", "Fire Team Assignment") as null|anything in list("None", "Fire Team 1", "Fire Team 2", "Fire Team 3")
						if(H.incapacitated() || get_dist(H, src) > 7 || !hasHUD(H,"squadleader")) return
						ID = get_idcard()
						if(ID && ID.rank in JOBS_MARINES)//still a marine with an ID
							if(assigned_squad == H.assigned_squad) //still same squad
								switch(newfireteam)
									if("None") ID.assigned_fireteam = 0
									if("Fire Team 1") ID.assigned_fireteam = 1
									if("Fire Team 2") ID.assigned_fireteam = 2
									if("Fire Team 3") ID.assigned_fireteam = 3
									else return
								hud_set_squad()


	if (href_list["criminal"])
		if(hasHUD(usr,"security"))

			var/modified = 0
			var/perpname = "wot"
			if(wear_id)
				var/obj/item/card/id/I = wear_id.GetID()
				if(I)
					perpname = I.registered_name
				else
					perpname = name
			else
				perpname = name

			if(perpname)
				for (var/datum/data/record/E in GLOB.datacore.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in GLOB.datacore.security)
							if (R.fields["id"] == E.fields["id"])

								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Released", "Cancel")

								if(hasHUD(usr, "security"))
									if(setcriminal != "Cancel")
										R.fields["criminal"] = setcriminal
										modified = 1
										sec_hud_set_security_status()


			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if (href_list["secrecord"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
			else
				perpname = src.name
			for (var/datum/data/record/E in GLOB.datacore.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.datacore.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
								to_chat(usr, "<b>Minor Crimes:</b> [R.fields["mi_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_crim_d"]]")
								to_chat(usr, "<b>Major Crimes:</b> [R.fields["ma_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_crim_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=\ref[src];secrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if (href_list["secrecordComment"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
			else
				perpname = src.name
			for (var/datum/data/record/E in GLOB.datacore.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.datacore.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, text("[]", R.fields[text("com_[]", counter)]))
									counter++
								if (counter == 1)
									to_chat(usr, "No comment found")
								to_chat(usr, "<a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if (href_list["secrecordadd"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
			else
				perpname = src.name
			for (var/datum/data/record/E in GLOB.datacore.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.datacore.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								var/t1 = copytext(sanitize(input("Add Comment:", "Sec. records", null, null)  as message),1,MAX_MESSAGE_LEN)
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"security")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [GAME_YEAR]<BR>[t1]")

	if (href_list["medical"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/modified = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
			else
				perpname = src.name

			for (var/datum/data/record/E in GLOB.datacore.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.datacore.general)
						if (R.fields["id"] == E.fields["id"])

							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")

							if(hasHUD(usr,"medical"))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1

									spawn()
										if(istype(usr,/mob/living/carbon/human))
											var/mob/living/carbon/human/U = usr
											U.handle_regular_hud_updates()

			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if (href_list["medrecord"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
			else
				perpname = src.name
			for (var/datum/data/record/E in GLOB.datacore.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.datacore.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Blood Type:</b> [R.fields["b_type"]]")
								to_chat(usr, "<b>DNA:</b> [R.fields["b_dna"]]")
								to_chat(usr, "<b>Minor Disabilities:</b> [R.fields["mi_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_dis_d"]]")
								to_chat(usr, "<b>Major Disabilities:</b> [R.fields["ma_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_dis_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=\ref[src];medrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if (href_list["medrecordComment"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
			else
				perpname = src.name
			for (var/datum/data/record/E in GLOB.datacore.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.datacore.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, text("[]", R.fields[text("com_[]", counter)]))
									counter++
								if (counter == 1)
									to_chat(usr, "No comment found")
								to_chat(usr, "<a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if (href_list["medrecordadd"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
			else
				perpname = src.name
			for (var/datum/data/record/E in GLOB.datacore.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.datacore.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								var/t1 = copytext(sanitize(input("Add Comment:", "Med. records", null, null)  as message),1,MAX_MESSAGE_LEN)
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"medical")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [GAME_YEAR]<BR>[t1]")

	if (href_list["medholocard"])
		if(!species?.count_human)
			to_chat(usr, "<span class='warning'>Triage holocards only works on organic humanoid entities.</span>")
			return
		var/newcolor = input("Choose a triage holo card to add to the patient:", "Triage holo card", null, null) in list("black", "red", "orange", "none")
		if(!newcolor)
			return
		if(get_dist(usr, src) > 7)
			to_chat(usr, "<span class='warning'>[src] is too far away.</span>")
			return
		if(newcolor == "none")
			if(!holo_card_color)
				return
			holo_card_color = null
			to_chat(usr, "<span class='notice'>You remove the holo card on [src].</span>")
		else if(newcolor != holo_card_color)
			holo_card_color = newcolor
			to_chat(usr, "<span class='notice'>You add a [newcolor] holo card on [src].</span>")
		update_targeted()

	if (href_list["scanreport"])
		if(hasHUD(usr,"medical"))
			if(!ishuman(src))
				to_chat(usr, "<span class='warning'>This only works on humanoids.</span>")
				return
			if(get_dist(usr, src) > 7)
				to_chat(usr, "<span class='warning'>[src] is too far away.</span>")
				return

			for(var/datum/data/record/R in GLOB.datacore.medical)
				if (R.fields["name"] == real_name)
					if(R.fields["last_scan_time"] && R.fields["last_scan_result"])
						var/datum/browser/popup = new(usr, "scanresults", "<div align='center'>Last Scan Result</div>", 430, 600)
						popup.set_content(R.fields["last_scan_result"])
						popup.open(FALSE)
					break

	if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		if(istype(I))
			I.examine(usr)

	return ..()

///get_eye_protection()
///Returns a number between -1 to 2
/mob/living/carbon/human/get_eye_protection()
	var/number = 0

	if(!species.has_organ["eyes"]) return 2//No eyes, can't hurt them.

	var/datum/internal_organ/eyes/I = internal_organs_by_name["eyes"]
	if(I)
		if(I.cut_away)
			return 2
		if(I.robotic == ORGAN_ROBOT)
			return 2
	else
		return 2

	if(istype(head, /obj/item/clothing))
		var/obj/item/clothing/C = head
		number += C.eye_protection
	if(istype(wear_mask))
		number += wear_mask.eye_protection
	if(glasses)
		number += glasses.eye_protection

	return number


/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.flags_item & ITEM_ABSTRACT)) || (src.r_hand && !( src.r_hand.flags_item & ITEM_ABSTRACT)) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.wear_ear || src.gloves)))
		return 1

	if( (src.l_hand && !(src.l_hand.flags_item & ITEM_ABSTRACT)) || (src.r_hand && !(src.r_hand.flags_item & ITEM_ABSTRACT)) )
		return 1

	return 0

/mob/living/carbon/human/get_species()

	if(!species)
		set_species()

	return species.name


/mob/living/carbon/human/proc/play_xylophone()
	visible_message("<span class='warning'> [src] begins playing his ribcage like a xylophone. It's quite spooky.</span>","<span class='notice'> You begin to play a spooky refrain on your ribcage.</span>","<span class='warning'> You hear a spooky xylophone melody.</span>")
	var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
	playsound(loc, song, 25, 1)


/mob/living/carbon/human/proc/get_visible_gender()
	if(wear_suit && wear_suit.flags_inv_hide & HIDEJUMPSUIT && ((head && head.flags_inv_hide & HIDEMASK) || wear_mask))
		return NEUTER
	return gender

/mob/living/carbon/human/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n


/mob/living/carbon/human/revive()
	for (var/datum/limb/O in limbs)
		if(O.limb_status & LIMB_ROBOT)
			O.limb_status = LIMB_ROBOT
		else
			O.limb_status = NONE
		O.perma_injury = 0
		O.germ_level = 0
		O.wounds.Cut()
		O.heal_damage(1000,1000,1,1)
		O.reset_limb_surgeries()

	var/datum/limb/head/h = get_limb("head")
	h.disfigured = 0
	name = get_visible_name()

	if(species && !(species.species_flags & NO_BLOOD))
		restore_blood()

	//try to find the brain player in the decapitated head and put them back in control of the human
	if(!client && !mind) //if another player took control of the human, we don't want to kick them out.
		for (var/obj/item/limb/head/H in GLOB.item_list)
			if(H.brainmob)
				if(H.brainmob.real_name == src.real_name)
					if(H.brainmob.mind)
						H.brainmob.mind.transfer_to(src)
						qdel(H)

	for(var/datum/internal_organ/I in internal_organs)
		I.damage = 0

	undefibbable = FALSE
	
	return ..()

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/datum/internal_organ/lungs/L = internal_organs_by_name["lungs"]
	return L && L.is_bruised()

/mob/living/carbon/human/proc/rupture_lung()
	var/datum/internal_organ/lungs/L = internal_organs_by_name["lungs"]

	if(L && !L.is_bruised())
		src.custom_pain("You feel a stabbing pain in your chest!", 1)
		L.damage = L.min_bruised_damage



/mob/living/carbon/human/get_visible_implants(var/class = 0)

	var/list/visible_implants = list()
	for(var/datum/limb/organ in limbs)
		for(var/obj/item/O in organ.implants)
			if(!istype(O,/obj/item/implant) && (O.w_class > class) && !istype(O,/obj/item/shard/shrapnel))
				visible_implants += O

	return(visible_implants)

/mob/living/carbon/human/proc/handle_embedded_objects()

	for(var/datum/limb/organ in limbs)
		if(organ.limb_status & LIMB_SPLINTED || organ.limb_status & LIMB_STABILIZED || (m_intent == MOVE_INTENT_WALK && !pulledby) ) //Splints prevent movement. Walking stops shrapnel from harming organs unless being pulled.
			continue
		for(var/obj/item/O in organ.implants)
			if(!istype(O,/obj/item/implant) && prob(4)) //Moving with things stuck in you could be bad.
				// All kinds of embedded objects cause bleeding.
				var/msg = null
				switch(rand(1,3))
					if(1)
						msg ="<span class='warning'>A spike of pain jolts your [organ.display_name] as you bump [O] inside.</span>"
					if(2)
						msg ="<span class='warning'>Your movement jostles [O] in your [organ.display_name] painfully.</span>"
					if(3)
						msg ="<span class='warning'>[O] in your [organ.display_name] twists painfully as you move.</span>"
				to_chat(src, msg)

				organ.take_damage_limb(rand(1, 2))
				if(!(organ.limb_status & LIMB_ROBOT) && !(species.species_flags & NO_BLOOD)) //There is no blood in protheses.
					organ.limb_status |= LIMB_BLEEDING
					if(prob(10)) src.adjustToxLoss(1)

/mob/living/carbon/human/verb/check_pulse()
	set category = "Object"
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.stat > 0 || usr.restrained() || !isliving(usr)) return

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message("<span class='notice'>[usr] kneels down, puts [usr.p_their()] hand on [src]'s wrist and begins counting their pulse.</span>",\
		"<span class='notice'>You begin counting [src]'s pulse...</span>", null, 3)
	else
		usr.visible_message("<span class='notice'>[usr] begins counting their pulse.</span>",\
		"<span class='notice'>You begin counting your pulse...</span>", null, 3)

	if(src.pulse)
		to_chat(usr, "<span class='notice'>[self ? "You have a" : "[src] has a"] pulse! Counting...</span>")
	else
		to_chat(usr, "<span class='warning'> [src] has no pulse!</span>"	)
		return

	to_chat(usr, "Don't move until counting is finished.")
	var/time = world.time
	sleep(60)
	if(usr.last_move_time >= time)	//checks if our mob has moved during the sleep()
		to_chat(usr, "You moved while counting. Try again.")
	else
		to_chat(usr, "<span class='notice'>[self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].</span>")

/mob/living/carbon/human/verb/view_manifest()
	set name = "View Crew Manifest"
	set category = "IC"

	var/dat = GLOB.datacore.get_manifest()

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Crew Manifest</div>", 370, 420)
	popup.set_content(dat)
	popup.open(FALSE)


/mob/living/carbon/human/species
	var/race = null

/mob/living/carbon/human/species/Initialize()
	. = ..()
	set_species(race)

/mob/living/carbon/human/proc/set_species(var/new_species, var/default_colour)

	if(!new_species)
		new_species = "Human"

	if(species)

		if(species.name && species.name == new_species) //we're already that species.
			return
		if(species.language)
			remove_language(species.language)

		if(species.default_language)
			remove_language(species.default_language)

		// Clear out their species abilities.
		species.remove_inherent_verbs(src)

	var/datum/species/oldspecies = species

	species = GLOB.all_species[new_species]

	if(oldspecies)
		//additional things to change when we're no longer that species
		oldspecies.post_species_loss(src)

	species.create_organs(src)

	if(species.language)
		grant_language(species.language)

	if(species.default_language)
		grant_language(species.default_language)
		var/datum/language_holder/H = get_language_holder()
		H.selected_default_language = species.default_language

	if(species.base_color && default_colour)
		//Apply colour.
		r_skin = hex2num(copytext(species.base_color,2,4))
		g_skin = hex2num(copytext(species.base_color,4,6))
		b_skin = hex2num(copytext(species.base_color,6,8))
	else
		r_skin = 0
		g_skin = 0
		b_skin = 0

	if(species.hair_color)
		r_hair = hex2num(copytext(species.hair_color, 2, 4))
		g_hair = hex2num(copytext(species.hair_color, 4, 6))
		b_hair = hex2num(copytext(species.hair_color, 6, 8))

	species.handle_post_spawn(src)

	INVOKE_ASYNC(src, .proc/regenerate_icons)
	INVOKE_ASYNC(src, .proc/update_body)
	INVOKE_ASYNC(src, .proc/restore_blood)

	if(species)
		return 1
	else
		return 0

/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if (src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	if (!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if (src.gloves)
		to_chat(src, "<span class='warning'>Your [src.gloves] are getting in the way.</span>")
		return

	var/turf/T = src.loc
	if (!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, "<span class='warning'>You cannot reach the floor.</span>")
		return

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	if (direction != "Here")
		T = get_step(T,text2dir(direction))
	if (!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.basecolor = (blood_color) ? blood_color : "#A10808"
		W.update_icon()
		W.message = message

/mob/living/carbon/human/reagent_check(datum/reagent/R)
	return species.handle_chemicals(R,src) // if it returns 0, it will run the usual on_mob_life for that reagent. otherwise, it will stop after running handle_chemicals for the species.

/mob/living/carbon/human/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	if(shoes && !override_noslip) // && (shoes.flags_inventory & NOSLIPPING)) // no more slipping if you have shoes on. -spookydonut
		return FALSE
	. = ..()

/mob/living/carbon/human/smokecloak_on()
	var/obj/item/storage/backpack/marine/satchel/scout_cloak/S = back
	if(istype(S) && S.camo_active)
		return FALSE
	return ..()

/mob/living/carbon/human/disable_lights(armor = TRUE, guns = TRUE, flares = TRUE, misc = TRUE, sparks = FALSE, silent = FALSE)
	if(luminosity <= 0)
		return FALSE

	if(sparks)
		var/datum/effect_system/spark_spread/spark_system = new
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start(src)

	var/light_off = 0
	var/goes_out = 0
	if(armor)
		if(istype(wear_suit, /obj/item/clothing/suit/storage/marine))
			var/obj/item/clothing/suit/storage/marine/S = wear_suit
			if(S.turn_off_light(src))
				light_off++
	if(guns)
		for(var/obj/item/weapon/gun/G in contents)
			if(G.turn_off_light(src))
				light_off++
	if(flares)
		for(var/obj/item/flashlight/flare/F in contents)
			if(F.on)
				goes_out++
			F.turn_off(src)
		for(var/obj/item/explosive/grenade/flare/FL in contents)
			if(FL.active)
				goes_out++
			FL.turn_off(src)
	if(misc)
		for(var/obj/item/clothing/head/hardhat/H in contents)
			if(H.turn_off_light(src))
				light_off++
		for(var/obj/item/flashlight/L in contents)
			if(istype(L, /obj/item/flashlight/flare))
				continue
			if(L.turn_off_light(src))
				light_off++
		for(var/obj/item/tool/weldingtool/W in contents)
			if(W.isOn())
				W.toggle()
				goes_out++
		for(var/obj/item/tool/pickaxe/plasmacutter/W in contents)
			if(W.powered)
				W.toggle()
				goes_out++
		for(var/obj/item/tool/match/M in contents)
			M.burn_out(src)
		for(var/obj/item/tool/lighter/Z in contents)
			if(Z.turn_off(src))
				goes_out++
	if(!silent)
		if(goes_out && light_off)
			to_chat(src, "<span class='notice'>Your sources of light short and fizzle out.</span>")
		else if(goes_out)
			if(goes_out > 1)
				to_chat(src, "<span class='notice'>Your sources of light fizzle out.</span>")
			else
				to_chat(src, "<span class='notice'>Your source of light fizzles out.</span>")
		else if(light_off)
			if(light_off > 1)
				to_chat(src, "<span class='notice'>Your sources of light short out.</span>")
			else
				to_chat(src, "<span class='notice'>Your source of light shorts out.</span>")
		return TRUE

/mob/living/carbon/get_standard_pixel_y_offset()
	if(lying)
		return -6
	else
		return initial(pixel_y)


/mob/living/carbon/human/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		return

	sight = initial(sight)
	see_in_dark = species.darksight
	see_invisible = SEE_INVISIBLE_LIVING

	if(glasses)
		var/obj/item/clothing/glasses/G = glasses
		//prescription applies regardless of it the glasses are active
		if(G.active)
			see_in_dark = max(G.darkness_view, see_in_dark)
			sight |= G.vision_flags
			if(G.fullscreen_vision)
				overlay_fullscreen("glasses_vision", G.fullscreen_vision)
			else
				clear_fullscreen("glasses_vision", 0)
			if(G.see_invisible)
				see_invisible = min(G.see_invisible, see_invisible)
		else
			clear_fullscreen("glasses_vision", 0)
	else
		clear_fullscreen("glasses_vision", 0)

/mob/living/carbon/human/get_total_tint()
	. = ..()
	var/obj/item/clothing/C
	if(istype(head, /obj/item/clothing/head))
		C = head
		. += C.tint
	if(istype(wear_mask, /obj/item/clothing/mask))
		C = wear_mask
		. += C.tint
	if(istype(glasses, /obj/item/clothing/glasses))
		C = glasses
		. += C.tint


/mob/living/carbon/human/proc/randomize_appearance()
	if(prob(50))
		gender = FEMALE
		name = pick(GLOB.first_names_female) + " " + pick(GLOB.last_names)
		real_name = name
	else
		gender = MALE
		name = pick(GLOB.first_names_male) + " " + pick(GLOB.last_names)
		real_name = name


	switch(pick(15;"black", 15;"grey", 15;"brown", 15;"lightbrown", 10;"white", 15;"blonde", 15;"red"))
		if("black")
			r_hair = 10
			g_hair = 10
			b_hair = 10
			r_facial = 10
			g_facial = 10
			b_facial = 10
		if("grey")
			r_hair = 50
			g_hair = 50
			b_hair = 50
			r_facial = 50
			g_facial = 50
			b_facial = 50
		if("brown")
			r_hair = 70
			g_hair = 35
			b_hair = 0
			r_facial = 70
			g_facial = 35
			b_facial = 0
		if("lightbrown")
			r_hair = 100
			g_hair = 50
			b_hair = 0
			r_facial = 100
			g_facial = 50
			b_facial = 0
		if("white")
			r_hair = 235
			g_hair = 235
			b_hair = 235
			r_facial = 235
			g_facial = 235
			b_facial = 235
		if("blonde")
			r_hair = 240
			g_hair = 240
			b_hair = 0
			r_facial = 240
			g_facial = 240
			b_facial = 0
		if("red")
			r_hair = 128
			g_hair = 0
			b_hair = 0
			r_facial = 128
			g_facial = 0
			b_facial = 0

	h_style = random_hair_style(gender)

	switch(pick("none", "some"))
		if("none")
			f_style = "Shaved"
		if("some")
			f_style = random_facial_hair_style(gender)

	switch(pick(15;"black", 15;"green", 15;"brown", 15;"blue", 15;"lightblue", 5;"red"))
		if("black")
			r_eyes = 10
			g_eyes = 10
			b_eyes = 10
		if("green")
			r_eyes = 200
			g_eyes = 0
			b_eyes = 0
		if("brown")
			r_eyes = 100
			g_eyes = 50
			b_eyes = 0
		if("blue")
			r_eyes = 0
			g_eyes = 0
			b_eyes = 200
		if("lightblue")
			r_eyes = 0
			g_eyes = 150
			b_eyes = 255
		if("red")
			r_eyes = 220
			g_eyes = 0
			b_eyes = 0

	ethnicity = random_ethnicity()
	body_type = random_body_type()

	age = rand(17, 55)

	update_hair()
	update_body()
	regenerate_icons()


/mob/living/carbon/human/verb/check_skills()
	set category = "IC"
	set name = "Check Skills"

	var/dat
	if(!mind)
		dat += "You have no mind!"
	else if(!mind.cm_skills)
		dat += "You don't have any skills restrictions. Enjoy."
	else
		var/datum/skills/S = mind.cm_skills
		for(var/i = 1 to length(S.values))
			var/index = S.values[i]
			var/value = max(S.values[index], 0)
			dat += "[index]: [value]<br>"

	var/datum/browser/popup = new(src, "skills", "<div align='center'>Skills</div>", 300, 600)
	popup.set_content(dat)
	popup.open(FALSE)



/mob/living/carbon/human/proc/set_rank(rank)
	if(!rank)
		return FALSE

	if(!mind)
		job = rank
		return FALSE

	var/datum/job/J = SSjob.GetJob(rank)
	if(!J)
		return FALSE

	var/datum/outfit/job/O = new J.outfit
	var/id = O.id ? O.id : /obj/item/card/id
	var/obj/item/card/id/I = new id
	var/datum/skills/L = new J.skills_type
	mind.cm_skills = L
	mind.comm_title = J.comm_title

	if(wear_id)
		qdel(wear_id)

	job = rank
	faction = J.faction

	equip_to_slot_or_del(I, SLOT_WEAR_ID)

	SSjob.AssignRole(src, rank)
	O.handle_id(src)

	GLOB.datacore.manifest_update(real_name, real_name, job)

	if(assigned_squad)
		change_squad(assigned_squad.name)

	return TRUE


/mob/living/carbon/human/proc/set_equipment(equipment)
	if(!equipment)
		return FALSE

	var/list/job_paths = subtypesof(/datum/outfit/job)
	var/list/outfits = list()
	for(var/path in job_paths)
		var/datum/outfit/O = path
		if(initial(O.can_be_admin_equipped))
			outfits[initial(O.name)] = path

	for(var/datum/outfit/D in GLOB.custom_outfits)
		outfits[D.name] = D

	if(!(equipment in outfits))
		return FALSE

	var/outfit_type = outfits[equipment]
	var/datum/outfit/O = new outfit_type
	delete_equipment(TRUE)
	equipOutfit(O, FALSE)
	regenerate_icons()

	return TRUE


/mob/living/carbon/human/canUseTopic(atom/movable/AM)
	if(incapacitated())
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(!in_range(AM, src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/human/take_over(mob/M)
	. = ..()

	set_rank(job)

	if(assigned_squad)
		change_squad(assigned_squad.name)


/mob/living/carbon/human/proc/change_squad(squad)
	if(!squad || !(job in JOBS_MARINES))
		return FALSE

	var/datum/squad/S = SSjob.squads[squad]

	if(!mind)
		assigned_squad = S
		return FALSE

	else if(assigned_squad)
		assigned_squad.clean_marine_from_squad(src)
		assigned_squad = null

	var/datum/job/J = SSjob.GetJob(mind.assigned_role)
	var/datum/outfit/job/O = new J.outfit
	O.handle_id(src)

	S.put_marine_in_squad(src)

	//Crew manifest
	for(var/i in GLOB.datacore.general)
		var/datum/data/record/R = i
		if(R.fields["name"] == real_name)
			R.fields["squad"] = S.name
			break

	if(istype(wear_id, /obj/item/card/id))
		var/obj/item/card/id/ID = wear_id
		ID.assigned_fireteam = 0

	//Headset frequency.
	if(istype(wear_ear, /obj/item/radio/headset/almayer/marine))
		var/obj/item/radio/headset/almayer/marine/E = wear_ear
		E.set_frequency(S.radio_freq)
	else
		if(wear_ear)
			dropItemToGround(wear_ear)
		var/obj/item/radio/headset/almayer/marine/E = new
		equip_to_slot_or_del(E, SLOT_EARS)
		E.set_frequency(S.radio_freq)
		update_icons()

	hud_set_squad()

	return TRUE


/mob/living/carbon/human/is_muzzled()
	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return TRUE
	return ..()

/mob/living/carbon/human/fully_replace_character_name(oldname, newname)
	. = ..()
	if(!.)
		return FALSE

	if(istype(wear_id))
		var/obj/item/card/id/C = wear_id
		C.registered_name = real_name
		C.update_label()

	if(!GLOB.datacore.manifest_update(oldname, newname, job))
		GLOB.datacore.manifest_inject(src)

	return TRUE


/mob/living/carbon/human/canUseTopic(atom/movable/AM, proximity = FALSE, dexterity = FALSE)
	. = ..()
	if(!Adjacent(AM) && (AM.loc != src))
		if(!proximity)
			return TRUE
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE


/mob/living/carbon/human/do_camera_update(oldloc, obj/item/radio/headset/almayer/H)
	if(QDELETED(H?.camera) || oldloc == get_turf(src))
		return

	GLOB.cameranet.updatePortableCamera(H.camera)


/mob/living/carbon/human/update_camera_location(oldloc)
	oldloc = get_turf(oldloc)

	if(!wear_ear || !istype(wear_ear, /obj/item/radio/headset/almayer) || oldloc == get_turf(src))
		return

	var/obj/item/radio/headset/almayer/H = wear_ear

	if(QDELETED(H.camera))
		return

	addtimer(CALLBACK(src, .proc/do_camera_update, oldloc, H), 1 SECONDS)