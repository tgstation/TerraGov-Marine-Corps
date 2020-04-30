/*
	Global associative list for caching humanoid icons.
	Index format m or f, followed by a string of 0 and 1 to represent bodyparts followed by husk fat hulk skeleton 1 or 0.
	TODO: Proper documentation
	icon_key is [species.race_key][g][husk][fat][hulk][skeleton][ethnicity]
*/
GLOBAL_LIST_EMPTY(human_icon_cache)

	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*

Another feature of this new system is that our lists are indexed. This means we can update specific overlays!
So we only regenerate icons when we need them to be updated! This is the main saving for this system.

In practice this means that:
	Everytime you do something minor like take a pen out of your pocket, we only update the in-hand overlay
	etc...


There are several things that need to be remembered:

>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src) )
	You will need to call the relevant update_inv_* proc:
		update_inv_head()
		update_inv_wear_suit()
		update_inv_gloves()
		update_inv_shoes()
		update_inv_w_uniform()
		update_inv_glasse()
		update_inv_l_hand()
		update_inv_r_hand()
		update_inv_belt()
		update_inv_wear_id()
		update_inv_ears()
		update_inv_s_store()
		update_inv_pockets()
		update_inv_back()
		update_inv_handcuffed()
		update_inv_wear_mask()

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	corgi etc. Instead, it'll just return without doing any work. So no harm in calling it for corgis and such.


>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		UpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
		update_body()	//Handles updating your mob's icon to reflect their gender/race/complexion etc
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)
		update_targeted() // Updates the target overlay when someone points a gun at you

>	If you need to update all overlays you can use regenerate_icons(). it works exactly like update_clothing used to.


*/

/mob/living/carbon/human
	var/list/overlays_standing[TOTAL_LAYERS]
	var/list/underlays_standing[TOTAL_UNDERLAYS]
	var/previous_damage_appearance // store what the body last looked like, so we only have to update it if something changed



/mob/living/carbon/human/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/human/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null

/mob/living/carbon/human/apply_underlay(cache_index)
	var/image/I = underlays_standing[cache_index]
	if(I)
		underlays += I

/mob/living/carbon/human/remove_underlay(cache_index)
	if(underlays_standing[cache_index])
		underlays -= underlays_standing[cache_index]
		underlays_standing[cache_index] = null

