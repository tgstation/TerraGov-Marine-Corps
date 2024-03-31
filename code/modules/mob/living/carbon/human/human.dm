/mob/living/carbon/human/Initialize()
	verbs += /mob/living/proc/mob_sleep
	verbs += /mob/living/proc/lay_down

	icon_state = ""		//Remove the inherent human icon that is visible on the map editor. We're rendering ourselves limb by limb, having it still be there results in a bug where the basic human icon appears below as south in all directions and generally looks nasty.

	//initialize limbs first
	create_bodyparts()

	setup_human_dna()

	if(dna.species)
		set_species(dna.species.type)

	//initialise organs
	create_internal_organs() //most of it is done in set_species now, this is only for parent call
	physiology = new()

	. = ..()

	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_blood)
	AddComponent(/datum/component/personal_crafting)
	AddComponent(/datum/component/footstep, footstep_type, 1, 2)
	GLOB.human_list += src

/mob/living/carbon/human/ZImpactDamage(turf/T, levels)
	var/obj/item/bodypart/affecting
	var/dam = levels * rand(10,50)
	add_stress(/datum/stressevent/felldown)
	switch(rand(1,4))
		if(1)
			affecting = get_bodypart("[pick("r","l")]_leg")
			to_chat(src, "<span class='danger'>I fall on my leg!</span>")
			if(affecting && apply_damage(dam, BRUTE, affecting, run_armor_check(affecting, "melee", damage = dam)))
				update_damage_overlays()
		if(2)
			affecting = get_bodypart("[pick("r","l")]_arm")
			to_chat(src, "<span class='danger'>I fall on my arm!</span>")
			if(affecting && apply_damage(dam, BRUTE, affecting, run_armor_check(affecting, "melee", damage = dam)))
				update_damage_overlays()
		if(3)
			affecting = get_bodypart("chest")
			to_chat(src, "<span class='danger'>I fall flat! I'm winded!</span>")
			emote("gasp")
			adjustOxyLoss(50)
			if(affecting && apply_damage(dam, BRUTE, affecting, run_armor_check(affecting, "melee", damage = dam)))
				update_damage_overlays()
		if(4)
			affecting = get_bodypart("head")
			to_chat(src, "<span class='danger'>I fall on my head!</span>")
			if(affecting && apply_damage(dam, BRUTE, affecting, run_armor_check(affecting, "melee", damage = dam)))
				update_damage_overlays()

	AdjustKnockdown(levels * 15)

/mob/living/carbon/human/proc/setup_human_dna()
	//initialize dna. for spawned humans; overwritten by other code
	create_dna(src)
	randomize_human(src)
	dna.initialize_dna()

/mob/living/carbon/human/ComponentInitialize()
	. = ..()
	if(!CONFIG_GET(flag/disable_human_mood))
		AddComponent(/datum/component/mood)

/mob/living/carbon/human/Destroy()
	SShumannpc.processing -= src
	QDEL_NULL(physiology)
	GLOB.human_list -= src
	return ..()


/mob/living/carbon/human/prepare_data_huds()
	//Update med hud images...
	..()
	//...sec hud images...
	sec_hud_set_ID()
	sec_hud_set_implants()
	sec_hud_set_security_status()
	//...and display them.
	add_to_all_human_data_huds()

/mob/living/carbon/human/Stat()
	..()
	if(mind)
		var/datum/antagonist/vampirelord/VD = mind.has_antag_datum(/datum/antagonist/vampirelord)
		if(VD)
			if(statpanel("Stats"))
				stat("Vitae:",VD.vitae)
		if((mind.assigned_role == "Shepherd") || (mind.assigned_role == "Witch Hunter"))
			if(statpanel("Status"))
				stat("Confessions sent: [GLOB.confessors.len]")

	return //RTchange

	if(statpanel("Status"))
//		stat(null, "Intent: [used_intent]")
//		stat(null, "Move Mode: [m_intent]")
		if (internal)
			if (!internal.air_contents)
				qdel(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)

		if(mind)
			var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
			if(changeling)
				stat("Chemical Storage", "[changeling.chem_charges]/[changeling.chem_storage]")
				stat("Absorbed DNA", changeling.absorbedcount)

	//NINJACODE
	if(istype(wear_armor, /obj/item/clothing/suit/space/space_ninja)) //Only display if actually a ninja.
		var/obj/item/clothing/suit/space/space_ninja/SN = wear_armor
		if(statpanel("SpiderOS"))
			stat("SpiderOS Status:","[SN.s_initialized ? "Initialized" : "Disabled"]")
			stat("Current Time:", "[station_time_timestamp()]")
			if(SN.s_initialized)
				//Suit gear
				stat("Energy Charge:", "[round(SN.cell.charge/100)]%")
				stat("Smoke Bombs:", "\Roman [SN.s_bombs]")
				//Ninja status
				stat("Fingerprints:", "[md5(dna.uni_identity)]")
				stat("Unique Identity:", "[dna.unique_enzymes]")
				stat("Overall Status:", "[stat > 1 ? "dead" : "[health]% healthy"]")
				stat("Nutrition Status:", "[nutrition]")
				stat("Oxygen Loss:", "[getOxyLoss()]")
				stat("Toxin Levels:", "[getToxLoss()]")
				stat("Burn Severity:", "[getFireLoss()]")
				stat("Brute Trauma:", "[getBruteLoss()]")
				stat("Radiation Levels:","[radiation] rad")
				stat("Body Temperature:","[bodytemperature-T0C] degrees C ([bodytemperature*1.8-459.67] degrees F)")

				//Diseases
				if(diseases.len)
					stat("Viruses:", null)
					for(var/thing in diseases)
						var/datum/disease/D = thing
						stat("*", "[D.name], Type: [D.spread_text], Stage: [D.stage]/[D.max_stages], Possible Cure: [D.cure_text]")


/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/list/obscured = check_obscured_slots()
	var/list/dat = list()

	dat += "<table>"

	if(handcuffed)
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_HANDCUFFED]'>Remove [handcuffed]</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_LEGCUFFED]'>Remove [legcuffed]</A></td></tr>"

	dat += "<tr><td><hr></td></tr>"

	for(var/i in 1 to held_items.len)
		var/obj/item/I = get_item_for_held_index(i)
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_HANDS];hand_index=[i]'>[(I && !(I.item_flags & ABSTRACT)) ? I : "<font color=grey>[get_held_index_name(i)]</font>"]</a></td></tr>"

	dat += "<tr><td><hr></td></tr>"

//	if(has_breathable_mask && istype(back, /obj/item/tank))
//		dat += "&nbsp;<A href='?src=[REF(src)];internal=[SLOT_BACK]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

//	dat += "<tr><td><B>HEAD</B></td></tr>"

	//head
	if(SLOT_HEAD in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_HEAD]'>[(head && !(head.item_flags & ABSTRACT)) ? head : "<font color=grey>Head</font>"]</A></td></tr>"

	if(SLOT_WEAR_MASK in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_WEAR_MASK]'>[(wear_mask && !(wear_mask.item_flags & ABSTRACT)) ? wear_mask : "<font color=grey>Mask</font>"]</A></td></tr>"

	if(SLOT_MOUTH in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_MOUTH]'>[(mouth && !(mouth.item_flags & ABSTRACT)) ? mouth : "<font color=grey>Mouth</font>"]</A></td></tr>"

	if(SLOT_NECK in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_NECK]'>[(wear_neck && !(wear_neck.item_flags & ABSTRACT)) ? wear_neck : "<font color=grey>Neck</font>"]</A></td></tr>"

	dat += "<tr><td><hr></td></tr>"

