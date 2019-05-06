GLOBAL_LIST_EMPTY(gamemode_survivor_key_items)

/*
SPAWNS
*/
/obj/effect/landmark/survivor/spawn/queen_ovi/Initialize()
    . = ..()
    GLOB.survivor_spawn_human += loc
    flags_atom |= INITIALIZED
    return INITIALIZE_HINT_QDEL

/obj/effect/landmark/survivor/spawn/human/Initialize()
    . = ..()
    GLOB.survivor_spawn_human += loc
    flags_atom |= INITIALIZED
    return INITIALIZE_HINT_QDEL


/obj/effect/landmark/survivor/spawn/random_items/Initialize()
    . = ..()
    GLOB.survivor_spawn_random_item += loc
    flags_atom |= INITIALIZED
    return INITIALIZE_HINT_QDEL


/obj/effect/landmark/survivor/spawn/key_items/Initialize()
    . = ..()
    GLOB.survivor_spawn_key_item += loc
    flags_atom |= INITIALIZED
    return INITIALIZE_HINT_QDEL


/datum/game_mode/survivor
    name = "Survivor"
    config_tag = "Survivor"
    required_players = 1

    var/player_size // used to balance the gamemode. (= lowpop, medpop, highpop)
    var/init_human_size 
    var/init_xeno_size 

    var/list/humans = list()
    var/list/xenos = list()
    
    var/obj/item/beacon/beacon = null
    var/last_beacon_announce = 0

    // Configuration
    var/late_join_time = 5 MINUTES // this is late join for survivors
    var/xeno_min = 2 // absolute min amount of xenos
    var/xeno_ratio = 0.35 // otherwise fill to ratio of xeno to humans

    var/list/key_items = list( // Beacon requires repair at lowpop
        /obj/item/beacon/rescue,
        /obj/item/tool/weldingtool,
    )
    var/list/key_items_medpop = list( // Medpop requires a working cell 
        /obj/item/cell/high,
    )
    var/list/key_items_highpop = list( // Highpop requires the laptop
        /obj/item/laptop/rescue,
    )

    var/list/random_items = list() // Use to add more random items to the map



/datum/game_mode/survivor/new_player_topic(mob/M, href, href_list[])
    switch(href_list["lobby_choice"])
        if("late_join_survivor")
            if (world.time > (SSticker.round_start_time + late_join_time))
                to_chat(src, "<span class='warning'>It's too late to join this round.</span>")
                return

            if (!M.mind)
                M.mind = new
            M.mind.assigned_role = ROLE_SURVIVOR
            M.mind.late_joiner = TRUE
            humans +=  M.mind
            transform_survivor( M.mind, TRUE)
            return TRUE

    return ..()


/datum/game_mode/survivor/pre_setup()
    . = ..()

    if (!scale_player_size())
        message_admins("failed to scale_player_size()")
        return FALSE
    if (!calculate_team_sizes())
        message_admins("failed to calculate_team_sizes()")
        return FALSE
    if (!assign_players())
        message_admins("failed to assign_players()")
        return FALSE
    if (!adjust_map())
        message_admins("failed to adjust_map()")
        return FALSE

    return TRUE

/datum/game_mode/survivor/announce()
    to_chat(world, "<br><b>The current game mode is - Survivor!</b>")
    to_chat(world, "<b>Find all the parts required to setup a distress beacon and get the fuck out of there!</b><br>")
    // TODO: Debug code
    to_chat(world, "<br><hr><br>")
    to_chat(world, "<h3> TL;DR Advice while testing </h3>")
    to_chat(world, "<b>Difficulty changes as pop goes up, breakpoints are around high (15+) med (10-15) low (10-0). </b><br>")
    to_chat(world, "<b>Humans start with different gearsets. Group up and work together to find the key items needed.</b><br>")
    to_chat(world, "<b>Some humans spawn with radios, you can find more in the world</b><br>")
    to_chat(world, "<b>Xenos are expected to assault humans as soon as possible, humans just need to place a beacon and defend it.</b><br>")
    to_chat(world, "<b>Xenos work just like in distress nothing special here.</b><br>")
    to_chat(world, "<b>Xenos can break the beacon to interrupt the timer, it will restart where it left off.</b><br>")
    to_chat(world, "<span class='boldnotice'>Send your feedback to PsyKzz</span><br>")

/datum/game_mode/survivor/setup()
    
    for(var/i in xenos)
        var/datum/mind/M = i
        transform_xeno(M)

    for(var/i in humans)
        var/datum/mind/M = i
        transform_survivor(M)

    return TRUE


