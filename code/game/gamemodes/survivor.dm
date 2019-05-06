GLOBAL_LIST_EMPTY(gamemode_survivor_key_items)

/*
SPAWNS
*/
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

    var/player_size

    var/init_human_size = 0
    var/init_xeno_size = 0

    var/xeno_ratio = 0.35 // ratio of xeno to humans

    var/list/humans = list()
    var/list/xenos = list()

    var/list/key_items = list(
        /obj/item/beacon/rescue,
        /obj/item/tool/weldingtool,
    )
    var/list/key_items_medpop = list( 
        /obj/item/cell/high,
    )
    var/list/key_items_highpop = list(
        /obj/item/laptop/rescue,
    )

    var/list/random_items = list(
        /obj/item/cell,
        /obj/item/cell,
    )

    var/obj/item/beacon/beacon = null
    var/last_beacon_announce = 0


/datum/game_mode/survivor/new_player_topic(mob/M, href, href_list[])
    switch(href_list["lobby_choice"])
        if("late_join_survivor")
            var/datum/mind/new_human = M
            new_human.assigned_role = ROLE_SURVIVOR
            humans += new_human
            transform_survivor(new_human, TRUE)
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
    to_chat(world, "<br><hr><br>")
    to_chat(world, "<h3> TL;DR Advice while testing </h3>")
    to_chat(world, "<b>Difficulty changes as pop goes up, breakpoints are around high (15+) med (10-15) low (10-0). </b><br>")
    to_chat(world, "<b>Humans start with a pinpointer, use this to find the key items needed.</b><br>")
    to_chat(world, "<b>Xenos are expected to assault humans as soon as possible, humans just need to place a beacon and defend it.</b><br>")
    to_chat(world, "<b>Xenos work just like in distress nothing special here.</b><br>")
    to_chat(world, "<b>Humans do not yet have a way to communicate, ideally radios will be found and used. (not yet implemented)</b><br>")

/datum/game_mode/survivor/setup()
    
    for(var/i in xenos)
        var/datum/mind/M = i
        if(M.assigned_role == ROLE_XENO_QUEEN)
            transform_queen(M)
        else
            transform_xeno(M)

    for(var/i in humans)
        var/datum/mind/M = i
        transform_survivor(M)

    return TRUE

/datum/game_mode/survivor/post_setup()
    . = ..()

    // Transfer everyone to their bodies and delete existing
    for(var/mob/new_player/player in GLOB.mob_list)
        var/mob/living = player.transfer_character()
        if(living)
            qdel(player)
            
    spawn_mission_items()

/datum/game_mode/survivor/proc/calculate_team_sizes()
    init_xeno_size = max(CEILING(GLOB.ready_players * xeno_ratio, 1), 1)
    init_human_size = GLOB.ready_players - init_xeno_size

    message_admins("calculate_team_sizes::\nhuman: [init_human_size]\nxeno: [init_xeno_size]")
    return TRUE // TODO: Remove this line, TRUE is DEBUG CODE.
    // return (init_human_size > 0 && init_xeno_size > 0)

/datum/game_mode/survivor/proc/assign_players()
    var/list/possible_xeno_queens = get_players_for_role(BE_QUEEN)
    var/list/possible_xenos = get_players_for_role(BE_ALIEN)
    var/list/possible_humans = get_players_for_role(BE_SURVIVOR)

    for(var/I in possible_xeno_queens)
        var/datum/mind/new_xeno = I

        new_xeno.assigned_role = ROLE_XENO_QUEEN
        xenos += new_xeno

        possible_humans -= I
        possible_xeno_queens -= I
        possible_xenos -= I
        // We only need 1 queen
        break

    for(var/I in possible_humans)
        var/datum/mind/new_surivor = I

        humans += new_surivor

        possible_humans -= I
        possible_xeno_queens -= I
        possible_xenos -= I
        if(length(humans) >= init_human_size)
            break

    for(var/I in possible_xenos)
        var/datum/mind/new_xeno = I

        new_xeno.assigned_role = ROLE_XENOMORPH
        xenos += new_xeno

        possible_humans -= I
        possible_xeno_queens -= I
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


/datum/game_mode/survivor/proc/transform_survivor(datum/mind/M, late_join = FALSE)
    var/mob/living/carbon/human/H = new (pick(GLOB.survivor_spawn_human))

    if(isnewplayer(M.current))
        var/mob/new_player/N = M.current
        N.close_spawn_windows()
        N.new_character = H

    M.transfer_to(H, TRUE)
    H.client.prefs.copy_to(H)

    var/survivor_job = pick(subtypesof(/datum/job/survivor))
    var/datum/job/J = new survivor_job

    if(SSmapping.config.map_name == MAP_ICE_COLONY)
        H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(H), SLOT_HEAD)
        H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/snow_suit(H), SLOT_WEAR_SUIT)
        H.equip_to_slot_or_del(new /obj/item/clothing/shoes/snow(H), SLOT_SHOES)

    var/role_guide

    switch(/*rand(0, 100)*/ 55)
        if (0 to 25)
            // Builder 
            H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), SLOT_GLASSES)
            H.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/full(H), SLOT_R_STORE)
            role_guide = "You have extra building equipment, use the metal and tools to create defenses. You won't know you'll need it until its too late..."
        if (25 to 50)
            // Medic
            H.equip_to_slot_or_del(new /obj/item/storage/pouch/survival/full(H), SLOT_L_STORE)
            role_guide = "You have extra medical supplies, that could be useful if you or someone else gets hurt..."
        if (50 to 75)
            // Fighter
            H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/smg/mp7(H), SLOT_L_STORE)
            H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/mp7(H), SLOT_R_HAND)
            role_guide = "You have found a weapon! Hope you don't have to use it too soon..."
        if (75 to 100)
            // Scav
            H.equip_to_slot_or_del(new /obj/item/pinpointer(H), SLOT_R_HAND)
            H.equip_to_slot_or_del(new /obj/item/radio/marine(H), SLOT_L_HAND)
            role_guide = "You have a radio and pinpointer! Maybe this will lead you to what you need most..."

    // Equip job based items last to not conflict with gamemode items.
    H.set_rank(J.title)
    J.equip(H)

    H.mind.assigned_role = "Survivor"

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
    to_chat(H, "<span class='caption'>[role_guide]</span>")


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

    for (var/key_item in all_key_items)
        GLOB.gamemode_survivor_key_items += new key_item(pick(GLOB.survivor_spawn_key_item)) 

    for (var/random_item in random_items)
        new random_item(pick(GLOB.survivor_spawn_random_item)) 


/datum/game_mode/survivor/process()
    if(round_finished)
        return FALSE

    if(beacon)
        if(!beacon.anchored)
            return
        if (world.time - last_beacon_announce > 1 MINUTES)
            return
        annouce_beacon_location()


/datum/game_mode/survivor/proc/annouce_beacon_location()
    var/area/beacon_area = get_area(beacon)

    for(var/i in GLOB.alive_xeno_list)
        var/mob/M = i
        SEND_SOUND(M, sound(get_sfx("queen"), wait = 0, volume = 50))
        to_chat(M, "<span class='xenoannounce'>The Queen Mother reaches into your mind from worlds away.</span>")
        to_chat(M, "<span class='xenoannounce'>To my children and their Queen. I sense the humans reaching out for aid in \the [beacon_area] to the [dir2text(get_dir(M, beacon_area))]. Find their mechanical device and destroy it!</span>")


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