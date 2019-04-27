
/obj/item/encryptionkey
	name = "Standard Encryption Key"
	desc = "An encryption key for a radio headset."
	icon = 'icons/obj/items/radio.dmi'
	icon_state = "cypherkey"
	item_state = ""
	w_class = 1
	var/translate_binary = FALSE
	var/translate_hive = FALSE
	var/syndie = FALSE
	var/list/channels = list()


/obj/item/encryptionkey/syndicate
	icon_state = "cypherkey"
	channels = list("Syndicate" = TRUE)
	origin_tech = "syndicate=3"
	syndie = TRUE//Signifies that it de-crypts Syndicate transmissions

/obj/item/encryptionkey/binary
	icon_state = "cypherkey"
	translate_binary = TRUE
	origin_tech = "syndicate=3"



/obj/item/encryptionkey/ai_integrated
	name = "AI Integrated Encryption Key"
	desc = "Integrated encryption key"
	icon_state = "cap_cypherkey"
	channels = list("Theseus" = TRUE, "Command" = TRUE, "MP" = TRUE, "Engi" = TRUE, "MedSci" = TRUE)

/obj/item/encryptionkey/engi
	name = "Engineering Radio Encryption Key"
	icon_state = "eng_cypherkey"
	channels = list("Engi" = TRUE)

/obj/item/encryptionkey/sec
	name = "Security Radio Encryption Key"
	icon_state = "sec_cypherkey"
	channels = list("MP" = TRUE)

/obj/item/encryptionkey/med
	name = "Medical Radio Encryption Key"
	icon_state = "med_cypherkey"
	channels = list("MedSci" = TRUE)

/obj/item/encryptionkey/ce
	name = "Chief Ship Engineer's Encryption Key"
	icon_state = "ce_cypherkey"
	channels = list("Engi" = TRUE, "Command" = TRUE)

/obj/item/encryptionkey/cmo
	name = "Chief Medical Officer's Encryption Key"
	icon_state = "cmo_cypherkey"
	channels = list("MedSci" = TRUE, "Command" = TRUE)

/obj/item/encryptionkey/req
	name = "Supply Radio Encryption Key"
	icon_state = "cargo_cypherkey"
	channels = list("Req" = TRUE)

/obj/item/encryptionkey/mmpo
	name = "\improper Military Police radio encryption key"
	icon_state = "rob_cypherkey"
	channels = list("MP" = TRUE, "Command" = TRUE)



/obj/item/encryptionkey/ert
	name = "ERT Radio Encryption Key"
	channels = list("Response Team" = TRUE, "Command" = TRUE, "MedSci" = TRUE, "Engi" = TRUE)






//MARINE ENCRYPTION KEYS

/obj/item/encryptionkey/cmpcom
	name = "\improper Marine Command Master at Arms radio encryption key"
	icon_state = "cap_cypherkey"
	channels = list("Command" = TRUE, "MP" = TRUE, "Alpha" = TRUE, "Bravo" = TRUE, "Charlie" = TRUE, "Delta" = TRUE, "Engi" = TRUE, "MedSci" = TRUE, "Req" = TRUE)

/obj/item/encryptionkey/mcom
	name = "\improper Marine Command radio encryption key"
	icon_state = "cap_cypherkey"
	channels = list("Command" = TRUE, "MP" = TRUE, "Alpha" = TRUE, "Bravo" = TRUE, "Charlie" = TRUE, "Delta" = TRUE, "Engi" = TRUE, "MedSci" = TRUE, "Req" = TRUE)

/obj/item/encryptionkey/mcom/ai //AI only.
	channels = list("Command" = TRUE, "MP" = TRUE, "Alpha" = TRUE, "Bravo" = TRUE, "Charlie" = TRUE, "Delta" = TRUE, "Engi" = TRUE, "MedSci" = TRUE, "Req" = TRUE)


/obj/item/encryptionkey/squadlead
	name = "\improper Squad Leader encryption key"
	icon_state = "hop_cypherkey"
	channels = list("Command" = TRUE)

/obj/item/encryptionkey/alpha
	name = "\improper Alpha Squad radio encryption key"
	icon_state = "eng_cypherkey"
	channels = list("Alpha" = TRUE)

/obj/item/encryptionkey/bravo
	name = "\improper Bravo Squad radio encryption key"
	icon_state = "cypherkey"
	channels = list("Bravo" = TRUE)

/obj/item/encryptionkey/charlie
	name = "\improper Charlie Squad radio encryption key"
	icon_state = "sci_cypherkey"
	channels = list("Charlie" = TRUE)

/obj/item/encryptionkey/delta
	name = "\improper Delta Squad radio encryption key"
	icon_state = "hos_cypherkey"
	channels = list("Delta" = TRUE)

/obj/item/encryptionkey/general
    	name = "\improper General radio encryption key"
    	icon_state = "cypherkey"
    	channels = list("Theseus" = TRUE)


//PMCs
/obj/item/encryptionkey/dutch
	name = "\improper Colonist encryption key"
	channels = list("Colonist" = TRUE)

/obj/item/encryptionkey/PMC
	name = "\improper Nanotrasen encryption key"
	channels = list("NT PMC" = TRUE)

/obj/item/encryptionkey/bears
	name = "\improper UPP encryption key"
	syndie = TRUE
	channels = list("UPP" = TRUE)

/obj/item/encryptionkey/commando
	name = "\improper NT commando encryption key"
	channels = list("SpecOps" = TRUE)

/obj/item/encryptionkey/imperial
	name = "\improper Imperial encryption key"
	channels = list("Imperial" = TRUE)
