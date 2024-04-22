/proc/attempt_initiate_surgery(obj/item/I, mob/living/M, mob/user)
	if(!istype(M))
		return

	var/mob/living/carbon/C
	var/obj/item/bodypart/affecting
	var/selected_zone = user.zone_selected

	if(iscarbon(M))
		C = M
		affecting = C.get_bodypart(check_zone(selected_zone))

	var/datum/surgery/current_surgery

	for(var/datum/surgery/S in M.surgeries)
		if(S.location == selected_zone)
			current_surgery = S

	if(!current_surgery)
		var/list/all_surgeries = GLOB.surgeries_list.Copy()
		var/list/available_surgeries = list()

		for(var/datum/surgery/S in all_surgeries)
			if(!S.possible_locs.Find(selected_zone))
				continue
			if(affecting)
				if(!S.requires_bodypart)
					continue
				if(S.requires_bodypart_type && affecting.status != S.requires_bodypart_type)
					continue
				if(S.requires_real_bodypart && affecting.is_pseudopart)
					continue
			else if(C && S.requires_bodypart) //mob with no limb in surgery zone when we need a limb
				continue
			if(S.lying_required && (M.mobility_flags & MOBILITY_STAND))
				continue
			if(!S.can_start(user, M))
				continue
			for(var/path in S.target_mobtypes)
				if(istype(M, path))
					available_surgeries[S.name] = S
					break

		if(!available_surgeries.len)
			return

		var/P = input("Begin which procedure?", "Surgery", null, null) as null|anything in sortList(available_surgeries)
		if(P && user && user.Adjacent(M) && (I in user))
			var/datum/surgery/S = available_surgeries[P]

			for(var/datum/surgery/other in M.surgeries)
				if(other.location == selected_zone)
					return //during the input() another surgery was started at the same location.

			//we check that the surgery is still doable after the input() wait.
			if(C)
				affecting = C.get_bodypart(check_zone(selected_zone))
			if(affecting)
				if(!S.requires_bodypart)
					return
				if(S.requires_bodypart_type && affecting.status != S.requires_bodypart_type)
					return
			else if(C && S.requires_bodypart)
				return
			if(S.lying_required && (M.mobility_flags & MOBILITY_STAND))
				return
			if(!S.can_start(user, M))
				return

			if(S.ignore_clothes || get_location_accessible(M, selected_zone))
				var/datum/surgery/procedure = new S.type(M, selected_zone, affecting)
				user.visible_message("<span class='notice'>[user] drapes [I] over [M]'s [parse_zone(selected_zone)] to prepare for surgery.</span>", \
					"<span class='notice'>I drape [I] over [M]'s [parse_zone(selected_zone)] to prepare for \an [procedure.name].</span>")

				log_combat(user, M, "operated on", null, "(OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")
			else
				to_chat(user, "<span class='warning'>I need to expose [M]'s [parse_zone(selected_zone)] first!</span>")

	else if(!current_surgery.step_in_progress)
		attempt_cancel_surgery(current_surgery, I, M, user)

	return TRUE

/proc/attempt_cancel_surgery(datum/surgery/S, obj/item/I, mob/living/M, mob/user)
	var/selected_zone = user.zone_selected
	if(S.status == 1)
		M.surgeries -= S
		user.visible_message("<span class='notice'>[user] removes [I] from [M]'s [parse_zone(selected_zone)].</span>", \
			"<span class='notice'>I remove [I] from [M]'s [parse_zone(selected_zone)].</span>")
		qdel(S)
	else if(S.can_cancel)
		var/required_tool_type = TOOL_CAUTERY
		var/obj/item/close_tool = user.get_inactive_held_item()
		var/is_robotic = S.requires_bodypart_type == BODYPART_ROBOTIC
		if(is_robotic)
			required_tool_type = TOOL_SCREWDRIVER
		if(close_tool?.tool_behaviour == required_tool_type || iscyborg(user))
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				H.bleed_rate = max( (H.bleed_rate - 3), 0)
			M.surgeries -= S
			user.visible_message("<span class='notice'>[user] closes [M]'s [parse_zone(selected_zone)] with [close_tool] and removes [I].</span>", \
				"<span class='notice'>I close [M]'s [parse_zone(selected_zone)] with [close_tool] and remove [I].</span>")
			qdel(S)
		else
			to_chat(user, "<span class='warning'>I need to hold a [is_robotic ? "screwdriver" : "cautery"] in your inactive hand to stop [M]'s surgery!</span>")