//	dat += "<tr><td><B>BACK</B></td></tr>"

	if(SLOT_CLOAK in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_CLOAK]'>[(cloak && !(cloak.item_flags & ABSTRACT)) ? cloak : "<font color=grey>Cloak</font>"]</A></td></tr>"

	if(SLOT_BACK_R in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_BACK_R]'>[(backr && !(backr.item_flags & ABSTRACT)) ? backr : "<font color=grey>Back</font>"]</A></td></tr>"

	if(SLOT_BACK_L in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_BACK_L]'>[(backl && !(backl.item_flags & ABSTRACT)) ? backl : "<font color=grey>Back</font>"]</A></td></tr>"

	dat += "<tr><td><hr></td></tr>"

//	dat += "<tr><td><B>TORSO</B></td></tr>"

	if(SLOT_ARMOR in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_ARMOR]'>[(wear_armor && !(wear_armor.item_flags & ABSTRACT)) ? wear_armor : "<font color=grey>Armor</font>"]</A></td></tr>"

	if(SLOT_SHIRT in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_SHIRT]'>[(wear_shirt && !(wear_shirt.item_flags & ABSTRACT)) ? wear_shirt : "<font color=grey>Shirt</font>"]</A></td></tr>"

	if(SLOT_GLOVES in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_GLOVES]'>[(gloves && !(gloves.item_flags & ABSTRACT)) ? gloves : "<font color=grey>Gloves</font>"]</A></td></tr>"

	if(SLOT_RING in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_RING]'>[(wear_ring && !(wear_ring.item_flags & ABSTRACT)) ? wear_ring : "<font color=grey>Ring</font>"]</A></td></tr>"

	if(SLOT_WRISTS in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_WRISTS]'>[(wear_wrists && !(wear_wrists.item_flags & ABSTRACT)) ? wear_wrists : "<font color=grey>Wrists</font>"]</A></td></tr>"

	dat += "<tr><td><hr></td></tr>"

//	dat += "<tr><td><B>WAIST</B></td></tr>"

	if(SLOT_BELT in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_BELT]'>[(belt && !(belt.item_flags & ABSTRACT)) ? belt : "<font color=grey>Belt</font>"]</A></td></tr>"

	if(SLOT_BELT_R in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_BELT_R]'>[(beltr && !(beltr.item_flags & ABSTRACT)) ? beltr : "<font color=grey>Hip</font>"]</A></td></tr>"

	if(SLOT_BELT_L in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_BELT_L]'>[(beltl && !(beltl.item_flags & ABSTRACT)) ? beltl : "<font color=grey>Hip</font>"]</A></td></tr>"

	dat += "<tr><td><hr></td></tr>"

//	dat += "<tr><td><B>LEGS</B></td></tr>"

	if(SLOT_PANTS in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_PANTS]'>[(wear_pants && !(wear_pants.item_flags & ABSTRACT)) ? wear_pants : "<font color=grey>Trousers</font>"]</A></td></tr>"

	if(SLOT_SHOES in obscured)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_SHOES]'>[(shoes && !(shoes.item_flags & ABSTRACT)) ? shoes : "<font color=grey>Boots</font>"]</A></td></tr>"

	dat += "<tr><td><hr></td></tr>"

	dat += {"</table>"}

	var/datum/browser/popup = new(user, "mob[REF(src)]", "[src]", 220, 690)
	popup.set_content(dat.Join())
	popup.open()

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/Crossed(atom/movable/AM)
	var/mob/living/simple_animal/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

	. = ..()
	spreadFire(AM)