GLOBAL_LIST_EMPTY(damage_icon_parts)
/mob/living/carbon/human/proc/get_damage_icon_part(damage_state, body_part)
	if(GLOB.damage_icon_parts["[damage_state]_[species.blood_color]_[body_part]"] == null)
		var/brutestate = copytext(damage_state, 1, 2)
		var/burnstate = copytext(damage_state, 2)
		var/icon/DI
		if(species.blood_color != "#A10808") //not human blood color
			DI = new /icon('icons/mob/dam_human.dmi', "grayscale_[brutestate]")// the damage icon for whole human in grayscale
			DI.Blend(species.blood_color, ICON_MULTIPLY) //coloring with species' blood color
		else
			DI = new /icon('icons/mob/dam_human.dmi', "human_[brutestate]")
		DI.Blend(new /icon('icons/mob/dam_human.dmi', "burn_[burnstate]"), ICON_OVERLAY)//adding burns
		DI.Blend(new /icon('icons/mob/dam_mask.dmi', body_part), ICON_MULTIPLY)		// mask with this organ's pixels
		GLOB.damage_icon_parts["[damage_state]_[species.blood_color]_[body_part]"] = DI
		return DI
	else
		return GLOB.damage_icon_parts["[damage_state]_[species.blood_color]_[body_part]"]

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/UpdateDamageIcon()

	if(species.species_flags & NO_DAMAGE_OVERLAY)
		return

	// first check whether something actually changed about damage appearance
	var/damage_appearance = ""

	for(var/datum/limb/O in limbs)
		if(O.limb_status & LIMB_DESTROYED)
			damage_appearance += "d"
		else
			damage_appearance += O.damage_state

	if(damage_appearance == previous_damage_appearance)
		// nothing to do here
		return

	remove_overlay(DAMAGE_LAYER)

	previous_damage_appearance = damage_appearance

	var/icon/standing = new('icons/mob/dam_human.dmi', "00")

	var/image/standing_image = image("icon" = standing, "layer" = -DAMAGE_LAYER)

	// blend the individual damage states with our icons
	for(var/o in limbs)
		var/datum/limb/limb_to_update = o
		limb_to_update.update_icon()

		if(limb_to_update.damage_state == "00")
			continue

		var/icon/DI = get_damage_icon_part(limb_to_update.damage_state, limb_to_update.icon_name)

		standing_image.overlays += DI

	overlays_standing[DAMAGE_LAYER]	= standing_image

	apply_overlay(DAMAGE_LAYER)

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(update_icons = 1, force_cache_update = 0)
	var/necrosis_color_mod = rgb(10,50,0)

	var/g = get_gender_name(gender)
	var/has_head = 0


	//CACHING: Generate an index key from visible bodyparts.
	//0 = destroyed, 1 = normal, 2 = robotic, 3 = necrotic.

	//Create a new, blank icon for our mob to use.
	if(stand_icon)
		qdel(stand_icon)

	stand_icon = new(species.icon_template ? species.icon_template : 'icons/mob/human.dmi',"blank")

	var/icon_key = "[species.race_key][g][ethnicity]"
	for(var/datum/limb/part in limbs)

		if(istype(part,/datum/limb/head) && !(part.limb_status & LIMB_DESTROYED))
			has_head = 1

		if(part.limb_status & LIMB_DESTROYED)
			icon_key = "[icon_key]0"
		else if(part.limb_status & LIMB_ROBOT)
			icon_key = "[icon_key]2"
		else if(part.limb_status & LIMB_NECROTIZED)
			icon_key = "[icon_key]3"
		else
			icon_key = "[icon_key]1"

	icon_key = "[icon_key][0][0][0][0][ethnicity]"

	var/icon/base_icon
	if(!force_cache_update && GLOB.human_icon_cache[icon_key])
		//Icon is cached, use existing icon.
		base_icon = GLOB.human_icon_cache[icon_key]

		//log_debug("Retrieved cached mob icon ([icon_key] \icon[GLOB.human_icon_cache[icon_key]]) for [src].")

	else

	//BEGIN CACHED ICON GENERATION.

		// Why don't we just make skeletons/shadows/golems a species? ~Z
		var/race_icon =   species.icobase
		var/deform_icon = species.icobase

		//Robotic limbs are handled in get_icon() so all we worry about are missing or dead limbs.
		//No icon stored, so we need to start with a basic one.
		var/datum/limb/chest = get_limb("chest")
		base_icon = chest.get_icon(race_icon,deform_icon,g)

		if(chest.limb_status & LIMB_NECROTIZED)
			base_icon.ColorTone(necrosis_color_mod)
			base_icon.SetIntensity(0.7)

		for(var/datum/limb/part in limbs)

			var/icon/temp //Hold the bodypart icon for processing.

			if(part.limb_status & LIMB_DESTROYED)
				continue

			if(istype(part, /datum/limb/chest)) //already done above
				continue

			if (istype(part, /datum/limb/groin) || istype(part, /datum/limb/head))
				temp = part.get_icon(race_icon,deform_icon,g)
			else
				temp = part.get_icon(race_icon,deform_icon)

			if(part.limb_status & LIMB_NECROTIZED)
				temp.ColorTone(necrosis_color_mod)
				temp.SetIntensity(0.7)

			//That part makes left and right legs drawn topmost and lowermost when human looks WEST or EAST
			//And no change in rendering for other parts (they icon_position is 0, so goes to 'else' part)
			if(part.icon_position&(LEFT|RIGHT))

				var/icon/temp2 = new('icons/mob/human.dmi',"blank")

				temp2.Insert(new/icon(temp,dir=NORTH),dir=NORTH)
				temp2.Insert(new/icon(temp,dir=SOUTH),dir=SOUTH)

				if(!(part.icon_position & LEFT))
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)

				if(!(part.icon_position & RIGHT))
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)

				base_icon.Blend(temp2, ICON_OVERLAY)

				if(part.icon_position & LEFT)
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)

				if(part.icon_position & RIGHT)
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)

				base_icon.Blend(temp2, ICON_UNDERLAY)

			else

				base_icon.Blend(temp, ICON_OVERLAY)

		GLOB.human_icon_cache[icon_key] = base_icon

		//log_debug("Generated new cached mob icon ([icon_key] \icon[GLOB.human_icon_cache[icon_key]]) for [src]. [GLOB.human_icon_cache.len] cached mob icons.")

	//END CACHED ICON GENERATION.

	stand_icon.Blend(base_icon,ICON_OVERLAY)

	/*
	//Skin colour. Not in cache because highly variable (and relatively benign).
	if (species.species_flags & HAS_SKIN_COLOR)
		stand_icon.Blend(rgb(r_skin, g_skin, b_skin), ICON_ADD)
	*/

	if(has_head)
		//Eyes
		var/icon/eyes = new/icon('icons/mob/human_face.dmi', species.eyes)
		eyes.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
		stand_icon.Blend(eyes, ICON_OVERLAY)

		//Mouth	(lipstick!)
		if(lip_style && (species && species.species_flags & HAS_LIPS))	//skeletons are allowed to wear lipstick no matter what you think, agouri.
			stand_icon.Blend(new/icon('icons/mob/human_face.dmi', "camo_[lip_style]_s"), ICON_OVERLAY)


	if(species.species_flags & HAS_UNDERWEAR)

		//Underwear
		if(underwear >0 && underwear < 3)
			stand_icon.Blend(new /icon('icons/mob/human.dmi', "cryo[underwear]_[g]_s"), ICON_OVERLAY)

		if(ismarinejob(job)) //undoing override
			if(undershirt>0 && undershirt < 5)
				stand_icon.Blend(new /icon('icons/mob/human.dmi', "cryoshirt[undershirt]_s"), ICON_OVERLAY)
		else if(undershirt > 0 && undershirt < 7)
			stand_icon.Blend(new /icon('icons/mob/human.dmi', "cryoshirt[undershirt]_s"), ICON_OVERLAY)

	icon = stand_icon

	species?.update_body(src)
	update_tail_showing()

