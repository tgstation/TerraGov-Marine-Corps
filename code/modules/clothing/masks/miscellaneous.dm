/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = ""
	icon_state = "muzzle"
	item_state = "blindfold"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.9
	equip_delay_other = 20

/obj/item/clothing/mask/muzzle/attack_paw(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.wear_mask)
			to_chat(user, "<span class='warning'>I need help taking this off!</span>")
			return
	..()

/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = ""
	icon_state = "sterile"
	item_state = "sterile"
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH
	visor_flags_inv = HIDEFACE
	visor_flags_cover = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.9
	permeability_coefficient = 0.01
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 25, "rad" = 0, "fire" = 0, "acid" = 0)
	actions_types = list(/datum/action/item_action/adjust)

/obj/item/clothing/mask/surgical/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = ""
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE

/obj/item/clothing/mask/fakemoustache/italian
	name = "italian moustache"
	desc = ""
	modifies_speech = TRUE

/obj/item/clothing/mask/fakemoustache/italian/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/italian_words = strings("italian_replacement.json", "italian")

		for(var/key in italian_words)
			var/value = italian_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		if(prob(3))
			message += pick(" Ravioli, ravioli, give me the formuoli!"," Mamma-mia!"," Mamma-mia! That's a spicy meat-ball!", " La la la la la funiculi funicula!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/obj/item/clothing/mask/joy
	name = "joy mask"
	desc = ""
	icon_state = "joy"

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = ""
	icon_state = "pig"
	item_state = "pig"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	clothing_flags = VOICEBOX_TOGGLABLE
	w_class = WEIGHT_CLASS_SMALL
	modifies_speech = TRUE

/obj/item/clothing/mask/pig/handle_speech(datum/source, list/speech_args)
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		speech_args[SPEECH_MESSAGE] = pick("Oink!","Squeeeeeeee!","Oink Oink!")

/obj/item/clothing/mask/pig/cursed
	name = "pig face"
	desc = ""
	flags_inv = HIDEFACIALHAIR
	clothing_flags = NONE

/obj/item/clothing/mask/pig/cursed/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)
	playsound(get_turf(src), 'sound/blank.ogg', 50, TRUE)

///frog mask - reeee!!
/obj/item/clothing/mask/frog
	name = "frog mask"
	desc = ""
	icon_state = "frog"
	item_state = "frog"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	clothing_flags = VOICEBOX_TOGGLABLE
	modifies_speech = TRUE

/obj/item/clothing/mask/frog/handle_speech(datum/source, list/speech_args) //whenever you speak
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		if(prob(5)) //sometimes, the angry spirit finds others words to speak.
			speech_args[SPEECH_MESSAGE] = pick("HUUUUU!!","SMOOOOOKIN'!!","Hello my baby, hello my honey, hello my rag-time gal.", "Feels bad, man.", "GIT DIS GUY OFF ME!!" ,"SOMEBODY STOP ME!!", "NORMIES, GET OUT!!")
		else
			speech_args[SPEECH_MESSAGE] = pick("Ree!!", "Reee!!","REEE!!","REEEEE!!") //but its usually just angry gibberish,

/obj/item/clothing/mask/frog/cursed
	clothing_flags = NONE

/obj/item/clothing/mask/frog/cursed/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)

/obj/item/clothing/mask/frog/cursed/equipped(mob/user, slot)
	var/mob/living/carbon/C = user
	if(C.wear_mask == src && HAS_TRAIT_FROM(src, TRAIT_NODROP, CURSED_MASK_TRAIT))
		to_chat(user, "<span class='danger'>[src] was cursed! Ree!!</span>")
	return ..()

/obj/item/clothing/mask/cowmask
	name = "cow mask"
	icon_state = "cowmask"
	item_state = "cowmask"
	clothing_flags = VOICEBOX_TOGGLABLE
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	modifies_speech = TRUE

/obj/item/clothing/mask/cowmask/handle_speech(datum/source, list/speech_args)
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		speech_args[SPEECH_MESSAGE] = pick("Moooooooo!","Moo!","Moooo!")

/obj/item/clothing/mask/cowmask/cursed
	name = "cow face"
	desc = ""
	flags_inv = HIDEFACIALHAIR
	clothing_flags = NONE

/obj/item/clothing/mask/cowmask/cursed/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)
	playsound(get_turf(src), 'sound/blank.ogg', 50, TRUE)

/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = ""
	icon_state = "horsehead"
	item_state = "horsehead"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEYES|HIDEEARS
	w_class = WEIGHT_CLASS_SMALL
	clothing_flags = VOICEBOX_TOGGLABLE