/mob/living/carbon/human/Topic(href, href_list)

	if(href_list["inspect_limb"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		var/list/msg = list()
		if(!ismob(usr))
			return
		var/mob/user = usr
		var/obj/item/bodypart/BP = get_bodypart(check_zone(user.zone_selected))
		msg += "<B>[parse_zone(check_zone(user.zone_selected))]:</B>\n"
		if(BP)
			if(get_location_accessible(src, check_zone(user.zone_selected)))
				if(BP.disabled == BODYPART_DISABLED_CRIT)
					msg += "I notice a broken bone.\n"
				if(BP.disabled == BODYPART_DISABLED_FALL)
					msg += "The leg is numb to touch.\n"
				if(BP.bandage)
					var/usedclass = "'notice'"
					if(BP.bandage.return_blood_DNA())
						usedclass = "'danger'"
					msg += "<a href='?src=[REF(src)];bandage=[REF(BP.bandage)];bandaged_limb=[REF(BP)]' class=[usedclass]>Bandaged</a>\n"
				else if(BP.wounds.len)
					msg += "<B>Wounds:</B>\n"
					for(var/datum/wound/W in BP.wounds)
						msg += "[W.name]\n"

			else
				msg += "Obscured by clothing.\n"
			for(var/obj/item/I in BP.embedded_objects)
				msg += "<a href='?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(BP)]'>[I.name]</a>\n"
		else
			msg += "<B>Limb is missing!</B>\n"
		to_chat(usr, "[msg.Join("")]")

	if(href_list["check_hb"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		if(Adjacent(usr))
			usr.visible_message("<span class='info'>[usr] tries to hear [src]'s heartbeat.</span>")
			if(do_after(usr, 30, needhand = 1, target = src))
				if(stat == DEAD)
					to_chat(usr, "<B>No heartbeat...</B>")
				else
					to_chat(usr, "<B>The heart is still beating.</B>")

	if(href_list["embedded_object"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		var/obj/item/bodypart/L = locate(href_list["embedded_limb"]) in bodyparts
		if(!L)
			return
		var/obj/item/I = locate(href_list["embedded_object"]) in L.embedded_objects
		if(!I || I.loc != src) //no item, no limb, or item is not in limb or in the person anymore
			return
		var/time_taken = I.embedding.embedded_unsafe_removal_time*I.w_class
		if(usr == src)
			usr.visible_message("<span class='warning'>[usr] attempts to remove [I] from [usr.p_their()] [L.name].</span>","<span class='warning'>I attempt to remove [I] from my [L.name]...</span>")
		else
			usr.visible_message("<span class='warning'>[usr] attempts to remove [I] from [src]'s [L.name].</span>","<span class='warning'>I attempt to remove [I] from [src]'s [L.name]...</span>")
		if(do_after(usr, time_taken, needhand = 1, target = src))
			if(!I || !L || I.loc != src || !(I in L.embedded_objects))
				return
			L.embedded_objects -= I
			emote("pain", TRUE)
			L.receive_damage(I.embedding.embedded_unsafe_removal_pain_multiplier*I.w_class)//It hurts to rip it out, get surgery you dingus.
			I.forceMove(get_turf(src))
			usr.put_in_hands(I)
			playsound(loc, 'sound/foley/flesh_rem.ogg', 100, TRUE, -2)
			if(usr == src)
				usr.visible_message("<span class='notice'>[usr] rips [I] out of [usr.p_their()] [L.name]!</span>", "<span class='notice'>I successfully remove [I] from my [L.name].</span>")
			else
				usr.visible_message("<span class='notice'>[usr] rips [I] out of [src]'s [L.name]!</span>", "<span class='notice'>I successfully remove [I] from [src]'s [L.name].</span>")
			if(!has_embedded_objects())
				clear_alert("embeddedobject")
				SEND_SIGNAL(usr, COMSIG_CLEAR_MOOD_EVENT, "embedded")
		return

	if(href_list["bandage"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		var/obj/item/bodypart/L = locate(href_list["bandaged_limb"]) in bodyparts
		if(!L)
			return
		var/obj/item/I = L.bandage
		if(!I)
			return
		if(usr == src)
			usr.visible_message("<span class='warning'>[usr] starts unbandaging [usr.p_their()] [L.name].</span>","<span class='warning'>I start unbandaging [L.name]...</span>")
		else
			usr.visible_message("<span class='warning'>[usr] starts unbandaging [src]'s [L.name].</span>","<span class='warning'>I start unbandaging [src]'s [L.name]...</span>")
		if(do_after(usr, 50, needhand = 1, target = src))
			if(!I || !L || !(L.bandage == I))
				return
			I.forceMove(get_turf(src))
			L.bandage = null
			usr.put_in_hands(I)
			src.update_damage_overlays()
		return

	if(href_list["item"]) //canUseTopic check for this is handled by mob/Topic()
		var/slot = text2num(href_list["item"])
		if(slot in check_obscured_slots(TRUE))
			to_chat(usr, "<span class='warning'>I can't reach that! Something is covering it.</span>")
			return

	if(href_list["undiesthing"]) //canUseTopic check for this is handled by mob/Topic()
		if(!get_location_accessible(src, BODY_ZONE_PRECISE_GROIN, skipundies = TRUE))
			to_chat(usr, "<span class='warning'>I can't reach that! Something is covering it.</span>")
			return
		if(underwear == "Nude")
			return
		if(do_after(usr, 50, needhand = 1, target = src))
			cached_underwear = underwear
			underwear = "Nude"
			update_body()
			var/obj/item/undies/U
			if(gender == MALE)
				U = new/obj/item/undies(get_turf(src))
			else
				U = new/obj/item/undies/f(get_turf(src))
			U.color = underwear_color
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.put_in_hands(U)

	if(href_list["pockets"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY)) //TODO: Make it match (or intergrate it into) strippanel so you get 'item cannot fit here' warnings if mob_can_equip fails
		var/pocket_side = href_list["pockets"]
		var/pocket_id = (pocket_side == "right" ? SLOT_R_STORE : SLOT_L_STORE)
		var/obj/item/pocket_item = (pocket_id == SLOT_R_STORE ? r_store : l_store)
		var/obj/item/place_item = usr.get_active_held_item() // Item to place in the pocket, if it's empty

		var/delay_denominator = 1
		if(pocket_item && !(pocket_item.item_flags & ABSTRACT))
			if(HAS_TRAIT(pocket_item, TRAIT_NODROP))
				to_chat(usr, "<span class='warning'>I try to empty [src]'s [pocket_side] pocket, it seems to be stuck!</span>")
			to_chat(usr, "<span class='notice'>I try to empty [src]'s [pocket_side] pocket.</span>")
		else if(place_item && place_item.mob_can_equip(src, usr, pocket_id, 1) && !(place_item.item_flags & ABSTRACT))
			to_chat(usr, "<span class='notice'>I try to place [place_item] into [src]'s [pocket_side] pocket.</span>")
			delay_denominator = 4
		else
			return

		if(do_mob(usr, src, POCKET_STRIP_DELAY/delay_denominator)) //placing an item into the pocket is 4 times faster
			if(pocket_item)
				if(pocket_item == (pocket_id == SLOT_R_STORE ? r_store : l_store)) //item still in the pocket we search
					dropItemToGround(pocket_item)
			else
				if(place_item)
					if(place_item.mob_can_equip(src, usr, pocket_id, FALSE, TRUE))
						usr.temporarilyRemoveItemFromInventory(place_item, TRUE)
						equip_to_slot(place_item, pocket_id, TRUE)
					//do nothing otherwise
				//updating inv screen after handled by living/Topic()
		else
			// Display a warning if the user mocks up
			to_chat(src, "<span class='warning'>I feel your [pocket_side] pocket being fumbled with!</span>")

///////HUDs///////
	if(href_list["hud"])
		if(!ishuman(usr))
			return
		var/mob/living/carbon/human/H = usr
		var/perpname = get_face_name(get_id_name(""))
		if(!HAS_TRAIT(H, TRAIT_SECURITY_HUD) && !HAS_TRAIT(H, TRAIT_MEDICAL_HUD))
			return
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.general)
		if(href_list["photo_front"] || href_list["photo_side"])
			if(!R)
				return
			if(!H.canUseHUD())
				return
			if(!HAS_TRAIT(H, TRAIT_SECURITY_HUD) && !HAS_TRAIT(H, TRAIT_MEDICAL_HUD))
				return
			var/obj/item/photo/P = null
			if(href_list["photo_front"])
				P = R.fields["photo_front"]
			else if(href_list["photo_side"])
				P = R.fields["photo_side"]
			if(P)
				P.show(H)
			return

		if(href_list["hud"] == "m")
			if(!HAS_TRAIT(H, TRAIT_MEDICAL_HUD))
				return
			if(href_list["evaluation"])
				if(!getBruteLoss() && !getFireLoss() && !getOxyLoss() && getToxLoss() < 20)
					to_chat(usr, "<span class='notice'>No external injuries detected.</span><br>")
					return
				var/span = "notice"
				var/status = ""
				if(getBruteLoss())
					to_chat(usr, "<b>Physical trauma analysis:</b>")
					for(var/X in bodyparts)
						var/obj/item/bodypart/BP = X
						var/brutedamage = BP.brute_dam
						if(brutedamage > 0)
							status = "received minor physical injuries."
							span = "notice"
						if(brutedamage > 20)
							status = "been seriously damaged."
							span = "danger"
						if(brutedamage > 40)
							status = "sustained major trauma!"
							span = "danger"
						if(brutedamage)
							to_chat(usr, "<span class='[span]'>[BP] appears to have [status]</span>")
				if(getFireLoss())
					to_chat(usr, "<b>Analysis of skin burns:</b>")
					for(var/X in bodyparts)
						var/obj/item/bodypart/BP = X
						var/burndamage = BP.burn_dam
						if(burndamage > 0)
							status = "signs of minor burns."
							span = "notice"
						if(burndamage > 20)
							status = "serious burns."
							span = "danger"
						if(burndamage > 40)
							status = "major burns!"
							span = "danger"
						if(burndamage)
							to_chat(usr, "<span class='[span]'>[BP] appears to have [status]</span>")
				if(getOxyLoss())
					to_chat(usr, "<span class='danger'>Patient has signs of suffocation, emergency treatment may be required!</span>")
				if(getToxLoss() > 20)
					to_chat(usr, "<span class='danger'>Gathered data is inconsistent with the analysis, possible cause: poisoning.</span>")
			if(!H.wear_ring) //You require access from here on out.
				to_chat(H, "<span class='warning'>ERROR: Invalid access</span>")
				return
			var/list/access = H.wear_ring.GetAccess()
			if(!(ACCESS_MEDICAL in access))
				to_chat(H, "<span class='warning'>ERROR: Invalid access</span>")
				return
			if(href_list["p_stat"])
				var/health_status = input(usr, "Specify a new physical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("Active", "Physically Unfit", "*Unconscious*", "*Deceased*", "Cancel")
				if(!R)
					return
				if(!H.canUseHUD())
					return
				if(!HAS_TRAIT(H, TRAIT_MEDICAL_HUD))
					return
				if(health_status && health_status != "Cancel")
					R.fields["p_stat"] = health_status
				return
			if(href_list["m_stat"])
				var/health_status = input(usr, "Specify a new mental status for this person.", "Medical HUD", R.fields["m_stat"]) in list("Stable", "*Watch*", "*Unstable*", "*Insane*", "Cancel")
				if(!R)
					return
				if(!H.canUseHUD())
					return
				if(!HAS_TRAIT(H, TRAIT_MEDICAL_HUD))
					return
				if(health_status && health_status != "Cancel")
					R.fields["m_stat"] = health_status
				return
			return //Medical HUD ends here.

		if(href_list["hud"] == "s")
			if(!HAS_TRAIT(H, TRAIT_SECURITY_HUD))
				return
			if(usr.stat || usr == src) //|| !usr.canmove || usr.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
				return													  //Non-fluff: This allows sec to set people to arrest as they get disarmed or beaten
			// Checks the user has security clearence before allowing them to change arrest status via hud, comment out to enable all access
			var/allowed_access = null
			var/obj/item/clothing/glasses/hud/security/G = H.glasses
			if(istype(G) && (G.obj_flags & EMAGGED))
				allowed_access = "@%&ERROR_%$*"
			else //Implant and standard glasses check access
				if(H.wear_ring)
					var/list/access = H.wear_ring.GetAccess()
					if(ACCESS_SEC_DOORS in access)
						allowed_access = H.get_authentification_name()

			if(!allowed_access)
				to_chat(H, "<span class='warning'>ERROR: Invalid access.</span>")
				return

			if(!perpname)
				to_chat(H, "<span class='warning'>ERROR: Can not identify target.</span>")
				return
			R = find_record("name", perpname, GLOB.data_core.security)
			if(!R)
				to_chat(usr, "<span class='warning'>ERROR: Unable to locate data core entry for target.</span>")
				return
			if(href_list["status"])
				var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Paroled", "Discharged", "Cancel")
				if(setcriminal != "Cancel")
					if(!R)
						return
					if(!H.canUseHUD())
						return
					if(!HAS_TRAIT(H, TRAIT_SECURITY_HUD))
						return
					investigate_log("[key_name(src)] has been set from [R.fields["criminal"]] to [setcriminal] by [key_name(usr)].", INVESTIGATE_RECORDS)
					R.fields["criminal"] = setcriminal
					sec_hud_set_security_status()
				return

			if(href_list["view"])
				if(!H.canUseHUD())
					return
				if(!HAS_TRAIT(H, TRAIT_SECURITY_HUD))
					return
				to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
				to_chat(usr, "<b>Minor Crimes:</b>")
				for(var/datum/data/crime/c in R.fields["mi_crim"])
					to_chat(usr, "<b>Crime:</b> [c.crimeName]")
					to_chat(usr, "<b>Details:</b> [c.crimeDetails]")
					to_chat(usr, "Added by [c.author] at [c.time]")
					to_chat(usr, "----------")
					to_chat(usr, "<b>Major Crimes:</b>")
				for(var/datum/data/crime/c in R.fields["ma_crim"])
					to_chat(usr, "<b>Crime:</b> [c.crimeName]")
					to_chat(usr, "<b>Details:</b> [c.crimeDetails]")
					to_chat(usr, "Added by [c.author] at [c.time]")
					to_chat(usr, "----------")
				to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
				return

			if(href_list["add_crime"])
				switch(alert("What crime would you like to add?","Security HUD","Minor Crime","Major Crime","Cancel"))
					if("Minor Crime")
						var/t1 = stripped_input("Please input minor crime names:", "Security HUD", "", null)
						var/t2 = stripped_multiline_input("Please input minor crime details:", "Security HUD", "", null)
						if(!R || !t1 || !t2 || !allowed_access)
							return
						if(!H.canUseHUD())
							return
						if(!HAS_TRAIT(H, TRAIT_SECURITY_HUD))
							return
						var/crime = GLOB.data_core.createCrimeEntry(t1, t2, allowed_access, station_time_timestamp())
						GLOB.data_core.addMinorCrime(R.fields["id"], crime)
						investigate_log("New Minor Crime: <strong>[t1]</strong>: [t2] | Added to [R.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)
						to_chat(usr, "<span class='notice'>Successfully added a minor crime.</span>")
						return
					if("Major Crime")
						var/t1 = stripped_input("Please input major crime names:", "Security HUD", "", null)
						var/t2 = stripped_multiline_input("Please input major crime details:", "Security HUD", "", null)
						if(!R || !t1 || !t2 || !allowed_access)
							return
						if(!H.canUseHUD())
							return
						if(!HAS_TRAIT(H, TRAIT_SECURITY_HUD))
							return
						var/crime = GLOB.data_core.createCrimeEntry(t1, t2, allowed_access, station_time_timestamp())
						GLOB.data_core.addMajorCrime(R.fields["id"], crime)
						investigate_log("New Major Crime: <strong>[t1]</strong>: [t2] | Added to [R.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)
						to_chat(usr, "<span class='notice'>Successfully added a major crime.</span>")
				return

			if(href_list["view_comment"])
				if(!H.canUseHUD())
					return
				if(!HAS_TRAIT(H, TRAIT_SECURITY_HUD))
					return
				to_chat(usr, "<b>Comments/Log:</b>")
				var/counter = 1
				while(R.fields[text("com_[]", counter)])
					to_chat(usr, R.fields[text("com_[]", counter)])
					to_chat(usr, "----------")
					counter++
				return

			if(href_list["add_comment"])
				var/t1 = stripped_multiline_input("Add Comment:", "Secure. records", null, null)
				if (!R || !t1 || !allowed_access)
					return
				if(!H.canUseHUD())
					return
				if(!HAS_TRAIT(H, TRAIT_SECURITY_HUD))
					return
				var/counter = 1
				while(R.fields[text("com_[]", counter)])
					counter++
				R.fields[text("com_[]", counter)] = text("Made by [] on [] [], []<BR>[]", allowed_access, station_time_timestamp(), time2text(world.realtime, "MMM DD"), GLOB.year_integer+540, t1)
				to_chat(usr, "<span class='notice'>Successfully added comment.</span>")
				return

	..() //end of this massive fucking chain. TODO: make the hud chain not spooky. - Yeah, great job doing that.

/mob/living/carbon/human/proc/canUseHUD()
	return (mobility_flags & MOBILITY_USE)

/mob/living/carbon/human/can_inject(mob/user, error_msg, target_zone, penetrate_thick = 0)
	. = 1 // Default to returning true.
	if(user && !target_zone)
		target_zone = user.zone_selected
	if(HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
		. = 0
	// If targeting the head, see if the head item is thin enough.
	// If targeting anything else, see if the wear suit is thin enough.
	if (!penetrate_thick)
		if(above_neck(target_zone))
			if(head && istype(head, /obj/item/clothing))
				var/obj/item/clothing/CH = head
				if (CH.clothing_flags & THICKMATERIAL)
					. = 0
		else
			if(wear_armor && istype(wear_armor, /obj/item/clothing))
				var/obj/item/clothing/CS = wear_armor
				if (CS.clothing_flags & THICKMATERIAL)
					. = 0
	if(!. && error_msg && user)
		// Might need re-wording.
		to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [above_neck(target_zone) ? "on [p_their()] head" : "on [p_their()] body"].</span>")

/mob/living/carbon/human/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null)
	if(judgement_criteria & JUDGE_EMAGGED)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(istype(wear_armor, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if(is_holding_item_of_type(/obj/item/gun/energy/laser/redtag))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/redtag))
				threatcount += 2

		if(lasercolor == "r")
			if(istype(wear_armor, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if(is_holding_item_of_type(/obj/item/gun/energy/laser/bluetag))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/bluetag))
				threatcount += 2

		return threatcount

	//Check for ID
	var/obj/item/card/id/idcard = get_idcard(FALSE)
	if( (judgement_criteria & JUDGE_IDCHECK) && !idcard && name=="Unknown")
		threatcount += 4

	//Check for weapons
	if( (judgement_criteria & JUDGE_WEAPONCHECK) && weaponcheck)
		if(!idcard || !(ACCESS_WEAPONS in idcard.access))
			for(var/obj/item/I in held_items) //if they're holding a gun
				if(weaponcheck.Invoke(I))
					threatcount += 4
			if(weaponcheck.Invoke(belt) || weaponcheck.Invoke(back)) //if a weapon is present in the belt or back slot
				threatcount += 2 //not enough to trigger look_for_perp() on it's own unless they also have criminal status.

	//Check for arrest warrant
	if(judgement_criteria & JUDGE_RECORDCHECK)
		var/perpname = get_face_name(get_id_name())
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if("*Arrest*")
					threatcount += 5
				if("Incarcerated")
					threatcount += 2
				if("Paroled")
					threatcount += 2

	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/wizard))
		threatcount += 2

	//Check for nonhuman scum
	if(dna && dna.species.id && dna.species.id != "human")
		threatcount += 1

	//mindshield implants imply trustworthyness
	if(HAS_TRAIT(src, TRAIT_MINDSHIELD))
		threatcount -= 1

	//Agent cards lower threatlevel.
	if(istype(idcard, /obj/item/card/id/syndicate))
		threatcount -= 5

	return threatcount


//Used for new human mobs created by cloning/goleming/podding
/mob/living/carbon/human/proc/set_cloned_appearance()
	if(gender == MALE)
		facial_hairstyle = "Full Beard"
	else
		facial_hairstyle = "Shaved"
	hairstyle = pick("Bedhead", "Bedhead 2", "Bedhead 3")
	underwear = "Nude"
	update_body()
	update_hair()

/mob/living/carbon/human/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_THREE)
		for(var/obj/item/hand in held_items)
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2)  && dropItemToGround(hand))
				step_towards(hand, src)
				to_chat(src, "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>")
	rad_act(current_size * 3)

/mob/living/carbon/human/proc/do_cpr(mob/living/carbon/C)
	CHECK_DNA_AND_SPECIES(C)

	if(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_FAKEDEATH)))
		to_chat(src, "<span class='warning'>[C.name] is dead!</span>")
		return
	if(is_mouth_covered())
		to_chat(src, "<span class='warning'>Remove your mask first!</span>")
		return 0
	if(C.is_mouth_covered())
		to_chat(src, "<span class='warning'>Remove [p_their()] mask first!</span>")
		return 0

	if(C.cpr_time < world.time + 30)
		visible_message("<span class='notice'>[src] is trying to perform CPR on [C.name]!</span>", \
						"<span class='notice'>I try to perform CPR on [C.name]... Hold still!</span>")
		if(!do_mob(src, C))
			to_chat(src, "<span class='warning'>I fail to perform CPR on [C]!</span>")
			return 0

		var/they_breathe = !HAS_TRAIT(C, TRAIT_NOBREATH)
		var/they_lung = C.getorganslot(ORGAN_SLOT_LUNGS)

		if(C.health > C.crit_threshold)
			return

		src.visible_message("<span class='notice'>[src] performs CPR on [C.name]!</span>", "<span class='notice'>I perform CPR on [C.name].</span>")
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "perform_cpr", /datum/mood_event/perform_cpr)
		C.cpr_time = world.time
		log_combat(src, C, "CPRed")

		if(they_breathe && they_lung)
			var/suff = min(C.getOxyLoss(), 7)
			C.adjustOxyLoss(-suff)
			C.updatehealth()
			to_chat(C, "<span class='unconscious'>I feel a breath of fresh air enter your lungs... It feels good...</span>")
		else if(they_breathe && !they_lung)
			to_chat(C, "<span class='unconscious'>I feel a breath of fresh air... but you don't feel any better...</span>")
		else
			to_chat(C, "<span class='unconscious'>I feel a breath of fresh air... which is a sensation you don't recognise...</span>")

/mob/living/carbon/human/cuff_resist(obj/item/I)
	if(dna && dna.check_mutation(HULK))
		say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced = "hulk")
		if(..(I, cuff_break = FAST_CUFFBREAK))
			dropItemToGround(I, silent = FALSE)
	else
		if(..())
			dropItemToGround(I)

/mob/living/carbon/human/proc/clean_blood(datum/source, strength)
	if(strength < CLEAN_STRENGTH_BLOOD)
		return
	if(gloves)
		if(SEND_SIGNAL(gloves, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
			update_inv_gloves()
	else
		if(bloody_hands)
			bloody_hands = 0
			update_inv_gloves()

//Turns a mob black, flashes a skeleton overlay
//Just like a cartoon!
/mob/living/carbon/human/proc/electrocution_animation(anim_duration)
	//Handle mutant parts if possible
	if(dna && dna.species)
		add_atom_colour("#000000", TEMPORARY_COLOUR_PRIORITY)
		var/static/mutable_appearance/electrocution_skeleton_anim
		if(!electrocution_skeleton_anim)
			electrocution_skeleton_anim = mutable_appearance(icon, "electrocuted_base")
			electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART
		add_overlay(electrocution_skeleton_anim)
		addtimer(CALLBACK(src, .proc/end_electrocution_animation, electrocution_skeleton_anim), anim_duration)

	else //or just do a generic animation
		flick_overlay_view(image(icon,src,"electrocuted_generic",ABOVE_MOB_LAYER), src, anim_duration)

/mob/living/carbon/human/proc/end_electrocution_animation(mutable_appearance/MA)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#000000")
	cut_overlay(MA)

/mob/living/carbon/human/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE)
	if(!(mobility_flags & MOBILITY_UI))
		to_chat(src, "<span class='warning'>I can't do that right now!</span>")
		return FALSE
	if(!Adjacent(M) && (M.loc != src))
		if((be_close == FALSE) || (!no_tk && (dna.check_mutation(TK) && tkMaxRangeCheck(src, M))))
			return TRUE
		to_chat(src, "<span class='warning'>I am too far away!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/human/resist_restraints()
	if(wear_armor && wear_armor.breakouttime)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		cuff_resist(wear_armor)
	else
		..()

/mob/living/carbon/human/replace_records_name(oldname,newname) // Only humans have records right now, move this up if changed.
	for(var/list/L in list(GLOB.data_core.general,GLOB.data_core.medical,GLOB.data_core.security,GLOB.data_core.locked))
		var/datum/data/record/R = find_record("name", oldname, L)
		if(R)
			R.fields["name"] = newname

/mob/living/carbon/human/get_total_tint()
	. = ..()
	if(glasses)
		. += glasses.tint

/mob/living/carbon/human/update_tod_hud()
	if(!client || !hud_used)
		return
	if(hud_used.clock)
		hud_used.clock.update_icon()

/mob/living/carbon/human/update_health_hud()
	if(!client || !hud_used)
		return
	if(dna.species.update_health_hud())
		return
	else
		if(hud_used.bloods)
			var/bloodloss = ((BLOOD_VOLUME_NORMAL - blood_volume) / BLOOD_VOLUME_NORMAL) * 100

			var/burnhead = 0
			var/brutehead = 0
			var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
			if(head)
				burnhead = (head.burn_dam / head.max_damage) * 100
				brutehead = (head.brute_dam / head.max_damage) * 100

			var/toxloss = getToxLoss()
			var/oxloss = getOxyLoss()

			var/hungloss = nutrition*-1 //this is smart i think

			var/usedloss = 0
			if(bloodloss > 0)
				usedloss = bloodloss
			if(burnhead > usedloss)
				usedloss = burnhead
			if(brutehead > usedloss)
				usedloss = brutehead
			if(toxloss > usedloss)
				usedloss = toxloss
			if(oxloss > usedloss)
				usedloss = oxloss
			if(hungloss > usedloss)
				usedloss = hungloss

			if(usedloss <= 0)
				hud_used.bloods.icon_state = "dam0"
			else
				var/used = round(usedloss, 10)
				if(used <= 80)
					hud_used.bloods.icon_state = "dam[used]"
				else
					hud_used.bloods.icon_state = "damelse"

/*		if(hud_used.healthdoll)
			hud_used.healthdoll.cut_overlays()
			if(stat != DEAD)
				hud_used.healthdoll.icon_state = "healthdoll_OVERLAY"
				for(var/X in bodyparts)
					var/obj/item/bodypart/BP = X
					var/damage = BP.burn_dam + BP.brute_dam
					var/comparison = (BP.max_damage/5)
					var/icon_num = 0
					if(damage)
						icon_num = 1
					if(damage > (comparison))
						icon_num = 2
					if(damage > (comparison*2))
						icon_num = 3
					if(damage > (comparison*3))
						icon_num = 4
					if(damage > (comparison*4))
						icon_num = 5
					if(hal_screwyhud == SCREWYHUD_HEALTHY)
						icon_num = 0
					if(icon_num)
						hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[BP.body_zone][icon_num]"))
				for(var/t in get_missing_limbs()) //Missing limbs
					hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[t]6"))
				for(var/t in get_disabled_limbs()) //Disabled limbs
					hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[t]7"))
			else
				hud_used.healthdoll.icon_state = "healthdoll_DEAD"*/

		if(hud_used.fats)
			if(stat != DEAD)
				. = 1
				if(rogfat >= maxrogfat)
					hud_used.fats.icon_state = "fat0"
				else if(rogfat > maxrogfat*0.90)
					hud_used.fats.icon_state = "fat10"
				else if(rogfat > maxrogfat*0.80)
					hud_used.fats.icon_state = "fat20"
				else if(rogfat > maxrogfat*0.70)
					hud_used.fats.icon_state = "fat30"
				else if(rogfat > maxrogfat*0.60)
					hud_used.fats.icon_state = "fat40"
				else if(rogfat > maxrogfat*0.50)
					hud_used.fats.icon_state = "fat50"
				else if(rogfat > maxrogfat*0.40)
					hud_used.fats.icon_state = "fat60"
				else if(rogfat > maxrogfat*0.30)
					hud_used.fats.icon_state = "fat70"
				else if(rogfat > maxrogfat*0.20)
					hud_used.fats.icon_state = "fat80"
				else if(rogfat > maxrogfat*0.10)
					hud_used.fats.icon_state = "fat90"
				else if(rogfat >= 0)
					hud_used.fats.icon_state = "fat100"
		if(hud_used.stams)
			if(stat != DEAD)
				. = 1
				if(rogstam <= 0)
					hud_used.stams.icon_state = "stam0"
				else if(rogstam > maxrogstam*0.90)
					hud_used.stams.icon_state = "stam100"
				else if(rogstam > maxrogstam*0.80)
					hud_used.stams.icon_state = "stam90"
				else if(rogstam > maxrogstam*0.70)
					hud_used.stams.icon_state = "stam80"
				else if(rogstam > maxrogstam*0.60)
					hud_used.stams.icon_state = "stam70"
				else if(rogstam > maxrogstam*0.50)
					hud_used.stams.icon_state = "stam60"
				else if(rogstam > maxrogstam*0.40)
					hud_used.stams.icon_state = "stam50"
				else if(rogstam > maxrogstam*0.30)
					hud_used.stams.icon_state = "stam40"
				else if(rogstam > maxrogstam*0.20)
					hud_used.stams.icon_state = "stam30"
				else if(rogstam > maxrogstam*0.10)
					hud_used.stams.icon_state = "stam20"
				else if(rogstam > 0)
					hud_used.stams.icon_state = "stam10"

		if(hud_used.zone_select)
			hud_used.zone_select.update_icon()

/mob/living/carbon/human/fully_heal(admin_revive = FALSE)
	dna?.species.spec_fully_heal(src)
	if(admin_revive)
		regenerate_limbs()
		regenerate_organs()
	remove_all_embedded_objects()
	set_heartattack(FALSE)
	drunkenness = 0
	for(var/datum/mutation/human/HM in dna.mutations)
		if(HM.quality != POSITIVE)
			dna.remove_mutation(HM.name)
	..()

/mob/living/carbon/human/check_weakness(obj/item/weapon, mob/living/attacker)
	. = ..()
	if (dna && dna.species)
		. += dna.species.check_species_weakness(weapon, attacker)

/mob/living/carbon/human/is_literate()
	if(mind)
		if(mind.get_skill_level(/datum/skill/misc/reading) > 0)
			return TRUE
		else
			return FALSE
	return TRUE

/mob/living/carbon/human/can_hold_items()
	return TRUE

/mob/living/carbon/human/update_gravity(has_gravity,override = 0)
	if(dna && dna.species) //prevents a runtime while a human is being monkeyfied
		override = dna.species.override_float
	..()

/mob/living/carbon/human/vomit(lost_nutrition = 10, blood = 0, stun = 1, distance = 0, message = 1, toxic = 0)
	if(blood && (NOBLOOD in dna.species.species_traits) && !HAS_TRAIT(src, TRAIT_TOXINLOVER))
		if(message)
			visible_message("<span class='warning'>[src] dry heaves!</span>", \
							"<span class='danger'>I try to throw up, but there's nothing in your stomach!</span>")
		if(stun)
			Immobilize(200)
		return 1
	..()

/mob/living/carbon/human/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_COPY_OUTFIT, "Copy Outfit")
	VV_DROPDOWN_OPTION(VV_HK_MOD_MUTATIONS, "Add/Remove Mutation")
	VV_DROPDOWN_OPTION(VV_HK_MOD_QUIRKS, "Add/Remove Quirks")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_MONKEY, "Make Monkey")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_CYBORG, "Make Cyborg")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_SLIME, "Make Slime")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_ALIEN, "Make Alien")
	VV_DROPDOWN_OPTION(VV_HK_SET_SPECIES, "Set Species")
	VV_DROPDOWN_OPTION(VV_HK_PURRBATION, "Toggle Purrbation")