//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	if(species.species_flags & HAS_NO_HAIR)
		return

	var/datum/limb/head/head_organ = get_limb("head")
	if( !head_organ || (head_organ.limb_status & LIMB_DESTROYED) )
		return

	//masks and helmets can obscure our hair.
	if( (head && (head.flags_inv_hide & HIDEALLHAIR)) || (wear_mask && (wear_mask.flags_inv_hide & HIDEALLHAIR)))
		return

	//base icons
	var/icon/face_standing	= new /icon('icons/mob/human_face.dmi',"bald_s")

	if(f_style && !(wear_suit && (wear_suit.flags_inv_hide & HIDELOWHAIR)) && !(wear_mask && (wear_mask.flags_inv_hide & HIDELOWHAIR)))
		var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[f_style]
		if(facial_hair_style && facial_hair_style.species_allowed && (species.name in facial_hair_style.species_allowed))
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

			face_standing.Blend(facial_s, ICON_OVERLAY)

	if(h_style && !(head && (head.flags_inv_hide & HIDETOPHAIR)))
		var/datum/sprite_accessory/hair_style = GLOB.hair_styles_list[h_style]
		if(hair_style && (species.name in hair_style.species_allowed))
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

			face_standing.Blend(hair_s, ICON_OVERLAY)

	overlays_standing[HAIR_LAYER]	= image("icon"= face_standing, "layer" =-HAIR_LAYER)

	apply_overlay(HAIR_LAYER)

//Call when target overlay should be added/removed
/mob/living/carbon/human/update_targeted()
	remove_overlay(TARGETED_LAYER)
	var/image/I
	if(holo_card_color)
		if(I)
			I.overlays += image("icon" = 'icons/effects/Targeted.dmi', "icon_state" = "holo_card_[holo_card_color]")
		else
			I = image("icon" = 'icons/effects/Targeted.dmi', "icon_state" = "holo_card_[holo_card_color]", "layer" =-TARGETED_LAYER)
	if(I)
		overlays_standing[TARGETED_LAYER] = I
	apply_overlay(TARGETED_LAYER)


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	update_mutations(0)
	update_inv_w_uniform()
	update_inv_wear_id()
	update_inv_gloves()
	update_inv_glasses()
	update_inv_ears()
	update_inv_shoes()
	update_inv_s_store()
	update_inv_wear_mask()
	update_inv_head()
	update_inv_belt()
	update_inv_back()
	update_inv_wear_suit()
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_inv_pockets()
	update_fire()
	update_burst()
	UpdateDamageIcon()
	update_transform()