/datum/game_mode/survivor/post_setup()
    . = ..()

    spawn_queen_in_ovi()
    
    // Transfer everyone to their bodies and delete existing
    for(var/mob/new_player/player in GLOB.mob_list)
        var/mob/living = player.transfer_character()
        if(living)
            qdel(player)
            
    spawn_mission_items()

/datum/game_mode/survivor/proc/calculate_team_sizes()
    init_xeno_size = max(CEILING(GLOB.ready_players * xeno_ratio, 1), 1)
    init_human_size = GLOB.ready_players - init_xeno_size

    return TRUE
    // We might not require the exact size if we want to allow late joins, this should just be an admin though delaying to start until ready.
    // return (init_human_size > 0 && init_xeno_size > 0)

/datum/game_mode/survivor/proc/assign_players()
    var/list/possible_xenos = get_players_for_role(BE_ALIEN)
    var/list/possible_humans = get_players_for_role(BE_SURVIVOR)


    for(var/I in possible_humans)
        var/datum/mind/new_surivor = I

        humans += new_surivor

        possible_humans -= I
        // possible_xeno_queens -= I
        possible_xenos -= I
        if(length(humans) >= init_human_size)
            break

    for(var/I in possible_xenos)
        var/datum/mind/new_xeno = I

        new_xeno.assigned_role = ROLE_XENOMORPH
        xenos += new_xeno

        possible_humans -= I
        // possible_xeno_queens -= I
        possible_xenos -= I
        if(length(xenos) >= init_xeno_size)
            break

    return TRUE


/datum/game_mode/survivor/proc/scale_player_size()
    if (GLOB.ready_players > 15)
        player_size = HIGH_POP
    else if (GLOB.ready_players > 10)
        player_size = MED_POP
    else 
        player_size = LOW_POP

    // TODO: debug code for now, while people are working things out, high pop works best
    player_size = HIGH_POP
    return TRUE


/datum/game_mode/survivor/proc/adjust_map()
    // TODO: Replace this with a loop through area's instead
    /*
    for (var/area/A in GLOB.sortedAreas)
        var/obj/machinery/power/apc/A = A.apc
        var/ratio = rand(0, 100)
        switch (player_size)
            if(HIGH_POP)
                ratio = rand(5,50)
            if(MED_POP)
                ratio = rand(25,50)
            if(LOW_POP)
                ratio = rand(50,100)
        A.cell.charge = A.cell.maxcharge * (ratio / 100)
    */

    for (var/I in GLOB.machines)
        if (istype(I, /obj/machinery/door))
            var/obj/machinery/door/airlock/A = I
            A.req_access = null
            A.req_access_txt = null
            A.req_one_access = null
            A.req_one_access_txt = null

        // Charge every apc across the map
        if (isAPC(I))
            var/obj/machinery/power/apc/A = I
            var/ratio = rand(0, 100)
            switch (player_size)
                if(HIGH_POP)
                    ratio = rand(5,50)
                if(MED_POP)
                    ratio = rand(25,50)
                if(LOW_POP)
                    ratio = rand(50,100)
            A.cell.charge = A.cell.maxcharge * (ratio / 100)

    return TRUE


/datum/game_mode/survivor/proc/transform_xeno(datum/mind/M)
    var/mob/living/carbon/Xenomorph/Larva/X = new (pick(GLOB.xeno_spawn))

    if(isnewplayer(M.current))
        var/mob/new_player/N = M.current
        N.close_spawn_windows()
        N.new_character = X

    M.transfer_to(X, TRUE)

    to_chat(X, "<B>You are now an alien!</B>")
    to_chat(X, "<B>Your job is to spread the hive and protect the Queen. If there's no Queen, you can become the Queen yourself by evolving into a drone.</B>")
    to_chat(X, "Talk in Hivemind using <strong>;</strong> (e.g. ';My life for the queen!')")

    X.update_icons()


/datum/game_mode/survivor/proc/transform_queen(datum/mind/M)
    // var/mob/living/carbon/Xenomorph/Queen/X = new (pick(GLOB.survivor_spawn_xeno))
    var/mob/living/carbon/Xenomorph/Queen/X = new (pick(GLOB.xeno_spawn))

    if(isnewplayer(M.current))
        var/mob/new_player/N = M.current
        N.close_spawn_windows()
        N.new_character = X

    M.transfer_to(X, TRUE)

    to_chat(X, "<B>You are now the alien queen!</B>")
    to_chat(X, "<B>Your job is to spread the hive.</B>")
    to_chat(X, "Talk in Hivemind using <strong>;</strong> (e.g. ';My life for the hive!')")

    X.update_icons()