/mob/living/carbon/human/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_COPY_OUTFIT])
		if(!check_rights(R_SPAWN))
			return
		copy_outfit()
	if(href_list[VV_HK_MOD_MUTATIONS])
		if(!check_rights(R_SPAWN))
			return

		var/list/options = list("Clear"="Clear")
		for(var/x in subtypesof(/datum/mutation/human))
			var/datum/mutation/human/mut = x
			var/name = initial(mut.name)
			options[dna.check_mutation(mut) ? "[name] (Remove)" : "[name] (Add)"] = mut

		var/result = input(usr, "Choose mutation to add/remove","Mutation Mod") as null|anything in sortList(options)
		if(result)
			if(result == "Clear")
				dna.remove_all_mutations()
			else
				var/mut = options[result]
				if(dna.check_mutation(mut))
					dna.remove_mutation(mut)
				else
					dna.add_mutation(mut)
	if(href_list[VV_HK_MOD_QUIRKS])
		if(!check_rights(R_SPAWN))
			return

		var/list/options = list("Clear"="Clear")
		for(var/x in subtypesof(/datum/quirk))
			var/datum/quirk/T = x
			var/qname = initial(T.name)
			options[has_quirk(T) ? "[qname] (Remove)" : "[qname] (Add)"] = T

		var/result = input(usr, "Choose quirk to add/remove","Quirk Mod") as null|anything in sortList(options)
		if(result)
			if(result == "Clear")
				for(var/datum/quirk/q in roundstart_quirks)
					remove_quirk(q.type)
			else
				var/T = options[result]
				if(has_quirk(T))
					remove_quirk(T)
				else
					add_quirk(T,TRUE)
	if(href_list[VV_HK_MAKE_MONKEY])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("monkeyone"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MAKE_CYBORG])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makerobot"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MAKE_ALIEN])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makealien"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MAKE_SLIME])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makeslime"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_SET_SPECIES])
		if(!check_rights(R_SPAWN))
			return
		var/result = input(usr, "Please choose a new species","Species") as null|anything in GLOB.species_list
		if(result)
			var/newtype = GLOB.species_list[result]
			admin_ticket_log("[key_name_admin(usr)] has modified the bodyparts of [src] to [result]")
			set_species(newtype)
	if(href_list[VV_HK_PURRBATION])
		if(!check_rights(R_SPAWN))
			return
		if(!ishumanbasic(src))
			to_chat(usr, "This can only be done to the basic human species at the moment.")
			return
		var/success = purrbation_toggle(src)
		if(success)
			to_chat(usr, "Put [src] on purrbation.")
			log_admin("[key_name(usr)] has put [key_name(src)] on purrbation.")
			var/msg = "<span class='notice'>[key_name_admin(usr)] has put [key_name(src)] on purrbation.</span>"
			message_admins(msg)
			admin_ticket_log(src, msg)

		else
			to_chat(usr, "Removed [src] from purrbation.")
			log_admin("[key_name(usr)] has removed [key_name(src)] from purrbation.")
			var/msg = "<span class='notice'>[key_name_admin(usr)] has removed [key_name(src)] from purrbation.</span>"
			message_admins(msg)
			admin_ticket_log(src, msg)

