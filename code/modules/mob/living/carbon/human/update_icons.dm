/*
	Global associative list for caching humanoid icons.
	Index format m or f, followed by a string of 0 and 1 to represent bodyparts followed by husk fat hulk skeleton 1 or 0.
	TODO: Proper documentation
	icon_key is [species.race_key][g][husk][fat][hulk][skeleton][ethnicity]
*/
var/global/list/human_icon_cache = list()

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
		update_mutantrace()	//handles updating your appearance after setting the mutantrace var
		UpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
		update_body()	//Handles updating your mob's icon to reflect their gender/race/complexion etc
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)
		update_targeted() // Updates the target overlay when someone points a gun at you

>	If you need to update all overlays you can use regenerate_icons(). it works exactly like update_clothing used to.


*/

//Human Overlays Indexes/////////
#define MUTANTRACE_LAYER		25
#define MUTATIONS_LAYER			24
#define DAMAGE_LAYER			23
#define UNIFORM_LAYER			22
#define TAIL_LAYER				21		//bs12 specific. this hack is probably gonna come back to haunt me
#define ID_LAYER				20
#define SHOES_LAYER				19
#define GLOVES_LAYER			18
#define SUIT_LAYER				17
#define GLASSES_LAYER			16
#define BELT_LAYER				15		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		14
#define BACK_LAYER				13
#define HAIR_LAYER				12		//TODO: make part of head layer?
#define EARS_LAYER				11
#define FACEMASK_LAYER			10
#define HEAD_LAYER				9
#define COLLAR_LAYER			8
#define HANDCUFF_LAYER			7
#define LEGCUFF_LAYER			6
#define L_HAND_LAYER			5
#define R_HAND_LAYER			4
#define BURST_LAYER				3 	//Chestburst overlay
#define TARGETED_LAYER			2	//for target sprites when held at gun point, and holo cards.
#define FIRE_LAYER				1		//If you're on fire		//BS12: Layer for the target overlay from weapon targeting system

#define TOTAL_LAYERS			25
//////////////////////////////////

/mob/living/carbon/human
	var/list/overlays_standing[TOTAL_LAYERS]
	var/previous_damage_appearance // store what the body last looked like, so we only have to update it if something changed



/mob/living/carbon/human/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/human/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null


//UPDATES OVERLAYS FROM OVERLAYS_LYING/OVERLAYS_STANDING
//this proc is messy as I was forced to include some old laggy cloaking code to it so that I don't break cloakers
//I'll work on removing that stuff by rewriting some of the cloaking stuff at a later date.
/mob/living/carbon/human/update_transform()
	if(lying != lying_prev )
		lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again

		if(lying && !species.prone_icon) //Only rotate them if we're not drawing a specific icon for being prone.
			var/matrix/M = matrix()
			M.Turn(90)
			M.Scale(size_multiplier)
			M.Translate(1,-6)
			src.transform = M
		else
			var/matrix/M = matrix()
			M.Scale(size_multiplier)
			M.Translate(0, 16*(size_multiplier-1))
			src.transform = M

