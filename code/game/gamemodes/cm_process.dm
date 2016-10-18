#define QUEEN_DEATH_COUNTDOWN 			 12000 //20 minutes. Can be changed into a variable if it needs to be manipulated later.

#define MODE_INFESTATION_X_MAJOR		"Xenomorph Major Victory"
#define MODE_INFESTATION_H_MAJOR		"Marine Major Victory"
#define MODE_INFESTATION_X_MINOR		"Xenomorph Minor Victory"
#define MODE_INFESTATION_H_MINOR		"Marine Minor Victory"
#define MODE_INFESTATION_DRAW_NUKE		"DRAW: Nuclear Explosion"
#define MODE_INFESTATION_DRAW_DEATH		"DRAW: Mutual Annihilation"

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

/datum/game_mode/proc/process_infestation()
	if(--round_started > 0) return //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.

	if(!round_finished)
		if(xeno_queen_timer && --xeno_queen_timer <= 1) xeno_message("The Hive is ready for a new Queen to evolve.")

		// Automated bioscan / Queen Mother message
		if(world.time > bioscan_current_interval) //If world time is greater than required bioscan time.
			announce_bioscans() //Announce the results of the bioscan to both sides.
			bioscan_current_interval += bioscan_ongoing_interval //Add to the interval based on our set interval time.

		if(++round_checkwin >= 5) //Only check win conditions every 5 ticks.
			check_win()
			round_checkwin = 0

//===================================================\\

				  //CHECK VICTORY\\

//===================================================\\

/datum/game_mode/proc/check_win_infestation()
	var/living_player_list[] = count_humans_and_xenos()
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]

	if(!num_humans && num_xenos) 		round_finished = MODE_INFESTATION_X_MAJOR
	else if(num_humans && !num_xenos)	round_finished = MODE_INFESTATION_H_MAJOR
	else if(!num_humans && !num_xenos)	round_finished = MODE_INFESTATION_DRAW_DEATH
	else if(emergency_shuttle.returned())
		emergency_shuttle.evac = 1
		round_finished 								   = MODE_INFESTATION_X_MINOR
	else if(station_was_nuked)			round_finished = MODE_INFESTATION_DRAW_NUKE

//If the queen is dead after a period of time, this will end the game.
/datum/game_mode/proc/check_queen_status(queen_time)
	set waitfor = 0
	ticker.mode.xeno_queen_timer = queen_time
	if(!(flags_round_type & MODE_INFESTATION)) return
	var/num_last_deaths = xeno_queen_deaths++
	sleep(QUEEN_DEATH_COUNTDOWN)
	//We want to make sure that another queen didn't die in the interim.
	if(xeno_queen_deaths == num_last_deaths && !round_finished && !is_queen_alive() ) round_finished = MODE_INFESTATION_H_MINOR

//===================================================\\

				//ANNOUNCE COMPLETION\\

//===================================================\\

/datum/game_mode/proc/declare_completion_infestation()
	world << "<span class='round_header'>[round_finished]</span>"
	feedback_set_details("round_end_result",round_finished)

	switch(round_finished)
		if(MODE_INFESTATION_X_MAJOR)
			world << "<span class='round_body'>The aliens have successfully wiped out the marines and will live to spread the infestation!</span>"
			if(prob(50)) 	world << 'sound/misc/Game_Over_Man.ogg'
			else 			world << 'sound/misc/asses_kicked.ogg'
		if(MODE_INFESTATION_H_MAJOR)
			world << "<span class='round_body'>The marines managed to wipe out the aliens and stop the infestation!</span>"
			if(prob(50)) 	world << 'sound/misc/hardon.ogg'
			else			world << 'sound/misc/hell_march.ogg'
		if(MODE_INFESTATION_X_MINOR)
			world << "<span class='round_body'>The Sulaco has been evacuated...but the infestation remains!</span>"
		if(MODE_INFESTATION_H_MINOR)
			world << "<span class='round_body'>The Marines have killed the Xenomorph queen but were unable to finish off the hive!</span>"
		if(MODE_INFESTATION_DRAW_NUKE)
			world << "<span class='round_body'>The station has blown by a nuclear fission device... there are no winners!</span>"
			world << 'sound/misc/sadtrombone.ogg'
		if(MODE_INFESTATION_DRAW_DEATH)
			world << "<span class='round_body'>Both the marines and the aliens have been terminated. At least the infestation has been eradicated!</span>"
			world << 'sound/misc/sadtrombone.ogg'
		else world << "<span class='round_body'>Whoops, something went wrong with declare_completion(), blame the coders!</span>"

	var/living_player_list[] = count_humans_and_xenos()
	var/dat = "Xenomorphs remaining: [living_player_list[2]]. Humans remaining: [living_player_list[1]]."
	if(round_stats) round_stats << "[round_finished]\n[dat]\nRound time: [duration2text()]\nRound population: [clients.len][log_end]" // Logging to data/logs/round_stats.log

	world << dat
	declare_completion_announce_predators()
	declare_completion_announce_xenomorphs()
	declare_completion_announce_survivors()
	return 1