/mob/living/carbon/human/MouseDrop_T(mob/living/target, mob/living/user)
	if(user == target)
		return FALSE
	if(pulling == target && stat == CONSCIOUS)
		//If they dragged themselves and we're currently aggressively grabbing them try to piggyback
		if(user == target && can_piggyback(target))
			piggyback(target)
			return TRUE
		//If you dragged them to you and you're aggressively grabbing try to carry them
		else if(user != target && can_be_firemanned(target))
			var/obj/G = get_active_held_item()
			if(G)
				if(istype(G, /obj/item/grabbing))
					fireman_carry(target)
					return TRUE
	. = ..()

//src is the user that will be carrying, target is the mob to be carried
/mob/living/carbon/human/proc/can_piggyback(mob/living/carbon/target)
	return (istype(target) && target.stat == CONSCIOUS)

/mob/living/carbon/human/proc/can_be_firemanned(mob/living/carbon/target)
	return (ishuman(target) && !(target.mobility_flags & MOBILITY_STAND))

/mob/living/carbon/human/proc/fireman_carry(mob/living/carbon/target)
	var/carrydelay = 50 //if you have latex you are faster at grabbing

	var/backnotshoulder = FALSE
	if(r_grab && l_grab)
		if(r_grab.grabbed == target)
			if(l_grab.grabbed == target)
				backnotshoulder = TRUE

	if(can_be_firemanned(target) && !incapacitated(FALSE, TRUE))
		if(backnotshoulder)
			visible_message("<span class='notice'>[src] starts lifting [target] onto their back..</span>")
		else
			visible_message("<span class='notice'>[src] starts lifting [target] onto their shoulder..</span>")
		if(do_after(src, carrydelay, TRUE, target))
			//Second check to make sure they're still valid to be carried
			if(can_be_firemanned(target) && !incapacitated(FALSE, TRUE))
				buckle_mob(target, TRUE, TRUE, 90, 0, 0)
				return
	to_chat(src, "<span class='warning'>I fail to carry [target].</span>")