/datum/game_mode/survivor/proc/spawn_queen_in_ovi()
    var/mob/living/carbon/Xenomorph/Queen/Q = new (pick(GLOB.xeno_spawn))
    Q.ovipositor = TRUE
    Q.away_time = 0 // queen so they can't be taken by late joins


/datum/game_mode/survivor/proc/transform_survivor(datum/mind/M, late_join = FALSE)
    var/mob/living/carbon/human/H = new (pick(GLOB.survivor_spawn_human))

    if(isnewplayer(M.current))
        var/mob/new_player/N = M.current
        N.close_spawn_windows()
        N.new_character = H

    M.transfer_to(H, TRUE)
    H.client.prefs.copy_to(H)

    var/job_title
    var/role_guide
    var/survivor_job = pick(subtypesof(/datum/job/survivor))

    switch(rand(0, 100))
        if (0 to 25)
            survivor_job = /datum/job/survivor/atmos
            job_title = SURVIVOR_BUILDER
            role_guide = "You have extra building equipment, use the metal and tools to create defenses. You won't know you'll need it until its too late..."
        if (25 to 50)
            survivor_job = /datum/job/survivor/doctor
            job_title = SURVIVOR_MEDIC
            role_guide = "You have extra medical supplies, that could be useful if you or someone else gets hurt..."
        if (50 to 75)
            survivor_job = /datum/job/survivor/security
            job_title = SURVIVOR_FIGHTER
            role_guide = "You have found a weapon! Hope you don't have to use it too soon..."
        if (75 to 100)
            job_title = SURVIVOR_SCAV
            role_guide = "You have a radio and pinpointer! Maybe this will lead you to what you need most..."

    var/datum/job/J = new survivor_job

    H.set_rank(J.title)
    H.mind.cm_skills = null // Remove skill requirements
    J.equip(H)

    if(SSmapping.config.map_name == MAP_ICE_COLONY)
        H.equip_to_slot(new /obj/item/clothing/head/ushanka(H), SLOT_HEAD)
        H.equip_to_slot(new /obj/item/clothing/mask/rebreather(H), SLOT_WEAR_MASK)
        H.equip_to_slot(new /obj/item/clothing/suit/storage/snow_suit(H), SLOT_WEAR_SUIT)
        H.equip_to_slot(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
        H.equip_to_slot(new /obj/item/clothing/shoes/snow(H), SLOT_SHOES)

    switch(job_title)
        if (SURVIVOR_BUILDER)
            H.equip_to_slot(new /obj/item/clothing/suit/storage/snow_suit/engineer(H), SLOT_WEAR_SUIT)
            H.equip_to_slot(new /obj/item/clothing/glasses/welding(H), SLOT_GLASSES)
            H.equip_to_slot(new /obj/item/storage/pouch/survival/full(H), SLOT_L_STORE)
            H.equip_to_slot(new /obj/item/storage/pouch/tools/full(H), SLOT_R_STORE)
        if (SURVIVOR_MEDIC)
            H.equip_to_slot(new /obj/item/clothing/suit/storage/snow_suit/doctor(H), SLOT_WEAR_SUIT)
            H.equip_to_slot(new /obj/item/storage/pouch/firstaid/full(H), SLOT_L_STORE)
            H.equip_to_slot(new /obj/item/healthanalyzer(H), SLOT_R_STORE)
        if (SURVIVOR_FIGHTER)
            H.equip_to_slot(new /obj/item/storage/pouch/magazine/smg/ppsh(H), SLOT_R_STORE)
            H.equip_to_slot(new /obj/item/weapon/gun/smg/ppsh(H), SLOT_R_HAND)
        if (SURVIVOR_SCAV)
            H.equip_to_slot(new /obj/item/pinpointer(H), SLOT_R_STORE)
            H.equip_to_slot(new /obj/item/radio/marine(H), SLOT_L_STORE)

    H.mind.assigned_role = ROLE_SURVIVOR

    to_chat(H, "<h2>You are a survivor!</h2>")
    switch(SSmapping.config.map_name)
        if(MAP_PRISON_STATION)
            to_chat(H, "<span class='notice'>You are a survivor of the attack on Fiorina Orbital Penitentiary. You worked or lived on the prison station, and managed to avoid the alien attacks.. until now.</span>")
        if(MAP_ICE_COLONY)
            to_chat(H, "<span class='notice'>You are a survivor of the attack on the ice habitat. You worked or lived on the colony, and managed to avoid the alien attacks.. until now.</span>")
        if(MAP_BIG_RED)
            to_chat(H, "<span class='notice'>You are a survivor of the attack on the colony. You worked or lived in the archaeology colony, and managed to avoid the alien attacks...until now.</span>")
        if(MAP_LV_624)
            to_chat(H, "<span class='notice'>You are a survivor of the attack on the colony. You suspected something was wrong and tried to warn others, but it was too late...</span>")
        else
            to_chat(H, "<span class='notice'>Through a miracle you managed to survive the attack. But are you truly safe now?</span>")
    to_chat(H, "<span class='boldnotice'>[role_guide]</span>")


/datum/game_mode/survivor/attempt_to_join_as_larva(mob/xeno_candidate)
    var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
    return HS.can_spawn_larva(xeno_candidate)

/datum/game_mode/survivor/spawn_larva(mob/xeno_candidate)
    var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
    return HS.spawn_larva(xeno_candidate)

/datum/game_mode/survivor/proc/spawn_mission_items()
    GLOB.survivor_spawn_key_item = shuffle(GLOB.survivor_spawn_key_item)
    GLOB.survivor_spawn_random_item = shuffle(GLOB.survivor_spawn_random_item)
    var/list/all_key_items = key_items 

    if(player_size == MED_POP)
        all_key_items += key_items_medpop
    if(player_size == HIGH_POP)
        all_key_items += key_items_medpop + key_items_highpop

    if (length(GLOB.survivor_spawn_key_item))
        for (var/key_item in all_key_items)
            GLOB.gamemode_survivor_key_items += new key_item(pick(GLOB.survivor_spawn_key_item)) 
    if (length(GLOB.survivor_spawn_random_item))
        for (var/random_item in random_items)
            new random_item(pick(GLOB.survivor_spawn_random_item)) 


/datum/game_mode/survivor/process()
    if(round_finished)
        return FALSE

    if(beacon)
        if(!beacon.anchored)
            return
        if (world.time - last_beacon_announce < 2 MINUTES)
            return
        annouce_beacon_location()


/datum/game_mode/survivor/proc/annouce_beacon_location()
    last_beacon_announce = world.time
    var/area/beacon_area = get_area(beacon.loc)
    for(var/i in GLOB.alive_xeno_list)
        var/mob/M = i
        SEND_SOUND(M, sound(get_sfx("queen"), wait = 0, volume = 50))
        to_chat(M, "<span class='xenoannounce'>The Queen Mother reaches into your mind from worlds away.</span>")
        to_chat(M, "<span class='xenoannounce'>To my children and their Queen. I sense the humans reaching out for aid in \the [beacon_area] to the [dir2text(get_dir(M, beacon))]. Find their mechanical device and destroy it!</span>")


/datum/game_mode/survivor/proc/count_team_alive(list/team)
    var/count = 0
    for(var/mob/M in team)
        if(!M.client && !isaghost(M))
            continue
        if (ishuman(M))
            var/mob/living/carbon/human/H = M
            if(CHECK_BITFIELD(H.status_flags, XENO_HOST))
                continue
        if(M.stat != CONSCIOUS)
            continue
        count++
    return count


/datum/game_mode/survivor/check_finished()
    var/H = count_team_alive(GLOB.alive_human_list)
    var/X = count_team_alive(GLOB.alive_xeno_list)
    if (round_finished)
        return TRUE

    if(H == 0 && X == 0)
        round_finished = GAMEMODE_SURIVOR_DRAW
        return TRUE
    else if(H > 0 && X == 0)
        round_finished = GAMEMODE_SURIVOR_HUMAN_WIN
        return TRUE
    else if(H == 0 && X > 0)
        round_finished = GAMEMODE_SURIVOR_XENO_WIN
        return TRUE
    return FALSE

/datum/game_mode/survivor/declare_completion()
    if (round_finished == GAMEMODE_SURIVOR_DRAW)
        return
    else
        to_chat(world, "<span class='round_header'> >> [round_finished] << </span>")
        log_game("Humans remaining: [length(GLOB.alive_human_list)]\nXenos remaining: [length(GLOB.alive_xeno_list)]\nRound time: [duration2text()]")
    
    return TRUE