/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)
	if(w_uniform)
		var/obj/item/clothing/under/U = w_uniform
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			U.screen_loc = ui_iclothing
			client.screen += U

		if(wear_suit && (wear_suit.flags_inv_hide & HIDEJUMPSUIT))
			return

		var/used_state = U.icon_state
		if(U.rolled_sleeves)
			used_state += "_d"
		var/image/standing	= image("icon_state" = "[used_state]", "layer" =-UNIFORM_LAYER)

		if(U.icon_override)
			standing.icon = U.icon_override
		else if(U.sprite_sheets && U.sprite_sheets[species.name])
			standing.icon = U.sprite_sheets[species.name]
		else
			standing.icon = U.sprite_sheet_id?'icons/mob/uniform_1.dmi':'icons/mob/uniform_0.dmi'

		if(U.blood_overlay)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "uniformblood")
			bloodsies.color		= U.blood_color
			standing.overlays	+= bloodsies

		if(U.hastie)
			var/tie_state = U.hastie.item_state
			if(!tie_state) tie_state = U.hastie.icon_state
			standing.overlays	+= image("icon" = 'icons/mob/ties.dmi', "icon_state" = "[tie_state]")

		overlays_standing[UNIFORM_LAYER]	= standing

		apply_overlay(UNIFORM_LAYER)
	species?.update_inv_w_uniform(src)

/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)
	if(wear_id)
		if(client && hud_used && hud_used.hud_shown)
			wear_id.screen_loc = ui_id
			client.screen += wear_id
		if((w_uniform && w_uniform.displays_id) || istype(wear_id, /obj/item/card/id/dogtag))
			var/id_state = wear_id.icon_state
			if(wear_id.item_state)
				id_state = wear_id.item_state
			overlays_standing[ID_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "[id_state]", "layer" =-ID_LAYER)
		else
			overlays_standing[ID_LAYER]	= null
		apply_overlay(ID_LAYER)



/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)
	if(gloves)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			gloves.screen_loc = ui_gloves
			client.screen += gloves
		var/t_state = gloves.item_state
		if(!t_state)	t_state = gloves.icon_state

		var/image/standing
		if(gloves.icon_override)
			standing = image("icon" = gloves.icon_override, "icon_state" = "[t_state]", "layer" =-GLOVES_LAYER)
		else if(gloves.sprite_sheets && gloves.sprite_sheets[species.name])
			standing = image("icon" = gloves.sprite_sheets[species.name], "icon_state" = "[t_state]", "layer" =-GLOVES_LAYER)
		else
			standing = image("icon" = 'icons/mob/hands.dmi', "icon_state" = "[t_state]", "layer" =-GLOVES_LAYER)

		if(gloves.blood_overlay)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
			bloodsies.color = gloves.blood_color
			standing.overlays	+= bloodsies
		overlays_standing[GLOVES_LAYER]	= standing
		apply_overlay(GLOVES_LAYER)
		return
	if(!blood_color || !bloody_hands)
		return
	var/datum/limb/left_hand = get_limb("l_hand")
	var/datum/limb/right_hand = get_limb("r_hand")
	var/image/bloodsies
	if(left_hand.limb_status & LIMB_DESTROYED)
		if(right_hand.limb_status & LIMB_DESTROYED)
			return //No hands.
		bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhand_right") //Only right hand.
	else if(right_hand.limb_status & LIMB_DESTROYED)
		bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhand_left") //Only left hand.
	else
		bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands") //Both hands.

	bloodsies.color = blood_color
	overlays_standing[GLOVES_LAYER]	= bloodsies
	apply_overlay(GLOVES_LAYER)