/mob/living/carbon/human/proc/piggyback(mob/living/carbon/target)
	if(can_piggyback(target))
		visible_message("<span class='notice'>[target] starts to climb onto [src]...</span>")
		if(do_after(target, 15, target = src))
			if(can_piggyback(target))
				if(target.incapacitated(FALSE, TRUE) || incapacitated(FALSE, TRUE))
					to_chat(target, "<span class='warning'>I can't piggyback ride [src].</span>")
					return
				buckle_mob(target, TRUE, TRUE, FALSE, 0, 0)
	else
		to_chat(target, "<span class='warning'>I can't piggyback ride [src].</span>")

/mob/living/carbon/human/buckle_mob(mob/living/target, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0)
	if(!force)//humans are only meant to be ridden through piggybacking and special cases
		return
	if(!is_type_in_typecache(target, can_ride_typecache))
		target.visible_message("<span class='warning'>[target] really can't seem to mount [src]...</span>")
		return
	buckle_lying = lying_buckle
	var/datum/component/riding/human/riding_datum = LoadComponent(/datum/component/riding/human)
	if(target_hands_needed)
		riding_datum.ride_check_rider_restrained = TRUE
	if(buckled_mobs && ((target in buckled_mobs) || (buckled_mobs.len >= max_buckled_mobs)) || buckled)
		return
	var/equipped_hands_self
	var/equipped_hands_target
	if(hands_needed)
		equipped_hands_self = riding_datum.equip_buckle_inhands(src, hands_needed, target)
	if(target_hands_needed)
		equipped_hands_target = riding_datum.equip_buckle_inhands(target, target_hands_needed)

	if(hands_needed || target_hands_needed)
		if(hands_needed && !equipped_hands_self)
			src.visible_message("<span class='warning'>[src] can't get a grip on [target] because their hands are full!</span>",
				"<span class='warning'>I can't get a grip on [target] because your hands are full!</span>")
			return
		else if(target_hands_needed && !equipped_hands_target)
			target.visible_message("<span class='warning'>[target] can't get a grip on [src] because their hands are full!</span>",
				"<span class='warning'>I can't get a grip on [src] because your hands are full!</span>")
			return

	//stop_pulling()
	riding_datum.handle_vehicle_layer()
	. = ..(target, force, check_loc)

