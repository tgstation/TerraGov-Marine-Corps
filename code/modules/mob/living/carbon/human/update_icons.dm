	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/* Keep these comments up-to-da/sprite_accessory/earste if you -insist- on hurting my code-baby ;_;
This system allows you to update individual mob-overlays, without regenerating them all each time.
When we generate overlays we generate the standing version and then rotate the mob as necessary..

As of the time of writing there are 20 layers within this list. Please try to keep this from increasing. //22 and counting, good job guys
	var/overlays_standing[20]		//For the standing stance

Most of the time we only wish to update one overlay:
	e.g. - we dropped the fireaxe out of our left hand and need to remove its icon from our mob
	e.g.2 - our hair colour has changed, so we need to update our hair icons on our mob
In these cases, instead of updating every overlay using the old behaviour (regenerate_icons), we instead call
the appropriate update_X proc.
	e.g. - update_l_hand()
	e.g.2 - update_hair()

Note: Recent changes by aranclanos+carn:
	update_icons() no longer needs to be called.
	the system is easier to use. update_icons() should not be called unless you absolutely -know- you need it.
	IN ALL OTHER CASES it's better to just call the specific update_X procs.

Note: The defines for layer numbers is now kept exclusvely in __DEFINES/misc.dm instead of being defined there,
	then redefined and undefiend everywhere else. If you need to change the layering of sprites (or add a new layer)
	that's where you should start.

All of this means that this code is more maintainable, faster and still fairly easy to use.

There are several things that need to be remembered:
>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src), rather than using the helper procs)
	You will need to call the relevant update_inv_* proc

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_damage_overlays()	//handles damage overlays for brute/burn damage
		update_body()				//Handles updating your mob's body layer and mutant bodyparts
									as well as sprite-accessories that didn't really fit elsewhere (underwear, undershirts, socks, lips, eyes)
									//NOTE: update_mutantrace() is now merged into this!
		update_hair()				//Handles updating your hair overlay (used to be update_face, but mouth and
									eyes were merged into update_body())


*/

/mob/living/carbon/proc/get_limbloss_index(limbr, limbl)
	var/jazz = 1
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == limbr)
			jazz += 1
		if(affecting.body_part == limbl)
			jazz += 2
	return jazz

//HAIR OVERLAY
/mob/living/carbon/human/update_hair()
	dna.species.handle_hair(src)

//used when putting/removing clothes that hide certain mutant body parts to just update those and not update the whole body.
/mob/living/carbon/human/proc/update_mutant_bodyparts()
	dna.species.handle_mutant_bodyparts(src)


/mob/living/carbon/human/update_body()
	dna.species.handle_body(src)
	..()

/mob/living/carbon/human/update_fire()
	if(fire_stacks < 10)
		return ..("Generic_mob_burning")
	else
		var/burning = dna.species.enflamed_icon
		if(!burning)
			return ..("widefire")
		return ..(burning)


/mob/living/carbon/human/update_damage_overlays()
	START_PROCESSING(SSdamoverlays,src)

/mob/living/carbon/human/proc/update_damage_overlays_real()
	if(dna.species)
		if(dna.species.update_damage_overlays(src))
			return
	remove_overlay(DAMAGE_LAYER)
	remove_overlay(LEG_DAMAGE_LAYER)
	remove_overlay(ARM_DAMAGE_LAYER)

	var/limb_icon = dna.species.dam_icon
	var/hidechest = FALSE
	var/list/limb_overlaysa = list()
	var/list/limb_overlaysb = list()
	var/list/limb_overlaysc = list()

	if(gender == FEMALE || dna.species.use_f)
		limb_icon = dna.species.dam_icon_f

		if(gender == MALE)
			hidechest = TRUE

		var/obj/item/bodypart/CH = get_bodypart(BODY_ZONE_CHEST)
		if(CH && !hidechest)
			if(wear_armor)
				var/obj/item/I = wear_armor
				if(I.flags_inv & HIDEBOOB)
					hidechest = TRUE
			if(wear_shirt)
				var/obj/item/I = wear_shirt
				if(I.flags_inv & HIDEBOOB)
					hidechest = TRUE
			if(cloak)
				var/obj/item/I = cloak
				if(I.flags_inv & HIDEBOOB)
					hidechest = TRUE

	for(var/X in bodyparts)
		var/list/damage_overlays = list()
		var/list/legdam_overlays = list()
		var/list/armdam_overlays = list()
		var/obj/item/bodypart/BP = X
		var/g = BP.offset
		if(gender == FEMALE || dna.species.use_f)
			g = BP.offset_f
		if(BP.body_zone == BODY_ZONE_HEAD)
			update_hair()
		if(BP.brutestate && !BP.skeletonized)
			var/mutable_appearance/damage_overlay = mutable_appearance(limb_icon, "[BP.body_zone]_[BP.brutestate]0", -DAMAGE_LAYER)
			damage_overlays += damage_overlay
			var/mutable_appearance/legdam_overlay = mutable_appearance(limb_icon, "legdam_[BP.body_zone]_[BP.brutestate]0", -LEG_DAMAGE_LAYER)
			legdam_overlays += legdam_overlay
			var/mutable_appearance/armdam_overlay = mutable_appearance(limb_icon, "armdam_[BP.body_zone]_[BP.brutestate]0", -ARM_DAMAGE_LAYER)
			armdam_overlays += armdam_overlay
		if(BP.burnstate && !BP.skeletonized)
			var/mutable_appearance/damage_overlay = mutable_appearance(limb_icon, "[BP.body_zone]_0[BP.burnstate]", -DAMAGE_LAYER)
			damage_overlays += damage_overlay
			var/mutable_appearance/legdam_overlay = mutable_appearance(limb_icon, "legdam_[BP.body_zone]_0[BP.burnstate]", -LEG_DAMAGE_LAYER)
			legdam_overlays += legdam_overlay
			var/mutable_appearance/armdam_overlay = mutable_appearance(limb_icon, "armdam_[BP.body_zone]_0[BP.burnstate]", -ARM_DAMAGE_LAYER)
			armdam_overlays += armdam_overlay
		var/checker = FALSE
		if(BP.get_bleedrate())
			checker = TRUE
			if(BP.bandage)
				var/mutable_appearance/damage_overlay = mutable_appearance(limb_icon, "[BP.body_zone]_b", -DAMAGE_LAYER)
				damage_overlay.color = BP.bandage.color
				damage_overlays += damage_overlay
				var/mutable_appearance/legdam_overlay = mutable_appearance(limb_icon, "legdam_[BP.body_zone]_b", -LEG_DAMAGE_LAYER)
				legdam_overlay.color = BP.bandage.color
				legdam_overlays += legdam_overlay
				var/mutable_appearance/armdam_overlay = mutable_appearance(limb_icon, "armdam_[BP.body_zone]_b", -ARM_DAMAGE_LAYER)
				armdam_overlay.color = BP.bandage.color
				armdam_overlays += armdam_overlay
		for(var/datum/wound/W in BP.wounds)
			if(!BP.skeletonized)
				var/mutable_appearance/damage_overlay = mutable_appearance(limb_icon, "[BP.body_zone]_[W.mob_overlay]", -DAMAGE_LAYER)
				damage_overlays += damage_overlay
				var/mutable_appearance/legdam_overlay = mutable_appearance(limb_icon, "legdam_[BP.body_zone]_[W.mob_overlay]", -LEG_DAMAGE_LAYER)
				legdam_overlays += legdam_overlay
				var/mutable_appearance/armdam_overlay = mutable_appearance(limb_icon, "armdam_[BP.body_zone]_[W.mob_overlay]", -ARM_DAMAGE_LAYER)
				armdam_overlays += armdam_overlay
		if(!checker)
			if(BP.bandage)
				var/mutable_appearance/damage_overlay = mutable_appearance(limb_icon, "[BP.body_zone]_b", -DAMAGE_LAYER)
				damage_overlay.color = BP.bandage.color
				damage_overlays += damage_overlay
				var/mutable_appearance/legdam_overlay = mutable_appearance(limb_icon, "legdam_[BP.body_zone]_b", -LEG_DAMAGE_LAYER)
				legdam_overlay.color = BP.bandage.color
				legdam_overlays += legdam_overlay
				var/mutable_appearance/armdam_overlay = mutable_appearance(limb_icon, "armdam_[BP.body_zone]_b", -ARM_DAMAGE_LAYER)
				armdam_overlay.color = BP.bandage.color
				armdam_overlays += armdam_overlay
		if(BP.aux_zone && !((BP.body_zone == BODY_ZONE_CHEST) && hidechest) )
			if(BP.brutestate && !BP.skeletonized)
				var/mutable_appearance/damage_overlay = mutable_appearance(limb_icon, "[BP.aux_zone]_[BP.brutestate]0", -DAMAGE_LAYER)
				damage_overlays += damage_overlay
				var/mutable_appearance/legdam_overlay = mutable_appearance(limb_icon, "legdam_[BP.aux_zone]_[BP.brutestate]0", -LEG_DAMAGE_LAYER)
				legdam_overlays += legdam_overlay
				var/mutable_appearance/armdam_overlay = mutable_appearance(limb_icon, "armdam_[BP.aux_zone]_[BP.brutestate]0", -ARM_DAMAGE_LAYER)
				armdam_overlays += armdam_overlay
			if(BP.burnstate && !BP.skeletonized)
				var/mutable_appearance/damage_overlay = mutable_appearance(limb_icon, "[BP.aux_zone]_0[BP.burnstate]", -DAMAGE_LAYER)
				damage_overlays += damage_overlay
				var/mutable_appearance/legdam_overlay = mutable_appearance(limb_icon, "legdam_[BP.aux_zone]_0[BP.burnstate]", -LEG_DAMAGE_LAYER)
				legdam_overlays += legdam_overlay
				var/mutable_appearance/armdam_overlay = mutable_appearance(limb_icon, "armdam_[BP.aux_zone]_0[BP.burnstate]", -ARM_DAMAGE_LAYER)
				armdam_overlays += armdam_overlay
			if(checker)
				if(BP.bandage)
					var/mutable_appearance/damage_overlay = mutable_appearance(limb_icon, "[BP.aux_zone]_b", -DAMAGE_LAYER)
					damage_overlay.color = BP.bandage.color
					damage_overlays += damage_overlay
					var/mutable_appearance/legdam_overlay = mutable_appearance(limb_icon, "legdam_[BP.aux_zone]_b", -LEG_DAMAGE_LAYER)
					legdam_overlay.color = BP.bandage.color
					legdam_overlays += legdam_overlay
					var/mutable_appearance/armdam_overlay = mutable_appearance(limb_icon, "armdam_[BP.aux_zone]_b", -ARM_DAMAGE_LAYER)
					armdam_overlay.color = BP.bandage.color
					armdam_overlays += armdam_overlay
			for(var/datum/wound/W in BP.wounds)
				if(!BP.skeletonized)
					var/mutable_appearance/damage_overlay = mutable_appearance(limb_icon, "[BP.aux_zone]_[W.mob_overlay]", -DAMAGE_LAYER)
					damage_overlays += damage_overlay
					var/mutable_appearance/legdam_overlay = mutable_appearance(limb_icon, "legdam_[BP.aux_zone]_[W.mob_overlay]", -LEG_DAMAGE_LAYER)
					legdam_overlays += legdam_overlay
					var/mutable_appearance/armdam_overlay = mutable_appearance(limb_icon, "armdam_[BP.aux_zone]_[W.mob_overlay]", -ARM_DAMAGE_LAYER)
					armdam_overlays += armdam_overlay
			if(!checker)
				if(BP.bandage)
					var/mutable_appearance/damage_overlay = mutable_appearance(limb_icon, "[BP.aux_zone]_b", -DAMAGE_LAYER)
					damage_overlay.color = BP.bandage.color
					damage_overlays += damage_overlay
					var/mutable_appearance/legdam_overlay = mutable_appearance(limb_icon, "legdam_[BP.aux_zone]_b", -LEG_DAMAGE_LAYER)
					legdam_overlay.color = BP.bandage.color
					legdam_overlays += legdam_overlay
					var/mutable_appearance/armdam_overlay = mutable_appearance(limb_icon, "armdam_[BP.aux_zone]_b", -ARM_DAMAGE_LAYER)
					armdam_overlay.color = BP.bandage.color
					armdam_overlays += armdam_overlay

		var/used_offset = BP.offset
		if(gender == FEMALE)
			used_offset = BP.offset_f


		for(var/mutable_appearance/M in damage_overlays)
			if(used_offset in dna.species.offset_features)
				M.pixel_x += dna.species.offset_features[g][1]
				M.pixel_y += dna.species.offset_features[g][2]
			limb_overlaysa += M
		for(var/mutable_appearance/M in legdam_overlays)
			if(used_offset in dna.species.offset_features)
				M.pixel_x += dna.species.offset_features[g][1]
				M.pixel_y += dna.species.offset_features[g][2]
			limb_overlaysb += M
		for(var/mutable_appearance/M in armdam_overlays)
			if(used_offset in dna.species.offset_features)
				M.pixel_x += dna.species.offset_features[g][1]
				M.pixel_y += dna.species.offset_features[g][2]
			limb_overlaysc += M

	overlays_standing[DAMAGE_LAYER] = limb_overlaysa
	overlays_standing[LEG_DAMAGE_LAYER] = limb_overlaysb
	overlays_standing[ARM_DAMAGE_LAYER] = limb_overlaysc

	apply_overlay(DAMAGE_LAYER)
	apply_overlay(LEG_DAMAGE_LAYER)
	apply_overlay(ARM_DAMAGE_LAYER)


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	if(!..())
		icon_render_key = null //invalidate bodyparts cache
		if(dna.species)
			if(dna.species.regenerate_icons(src))
				return
		update_body()
		update_hair()
