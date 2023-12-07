/datum/outfit
	var/name = ""

	var/w_uniform = null
	var/wear_suit = null
	var/toggle_helmet = TRUE
	var/back = null // Set to FALSE if your outfit needs nothing in back slot at all
	var/belt = null
	var/gloves = null
	var/shoes = null
	var/head = null
	var/mask = null
	var/neck = null
	var/ears = null
	var/glasses = null
	var/id = null
	var/l_store = null
	var/r_store = null
	var/suit_store = null
	var/r_hand = null
	var/l_hand = null
	var/internals_slot = null //ID of slot containing a gas tank
	var/list/backpack_contents = null // In the list(path=count,otherpath=count) format
	var/box // Internals box. Will be inserted at the start of backpack_contents
	var/list/implants = null
	var/accessory = null

	var/can_be_admin_equipped = TRUE // Set to FALSE if your outfit requires runtime parameters
	///the species this outfit is designed for
	var/species = SPECIES_HUMAN


/datum/outfit/proc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overridden for customization depending on client prefs,species etc
	return


/datum/outfit/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overridden for toggling internals, id binding, access etc
	return


/datum/outfit/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	pre_equip(H, visualsOnly)

	//Start with uniform,suit,backpack for additional slots
	if(w_uniform)
		H.equip_to_slot_or_del(new w_uniform(H),SLOT_W_UNIFORM, override_nodrop = TRUE)
	if(wear_suit)
		H.equip_to_slot_or_del(new wear_suit(H),SLOT_WEAR_SUIT, override_nodrop = TRUE)
	if(back)
		H.equip_to_slot_or_del(new back(H),SLOT_BACK, override_nodrop = TRUE)
	if(belt)
		H.equip_to_slot_or_del(new belt(H),SLOT_BELT, override_nodrop = TRUE)
	if(gloves)
		H.equip_to_slot_or_del(new gloves(H),SLOT_GLOVES, override_nodrop = TRUE)
	if(shoes)
		H.equip_to_slot_or_del(new shoes(H),SLOT_SHOES, override_nodrop = TRUE)
	if(head)
		H.equip_to_slot_or_del(new head(H),SLOT_HEAD, override_nodrop = TRUE)
	if(mask)
		H.equip_to_slot_or_del(new mask(H),SLOT_WEAR_MASK, override_nodrop = TRUE)
	if(ears)
		if(visualsOnly)
			H.equip_to_slot_or_del(new /obj/item/radio/headset(H), SLOT_EARS, override_nodrop = TRUE) //We don't want marine cameras. For now they have the same item_state as the rest.
		else
			H.equip_to_slot_or_del(new ears(H), SLOT_EARS, override_nodrop = TRUE)
	if(glasses)
		H.equip_to_slot_or_del(new glasses(H),SLOT_GLASSES, override_nodrop = TRUE)
	if(id)
		H.equip_to_slot_or_del(new id(H),SLOT_WEAR_ID, override_nodrop = TRUE)
	if(suit_store)
		H.equip_to_slot_or_del(new suit_store(H),SLOT_S_STORE, override_nodrop = TRUE)
	if(l_hand)
		H.put_in_l_hand(new l_hand(H))
	if(r_hand)
		H.put_in_r_hand(new r_hand(H))

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_store)
			H.equip_to_slot_or_del(new l_store(H),SLOT_L_STORE, override_nodrop = TRUE)
		if(r_store)
			H.equip_to_slot_or_del(new r_store(H),SLOT_R_STORE, override_nodrop = TRUE)

		if(box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, box)
			backpack_contents[box] = 1

		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					H.equip_to_slot_or_del(new path(H),SLOT_IN_BACKPACK, override_nodrop = TRUE)

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		if(internals_slot)
			H.internal = H.get_item_by_slot(internals_slot)
			H.update_action_buttons()

	if(implants && implants.len)
		for(var/implant_type in implants)
			var/obj/item/implant/implanter = new implant_type(H)
			implanter.implant(H)

	H.update_body()
	return TRUE


/datum/outfit/proc/get_json_data()
	. = list()
	.["outfit_type"] = type
	.["name"] = name
	.["uniform"] = w_uniform
	.["suit"] = wear_suit
	.["toggle_helmet"] = toggle_helmet
	.["back"] = back
	.["belt"] = belt
	.["gloves"] = gloves
	.["shoes"] = shoes
	.["head"] = head
	.["mask"] = mask
	.["ears"] = ears
	.["glasses"] = glasses
	.["id"] = id
	.["l_store"] = l_store
	.["r_store"] = r_store
	.["suit_store"] = suit_store
	.["r_hand"] = r_hand
	.["l_hand"] = l_hand
	.["internals_slot"] = internals_slot
	.["backpack_contents"] = backpack_contents
	.["box"] = box
	.["implants"] = implants
	.["accessory"] = accessory

/// Copy most vars from another outfit to this one
/datum/outfit/proc/copy_from(datum/outfit/target)
	name = target.name
	w_uniform = target.w_uniform
	wear_suit = target.wear_suit
	toggle_helmet = target.toggle_helmet
	back = target.back
	belt = target.belt
	gloves = target.gloves
	shoes = target.shoes
	head = target.head
	mask = target.mask
	ears = target.ears
	glasses = target.glasses
	id = target.id
	l_store = target.l_store
	r_store = target.r_store
	suit_store = target.suit_store
	r_hand = target.r_hand
	l_hand = target.l_hand
	internals_slot = target.internals_slot
	backpack_contents = target.backpack_contents
	box = target.box
	implants = target.implants
	accessory = target.accessory
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
	toggle_helmet = outfit_data["toggle_helmet"]
	back = text2path(outfit_data["back"])
	belt = text2path(outfit_data["belt"])
	gloves = text2path(outfit_data["gloves"])
	shoes = text2path(outfit_data["shoes"])
	head = text2path(outfit_data["head"])
	mask = text2path(outfit_data["mask"])
	ears = text2path(outfit_data["ears"])
	glasses = text2path(outfit_data["glasses"])
	id = text2path(outfit_data["id"])
	l_store = text2path(outfit_data["l_store"])
	r_store = text2path(outfit_data["r_store"])
	suit_store = text2path(outfit_data["suit_store"])
	r_hand = text2path(outfit_data["r_hand"])
	l_hand = text2path(outfit_data["l_hand"])
	internals_slot = outfit_data["internals_slot"]
	var/list/backpack = outfit_data["backpack_contents"]
	backpack_contents = list()
	for(var/item in backpack)
		var/itype = text2path(item)
		if(itype)
			backpack_contents[itype] = backpack[item]
	box = text2path(outfit_data["box"])
	var/list/impl = outfit_data["implants"]
	implants = list()
	for(var/I in impl)
		var/imptype = text2path(I)
		if(imptype)
			implants += imptype
	accessory = text2path(outfit_data["accessory"])
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
	l_store = human_mob.l_store?.type
	r_store = human_mob.r_store?.type