/mob/living/carbon/human/proc/is_shove_knockdown_blocked() //If you want to add more things that block shove knockdown, extend this
	var/list/body_parts = list(head, wear_mask, wear_armor, wear_pants, back, gloves, shoes, belt, s_store, glasses, ears, wear_ring) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(istype(bp, /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.clothing_flags & BLOCKS_SHOVE_KNOCKDOWN)
				return TRUE
	return FALSE

/mob/living/carbon/human/proc/clear_shove_slowdown()
	remove_movespeed_modifier(MOVESPEED_ID_SHOVE)
	var/active_item = get_active_held_item()
	if(is_type_in_typecache(active_item, GLOB.shove_disarming_types))
		visible_message("<span class='warning'>[src.name] regains their grip on \the [active_item]!</span>", "<span class='warning'>I regain your grip on \the [active_item]</span>", null, COMBAT_MESSAGE_RANGE)

/mob/living/carbon/human/do_after_coefficent()
	. = ..()
	. *= physiology.do_after_speed

/mob/living/carbon/human/updatehealth()
	. = ..()
	dna?.species.spec_updatehealth(src)
	if(HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN)
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN_FLYING)
		return
	var/health_deficiency = max((maxHealth - health), 0)
	if(health_deficiency >= 80)
		add_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN, override = TRUE, multiplicative_slowdown = (health_deficiency / 75), blacklisted_movetypes = FLOATING|FLYING)
		add_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN_FLYING, override = TRUE, multiplicative_slowdown = (health_deficiency / 25), movetypes = FLOATING)
	else
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN)
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN_FLYING)

