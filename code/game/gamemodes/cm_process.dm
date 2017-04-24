/*
/mob/verb/test_shuttle()
	set name = "DEBUG EVAC SHUTTLE"
	set category = "DEBUG"

	world << "Location is [emergency_shuttle.shuttle.location]"
	world << "Moving status is [emergency_shuttle.shuttle.moving_status]"
	world << "Departed is [emergency_shuttle.departed]"

*/
#define QUEEN_DEATH_COUNTDOWN 			 12000 //20 minutes. Can be changed into a variable if it needs to be manipulated later.

#define MODE_INFESTATION_X_MAJOR		"Xenomorph Major Victory"
#define MODE_INFESTATION_M_MAJOR		"Marine Major Victory"
#define MODE_INFESTATION_X_MINOR		"Xenomorph Minor Victory"
#define MODE_INFESTATION_M_MINOR		"Marine Minor Victory"
#define MODE_INFESTATION_DRAW_DEATH		"DRAW: Mutual Annihilation"

#define MODE_BATTLEFIELD_W_MAJOR		"W-Y PMC Major Success"
#define MODE_BATTLEFIELD_M_MAJOR		"Marine Major Success"
#define MODE_BATTLEFIELD_W_MINOR		"W-Y PMC Minor Success"
#define MODE_BATTLEFIELD_M_MINOR		"Marine Minor Success"
#define MODE_BATTLEFIELD_DRAW_STALEMATE "DRAW: Stalemate"
#define MODE_BATTLEFIELD_DRAW_DEATH		"DRAW: My Friends Are Dead"

#define MODE_GENERIC_DRAW_NUKE			"DRAW: Nuclear Explosion"

/*
Like with cm_initialize.dm, these procs exist to quickly populate classic CM game modes.
Specifically for processing, announcing completion, and so on. Simply plug in these procs
in to the appropriate slots, like the in the example game modes, and you're good to go.
This is meant for infestation type game modes for right now (marines vs. aliens, with a chance
of predators), but can be added to include variant game modes (like humans vs. humans).
*/

//===================================================\\

				//PROCESS GAME MODE\\

//===================================================\\

/datum/game_mode/proc/pre_setup_infestation()
	round_fog = new
	var/xeno_tunnels[] = new
	var/obj/effect/blocker/fog/F
	for(var/obj/effect/landmark/L in world)
		switch(L.name)
			if("hunter_primary")
				cdel(L)
			if("hunter_secondary")
				cdel(L)
			if("crap_item")
				cdel(L)
			if("good_item")
				cdel(L)
			if("block_hellhound")
				cdel(L)
			if("fog blocker")
				F = new(L.loc)
				round_fog += F
				cdel(L)
			if("xeno tunnel")
				xeno_tunnels += L.loc
				cdel(L)
	if(!round_fog.len) round_fog = null //No blockers?
	else
		round_time_fog = rand(-2500,2500)
		flags_round_type |= MODE_FOG_ACTIVATED
	var/obj/structure/tunnel/T
	var/i = 0
	var/turf/t
	while(xeno_tunnels.len && i++ < 3)
		t = pick(xeno_tunnels)
		xeno_tunnels -= t
		T = new(t)
		T.id = "hole[i]"

	r_TRU

//===================================================\\

				//PROCESS GAME MODE\\

//===================================================\\

#define FOG_DELAY_INTERVAL		27000 // 45 minutes
/datum/game_mode/proc/process_infestation()
	if(--round_started > 0) r_FAL //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.

	if(!round_finished)
		if(xeno_queen_timer && --xeno_queen_timer <= 1) xeno_message("The Hive is ready for a new Queen to evolve.")

		// Automated bioscan / Queen Mother message
		if(world.time > bioscan_current_interval) //If world time is greater than required bioscan time.
			announce_bioscans() //Announce the results of the bioscan to both sides.
			bioscan_current_interval += bioscan_ongoing_interval //Add to the interval based on our set interval time.

		if(++round_checkwin >= 5) //Only check win conditions every 5 ticks.
			if(flags_round_type & MODE_FOG_ACTIVATED && world.time >= (FOG_DELAY_INTERVAL + round_time_lobby + round_time_fog)) disperse_fog()//Some RNG thrown in.
			check_win()
			round_checkwin = 0

