/mob/living/carbon/human/Initialize()
	verbs += /mob/living/proc/lay_down
	b_type = pick(7;"O-", 38;"O+", 6;"A-", 34;"A+", 2;"B-", 9;"B+", 1;"AB-", 3;"AB+")
	blood_type = b_type

	if(!species)
		set_species()

	. = ..()

	GLOB.human_mob_list += src
	GLOB.alive_human_list += src
	LAZYADD(GLOB.humans_by_zlevel["[z]"], src)
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, .proc/human_z_changed)

	var/datum/action/skill/toggle_orders/toggle_orders_action = new
	toggle_orders_action.give_action(src)
	var/datum/action/skill/issue_order/move/issue_order_move = new
	issue_order_move.give_action(src)
	var/datum/action/skill/issue_order/hold/issue_order_hold = new
	issue_order_hold.give_action(src)
	var/datum/action/skill/issue_order/focus/issue_order_focus = new
	issue_order_focus.give_action(src)
	var/datum/action/innate/order/attack_order/send_attack_order = new
	send_attack_order.give_action(src)
	var/datum/action/innate/order/defend_order/send_defend_order = new
	send_defend_order.give_action(src)
	var/datum/action/innate/order/retreat_order/send_retreat_order = new
	send_retreat_order.give_action(src)
	var/datum/action/innate/order/rally_order/send_rally_order = new
	send_rally_order.give_action(src)
	var/datum/action/innate/message_squad/screen_orders = new
	screen_orders.give_action(src)


	//makes order hud visible
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_ORDER]
	H.add_hud_to(usr)

	randomize_appearance()

	RegisterSignal(src, COMSIG_ATOM_ACIDSPRAY_ACT, .proc/acid_spray_entered)
	RegisterSignal(src, list(COMSIG_KB_QUICKEQUIP, COMSIG_CLICK_QUICKEQUIP), .proc/async_do_quick_equip)
	RegisterSignal(src, COMSIG_KB_QUICKEQUIPALT, .proc/async_do_quick_equip_alt)
	RegisterSignal(src, COMSIG_KB_UNIQUEACTION, .proc/do_unique_action)
	RegisterSignal(src, COMSIG_GRAB_SELF_ATTACK, .proc/fireman_carry_grabbed) // Fireman carry
	RegisterSignal(src, COMSIG_KB_GIVE, .proc/give_signal_handler)
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HUMAN)
	AddComponent(/datum/component/bump_attack, FALSE, FALSE)
	AddElement(/datum/element/ridable, /datum/component/riding/creature/human)

/mob/living/carbon/human/proc/human_z_changed(datum/source, old_z, new_z)
	SIGNAL_HANDLER
	LAZYREMOVE(GLOB.humans_by_zlevel["[old_z]"], src)
	LAZYADD(GLOB.humans_by_zlevel["[new_z]"], src)

/mob/living/carbon/human/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Drop Everything"] = "?_src_=vars;[HrefToken()];dropeverything=[REF(src)]"
	.["Copy Outfit"] = "?_src_=vars;[HrefToken()];copyoutfit=[REF(src)]"


/mob/living/carbon/human/prepare_huds()
	..()
	//updating all the mob's hud images
	med_pain_set_perceived_health()
	med_hud_set_health()
	med_hud_set_status()
	sec_hud_set_security_status()
	hud_set_order()
	//and display them
	add_to_all_mob_huds()

	GLOB.huds[DATA_HUD_BASIC].add_hud_to(src)
	GLOB.huds[DATA_HUD_XENO_HEART].add_to_hud(src)



/mob/living/carbon/human/Destroy()
	assigned_squad?.remove_from_squad(src)
	remove_from_all_mob_huds()
	GLOB.human_mob_list -= src
	GLOB.alive_human_list -= src
	LAZYREMOVE(GLOB.alive_human_list_faction[faction], src)
	LAZYREMOVE(GLOB.humans_by_zlevel["[z]"], src)
	GLOB.dead_human_list -= src
	return ..()

