//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/proc/dopage(src,target)
	var/href_list
	var/href
	href_list = params2list("src=\ref[src]&[target]=1")
	href = "src=\ref[src];[target]=1"
	src:temphtml = null
	src:Topic(href, href_list)
	return null

/proc/get_area(atom/A)
	if(isarea(A))
		return A
	var/turf/T = get_turf(A)
	return T ? T.loc : null

/proc/get_area_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return null
	return format_text ? format_text(A.name) : A.name

/proc/get_adjacent_open_turfs(atom/center)
	. = list()
	for(var/i in GLOB.cardinals)
		var/turf/open/T = get_step(center, i)
		if(!istype(T))
			continue
		. += T

// Like view but bypasses luminosity check

/proc/hear(var/range, var/atom/source)

	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard


//supposedly the fastest way to do this according to https://gist.github.com/Giacom/be635398926bb463b42a
#define RANGE_TURFS(RADIUS, CENTER) \
  block( \
    locate(max(CENTER.x-(RADIUS),1),          max(CENTER.y-(RADIUS),1),          CENTER.z), \
    locate(min(CENTER.x+(RADIUS),world.maxx), min(CENTER.y+(RADIUS),world.maxy), CENTER.z) \
  )
 

/proc/trange(rad = 0, turf/centre = null) //alternative to range (ONLY processes turfs and thus less intensive)
	if(!centre)
		return

	var/turf/x1y1 = locate(((centre.x - rad) < 1 ? 1 : centre.x - rad), ((centre.y-rad) < 1 ? 1 : centre.y - rad), centre.z)
	var/turf/x2y2 = locate(((centre.x + rad) > world.maxx ? world.maxx : centre.x + rad), ((centre.y + rad) > world.maxy ? world.maxy : centre.y + rad), centre.z)
	return block(x1y1, x2y2)

/proc/get_dist_euclidian(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	var/dist = sqrt(dx**2 + dy**2)

	return dist

//var/debug_mob = 0

// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
// being unable to hear people due to being in a box within a bag.

/proc/recursive_mob_check(var/atom/O,  var/list/L = list(), var/recursion_limit = 3, var/client_check = 1, var/sight_check = 1, var/include_radio = 1)

	//debug_mob += O.contents.len
	if(!recursion_limit)
		return L
	for(var/atom/A in O.contents)

		if(ismob(A))
			var/mob/M = A
			if(client_check && !M.client)
				L |= recursive_mob_check(A, L, recursion_limit - 1, client_check, sight_check, include_radio)
				continue
			if(sight_check && !isInSight(A, O))
				continue
			L |= M
			//log_world("[recursion_limit] = [M] - [get_turf(M)] - ([M.x], [M.y], [M.z])")

		else if(include_radio && istype(A, /obj/item/radio))
			if(sight_check && !isInSight(A, O))
				continue
			L |= A

		if(isobj(A) || ismob(A))
			L |= recursive_mob_check(A, L, recursion_limit - 1, client_check, sight_check, include_radio)
	return L

// The old system would loop through lists for a total of 5000 per function call, in an empty server.
// This new system will loop at around 1000 in an empty server.

/proc/get_mobs_in_view(var/R, var/atom/source)
	// Returns a list of mobs in range of R from source. Used in radio and say code.

	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/list/range = hear(R, T)

	for(var/atom/A in range)
		if(ismob(A))
			var/mob/M = A
			if(M.client)
				hear += M
			//log_world("Start = [M] - [get_turf(M)] - ([M.x], [M.y], [M.z])")
		else if(istype(A, /obj/item/radio))
			hear += A

		if(isobj(A) || ismob(A))
			hear |= recursive_mob_check(A, hear, 3, 1, 0, 1)

	return hear


/proc/get_mobs_in_radio_ranges(var/list/obj/item/radio/radios)

	set background = 1

	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	var/list/speaker_coverage = list()
	for(var/obj/item/radio/R in radios)
		if(!R)
			continue

		var/turf/speaker = get_turf(R)
		if(!speaker)
			continue
			
		for(var/turf/T in hear(R.canhear_range,speaker))
			speaker_coverage[T] = T


	// Try to find all the players who can hear the message
	for(var/i = 1; i <= GLOB.player_list.len; i++)
		var/mob/M = GLOB.player_list[i]
		if(M)
			var/turf/ear = get_turf(M)
			if(ear)
				// Ghostship is magic: Ghosts can hear radio chatter from anywhere
				if(speaker_coverage[ear] || (isobserver(M) && M.client?.prefs?.toggles_chat & CHAT_GHOSTRADIO))
					. |= M		// Since we're already looping through mobs, why bother using |= ? This only slows things down.
	return .

proc
	inLineOfSight(X1,Y1,X2,Y2,Z=1,PX1=16.5,PY1=16.5,PX2=16.5,PY2=16.5)
		var/turf/T
		if(X1==X2)
			if(Y1==Y2)
				return 1 //Light cannot be blocked on same tile
			else
				var/s = (((Y2-Y1)<0)?-1:1)
				Y1+=s
				while(Y1!=Y2)
					T=locate(X1,Y1,Z)
					if(T.opacity)
						return 0
					Y1+=s
		else
			var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
			var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
			var/signX = (((X2-X1)<0)?-1:1)
			var/signY = (((Y2-Y1)<0)?-1:1)
			if(X1<X2)
				b+=m
			while(X1!=X2 || Y1!=Y2)
				if(round(m*X1+b-Y1))
					Y1+=signY //Line exits tile vertically
				else
					X1+=signX //Line exits tile horizontally
				T=locate(X1,Y1,Z)
				if(T.opacity)
					return 0
		return 1

proc/isInSight(var/atom/A, var/atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return 0

	if(inLineOfSight(Aturf.x,Aturf.y, Bturf.x,Bturf.y,Aturf.z))
		return 1

	else
		return 0

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/get_mob_by_key(var/key)
	for(var/mob/M in GLOB.mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null


// Will return a list of active candidates. It increases the buffer 5 times until it finds a candidate which is active within the buffer.
/proc/get_active_candidates(var/buffer = 1)

	var/list/candidates = list() //List of candidate KEYS to assume control of the new larva ~Carn
	var/i = 0
	while(candidates.len <= 0 && i < 5)
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(((G.client.inactivity/10)/60) <= buffer + i) // the most active players are more likely to become an alien
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					candidates += G.key
		i++
	return candidates

// Same as above but for alien candidates.
/proc/get_alien_candidate()
	var/mob/picked

	for(var/mob/dead/observer/O in GLOB.dead_mob_list)
		//Players without preferences or jobbaned players cannot be drafted.
		if(!O.key || !O.client?.prefs || !(O.client.prefs.be_special & BE_ALIEN) || jobban_isbanned(O, "Alien"))
			continue

		//AFK players cannot be drafted
		if(O.client.inactivity / 600 > ALIEN_SELECT_AFK_BUFFER + 5)
			continue

		//Recently dead observers cannot be drafted.
		var/deathtime = world.time - O.timeofdeath
		if(deathtime < GLOB.respawntime)
			continue

		//Aghosted admins don't get picked
		if(O.mind?.current && isaghost(O.mind.current))
			continue

		if(!picked)
			picked = O
			continue

		if(O.timeofdeath < picked.timeofdeath)
			picked = O

	return picked?.key


/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))	O = new /obj/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay=0)
	if(!isobj(O))	return
	if(!group)	group = GLOB.clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O

datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(var/src_x, var/src_y, var/time, var/distance, \
						   var/power_x, var/power_y, var/dest_x, var/dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/proc/projectile_trajectory(var/src_x, var/src_y, var/rotation, var/angle, var/power)

	// returns the destination (Vx,y) that a projectile shot at [src_x], [src_y], with an angle of [angle],
	// rotated at [rotation] and with the power of [power]
	// Thanks to VistaPOWA for this function

	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = 2* power_y / 10 //10 = g

	var/distance = time * power_x

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)

/proc/GetRedPart(const/hexa)
	return hex2num(copytext(hexa,2,4))

/proc/GetGreenPart(const/hexa)
	return hex2num(copytext(hexa,4,6))

/proc/GetBluePart(const/hexa)
	return hex2num(copytext(hexa,6,8))

/proc/GetHexColors(const/hexa)
	return list(
			GetRedPart(hexa),
			GetGreenPart(hexa),
			GetBluePart(hexa)
		)

/proc/MixColors(const/list/colors)
	var/list/reds = list()
	var/list/blues = list()
	var/list/greens = list()
	var/list/weights = list()

	for (var/i = 0, ++i <= colors.len)
		reds.Add(GetRedPart(colors[i]))
		blues.Add(GetBluePart(colors[i]))
		greens.Add(GetGreenPart(colors[i]))
		weights.Add(1)

	var/r = mixOneColor(weights, reds)
	var/g = mixOneColor(weights, greens)
	var/b = mixOneColor(weights, blues)
	return rgb(r,g,b)

/proc/mixOneColor(list/weight, list/color)
	if (!weight || !color || length(weight) != length(color))
		return FALSE

	var/contents = length(weight)
	var/i

	//normalize weights
	var/listsum = 0
	for(i in 1 to contents)
		listsum += weight[i]
	for(i in 1 to contents)
		weight[i] /= listsum

	//mix them
	var/mixedcolor = 0
	for(i in 1 to contents)
		mixedcolor += weight[i]*color[i]
	mixedcolor = round(mixedcolor)

	mixedcolor= CLAMP(mixedcolor, 0 ,255)

	return mixedcolor

/proc/convert_k2c(var/temp)
	return ((temp - T0C))

/proc/convert_c2k(var/temp)
	return ((temp + T0C))

// replacement for /image/reusable/proc/flick_overlay()

/proc/remove_images_from_clients(image/I, list/show_to)
	for(var/client/C in show_to)
		C.images -= I

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	addtimer(CALLBACK(GLOBAL_PROC, /proc/remove_images_from_clients, I, show_to), duration, TIMER_CLIENT_TIME)

/proc/flick_overlay_view(image/I, atom/target, duration) //wrapper for the above, flicks to everyone who can see the target atom
	var/list/viewing = list()
	for(var/m in viewers(target))
		var/mob/M = m
		if(M.client)
			viewing += M.client
	flick_overlay(I, viewing, duration)


/proc/window_flash(client/C, ignorepref = FALSE)
	if(ismob(C))
		var/mob/M = C
		C = M.client
	if(!C?.prefs.windowflashing && !ignorepref)
		return
	winset(C, "mainwindow", "flash=5")
