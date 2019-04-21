//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
 * A large number of misc global procs.
 */

//Inverts the colour of an HTML string
/proc/invertHTML(HTMLstring)

	if (!( istext(HTMLstring) ))
		CRASH("Given non-text argument!")
		return
	else
		if (length(HTMLstring) != 7)
			CRASH("Given non-HTML argument!")
			return
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	var/r = hex2num(textr)
	var/g = hex2num(textg)
	var/b = hex2num(textb)
	textr = num2hex(255 - r)
	textg = num2hex(255 - g)
	textb = num2hex(255 - b)
	if (length(textr) < 2)
		textr = text("0[]", textr)
	if (length(textg) < 2)
		textr = text("0[]", textg)
	if (length(textb) < 2)
		textr = text("0[]", textb)
	return text("#[][][]", textr, textg, textb)
	return

//Returns the middle-most value
/proc/dd_range(var/low, var/high, var/num)
	return max(low,min(high,num))

//Returns whether or not A is the middle most value
/proc/InRange(var/A, var/lower, var/upper)
	if(A < lower) return 0
	if(A > upper) return 0
	return 1


/proc/Get_Angle(atom/start,atom/end)//For beams.
	if(!start || !end) return 0
	if(!start.z || !end.z) return 0 //Atoms are not on turfs.
	var/dy
	var/dx
	dy=(32*end.y+end.pixel_y)-(32*start.y+start.pixel_y)
	dx=(32*end.x+end.pixel_x)-(32*start.x+start.pixel_x)
	if(!dy)
		return (dx>=0)?90:270
	.=arctan(dx/dy)
	if(dy<0)
		.+=180
	else if(dx<0)
		.+=360

/proc/Get_Compass_Dir(atom/start,atom/end)//get_dir() only considers an object to be north/south/east/west if there is zero deviation. This uses rounding instead.
	if(!start || !end) return 0
	if(!start.z || !end.z) return 0 //Atoms are not on turfs.
	var/dy=end.y-start.y
	var/dx=end.x-start.x
	if(!dy)
		return (dx>=0)?4:8
	var/angle=arctan(dx/dy)
	if(dy<0)
		angle+=180
	else if(dx<0)
		angle+=360

	switch(angle) //diagonal directions get priority over straight directions in edge cases
		if (22.5 to 67.5)
			return NORTHEAST
		if (112.5 to 157.5)
			return SOUTHEAST
		if (202.5 to 247.5)
			return SOUTHWEST
		if (292.5 to 337.5)
			return NORTHWEST
		if (0 to 22.5)
			return NORTH
		if (67.5 to 112.5)
			return EAST
		if (157.5 to 202.5)
			return SOUTH
		if (247.5 to 292.5)
			return WEST
		else
			return NORTH

//Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location,mob/target,distance = 1, density = 0, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
/*
Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
Random error in tile placement x, error in tile placement y, and block offset.
Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
Turf and target are seperate in case you want to teleport some distance from a turf the target is not standing on or something.
*/

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)
	//var/errorxy = round((errorx+errory)/2)//Used for diagonal boxes.

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry+=distance
			yoffset+=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(2)//South
			diry-=distance
			yoffset-=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(4)//East
			dirx+=distance
			yoffset+=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx
		if(8)//West
			dirx-=distance
			yoffset-=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx

	var/turf/destination=locate(location.x+dirx,location.y+diry,location.z)

	if(destination)//If there is a destination.
		if(errorx||errory)//If errorx or y were specified.
			var/destination_list[] = list()//To add turfs to list.
			//destination_list = new()
			/*This will draw a block around the target turf, given what the error is.
			Specifying the values above will basically draw a different sort of block.
			If the values are the same, it will be a square. If they are different, it will be a rectengle.
			In either case, it will center based on offset. Offset is position from center.
			Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
			the offset should remain positioned in relation to destination.*/

			var/turf/center = locate((destination.x+xoffset),(destination.y+yoffset),location.z)//So now, find the new center.

			//Now to find a box from center location and make that our destination.
			for(var/turf/T in block(locate(center.x+b1xerror,center.y+b1yerror,location.z), locate(center.x+b2xerror,center.y+b2yerror,location.z) ))
				if(density&&T.density)	continue//If density was specified.
				if(T.x>world.maxx || T.x<1)	continue//Don't want them to teleport off the map.
				if(T.y>world.maxy || T.y<1)	continue
				destination_list += T
			if(destination_list.len)
				destination = pick(destination_list)
			else	return

		else//Same deal here.
			if(density&&destination.density)	return
			if(destination.x>world.maxx || destination.x<1)	return
			if(destination.y>world.maxy || destination.y<1)	return
	else	return

	return destination

/proc/LinkBlocked(turf/A, turf/B)
	if(A == null || B == null)
		return TRUE
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if(adir & (adir-1))//is diagonal direction
		var/turf/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!iStep.density && !LinkBlocked(A,iStep) && !LinkBlocked(iStep,B))
			return FALSE

		var/turf/pStep = get_step(A,adir&(EAST|WEST))
		if(!pStep.density && !LinkBlocked(A,pStep) && !LinkBlocked(pStep,B))
			return FALSE
		return TRUE

	if(DirBlocked(A,adir))
		return TRUE
	if(DirBlocked(B,rdir))
		return TRUE
	return FALSE

