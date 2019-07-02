// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/xeno_action/activable/spray_acid/line
	name = "Spray Acid"
	action_icon_state = "spray_acid"
	mechanics_text = "Spray a line of dangerous acid at your target."
	ability_name = "spray acid"
	plasma_cost = 250
	cooldown_timer = 30 SECONDS

/datum/action/xeno_action/activable/spray_acid/line/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/turf/target = get_turf(A)

	if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	if(X.action_busy || !do_after(X, 5, TRUE, target, BUSY_ICON_DANGER))
		return

	if(!can_use_ability(A, TRUE))
		return fail_activate()

	succeed_activate()

	playsound(X.loc, 'sound/effects/refill.ogg', 50, 1)
	X.visible_message("<span class='xenowarning'>\The [X] spews forth a virulent spray of acid!</span>", \
	"<span class='xenowarning'>We spew forth a spray of acid!</span>", null, 5)
	var/turflist = getline(X, target)
	spray_turfs(turflist)
	add_cooldown()


/datum/action/xeno_action/activable/spray_acid/line/proc/spray_turfs(list/turflist)
	set waitfor = FALSE

	if(isnull(turflist))
		return

	var/turf/prev_turf
	var/distance = 0

	for(var/X in turflist)
		var/turf/T = X

		if(!prev_turf && turflist.len > 1)
			prev_turf = get_turf(owner)
			continue //So we don't burn the tile we be standin on

		for(var/obj/structure/barricade/B in prev_turf)
			if(get_dir(prev_turf, T) & B.dir)
				B.acid_spray_act(owner)

		if(T.density || isspaceturf(T))
			break

		var/blocked = FALSE
		for(var/obj/O in T)
			if(O.density && !O.throwpass && !(O.flags_atom & ON_BORDER))
				blocked = TRUE
				break

		var/turf/TF
		if(!prev_turf.Adjacent(T) && (T.x != prev_turf.x || T.y != prev_turf.y)) //diagonally blocked, it will seek for a cardinal turf by the former target.
			blocked = TRUE
			var/turf/Ty = locate(prev_turf.x, T.y, prev_turf.z)
			var/turf/Tx = locate(T.x, prev_turf.y, prev_turf.z)
			for(var/turf/TB in shuffle(list(Ty, Tx)))
				if(prev_turf.Adjacent(TB) && !TB.density && !isspaceturf(TB))
					TF = TB
					break
			if(!TF)
				break
		else
			TF = T

		for(var/obj/structure/barricade/B in TF)
			if(get_dir(TF, prev_turf) & B.dir)
				B.acid_spray_act(owner)

		acid_splat_turf(TF)

		distance++
		if(distance > 7 || blocked)
			break

		prev_turf = T
		sleep(2)