/proc/get_location_modifier(mob/M)
	var/turf/T = get_turf(M)
	if(locate(/obj/structure/table/optable, T))
		return 1
	else if(locate(/obj/machinery/stasis, T))
		return 0.9
	else if(locate(/obj/structure/table, T))
		return 0.8
	else if(locate(/obj/structure/bed, T))
		return 0.7
	else
		return 0.5

/proc/get_location_accessible(mob/M, location, grabs, skipundies = FALSE)
	var/covered_locations = 0	//based on body_parts_covered
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		for(var/obj/item/clothing/I in list(C.back, C.wear_mask, C.head))
			if(zone2covered(location, I.body_parts_covered))
				return TRUE
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
#ifdef MATURESERVER
			if(!skipundies)
				if(H.underwear != "Nude")
					covered_locations |= GROIN
#endif
			var/list/body_parts = list(H.head, H.mouth, H.wear_mask, H.wear_wrists, H.wear_shirt, H.wear_neck, H.cloak, H.wear_armor, H.wear_pants, H.backr, H.backl, H.gloves, H.shoes, H.belt, H.wear_ring)
			for(var/obj/item/I in body_parts)
				if(zone2covered(location, I.body_parts_covered))
					return FALSE
			if(grabs)
				switch(grabs)
					if("other")
						for(var/obj/item/grabbing/G in H.grabbedby) //other person hand covering it
							if(G.grabbee == H)
								continue
							if(G.sublimb_grabbed == BODY_ZONE_PRECISE_GROIN)
								covered_locations |= GROIN
							if(G.sublimb_grabbed == BODY_ZONE_PRECISE_MOUTH)
								covered_locations |= MOUTH
					if("ours")
						for(var/obj/item/grabbing/G in H.grabbedby) //other person hand covering it
							if(G.grabbee == H)
								if(G.sublimb_grabbed == BODY_ZONE_PRECISE_GROIN)
									covered_locations |= GROIN
								if(G.sublimb_grabbed == BODY_ZONE_PRECISE_MOUTH)
									covered_locations |= MOUTH
			if(zone2covered(location, covered_locations))
				return FALSE
	return TRUE

/proc/zone2covered(location, covered_locations)
	switch(location)
		if(BODY_ZONE_HEAD)
			if(covered_locations & HEAD)
				return 1
		if(BODY_ZONE_PRECISE_EARS)
			if(covered_locations & EARS)
				return 1
		if(BODY_ZONE_PRECISE_HAIR)
			if(covered_locations & HAIR)
				return 1
		if(BODY_ZONE_PRECISE_NOSE)
			if(covered_locations & NOSE)
				return 1
		if(BODY_ZONE_PRECISE_NECK)
			if(covered_locations & NECK)
				return 1
		if(BODY_ZONE_PRECISE_L_EYE)
			if(covered_locations & LEFT_EYE)
				return 1
		if(BODY_ZONE_PRECISE_R_EYE)
			if(covered_locations & RIGHT_EYE)
				return 1
		if(BODY_ZONE_PRECISE_MOUTH)
			if(covered_locations & MOUTH)
				return 1
		if(BODY_ZONE_CHEST)
			if(covered_locations & CHEST)
				return 1
		if(BODY_ZONE_PRECISE_STOMACH)
			if(covered_locations & VITALS)
				return 1
		if(BODY_ZONE_PRECISE_GROIN)
			if(covered_locations & GROIN)
				return 1
		if(BODY_ZONE_L_ARM)
			if(covered_locations & ARM_LEFT)
				return 1
		if(BODY_ZONE_R_ARM)
			if(covered_locations & ARM_RIGHT)
				return 1
		if(BODY_ZONE_L_LEG)
			if(covered_locations & LEG_LEFT)
				return 1
		if(BODY_ZONE_R_LEG)
			if(covered_locations & LEG_RIGHT)
				return 1
		if(BODY_ZONE_PRECISE_L_HAND)
			if(covered_locations & HAND_LEFT)
				return 1
		if(BODY_ZONE_PRECISE_R_HAND)
			if(covered_locations & HAND_RIGHT)
				return 1
		if(BODY_ZONE_PRECISE_L_FOOT)
			if(covered_locations & FOOT_LEFT)
				return 1
		if(BODY_ZONE_PRECISE_R_FOOT)
			if(covered_locations & FOOT_RIGHT)
				return 1

	return 0