/proc/DirBlocked(turf/loc,var/direction)
	for(var/obj/structure/window/D in loc)
		if(!D.density)
			continue
		if(D.is_full_window())
			return TRUE
		if(D.dir == direction)
			return TRUE

	for(var/obj/machinery/door/D in loc)
		if(!D.density)
			continue
		if(istype(D, /obj/machinery/door/window))
			if(D.dir == direction)
				return TRUE
		else
			return TRUE	// it's a real, air blocking door
	for(var/obj/structure/mineral_door/D in loc)
		if(D.density)
			return TRUE
	return FALSE

/proc/TurfBlockedNonWindow(turf/loc)
	for(var/obj/O in loc)
		if(O.density && !istype(O, /obj/structure/window))
			return TRUE
	return FALSE

/proc/sign(x)
	return x!=0?x/abs(x):0

//Returns whether or not a player is a guest using their ckey as an input
/proc/IsGuestKey(key)
	if (findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return 0

	var/i = 7, ch, len = length(key)

	if(copytext(key, 7, 8) == "W") //webclient
		i++

	for (, i <= len, ++i)
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57)
			return 0
	return 1

//Ensure the frequency is within bounds of what it should be sending/recieving at
/proc/sanitize_frequency(var/f)
	f = round(f)
	f = max(1441, f) // 144.1
	f = min(1489, f) // 148.9
	if ((f % 2) == 0) //Ensure the last digit is an odd number
		f += 1
	return f

//Turns 1479 into 147.9
/proc/format_frequency(var/f)
	return "[round(f / 10)].[f % 10]"



//This will update a mob's name, real_name, mind.name, GLOB.datacore records and id
/mob/proc/fully_replace_character_name(oldname, newname)
	if(!newname)	
		return FALSE

	log_played_names(ckey, newname)

	real_name = newname
	voice_name = newname
	name = newname
	if(mind)
		mind.name = newname
		if(mind.key)
			log_played_names(mind.key, newname) //Just in case the mind is unsynced at the moment.
	if(dna)
		dna.real_name = real_name

	return TRUE


/mob/living/carbon/human/fully_replace_character_name(oldname, newname)
	. = ..()
	if(!.)
		return FALSE

	if(istype(wear_id))
		var/obj/item/card/id/C = wear_id
		C.update_label()

	if(!GLOB.datacore.manifest_update(oldname, newname, job))
		GLOB.datacore.manifest_inject(src)

	return TRUE


//Generalised helper proc for letting mobs rename themselves. Used to be clname() and ainame()
//Last modified by Carn
/mob/proc/rename_self(var/role, var/allow_numbers=0)
	spawn(0)
		var/oldname = real_name

		var/time_passed = world.time
		var/newname

		for(var/i=1,i<=3,i++)	//we get 3 attempts to pick a suitable name.
			newname = input(src,"You are a [role]. Would you like to change your name to something else?", "Name change",oldname) as text
			if((world.time-time_passed)>300)
				return	//took too long
			newname = reject_bad_name(newname,allow_numbers)	//returns null if the name doesn't meet some basic requirements. Tidies up a few other things like bad-characters.

			for(var/mob/living/M in GLOB.player_list)
				if(M == src)
					continue
				if(!newname || M.real_name == newname)
					newname = null
					break
			if(newname)
				break	//That's a suitable name!
			to_chat(src, "Sorry, that [role]-name wasn't appropriate, please try another. It's possibly too long/short, has bad characters or is already taken.")

		if(!newname)	//we'll stick with the oldname then
			return

		if(cmptext("ai",role))
			if(isAI(src))
				var/mob/living/silicon/ai/A = src
				oldname = null//don't bother with the records update crap
				//to_chat(world, "<b>[newname] is the AI!</b>")
				//world << sound('sound/AI/newAI.ogg')
				// Set eyeobj name
				A.SetName(newname)


		fully_replace_character_name(oldname,newname)



//Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

//When an AI is activated, it can choose from a list of non-slaved borgs to have as a slave.
/proc/freeborg()
	var/select = null
	var/list/borgs = list()
	for (var/mob/living/silicon/robot/A in GLOB.player_list)
		if (A.stat == 2 || A.connected_ai || A.scrambledcodes)
			continue
		var/name = "[A.real_name] ([A.modtype] [A.braintype])"
		borgs[name] = A

	if (borgs.len)
		select = input("Unshackled borg signals detected:", "Borg selection", null, null) as null|anything in borgs
		return borgs[select]

//When a borg is activated, it can choose which AI it wants to be slaved to
/proc/active_ais()
	. = list()
	for(var/mob/living/silicon/ai/A in GLOB.alive_mob_list)
		if(A.stat == DEAD)
			continue
		if(A.control_disabled == 1)
			continue
		. += A
	return .

//Find an active ai with the least borgs. VERBOSE PROCNAME HUH!
/proc/select_active_ai_with_fewest_borgs()
	var/mob/living/silicon/ai/selected
	var/list/active = active_ais()
	for(var/mob/living/silicon/ai/A in active)
		if(!selected || (selected.connected_robots > A.connected_robots))
			selected = A

	return selected