#undef FOG_DELAY_INTERVAL

//===================================================\\

				  //CHECK VICTORY\\

//===================================================\\

/datum/game_mode/proc/check_win_infestation()
	var/living_player_list[] = count_humans_and_xenos(EvacuationAuthority.get_affected_zlevels())
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]

	if(EvacuationAuthority.dest_status == NUKE_EXPLOSION_FINISHED)			round_finished = MODE_GENERIC_DRAW_NUKE //Nuke went off, ending the round.
	else if(!num_humans && num_xenos) //No humans remain alive.
		if(EvacuationAuthority.evac_status == EVACUATION_STATUS_COMPLETE) 	round_finished = MODE_INFESTATION_X_MINOR //Evacuation successfully took place. //TODO Find out if anyone made it on.
		else																round_finished = MODE_INFESTATION_X_MAJOR //Evacuation did not take place. Everyone died.
	else if(num_humans && !num_xenos)										round_finished = MODE_INFESTATION_M_MAJOR //Humans destroyed the xenomorphs.
	else if(!num_humans && !num_xenos)										round_finished = MODE_INFESTATION_DRAW_DEATH //Both were somehow destroyed.

//If the queen is dead after a period of time, this will end the game.
/datum/game_mode/proc/check_queen_status(queen_time)
	set waitfor = 0
	ticker.mode.xeno_queen_timer = queen_time
	if(!(flags_round_type & MODE_INFESTATION)) return
	var/num_last_deaths = ++xeno_queen_deaths
	sleep(QUEEN_DEATH_COUNTDOWN)
	//We want to make sure that another queen didn't die in the interim.
	if(xeno_queen_deaths == num_last_deaths && !round_finished && !is_queen_alive() ) round_finished = MODE_INFESTATION_M_MINOR

//===================================================\\

				//ANNOUNCE COMPLETION\\

//===================================================\\

/datum/game_mode/proc/declare_completion_infestation() //TO DO: Change the file path to something better. This is not only for infestation anymore.
	world << "<span class='round_header'>[round_finished]</span>"
	feedback_set_details("round_end_result",round_finished)


	if(flags_round_type & MODE_INFESTATION)
		world << "<span class='round_body'>Thus ends the story of the brave men and women of the [MAIN_SHIP_NAME] and their struggle on [uppertext(name)].</span>"
		var/musical_track
		switch(round_finished)
			if(MODE_INFESTATION_X_MAJOR) musical_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
			if(MODE_INFESTATION_M_MAJOR) musical_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
			if(MODE_INFESTATION_X_MINOR) musical_track = pick('sound/theme/neutral_melancholy1.ogg','sound/theme/neutral_melancholy2.ogg')
			if(MODE_INFESTATION_M_MINOR) musical_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
			if(MODE_INFESTATION_DRAW_DEATH) musical_track = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg') //This one is unlikely to play.
		world << musical_track
	else
		switch(round_finished)
			if(MODE_BATTLEFIELD_W_MAJOR)
				world << "<span class='round_body'>The W-Y PMCs have successfully repelled the USCM assault and completed their objectives!</span>"
				world << 'sound/misc/good_is_dumb.ogg'
			if(MODE_BATTLEFIELD_M_MAJOR)
				world << "<span class='round_body'>The marines have wiped out the PMC garrison and completed their objective! Hooah!</span>"
				world << 'sound/misc/outstanding_marines.ogg'
			if(MODE_BATTLEFIELD_W_MINOR)
				world << "<span class='round_body'>The W-Y PMCs wiped out the marines, but they failed to complete their objective! W-Y won't be happy!</span>"
				world << 'sound/misc/gone_to_plaid.ogg'
			if(MODE_BATTLEFIELD_M_MINOR)
				world << "<span class='round_body'>The marines glassed the W-Y mercs, but they failed to complete their objective! Incompetent baldies!</span>"
				world << 'sound/misc/apcdestroyed.ogg'
			if(MODE_BATTLEFIELD_DRAW_STALEMATE)
				world << "<span class='round_body'>The marines completed their objective, but they failed to destroy the PMCs! W-Y will be coming back!</span>"
			if(MODE_BATTLEFIELD_DRAW_DEATH)
				world << "<span class='round_body'>Both the marines and the W-Y PMCs were annihilated! The nightmare continues!</span>"
				world << 'sound/misc/Rerun.ogg'
			if(MODE_GENERIC_DRAW_NUKE)
				world << "<span class='round_body'>The nuclear explosion changed everything.</span>"

			else world << "<span class='round_body'>Whoops, something went wrong with declare_completion(), blame the coders!</span>"

	var/dat = ""
	if(flags_round_type & MODE_INFESTATION)
		var/living_player_list[] = count_humans_and_xenos()
		dat = "\nXenomorphs remaining: [living_player_list[2]]. Humans remaining: [living_player_list[1]]."
	if(round_stats) round_stats << "[round_finished][dat]\nRound time: [duration2text()]\nRound population: [clients.len][log_end]" // Logging to data/logs/round_stats.log

	world << dat

	declare_completion_announce_individual()
	declare_completion_announce_predators()
	if(flags_round_type & MODE_INFESTATION)
		declare_completion_announce_xenomorphs()
		declare_completion_announce_survivors()
	return 1