/obj/item/clothing/mask/horsehead/handle_speech(datum/source, list/speech_args)
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		speech_args[SPEECH_MESSAGE] = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")

/obj/item/clothing/mask/horsehead/cursed
	name = "horse face"
	desc = ""
	clothing_flags = NONE
	flags_inv = HIDEFACIALHAIR

/obj/item/clothing/mask/horsehead/cursed/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)
	playsound(get_turf(src), 'sound/blank.ogg', 50, TRUE)

/obj/item/clothing/mask/rat
	name = "rat mask"
	desc = ""
	icon_state = "rat"
	item_state = "rat"
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/mask/rat/fox
	name = "fox mask"
	desc = ""
	icon_state = "fox"
	item_state = "fox"

/obj/item/clothing/mask/rat/bee
	name = "bee mask"
	desc = ""
	icon_state = "bee"
	item_state = "bee"

/obj/item/clothing/mask/rat/bear
	name = "bear mask"
	desc = ""
	icon_state = "bear"
	item_state = "bear"

/obj/item/clothing/mask/rat/bat
	name = "bat mask"
	desc = ""
	icon_state = "bat"
	item_state = "bat"

/obj/item/clothing/mask/rat/raven
	name = "raven mask"
	desc = ""
	icon_state = "raven"
	item_state = "raven"

/obj/item/clothing/mask/rat/jackal
	name = "jackal mask"
	desc = ""
	icon_state = "jackal"
	item_state = "jackal"

/obj/item/clothing/mask/rat/tribal
	name = "tribal mask"
	desc = ""
	icon_state = "bumba"
	item_state = "bumba"

/obj/item/clothing/mask/bandana
	name = "botany bandana"
	desc = ""
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH | PEPPERPROOF
	slot_flags = ITEM_SLOT_MASK
	adjusted_flags = ITEM_SLOT_HEAD
	icon_state = "bandbotany"

/obj/item/clothing/mask/bandana/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/bandana/AltClick(mob/user)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if((C.get_item_by_slot(SLOT_HEAD == src)) || (C.get_item_by_slot(SLOT_WEAR_MASK) == src))
			to_chat(user, "<span class='warning'>I can't tie [src] while wearing it!</span>")
			return
	if(slot_flags & ITEM_SLOT_HEAD)
		to_chat(user, "<span class='warning'>I must undo [src] before you can tie it into a neckerchief!</span>")
	else
		if(user.is_holding(src))
			var/obj/item/clothing/neck/neckerchief/nk = new(src)
			nk.name = "[name] neckerchief"
			nk.desc = ""
			nk.icon_state = icon_state
			nk.sourceBandanaType = src.type
			var/currentHandIndex = user.get_held_index_of_item(src)
			user.transferItemToLoc(src, null)
			user.put_in_hand(nk, currentHandIndex)
			user.visible_message("<span class='notice'>I tie [src] up like a neckerchief.</span>", "<span class='notice'>[user] ties [src] up like a neckerchief.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>I must be holding [src] in order to tie it!</span>")

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	desc = ""
	icon_state = "bandred"

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	desc = ""
	icon_state = "bandblue"

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	desc = ""
	icon_state = "bandgreen"

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	desc = ""
	icon_state = "bandgold"

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	desc = ""
	icon_state = "bandblack"

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = ""
	icon_state = "bandskull"

/obj/item/clothing/mask/bandana/durathread
	name = "durathread bandana"
	desc =  "A bandana made from durathread, you wish it would provide some protection to its wearer, but it's far too thin..."
	icon_state = "banddurathread"

/obj/item/clothing/mask/mummy
	name = "mummy mask"
	desc = ""
	icon_state = "mummy_mask"
	item_state = "mummy_mask"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/mask/scarecrow
	name = "sack mask"
	desc = ""
	icon_state = "scarecrow_sack"
	item_state = "scarecrow_sack"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/mask/gondola
	name = "gondola mask"
	desc = ""
	icon_state = "gondola"
	item_state = "gondola"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	modifies_speech = TRUE

/obj/item/clothing/mask/gondola/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/spurdo_words = strings("spurdo_replacement.json", "spurdo")
		for(var/key in spurdo_words)
			var/value = spurdo_words[key]
			if(islist(value))
				value = pick(value)
			message = replacetextEx(message,regex(uppertext(key),"g"), "[uppertext(value)]")
			message = replacetextEx(message,regex(capitalize(key),"g"), "[capitalize(value)]")
			message = replacetextEx(message,regex(key,"g"), "[value]")
	speech_args[SPEECH_MESSAGE] = trim(message)