/proc/select_active_ai(var/mob/user)
	var/list/ais = active_ais()
	if(ais.len)
		if(user)	. = input(usr,"AI signals detected:", "AI selection") in ais
		else		. = pick(ais)
	return .

//Orders mobs by type then by name
/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sortNames(GLOB.mob_list)
	for(var/mob/living/silicon/ai/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/robot/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/human/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/brain/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/Xenomorph/M in sortmob)
		moblist.Add(M)
	for(var/mob/dead/observer/M in sortmob)
		moblist.Add(M)
	for(var/mob/new_player/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/monkey/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/M in sortmob)
		moblist.Add(M)
	return moblist

/proc/sortxenos()
	var/list/xenolist = list()
	var/list/sortmob = sortNames(GLOB.mob_list)
	for(var/mob/living/carbon/Xenomorph/M in sortmob)
		if(!M.client)
			continue
		xenolist.Add(M)
	return xenolist

/proc/sorthumans()
	var/list/humanlist = list()
	var/list/sortmob = sortNames(GLOB.mob_list)
	for(var/mob/living/carbon/human/M in sortmob)
		if(!M.client)
			continue
		humanlist.Add(M)
	return humanlist

//E = MC^2
/proc/convert2energy(var/M)
	var/E = M*(SPEED_OF_LIGHT_SQ)
	return E

//M = E/C^2
/proc/convert2mass(var/E)
	var/M = E/(SPEED_OF_LIGHT_SQ)
	return M

//Forces a variable to be posative
/proc/modulus(var/M)
	if(M >= 0)
		return M
	if(M < 0)
		return -M

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(var/atom/A, var/direction)

	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return 0
		//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

		// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)

	return target

// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(var/atom/A, var/direction, var/range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	if(direction & WEST)
		x = max(1, x - range)

	return locate(x,y,A.z)


// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/get_offset_target_turf(var/atom/A, var/dx, var/dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x,y,A.z)

//Makes sure MIDDLE is between LOW and HIGH. If not, it adjusts it. Returns the adjusted value.
/proc/between(var/low, var/middle, var/high)
	return max(min(middle, high), low)

proc/arctan(x)
	var/y=arcsin(x/sqrt(1+x*x))
	return y

//returns random gauss number
proc/GaussRand(var/sigma)
  var/x,y,rsq
  do
    x=2*rand()-1
    y=2*rand()-1
    rsq=x*x+y*y
  while(rsq>1 || !rsq)
  return sigma*y*sqrt(-2*log(rsq)/rsq)

//returns random gauss number, rounded to 'roundto'
proc/GaussRandRound(var/sigma,var/roundto)
	return round(GaussRand(sigma),roundto)

proc/anim(turf/location,atom/target,a_icon,a_icon_state as text,flick_anim as text,sleeptime = 0,direction as num)
//This proc throws up either an icon or an animation for a specified amount of time.
//The variables should be apparent enough.
	var/atom/movable/overlay/animation = new(location)
	if(direction)
		animation.setDir(direction)
	animation.icon = a_icon
	animation.layer = target.layer+0.1
	if(a_icon_state)
		animation.icon_state = a_icon_state
	else
		animation.icon_state = "blank"
		animation.master = target
		flick(flick_anim, animation)
	sleep(max(sleeptime, 15))
	qdel(animation)

//Will return the contents of an atom recursivly to a depth of 'searchDepth'
/atom/proc/GetAllContents(searchDepth = 5)
	var/list/toReturn = list()

	for(var/atom/part in contents)
		toReturn += part
		if(part.contents.len && searchDepth)
			toReturn += part.GetAllContents(searchDepth - 1)

	return toReturn

//Step-towards method of determining whether one atom can see another. Similar to viewers()
/proc/can_see(atom/source, atom/target, length=5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	if(current == target_turf)
		return TRUE
	if(get_dist(current, target_turf) > length)
		return FALSE
	current = get_step_towards(source, target_turf)
	while((current != target_turf))
		if(current.opacity)
			return FALSE
		for(var/thing in current)
			var/atom/A = thing
			if(A.opacity)
				return FALSE
		current = get_step_towards(current, target_turf)
	return TRUE
/proc/is_blocked_turf(var/turf/T)
	var/cant_pass = 0
	if(T.density) cant_pass = 1
	for(var/atom/A in T)
		if(A.density)//&&A.anchored
			cant_pass = 1
	return cant_pass

/proc/get_step_towards2(var/atom/ref , var/atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref,trg))
	var/turf/temp = get_step_towards(ref,trg)

	if(is_blocked_turf(temp))
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile = null
		var/breakpoint = 0

		while(!free_tile && breakpoint < 10)
			if(!is_blocked_turf(turf_last1))
				free_tile = turf_last1
				break
			if(!is_blocked_turf(turf_last2))
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1,dir_alt1)
			turf_last2 = get_step(turf_last2,dir_alt2)
			breakpoint++

		if(!free_tile) return get_step(ref, base_dir)
		else return get_step_towards(ref,free_tile)

	else return get_step(ref, base_dir)


