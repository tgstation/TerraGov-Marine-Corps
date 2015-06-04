/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		switch(alert("Travel back to ss13?",,"Yes","No"))
			if("Yes")
				if(user.z != src.z)	return
				user.loc.loc.Exited(user)
				user.loc = pick(latejoin)
			if("No")
				return

/obj/effect/mark
		var/mark = ""
		icon = 'icons/misc/mark.dmi'
		icon_state = "blank"
		anchored = 1
		layer = 99
		mouse_opacity = 0
		unacidable = 1//Just to be sure.

/obj/effect/beam
	name = "beam"
	unacidable = 1//Just to be sure.
	var/def_zone
	pass_flags = PASSTABLE


/obj/effect/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = 1.0
	unacidable = 1

/*
 * This item is completely unused, but removing it will break something in R&D and Radio code causing PDA and Ninja code to fail on compile
 */

/obj/effect/datacore
	name = "datacore"
	var/medical[] = list()
	var/general[] = list()
	var/security[] = list()
	//This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/locked[] = list()



/obj/effect/datacore/proc/get_manifest(monochrome, OOC)
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th><th>Activity</th></tr>
	"}
	return dat

	//Fuck this for now

/*
	var/list/command = new()
	var/list/eng = new()
	var/list/med = new()
	var/list/mar = new()
	var/list/isactive = new()

	var/even = 0
	// sort mobs

	for(var/datum/data/record/t in data_core.general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/real_rank = t.fields["real_rank"]
		if(OOC)
			var/active = 0
			for(var/mob/M in player_list)
				if(M.real_name == name && M.client && M.client.inactivity <= 10 * 60 * 10)
					active = 1
					break
			isactive[name] = active ? "Active" : "Inactive"
		else
			isactive[name] = t.fields["p_stat"]
			//world << "[name]: [rank]"
			//cael - to prevent multiple appearances of a player/job combination, add a continue after each line
		var/department = 0
		if(real_rank in command_positions)
			heads[name] = rank
			department = 1
		if(real_rank in security_positions)
			sec[name] = rank
			department = 1
		if(real_rank in marine_unassigned_positions)
			marine_unassigned_positions[name] = rank
			department = 1
/*		if(real_rank in marine_alpha_positions)
			mar_alpha[name] = rank
			department = 1
		if(real_rank in marine_bravo_positions)
			mar_bravo[name] = rank
			department = 1
		if(real_rank in marine_charlie_positions)
			mar_charlie[name] = rank
			department = 1
		if(real_rank in marine_delta_positions)
			mar_delta[name] = rank
			department = 1
	*/
		if(real_rank in engineering_positions)
			eng[name] = rank
			department = 1
		if(real_rank in medical_positions)
			med[name] = rank
			department = 1
		if(real_rank in science_positions)
			sci[name] = rank
			department = 1
		if(real_rank in civilian_positions)
			civ[name] = rank
			department = 1
		if(real_rank in nonhuman_positions)
			bot[name] = rank
			department = 1
		if(!department && !(name in heads))
			misc[name] = rank
	if(heads.len > 0)
		dat += "<tr><th colspan=3>Command Staff</th></tr>"
		for(name in heads)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[heads[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(sec.len > 0)
		dat += "<tr><th colspan=3>Security</th></tr>"
		for(name in sec)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sec[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(marine_unassigned_positions.len > 0)
		dat += "<tr><th colspan=3>Unassigned</th></tr>"
		for(name in marine_unassigned_positions)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[marine_unassigned_positions[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(mar_alpha.len > 0)
		dat += "<tr><th colspan=3>Alpha</th></tr>"
		for(name in mar_alpha)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[mar_alpha[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(mar_bravo.len > 0)
		dat += "<tr><th colspan=3>Bravo</th></tr>"
		for(name in mar_bravo)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[mar_bravo[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(mar_charlie.len > 0)
		dat += "<tr><th colspan=3>Charlie</th></tr>"
		for(name in mar_charlie)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[mar_charlie[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(mar_delta.len > 0)
		dat += "<tr><th colspan=3>Delta</th></tr>"
		for(name in mar_delta)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[mar_delta[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(eng.len > 0)
		dat += "<tr><th colspan=3>Engineering</th></tr>"
		for(name in eng)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[eng[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(med.len > 0)
		dat += "<tr><th colspan=3>Medical</th></tr>"
		for(name in med)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[med[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(sci.len > 0)
		dat += "<tr><th colspan=3>Science</th></tr>"
		for(name in sci)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sci[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(civ.len > 0)
		dat += "<tr><th colspan=3>Civilian</th></tr>"
		for(name in civ)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[civ[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	// in case somebody is insane and added them to the manifest, why not
	if(bot.len > 0)
		dat += "<tr><th colspan=3>Silicon</th></tr>"
		for(name in bot)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[bot[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	// misc guys
	if(misc.len > 0)
		dat += "<tr><th colspan=3>Miscellaneous</th></tr>"
		for(name in misc)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[misc[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")

*/


/*
We can't just insert in HTML into the nanoUI so we need the raw data to play with.
Instead of creating this list over and over when someone leaves their PDA open to the page
we'll only update it when it changes.  The PDA_Manifest global list is zeroed out upon any change
using /obj/effect/datacore/proc/manifest_inject( ), or manifest_insert( )
*/

var/global/list/PDA_Manifest = list()

/obj/effect/datacore/proc/get_manifest_json()
	if(PDA_Manifest.len)
		return PDA_Manifest

//God, fuck this shit for now
	PDA_Manifest = list("marines")
	return PDA_Manifest
/*
	var/heads[0]
	var/sec[0]
	var/eng[0]
	var/med[0]
	var/sci[0]
	var/civ[0]
	var/bot[0]
	var/misc[0]
	var/marine_unassigned_positions[0]
	var/mar_alpha[0]
	var/mar_bravo[0]
	var/mar_charlie[0]
	var/mar_delta[0]

	for(var/datum/data/record/t in data_core.general)
		var/name = sanitize(t.fields["name"])
		var/rank = sanitize(t.fields["rank"])
		var/real_rank = t.fields["real_rank"]
		var/isactive = t.fields["p_stat"]
		var/department = 0
		var/depthead = 0 			// Department Heads will be placed at the top of their lists.
		if(real_rank in command_positions)
			heads[++heads.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			depthead = 1
			if(rank=="Commander" && heads.len != 1)
				heads.Swap(1,heads.len)

		if(real_rank in security_positions)
			sec[++sec.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && sec.len != 1)
				sec.Swap(1,sec.len)

		if(real_rank in engineering_positions)
			eng[++eng.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && eng.len != 1)
				eng.Swap(1,eng.len)

		if(real_rank in medical_positions)
			med[++med.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && med.len != 1)
				med.Swap(1,med.len)

		if(real_rank in science_positions)
			sci[++sci.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && sci.len != 1)
				sci.Swap(1,sci.len)

		if(real_rank in civilian_positions)
			civ[++civ.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && civ.len != 1)
				civ.Swap(1,civ.len)

		if(real_rank in marine_unassigned_positions)
			marine_unassigned_positions[++marine_unassigned_positions.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && marine_unassigned_positions.len != 1)
				marine_unassigned_positions.Swap(1,marine_unassigned_positions.len)
/*
		if(real_rank in marine_alpha_positions)
			mar_alpha[++mar_alpha.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && mar_alpha.len != 1)
				mar_alpha.Swap(1,mar_alpha.len)

		if(real_rank in marine_bravo_positions)
			mar_bravo[++mar_bravo.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && mar_bravo.len != 1)
				mar_bravo.Swap(1,mar_bravo.len)

		if(real_rank in marine_charlie_positions)
			mar_charlie[++mar_charlie.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && mar_charlie.len != 1)
				mar_charlie.Swap(1,mar_charlie.len)

		if(real_rank in marine_delta_positions)
			mar_delta[++mar_delta.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && mar_delta.len != 1)
				mar_delta.Swap(1,mar_delta.len)
*/
		if(real_rank in nonhuman_positions)
			bot[++bot.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1

		if(!department && !(name in heads))
			misc[++misc.len] = list("name" = name, "rank" = rank, "active" = isactive)


	PDA_Manifest = list(\
		"heads" = heads,\
		"sec" = sec,\
		"eng" = eng,\
		"med" = med,\
		"sci" = sci,\
		"civ" = civ,\
		"marine_unassigned_positions" = marine_unassigned_positions,\
		"mar_alpha" = mar_alpha,\
		"mar_bravo" = mar_bravo,\
		"mar_charlie" = mar_charlie,\
		"mar_delta" = mar_delta,\
		"bot" = bot,\
		"misc" = misc\
		)
	return PDA_Manifest

*/

/obj/effect/laser
	name = "laser"
	desc = "IT BURNS!!!"
	icon = 'icons/obj/projectiles.dmi'
	var/damage = 0.0
	var/range = 10.0


/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = 1.0


/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )

/obj/structure/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1
	unacidable = 1//temporary until I decide whether the borg can be removed. -veyveyr

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/item/weapon/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = 0
	anchored = 0
	w_class = 2.0
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		user.drop_item()
		src.throw_at(target, throw_range, throw_speed, user)

/obj/effect/stop
	var/victim = null
	icon_state = "empty"
	name = "Geas"
	desc = "You can't resist."
	// name = ""

/obj/effect/spawner
	name = "object spawner"