//		update_inv_w_uniform()
		update_inv_wear_id()
		update_inv_gloves()
//		update_inv_glasses()
//		update_inv_ears()
		update_inv_shoes()
//		update_inv_s_store()
		update_inv_wear_mask()
		update_inv_head()
		update_inv_belt()
		update_inv_back()
//		update_inv_wear_suit()
		update_inv_armor()
		update_inv_pockets()
		update_inv_neck()
		update_inv_cloak()
		update_inv_pants()
		update_inv_shirt()
		update_inv_mouth()
		update_transform()
		//mutations
		update_mutations_overlay()
		//damage overlays
		update_damage_overlays()

/mob/proc/regenerate_clothes()
	return
/mob/living/carbon/human/regenerate_clothes()
	update_inv_wear_id()
	update_inv_gloves()
	update_inv_shoes()
	update_inv_wear_mask()
	update_inv_head()
	update_inv_belt()
	update_inv_back()
	update_inv_armor()
	update_inv_pockets()
	update_inv_neck()
	update_inv_cloak()
	update_inv_pants()
	update_inv_shirt()
	update_inv_mouth()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform()
	return
/*
	remove_overlay(PANTS_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_PANTS]
		inv.update_icon()

	if(istype(wear_pants, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = wear_pants
		U.screen_loc = rogueui_pants
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += wear_pants
		update_observer_view(wear_pants,1)

		if(wear_armor && (wear_armor.flags_inv & HIDEJUMPSUIT))
			return


		var/target_overlay = U.icon_state
		if(U.adjusted == ALT_STYLE)
			target_overlay = "[target_overlay]_d"
		else if(U.adjusted == DIGITIGRADE_STYLE)
			target_overlay = "[target_overlay]_l"


		var/mutable_appearance/uniform_overlay

		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			if(G == "f" && U.fitted != NO_FEMALE_UNIFORM)
				uniform_overlay = U.build_worn_icon(default_layer = PANTS_LAYER, default_icon_file = 'icons/mob/clothing/under/default.dmi', isinhands = FALSE, femaleuniform = U.fitted, override_state = target_overlay)

		if(!uniform_overlay)
			uniform_overlay = U.build_worn_icon(default_layer = PANTS_LAYER, default_icon_file = 'icons/mob/clothing/under/default.dmi', isinhands = FALSE, override_state = target_overlay)

		if(gender == MALE)
			if(OFFSET_UNIFORM in dna.species.offset_features)
				uniform_overlay.pixel_x += dna.species.offset_features[OFFSET_UNIFORM][1]
				uniform_overlay.pixel_y += dna.species.offset_features[OFFSET_UNIFORM][2]

		overlays_standing[PANTS_LAYER] = uniform_overlay

	apply_overlay(PANTS_LAYER)
	update_mutant_bodyparts()
*/



/mob/living/carbon/human/update_inv_neck()
	remove_overlay(NECK_LAYER)

	if(client && hud_used && hud_used.inv_slots[SLOT_NECK])
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_NECK]
		inv.update_icon()

	if(wear_neck)
		var/mutable_appearance/neck_overlay

		if(!(SLOT_NECK in check_obscured_slots()))
			neck_overlay = wear_neck.build_worn_icon(default_layer = NECK_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/neck.dmi')
			if(gender == MALE)
				if(OFFSET_NECK in dna.species.offset_features)
					neck_overlay.pixel_x += dna.species.offset_features[OFFSET_NECK][1]
					neck_overlay.pixel_y += dna.species.offset_features[OFFSET_NECK][2]
			else
				if(OFFSET_NECK_F in dna.species.offset_features)
					neck_overlay.pixel_x += dna.species.offset_features[OFFSET_NECK_F][1]
					neck_overlay.pixel_y += dna.species.offset_features[OFFSET_NECK_F][2]
			overlays_standing[NECK_LAYER] = neck_overlay

		update_hud_neck(wear_neck)
	update_hair()
	apply_overlay(NECK_LAYER)

/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(RING_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_RING]
		inv.update_icon()

	var/mutable_appearance/id_overlay

	if(wear_ring)
		wear_ring.screen_loc = rogueui_ringr
		if(client && hud_used && hud_used.hud_shown)
			client.screen += wear_ring
		update_observer_view(wear_ring)
		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			if(G == "f" || dna.species.use_f)
				id_overlay = wear_ring.build_worn_icon(default_layer = RING_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = TRUE)
			else
				id_overlay = wear_ring.build_worn_icon(default_layer = RING_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = FALSE)
		if(gender == MALE)
			if(OFFSET_ID in dna.species.offset_features)
				id_overlay.pixel_x += dna.species.offset_features[OFFSET_ID][1]
				id_overlay.pixel_y += dna.species.offset_features[OFFSET_ID][2]
		else
			if(OFFSET_ID_F in dna.species.offset_features)
				id_overlay.pixel_x += dna.species.offset_features[OFFSET_ID_F][1]
				id_overlay.pixel_y += dna.species.offset_features[OFFSET_ID_F][2]
		overlays_standing[RING_LAYER] = id_overlay

	apply_overlay(RING_LAYER)


/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)
	remove_overlay(GLOVESLEEVE_LAYER)

	if(client && hud_used && hud_used.inv_slots[SLOT_GLOVES])
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_GLOVES]
		inv.update_icon()

	if(!gloves && bloody_hands)
		var/mutable_appearance/bloody_overlay = mutable_appearance('icons/effects/blood.dmi', "bloodyhands", -GLOVES_LAYER)
		if(get_num_arms(FALSE) < 2)
			if(has_left_hand(FALSE))
				bloody_overlay.icon_state = "bloodyhands_left"
			else if(has_right_hand(FALSE))
				bloody_overlay.icon_state = "bloodyhands_right"

		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			if(G == "f")
				bloody_overlay.icon_state += "_f"

		overlays_standing[GLOVESLEEVE_LAYER] = bloody_overlay

	if(gloves)
		gloves.screen_loc = rogueui_gloves
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += gloves
		update_observer_view(gloves,1)
		if(dna && dna.species.sexes)
			var/racecustom
			var/mutable_appearance/gloves_overlay
			if(dna.species.custom_clothes)
				racecustom = dna.species.id
			var/G = (gender == FEMALE) ? "f" : "m"
			var/armsindex = get_limbloss_index(ARM_RIGHT, ARM_LEFT)
			if(G == "f" || dna.species.use_f)
				gloves_overlay = gloves.build_worn_icon(default_layer = GLOVES_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = TRUE, sleeveindex = armsindex)
			else
				gloves_overlay = gloves.build_worn_icon(default_layer = GLOVES_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = FALSE, sleeveindex = armsindex, customi = racecustom)

			if(gender == MALE)
				if(OFFSET_GLOVES in dna.species.offset_features)
					gloves_overlay.pixel_x += dna.species.offset_features[OFFSET_GLOVES][1]
					gloves_overlay.pixel_y += dna.species.offset_features[OFFSET_GLOVES][2]
			else
				if(OFFSET_GLOVES_F in dna.species.offset_features)
					gloves_overlay.pixel_x += dna.species.offset_features[OFFSET_GLOVES_F][1]
					gloves_overlay.pixel_y += dna.species.offset_features[OFFSET_GLOVES_F][2]
			overlays_standing[GLOVES_LAYER] = gloves_overlay

			//add sleeve overlays, then offset
			var/list/sleeves = list()
			if(gloves.sleeved && armsindex > 0)
				sleeves = get_sleeves_layer(gloves,armsindex,GLOVESLEEVE_LAYER)

			if(sleeves)
				for(var/X in sleeves)
					var/mutable_appearance/S = X
					if(gender == MALE)
						if(OFFSET_GLOVES in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_GLOVES][1]
							S.pixel_y += dna.species.offset_features[OFFSET_GLOVES][2]
					else
						if(OFFSET_GLOVES_F in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_GLOVES_F][1]
							S.pixel_y += dna.species.offset_features[OFFSET_GLOVES_F][2]
				overlays_standing[GLOVESLEEVE_LAYER] = sleeves


	apply_overlay(GLOVES_LAYER)
	apply_overlay(GLOVESLEEVE_LAYER)