var/global/image/busy_indicator_clock
var/global/image/busy_indicator_medical
var/global/image/busy_indicator_build
var/global/image/busy_indicator_friendly
var/global/image/busy_indicator_hostile

/proc/get_busy_icon(busy_type)
	if(busy_type == BUSY_ICON_GENERIC)
		if(!busy_indicator_clock)
			busy_indicator_clock = image('icons/mob/mob.dmi', null, "busy_generic", "pixel_y" = 22)
			busy_indicator_clock.layer = FLY_LAYER
		return busy_indicator_clock
	else if(busy_type == BUSY_ICON_MEDICAL)
		if(!busy_indicator_medical)
			busy_indicator_medical = image('icons/mob/mob.dmi', null, "busy_medical", "pixel_y" = 0) //This shows directly on top of the mob, no offset!
			busy_indicator_medical.layer = FLY_LAYER
		return busy_indicator_medical
	else if(busy_type == BUSY_ICON_BUILD)
		if(!busy_indicator_build)
			busy_indicator_build = image('icons/mob/mob.dmi', null, "busy_build", "pixel_y" = 22)
			busy_indicator_build.layer = FLY_LAYER
		return busy_indicator_build
	else if(busy_type == BUSY_ICON_FRIENDLY)
		if(!busy_indicator_friendly)
			busy_indicator_friendly = image('icons/mob/mob.dmi', null, "busy_friendly", "pixel_y" = 22)
			busy_indicator_friendly.layer = FLY_LAYER
		return busy_indicator_friendly
	else if(busy_type == BUSY_ICON_HOSTILE)
		if(!busy_indicator_hostile)
			busy_indicator_hostile = image('icons/mob/mob.dmi', null, "busy_hostile", "pixel_y" = 22)
			busy_indicator_hostile.layer = FLY_LAYER
		return busy_indicator_hostile



/proc/do_mob(mob/user , mob/target, time = 30, show_busy_icon, show_target_icon, selected_zone_check)
	if(!user || !target) return 0

	var/image/busy_icon
	if(show_busy_icon)
		busy_icon = get_busy_icon(show_busy_icon)
		if(busy_icon)
			user.overlays += busy_icon

	var/image/target_icon
	if(show_target_icon) //putting a busy overlay on top of the target
		target_icon = get_busy_icon(show_target_icon)
		if(target_icon)
			target.overlays += target_icon

	user.action_busy = TRUE

	var/cur_zone_sel
	if(selected_zone_check)
		cur_zone_sel = user.zone_selected

	var/user_loc = user.loc
	var/target_loc = target.loc
	var/delayfraction = round(time/5)
	var/holding = user.get_active_held_item()

	. = TRUE
	for(var/i = 0 to 5)
		sleep(delayfraction)
		if(!user || !target)
			. = FALSE
			break
		if(user.loc != user_loc || target.loc != target_loc)
			. = FALSE
			break
		if(user.get_active_held_item() != holding)
			. = FALSE
			break
		if(user.incapacitated(TRUE) || user.lying)
			. = FALSE
			break
		if(selected_zone_check && cur_zone_sel != user.zone_selected)
			. = FALSE
			break

	if(user && busy_icon)
		user.overlays -= busy_icon
	if(target && target_icon)
		target.overlays -= target_icon

	user.action_busy = FALSE


/proc/do_after(mob/user, delay, needhand = TRUE, numticks = 5, show_busy_icon, selected_zone_check, busy_check = FALSE) //hacky, will suffice for now.
	if(!istype(user) || delay <= 0)
		return FALSE

	if(busy_check && user.action_busy)
		to_chat(user, "<span class='warning'>You're already busy doing something!</span>")
		return FALSE

	var/mob/living/L
	if(isliving(user))
		L = user //No more doing things while you're in crit

	var/image/busy_icon
	if(show_busy_icon)
		busy_icon = get_busy_icon(show_busy_icon)
		if(busy_icon)
			user.overlays += busy_icon

	user.action_busy = TRUE

	var/cur_zone_sel
	if(selected_zone_check)
		cur_zone_sel = user.zone_selected

	var/original_loc = user.loc
	var/original_turf = get_turf(user)
	var/obj/holding = user.get_active_held_item()

	. = TRUE
	var/endtime = world.time + delay
	while(world.time < endtime)
		stoplag(1)
		if(!user || user.loc != original_loc || get_turf(user) != original_turf || user.stat || user.knocked_down || user.stunned)
			. = FALSE
			break
		if(L?.health && L.health < L.get_crit_threshold())
			. = FALSE //catching mobs below crit level but haven't had their stat var updated
			break
		if(needhand)
			if(holding)
				if(!holding.loc || user.get_active_held_item() != holding) //no longer holding the required item
					. = FALSE
					break
			else if(user.get_active_held_item()) //something in active hand when we need it to stay empty
				. = FALSE
				break

		if(selected_zone_check && cur_zone_sel != user.zone_selected) //changed the selected zone
			. = FALSE
			break

	if(user && busy_icon)
		user.overlays -= busy_icon

	user.action_busy = FALSE


