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
	density = 1
	anchored = 1


/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"


/obj/structure/filingcabinet/filingcabinet	//not changing the path to avoid unecessary map issues, but please don't name stuff like this in the future -Pete
	icon_state = "tallcabinet"


/obj/structure/filingcabinet/Initialize()
	. = ..()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/paper) || istype(I, /obj/item/folder) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle))
			I.loc = src


/obj/structure/filingcabinet/attackby(obj/item/P as obj, mob/user as mob)
	if(istype(P, /obj/item/paper) || istype(P, /obj/item/folder) || istype(P, /obj/item/photo) || istype(P, /obj/item/paper_bundle))
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		if(user.transferItemToLoc(P, src))
			icon_state = "[initial(icon_state)]-open"
			sleep(5)
			icon_state = initial(icon_state)
			updateUsrDialog()
	else if(iswrench(P))
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
	else
		to_chat(user, "<span class='notice'>You can't put [P] in [src]!</span>")


/obj/structure/filingcabinet/attack_hand(mob/user as mob)
	if(contents.len <= 0)
		to_chat(user, "<span class='notice'>\The [src] is empty.</span>")
		return

	user.set_interaction(src)
	var/dat = "<center><table>"
	for(var/obj/item/P in src)
		dat += "<tr><td><a href='?src=\ref[src];retrieve=\ref[P]'>[P.name]</a></td></tr>"
	dat += "</table></center>"
	user << browse("<html><head><title>[name]</title></head><body>[dat]</body></html>", "window=filingcabinet;size=350x300")

	return

/obj/structure/filingcabinet/attack_tk(mob/user)
	if(anchored)
		attack_self_tk(user)
	else
		..()

/obj/structure/filingcabinet/attack_self_tk(mob/user)
	if(contents.len)
		if(prob(40 + contents.len * 5))
			var/obj/item/I = pick(contents)
			I.loc = loc
			if(prob(25))
				step_rand(I)
			to_chat(user, "<span class='notice'>You pull \a [I] out of [src] at random.</span>")
			return
	to_chat(user, "<span class='notice'>You find nothing in [src].</span>")

/obj/structure/filingcabinet/Topic(href, href_list)
	if(href_list["retrieve"])
		usr << browse("", "window=filingcabinet") // Close the menu

		//var/retrieveindex = text2num(href_list["retrieve"])
		var/obj/item/P = locate(href_list["retrieve"])//contents[retrieveindex]
		if(istype(P) && (P.loc == src) && src.Adjacent(usr))
			usr.put_in_hands(P)
			updateUsrDialog()
			icon_state = "[initial(icon_state)]-open"
			spawn(0)
				sleep(5)
				icon_state = initial(icon_state)


#define CABINET_DATACORE_CREW	1
#define CABINET_DATACORE_COLONY	2

#define CAT_SECURITY	(1<<0)
#define CAT_MEDICAL		(1<<1)

/obj/structure/filingcabinet/records
	desc = "A large cabinet with drawers, commonly used to store records of each crewmember."
	var/datum/datacore/core
	var/init_datacore
	var/records_flags

/obj/structure/filingcabinet/records/Initialize(mapload)
	. = ..()
	switch(init_datacore)
		if(CABINET_DATACORE_CREW)
			core = GLOB.crew_datacore
		if(CABINET_DATACORE_COLONY)
			core = GLOB.colony_datacore
	if(!core)
		if(is_ground_level(z))
			core = GLOB.colony_datacore
		else if(is_mainship_or_low_orbit_level(z))
			core = GLOB.crew_datacore
	if(core)
		GLOB.records_cabinets[core] += src
	if(!mapload)
		populate()

/obj/structure/filingcabinet/records/Destroy()
	GLOB.records_cabinets[core] -= src
	return ..()

/obj/structure/filingcabinet/records/proc/populate()
	for(var/datum/data/record/G in core.general)
		sort_record(G)
		CHECK_TICK

/obj/structure/filingcabinet/records/proc/sort_record(datum/data/record/G, datum/data/record/M, datum/data/record/S)
	if(!core || !G)
		return
	var/list/papers
	if(!M && records_flags & CAT_MEDICAL)
		M = find_record("name", G.fields["name"], core.medical)
		if(M)
			papers += M
			papers[M] = CAT_MEDICAL
	if(!S && records_flags & CAT_SECURITY)
		S = find_record("name", G.fields["name"], core.security)
		if(S)
			papers += S
			papers[S] = CAT_SECURITY
	var/obj/item/folder/F
	if(length(papers) > 1)
		F = new (src)
			F.name = "folder - '[G.fields["name"]]'"
	for(var/R in papers)
		add_record(G, R, papers[R], F)


/obj/structure/filingcabinet/records/proc/add_record(datum/data/record/G, datum/data/record/R, category, obj/item/folder/F)
	if(!G || !R || !category)
		return
	var/obj/item/paper/P = new (F ? F : src)
	switch(category)
		if(CAT_MEDICAL)
			P.name = "paper - '[G.fields["name"]] (Medical)'"
			P.info = "<CENTER><B>Medical Record</B></CENTER><BR>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"
			P.info += "<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: [R.fields["b_type"]]<BR>\nDNA: [R.fields["b_dna"]]<BR>\n<BR>\nMinor Disabilities: [R.fields["mi_dis"]]<BR>\nDetails: [R.fields["mi_dis_d"]]<BR>\n<BR>\nMajor Disabilities: [R.fields["ma_dis"]]<BR>\nDetails: [R.fields["ma_dis_d"]]<BR>\n<BR>\nAllergies: [R.fields["alg"]]<BR>\nDetails: [R.fields["alg_d"]]<BR>\n<BR>\nCurrent Diseases: [R.fields["cdi"]] (per disease info placed in log/comment section)<BR>\nDetails: [R.fields["cdi_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[R.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
		if(CAT_SECURITY)
			P.name = "paper - '[G.fields["name"]] (Security)'"
			P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"
			P.info += "<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: [R.fields["criminal"]]<BR>\n<BR>\nMinor Crimes: [R.fields["mi_crim"]]<BR>\nDetails: [R.fields["mi_crim_d"]]<BR>\n<BR>\nMajor Crimes: [R.fields["ma_crim"]]<BR>\nDetails: [R.fields["ma_crim_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[R.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
	comment_field(R, P)

/obj/structure/filingcabinet/records/proc/comment_field(datum/data/record/R, obj/item/paper/P)
	var/counter = 1
	while(R.fields["com_[counter]"])
		P.info += "[R.fields["com_[counter]"]]<BR>"
		counter++
	P.info += "</TT>"

/obj/structure/filingcabinet/records/security
	records_flags = CAT_SECURITY

/obj/structure/filingcabinet/records/security/crew
	init_datacore = CABINET_DATACORE_CREW

/obj/structure/filingcabinet/records/security/colony
	init_datacore = CABINET_DATACORE_COLONY

/obj/structure/filingcabinet/records/medical
	records_flags = CAT_MEDICAL

/obj/structure/filingcabinet/records/medical/crew
	init_datacore = CABINET_DATACORE_CREW

/obj/structure/filingcabinet/records/medical/colony
	init_datacore = CABINET_DATACORE_COLONY

#undef CABINET_DATACORE_COLONY
#undef CABINET_DATACORE_CREW

#undef CAT_SECURITY
#undef CAT_MEDICAL