/datum/game_mode/proc/declare_completion_announce_individual()
	set waitfor = 0
	sleep(45)
/*
//WIP proc to announce specific outcomes to players. Might require better tracking, but the basics wouldn't hurt.

dat = "You have met your demise during the events of [upper_text(name)][m.mind.current ? " as [m.mind.current.real_name]" : ]. Rest in peace."

dat = "<b>You have survived the events of [upper_text(name)]</b>"

//General disposition.
dat += ", but a sickly feeling in your chest suggests a darker fate awaits you..."
dat += ", but you find yourself in a sticky situation. Best to find a way out..."
//Pain/damage.
dat += " The pain is making it difficult to see straight. You are still reeling from the experience."
dat += " Your severe injuries will no-doubt be a topic for discussion in the future."
//Managed to get to evac safely.
dat += " At least you've made it to evac; it's all over now, right?"
//Failed to catch it.
dat += " You failed to evacuate \the [MAIN_SHIP_NAME]"


"<b>You have survived</b>
"<b>You have survived</b>, and you have managed to evacuate the [MAIN_SHIP_NAME]. Maybe it's finally over..."
"<b>You have survived</b>. That is more than enough, but who knows what the future holds for you now..."

"<span class='round_body'>You lead your hive, and you have survived. Your influence will grow in time.</span>"
"<span class='round_body'>You have served the hive.</span>"

	for(var/mob/m in player_list)
		if(m.mind)
			if(m.stat == DEAD) "<span class='round_body'>You met your demise during the events of [upper_text(name)].</span>"
			else
				if(isYautja(m))

				if(ishuman(m))
					is_mob_immobalized()
				if(isXeno(m))


				var/turf/T = get_turf(m)
				if(ishuman(H))

				var/turf/playerTurf = get_turf(Player)
				if(emergency_shuttle.departed && emergency_shuttle.evac)
					if(playerTurf.z != 2)
						Player << "<span class='round_body'>You managed to survive, but were marooned on [station_name()] as [Player.real_name]...</span>"
					else
						Player << "<font color='green'><b>You managed to survive the events of [name] as [m.real_name].</b></font>"
				else if(playerTurf.z == 2)
					Player << "<font color='green'><b>You successfully underwent crew transfer after events on [station_name()] as [Player.real_name].</b></font>"
				else if(issilicon(Player))
					Player << "<font color='green'><b>You remain operational after the events on [station_name()] as [Player.real_name].</b></font>"
				else
					Player << "<font color='blue'><b>You missed the crew transfer after the events on [station_name()] as [Player.real_name].</b></font>"
			else

	if(xenomorphs.len)
		var/dat = "<span class='round_body'>The xenomorph Queen(s) were:</span>"
		var/mob/M
		for(var/datum/mind/X in xenomorphs)
			if(istype(X))
				M = X.current
				if(!M || !M.loc) M = X.original
				if(M && M.loc && istype(M,/mob/living/carbon/Xenomorph/Queen)) dat += "<br>[X.key] was [M] <span class='boldnotice'>([M.stat == DEAD? "DIED":"SURVIVED"])</span>"

		world << dat
*/
/datum/game_mode/proc/declare_completion_announce_xenomorphs()
	set waitfor = 0
	sleep(60)
	if(xenomorphs.len)
		var/dat = "<span class='round_body'>The xenomorph Queen(s) were:</span>"
		var/mob/M
		for(var/datum/mind/X in xenomorphs)
			if(istype(X))
				M = X.current
				if(!M || !M.loc) M = X.original
				if(M && M.loc && istype(M,/mob/living/carbon/Xenomorph/Queen)) dat += "<br>[X.key] was [M] <span class='boldnotice'>([M.stat == DEAD? "DIED":"SURVIVED"])</span>"

		world << dat