//Takes: Anything that could possibly have variables and a varname to check.
//Returns: 1 if found, 0 if not.
/proc/hasvar(var/datum/A, var/varname)
	if(A.vars.Find(lowertext(varname))) return 1
	else return 0

//Returns: all the areas in the world
/proc/return_areas()
	var/list/area/areas = list()
	for(var/area/A in all_areas)
		areas += A
	return areas

//Returns: all the areas in the world, sorted.
/proc/return_sorted_areas()
	return sortNames(return_areas())

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(var/areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/areas = new/list()
	for(var/area/N in all_areas)
		if(istype(N, areatype)) areas += N
	return areas

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(var/areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/turfs = new/list()
	for(var/area/N in all_areas)
		if(istype(N, areatype))
			for(var/turf/T in N) turfs += T
	return turfs

/datum/coords //Simple datum for storing coordinates.
	var/x_pos = null
	var/y_pos = null
	var/z_pos = null

/area/proc/move_contents_to(var/area/A, var/turftoleave=null, var/direction = null)
	//Takes: Area. Optional: turf type to leave behind.
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src) return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for (var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for (var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/fromupdate = new/list()
	var/list/toupdate = new/list()

	moving:
		for (var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for (var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					var/turf/X = B.ChangeTurf(T.type)
					X.setDir(old_dir1)
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					/* Quick visual fix for some weird shuttle corner artefacts when on transit space tiles */
					if(direction && findtext(X.icon_state, "swall_s"))

						// Spawn a new shuttle corner object
						var/obj/corner = new()
						corner.loc = X
						corner.density = 1
						corner.anchored = 1
						corner.icon = X.icon
						corner.icon_state = oldreplacetext(X.icon_state, "_s", "_f")
						corner.tag = "delete me"
						corner.name = "wall"

						// Find a new turf to take on the property of
						var/turf/nextturf = get_step(corner, direction)
						if(!nextturf || !isspaceturf(nextturf))
							nextturf = get_step(corner, turn(direction, 180))


						// Take on the icon of a neighboring scrolling space icon
						X.icon = nextturf.icon
						X.icon_state = nextturf.icon_state


					for(var/obj/O in T)
						// Reset the shuttle corners
						if(O.tag == "delete me")
							X.icon = 'icons/turf/shuttle.dmi'
							X.icon_state = oldreplacetext(O.icon_state, "_f", "_s") // revert the turf to the old icon_state
							X.name = "wall"
							qdel(O) // prevents multiple shuttle corners from stacking
							continue
						if(!istype(O,/obj)) continue
						O.loc = X
					for(var/mob/M in T)
						if(!istype(M,/mob) || istype(M, /mob/aiEye)) continue // If we need to check for more mobs, I'll add a variable
						M.loc = X

//					var/area/AR = X.loc

//					if(AR.lighting_use_dynamic)							//TODO: rewrite this code so it's not messed by lighting ~Carn
//						X.opacity = !X.opacity
//						X.SetOpacity(!X.opacity)

					toupdate += X

					if(turftoleave)
						fromupdate += T.ChangeTurf(turftoleave)
					else
						T.ChangeTurf(/turf/open/space)

					refined_src -= T
					refined_trg -= B
					continue moving

	var/list/doors = new/list()

	if(toupdate.len)
		for(var/turf/T1 in toupdate)
			for(var/obj/machinery/door/D2 in T1)
				doors += D2
			/*if(T1.parent)
				air_master.groups_to_rebuild += T1.parent
			else
				air_master.tiles_to_update += T1*/

	if(fromupdate.len)
		for(var/turf/T2 in fromupdate)
			for(var/obj/machinery/door/D2 in T2)
				doors += D2
			/*if(T2.parent)
				air_master.groups_to_rebuild += T2.parent
			else
				air_master.tiles_to_update += T2*/


/proc/DuplicateObject(atom/original, atom/newloc)
	if(!original || !newloc)
		return

	var/atom/O = new original.type(newloc)
	if(!O)
		return

	O.contents.Cut()

	for(var/V in original.vars - GLOB.duplicate_forbidden_vars)
		if(istype(original.vars[V], /datum)) // this would reference the original's object, that will break when it is used or deleted.
			continue
		else if(islist(original.vars[V]))
			var/list/L = original.vars[V]
			O.vars[V] = L.Copy()
		else
			O.vars[V] = original.vars[V]

	for(var/atom/A in original.contents)
		O.contents += new A.type

	if(isobj(O))
		var/obj/N = O

		N.update_icon()
		if(ismachinery(O))
			var/obj/machinery/M = O
			M.power_change()

	return O


/area/proc/copy_contents_to(var/area/A , var/platingRequired = 0 )
	//Takes: Area. Optional: If it should copy to areas that don't have plating
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src) return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for (var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for (var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/toupdate = new/list()

	var/copiedobjs = list()


	moving:
		for (var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for (var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					if(platingRequired)
						if(isspaceturf(B))
							continue moving

					var/turf/X = new T.type(B)
					X.setDir(old_dir1)
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi


					var/list/objs = new/list()
					var/list/newobjs = new/list()
					var/list/mobs = new/list()
					var/list/newmobs = new/list()

					for(var/obj/O in T)

						if(!istype(O,/obj))
							continue

						objs += O


					for(var/obj/O in objs)
						newobjs += DuplicateObject(O, T)


					for(var/obj/O in newobjs)
						O.loc = X

					for(var/mob/M in T)

						if(!istype(M,/mob) || istype(M, /mob/aiEye)) continue // If we need to check for more mobs, I'll add a variable
						mobs += M

					for(var/mob/M in mobs)
						newmobs += DuplicateObject(M, T)

					for(var/mob/M in newmobs)
						M.loc = X

					copiedobjs += newobjs
					copiedobjs += newmobs



					for(var/V in T.vars)
						if(!(V in list("type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key","x","y","z","contents", "luminosity")))
							X.vars[V] = T.vars[V]

//					var/area/AR = X.loc

//					if(AR.lighting_use_dynamic)
//						X.opacity = !X.opacity
//						X.sd_SetOpacity(!X.opacity)			//TODO: rewrite this code so it's not messed by lighting ~Carn

					toupdate += X

					refined_src -= T
					refined_trg -= B
					continue moving


	return copiedobjs



proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)

//I dont understand the above proc so I'm writing my own shittier one
proc/get_cardinal_dir2(var/atom/A, var/atom/B)
	var/dx = B.x - A.x
	var/dy = B.y - A.y
	if(abs(dx) > abs(dy))
		return (dx > 0) ? EAST : WEST
	return (dy > 0) ? NORTH : SOUTH

//Returns the 2 dirs perpendicular to the arg
proc/get_perpen_dir(var/dir)
	if(dir & (dir-1)) return 0 //diagonals
	if(dir in list(EAST, WEST))
		return list(SOUTH, NORTH)
	else return list(EAST, WEST)

//chances are 1:value. anyprob(1) will always return true
proc/anyprob(value)
	return (rand(1,value)==value)

proc/view_or_range(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = view(distance,center)
		if("range")
			. = range(distance,center)
	return

proc/oview_or_orange(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = oview(distance,center)
		if("range")
			. = orange(distance,center)
	return

proc/get_mob_with_client_list()
	var/list/mobs = list()
	for(var/mob/M in GLOB.mob_list)
		if (M.client)
			mobs += M
	return mobs


/proc/parse_zone(zone)
	if(zone == "r_hand") return "right hand"
	else if (zone == "l_hand") return "left hand"
	else if (zone == "l_arm") return "left arm"
	else if (zone == "r_arm") return "right arm"
	else if (zone == "l_leg") return "left leg"
	else if (zone == "r_leg") return "right leg"
	else if (zone == "l_foot") return "left foot"
	else if (zone == "r_foot") return "right foot"
	else if (zone == "l_hand") return "left hand"
	else if (zone == "r_hand") return "right hand"
	else if (zone == "l_foot") return "left foot"
	else if (zone == "r_foot") return "right foot"
	else return zone

/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null

/proc/get_turf_or_move(turf/location)
	return get_turf(location)


//Quick type checks for some tools
var/global/list/common_tools = list(
/obj/item/stack/cable_coil,
/obj/item/tool/wrench,
/obj/item/tool/weldingtool,
/obj/item/tool/screwdriver,
/obj/item/tool/wirecutters,
/obj/item/multitool,
/obj/item/tool/crowbar)

/proc/istool(O)
	if(O && is_type_in_list(O, common_tools))
		return 1
	return 0

proc/is_hot(obj/item/I)
	return I.heat_source

//Whether or not the given item counts as sharp in terms of dealing damage
/proc/is_sharp(obj/item/I)
	if (!istype(I)) return 0
	if (I.sharp) return 1
	if (I.edge) return 1
	return 0

//Whether or not the given item counts as cutting with an edge in terms of removing limbs
/proc/has_edge(obj/item/I)
	if (!istype(I)) return 0
	if (I.edge) return 1
	return 0

/proc/params2turf(scr_loc, turf/origin, client/C)
	if(!scr_loc)
		return null
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	var/list/actual_view = getviewsize(C ? C.view : world.view)
	tX = CLAMP(origin.x + text2num(tX) - round(actual_view[1] / 2) - 1, 1, world.maxx)
	tY = CLAMP(origin.y + text2num(tY) - round(actual_view[2] / 2) - 1, 1, world.maxy)
	return locate(tX, tY, tZ)


//Returns 1 if the given item is capable of popping things like balloons, inflatable barriers, or cutting police tape.
/proc/can_puncture(obj/item/W)		// For the record, WHAT THE HELL IS THIS METHOD OF DOING IT?
	if(!istype(W)) return 0
	return (W.sharp || W.heat_source >= 400 	|| \
		isscrewdriver(W)	 || \
		istype(W, /obj/item/tool/pen) 		 || \
		istype(W, /obj/item/tool/shovel) \
	)

/proc/is_surgery_tool(obj/item/W as obj)
	return (	\
	istype(W, /obj/item/tool/surgery/scalpel)			||	\
	istype(W, /obj/item/tool/surgery/hemostat)		||	\
	istype(W, /obj/item/tool/surgery/retractor)		||	\
	istype(W, /obj/item/tool/surgery/cautery)			||	\
	istype(W, /obj/item/tool/surgery/bonegel)			||	\
	istype(W, /obj/item/tool/surgery/bonesetter)
	)




/proc/reverse_direction(direction)
	switch(direction)
		if(NORTH)
			return SOUTH
		if(NORTHEAST)
			return SOUTHWEST
		if(EAST)
			return WEST
		if(SOUTHEAST)
			return NORTHWEST
		if(SOUTH)
			return NORTH
		if(SOUTHWEST)
			return NORTHEAST
		if(WEST)
			return EAST
		if(NORTHWEST)
			return SOUTHEAST

/proc/reverse_nearby_direction(direction)
	switch(direction)
		if(NORTH) 		. = list(SOUTH,     SOUTHEAST, SOUTHWEST)
		if(NORTHEAST) 	. = list(SOUTHWEST, SOUTH,     WEST)
		if(EAST) 		. = list(WEST,      SOUTHWEST, NORTHWEST)
		if(SOUTHEAST) 	. = list(NORTHWEST, NORTH,     WEST)
		if(SOUTH) 		. = list(NORTH,     NORTHEAST, NORTHWEST)
		if(SOUTHWEST) 	. = list(NORTHEAST, NORTH,     EAST)
		if(WEST) 		. = list(EAST,      NORTHEAST, SOUTHEAST)
		if(NORTHWEST) 	. = list(SOUTHEAST, SOUTH,     EAST)


/*
Checks if that loc and dir has a item on the wall
*/
var/list/WALLITEMS = list(
	"/obj/machinery/power/apc", "/obj/machinery/alarm", "/obj/item/radio/intercom",
	"/obj/structure/extinguisher_cabinet", "/obj/structure/reagent_dispensers/peppertank",
	"/obj/machinery/status_display", "/obj/machinery/requests_console", "/obj/machinery/light_switch", "/obj/effect/sign",
	"/obj/machinery/newscaster", "/obj/machinery/firealarm", "/obj/structure/noticeboard", "/obj/machinery/door_control",
	"/obj/machinery/computer/security/telescreen", "/obj/machinery/embedded_controller/radio/simple_vent_controller",
	"/obj/item/storage/secure/safe", "/obj/machinery/door_timer", "/obj/machinery/flasher", "/obj/machinery/keycard_auth",
	"/obj/structure/mirror", "/obj/structure/closet/fireaxecabinet", "/obj/machinery/computer/security/telescreen/entertainment"
	)
/proc/gotwallitem(loc, dir)
	for(var/obj/O in loc)
		for(var/item in WALLITEMS)
			if(istype(O, text2path(item)))
				//Direction works sometimes
				if(O.dir == dir)
					return 1

				//Some stuff doesn't use dir properly, so we need to check pixel instead
				switch(dir)
					if(SOUTH)
						if(O.pixel_y > 10)
							return 1
					if(NORTH)
						if(O.pixel_y < -10)
							return 1
					if(WEST)
						if(O.pixel_x > 10)
							return 1
					if(EAST)
						if(O.pixel_x < -10)
							return 1


	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in get_step(loc, dir))
		for(var/item in WALLITEMS)
			if(istype(O, text2path(item)))
				if(O.pixel_x == 0 && O.pixel_y == 0)
					return 1
	return 0

/proc/format_text(text)
	return oldreplacetext(oldreplacetext(text,"\proper ",""),"\improper ","")

/proc/topic_link(var/datum/D, var/arglist, var/content)
	if(istype(arglist,/list))
		arglist = list2params(arglist)
	return "<a href='?src=\ref[D];[arglist]'>[content]</a>"

#define SIGN(x) ( x < 0 ? -1  : 1 )
//Reasonably Optimized Bresenham's Line Drawing
/proc/getline(atom/start, atom/end)
	var/x = start.x
	var/y = start.y
	var/z = start.z

	//horizontal and vertical lines special case
	if(y == end.y)
		return x <= end.x ? block(locate(x,y,z), locate(end.x,y,z)) : reverseRange(block(locate(end.x,y,z), locate(x,y,z)))
	if(x == end.x)
		return y <= end.y ? block(locate(x,y,z), locate(x,end.y,z)) : reverseRange(block(locate(x,end.y,z), locate(x,y,z)))

	//let's compute these only once
	var/abs_dx = abs(end.x - x)
	var/abs_dy = abs(end.y - y)
	var/sign_dx = SIGN(end.x - x)
	var/sign_dy = SIGN(end.y - y)

	var/list/turfs = list(locate(x,y,z))

	//diagonal special case
	if(abs_dx == abs_dy)
		for(var/j = 1 to abs_dx)
			x += sign_dx
			y += sign_dy
			turfs += locate(x,y,z)
		return turfs

	/*x_error and y_error represents how far we are from the ideal line.
	Initialized so that we will check these errors against 0, instead of 0.5 * abs_(dx/dy)*/

	//We multiply every check by the line slope denominator so that we only handles integers
	if(abs_dx > abs_dy)
		var/y_error = -(abs_dx >> 1)
		var/steps = abs_dx
		while(steps--)
			y_error += abs_dy
			if(y_error > 0)
				y_error -= abs_dx
				y += sign_dy
			x += sign_dx
			turfs += locate(x,y,z)
	else
		var/x_error = -(abs_dy >> 1)
		var/steps = abs_dy
		while(steps--)
			x_error += abs_dx
			if(x_error > 0)
				x_error -= abs_dy
				x += sign_dx
			y += sign_dy
			turfs += locate(x,y,z)

	. = turfs

#undef SIGN

//gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	CRASH(msg)

/datum/proc/stack_trace(msg)
	CRASH(msg)

////// Matrices ///////

/matrix/proc/TurnTo(old_angle, new_angle)
	. = new_angle - old_angle
	Turn(.) //BYOND handles cases such as -270, 360, 540 etc. DOES NOT HANDLE 180 TURNS WELL, THEY TWEEN AND LOOK LIKE SHIT

//Key thing that stops lag. Cornerstone of performance in ss13, Just sitting here, in unsorted.dm.

//Increases delay as the server gets more overloaded,
//as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

//returns the number of ticks slept
/proc/stoplag(initial_delay)
	if (!Master || !(Master.current_runlevel & RUNLEVELS_DEFAULT))
		sleep(world.tick_lag)
		return 1
	if (!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += CEILING(i*DELTA_CALC, 1)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while (TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

#undef DELTA_CALC

//datum may be null, but it does need to be a typed var
#define NAMEOF(datum, X) (#X || ##datum.##X)

// \ref behaviour got changed in 512 so this is necesary to replicate old behaviour.
// If it ever becomes necesary to get a more performant REF(), this lies here in wait
// #define REF(thing) (thing && istype(thing, /datum) && (thing:datum_flags & DF_USE_TAG) && thing:tag ? "[thing:tag]" : "\ref[thing]")
/proc/REF(input)
	if(istype(input, /datum))
		var/datum/thing = input
		if(thing.datum_flags & DF_USE_TAG)
			if(!thing.tag)
				stack_trace("A ref was requested of an object with DF_USE_TAG set but no tag: [thing]")
				thing.datum_flags &= ~DF_USE_TAG
			else
				return "\[[url_encode(thing.tag)]\]"
	return "\ref[input]"

// Makes a call in the context of a different usr
// Use sparingly
/world/proc/PushUsr(mob/M, datum/callback/CB, ...)
	var/temp = usr
	usr = M
	if (length(args) > 2)
		. = CB.Invoke(arglist(args.Copy(3)))
	else
		. = CB.Invoke()
	usr = temp

#define UNTIL(X) while(!(X)) stoplag()


//returns a GUID like identifier (using a mostly made up record format)
//guids are not on their own suitable for access or security tokens, as most of their bits are predictable.
//	(But may make a nice salt to one)
/proc/GUID()
	var/const/GUID_VERSION = "b"
	var/const/GUID_VARIANT = "d"
	var/node_id = copytext(md5("[rand()*rand(1,9999999)][world.name][world.hub][world.hub_password][world.internet_address][world.address][world.contents.len][world.status][world.port][rand()*rand(1,9999999)]"), 1, 13)

	var/time_high = "[num2hex(text2num(time2text(world.realtime,"YYYY")), 2)][num2hex(world.realtime, 6)]"

	var/time_mid = num2hex(world.timeofday, 4)

	var/time_low = num2hex(world.time, 3)

	var/time_clock = num2hex(TICK_DELTA_TO_MS(world.tick_usage), 3)

	return "{[time_high]-[time_mid]-[GUID_VERSION][time_low]-[GUID_VARIANT][time_clock]-[node_id]}"

/proc/pass()
	return

proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types())
	if (value == FALSE) //nothing should be calling us with a number, so this is safe
		value = input("Enter type to find (blank for all, cancel to cancel)", "Search for type") as null|text
		if (isnull(value))
			return
	value = trim(value)
	if(!isnull(value) && value != "")
		matches = filter_fancy_list(matches, value)

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select a type", "Pick Type", matches[1]) as null|anything in matches
		if(!chosen)
			return
	chosen = matches[chosen]
	return chosen


/proc/IsValidSrc(datum/D)
	if(istype(D))
		return !QDELETED(D)
	return FALSE

//Repopulates sortedAreas list
/proc/repopulate_sorted_areas()
	GLOB.sortedAreas = list()

	for(var/area/A in world)
		GLOB.sortedAreas.Add(A)

	sortTim(GLOB.sortedAreas, /proc/cmp_name_asc)

// Format a power value in W, kW, MW, or GW.
/proc/DisplayPower(powerused)
	if(powerused < 1000) //Less than a kW
		return "[powerused] W"
	else if(powerused < 1000000) //Less than a MW
		return "[round((powerused * 0.001),0.01)] kW"
	else if(powerused < 1000000000) //Less than a GW
		return "[round((powerused * 0.000001),0.001)] MW"
	return "[round((powerused * 0.000000001),0.0001)] GW"

// Bucket a value within boundary
/proc/get_bucket(var/bucket_size, var/max, var/current, var/min = 0, var/list/boundary_terms = list())
	if (boundary_terms.len == 2)
		if (current >= max) 
			return boundary_terms[1]
		if (current < min)
			return boundary_terms[2]

	return CEILING((bucket_size / max) * current, 1)