var/global/list/damage_icon_parts = list()
/mob/living/carbon/human/proc/get_damage_icon_part(damage_state, body_part)
	if(damage_icon_parts["[damage_state]_[species.blood_color]_[body_part]"] == null)
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
		damage_icon_parts["[damage_state]_[species.blood_color]_[body_part]"] = DI
		return DI
	else
		return damage_icon_parts["[damage_state]_[species.blood_color]_[body_part]"]

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/UpdateDamageIcon()
	// first check whether something actually changed about damage appearance
	var/damage_appearance = ""

	for(var/datum/limb/O in limbs)
		if(O.status & LIMB_DESTROYED) damage_appearance += "d"
		else
			damage_appearance += O.damage_state

	if(damage_appearance == previous_damage_appearance)
		// nothing to do here
		return

	remove_overlay(DAMAGE_LAYER)

	previous_damage_appearance = damage_appearance

	var/icon/standing = new /icon('icons/mob/dam_human.dmi', "00")

	var/image/standing_image = new /image("icon" = standing, "layer" =-DAMAGE_LAYER)

	// blend the individual damage states with our icons
	for(var/datum/limb/O in limbs)
		if(!(O.status & LIMB_DESTROYED))
			O.update_icon()
			if(O.damage_state == "00") continue

			var/icon/DI = get_damage_icon_part(O.damage_state, O.icon_name)

			standing_image.overlays += DI

	overlays_standing[DAMAGE_LAYER]	= standing_image

	apply_overlay(DAMAGE_LAYER)

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(var/update_icons = 1, var/force_cache_update = 0)

	var/husk_color_mod = rgb(96,88,80)
	var/hulk_color_mod = rgb(48,224,40)
	var/necrosis_color_mod = rgb(10,50,0)

	var/husk = (HUSK in src.mutations)
	var/fat = (FAT in src.mutations)
	var/hulk = (HULK in src.mutations)
	var/skeleton = (SKELETON in src.mutations)

	var/g = get_gender_name(gender)
	var/has_head = 0


	//CACHING: Generate an index key from visible bodyparts.
	//0 = destroyed, 1 = normal, 2 = robotic, 3 = necrotic.

	//Create a new, blank icon for our mob to use.
	if(stand_icon)
		cdel(stand_icon)

	stand_icon = new(species.icon_template ? species.icon_template : 'icons/mob/human.dmi',"blank")

	var/icon_key = "[species.race_key][g][ethnicity]"
	for(var/datum/limb/part in limbs)

		if(istype(part,/datum/limb/head) && !(part.status & LIMB_DESTROYED))
			has_head = 1

		if(part.status & LIMB_DESTROYED)
			icon_key = "[icon_key]0"
		else if(part.status & LIMB_ROBOT)
			icon_key = "[icon_key]2"
		else if(part.status & LIMB_NECROTIZED)
			icon_key = "[icon_key]3"
		else
			icon_key = "[icon_key]1"

	icon_key = "[icon_key][husk ? 1 : 0][fat ? 1 : 0][hulk ? 1 : 0][skeleton ? 1 : 0][ethnicity]"

	var/icon/base_icon
	if(!force_cache_update && human_icon_cache[icon_key])
		//Icon is cached, use existing icon.
		base_icon = human_icon_cache[icon_key]

		//log_debug("Retrieved cached mob icon ([icon_key] \icon[human_icon_cache[icon_key]]) for [src].")

	else

	//BEGIN CACHED ICON GENERATION.

		// Why don't we just make skeletons/shadows/golems a species? ~Z
		var/race_icon =   (skeleton ? 'icons/mob/human_races/r_skeleton.dmi' : species.icobase)
		var/deform_icon = (skeleton ? 'icons/mob/human_races/r_skeleton.dmi' : species.icobase)

		//Robotic limbs are handled in get_icon() so all we worry about are missing or dead limbs.
		//No icon stored, so we need to start with a basic one.
		var/datum/limb/chest = get_limb("chest")
		base_icon = chest.get_icon(race_icon,deform_icon,g)

		if(chest.status & LIMB_NECROTIZED)
			base_icon.ColorTone(necrosis_color_mod)
			base_icon.SetIntensity(0.7)

		for(var/datum/limb/part in limbs)

			var/icon/temp //Hold the bodypart icon for processing.

			if(part.status & LIMB_DESTROYED)
				continue

			if(istype(part, /datum/limb/chest)) //already done above
				continue

			if (istype(part, /datum/limb/groin) || istype(part, /datum/limb/head))
				temp = part.get_icon(race_icon,deform_icon,g)
			else
				temp = part.get_icon(race_icon,deform_icon)

			if(part.status & LIMB_NECROTIZED)
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

		if(!skeleton)
			if(husk)
				base_icon.ColorTone(husk_color_mod)
			else if(hulk)
				var/list/tone = ReadRGB(hulk_color_mod)
				base_icon.MapColors(rgb(tone[1],0,0),rgb(0,tone[2],0),rgb(0,0,tone[3]))

		//Handle husk overlay.
		if(husk)
			var/icon/mask = new(base_icon)
			var/icon/husk_over = new(race_icon,"overlay_husk")
			mask.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,0)
			husk_over.Blend(mask, ICON_ADD)
			base_icon.Blend(husk_over, ICON_OVERLAY)


		human_icon_cache[icon_key] = base_icon

		//log_debug("Generated new cached mob icon ([icon_key] \icon[human_icon_cache[icon_key]]) for [src]. [human_icon_cache.len] cached mob icons.")

	//END CACHED ICON GENERATION.

	stand_icon.Blend(base_icon,ICON_OVERLAY)

	/*
	//Skin colour. Not in cache because highly variable (and relatively benign).
	if (species.flags & HAS_SKIN_COLOR)
		stand_icon.Blend(rgb(r_skin, g_skin, b_skin), ICON_ADD)
	*/

	if(has_head)
		//Eyes
		if(!skeleton)
			var/icon/eyes = new/icon('icons/mob/human_face.dmi', species.eyes)
			eyes.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
			stand_icon.Blend(eyes, ICON_OVERLAY)

		//Mouth	(lipstick!)
		if(lip_style && (species && species.flags & HAS_LIPS))	//skeletons are allowed to wear lipstick no matter what you think, agouri.
			stand_icon.Blend(new/icon('icons/mob/human_face.dmi', "camo_[lip_style]_s"), ICON_OVERLAY)


	if(species.flags & HAS_UNDERWEAR)

		//Underwear
		if(underwear >0 && underwear < 3)
			if(!fat && !skeleton)
				stand_icon.Blend(new /icon('icons/mob/human.dmi', "cryo[underwear]_[g]_s"), ICON_OVERLAY)

		if(job in ROLES_MARINES) //undoing override
			if(undershirt>0 && undershirt < 5)
				stand_icon.Blend(new /icon('icons/mob/human.dmi', "cryoshirt[undershirt]_s"), ICON_OVERLAY)
		else if(undershirt>0 && undershirt < 5)
			stand_icon.Blend(new /icon('icons/mob/human.dmi', "cryoshirt[undershirt]_s"), ICON_OVERLAY)

	icon = stand_icon

	//tail
	update_tail_showing(0)