/mob/living/carbon/human/Stat()
	. = ..()

	if(statpanel("Game"))
		var/eta_status = SSevacuation?.get_status_panel_eta()
		if(eta_status)
			stat("Evacuation in:", eta_status)

		//combat patrol timer
		var/patrol_end_countdown = SSticker.mode?.game_end_countdown()
		if(patrol_end_countdown)
			stat("<b>Combat Patrol timer:</b>", patrol_end_countdown)

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
		var/datum/game_mode/mode = SSticker.mode
		if(mode.flags_round_type & MODE_WIN_POINTS)
			stat("Points needed to win:", mode.win_points_needed)
			stat("Loyalists team points:", LAZYACCESS(mode.points_per_faction, FACTION_TERRAGOV) ? LAZYACCESS(mode.points_per_faction, FACTION_TERRAGOV) : 0)
			stat("Rebels team points:", LAZYACCESS(mode.points_per_faction, FACTION_TERRAGOV_REBEL) ? LAZYACCESS(mode.points_per_faction, FACTION_TERRAGOV_REBEL) : 0)

/mob/living/carbon/human/ex_act(severity)
	if(status_flags & GODMODE)
		return

	var/b_loss = 0
	var/f_loss = 0
	var/armor = get_soft_armor("bomb") * 0.01 //Gets average bomb armor over all limbs.

	switch(severity)
		if(EXPLODE_DEVASTATE)
			b_loss += rand(160, 200)
			f_loss += rand(160, 200)

			if(!istype(wear_ear, /obj/item/clothing/ears/earmuffs))
				adjust_ear_damage(60 - (60 * armor), 240 - (240 * armor))

			adjust_stagger(12 - (12 * armor))
			add_slowdown((120 - round(120 * armor, 1)) * 0.01)

		if(EXPLODE_HEAVY)
			b_loss += rand(80, 100)
			f_loss += rand(80, 100)

			if(!istype(wear_ear, /obj/item/clothing/ears/earmuffs))
				adjust_ear_damage(30 - (30 * armor), 120 - (120 * armor))

			adjust_stagger(6 - (6 * armor))
			add_slowdown((60 - round(60 * armor, 1)) * 0.1)

		if(EXPLODE_LIGHT)
			b_loss += rand(40, 50)
			f_loss += rand(40, 50)

			if(!istype(wear_ear, /obj/item/clothing/ears/earmuffs))
				adjust_ear_damage(10 - (10 * armor), 30 - (30 * armor))

			adjust_stagger(3 - (3 * armor))
			add_slowdown((30 - round(30 * armor, 1)) * 0.1)

	#ifdef DEBUG_HUMAN_ARMOR
	to_chat(world, "DEBUG EX_ACT: armor: [armor * 100], b_loss: [b_loss], f_loss: [f_loss]")
	#endif

	take_overall_damage(b_loss, f_loss, armor * 100, updating_health = TRUE)