/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)
	remove_overlay(GOGGLES_LAYER)
	if(glasses)
		if(istype(glasses,/obj/item/clothing/glasses/mgoggles))
			if(client && hud_used &&  hud_used.hud_shown && hud_used.inventory_shown)
				glasses.screen_loc = ui_glasses
				client.screen += glasses
			if(glasses.icon_override)
				overlays_standing[GOGGLES_LAYER] = image("icon" = glasses.icon_override, "icon_state" = "[glasses.icon_state]", "layer" =-GOGGLES_LAYER)
			else if(glasses.sprite_sheets && glasses.sprite_sheets[species.name])
				overlays_standing[GOGGLES_LAYER]= image("icon" = glasses.sprite_sheets[species.name], "icon_state" = "[glasses.icon_state]", "layer" =-GOGGLES_LAYER)
			else
				overlays_standing[GOGGLES_LAYER]= image("icon" = 'icons/mob/eyes.dmi', "icon_state" = "[glasses.icon_state]", "layer" =-GOGGLES_LAYER)

			apply_overlay(GOGGLES_LAYER)
		else
			if(client && hud_used &&  hud_used.hud_shown && hud_used.inventory_shown)
				glasses.screen_loc = ui_glasses
				client.screen += glasses
			if(glasses.icon_override)
				overlays_standing[GLASSES_LAYER] = image("icon" = glasses.icon_override, "icon_state" = "[glasses.icon_state]", "layer" =-GLASSES_LAYER)
			else if(glasses.sprite_sheets && glasses.sprite_sheets[species.name])
				overlays_standing[GLASSES_LAYER]= image("icon" = glasses.sprite_sheets[species.name], "icon_state" = "[glasses.icon_state]", "layer" =-GLASSES_LAYER)
			else
				overlays_standing[GLASSES_LAYER]= image("icon" = 'icons/mob/eyes.dmi', "icon_state" = "[glasses.icon_state]", "layer" =-GLASSES_LAYER)

			apply_overlay(GLASSES_LAYER)

/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)
	if(wear_ear)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			wear_ear.screen_loc = ui_wear_ear
			client.screen += wear_ear
	if( (head && (head.flags_inv_hide & HIDEEARS)) || (wear_mask && (wear_mask.flags_inv_hide & HIDEEARS)))
		return

	if(wear_ear)
		var/t_type = wear_ear.item_state? wear_ear.item_state : wear_ear.icon_state
		if(wear_ear.icon_override)
			t_type = "[t_type]_l"
			overlays_standing[EARS_LAYER] = image("icon" = wear_ear.icon_override, "icon_state" = "[t_type]", "layer" =-EARS_LAYER)
		else if(wear_ear.sprite_sheets && wear_ear.sprite_sheets[species.name])
			t_type = "[t_type]_l"
			overlays_standing[EARS_LAYER] = image("icon" = wear_ear.sprite_sheets[species.name], "icon_state" = "[t_type]", "layer" =-EARS_LAYER)
		else
			overlays_standing[EARS_LAYER] = image("icon" = 'icons/mob/ears.dmi', "icon_state" = "[t_type]", "layer" =-EARS_LAYER)

		apply_overlay(EARS_LAYER)

/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)
	if(shoes)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			shoes.screen_loc = ui_shoes
			client.screen += shoes
	if(wear_suit && (wear_suit.flags_inv_hide & HIDESHOES))
		return
	if(shoes)
		var/state = shoes.item_state ? shoes.item_state : shoes.icon_state
		var/image/standing
		if(shoes.icon_override)
			standing = image("icon" = shoes.icon_override, "icon_state" = "[state]", "layer" =-SHOES_LAYER)
		else if(shoes.sprite_sheets && shoes.sprite_sheets[species.name])
			standing = image("icon" = shoes.sprite_sheets[species.name], "icon_state" = "[state]", "layer" =-SHOES_LAYER)
		else
			standing = image("icon" = 'icons/mob/feet.dmi', "icon_state" = "[state]", "layer" =-SHOES_LAYER)

		if(shoes.blood_overlay)
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "shoeblood")
			bloodsies.color = shoes.blood_color
			standing.overlays += bloodsies
		overlays_standing[SHOES_LAYER] = standing
	else
		if(feet_blood_color)
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "shoeblood")
			bloodsies.color = feet_blood_color
			overlays_standing[SHOES_LAYER] = bloodsies

	apply_overlay(SHOES_LAYER)

/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)
	if(s_store)
		if(client && hud_used && hud_used.hud_shown)
			s_store.screen_loc = ui_sstore1
			client.screen += s_store
		var/t_state = s_store.item_state
		if(!t_state)	t_state = s_store.icon_state
		overlays_standing[SUIT_STORE_LAYER]	= image("icon" = 'icons/mob/suit_slot.dmi', "icon_state" = "[t_state]", "layer" =-SUIT_STORE_LAYER)
		apply_overlay(SUIT_STORE_LAYER)