//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	var/datum/limb/head/head_organ = get_limb("head")
	if( !head_organ || (head_organ.status & LIMB_DESTROYED) )
		return

	//masks and helmets can obscure our hair.
	if( (head && (head.flags_inv_hide & HIDEALLHAIR)) || (wear_mask && (wear_mask.flags_inv_hide & HIDEALLHAIR)))
		return

	//base icons
	var/icon/face_standing	= new /icon('icons/mob/human_face.dmi',"bald_s")

	if(f_style && !(wear_suit && (wear_suit.flags_inv_hide & HIDELOWHAIR)) && !(wear_mask && (wear_mask.flags_inv_hide & HIDELOWHAIR)))
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style && facial_hair_style.species_allowed && src.species.name in facial_hair_style.species_allowed)
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

			face_standing.Blend(facial_s, ICON_OVERLAY)

	if(h_style && !(head && (head.flags_inv_hide & HIDETOPHAIR)))
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style && src.species.name in hair_style.species_allowed)
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

			face_standing.Blend(hair_s, ICON_OVERLAY)

	overlays_standing[HAIR_LAYER]	= image("icon"= face_standing, "layer" =-HAIR_LAYER)

	apply_overlay(HAIR_LAYER)

/mob/living/carbon/human/update_mutations()
	remove_overlay(MUTATIONS_LAYER)
	var/fat
	if(FAT in mutations)
		fat = "fat"

	var/image/standing	= image("icon" = 'icons/effects/genetics.dmi', "layer" =-MUTATIONS_LAYER)
	var/add_image = 0
	var/g = "m"
	if(gender == FEMALE)	g = "f"
	// DNA2 - Drawing underlays.
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			var/underlay=gene.OnDrawUnderlays(src,g,fat)
			if(underlay)
				standing.underlays += underlay
				add_image = 1
	for(var/mut in mutations)
		switch(mut)
			/*
			if(HULK)
				if(fat)
					standing.underlays	+= "hulk_[fat]_s"
				else
					standing.underlays	+= "hulk_[g]_s"
				add_image = 1
			if(COLD_RESISTANCE)
				standing.underlays	+= "fire[fat]_s"
				add_image = 1
			if(TK)
				standing.underlays	+= "telekinesishead[fat]_s"
				add_image = 1
			*/
			if(LASER)
				standing.overlays	+= "lasereyes_s"
				add_image = 1
	if(add_image)
		overlays_standing[MUTATIONS_LAYER]	= standing

		apply_overlay(MUTATIONS_LAYER)


