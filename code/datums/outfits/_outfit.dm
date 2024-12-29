/datum/outfit
	/// The name of this outfit that will show in select outfit
	var/name = ""
	/// The worn uniform of this outfit
	var/w_uniform
	/// The worn suit of this outfit
	var/wear_suit
	/// The item in the slot of this outfit, set to FALSE if you want to have nothing (defaults to player pref if null)
	var/back
	/// The item in the belt slot
	var/belt
	/// The item in the glove slot
	var/gloves
	/// The item in the shoe slot
	var/shoes
	/// The item in the head slot
	var/head
	/// The item in the mask slot
	var/mask
	/// The item in the ear slot
	var/ears
	/// The item in the glasses/eye slot
	var/glasses
	/// The item in the ID slot
	var/id
	/// The item in the left pocket
	var/l_pocket
	/// The item in the right pocket
	var/r_pocket
	/// The item in the suit storage slot
	var/suit_store
	/// The item in the right hand
	var/r_hand
	/// The item in the left_hand
	var/l_hand
	/**
	  * List of items that should go in the backpack of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/backpack_contents
	/**
	  * List of items that should go in the belt of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/belt_contents
	/**
	  * List of items that should go in the shoes of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/shoe_contents
	/**
	  * List of items that should go in the suit storage of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/suit_contents
	/**
	  * List of items that should go in the webbing of the user's uniform
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/webbing_contents
	/**
	  * List of items that should go in the headwear of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/head_contents
	/**
	  * List of items that should go in the right pocket container of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/r_pocket_contents
	/**
	  * List of items that should go in the left pocket container of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/l_pocket_contents
	/// The implants this outfit comes with
	var/list/implants
	///the species this outfit is designed for
	var/species = SPECIES_HUMAN
	/// A list of all the container contents lists, used to save on copypasta, populated in New()
	var/list/container_list = list()

/datum/outfit/New()
	. = ..()
	container_list["slot_in_back"] = backpack_contents
	container_list["slot_in_belt"] = belt_contents
	container_list["slot_in_boot"] = shoe_contents
	container_list["slot_in_suit"] = suit_contents
	container_list["slot_in_accessory"] = webbing_contents
	container_list["slot_in_head"] = head_contents
	container_list["slot_in_r_store"] = r_pocket_contents
	container_list["slot_in_l_store"] = l_pocket_contents

/// This gets ran before we equip any items from the variables
/datum/outfit/proc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return


/// This gets ran after we equip any times from the variables, don't use this to put things inside containers
/datum/outfit/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return


/datum/outfit/proc/equip(mob/living/carbon/human/equipping_human, visualsOnly = FALSE)
	pre_equip(equipping_human, visualsOnly)

	//Start with uniform,suit,backpack for additional slots
	if(w_uniform)
		equipping_human.equip_to_slot_or_del(new w_uniform(equipping_human), SLOT_W_UNIFORM, override_nodrop = TRUE)
	if(wear_suit)
		equipping_human.equip_to_slot_or_del(new wear_suit(equipping_human), SLOT_WEAR_SUIT, override_nodrop = TRUE)
	if(back)
		equipping_human.equip_to_slot_or_del(new back(equipping_human), SLOT_BACK, override_nodrop = TRUE)
	if(belt)
		equipping_human.equip_to_slot_or_del(new belt(equipping_human), SLOT_BELT, override_nodrop = TRUE)
	if(gloves)
		equipping_human.equip_to_slot_or_del(new gloves(equipping_human), SLOT_GLOVES, override_nodrop = TRUE)
	if(shoes)
		equipping_human.equip_to_slot_or_del(new shoes(equipping_human), SLOT_SHOES, override_nodrop = TRUE)
	if(head)
		equipping_human.equip_to_slot_or_del(new head(equipping_human), SLOT_HEAD, override_nodrop = TRUE)
	if(mask)
		equipping_human.equip_to_slot_or_del(new mask(equipping_human), SLOT_WEAR_MASK, override_nodrop = TRUE)
	if(ears)
		if(visualsOnly)
			equipping_human.equip_to_slot_or_del(new /obj/item/radio/headset(equipping_human), SLOT_EARS, override_nodrop = TRUE) //We don't want marine cameras. For now they have the same worn_icon_state as the rest.
		else
			equipping_human.equip_to_slot_or_del(new ears(equipping_human), SLOT_EARS, override_nodrop = TRUE)
	if(glasses)
		equipping_human.equip_to_slot_or_del(new glasses(equipping_human), SLOT_GLASSES, override_nodrop = TRUE)
	if(id)
		equipping_human.equip_to_slot_or_del(new id(equipping_human), SLOT_WEAR_ID, override_nodrop = TRUE)
	if(suit_store)
		equipping_human.equip_to_slot_or_del(new suit_store(equipping_human), SLOT_S_STORE, override_nodrop = TRUE)
	if(l_hand)
		equipping_human.put_in_l_hand(new l_hand(equipping_human))
	if(r_hand)
		equipping_human.put_in_r_hand(new r_hand(equipping_human))

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket)
			equipping_human.equip_to_slot_or_del(new l_pocket(equipping_human), SLOT_L_STORE, override_nodrop = TRUE)
		if(r_pocket)
			equipping_human.equip_to_slot_or_del(new r_pocket(equipping_human), SLOT_R_STORE, override_nodrop = TRUE)

		for(var/slot in container_list)
			for(var/path in container_list[slot])
				var/number = container_list[slot][path]
				if(!isnum(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					if(!equipping_human.equip_to_slot_or_del(new path(equipping_human), GLOB.slot_str_to_slot[slot], TRUE))
						stack_trace("Failed to place item of type [path] from list in slot [slot] in outfit of type [type]!")

	post_equip(equipping_human, visualsOnly)

	for(var/implant_type in implants)
		var/obj/item/implant/implanter = new implant_type(equipping_human)
		implanter.implant(equipping_human)

	equipping_human.update_body()
	return TRUE


/datum/outfit/proc/get_json_data()
	. = list()
	.["outfit_type"] = type
	.["name"] = name
	.["uniform"] = w_uniform
	.["suit"] = wear_suit
	.["back"] = back
	.["belt"] = belt
	.["gloves"] = gloves
	.["shoes"] = shoes
	.["head"] = head
	.["mask"] = mask
	.["ears"] = ears
	.["glasses"] = glasses
	.["id"] = id
	.["l_pocket"] = l_pocket
	.["r_pocket"] = r_pocket
	.["suit_store"] = suit_store
	.["r_hand"] = r_hand
	.["l_hand"] = l_hand
	.["slot_in_back"] = backpack_contents
	.["slot_in_belt"] = belt_contents
	.["slot_in_boot"] = shoe_contents
	.["slot_in_suit"] = suit_contents
	.["slot_in_accessory"] = webbing_contents
	.["slot_in_head"] = head_contents
	.["slot_in_r_store"] = r_pocket_contents
	.["slot_in_l_store"] = l_pocket_contents
	.["implants"] = implants

/// Copy most vars from another outfit to this one
/datum/outfit/proc/copy_from(datum/outfit/target)
	name = target.name
	w_uniform = target.w_uniform
	wear_suit = target.wear_suit
	back = target.back
	belt = target.belt
	gloves = target.gloves
	shoes = target.shoes
	head = target.head
	mask = target.mask
	ears = target.ears
	glasses = target.glasses
	id = target.id
	l_pocket = target.l_pocket
	r_pocket = target.r_pocket
	suit_store = target.suit_store
	r_hand = target.r_hand
	l_hand = target.l_hand
	backpack_contents = target.backpack_contents
	belt_contents = target.belt_contents
	shoe_contents = target.shoe_contents
	suit_contents = target.suit_contents
	webbing_contents = target.webbing_contents
	head_contents = target.head_contents
	r_pocket_contents = target.r_pocket_contents
	l_pocket_contents = target.l_pocket_contents
	implants = target.implants
	return TRUE

/datum/outfit/proc/save_to_file()
	var/stored_data = get_json_data()
	var/json = json_encode(stored_data)
	//Kinda annoying but as far as i can tell you need to make actual file.
	var/f = file("data/TempOutfitUpload")
	fdel(f)
	WRITE_FILE(f, json)
	usr << ftp(f, "[name].json")


/datum/outfit/proc/load_from(list/outfit_data)
	name = outfit_data["name"]
	w_uniform = text2path(outfit_data["w_uniform"])
	wear_suit = text2path(outfit_data["wear_suit"])
	back = text2path(outfit_data["back"])
	belt = text2path(outfit_data["belt"])
	gloves = text2path(outfit_data["gloves"])
	shoes = text2path(outfit_data["shoes"])
	head = text2path(outfit_data["head"])
	mask = text2path(outfit_data["mask"])
	ears = text2path(outfit_data["ears"])
	glasses = text2path(outfit_data["glasses"])
	id = text2path(outfit_data["id"])
	l_pocket = text2path(outfit_data["l_pocket"])
	r_pocket = text2path(outfit_data["r_pocket"])
	suit_store = text2path(outfit_data["suit_store"])
	r_hand = text2path(outfit_data["r_hand"])
	l_hand = text2path(outfit_data["l_hand"])
	var/list/backpack = outfit_data["backpack_contents"]
	backpack_contents = list()
	for(var/item in backpack)
		var/itype = text2path(item)
		if(itype)
			backpack_contents[itype] = backpack[item]
	var/list/impl = outfit_data["implants"]
	implants = list()
	for(var/I in impl)
		var/imptype = text2path(I)
		if(imptype)
			implants += imptype
	return TRUE

/datum/outfit/proc/from_mob(mob/living/base)
	. = TRUE
	if(!isliving(base))
		return FALSE

	name = "Outfit: [base]"
	r_hand = base.r_hand
	l_hand = base.l_hand

	if(!iscarbon(base))
		return
	var/mob/living/carbon/carbon_mob = base
	back = carbon_mob.back?.type
	mask = carbon_mob.s_active?.type

	if(!ishuman(base))
		return
	var/mob/living/carbon/human/human_mob = base
	w_uniform = human_mob.w_uniform?.type
	wear_suit = human_mob.wear_suit?.type
	belt = human_mob.belt?.type
	gloves = human_mob.gloves?.type
	shoes = human_mob.shoes?.type
	head = human_mob.head?.type
	ears = human_mob.wear_ear?.type
	glasses = human_mob.glasses?.type
	id = human_mob.wear_id?.type
	l_pocket = human_mob.l_store?.type
	r_pocket = human_mob.r_store?.type

/datum/outfit/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_TO_OUTFIT_EDITOR, "Outfit Editor")

/datum/outfit/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_TO_OUTFIT_EDITOR])
		if(!check_rights(NONE))
			return
		usr.client.open_outfit_editor(src)