/mob/living/carbon/human/update_inv_head()
	remove_overlay(HEAD_LAYER)
	if(head)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			head.screen_loc = ui_head
			client.screen += head
		var/image/standing

		if(head.icon_override)
			standing = image("icon" = head.icon_override, "icon_state" = "[head.icon_state]", "layer" =-HEAD_LAYER)
		else if(head.sprite_sheets && head.sprite_sheets[species.name])
			standing = image("icon" = head.sprite_sheets[species.name], "icon_state" = "[head.icon_state]", "layer" =-HEAD_LAYER)
		else
			standing = image("icon" = head.sprite_sheet_id?'icons/mob/head_1.dmi':'icons/mob/head_0.dmi', "icon_state" = "[head.icon_state]", "layer" =-HEAD_LAYER)

		if(istype(head,/obj/item/clothing/head/helmet/marine))
			var/obj/item/clothing/head/helmet/marine/marine_helmet = head
			if(marine_helmet.flags_marine_helmet & HELMET_SQUAD_OVERLAY)
				if(assigned_squad)
					var/datum/squad/S = assigned_squad
					var/leader = S.squad_leader == src
					if(GLOB.helmetmarkings[S.type]) // just assume if it exists for both
						standing.overlays += leader? GLOB.helmetmarkings_sl[S.type] : GLOB.helmetmarkings[S.type]

			var/image/I
			for(var/i in marine_helmet.helmet_overlays)
				I = marine_helmet.helmet_overlays[i]
				if(I)
					I = image('icons/mob/helmet_garb.dmi',src,I.icon_state)
					standing.overlays += I

		if(head.blood_overlay)
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
			bloodsies.color = head.blood_color
			standing.overlays	+= bloodsies

		overlays_standing[HEAD_LAYER] = standing

		apply_overlay(HEAD_LAYER)
	species?.update_inv_head(src)

/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)
	if(belt)
		if(client && hud_used && hud_used.hud_shown)
			belt.screen_loc = ui_belt
			client.screen += belt
		var/t_state = belt.item_state
		if(!t_state)	t_state = belt.icon_state

		if(belt.icon_override)
			overlays_standing[BELT_LAYER] = image("icon" = belt.icon_override, "icon_state" = "[t_state]", "layer" =-BELT_LAYER)
		else if(belt.sprite_sheets && belt.sprite_sheets[species.name])
			overlays_standing[BELT_LAYER] = image("icon" = belt.sprite_sheets[species.name], "icon_state" = "[t_state]", "layer" =-BELT_LAYER)
		else
			overlays_standing[BELT_LAYER] = image("icon" = 'icons/mob/belt.dmi', "icon_state" = "[t_state]", "layer" =-BELT_LAYER)

		apply_overlay(BELT_LAYER)


/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)
	if(wear_suit)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			wear_suit.screen_loc = ui_oclothing
			client.screen += wear_suit

		var/image/standing
		if(wear_suit.icon_override)
			standing = image("icon" = wear_suit.icon_override, "icon_state" = "[wear_suit.icon_state]", "layer" =-SUIT_LAYER)
		else if(wear_suit.sprite_sheets && wear_suit.sprite_sheets[species.name])
			standing = image("icon" = wear_suit.sprite_sheets[species.name], "icon_state" = "[wear_suit.icon_state]", "layer" =-SUIT_LAYER)
		else
			standing = image("icon" = wear_suit.sprite_sheet_id?'icons/mob/suit_1.dmi':'icons/mob/suit_0.dmi', "icon_state" = "[wear_suit.icon_state]", "layer" =-SUIT_LAYER)

		if(istype(wear_suit, /obj/item/clothing/suit/storage/marine))
			var/obj/item/clothing/suit/storage/marine/marine_armor = wear_suit
			if(marine_armor.flags_armor_features & ARMOR_SQUAD_OVERLAY)
				if(assigned_squad)
					var/datum/squad/S = assigned_squad
					var/leader = S.squad_leader == src
					if(GLOB.armormarkings[S.type])
						standing.overlays += leader? GLOB.armormarkings_sl[S.type] : GLOB.armormarkings[S.type]
				if(length(marine_armor.armor_overlays))
					var/image/I
					for(var/i in marine_armor.armor_overlays)
						I = marine_armor.armor_overlays[i]
						if(I)
							I = image('icons/mob/suit_1.dmi',src,I.icon_state)
							standing.overlays += I

		if(istype(wear_suit, /obj/item/clothing/suit/storage/marine))
			var/obj/item/clothing/suit/storage/marine/marine_armor = wear_suit
			if(marine_armor.flags_armor_features & ARMOR_SQUAD_OVERLAY)
				if(assigned_squad)
					var/datum/squad/S = assigned_squad
					var/leader = S.squad_leader == src
					if(GLOB.armormarkings[S.type])
						standing.overlays += leader? GLOB.armormarkings_sl[S.type] : GLOB.armormarkings[S.type]

			if(length(marine_armor.armor_overlays))
				var/image/I
				for(var/i in marine_armor.armor_overlays)
					I = marine_armor.armor_overlays[i]
					if(I)
						I = image('icons/mob/suit_1.dmi',src,I.icon_state)
						standing.overlays += I

		if(wear_suit.blood_overlay)
			var/obj/item/clothing/suit/S = wear_suit
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[S.blood_overlay_type]blood")
			bloodsies.color = wear_suit.blood_color
			standing.overlays	+= bloodsies

		overlays_standing[SUIT_LAYER]	= standing

	update_tail_showing()

	species?.update_inv_wear_suit(src)

	apply_overlay(SUIT_LAYER)