/mob/living/carbon/human/proc/update_mutantrace()
	remove_overlay(MUTANTRACE_LAYER)
	var/fat

	if( FAT in mutations )
		fat = "fat"

	if(dna)
		switch(dna.mutantrace)
			if("golem","slime","shadow","adamantine")
				overlays_standing[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace][fat]_[gender]_s")


	if(!dna || !(dna.mutantrace in list("golem","metroid")))
		update_body(0)

	update_hair(0)
	apply_overlay(MUTANTRACE_LAYER)

//Call when target overlay should be added/removed
/mob/living/carbon/human/update_targeted()
	remove_overlay(TARGETED_LAYER)
	var/image/I
	if (targeted_by && target_locked)
		I = image("icon" = target_locked, "layer" =-TARGETED_LAYER)
	else if (!targeted_by && target_locked)
		cdel(target_locked)
		target_locked = null
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
	if(monkeyizing)		return
	update_mutations(0)
	update_mutantrace(0)
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

		if(U.blood_DNA)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "uniformblood")
			bloodsies.color		= U.blood_color
			standing.overlays	+= bloodsies

		if(U.hastie)
			var/tie_state = U.hastie.item_state
			if(!tie_state) tie_state = U.hastie.icon_state
			standing.overlays	+= image("icon" = 'icons/mob/ties.dmi', "icon_state" = "[tie_state]")

		overlays_standing[UNIFORM_LAYER]	= standing

		apply_overlay(UNIFORM_LAYER)

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

		if(gloves.blood_DNA)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
			bloodsies.color = gloves.blood_color
			standing.overlays	+= bloodsies
		overlays_standing[GLOVES_LAYER]	= standing
	else
		if(blood_DNA)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
			bloodsies.color = blood_color
			overlays_standing[GLOVES_LAYER]	= bloodsies

	apply_overlay(GLOVES_LAYER)