/datum/game_mode/proc/declare_completion_announce_predators()
	set waitfor = 0
	sleep(45)
	if(xenomorphs.len)
		var/dat = "<span class='round_body'>The xenomorph Queen(s) were:</span>"
		var/mob/M
		for(var/datum/mind/X in xenomorphs)
			if(istype(X))
				M = X.current
				if(!M || !M.loc) M = X.original
				if(M && M.loc && istype(M,/mob/living/carbon/Xenomorph/Queen)) dat += "<br>[X.key] was [M] <span class='boldnotice'>([M.stat == DEAD? "DIED":"SURVIVED"])</span>"

		world << dat

/datum/game_mode/proc/declare_completion_announce_xenomorphs()
	set waitfor = 0
	sleep(45)
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

/datum/game_mode/proc/declare_completion_announce_survivors()
	set waitfor = 0
	sleep(45)
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

/datum/game_mode/proc/announce_bioscans()
	var/list/activeXenos = list() //We'll announce to them later.
	var/numHostsPlanet 	= 0
	var/numHostsShip 	= 0
	var/numXenosPlanet 	= 0
	var/numXenosShip 	= 0

	for(var/mob/M in living_mob_list) //Scan through and detect Xenos and Hosts
		if(isXeno(M))
			switch(M.z)
				if(3,4) numXenosShip++ //On the ship.
				else	numXenosPlanet++ //Elsewhere.
			activeXenos += M

		if(ishuman(M) && !isYautja(M))
			switch(M.z)
				if(3,4) numHostsShip++ //On the ship.
				else	numHostsPlanet++ //Elsewhere.

	// The announcement to all Xenos. Slightly off for the human ship, accurate otherwise.
	for(var/mob/M in activeXenos)
		M << sound(get_sfx("queen"),wait=0,volume=50)
		M << "<br><br><h1 style='color:red'>The Queen Mother reaches into your mind from worlds away...</h1>"
		M << "<h2 style='color:red'>To my children and their queen... I sense approximately [ max(0,numHostsShip + rand(-2,2)) ] host\s in the metal hive and [numHostsPlanet? "[numHostsPlanet]" : "none"] scattered elsewhere...</h2>"

	// The announcement to all Humans. Slightly off for the planet and elsewhere, accurate for the ship.
	var/name = "M.O.T.H.E.R. Bioscan Status"
	var/input = "Bioscan complete.\n\nSensors indicate [numXenosShip?"[numXenosShip]":"no"] unknown lifeform signature[!numXenosShip||numXenosShip>1?"s":""] present on the ship and approximately [ max(0,numXenosPlanet + rand(-2,2)) ] signature\s located elsewhere."
	command_announcement.Announce(input, name, new_sound = 'sound/AI/commandreport.ogg')

	log_admin("A bioscan/Queen Mother message has completed. Humans: [numHostsPlanet] on the planet and [numHostsShip] on the ship. Xenos: [numXenosPlanet] on the planet and [numXenosShip] on the ship.")
	message_admins("A bioscan/Queen Mother message has completed. Humans: [numHostsPlanet] on the planet and [numHostsShip] on the ship. Xenos: [numXenosPlanet] on the planet and [numXenosShip] on the ship.", 1)

/*
Count up surviving humans and aliens.
Can't be in a locker, in space, in the thunderdome, or distress.
Only checks living mobs with a client attached.
*/
/datum/game_mode/proc/count_humans_and_xenos()
	var/num_humans = 0
	var/num_xenos = 0
	var/area/A

	for(var/mob/M in living_mob_list)
		A = get_area(M.loc)
		if(M.z && !istype(M.loc,/turf/space) && !istype(A,/area/centcom) && !istype(A,/area/tdome) && !istype(A,/area/shuttle/distress_start))
			if(ishuman(M) && !isYautja(M) && !(M.status_flags & XENO_HOST))
				num_humans++
			else if(isXeno(M))
				num_xenos++

	return list(num_humans,num_xenos)

#undef QUEEN_DEATH_COUNTDOWN

#undef MODE_INFESTATION_X_MAJOR
#undef MODE_INFESTATION_H_MAJOR
#undef MODE_INFESTATION_X_MINOR
#undef MODE_INFESTATION_H_MINOR
#undef MODE_INFESTATION_DRAW_NUKE
#undef MODE_INFESTATION_DRAW_DEATH