/datum/game_mode/proc/declare_completion_announce_survivors()
	set waitfor = 0
	sleep(85)
	if(survivors.len)
		var/dat = "<span class='round_body'>The survivors were:</span>"
		var/mob/M
		for(var/datum/mind/S in survivors)
			if(istype(S))
				M = S.current
				if(!M || !M.loc) M = S.original
				if(M && M.loc) 	dat += "<br>[S.key] was [M.real_name] <span class='boldnotice'>([M.stat == DEAD? "DIED":"SURVIVED"])</span>"
				else 			dat += "<br>[S.key]'s body was destroyed... <span class='boldnotice'>(DIED)</span>"

		world << dat

/datum/game_mode/proc/declare_completion_announce_predators()
	set waitfor = 0
	sleep(100)
	if(predators.len)
		var/dat = "<span class='round_body'>The Predators were:</span>"
		var/mob/M
		for(var/datum/mind/P in predators)
			if(istype(P))
				M = P.current
				if(!M || !M.loc) M = P.original
				if(M && M.loc) 	dat += "<br>[P.key] was [M.real_name] <span class='boldnotice'>([M.stat == DEAD? "DIED":"SURVIVED"])</span>"
				else 			dat += "<br>[P.key]'s body was destroyed... <span class='boldnotice'>(DIED)</span>"

		world << dat


//===================================================\\

					//HELPER PROCS\\

//===================================================\\

//Disperses fog, doing so gradually.
/datum/game_mode/proc/disperse_fog()
	set waitfor = 0
	//world << "<span class='boldnotice'>The fog north of the colony is starting to recede.</span>" //Let's try it without an announcement.
	flags_round_type &= ~MODE_FOG_ACTIVATED
	var/i
	for(i in round_fog)
		round_fog -= i
		cdel(i)
		sleep(1)
	round_fog = null