/mob/living/carbon/human/update_inv_pockets()
	if(l_store)
		if(client && hud_used && hud_used.hud_shown)
			l_store.screen_loc = ui_storage1
			client.screen += l_store
	if(r_store)
		if(client && hud_used && hud_used.hud_shown)
			r_store.screen_loc = ui_storage2
			client.screen += r_store


/mob/living/carbon/human/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)
	if(wear_mask)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			wear_mask.screen_loc = ui_mask
			client.screen += wear_mask
	if(head && (head.flags_inv_hide & HIDEMASK))
		return
	if(wear_mask)
		var/image/standing
		if(wear_mask.icon_override)
			standing = image("icon" = wear_mask.icon_override, "icon_state" = "[wear_mask.icon_state]", "layer" =-FACEMASK_LAYER)
		else if(wear_mask.sprite_sheets && wear_mask.sprite_sheets[species.name])
			standing = image("icon" = wear_mask.sprite_sheets[species.name], "icon_state" = "[wear_mask.icon_state]", "layer" =-FACEMASK_LAYER)
		else
			standing = image("icon" = 'icons/mob/mask.dmi', "icon_state" = "[wear_mask.icon_state]", "layer" =-FACEMASK_LAYER)

		if( !istype(wear_mask, /obj/item/clothing/mask/cigarette) && wear_mask.blood_overlay )
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "maskblood")
			bloodsies.color = wear_mask.blood_color
			standing.overlays	+= bloodsies
		overlays_standing[FACEMASK_LAYER]	= standing

		apply_overlay(FACEMASK_LAYER)


/mob/living/carbon/human/update_inv_back()
	remove_overlay(BACK_LAYER)
	if(back)
		if(client && hud_used && hud_used.hud_shown)
			back.screen_loc = ui_back
			client.screen += back

		var/t_state = back.item_state ? back.item_state : back.icon_state

		if(back.icon_override)
			overlays_standing[BACK_LAYER] = image("icon" = back.icon_override, "icon_state" = "[t_state]", "layer" =-BACK_LAYER)
		else if(back.sprite_sheets && back.sprite_sheets[species.name])
			overlays_standing[BACK_LAYER] = image("icon" = back.sprite_sheets[species.name], "icon_state" = "[t_state]", "layer" =-BACK_LAYER)
		else
			overlays_standing[BACK_LAYER] = image("icon" = 'icons/mob/back.dmi', "icon_state" = "[t_state]", "layer" =-BACK_LAYER)

		apply_overlay(BACK_LAYER)


/mob/living/carbon/human/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		overlays_standing[HANDCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "handcuff1", "layer" =-HANDCUFF_LAYER)
		apply_overlay(HANDCUFF_LAYER)

/mob/living/carbon/human/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	if(legcuffed)
		overlays_standing[LEGCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "legcuff1", "layer" =-LEGCUFF_LAYER)
		apply_overlay(LEGCUFF_LAYER)