/mob/living/carbon/human/update_inv_wrists()
	remove_overlay(WRISTS_LAYER)
	remove_overlay(WRISTSLEEVE_LAYER)

	if(client && hud_used && hud_used.inv_slots[SLOT_WRISTS])
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_WRISTS]
		inv.update_icon()

	if(wear_wrists)
		wear_wrists.screen_loc = rogueui_wrists
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += wear_wrists
		update_observer_view(wear_wrists,1)
		if(dna && dna.species.sexes)
			var/racecustom
			if(dna.species.custom_clothes)
				racecustom = dna.species.id
			var/G = (gender == FEMALE) ? "f" : "m"
			var/armsindex = get_limbloss_index(ARM_RIGHT, ARM_LEFT)
			var/mutable_appearance/wrists_overlay
			if(G == "f" || dna.species.use_f)
				wrists_overlay = wear_wrists.build_worn_icon(default_layer = WRISTS_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = TRUE, sleeveindex = armsindex)
			else
				wrists_overlay = wear_wrists.build_worn_icon(default_layer = WRISTS_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = FALSE, sleeveindex = armsindex, customi = racecustom)

			if(gender == MALE)
				if(OFFSET_WRISTS in dna.species.offset_features)
					wrists_overlay.pixel_x += dna.species.offset_features[OFFSET_WRISTS][1]
					wrists_overlay.pixel_y += dna.species.offset_features[OFFSET_WRISTS][2]
			else
				if(OFFSET_WRISTS_F in dna.species.offset_features)
					wrists_overlay.pixel_x += dna.species.offset_features[OFFSET_WRISTS_F][1]
					wrists_overlay.pixel_y += dna.species.offset_features[OFFSET_WRISTS_F][2]
			overlays_standing[WRISTS_LAYER] = wrists_overlay

			//add sleeve overlays, then offset
			var/list/sleeves = list()
			if(wear_wrists.sleeved && armsindex > 0)
				sleeves = get_sleeves_layer(wear_wrists,armsindex,WRISTSLEEVE_LAYER)

			if(sleeves)
				for(var/X in sleeves)
					var/mutable_appearance/S = X
					if(gender == MALE)
						if(OFFSET_WRISTS in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_WRISTS][1]
							S.pixel_y += dna.species.offset_features[OFFSET_WRISTS][2]
					else
						if(OFFSET_WRISTS_F in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_WRISTS_F][1]
							S.pixel_y += dna.species.offset_features[OFFSET_WRISTS_F][2]
				overlays_standing[WRISTSLEEVE_LAYER] = sleeves

	apply_overlay(WRISTS_LAYER)
	apply_overlay(WRISTSLEEVE_LAYER)

/mob/living/carbon/human/update_inv_glasses()
	/*
	remove_overlay(GLASSES_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //decapitated
		return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_GLASSES]
		inv.update_icon()

	if(glasses)
		glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				client.screen += glasses				//Either way, add the item to the HUD
		update_observer_view(glasses,1)
		if(!(head && (head.flags_inv & HIDEEYES)) && !(wear_mask && (wear_mask.flags_inv & HIDEEYES)))
			overlays_standing[GLASSES_LAYER] = glasses.build_worn_icon(default_layer = GLASSES_LAYER, default_icon_file = 'icons/mob/clothing/eyes.dmi')

		var/mutable_appearance/glasses_overlay = overlays_standing[GLASSES_LAYER]
		if(glasses_overlay)
			if(OFFSET_GLASSES in dna.species.offset_features)
				glasses_overlay.pixel_x += dna.species.offset_features[OFFSET_GLASSES][1]
				glasses_overlay.pixel_y += dna.species.offset_features[OFFSET_GLASSES][2]
			overlays_standing[GLASSES_LAYER] = glasses_overlay
	apply_overlay(GLASSES_LAYER)*/
	return


/mob/living/carbon/human/update_inv_ears()
	/*
	remove_overlay(MASK_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //decapitated
		return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_WEAR_MASK]
		inv.update_icon()

	if(ears)
		ears.screen_loc = ui_ears	//move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += ears					//add it to the client's screen
		update_observer_view(ears,1)
		overlays_standing[MASK_LAYER] = ears.build_worn_icon(default_layer = MASK_LAYER, default_icon_file = 'icons/mob/clothing/ears.dmi')
		var/mutable_appearance/ears_overlay = overlays_standing[MASK_LAYER]
		if(OFFSET_EARS in dna.species.offset_features)
			ears_overlay.pixel_x += dna.species.offset_features[OFFSET_EARS][1]
			ears_overlay.pixel_y += dna.species.offset_features[OFFSET_EARS][2]
		overlays_standing[MASK_LAYER] = ears_overlay
	apply_overlay(MASK_LAYER)*/
	return


/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)
	remove_overlay(SHOESLEEVE_LAYER)
	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_SHOES]
		inv.update_icon()

	if(shoes)
		shoes.screen_loc = rogueui_shoes					//move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += shoes					//add it to client's screen
		update_observer_view(shoes,1)
		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			var/footindex = get_limbloss_index(LEG_RIGHT, LEG_LEFT)
			var/racecustom
			var/mutable_appearance/shoes_overlay
			if(dna.species.custom_clothes)
				racecustom = dna.species.id
			if(G == "f" || dna.species.use_f)
				shoes_overlay = shoes.build_worn_icon(default_layer = SHOES_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "f", customi = racecustom, sleeveindex = footindex)
			else
				shoes_overlay = shoes.build_worn_icon(default_layer = SHOES_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = FALSE, customi = racecustom, sleeveindex = footindex)

			if(OFFSET_SHOES in dna.species.offset_features)
				shoes_overlay.pixel_x += dna.species.offset_features[OFFSET_SHOES][1]
				shoes_overlay.pixel_y += dna.species.offset_features[OFFSET_SHOES][2]
			overlays_standing[SHOES_LAYER] = shoes_overlay

			//add sleeve overlays, then offset
			var/list/sleeves = list()
			if(shoes.sleeved && footindex > 0)
				sleeves = get_sleeves_layer(shoes,footindex,SHOESLEEVE_LAYER)
			if(sleeves)
				for(var/X in sleeves)
					var/mutable_appearance/S = X
					if(OFFSET_SHOES in dna.species.offset_features)
						S.pixel_x += dna.species.offset_features[OFFSET_SHOES][1]
						S.pixel_y += dna.species.offset_features[OFFSET_SHOES][2]

				overlays_standing[SHOESLEEVE_LAYER] = sleeves

	apply_overlay(SHOES_LAYER)
	apply_overlay(SHOESLEEVE_LAYER)

/mob/living/carbon/human/update_inv_s_store()
/*
	remove_overlay(BELT_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_S_STORE]
		inv.update_icon()

	if(s_store)
		s_store.screen_loc = ui_sstore1
		if(client && hud_used && hud_used.hud_shown)
			client.screen += s_store
		update_observer_view(s_store)
		var/t_state = s_store.item_state
		if(!t_state)
			t_state = s_store.icon_state
		overlays_standing[BELT_LAYER]	= mutable_appearance('icons/mob/clothing/belt_mirror.dmi', t_state, -BELT_LAYER)
		var/mutable_appearance/s_store_overlay = overlays_standing[BELT_LAYER]
		if(OFFSET_S_STORE in dna.species.offset_features)
			s_store_overlay.pixel_x += dna.species.offset_features[OFFSET_S_STORE][1]
			s_store_overlay.pixel_y += dna.species.offset_features[OFFSET_S_STORE][2]
		overlays_standing[BELT_LAYER] = s_store_overlay
	apply_overlay(BELT_LAYER)*/
	return


/mob/living/carbon/human/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used && hud_used.inv_slots[SLOT_HEAD])
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_HEAD]
		inv.update_icon()

	if(head)
		update_hud_head(head)
		update_mutant_bodyparts()
//		var/G = (gender == FEMALE) ? "f" : "m"
//		if(G == "f" || dna.species.use_f)
//			overlays_standing[HEAD_LAYER] = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "e")
//		else
		overlays_standing[HEAD_LAYER] = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/head.dmi', coom = FALSE)
		var/mutable_appearance/head_overlay = overlays_standing[HEAD_LAYER]
		if(head_overlay)
			remove_overlay(HEAD_LAYER)
			if(gender == MALE)
				if(OFFSET_HEAD in dna.species.offset_features)
					head_overlay.pixel_x += dna.species.offset_features[OFFSET_HEAD][1]
					head_overlay.pixel_y += dna.species.offset_features[OFFSET_HEAD][2]
			else
				if(OFFSET_HEAD_F in dna.species.offset_features)
					head_overlay.pixel_x += dna.species.offset_features[OFFSET_HEAD_F][1]
					head_overlay.pixel_y += dna.species.offset_features[OFFSET_HEAD_F][2]
			overlays_standing[HEAD_LAYER] = head_overlay
		apply_overlay(HEAD_LAYER)

	update_hair() //hoodies