/mob/living/carbon/human/attack_animal(mob/living/M as mob)
	if(M.melee_damage == 0)
		M.emote("me", EMOTE_VISIBLE, "[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 25, 1)
		visible_message(span_danger("[M] [M.attacktext] [src]!"))
		log_combat(M, src, "attacked")
		var/damage = M.melee_damage
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/datum/limb/affecting = get_limb(ran_zone(dam_zone))
		var/armor = get_soft_armor("melee", affecting)
		apply_damage(damage, BRUTE, affecting, armor, updating_health = TRUE)

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
	[internal ? "<BR><A href='?src=[REF(src)];internal=1'>Remove Internal</A>" : ""]
	<BR><A href='?src=[REF(src)];splints=1'>Remove Splints</A>
	<BR><A href='?src=[REF(src)];pockets=1'>Empty Pockets</A>
	<BR>
	<BR><A href='?src=[REF(user)];refresh=1'>Refresh</A>
	<BR>"}

	var/datum/browser/browser = new(user, "mob[name]", "<div align='center'>[name]</div>", 380, 540)
	browser.set_content(dat)
	browser.open(FALSE)


//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job")
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
/mob/living/carbon/human/proc/get_authentification_name(if_no_id = "Unknown")
	var/obj/item/card/id/id = wear_id
	if (istype(id))
		return id.registered_name
	else
		return if_no_id

//gets paygrade from ID
//paygrade is a user's actual rank, as defined on their ID.  size 1 returns an abbreviation, size 0 returns the full rank name, the third input is used to override what is returned if no paygrade is assigned.
/mob/living/carbon/human/get_paygrade(size = 1)
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


/mob/living/carbon/human/proc/get_id_name(if_no_id = "Unknown")
	. = if_no_id
	if(!wear_id)
		return

	var/obj/item/card/id/I = get_idcard()
	if(istype(I))
		return I.registered_name

//Gets ID card from a human. If hand_first is false the one in the id slot is prioritized, otherwise inventory slots go first.
/mob/living/carbon/human/get_idcard(hand_first = TRUE)
	var/obj/item/card/id/id_card = get_active_held_item()
	if(!id_card) //If there is no id, check the other hand
		id_card = get_inactive_held_item()

	if(istype(id_card, /obj/item/storage/wallet))
		var/obj/item/storage/wallet/W = id_card
		id_card = W.front_id

	if(istype(id_card) && hand_first)
		return id_card

	if(wear_id)
		id_card = wear_id
	else if(belt)
		id_card = belt

	if(istype(id_card, /obj/item/storage/wallet))
		var/obj/item/storage/wallet/W = id_card
		id_card = W.front_id

	return istype(id_card) ? id_card : null

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(shock_damage, obj/source, base_siemens_coeff = 1.0, def_zone = null)
	if(status_flags & GODMODE)	return 0	//godmode

	if (!def_zone)
		def_zone = pick("l_hand", "r_hand")

	var/datum/limb/affected_organ = get_limb(check_zone(def_zone))
	var/siemens_coeff = base_siemens_coeff * get_siemens_coefficient_organ(affected_organ)

	return ..(shock_damage, source, siemens_coeff, def_zone)


/mob/living/carbon/human/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if (href_list["refresh"])
		if(interactee&&(in_range(src, usr)))
			show_inv(interactee)

	if (href_list["item"])
		var/slot = text2num(href_list["item"])
		if(!usr.incapacitated() && Adjacent(usr))
			if(slot == SLOT_WEAR_ID)
				if(istype(wear_id, /obj/item/card/id/dogtag))
					var/obj/item/card/id/dogtag/DT = wear_id
					if(!DT.dogtag_taken)
						if(stat == DEAD)
							to_chat(usr, span_notice("You take [src]'s information tag, leaving the ID tag"))
							DT.dogtag_taken = TRUE
							DT.icon_state = "dogtag_taken"
							var/obj/item/dogtag/D = new(loc)
							D.fallen_names = list(DT.registered_name)
							D.fallen_assignements = list(DT.assignment)
							usr.put_in_hands(D)
						else
							to_chat(usr, span_warning("You can't take a dogtag's information tag while its owner is alive."))
					else
						to_chat(usr, span_warning("Someone's already taken [src]'s information tag."))
					return
			//police skill lets you strip multiple items from someone at once.
			if(!usr.do_actions || usr.skills.getRating("police") >= SKILL_POLICE_MP)
				var/obj/item/what = get_item_by_slot(slot)
				if(what)
					usr.stripPanelUnequip(what,src,slot)
				else
					what = usr.get_active_held_item()
					usr.stripPanelEquip(what,src,slot)

	if(href_list["pockets"])

		if(!usr.do_actions)
			var/obj/item/place_item = usr.get_active_held_item() // Item to place in the pocket, if it's empty

			var/placing = FALSE

			if(place_item && !(place_item.flags_item & ITEM_ABSTRACT) && (place_item.mob_can_equip(src, SLOT_L_STORE, TRUE) || place_item.mob_can_equip(src, SLOT_R_STORE, TRUE)))
				to_chat(usr, span_notice("You try to place [place_item] into [src]'s pocket."))
				placing = TRUE
			else
				to_chat(usr, span_notice("You try to empty [src]'s pockets."))

			if(do_mob(usr, src, POCKET_STRIP_DELAY))
				if(placing)
					if(place_item && place_item == usr.get_active_held_item())
						if(place_item.mob_can_equip(src, SLOT_R_STORE, TRUE))
							usr.dropItemToGround(place_item)
							equip_to_slot_if_possible(place_item, SLOT_R_STORE, 1, 0, 1)
						if(place_item.mob_can_equip(src, SLOT_L_STORE, TRUE))
							usr.dropItemToGround(place_item)
							equip_to_slot_if_possible(place_item, SLOT_L_STORE, 1, 0, 1)

				else
					if(r_store || l_store)
						if(r_store && !(r_store.flags_item & NODROP))
							dropItemToGround(r_store)
						if(l_store && !(l_store.flags_item & NODROP))
							dropItemToGround(l_store)
					else
						to_chat(usr, span_notice("[src]'s pockets are empty."))


				// Update strip window
				if(usr.interactee == src && Adjacent(usr))
					show_inv(usr)


	if(href_list["internal"])

		if(!usr.do_actions)
			log_combat(usr, src, "attempted to toggle internals")
			if(internal)
				usr.visible_message(span_danger("[usr] is trying to disable [src]'s internals"), null, null, 3)
			else
				usr.visible_message(span_danger("[usr] is trying to enable [src]'s internals."), null, null, 3)

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
							visible_message(span_notice("[src] is now running on internals."), null, null, 1)
							if (hud_used && hud_used.internals)
								hud_used.internals.icon_state = "internal1"

				// Update strip window
				if(usr.interactee == src && Adjacent(usr))
					show_inv(usr)



	if(href_list["splints"])

		if(!usr.do_actions)
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
							o.remove_limb_flags(LIMB_SPLINTED)
							limbcount++
					if(limbcount)
						new /obj/item/stack/medical/splint(loc, limbcount)
	if(href_list["sensor"])
		if(!usr.do_actions)

			log_combat(usr, src, "attempted to toggle sensors")
			var/obj/item/clothing/under/U = w_uniform
			if(U.has_sensor >= 2)
				to_chat(usr, "The controls are locked.")
			else
				var/oldsens = U.has_sensor
				visible_message(span_danger("[usr] is trying to modify [src]'s sensors!"), null, null, 4)
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
				if(ID && (ID.rank in GLOB.jobs_marines))//still a marine, with an ID.
					if(assigned_squad == H.assigned_squad) //still same squad
						var/newfireteam = tgui_input_list(usr, "Assign this marine to a fireteam.", "Fire Team Assignment", list("None", "Fire Team 1", "Fire Team 2", "Fire Team 3"))
						if(H.incapacitated() || get_dist(H, src) > 7 || !hasHUD(H,"squadleader")) return
						ID = get_idcard()
						if(ID && (ID.rank in GLOB.jobs_marines))//still a marine with an ID
							if(assigned_squad == H.assigned_squad) //still same squad
								switch(newfireteam)
									if("None") ID.assigned_fireteam = 0
									if("Fire Team 1") ID.assigned_fireteam = 1
									if("Fire Team 2") ID.assigned_fireteam = 2
									if("Fire Team 3") ID.assigned_fireteam = 3
									else return
								hud_set_job(faction)


	if (href_list["criminal"])
		if(hasHUD(usr,"security"))

			var/modified = 0
			var/perpname = "wot"
			if(wear_id)
				var/obj/item/card/id/I = get_idcard()
				if(istype(I))
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

								var/setcriminal = tgui_input_list(usr, "Specify a new criminal status for this person.", "Security HUD", list("None", "*Arrest*", "Incarcerated", "Released"))

								if(hasHUD(usr, "security"))
									if(setcriminal)
										R.fields["criminal"] = setcriminal
										modified = 1
										sec_hud_set_security_status()


			if(!modified)
				to_chat(usr, span_warning("Unable to locate a data core entry for this person."))

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
				to_chat(usr, span_warning("Unable to locate a data core entry for this person."))

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
				to_chat(usr, span_warning("Unable to locate a data core entry for this person."))

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
								var/t1 = stripped_input(usr, "Add Comment:", "Sec. records")
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

							var/setmedical = tgui_input_list(usr, "Specify a new medical status for this person.", "Medical HUD", list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled"))

							if(hasHUD(usr,"medical"))
								if(setmedical)
									R.fields["p_stat"] = setmedical
									modified = 1

									if(istype(usr,/mob/living/carbon/human))
										var/mob/living/carbon/human/U = usr
										U.handle_regular_hud_updates()

			if(!modified)
				to_chat(usr, span_warning("Unable to locate a data core entry for this person."))

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
				to_chat(usr, span_warning("Unable to locate a data core entry for this person."))

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
				to_chat(usr, span_warning("Unable to locate a data core entry for this person."))

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
								var/t1 = stripped_input(usr, "Add Comment:", "Med. records")
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
			to_chat(usr, span_warning("Triage holocards only works on organic humanoid entities."))
			return
		var/newcolor = tgui_input_list(usr, "Choose a triage holo card to add to the patient:", "Triage holo card", list("black", "red", "orange", "none"))
		if(!newcolor)
			return
		if(get_dist(usr, src) > 7)
			to_chat(usr, span_warning("[src] is too far away."))
			return
		if(newcolor == "none")
			if(!holo_card_color)
				return
			holo_card_color = null
			to_chat(usr, span_notice("You remove the holo card on [src]."))
		else if(newcolor != holo_card_color)
			holo_card_color = newcolor
			to_chat(usr, span_notice("You add a [newcolor] holo card on [src]."))
		update_targeted()

	if (href_list["scanreport"])
		if(hasHUD(usr,"medical"))
			if(!ishuman(src))
				to_chat(usr, span_warning("This only works on humanoids."))
				return
			if(get_dist(usr, src) > 7)
				to_chat(usr, span_warning("[src] is too far away."))
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


/mob/living/carbon/human/proc/fireman_carry_grabbed()
	SIGNAL_HANDLER
	var/mob/living/grabbed = pulling
	if(!istype(grabbed))
		return NONE
	if(stat == CONSCIOUS && can_be_firemanned(grabbed))
		//If you dragged them to you and you're aggressively grabbing try to fireman carry them
		INVOKE_ASYNC(src, .proc/fireman_carry, grabbed)
		return COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK
	return NONE

//src is the user that will be carrying, target is the mob to be carried
/mob/living/carbon/human/proc/can_be_firemanned(mob/living/carbon/target)
	return (ishuman(target) && !target.canmove)

/mob/living/carbon/human/proc/fireman_carry(mob/living/carbon/target)
	if(!can_be_firemanned(target) || incapacitated(restrained_flags = RESTRAINED_NECKGRAB))
		to_chat(src, span_warning("You can't fireman carry [target] while they're standing!"))
		return
	visible_message(span_notice("[src] starts lifting [target] onto [p_their()] back..."),
	span_notice("You start to lift [target] onto your back..."))
	var/delay = 5 SECONDS - LERP(0 SECONDS, 4 SECONDS, skills.getPercent("medical", SKILL_MEDICAL_MASTER))
	if(!do_mob(src, target, delay, target_display = BUSY_ICON_HOSTILE))
		visible_message(span_warning("[src] fails to fireman carry [target]!"))
		return
	//Second check to make sure they're still valid to be carried
	if(!can_be_firemanned(target) || incapacitated(restrained_flags = RESTRAINED_NECKGRAB))
		return
	buckle_mob(target, TRUE, TRUE, 90, 1, 0)

/mob/living/carbon/human/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(!force)//humans are only meant to be ridden through piggybacking and special cases
		return FALSE
	return ..()


///get_eye_protection()
///Returns a number between -1 to 2
/mob/living/carbon/human/get_eye_protection()
	var/number = 0

	if(!species.has_organ["eyes"]) return 2//No eyes, can't hurt them.

	var/datum/internal_organ/eyes/I = internal_organs_by_name["eyes"]
	if(!I)
		return 2
	if(I.robotic == ORGAN_ROBOT)
		return 2

	if(istype(head, /obj/item/clothing))
		var/obj/item/clothing/C = head
		number += C.eye_protection
	if(istype(wear_mask))
		number += wear_mask.eye_protection
	if(glasses)
		number += glasses.eye_protection

	return number


/mob/living/carbon/human/abiotic(full_body = 0)
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
	visible_message(span_warning(" [src] begins playing his ribcage like a xylophone. It's quite spooky."),span_notice(" You begin to play a spooky refrain on your ribcage."),span_warning(" You hear a spooky xylophone melody."))
	var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
	playsound(loc, song, 25, 1)


/mob/living/carbon/human/proc/is_lung_ruptured()
	var/datum/internal_organ/lungs/L = internal_organs_by_name["lungs"]
	return L?.organ_status == ORGAN_BRUISED

/mob/living/carbon/human/proc/rupture_lung()
	var/datum/internal_organ/lungs/L = internal_organs_by_name["lungs"]

	if(L?.organ_status == ORGAN_BRUISED)
		src.custom_pain("You feel a stabbing pain in your chest!", 1)
		L.damage = L.min_bruised_damage


/mob/living/carbon/human/verb/check_pulse()
	set category = "Object"
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = FALSE

	if(!isliving(usr) || usr.incapacitated())
		return

	if(usr == src)
		self = TRUE

	if(!self)
		usr.visible_message(span_notice("[usr] kneels down, puts [usr.p_their()] hand on [src]'s wrist and begins counting their pulse."),
		span_notice("You begin counting [src]'s pulse."), null, 3)
	else
		usr.visible_message(span_notice("[usr] begins counting their pulse."),
		span_notice("You begin counting your pulse."), null, 3)

	if(handle_pulse())
		to_chat(usr, span_notice("[self ? "You have a" : "[src] has a"] pulse! Counting..."))
	else
		to_chat(usr, span_warning(" [src] has no pulse!"))
		return

	to_chat(usr, "You must[self ? "" : " both"] remain still until counting is finished.")

	if(!do_mob(usr, src, 6 SECONDS))
		to_chat(usr, span_warning("You failed to check the pulse. Try again."))
		return

	to_chat(usr, span_notice("[self ? "Your" : "[src]'s"] pulse is [get_pulse(GETPULSE_HAND)]."))


/mob/living/carbon/human/verb/view_manifest()
	set name = "View Crew Manifest"
	set category = "IC"

	var/dat = GLOB.datacore.get_manifest()

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Crew Manifest</div>", 370, 420)
	popup.set_content(dat)
	popup.open(FALSE)


/mob/living/carbon/human/species
	var/race = null

/mob/living/carbon/human/species/set_species(new_species, default_colour)
	if(!new_species)
		new_species = race
	return ..()

/mob/living/carbon/human/proc/set_species(new_species, default_colour)

	if(!new_species)
		new_species = "Human"

	if(species)

		if(species.name && species.name == new_species) //we're already that species.
			return

		// Clear out their species abilities.
		species.remove_inherent_verbs(src)

	var/datum/species/oldspecies = species

	species = GLOB.all_species[new_species]

	if(oldspecies)
		//additional things to change when we're no longer that species
		oldspecies.post_species_loss(src)

	var/datum/reagents/R
	if(species.species_flags & NO_CHEM_METABOLIZATION)
		R = new /datum/reagents(0)
	else
		R = new /datum/reagents(1000)
	reagents = R
	R.my_atom = src

	species.create_organs(src)

	dextrous = species.has_fine_manipulation

	if(species.default_language_holder)
		language_holder = new species.default_language_holder(src)

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
	INVOKE_ASYNC(src, .proc/update_hair)
	INVOKE_ASYNC(src, .proc/restore_blood)

	if(!(species.species_flags & NO_STAMINA))
		AddComponent(/datum/component/stamina_behavior)
		max_stamina = species.max_stamina
		max_stamina_buffer = max_stamina
		setStaminaLoss(-max_stamina)

	add_movespeed_modifier(MOVESPEED_ID_SPECIES, TRUE, 0, NONE, TRUE, species.slowdown)
	species.on_species_gain(src, oldspecies) //todo move most of the stuff in this proc to here
	return TRUE


/mob/living/carbon/human/reagent_check(datum/reagent/R)
	return species.handle_chemicals(R,src) // if it returns 0, it will run the usual on_mob_life for that reagent. otherwise, it will stop after running handle_chemicals for the species.

/mob/living/carbon/human/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	if(shoes && !override_noslip) // && (shoes.flags_inventory & NOSLIPPING)) // no more slipping if you have shoes on. -spookydonut
		return FALSE
	return ..()

/mob/living/carbon/human/smokecloak_on()
	var/obj/item/storage/backpack/marine/satchel/scout_cloak/S = back
	if(istype(S) && S.camo_active)
		return FALSE
	return ..()

/mob/living/carbon/human/disable_lights(clothing = TRUE, guns = TRUE, flares = TRUE, misc = TRUE, sparks = FALSE, silent = FALSE, forced = FALSE, light_again = FALSE)
	var/light_off = 0
	var/goes_out = 0
	if(clothing)
		if(istype(wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/S = wear_suit
			if(S.turn_light(src, FALSE, 0, FALSE, forced, light_again))
				light_off++
		for(var/obj/item/clothing/head/hardhat/H in contents)
			H.turn_light(src, FALSE, 0,FALSE, forced, light_again)
			light_off++
		for(var/obj/item/flashlight/L in contents)
			if(istype(L, /obj/item/flashlight/flare))
				continue
			if(L.turn_light(src, FALSE, 0, FALSE, forced))
				light_off++
	if(guns)
		for(var/obj/item/weapon/gun/lit_gun in contents)
			var/obj/item/attachable/flashlight/lit_rail_flashlight = LAZYACCESS(lit_gun.attachments_by_slot, ATTACHMENT_SLOT_RAIL)
			if(!isattachmentflashlight(lit_rail_flashlight))
				continue
			lit_rail_flashlight.turn_light(src, FALSE, 0, FALSE, forced)
			light_off++
	if(flares)
		for(var/obj/item/flashlight/flare/F in contents)
			if(F.light_on)
				goes_out++
			F.turn_off(src)
		for(var/obj/item/explosive/grenade/flare/FL in contents)
			if(FL.active)
				goes_out++
			FL.turn_off(src)
	if(misc)
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
	if(sparks && light_off)
		var/datum/effect_system/spark_spread/spark_system = new
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start(src)
	if(!silent)
		if(goes_out && light_off)
			to_chat(src, span_notice("Your sources of light short and fizzle out."))
			return
		if(goes_out)
			if(goes_out > 1)
				to_chat(src, span_notice("Your sources of light fizzle out."))
				return
			to_chat(src, span_notice("Your source of light fizzles out."))
			return
		if(light_off)
			if(light_off > 1)
				to_chat(src, span_notice("Your sources of light short out."))
				return
			to_chat(src, span_notice("Your source of light shorts out."))



/mob/living/carbon/human/proc/randomize_appearance()
	gender = pick(MALE, FEMALE)
	name = species.random_name(gender)
	real_name = name

	if(!(species.species_flags & HAS_NO_HAIR))
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

	age = rand(17, 55)

	update_hair()
	update_body()
	regenerate_icons()


/mob/living/carbon/human/verb/show_skills()
	set category = "IC"
	set name = "Show Skills"

	var/list/dat = list()
	var/list/skill_list = skills.getList()
	for(var/i in skill_list)
		dat += "[i]: [skill_list[i]]"

	var/datum/browser/popup = new(src, "skills", "<div align='center'>Skills</div>", 300, 600)
	popup.set_content(dat.Join("<br>"))
	popup.open(FALSE)


/mob/living/carbon/human/proc/set_equipment(equipment)
	if(!equipment)
		return FALSE

	var/list/job_paths = subtypesof(/datum/outfit/job)
	var/list/outfits = list()
	for(var/path in job_paths)
		var/datum/outfit/O = path
		if(initial(O.can_be_admin_equipped))
			outfits[initial(O.name)] = path

	if(!(equipment in outfits))
		return FALSE

	var/outfit_type = outfits[equipment]
	var/datum/outfit/O = new outfit_type
	delete_equipment(TRUE)
	equipOutfit(O, FALSE)
	regenerate_icons()

	return TRUE


/mob/living/carbon/human/proc/change_squad(squad)
	if(!squad || !ismarinejob(job))
		return FALSE

	var/datum/squad/S = SSjob.squads[squad]

	if(!mind)
		assigned_squad = S
		return FALSE

	if(assigned_squad)
		assigned_squad.remove_from_squad(src)
	S.insert_into_squad(src)
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

	if(job && !GLOB.datacore.manifest_update(oldname, newname, job.title))
		GLOB.datacore.manifest_inject(src)

	return TRUE


/mob/living/carbon/human/do_camera_update(oldloc, obj/item/radio/headset/mainship/H)
	if(QDELETED(H?.camera) || oldloc == get_turf(src))
		return

	GLOB.cameranet.updatePortableCamera(H.camera)


/mob/living/carbon/human/update_camera_location(oldloc)
	oldloc = get_turf(oldloc)

	if(!wear_ear || !istype(wear_ear, /obj/item/radio/headset/mainship) || oldloc == get_turf(src))
		return

	var/obj/item/radio/headset/mainship/H = wear_ear

	if(QDELETED(H.camera))
		return

	addtimer(CALLBACK(src, .proc/do_camera_update, oldloc, H), 1 SECONDS)


/mob/living/carbon/human/get_language_holder()
	if(language_holder)
		return language_holder
	else if(species)
		language_holder = new species.default_language_holder(src)
		return language_holder
	else
		language_holder = new initial_language_holder(src)
		return language_holder


/mob/living/carbon/human/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(buckled)
		return
	return ..()