/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)
	if(glasses)
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
		var/image/standing
		if(shoes.icon_override)
			standing = image("icon" = shoes.icon_override, "icon_state" = "[shoes.icon_state]", "layer" =-SHOES_LAYER)
		else if(shoes.sprite_sheets && shoes.sprite_sheets[species.name])
			standing = image("icon" = shoes.sprite_sheets[species.name], "icon_state" = "[shoes.icon_state]", "layer" =-SHOES_LAYER)
		else
			standing = image("icon" = 'icons/mob/feet.dmi', "icon_state" = "[shoes.icon_state]", "layer" =-SHOES_LAYER)

		if(shoes.blood_DNA)
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "shoeblood")
			bloodsies.color = shoes.blood_color
			standing.overlays += bloodsies
		overlays_standing[SHOES_LAYER] = standing
	else
		if(feet_blood_DNA)
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
					switch(S.color)
						if(1 to 4) standing.overlays += leader? helmetmarkings_sql[S.color] : helmetmarkings[S.color]

			var/image/I
			for(var/i in marine_helmet.helmet_overlays)
				I = marine_helmet.helmet_overlays[i]
				if(I)
					I = image('icons/mob/helmet_garb.dmi',src,I.icon_state)
					standing.overlays += I

		if(head.blood_DNA)
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
			bloodsies.color = head.blood_color
			standing.overlays	+= bloodsies

		overlays_standing[HEAD_LAYER] = standing

		apply_overlay(HEAD_LAYER)

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
			if(marine_armor.flags_marine_armor & ARMOR_SQUAD_OVERLAY)
				if(assigned_squad)
					var/datum/squad/S = assigned_squad
					var/leader = S.squad_leader == src
					switch(S.color)
						if(1 to 4) standing.overlays += leader? armormarkings_sql[S.color] : armormarkings[S.color]

			if(marine_armor.armor_overlays.len)
				var/image/I
				for(var/i in marine_armor.armor_overlays)
					I = marine_armor.armor_overlays[i]
					if(I)
						I = image(I.icon,src,I.icon_state)
						standing.overlays += I

		if(wear_suit.blood_DNA)
			var/obj/item/clothing/suit/S = wear_suit
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[S.blood_overlay_type]blood")
			bloodsies.color = wear_suit.blood_color
			standing.overlays	+= bloodsies

		overlays_standing[SUIT_LAYER]	= standing

	update_tail_showing()
	update_collar()

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

		if( !istype(wear_mask, /obj/item/clothing/mask/cigarette) && wear_mask.blood_DNA )
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


//Adds a collar overlay above the helmet layer if the suit has one
//	Suit needs an identically named sprite in icons/mob/collar.dmi
/mob/living/carbon/human/proc/update_collar()
	remove_overlay(COLLAR_LAYER)
	var/icon/C = new('icons/mob/collar.dmi')
	var/image/standing = null

	if(wear_suit)
		if(wear_suit.icon_state in C.IconStates())
			standing = image("icon" = C, "icon_state" = "[wear_suit.icon_state]", "layer" =-COLLAR_LAYER)

	overlays_standing[COLLAR_LAYER]	= standing

	apply_overlay(COLLAR_LAYER)



// Used mostly for creating head items
/mob/living/carbon/human/proc/generate_head_icon()
//gender no longer matters for the mouth, although there should probably be seperate base head icons.
//	var/g = "m"
//	if (gender == FEMALE)	g = "f"

	//base icons
	var/icon/face_lying		= new /icon('icons/mob/human_face.dmi',"bald_l")

	if(f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style)
			var/icon/facial_l = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_l")
			facial_l.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			face_lying.Blend(facial_l, ICON_OVERLAY)

	if(h_style)
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
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


//Human Overlays Indexes/////////
#undef MUTANTRACE_LAYER
#undef MUTATIONS_LAYER
#undef DAMAGE_LAYER
#undef UNIFORM_LAYER
#undef TAIL_LAYER
#undef ID_LAYER
#undef SHOES_LAYER
#undef GLOVES_LAYER
#undef EARS_LAYER
#undef SUIT_LAYER
#undef GLASSES_LAYER
#undef FACEMASK_LAYER
#undef BELT_LAYER
#undef SUIT_STORE_LAYER
#undef BACK_LAYER
#undef HAIR_LAYER
#undef HEAD_LAYER
#undef COLLAR_LAYER
#undef HANDCUFF_LAYER
#undef LEGCUFF_LAYER
#undef L_HAND_LAYER
#undef R_HAND_LAYER
#undef TARGETED_LAYER
#undef FIRE_LAYER
#undef BURST_LAYER
#undef TOTAL_LAYERS
