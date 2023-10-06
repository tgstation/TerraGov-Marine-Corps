/* Filing cabinets!
* Contains:
*		Filing Cabinets
*		Security Record Cabinets
*		Medical Record Cabinets
*/


/*
* Filing Cabinets
*/
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/structures/misc.dmi'
	icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 100
	soft_armor = list(MELEE = 0, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)


/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"


/obj/structure/filingcabinet/filingcabinet	//not changing the path to avoid unecessary map issues, but please don't name stuff like this in the future -Pete
	icon_state = "tallcabinet"


/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/paper) || istype(I, /obj/item/folder) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle))
			I.loc = src


/obj/structure/filingcabinet/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/paper) || istype(I, /obj/item/folder) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle))
		if(!user.transferItemToLoc(I, src))
			return

		to_chat(user, span_notice("You put [I] in [src]."))
		icon_state = "[initial(icon_state)]-open"
		sleep(0.5 SECONDS)
		icon_state = initial(icon_state)
		updateUsrDialog()

	else if(iswrench(I))
		anchored = !anchored
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		to_chat(user, span_notice("You [anchored ? "wrench" : "unwrench"] \the [src]."))

	else
		to_chat(user, span_notice("You can't put [I] in [src]!"))


/obj/structure/filingcabinet/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(length(contents) <= 0)
		to_chat(user, span_notice("\The [src] is empty."))
		return

	user.set_interaction(src)
	var/dat = "<center><table>"
	for(var/obj/item/P in src)
		dat += "<tr><td><a href='?src=[text_ref(src)];retrieve=[text_ref(P)]'>[P.name]</a></td></tr>"
	dat += "</table></center>"
	user << browse("<html><head><title>[name]</title></head><body>[dat]</body></html>", "window=filingcabinet;size=350x300")


/obj/structure/filingcabinet/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["retrieve"])
		usr << browse("", "window=filingcabinet") // Close the menu

		//var/retrieveindex = text2num(href_list["retrieve"])
		var/obj/item/P = locate(href_list["retrieve"])//contents[retrieveindex]
		if(istype(P) && (P.loc == src) && src.Adjacent(usr))
			usr.put_in_hands(P)
			updateUsrDialog()
			icon_state = "[initial(icon_state)]-open"
			addtimer(VARSET_CALLBACK(src, icon_state, initial(icon_state)), 5)


/*
* Security Record Cabinets
*/
/obj/structure/filingcabinet/security
	var/virgin = 1


/obj/structure/filingcabinet/security/proc/populate()
	if(virgin)
		for(var/datum/data/record/G in GLOB.datacore.general)
			var/datum/data/record/S
			for(var/datum/data/record/R in GLOB.datacore.security)
				if((R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"]))
					S = R
					break
			if(S)
				var/obj/item/paper/P = new /obj/item/paper(src)
				P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
				P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"
				P.info += "<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: [S.fields["criminal"]]<BR>\n<BR>\nMinor Crimes: [S.fields["mi_crim"]]<BR>\nDetails: [S.fields["mi_crim_d"]]<BR>\n<BR>\nMajor Crimes: [S.fields["ma_crim"]]<BR>\nDetails: [S.fields["ma_crim_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[S.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
				var/counter = 1
				while(S.fields["com_[counter]"])
					P.info += "[S.fields["com_[counter]"]]<BR>"
					counter++
				P.info += "</TT>"
				P.name = "Security Record ([G.fields["name"]])"
			virgin = 0	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/security/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	populate()

/*
* Medical Record Cabinets
*/
/obj/structure/filingcabinet/medical
	var/virgin = 1

/obj/structure/filingcabinet/medical/proc/populate()
	if(virgin)
		for(var/datum/data/record/G in GLOB.datacore.general)
			var/datum/data/record/M
			for(var/datum/data/record/R in GLOB.datacore.medical)
				if((R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"]))
					M = R
					break
			if(M)
				var/obj/item/paper/P = new /obj/item/paper(src)
				P.info = "<CENTER><B>Medical Record</B></CENTER><BR>"
				P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"

				P.info += "<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: [M.fields["b_type"]]<BR>\nDNA: [M.fields["b_dna"]]<BR>\n<BR>\nMinor Disabilities: [M.fields["mi_dis"]]<BR>\nDetails: [M.fields["mi_dis_d"]]<BR>\n<BR>\nMajor Disabilities: [M.fields["ma_dis"]]<BR>\nDetails: [M.fields["ma_dis_d"]]<BR>\n<BR>\nAllergies: [M.fields["alg"]]<BR>\nDetails: [M.fields["alg_d"]]<BR>\n<BR>\nCurrent Diseases: [M.fields["cdi"]] (per disease info placed in log/comment section)<BR>\nDetails: [M.fields["cdi_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[M.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
				var/counter = 1
				while(M.fields["com_[counter]"])
					P.info += "[M.fields["com_[counter]"]]<BR>"
					counter++
				P.info += "</TT>"
				P.name = "Medical Record ([G.fields["name"]])"
			virgin = 0	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/medical/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	populate()
