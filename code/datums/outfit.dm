/datum/outfit
	var/name = ""

	var/w_uniform = null
	var/wear_suit = null
	var/toggle_helmet = TRUE
	var/back = null
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
		H.equip_to_slot_or_del(new w_uniform(H),SLOT_W_UNIFORM)
	if(wear_suit)
		H.equip_to_slot_or_del(new wear_suit(H),SLOT_WEAR_SUIT)
	if(back)
		H.equip_to_slot_or_del(new back(H),SLOT_BACK)
	if(belt)
		H.equip_to_slot_or_del(new belt(H),SLOT_BELT)
	if(gloves)
		H.equip_to_slot_or_del(new gloves(H),SLOT_GLOVES)
	if(shoes)
		H.equip_to_slot_or_del(new shoes(H),SLOT_SHOES)
	if(head)
		H.equip_to_slot_or_del(new head(H),SLOT_HEAD)
	if(mask)
		H.equip_to_slot_or_del(new mask(H),SLOT_WEAR_MASK)
	if(ears)
		H.equip_to_slot_or_del(new ears(H),SLOT_EARS)
	if(glasses)
		H.equip_to_slot_or_del(new glasses(H),SLOT_GLASSES)
	if(id)
		H.equip_to_slot_or_del(new id(H),SLOT_WEAR_ID)
	if(suit_store)
		H.equip_to_slot_or_del(new suit_store(H),SLOT_S_STORE)
	if(l_hand)
		H.put_in_l_hand(new l_hand(H))
	if(r_hand)
		H.put_in_r_hand(new r_hand(H))

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_store)
			H.equip_to_slot_or_del(new l_store(H),SLOT_L_STORE)
		if(r_store)
			H.equip_to_slot_or_del(new r_store(H),SLOT_R_STORE)

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
					H.equip_to_slot_or_del(new path(H),SLOT_IN_BACKPACK)

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		if(internals_slot)
			H.internal = H.get_item_by_slot(internals_slot)
			H.update_action_buttons()

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
	.["neck"] = neck
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