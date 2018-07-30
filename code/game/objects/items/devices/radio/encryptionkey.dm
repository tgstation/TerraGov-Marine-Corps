
/obj/item/device/encryptionkey
	name = "Standard Encryption Key"
	desc = "An encryption key for a radio headset."
	icon = 'icons/obj/items/radio.dmi'
	icon_state = "cypherkey"
	item_state = ""
	w_class = 1
	var/translate_binary = 0
	var/translate_hive = 0
	var/syndie = 0
	var/list/channels = list()


/obj/item/device/encryptionkey/syndicate
	icon_state = "cypherkey"
	channels = list("Syndicate" = 1)
	origin_tech = "syndicate=3"
	syndie = 1//Signifies that it de-crypts Syndicate transmissions

/obj/item/device/encryptionkey/binary
	icon_state = "cypherkey"
	translate_binary = 1
	origin_tech = "syndicate=3"



/obj/item/device/encryptionkey/ai_integrated
	name = "AI Integrated Encryption Key"
	desc = "Integrated encryption key"
	icon_state = "cap_cypherkey"
	channels = list("Command" = 1, "MP" = 1, "Engi" = 1, "MedSci" = 1)

/obj/item/device/encryptionkey/engi
	name = "Engineering Radio Encryption Key"
	icon_state = "eng_cypherkey"
	channels = list("Engi" = 1)

/obj/item/device/encryptionkey/sec
	name = "Security Radio Encryption Key"
	icon_state = "sec_cypherkey"
	channels = list("MP" = 1)

/obj/item/device/encryptionkey/med
	name = "Medical Radio Encryption Key"
	icon_state = "med_cypherkey"
	channels = list("MedSci" = 1)

/obj/item/device/encryptionkey/ce
	name = "Chief Engineer's Encryption Key"
	icon_state = "ce_cypherkey"
	channels = list("Engi" = 1, "Command" = 1)

/obj/item/device/encryptionkey/cmo
	name = "Chief Medical Officer's Encryption Key"
	icon_state = "cmo_cypherkey"
	channels = list("MedSci" = 1, "Command" = 1)

/obj/item/device/encryptionkey/req
	name = "Supply Radio Encryption Key"
	icon_state = "cargo_cypherkey"
	channels = list("Req" = 1)

/obj/item/device/encryptionkey/mmpo
	name = "\improper Military Police radio encryption key"
	icon_state = "rob_cypherkey"
	channels = list("MP" = 1, "Command" = 1)



/obj/item/device/encryptionkey/ert
	name = "W-Y ERT Radio Encryption Key"
	channels = list("Response Team" = 1, "Command" = 1, "MedSci" = 1, "Engi" = 1)






//MARINE ENCRYPTION KEYS

/obj/item/device/encryptionkey/cmpcom
	name = "\improper Marine Chief MP radio encryption key"
	icon_state = "cap_cypherkey"
	channels = list("Command" = 1, "MP" = 1, "Alpha" = 0, "Bravo" = 0, "Charlie" = 0, "Delta" = 0, "Engi" = 1, "MedSci" = 1, "Req" = 1 )

/obj/item/device/encryptionkey/mcom
	name = "\improper Marine Command radio encryption key"
	icon_state = "cap_cypherkey"
	channels = list("Command" = 1, "Alpha" = 0, "Bravo" = 0, "Charlie" = 0, "Delta" = 0, "Engi" = 1, "MedSci" = 1, "Req" = 1 )

/obj/item/device/encryptionkey/mcom/ai //AI only.
	channels = list("Command" = 1, "MP" = 1, "Alpha" = 1, "Bravo" = 1, "Charlie" = 1, "Delta" = 1, "Engi" = 1, "MedSci" = 1, "Req" = 1 )


/obj/item/device/encryptionkey/squadlead
	name = "\improper Squad Leader encryption key"
	icon_state = "hop_cypherkey"
	channels = list("Command" = 1)

/obj/item/device/encryptionkey/alpha
	name = "\improper Alpha Squad radio encryption key"
	icon_state = "eng_cypherkey"
	channels = list("Alpha" = 1)

/obj/item/device/encryptionkey/bravo
	name = "\improper Bravo Squad radio encryption key"
	icon_state = "cypherkey"
	channels = list("Bravo" = 1)

/obj/item/device/encryptionkey/charlie
	name = "\improper Charlie Squad radio encryption key"
	icon_state = "sci_cypherkey"
	channels = list("Charlie" = 1)

/obj/item/device/encryptionkey/delta
	name = "\improper Delta Squad radio encryption key"
	icon_state = "hos_cypherkey"
	channels = list("Delta" = 1)




//PMCs
/obj/item/device/encryptionkey/dutch
	name = "\improper Colonist encryption key"
	channels = list("Colonist" = 1)

/obj/item/device/encryptionkey/PMC
	name = "\improper Weyland Yutani encryption key"
	channels = list("WY PMC" = 1)

/obj/item/device/encryptionkey/bears
	name = "\improper UPP encryption key"
	syndie = 1
	channels = list("UPP" = 1)

/obj/item/device/encryptionkey/commando
	name = "\improper WY commando encryption key"
	channels = list("SpecOps" = 1)