/mob/living/carbon/human/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			client.screen += r_hand
			r_hand.screen_loc = ui_rhand
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state

		if(r_hand.icon_override)
			t_state = "[t_state]_r"
			overlays_standing[R_HAND_LAYER] = image("icon" = r_hand.icon_override, "icon_state" = "[t_state]", "layer" =-R_HAND_LAYER)
		else
			overlays_standing[R_HAND_LAYER] = image("icon" = r_hand.sprite_sheet_id?'icons/mob/items_righthand_1.dmi':'icons/mob/items_righthand_0.dmi', "icon_state" = "[t_state]", "layer" =-R_HAND_LAYER)

		apply_overlay(R_HAND_LAYER)


/mob/living/carbon/human/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			client.screen += l_hand
			l_hand.screen_loc = ui_lhand
		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state

		if(l_hand.icon_override)
			t_state = "[t_state]_l"
			overlays_standing[L_HAND_LAYER] = image("icon" = l_hand.icon_override, "icon_state" = "[t_state]", "layer" =-L_HAND_LAYER)
		else
			overlays_standing[L_HAND_LAYER] = image("icon" = l_hand.sprite_sheet_id?'icons/mob/items_lefthand_1.dmi':'icons/mob/items_lefthand_0.dmi', "icon_state" = "[t_state]", "layer" =-L_HAND_LAYER)

		apply_overlay(L_HAND_LAYER)


/mob/living/carbon/human/proc/update_tail_showing()
	remove_overlay(TAIL_LAYER)

	if(species.tail)
		if(!wear_suit || !(wear_suit.flags_inv_hide & HIDETAIL) && !istype(wear_suit, /obj/item/clothing/suit/space))
			var/icon/tail_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[species.tail]_s")
			tail_s.Blend(rgb(r_skin, g_skin, b_skin), ICON_ADD)

			overlays_standing[TAIL_LAYER]	= image(tail_s, layer = -TAIL_LAYER)

			apply_overlay(TAIL_LAYER)


// Used mostly for creating head items
/mob/living/carbon/human/proc/generate_head_icon()
//gender no longer matters for the mouth, although there should probably be seperate base head icons.
//	var/g = "m"
//	if (gender == FEMALE)	g = "f"

	//base icons
	var/icon/face_lying		= new /icon('icons/mob/human_face.dmi',"bald_l")

	if(f_style)
		var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[f_style]
		if(facial_hair_style)
			var/icon/facial_l = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_l")
			facial_l.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			face_lying.Blend(facial_l, ICON_OVERLAY)

	if(h_style)
		var/datum/sprite_accessory/hair_style = GLOB.hair_styles_list[h_style]
		if(hair_style)
			var/icon/hair_l = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_l")
			hair_l.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			face_lying.Blend(hair_l, ICON_OVERLAY)

	//Eyes
	// Note: These used to be in update_face(), and the fact they're here will make it difficult to create a disembodied head
	var/icon/eyes_l = new/icon('icons/mob/human_face.dmi', "eyes_l")
	eyes_l.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
	face_lying.Blend(eyes_l, ICON_OVERLAY)

	if(lip_style)
		face_lying.Blend(new/icon('icons/mob/human_face.dmi', "lips_[lip_style]_l"), ICON_OVERLAY)

	var/image/face_lying_image = new /image(icon = face_lying)
	return face_lying_image

/mob/living/carbon/human/update_burst()
	remove_overlay(BURST_LAYER)
	var/image/standing
	if(chestburst == 1)
		standing = image("icon" = 'icons/Xeno/Effects.dmi',"icon_state" = "burst_stand", "layer" =-BURST_LAYER)
	else if(chestburst == 2)
		standing = image("icon" = 'icons/Xeno/Effects.dmi',"icon_state" = "bursted_stand", "layer" =-BURST_LAYER)

	overlays_standing[BURST_LAYER]	= standing
	apply_overlay(BURST_LAYER)

/mob/living/carbon/human/update_fire()
	remove_overlay(FIRE_LAYER)
	if(on_fire)
		switch(fire_stacks)
			if(1 to 14)	overlays_standing[FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing_weak", "layer"=-FIRE_LAYER)
			if(15 to 20) overlays_standing[FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing_medium", "layer"=-FIRE_LAYER)

		apply_overlay(FIRE_LAYER)
