/obj/item/implant/sad_trombone
	name = "sad trombone implant"
	activated = 0

/obj/item/implant/sad_trombone/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Honk Co. Sad Trombone Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				"}
	return dat

/obj/item/implant/sad_trombone/trigger(emote, mob/source)
	if(emote == "deathgasp")
		playsound(loc, 'sound/blank.ogg', 50, FALSE)

/obj/item/implanter/sad_trombone
	name = "implanter (sad trombone)"
	imp_type = /obj/item/implant/sad_trombone

/obj/item/implantcase/sad_trombone
	name = "implant case - 'Sad Trombone'"
	desc = ""
	imp_type = /obj/item/implant/sad_trombone