/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)
	remove_overlay(BELT_BEHIND_LAYER)

	var/list/standing_front = list()
	var/list/standing_behind = list()

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_BELT]
		inv.update_icon()
		inv = hud_used.inv_slots[SLOT_BELT_R]
		inv.update_icon()
		inv = hud_used.inv_slots[SLOT_BELT_L]
		inv.update_icon()

	if(beltr)
		beltr.screen_loc = rogueui_beltr
		if(client && hud_used && hud_used.hud_shown)
			client.screen += beltr
		update_observer_view(beltr)
		if(!(cloak && (cloak.flags_inv & HIDEBELT)))
			var/mutable_appearance/onbelt_overlay
			var/mutable_appearance/onbelt_behind
			if(beltr.experimental_onhip)
				var/list/prop
				if(beltr.force_reupdate_inhand)
					prop = beltr.onprop["onbelt"]
					if(!prop)
						beltr.onprop["onbelt"] = beltr.getonmobprop("onbelt")
						prop = beltr.onprop["onbelt"]
				else
					prop = beltr.getonmobprop("onbelt")
				if(prop)
					onbelt_overlay = mutable_appearance(beltr.getmoboverlay("onbelt",prop,mirrored=FALSE), layer=-BELT_LAYER)
					onbelt_behind = mutable_appearance(beltr.getmoboverlay("onbelt",prop,behind=TRUE,mirrored=FALSE), layer=-BELT_BEHIND_LAYER)
					onbelt_overlay = center_image(onbelt_overlay, beltr.inhand_x_dimension, beltr.inhand_y_dimension)
					onbelt_behind = center_image(onbelt_behind, beltr.inhand_x_dimension, beltr.inhand_y_dimension)
					if(ishuman(src))
						var/mob/living/carbon/human/H = src
						if(H.dna && H.dna.species)
							if(gender == MALE)
								if(OFFSET_BELT in H.dna.species.offset_features)
									onbelt_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BELT][1]
									onbelt_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BELT][2]
									onbelt_behind.pixel_x += H.dna.species.offset_features[OFFSET_BELT][1]
									onbelt_behind.pixel_y += H.dna.species.offset_features[OFFSET_BELT][2]
							else
								if(OFFSET_BELT_F in H.dna.species.offset_features)
									onbelt_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BELT_F][1]
									onbelt_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BELT_F][2]
									onbelt_behind.pixel_x += H.dna.species.offset_features[OFFSET_BELT_F][1]
									onbelt_behind.pixel_y += H.dna.species.offset_features[OFFSET_BELT_F][2]
					standing_front += onbelt_overlay
					standing_behind += onbelt_behind
			else
				onbelt_overlay = beltr.build_worn_icon(default_layer = BELT_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/belt_r.dmi')
				if(onbelt_overlay)
					if(gender == MALE)
						if(OFFSET_BELT in dna.species.offset_features)
							onbelt_overlay.pixel_x += dna.species.offset_features[OFFSET_BELT][1]
							onbelt_overlay.pixel_y += dna.species.offset_features[OFFSET_BELT][2]
					else
						if(OFFSET_BELT_F in dna.species.offset_features)
							onbelt_overlay.pixel_x += dna.species.offset_features[OFFSET_BELT_F][1]
							onbelt_overlay.pixel_y += dna.species.offset_features[OFFSET_BELT_F][2]
				standing_front += onbelt_overlay

	if(beltl)
		beltl.screen_loc = rogueui_beltl
		if(client && hud_used && hud_used.hud_shown)
			client.screen += beltl
		update_observer_view(beltl)
		if(!(cloak && (cloak.flags_inv & HIDEBELT)))
			var/mutable_appearance/onbelt_overlay
			var/mutable_appearance/onbelt_behind
			if(beltl.experimental_onhip)
				var/list/prop
				if(beltl.force_reupdate_inhand)
					prop = beltl.onprop["onbelt"]
					if(!prop)
						beltl.onprop["onbelt"] = beltl.getonmobprop("onbelt")
						prop = beltl.onprop["onbelt"]
				else
					prop = beltl.getonmobprop("onbelt")
				if(prop)
					onbelt_overlay = mutable_appearance(beltl.getmoboverlay("onbelt",prop,mirrored=TRUE), layer=-BELT_LAYER)
					onbelt_behind = mutable_appearance(beltl.getmoboverlay("onbelt",prop,behind=TRUE,mirrored=TRUE), layer=-BELT_BEHIND_LAYER)
					onbelt_overlay = center_image(onbelt_overlay, beltl.inhand_x_dimension, beltl.inhand_y_dimension)
					onbelt_behind = center_image(onbelt_behind, beltl.inhand_x_dimension, beltl.inhand_y_dimension)
					if(ishuman(src))
						var/mob/living/carbon/human/H = src
						if(H.dna && H.dna.species)
							if(gender == MALE)
								if(OFFSET_BELT in H.dna.species.offset_features)
									onbelt_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BELT][1]
									onbelt_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BELT][2]
									onbelt_behind.pixel_x += H.dna.species.offset_features[OFFSET_BELT][1]
									onbelt_behind.pixel_y += H.dna.species.offset_features[OFFSET_BELT][2]
							else
								if(OFFSET_BELT_F in H.dna.species.offset_features)
									onbelt_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BELT_F][1]
									onbelt_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BELT_F][2]
									onbelt_behind.pixel_x += H.dna.species.offset_features[OFFSET_BELT_F][1]
									onbelt_behind.pixel_y += H.dna.species.offset_features[OFFSET_BELT_F][2]
					standing_front += onbelt_overlay
					standing_behind += onbelt_behind
			else
				onbelt_overlay = beltl.build_worn_icon(default_layer = BELT_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/belt_l.dmi')
				if(onbelt_overlay)
					if(gender == MALE)
						if(OFFSET_BELT in dna.species.offset_features)
							onbelt_overlay.pixel_x += dna.species.offset_features[OFFSET_BELT][1]
							onbelt_overlay.pixel_y += dna.species.offset_features[OFFSET_BELT][2]
					else
						if(OFFSET_BELT_F in dna.species.offset_features)
							onbelt_overlay.pixel_x += dna.species.offset_features[OFFSET_BELT_F][1]
							onbelt_overlay.pixel_y += dna.species.offset_features[OFFSET_BELT_F][2]
				standing_front += onbelt_overlay

	if(belt)
		belt.screen_loc = rogueui_belt
		if(client && hud_used && hud_used.hud_shown)
			client.screen += belt
		update_observer_view(belt)
		if(!(cloak && (cloak.flags_inv & HIDEBELT)))
			if(dna && dna.species.sexes)
				var/G = (gender == FEMALE) ? "f" : "m"
				var/racecustom
				var/mutable_appearance/mbeltoverlay
				if(dna.species.custom_clothes)
					racecustom = dna.species.id
				if(G == "f" || dna.species.use_f)
					mbeltoverlay = belt.build_worn_icon(default_layer = BELT_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/belts.dmi', coom = "f", customi = racecustom)
				else
					mbeltoverlay = belt.build_worn_icon(default_layer = BELT_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/belts.dmi', coom = FALSE, customi = racecustom)
				if(mbeltoverlay && !dna.species.custom_clothes)
					if(gender == MALE)
						if(OFFSET_BELT in dna.species.offset_features)
							mbeltoverlay.pixel_x += dna.species.offset_features[OFFSET_BELT][1]
							mbeltoverlay.pixel_y += dna.species.offset_features[OFFSET_BELT][2]
					else
						if(OFFSET_BELT_F in dna.species.offset_features)
							mbeltoverlay.pixel_x += dna.species.offset_features[OFFSET_BELT_F][1]
							mbeltoverlay.pixel_y += dna.species.offset_features[OFFSET_BELT_F][2]
				standing_front += mbeltoverlay

	overlays_standing[BELT_LAYER] = standing_front
	overlays_standing[BELT_BEHIND_LAYER] = standing_behind

	apply_overlay(BELT_LAYER)
	apply_overlay(BELT_BEHIND_LAYER)



/mob/living/carbon/human/update_inv_wear_suit()
	return
/*
	remove_overlay(ARMOR_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_ARMOR]
		inv.update_icon()

	if(istype(wear_armor, /obj/item/clothing/suit))
		wear_armor.screen_loc = rogueui_armor
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += wear_armor
		update_observer_view(wear_armor,1)
		overlays_standing[ARMOR_LAYER] = wear_armor.build_worn_icon(default_layer = ARMOR_LAYER, default_icon_file = 'icons/mob/clothing/suit.dmi')
		var/mutable_appearance/suit_overlay = overlays_standing[ARMOR_LAYER]
		if(OFFSET_SUIT in dna.species.offset_features)
			suit_overlay.pixel_x += dna.species.offset_features[OFFSET_SUIT][1]
			suit_overlay.pixel_y += dna.species.offset_features[OFFSET_SUIT][2]
		overlays_standing[ARMOR_LAYER] = suit_overlay
	update_hair()
	update_mutant_bodyparts()

	apply_overlay(ARMOR_LAYER)
*/

/mob/living/carbon/human/update_inv_pockets()
	return/*
	if(client && hud_used)
		var/obj/screen/inventory/inv

		inv = hud_used.inv_slots[SLOT_L_STORE]
		inv.update_icon()

		inv = hud_used.inv_slots[SLOT_R_STORE]
		inv.update_icon()

		if(l_store)
			l_store.screen_loc = ui_storage1
			if(hud_used.hud_shown)
				client.screen += l_store
			update_observer_view(l_store)

		if(r_store)
			r_store.screen_loc = ui_storage2
			if(hud_used.hud_shown)
				client.screen += r_store
			update_observer_view(r_store)*/


/mob/living/carbon/human/update_inv_wear_mask()
	..()
	var/mutable_appearance/mask_overlay = overlays_standing[MASK_LAYER]
	if(mask_overlay)
		remove_overlay(MASK_LAYER)
		if(gender == MALE)
			if(OFFSET_FACEMASK in dna.species.offset_features)
				mask_overlay.pixel_x += dna.species.offset_features[OFFSET_FACEMASK][1]
				mask_overlay.pixel_y += dna.species.offset_features[OFFSET_FACEMASK][2]
		else
			if(OFFSET_FACEMASK_F in dna.species.offset_features)
				mask_overlay.pixel_x += dna.species.offset_features[OFFSET_FACEMASK_F][1]
				mask_overlay.pixel_y += dna.species.offset_features[OFFSET_FACEMASK_F][2]
		overlays_standing[MASK_LAYER] = mask_overlay
		apply_overlay(MASK_LAYER)
	update_mutant_bodyparts() //e.g. upgate needed because mask now hides lizard snout

/mob/living/carbon/human/update_inv_back()
	remove_overlay(BACK_LAYER)
	remove_overlay(BACK_BEHIND_LAYER)
	remove_overlay(UNDER_CLOAK_LAYER)
	var/list/overcloaks = list()
	var/list/undercloaks = list()
	var/list/backbehind = list()
	if(client && hud_used && hud_used.inv_slots[SLOT_BACK])
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_BACK]
		inv.update_icon()
		inv = hud_used.inv_slots[SLOT_BACK_R]
		inv.update_icon()
		inv = hud_used.inv_slots[SLOT_BACK_L]
		inv.update_icon()
	if(backr)
		if(backr.alternate_worn_layer == CLOAK_BEHIND_LAYER)
			update_inv_cloak()
		else
			var/mutable_appearance/back_overlay
			var/mutable_appearance/behindback_overlay
			update_hud_backr(backr)
			if(backr.experimental_onback)
				var/list/prop
				if(backr.force_reupdate_inhand)
					prop = backr.onprop["onback"]
					if(!prop)
						backr.onprop["onback"] = backr.getonmobprop("onback")
						prop = backr.onprop["onback"]
				else
					prop = backr.getonmobprop("onback")
				if(prop)
					back_overlay = mutable_appearance(backr.getmoboverlay("onback",prop,mirrored=FALSE), layer=-BACK_LAYER)
					behindback_overlay = mutable_appearance(backr.getmoboverlay("onback",prop,behind=TRUE,mirrored=FALSE), layer=-BACK_BEHIND_LAYER)
					back_overlay = center_image(back_overlay, backr.inhand_x_dimension, backr.inhand_y_dimension)
					behindback_overlay = center_image(behindback_overlay, backr.inhand_x_dimension, backr.inhand_y_dimension)
					if(ishuman(src))
						var/mob/living/carbon/human/H = src
						if(H.dna && H.dna.species)
							if(gender == MALE)
								if(OFFSET_BACK in H.dna.species.offset_features)
									back_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BACK][1]
									back_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BACK][2]
									behindback_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BACK][1]
									behindback_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BACK][2]
							else
								if(OFFSET_BACK_F in H.dna.species.offset_features)
									back_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BACK_F][1]
									back_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BACK_F][2]
									behindback_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BACK_F][1]
									behindback_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BACK_F][2]
					overcloaks += back_overlay
					backbehind += behindback_overlay
			else
				back_overlay = backr.build_worn_icon(default_layer = BACK_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/back_r.dmi')
				if(gender == MALE)
					if(OFFSET_BACK in dna.species.offset_features)
						back_overlay.pixel_x += dna.species.offset_features[OFFSET_BACK][1]
						back_overlay.pixel_y += dna.species.offset_features[OFFSET_BACK][2]
				else
					if(OFFSET_BACK_F in dna.species.offset_features)
						back_overlay.pixel_x += dna.species.offset_features[OFFSET_BACK_F][1]
						back_overlay.pixel_y += dna.species.offset_features[OFFSET_BACK_F][2]
				if(backr.alternate_worn_layer == UNDER_CLOAK_LAYER)
					undercloaks += back_overlay
				else
					overcloaks += back_overlay

	if(backl)
		if(backl.alternate_worn_layer == CLOAK_BEHIND_LAYER)
			update_inv_cloak()
		else
			update_hud_backl(backl)
			var/mutable_appearance/back_overlay
			var/mutable_appearance/behindback_overlay
			if(backl.experimental_onback)
				var/list/prop
				if(backl.force_reupdate_inhand)
					prop = backl.onprop["onback"]
					if(!prop)
						backl.onprop["onback"] = backl.getonmobprop("onback")
						prop = backl.onprop["onback"]
				else
					prop = backl.getonmobprop("onback")
				if(prop)
					back_overlay = mutable_appearance(backl.getmoboverlay("onback",prop,mirrored=TRUE), layer=-BACK_LAYER)
					behindback_overlay = mutable_appearance(backl.getmoboverlay("onback",prop,behind=TRUE,mirrored=TRUE), layer=-BACK_BEHIND_LAYER)
					back_overlay = center_image(back_overlay, backl.inhand_x_dimension, backl.inhand_y_dimension)
					behindback_overlay = center_image(behindback_overlay, backl.inhand_x_dimension, backl.inhand_y_dimension)
					if(ishuman(src))
						var/mob/living/carbon/human/H = src
						if(H.dna && H.dna.species)
							if(gender == MALE)
								if(OFFSET_BACK in H.dna.species.offset_features)
									back_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BACK][1]
									back_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BACK][2]
									behindback_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BACK][1]
									behindback_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BACK][2]
							else
								if(OFFSET_BACK_F in H.dna.species.offset_features)
									back_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BACK_F][1]
									back_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BACK_F][2]
									behindback_overlay.pixel_x += H.dna.species.offset_features[OFFSET_BACK_F][1]
									behindback_overlay.pixel_y += H.dna.species.offset_features[OFFSET_BACK_F][2]
					overcloaks += back_overlay
					backbehind += behindback_overlay
			else
				back_overlay = backl.build_worn_icon(default_layer = BACK_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/back_l.dmi')
				if(gender == MALE)
					if(OFFSET_BACK in dna.species.offset_features)
						back_overlay.pixel_x += dna.species.offset_features[OFFSET_BACK][1]
						back_overlay.pixel_y += dna.species.offset_features[OFFSET_BACK][2]
				else
					if(OFFSET_BACK_F in dna.species.offset_features)
						back_overlay.pixel_x += dna.species.offset_features[OFFSET_BACK_F][1]
						back_overlay.pixel_y += dna.species.offset_features[OFFSET_BACK_F][2]
				if(backl.alternate_worn_layer == UNDER_CLOAK_LAYER)
					undercloaks += back_overlay
				else
					overcloaks += back_overlay

	if(overcloaks.len)
		overlays_standing[BACK_LAYER] = overcloaks
	if(backbehind.len)
		overlays_standing[BACK_BEHIND_LAYER] = backbehind
	if(undercloaks.len)
		overlays_standing[UNDER_CLOAK_LAYER] = undercloaks

	apply_overlay(BACK_LAYER)
	apply_overlay(BACK_BEHIND_LAYER)
	apply_overlay(UNDER_CLOAK_LAYER)

/mob/living/carbon/human/update_inv_cloak()
	remove_overlay(CLOAK_LAYER)
	remove_overlay(CLOAK_BEHIND_LAYER)
	remove_overlay(TABARD_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_CLOAK]
		inv.update_icon()

	var/list/cloaklays = list()

	if(cloak)
		cloak.screen_loc = rogueui_cloak					//move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += cloak					//add it to client's screen
		update_observer_view(cloak,1)
		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			var/racecustom
			var/mutable_appearance/cloak_overlay
			if(dna.species.custom_clothes)
				racecustom = dna.species.id
			if(G == "f")
				cloak_overlay = cloak.build_worn_icon(default_layer = CLOAK_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "f", customi = racecustom)
			else
				if(dna.species.use_f)
					cloak_overlay = cloak.build_worn_icon(default_layer = CLOAK_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "e", customi = racecustom)
				else
					cloak_overlay = cloak.build_worn_icon(default_layer = CLOAK_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = FALSE, customi = racecustom)

			if(gender == MALE)
				if(OFFSET_CLOAK in dna.species.offset_features)
					cloak_overlay.pixel_x += dna.species.offset_features[OFFSET_CLOAK][1]
					cloak_overlay.pixel_y += dna.species.offset_features[OFFSET_CLOAK][2]
			else
				if(OFFSET_CLOAK_F in dna.species.offset_features)
					cloak_overlay.pixel_x += dna.species.offset_features[OFFSET_CLOAK_F][1]
					cloak_overlay.pixel_y += dna.species.offset_features[OFFSET_CLOAK_F][2]
			if(cloak.alternate_worn_layer == TABARD_LAYER)
				overlays_standing[TABARD_LAYER] = cloak_overlay
			if(cloak.alternate_worn_layer == CLOAK_BEHIND_LAYER)
				overlays_standing[CLOAK_BEHIND_LAYER] = cloak_overlay
			if(!cloak.alternate_worn_layer)
				cloaklays += cloak_overlay

			//add sleeve overlays, then offset
			var/list/cloaksleeves = list()
			if(cloak.sleeved)
				cloaksleeves = get_sleeves_layer(cloak,0,CLOAK_LAYER)

			if(cloaksleeves.len)
				for(var/X in cloaksleeves)
					var/mutable_appearance/S = X
					if(gender == MALE)
						if(OFFSET_SHIRT in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_CLOAK][1]
							S.pixel_y += dna.species.offset_features[OFFSET_CLOAK][2]
					else
						if(OFFSET_SHIRT_F in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_CLOAK_F][1]
							S.pixel_y += dna.species.offset_features[OFFSET_CLOAK_F][2]
					cloaklays += S
	if(backr && backr.alternate_worn_layer == CLOAK_BEHIND_LAYER)
		update_hud_backr(backr)
		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			var/racecustom
			var/mutable_appearance/cloak_overlay
			if(dna.species.custom_clothes)
				racecustom = dna.species.id
			if(G == "f")
				cloak_overlay = backr.build_worn_icon(default_layer = CLOAK_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "f", customi = racecustom)
			else
				if(dna.species.use_f)
					cloak_overlay = backr.build_worn_icon(default_layer = CLOAK_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "e", customi = racecustom)
				else
					cloak_overlay = backr.build_worn_icon(default_layer = CLOAK_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = FALSE, customi = racecustom)

			if(gender == MALE)
				if(OFFSET_CLOAK in dna.species.offset_features)
					cloak_overlay.pixel_x += dna.species.offset_features[OFFSET_CLOAK][1]
					cloak_overlay.pixel_y += dna.species.offset_features[OFFSET_CLOAK][2]
			else
				if(OFFSET_CLOAK_F in dna.species.offset_features)
					cloak_overlay.pixel_x += dna.species.offset_features[OFFSET_CLOAK_F][1]
					cloak_overlay.pixel_y += dna.species.offset_features[OFFSET_CLOAK_F][2]
			if(backr.alternate_worn_layer == TABARD_LAYER)
				overlays_standing[TABARD_LAYER] = cloak_overlay
			if(backr.alternate_worn_layer == CLOAK_BEHIND_LAYER)
				overlays_standing[CLOAK_BEHIND_LAYER] = cloak_overlay
			if(!backr.alternate_worn_layer)
				cloaklays += cloak_overlay

			//add sleeve overlays, then offset
			var/list/cloaksleeves = list()
			if(backr.sleeved)
				cloaksleeves = get_sleeves_layer(backr,0,CLOAK_LAYER)

			if(cloaksleeves.len)
				for(var/X in cloaksleeves)
					var/mutable_appearance/S = X
					if(gender == MALE)
						if(OFFSET_SHIRT in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_CLOAK][1]
							S.pixel_y += dna.species.offset_features[OFFSET_CLOAK][2]
					else
						if(OFFSET_SHIRT_F in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_CLOAK_F][1]
							S.pixel_y += dna.species.offset_features[OFFSET_CLOAK_F][2]
					cloaklays += S

	overlays_standing[CLOAK_LAYER] = cloaklays
	update_inv_armor() //fixboob
	apply_overlay(TABARD_LAYER)
	apply_overlay(CLOAK_BEHIND_LAYER)
	apply_overlay(CLOAK_LAYER)

/mob/living/carbon/human/update_inv_shirt()
	remove_overlay(SHIRT_LAYER)
	remove_overlay(SHIRTSLEEVE_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_SHIRT]
		inv.update_icon()

	if(wear_shirt)
		wear_shirt.screen_loc = rogueui_shirt					//move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += wear_shirt					//add it to client's screen
		update_observer_view(wear_shirt,1)
		if(dna && dna.species.sexes)
			var/mutable_appearance/shirt_overlay
			var/armsindex = get_limbloss_index(ARM_RIGHT, ARM_LEFT)
			var/G = (gender == FEMALE) ? "f" : "m"
			var/racecustom
			var/hideboob = FALSE
			if(dna.species.custom_clothes)
				racecustom = dna.species.id
			if(wear_armor)
				var/obj/item/I = wear_armor
				if(I.flags_inv & HIDEBOOB)
					hideboob = TRUE
			if(cloak)
				var/obj/item/I = cloak
				if(I.flags_inv & HIDEBOOB)
					hideboob = TRUE
			if(G == "f" && !hideboob)
				shirt_overlay = wear_shirt.build_worn_icon(default_layer = SHIRT_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "f", customi = racecustom, sleeveindex = armsindex)
			else
				if(dna.species.use_f || G == "f")
					shirt_overlay = wear_shirt.build_worn_icon(default_layer = SHIRT_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "e", customi = racecustom, sleeveindex = armsindex)
				else
					shirt_overlay = wear_shirt.build_worn_icon(default_layer = SHIRT_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = FALSE, customi = racecustom, sleeveindex = armsindex)

			if(gender == MALE)
				if(OFFSET_SHIRT in dna.species.offset_features)
					shirt_overlay.pixel_x += dna.species.offset_features[OFFSET_SHIRT][1]
					shirt_overlay.pixel_y += dna.species.offset_features[OFFSET_SHIRT][2]
			else
				if(OFFSET_SHIRT_F in dna.species.offset_features)
					shirt_overlay.pixel_x += dna.species.offset_features[OFFSET_SHIRT_F][1]
					shirt_overlay.pixel_y += dna.species.offset_features[OFFSET_SHIRT_F][2]
			overlays_standing[SHIRT_LAYER] = shirt_overlay

			//add sleeve overlays, then offset
			var/list/sleeves = list()
			if(wear_shirt.sleeved && armsindex > 0)
				sleeves = get_sleeves_layer(wear_shirt,armsindex,SHIRTSLEEVE_LAYER)

			if(sleeves)
				for(var/X in sleeves)
					var/mutable_appearance/S = X
					if(gender == MALE)
						if(OFFSET_SHIRT in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_SHIRT][1]
							S.pixel_y += dna.species.offset_features[OFFSET_SHIRT][2]
					else
						if(OFFSET_SHIRT_F in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_SHIRT_F][1]
							S.pixel_y += dna.species.offset_features[OFFSET_SHIRT_F][2]
				overlays_standing[SHIRTSLEEVE_LAYER] = sleeves

	if(gender == FEMALE && dna?.species)
		update_body_parts(redraw = TRUE)
		dna.species.handle_body(src)
	update_hair()
	update_mutant_bodyparts()

	apply_overlay(SHIRT_LAYER)
	apply_overlay(SHIRTSLEEVE_LAYER)

/mob/living/carbon/human/update_inv_armor()
	remove_overlay(ARMOR_LAYER)
	remove_overlay(ARMORSLEEVE_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_ARMOR]
		inv.update_icon()

	if(wear_armor)
		wear_armor.screen_loc = rogueui_armor					//move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += wear_armor					//add it to client's screen
		update_observer_view(wear_armor,1)
		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			var/racecustom
			var/armsindex = get_limbloss_index(ARM_RIGHT, ARM_LEFT)
			var/mutable_appearance/armor_overlay
			var/hideboob = FALSE
			if(cloak)
				var/obj/item/I = cloak
				if(I.flags_inv & HIDEBOOB)
					hideboob = TRUE
			if(dna.species.custom_clothes)
				racecustom = dna.species.id
			if(G == "f" && !hideboob || G == "f")
				armor_overlay = wear_armor.build_worn_icon(default_layer = ARMOR_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "f", customi = racecustom, sleeveindex = armsindex)
			else
				if(dna.species.use_f)
					armor_overlay = wear_armor.build_worn_icon(default_layer = ARMOR_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "e", customi = racecustom, sleeveindex = armsindex)
				else
					armor_overlay = wear_armor.build_worn_icon(default_layer = ARMOR_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = null, customi = racecustom, sleeveindex = armsindex)

			if(gender == MALE)
				if(OFFSET_ARMOR in dna.species.offset_features)
					armor_overlay.pixel_x += dna.species.offset_features[OFFSET_ARMOR][1]
					armor_overlay.pixel_y += dna.species.offset_features[OFFSET_ARMOR][2]
			else
				if(OFFSET_ARMOR_F in dna.species.offset_features)
					armor_overlay.pixel_x += dna.species.offset_features[OFFSET_ARMOR_F][1]
					armor_overlay.pixel_y += dna.species.offset_features[OFFSET_ARMOR_F][2]
			overlays_standing[ARMOR_LAYER] = armor_overlay

			//add sleeve overlays, then offset
			var/list/sleeves = list()
			if(wear_armor.sleeved && armsindex > 0)
				sleeves = get_sleeves_layer(wear_armor,armsindex,ARMORSLEEVE_LAYER)

			if(sleeves)
				for(var/X in sleeves)
					var/mutable_appearance/S = X
					if(gender == MALE)
						if(OFFSET_ARMOR in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_ARMOR][1]
							S.pixel_y += dna.species.offset_features[OFFSET_ARMOR][2]
					else
						if(OFFSET_ARMOR_F in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_ARMOR_F][1]
							S.pixel_y += dna.species.offset_features[OFFSET_ARMOR_F][2]
				overlays_standing[ARMORSLEEVE_LAYER] = sleeves

	if(gender == FEMALE && dna?.species)
		update_body_parts(redraw = TRUE)
		dna.species.handle_body(src)
	update_hair()
	update_mutant_bodyparts()
	update_inv_shirt() // fix boob

	apply_overlay(ARMOR_LAYER)
	apply_overlay(ARMORSLEEVE_LAYER)

/mob/living/carbon/human/update_inv_pants()
	remove_overlay(PANTS_LAYER)
	remove_overlay(LEGSLEEVE_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_PANTS]
		inv.update_icon()

	if(wear_pants)
		wear_pants.screen_loc = rogueui_pants					//move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += wear_pants					//add it to client's screen
		update_observer_view(wear_pants,1)
		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			var/racecustom
			var/legsindex = get_limbloss_index(LEG_RIGHT, LEG_LEFT)
			var/mutable_appearance/pants_overlay
			if(dna.species.custom_clothes)
				racecustom = dna.species.id
			if(G == "f")
				pants_overlay = wear_pants.build_worn_icon(default_layer = PANTS_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "f", customi = racecustom, sleeveindex = legsindex)
			else
				if(dna.species.use_f)
					pants_overlay = wear_pants.build_worn_icon(default_layer = PANTS_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = "e", customi = racecustom, sleeveindex = legsindex)
				else
					pants_overlay = wear_pants.build_worn_icon(default_layer = PANTS_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', coom = FALSE, customi = racecustom, sleeveindex = legsindex)

			if(G == "m")
				if(OFFSET_PANTS in dna.species.offset_features)
					pants_overlay.pixel_x += dna.species.offset_features[OFFSET_PANTS][1]
					pants_overlay.pixel_y += dna.species.offset_features[OFFSET_PANTS][2]
			else
				if(OFFSET_PANTS_F in dna.species.offset_features)
					pants_overlay.pixel_x += dna.species.offset_features[OFFSET_PANTS_F][1]
					pants_overlay.pixel_y += dna.species.offset_features[OFFSET_PANTS_F][2]
			overlays_standing[PANTS_LAYER] = pants_overlay

			//add sleeve overlays, then offset
			var/list/sleeves = list()
			var/femw = (gender == FEMALE || dna.species.use_f) ? "_f" : ""
			if(wear_pants.sleeved && legsindex > 0 && wear_pants.adjustable != CADJUSTED)
				sleeves = get_sleeves_layer(wear_pants,legsindex,LEGSLEEVE_LAYER)
			if(wear_pants.adjustable == CADJUSTED)
				var/mutable_appearance/overleg = mutable_appearance(wear_pants.mob_overlay_icon, "[wear_pants.icon_state][femw][racecustom ? "_[racecustom]" : ""]", -LEGSLEEVE_LAYER)
				sleeves += overleg
			if(sleeves)
				for(var/X in sleeves)
					var/mutable_appearance/S = X
					if(gender == MALE)
						if(OFFSET_PANTS in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_PANTS][1]
							S.pixel_y += dna.species.offset_features[OFFSET_PANTS][2]
					else
						if(OFFSET_PANTS_F in dna.species.offset_features)
							S.pixel_x += dna.species.offset_features[OFFSET_PANTS_F][1]
							S.pixel_y += dna.species.offset_features[OFFSET_PANTS_F][2]
				overlays_standing[LEGSLEEVE_LAYER] = sleeves

	update_hair()
	update_mutant_bodyparts()

	apply_overlay(PANTS_LAYER)
	apply_overlay(LEGSLEEVE_LAYER)

/mob/living/carbon/human/update_inv_mouth()
	remove_overlay(MOUTH_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used && hud_used.inv_slots[SLOT_MOUTH])
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_MOUTH]
		inv.update_icon()

	if(mouth)
		if(!(SLOT_MOUTH in check_obscured_slots()))
			overlays_standing[MOUTH_LAYER] = mouth.build_worn_icon(default_layer = MOUTH_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/mouth_items.dmi')
		update_hud_mouth(mouth)

	apply_overlay(MOUTH_LAYER)
	var/mutable_appearance/mouth_overlay = overlays_standing[MOUTH_LAYER]
	if(mouth_overlay)
		remove_overlay(MOUTH_LAYER)
		if(gender == MALE)
			if(OFFSET_MOUTH in dna.species.offset_features)
				mouth_overlay.pixel_x += dna.species.offset_features[OFFSET_MOUTH][1]
				mouth_overlay.pixel_y += dna.species.offset_features[OFFSET_MOUTH][2]
		else
			if(OFFSET_MOUTH_F in dna.species.offset_features)
				mouth_overlay.pixel_x += dna.species.offset_features[OFFSET_MOUTH_F][1]
				mouth_overlay.pixel_y += dna.species.offset_features[OFFSET_MOUTH_F][2]
		overlays_standing[MOUTH_LAYER] = mouth_overlay
		apply_overlay(MOUTH_LAYER)
	update_mutant_bodyparts()

//endrogue


/mob/living/carbon/human/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	clear_alert("legcuffed")
	if(legcuffed)
		overlays_standing[LEGCUFF_LAYER] = mutable_appearance('icons/roguetown/mob/bodies/cuffed.dmi', "[legcuffed.name]down", -LEGCUFF_LAYER)
		apply_overlay(LEGCUFF_LAYER)
		throw_alert("legcuffed", /obj/screen/alert/restrained/legcuffed, new_master = src.legcuffed)

/proc/wear_female_version(t_color, icon, layer, type)
	var/index = t_color
	var/icon/female_clothing_icon = GLOB.female_clothing_icons[index]
	if(!female_clothing_icon) 	//Create standing/laying icons if they don't exist
		generate_female_clothing(index,t_color,icon,type)
	return mutable_appearance(GLOB.female_clothing_icons[t_color], layer = -layer)

/proc/wear_dismembered_version(t_color, icon, layer, sleeveindex, type)
	var/index = "[t_color][sleeveindex]"
	var/icon/clothing_icon = GLOB.dismembered_clothing_icons[index]
	if(!clothing_icon) 	//Create standing/laying icons if they don't exist
		generate_dismembered_clothing(index,t_color,icon,sleeveindex, type)
	return mutable_appearance(GLOB.dismembered_clothing_icons[index], layer = -layer)


/mob/living/carbon/human/proc/get_overlays_copy(list/unwantedLayers)
	var/list/out = new
	for(var/i in 1 to TOTAL_LAYERS)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out


//human HUD updates for items in our inventory

//update whether our head item appears on our hud.
/mob/living/carbon/human/update_hud_head(obj/item/I)
	I.screen_loc = rogueui_head
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our mask item appears on our hud.
/mob/living/carbon/human/update_hud_wear_mask(obj/item/I)
	I.screen_loc = rogueui_mask
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

/mob/living/carbon/human/update_hud_mouth(obj/item/I)
	I.screen_loc = rogueui_mouth
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our neck item appears on our hud.
/mob/living/carbon/human/update_hud_neck(obj/item/I)
	I.screen_loc = rogueui_neck
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our back item appears on our hud.
/mob/living/carbon/human/update_hud_back(obj/item/I)
	I.screen_loc = ui_back
	if(client && hud_used && hud_used.hud_shown)
		client.screen += I
	update_observer_view(I)

//update whether our back item appears on our hud.
/mob/living/carbon/human/update_hud_backr(obj/item/I)
	I.screen_loc = rogueui_backr
	if(client && hud_used && hud_used.hud_shown)
		client.screen += I
	update_observer_view(I)

//update whether our back item appears on our hud.
/mob/living/carbon/human/update_hud_backl(obj/item/I)
	I.screen_loc = rogueui_backl
	if(client && hud_used && hud_used.hud_shown)
		client.screen += I
	update_observer_view(I)

/*
Does everything in relation to building the /mutable_appearance used in the mob's overlays list
covers:
 inhands and any other form of worn item
 centering large appearances
 layering appearances on custom layers
 building appearances from custom icon files

By Remie Richards (yes I'm taking credit because this just removed 90% of the copypaste in update_icons())

state: A string to use as the state, this is FAR too complex to solve in this proc thanks to shitty old code
so it's specified as an argument instead.

default_layer: The layer to draw this on if no other layer is specified

default_icon_file: The icon file to draw states from if no other icon file is specified

isinhands: If true then alternate_worn_icon is skipped so that default_icon_file is used,
in this situation default_icon_file is expected to match either the lefthand_ or righthand_ file var

femalueuniform: A value matching a uniform item's fitted var, if this is anything but NO_FEMALE_UNIFORM, we
generate/load female uniform sprites matching all previously decided variables


*/
/obj/item/proc/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, coom = null, customi = null, sleeveindex)
	var/t_state
	var/sleevejazz = sleevetype
	if(override_state)
		t_state = override_state
	else
		if(isinhands && item_state)
			t_state = item_state
		else
			if(coom)
				t_state = icon_state + "_f"
				if(sleevejazz)
					sleevejazz += "_f"
			else
				t_state = icon_state
	if(customi)
		t_state += "_[customi]"
		if(sleevejazz)
			sleevejazz += "_[customi]"
	var/t_icon = mob_overlay_icon

	if(!t_icon)
		t_icon = default_icon_file

	//Find a valid icon file from variables+arguments
	var/file2use
	if(!isinhands && mob_overlay_icon)
		file2use = mob_overlay_icon
	if(!file2use)
		file2use = default_icon_file

	//Find a valid layer from variables+arguments
	var/layer2use
	if(alternate_worn_layer)
		layer2use = alternate_worn_layer
	if(!layer2use)
		layer2use = default_layer

	if(r_sleeve_status == SLEEVE_TORN || r_sleeve_status == SLEEVE_ROLLED)
		if(sleeveindex == 4 || sleeveindex == 2)
			sleeveindex -= 1
	if(l_sleeve_status == SLEEVE_TORN || l_sleeve_status == SLEEVE_ROLLED)
		if(sleeveindex == 4 || sleeveindex == 3)
			sleeveindex -= 2

	var/mutable_appearance/standing
//	if(femaleuniform)
//		standing = wear_female_version(t_state,file2use,layer2use,femaleuniform)
	if(sleeved && sleevejazz && sleeveindex < 4) //cut out sleeves from north/south sprites
		if(!nodismemsleeves)
			standing = wear_dismembered_version(t_state,file2use,layer2use,sleeveindex,sleevejazz)
		else
			sleeveindex = 4
	if(!standing)
		standing = mutable_appearance(file2use, t_state, -layer2use)

	//Get the overlays for this item when it's being worn
	//eg: ammo counters, primed grenade flashes, etc.
	var/list/worn_overlays = worn_overlays(isinhands, file2use)
	if(worn_overlays && worn_overlays.len)
//		for(var/mutable_appearance/MA in worn_overlays)
//			MA.blend_mode = BLEND_MULTIPLY
		standing.overlays.Add(worn_overlays)
	if(!isinhands && coom == "f" && boobed)
		var/mutable_appearance/boob_overlay = mutable_appearance(file2use, "[t_state]_boob", -layer2use)
		standing.overlays.Add(boob_overlay)

	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(file2use, "[t_state][get_detail_tag()]"), -layer2use)
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		standing.overlays.Add(pic)
		if(!isinhands && coom == "f" && boobed)
			pic = mutable_appearance(icon(file2use, "[t_state]_boob[get_detail_tag()]"), -layer2use)
			pic.appearance_flags = RESET_COLOR
			if(get_detail_color())
				pic.color = get_detail_color()
			standing.overlays.Add(pic)

	if(!isinhands && HAS_BLOOD_DNA(src))
		var/index = "[t_state][sleeveindex]"
		var/static/list/bloody_onmob = list()
		var/icon/clothing_icon = bloody_onmob["[index][(coom == "f") ? "_boob" : ""]"]
		if(!clothing_icon)
			if(sleeved && sleeveindex < 4) //cut out sleeves from north/south sprites
				clothing_icon = icon(GLOB.dismembered_clothing_icons[index])
			else
				clothing_icon = icon(file2use, t_state)
			if(coom == "f" && boobed)
				clothing_icon.Blend(icon(file2use, "[t_state]_boob"), ICON_OVERLAY)
			clothing_icon.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
			clothing_icon.Blend(icon(bloody_icon, bloody_icon_state), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
			bloody_onmob["[index][(coom == "f") ? "_boob" : ""]"] = fcopy_rsc(clothing_icon)
		var/mutable_appearance/pic = mutable_appearance(clothing_icon, -layer2use)
		standing.overlays.Add(pic)

	standing = center_image(standing, isinhands ? inhand_x_dimension : worn_x_dimension, isinhands ? inhand_y_dimension : worn_y_dimension)

	//Handle held offsets
	var/mob/M = loc
	if(istype(M))
		var/list/L = get_held_offsets()
		if(L)
			standing.pixel_x += L["x"] //+= because of center()ing
			standing.pixel_y += L["y"]

	standing.alpha = alpha
	standing.color = color

	return standing

/mob/living/carbon/proc/get_sleeves_layer(var/obj/item/I,sleeveindex,layer2use)
	if(!I)
		return
	var/list/sleeves = list()

	if(I.r_sleeve_status == SLEEVE_TORN || I.r_sleeve_status == SLEEVE_ROLLED)
		if(sleeveindex == 4 || sleeveindex == 2)
			sleeveindex -= 1
	if(I.l_sleeve_status == SLEEVE_TORN || I.l_sleeve_status == SLEEVE_ROLLED)
		if(sleeveindex == 4 || sleeveindex == 3)
			sleeveindex -= 2

	var/racecustom
	if(dna.species.custom_clothes)
		racecustom = dna.species.id
	var/index = "[I.icon_state][(gender == FEMALE || dna.species.use_f) ? "_f" : ""][racecustom ? "_[racecustom]" : ""]"
	var/static/list/bloody_r = list()
	var/static/list/bloody_l = list()
	if(I.nodismemsleeves && sleeveindex) //armor pauldrons that show up above arms but don't get dismembered
		sleeveindex = 4

	var/leftused = FALSE
	var/rightused = FALSE
	if(I.inhand_mod) //cloak holding icons
		for(var/obj/item/H in held_items)
			var/rightorleft
			rightorleft = get_held_index_of_item(H) % 2
			if(rightorleft == 0)
				rightused = TRUE
			else
				leftused = TRUE

	if(sleeveindex == 2 || sleeveindex == 4 || !sleeveindex)
		var/used = "r_[index]"
		if(!sleeveindex)
			if(rightused)
				used = "xr_[index]"
		var/mutable_appearance/r_sleeve = mutable_appearance(I.sleeved, used, layer=-layer2use)
		r_sleeve.color = I.color
		r_sleeve.alpha = I.alpha
		sleeves += r_sleeve

		if(I.get_detail_tag())
			var/mutable_appearance/pic = mutable_appearance(icon(I.sleeved, "[used][I.get_detail_tag()]"), layer=-layer2use)
//			pic.appearance_flags = RESET_COLOR
			if(I.get_detail_color())
				pic.color = I.get_detail_color()
			sleeves += pic

		if(HAS_BLOOD_DNA(I))
			var/icon/blood_overlay = bloody_r[used]
			if(!blood_overlay)
				blood_overlay = icon(I.sleeved, used)
				blood_overlay.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
				blood_overlay.Blend(icon(I.bloody_icon, I.bloody_icon_state), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
				bloody_r[used] = fcopy_rsc(blood_overlay)
			var/mutable_appearance/pic = mutable_appearance(blood_overlay, layer=-layer2use)
			sleeves += pic

	if(sleeveindex == 3 || sleeveindex == 4 || !sleeveindex)
		var/used = "l_[index]"
		if(!sleeveindex)
			if(leftused)
				used = "xl_[index]"
		var/mutable_appearance/l_sleeve = mutable_appearance(I.sleeved, used, layer=-layer2use)
		l_sleeve.color = I.color
		l_sleeve.alpha = I.alpha
		sleeves += l_sleeve

		if(I.get_detail_tag())
			var/mutable_appearance/pic = mutable_appearance(icon(I.sleeved, "[used][I.get_detail_tag()]"), layer=-layer2use)
//			pic.appearance_flags = RESET_COLOR
			if(I.get_detail_color())
				pic.color = I.get_detail_color()
			sleeves += pic

		if(HAS_BLOOD_DNA(I))
			var/icon/blood_overlay = bloody_l[used]
			if(!blood_overlay)
				blood_overlay = icon(I.sleeved, used)
				blood_overlay.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
				blood_overlay.Blend(icon(I.bloody_icon, I.bloody_icon_state), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
				bloody_l[used] = fcopy_rsc(blood_overlay)
			var/mutable_appearance/pic = mutable_appearance(blood_overlay, layer=-layer2use)
			sleeves += pic

	return sleeves


/obj/item/proc/get_held_offsets()
	var/list/L
	if(ismob(loc))
		var/mob/M = loc
		L = M.get_item_offsets_for_index(M.get_held_index_of_item(src))
	return L


//Can't think of a better way to do this, sadly
/mob/proc/get_item_offsets_for_index(i)
	switch(i)
		if(3) //odd = left hands
			return list("x" = 0, "y" = 16)
		if(4) //even = right hands
			return list("x" = 0, "y" = 16)
		else //No offsets or Unwritten number of hands
			return list("x" = 0, "y" = 0)//Handle held offsets

//produces a key based on the human's limbs
/mob/living/carbon/human/generate_icon_render_key()
	. = "[dna.species.limbs_id]"

	if(dna.check_mutation(HULK))
		. += "-coloured-hulk"
	else if(dna.species.use_skintones)
		. += "-coloured-[skin_tone]"
	else if(dna.species.fixed_mut_color)
		. += "-coloured-[dna.species.fixed_mut_color]"
	else if(dna.features["mcolor"])
		. += "-coloured-[dna.features["mcolor"]]"
	else
		. += "-not_coloured"

	. += "-[gender]"
	. += "-[age]"

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		. += "-[BP.body_zone]"
		if(BP.status == BODYPART_ORGANIC)
			. += "-organic"
		else
			. += "-robotic"
		if(BP.use_digitigrade)
			. += "-digitigrade[BP.use_digitigrade]"
		if(BP.rotted)
			. += "-rotted"
		if(BP.skeletonized)
			. += "-skeletonized"
		if(BP.dmg_overlay_type)
			. += "-[BP.dmg_overlay_type]"

	if(HAS_TRAIT(src, TRAIT_HUSK))
		. += "-husk"

/mob/living/carbon/human/load_limb_from_cache()
	..()
	update_hair()



/mob/living/carbon/human/proc/update_observer_view(obj/item/I, inventory)
	if(observers && observers.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			if(observe.client && observe.client.eye == src)
				if(observe.hud_used)
					if(inventory && !observe.hud_used.inventory_shown)
						continue
					observe.client.screen += I
			else
				observers -= observe
				if(!observers.len)
					observers = null
					break

/mob/living/carbon/human/update_body_parts(redraw = FALSE)
	//CHECK FOR UPDATE
	var/oldkey = icon_render_key
	icon_render_key = generate_icon_render_key()
	if(oldkey == icon_render_key && !redraw)
		return

	remove_overlay(BODYPARTS_LAYER)

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		BP.update_limb()

	//LOAD ICONS
	if(!redraw)
		if(limb_icon_cache[icon_render_key])
			load_limb_from_cache()
			return

	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	var/hiden = FALSE //used to tell if we should hide boobs, basically
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.name == BODY_ZONE_CHEST)
			if(wear_armor)
				var/obj/item/I = wear_armor
				if(I.flags_inv & HIDEBOOB)
					hiden = TRUE
			if(wear_shirt)
				var/obj/item/I = wear_shirt
				if(I.flags_inv & HIDEBOOB)
					hiden = TRUE
			if(cloak)
				var/obj/item/I = cloak
				if(I.flags_inv & HIDEBOOB)
					hiden = TRUE
			new_limbs += BP.get_limb_icon(hideaux = hiden)
		else
			new_limbs += BP.get_limb_icon()
	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs
		limb_icon_cache[icon_render_key] = new_limbs

	apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()

/mob/proc/update_body_parts_head_only()
	return

// Only renders the head of the human
/mob/living/carbon/human/update_body_parts_head_only()
	if (!dna)
		return

	if (!dna.species)
		return

	var/obj/item/bodypart/HD = get_bodypart("head")

	if (!istype(HD))
		return

	testing("ehadonly [src]")
	HD.update_limb()

	add_overlay(HD.get_limb_icon())
	update_damage_overlays()

	if(HD && !(HAS_TRAIT(src, TRAIT_HUSK)))

		// lipstick
		if(lip_style && (LIPS in dna.species.species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/human_face.dmi', "lips_[lip_style]", -BODY_LAYER)
			lip_overlay.color = lip_color
			if(gender == FEMALE)
				if(OFFSET_FACE_F in dna.species.offset_features)
					lip_overlay.pixel_x += dna.species.offset_features[OFFSET_FACE_F][1]
					lip_overlay.pixel_y += dna.species.offset_features[OFFSET_FACE_F][2]
			else
				if(OFFSET_FACE in dna.species.offset_features)
					lip_overlay.pixel_x += dna.species.offset_features[OFFSET_FACE][1]
					lip_overlay.pixel_y += dna.species.offset_features[OFFSET_FACE][2]
			add_overlay(lip_overlay)

		// eyes
		if(!(NOEYESPRITES in dna.species.species_traits))
			var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
			var/mutable_appearance/eye_overlay
			if(!E)
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER)
			else
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', E.eye_icon_state, -BODY_LAYER)
			if((EYECOLOR in dna.species.species_traits) && E)
				if(druggy)
					eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "[E.eye_icon_state]-r", -BODY_LAYER)
				else
					eye_overlay.color = "#" + eye_color
			if(gender == FEMALE)
				if(OFFSET_FACE_F in dna.species.offset_features)
					eye_overlay.pixel_x += dna.species.offset_features[OFFSET_FACE_F][1]
					eye_overlay.pixel_y += dna.species.offset_features[OFFSET_FACE_F][2]
			else
				if(OFFSET_FACE in dna.species.offset_features)
					eye_overlay.pixel_x += dna.species.offset_features[OFFSET_FACE][1]
					eye_overlay.pixel_y += dna.species.offset_features[OFFSET_FACE][2]
			add_overlay(eye_overlay)

	dna.species.handle_hair(src)

	update_inv_head()
	update_inv_wear_mask()
	update_inv_mouth()