//Delta is the randomness interval, in +/-. Might not be the exact mathematical definition
/datum/game_mode/proc/announce_bioscans(var/delta = 2)
	var/list/activeXenos = list() //We'll announce to them later.
	var/numHostsPlanet	= 0
	var/numHostsShip	= 0
	var/numXenosPlanet	= 0
	var/numXenosShip	= 0

	for(var/mob/M in player_list) //Scan through and detect Xenos and Hosts, but only those with clients.
		if(M.stat != DEAD)
			if(isXeno(M))
				switch(M.z)
					if(3, 4) numXenosShip++ //On the ship.
					else	 numXenosPlanet++ //Elsewhere.
				activeXenos += M

			if(ishuman(M) && !isYautja(M))
				switch(M.z)
					if(3, 4) numHostsShip++ //On the ship.
					else	 numHostsPlanet++ //Elsewhere.

	//Adjust the randomness there so everyone gets the same thing
	numHostsShip = max(0, numHostsShip + rand(-delta, delta))
	numXenosPlanet = max(0, numXenosPlanet + rand(-delta, delta))

	// The announcement to all Xenos. Slightly off for the human ship, accurate otherwise.
	for(var/mob/M in activeXenos)
		M << sound(get_sfx("queen"), wait = 0, volume = 50)
		M << "<span class='xenoannounce'>The Queen Mother reaches into your mind from worlds away.</span>"
		M << "<span class='xenoannounce'>To my children and their Queen. I sense [numHostsShip ? "approximately [numHostsShip]":"no"] host[!numHostsShip || numHostsShip > 1 ? "s":""] in the metal hive and [numHostsPlanet ? "[numHostsPlanet]":"none"] scattered elsewhere.</span>"

	// The announcement to all Humans. Slightly off for the planet and elsewhere, accurate for the ship.
	var/name = "M.O.T.H.E.R. Bioscan Status"
	var/input = "Bioscan complete.\n\nSensors indicate [numXenosShip ? "[numXenosShip]":"no"] unknown lifeform signature[!numXenosShip || numXenosShip > 1 ? "s":""] present on the ship and [numXenosPlanet ? "approximately [numXenosPlanet]":"no"] signature[!numXenosPlanet || numXenosPlanet > 1 ? "s":""] located elsewhere."
	command_announcement.Announce(input, name, new_sound = 'sound/AI/commandreport.ogg')

	log_admin("A bioscan/Queen Mother message has completed. Humans: [numHostsPlanet] on the planet and [numHostsShip] on the ship. Xenos: [numXenosPlanet] on the planet and [numXenosShip] on the ship.")
	message_admins("A bioscan/Queen Mother message has completed. Humans: [numHostsPlanet] on the planet and [numHostsShip] on the ship. Xenos: [numXenosPlanet] on the planet and [numXenosShip] on the ship.", 1)

/*
Count up surviving humans and aliens.
Can't be in a locker, in space, in the thunderdome, or distress.
Only checks living mobs with a client attached.
*/
/datum/game_mode/proc/count_humans_and_xenos(list/z_levels = GAME_PLAY_Z_LEVELS)
	var/num_humans = 0
	var/num_xenos = 0
	var/area/A

	for(var/mob/M in player_list)
		A = get_area(M.loc)
		if(A.z in z_levels && M.stat != DEAD && !istype(M.loc, /turf/space) && !istype(A, /area/centcom) && !istype(A, /area/tdome) && !istype(A, /area/shuttle/distress_start) && !istype(A, /area/almayer/evacuation/stranded))
			if(ishuman(M) && !isYautja(M) && !(M.status_flags & XENO_HOST))
				num_humans++
			else if(isXeno(M))
				num_xenos++

	return list(num_humans,num_xenos)

/datum/game_mode/proc/count_marines_and_pmcs(list/z_levels = GAME_PLAY_Z_LEVELS)
	var/num_marines = 0
	var/num_pmcs = 0
	var/area/A

	for(var/mob/M in player_list)
		A = get_area(M.loc)
		if(A.z in z_levels && M.stat != DEAD && !istype(M.loc,/turf/space) && !istype(A, /area/centcom) && !istype(A, /area/tdome) && !istype(A, /area/shuttle/distress_start) && !istype(A, /area/almayer/evacuation/stranded))
			if(ishuman(M) && !isYautja(M))
				if(M.mind && M.mind.special_role == "PMC") 	num_pmcs++
				else if(M.mind && !M.mind.special_role)		num_marines++

	return list(num_marines,num_pmcs)

/*
#undef QUEEN_DEATH_COUNTDOWN
#undef MODE_INFESTATION_X_MAJOR
#undef MODE_INFESTATION_M_MAJOR
#undef MODE_INFESTATION_X_MINOR
#undef MODE_INFESTATION_M_MINOR
#undef MODE_INFESTATION_DRAW_DEATH
#undef MODE_BATTLEFIELD_W_MAJOR
#undef MODE_BATTLEFIELD_M_MAJOR
#undef MODE_BATTLEFIELD_W_MINOR
#undef MODE_BATTLEFIELD_M_MINOR
#undef MODE_BATTLEFIELD_DRAW_STALEMATE
#undef MODE_BATTLEFIELD_DRAW_DEATH
#undef MODE_GENERIC_DRAW_NUKE*/