/mob/living/carbon/human/adjust_nutrition(var/change) //Honestly FUCK the oldcoders for putting nutrition on /mob someone else can move it up because holy hell I'd have to fix SO many typechecks
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	return ..()

/mob/living/carbon/human/set_nutrition(var/change) //Seriously fuck you oldcoders.
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	return ..()

/mob/living/carbon/human/adjust_hydration(var/change)
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	return ..()

/mob/living/carbon/human/set_hydration(var/change)
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	return ..()

/mob/living/carbon/human/species
	var/race = null

/mob/living/carbon/human/species/Initialize()
	. = ..()
	if(race)
		set_species(race)

/mob/living/carbon/human/species/abductor
	race = /datum/species/abductor

/mob/living/carbon/human/species/android
	race = /datum/species/android

/mob/living/carbon/human/species/corporate
	race = /datum/species/corporate

/mob/living/carbon/human/species/dullahan
	race = /datum/species/dullahan

/mob/living/carbon/human/species/felinid
	race = /datum/species/human/felinid

/mob/living/carbon/human/species/fly
	race = /datum/species/fly

/mob/living/carbon/human/species/golem
	race = /datum/species/golem

/mob/living/carbon/human/species/golem/random
	race = /datum/species/golem/random

/mob/living/carbon/human/species/golem/adamantine
	race = /datum/species/golem/adamantine

/mob/living/carbon/human/species/golem/plasma
	race = /datum/species/golem/plasma

/mob/living/carbon/human/species/golem/diamond
	race = /datum/species/golem/diamond

/mob/living/carbon/human/species/golem/gold
	race = /datum/species/golem/gold

/mob/living/carbon/human/species/golem/silver
	race = /datum/species/golem/silver

/mob/living/carbon/human/species/golem/plasteel
	race = /datum/species/golem/plasteel

/mob/living/carbon/human/species/golem/titanium
	race = /datum/species/golem/titanium

/mob/living/carbon/human/species/golem/plastitanium
	race = /datum/species/golem/plastitanium

/mob/living/carbon/human/species/golem/alien_alloy
	race = /datum/species/golem/alloy

/mob/living/carbon/human/species/golem/wood
	race = /datum/species/golem/wood

/mob/living/carbon/human/species/golem/uranium
	race = /datum/species/golem/uranium

/mob/living/carbon/human/species/golem/sand
	race = /datum/species/golem/sand

/mob/living/carbon/human/species/golem/glass
	race = /datum/species/golem/glass

/mob/living/carbon/human/species/golem/bluespace
	race = /datum/species/golem/bluespace

/mob/living/carbon/human/species/golem/bananium
	race = /datum/species/golem/bananium

/mob/living/carbon/human/species/golem/blood_cult
	race = /datum/species/golem/runic

/mob/living/carbon/human/species/golem/cloth
	race = /datum/species/golem/cloth

/mob/living/carbon/human/species/golem/plastic
	race = /datum/species/golem/plastic

/mob/living/carbon/human/species/golem/bronze
	race = /datum/species/golem/bronze

/mob/living/carbon/human/species/golem/cardboard
	race = /datum/species/golem/cardboard

/mob/living/carbon/human/species/golem/leather
	race = /datum/species/golem/leather

/mob/living/carbon/human/species/golem/bone
	race = /datum/species/golem/bone

/mob/living/carbon/human/species/golem/durathread
	race = /datum/species/golem/durathread

/mob/living/carbon/human/species/golem/snow
	race = /datum/species/golem/snow

/mob/living/carbon/human/species/golem/capitalist
	race = /datum/species/golem/capitalist

/mob/living/carbon/human/species/golem/soviet
	race = /datum/species/golem/soviet

/mob/living/carbon/human/species/jelly
	race = /datum/species/jelly

/mob/living/carbon/human/species/jelly/slime
	race = /datum/species/jelly/slime

/mob/living/carbon/human/species/jelly/stargazer
	race = /datum/species/jelly/stargazer

/mob/living/carbon/human/species/jelly/luminescent
	race = /datum/species/jelly/luminescent

/mob/living/carbon/human/species/lizard
	race = /datum/species/lizard

/mob/living/carbon/human/species/ethereal
	race = /datum/species/ethereal

/mob/living/carbon/human/species/lizard/ashwalker
	race = /datum/species/lizard/ashwalker

/mob/living/carbon/human/species/moth
	race = /datum/species/moth

/mob/living/carbon/human/species/mush
	race = /datum/species/mush

/mob/living/carbon/human/species/plasma
	race = /datum/species/plasmaman

/mob/living/carbon/human/species/pod
	race = /datum/species/pod

/mob/living/carbon/human/species/shadow
	race = /datum/species/shadow

/mob/living/carbon/human/species/shadow/nightmare
	race = /datum/species/shadow/nightmare

//mob/living/carbon/human/species/skeleton
//	race = /datum/species/skeleton

/mob/living/carbon/human/species/snail
	race = /datum/species/snail

/mob/living/carbon/human/species/synth
	race = /datum/species/synth

/mob/living/carbon/human/species/synth/military
	race = /datum/species/synth/military

/mob/living/carbon/human/species/vampire
	race = /datum/species/vampire

/mob/living/carbon/human/species/zombie
	race = /datum/species/zombie

/mob/living/carbon/human/species/zombie/infectious
	race = /datum/species/zombie/infectious

/mob/living/carbon/human/species/zombie/krokodil_addict
	race = /datum/species/krokodil_addict
