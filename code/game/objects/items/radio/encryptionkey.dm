/obj/item/encryptionkey
	name = "Standard Encryption Key"
	desc = "An encryption key for a radio headset."
	icon = 'icons/obj/items/radio.dmi'
	icon_state = "cypherkey"
	item_state = ""
	w_class = 1
	var/list/channels = list()


/obj/item/encryptionkey/engi
	name = "Engineering Radio Encryption Key"
	icon_state = "eng_cypherkey"
	channels = list(RADIO_CHANNEL_ENGINEERING = TRUE)

/obj/item/encryptionkey/sec
	name = "Security Radio Encryption Key"
	icon_state = "sec_cypherkey"
	channels = list(RADIO_CHANNEL_POLICE = TRUE)

/obj/item/encryptionkey/med
	name = "Medical Radio Encryption Key"
	icon_state = "med_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = TRUE)

/obj/item/encryptionkey/ce
	name = "Chief Ship Engineer's Encryption Key"
	icon_state = "ce_cypherkey"
	channels = list(RADIO_CHANNEL_ENGINEERING = TRUE, RADIO_CHANNEL_COMMAND = TRUE)

/obj/item/encryptionkey/cmo
	name = "Chief Medical Officer's Encryption Key"
	icon_state = "cmo_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = TRUE, RADIO_CHANNEL_COMMAND = TRUE)

/obj/item/encryptionkey/req
	name = "Supply Radio Encryption Key"
	icon_state = "cargo_cypherkey"
	channels = list(RADIO_CHANNEL_REQUISITIONS = TRUE)

/obj/item/encryptionkey/mmpo
	name = "\improper Military Police radio encryption key"
	icon_state = "rob_cypherkey"
	channels = list(RADIO_CHANNEL_POLICE = TRUE, RADIO_CHANNEL_COMMAND = TRUE)


//Marine
/obj/item/encryptionkey/cmpcom
	name = "\improper Marine Command Master at Arms radio encryption key"
	icon_state = "cap_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = TRUE, RADIO_CHANNEL_POLICE = TRUE, RADIO_CHANNEL_ALPHA = TRUE, RADIO_CHANNEL_BRAVO = TRUE, RADIO_CHANNEL_CHARLIE = TRUE, RADIO_CHANNEL_DELTA = TRUE, RADIO_CHANNEL_ENGINEERING = TRUE, RADIO_CHANNEL_MEDICAL = TRUE, RADIO_CHANNEL_REQUISITIONS = TRUE)

/obj/item/encryptionkey/mcom
	name = "\improper Marine Command radio encryption key"
	icon_state = "cap_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = TRUE, RADIO_CHANNEL_POLICE = TRUE, RADIO_CHANNEL_ALPHA = TRUE, RADIO_CHANNEL_BRAVO = TRUE, RADIO_CHANNEL_CHARLIE = TRUE, RADIO_CHANNEL_DELTA = TRUE, RADIO_CHANNEL_ENGINEERING = TRUE, RADIO_CHANNEL_MEDICAL = TRUE, RADIO_CHANNEL_REQUISITIONS = TRUE)

/obj/item/encryptionkey/mcom/ai //AI only.
	channels = list(RADIO_CHANNEL_COMMAND = TRUE, RADIO_CHANNEL_POLICE = TRUE, RADIO_CHANNEL_ALPHA = TRUE, RADIO_CHANNEL_BRAVO = TRUE, RADIO_CHANNEL_CHARLIE = TRUE, RADIO_CHANNEL_DELTA = TRUE, RADIO_CHANNEL_ENGINEERING = TRUE, RADIO_CHANNEL_MEDICAL = TRUE, RADIO_CHANNEL_REQUISITIONS = TRUE)


/obj/item/encryptionkey/squadlead
	name = "\improper Squad Leader encryption key"
	icon_state = "hop_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = TRUE)

/obj/item/encryptionkey/alpha
	name = "\improper Alpha Squad radio encryption key"
	icon_state = "eng_cypherkey"
	channels = list(RADIO_CHANNEL_ALPHA = TRUE)

/obj/item/encryptionkey/bravo
	name = "\improper Bravo Squad radio encryption key"
	icon_state = "cypherkey"
	channels = list(RADIO_CHANNEL_BRAVO = TRUE)

/obj/item/encryptionkey/charlie
	name = "\improper Charlie Squad radio encryption key"
	icon_state = "sci_cypherkey"
	channels = list(RADIO_CHANNEL_CHARLIE = TRUE)

/obj/item/encryptionkey/delta
	name = "\improper Delta Squad radio encryption key"
	icon_state = "hos_cypherkey"
	channels = list(RADIO_CHANNEL_DELTA = TRUE)

/obj/item/encryptionkey/general
    	name = "\improper General radio encryption key"
    	icon_state = "cypherkey"
    	channels = list(RADIO_CHANNEL_COMMON = TRUE)


//ERT
/obj/item/encryptionkey/dutch
	name = "\improper Colonist encryption key"
	channels = list(RADIO_CHANNEL_COLONIST = TRUE)


/obj/item/encryptionkey/PMC
	name = "\improper Nanotrasen encryption key"
	channels = list(RADIO_CHANNEL_PMC = TRUE)


/obj/item/encryptionkey/bears
	name = "\improper UPP encryption key"
	channels = list(RADIO_CHANNEL_UPP = TRUE)


/obj/item/encryptionkey/commando
	name = "\improper NT commando encryption key"
	channels = list(RADIO_CHANNEL_DEATHSQUAD = TRUE)


/obj/item/encryptionkey/imperial
	name = "\improper Imperial encryption key"
	channels = list(RADIO_CHANNEL_IMPERIAL = TRUE)