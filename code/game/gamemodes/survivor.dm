#define GAMEMODE_SURIVOR_DRAW "DRAW"
#define GAMEMODE_SURIVOR_HUMAN_WIN "HUMAN WIN"
#define GAMEMODE_SURIVOR_XENO_WIN "XENO WIN"
#define HIGH_POP "HIGH_POP"
#define MED_POP "MED_POP"
#define LOW_POP "LOW_POP"

// TODO: Move shit to their own file.

/*
 Items
*/
/obj/item/laptop/rescue
    name = "Communications laptop"
    desc = "A small device used for augmenting communication. Someone seems to have left it logged in with open communications to a nearby ship."
    w_class = WEIGHT_CLASS_BULKY
    // icon = 'icons/obj/machines/computer.dmi'
    // icon_state = "comm_traffic"
    icon = 'icons/obj/machines/computer3.dmi'
    icon_state = "tracking_laptop"

    var/activation_time = 5 SECONDS

/obj/item/laptop/rescue/Initialize()
    . = ..()
    SetLuminosity(1)

/obj/item/laptop/rescue/Destroy()
    SetLuminosity(0)
    return ..()

/obj/item/laptop/rescue/attack_self(mob/user)
    if(anchored)
        to_chat(user, "<span class='warning'>It's already been anchored. Just leave it.</span>")
        return

    if(!ishuman(user)) 
        return

    if(!user.mind)
        to_chat(user, "<span class='warning'>It doesn't seem to do anything for you.</span>")
        return

    var/area/A = get_area(user)
    if(A && istype(A) && A.ceiling >= CEILING_METAL)
        to_chat(user, "<span class='warning'>You have to be outside or under a glass ceiling to activate this.</span>")
        return

    user.visible_message("<span class='notice'>[user] starts setting up [src] on the ground.</span>",
    "<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
    if(do_after(user, activation_time, TRUE, 5, BUSY_ICON_FRIENDLY))
        user.transferItemToLoc(src, user.loc)
        anchored = 1
        w_class = 10

/obj/item/beacon/rescue
    name = "Rescue beacon"
    desc = "A rugged, glorified laser pointer capable of sending a beam into space. Activate and throw this to call for someone to rescue you."
    icon_state = "motion0"
    w_class = WEIGHT_CLASS_BULKY

    var/activated = 0
    var/activation_time = 10 SECONDS
    var/icon_activated = "motion2"

    var/distress_timer = 10 SECONDS
    var/required_components

    var/required_nearby

    // For when it broken, we spit everything out again
    var/internal_components = list()

    // It can't be destroyed but it can be stopped by reducing health to 0
    var/max_hp = 100
    var/current_hp = 0

/obj/item/beacon/rescue/Initialize()
    if(!issurvivorgamemode(SSticker.mode))
        return

    var/datum/game_mode/survivor/GM = SSticker.mode
    switch (GM.player_size)
        if(MED_POP)
            required_components = list(
                /obj/item/cell,
            )
        if(HIGH_POP)
            required_components = list(
                /obj/item/cell,
            )
            required_nearby = list(
                /obj/item/laptop/rescue,
            )
    return ..()


/obj/item/beacon/rescue/Destroy()
    SetLuminosity(0)
    return ..()

/obj/item/beacon/rescue/examine()
    . = ..() // show parent examines (if any) first
    if (current_hp < max_hp)
        var/integrity = health / max_hp * 100
        switch(integrity)
            if(85 to 100)
                to_chat(usr, "It's fully intact.")
            if(65 to 85)
                to_chat(usr, "It's slightly damaged.")
            if(45 to 65)
                to_chat(usr, "It's badly damaged.")
            if(25 to 45)
                to_chat(usr, "It's heavily damaged.")
            else
                to_chat(usr, "It's falling apart.")
    if (length(required_components))
        to_chat(usr, "<span class='warning'>It looks like a few parts are missing.</span>")


/obj/item/beacon/rescue/proc/reset_state()
    anchored = 0
    activated = 0
    required_components = initial(required_components)
    
    // TODO: Handle if something is blocking the way to throw things
    for (var/I in internal_components)
        var/turf/T = get_step(src, pick(cardinal))
        if (T.obscured)
            usr.transferItemToLoc(I, src)
        else
            usr.transferItemToLoc(I, T)


/obj/item/beacon/rescue/attack_alien(mob/living/carbon/Xenomorph/M)
    M.animation_attack_on(src)
    current_hp -= rand(15, 30)
    if(health <= 0)
        M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
        "<span class='danger'>You slice [src] apart!</span>", null, 5)
        reset_state()
    else
        M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
        "<span class='danger'>You slash [src]!</span>", null, 5)
    playsound(loc, "alien_claw_metal", 25, 1)
    if(prob(10))
        new /obj/effect/decal/cleanable/blood/oil(src.loc)
    

// TODO: Handle other click types (altclick etc)
/obj/item/beacon/rescue/attackby(obj/item/W as obj, mob/user as mob)
    if(!anchored || activated)
        return

    // Install components
    for (var/R in required_components)
        if (istype(W, R))
            var/obj/item/cell/C = W
            if (C.charge < 2000)
                to_chat(user, "<span class='warning'>\The [C] doesn't have enough charge!</span>")
                return
            if (user.transferItemToLoc(W, src))
                required_components -= R
                internal_components += W
                user.visible_message("<span class='notice'>[user] installed \the [C]</span>","<span class='notice'>You installed \the [C]</span>")
                break

    // repair dmg
    if(iswelder(W) && current_hp < max_hp)
        var/obj/item/tool/weldingtool/WT = W
        if(WT.remove_fuel(0, user))
            user.visible_message("<span class='notice'>[user] started repairing \the [src]</span>","<span class='notice'>You started repairing \the [src]</span>")
            if(do_after(user, 1 SECONDS, TRUE, 5, BUSY_ICON_BUILD,, TRUE))
                playsound(get_turf(src), 'sound/items/Welder2.ogg', 25, 1)
                current_hp = min(current_hp + 25, max_hp)
    else if(iswelder(W) && current_hp == max_hp)
        to_chat(user, "That doesn't look damaged!")

    // Required Nearby components
    // TODO: This seems wasteful.
    var/nearby_setup = 0
    for (var/R in required_nearby)
        var/obj/found = locate(R) in range(2, src)
        if (found && found.anchored == 1)
            nearby_setup++

    if(length(required_components) == 0 && current_hp == max_hp && nearby_setup == length(required_nearby))
        activate_beacon(user)

/obj/item/beacon/rescue/proc/activate_beacon(mob/user as mob)
    icon_state = "[icon_activated]"
    playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
    user.visible_message("<span class='notice'>[user] activates [src]</span>", "<span class='notice'>You activate [src]</span>")
    activated = 1
    SetLuminosity(1)

    addtimer(CALLBACK(src, .proc/make_noise), 3 SECONDS, TIMER_LOOP)
    addtimer(CALLBACK(src, .proc/call_distress_team), distress_timer, TIMER_UNIQUE)

/obj/item/beacon/rescue/attack_self(mob/user)
    if(anchored)
        to_chat(user, "<span class='warning'>It's already been anchored. Just leave it.</span>")
        return

    if(!ishuman(user)) 
        return

    if(!user.mind)
        to_chat(user, "<span class='warning'>It doesn't seem to do anything for you.</span>")
        return

    var/area/A = get_area(user)
    if(A && istype(A) && A.ceiling >= CEILING_METAL)
        to_chat(user, "<span class='warning'>You have to be outside or under a glass ceiling to activate this.</span>")
        return

    user.visible_message("<span class='notice'>[user] starts setting up [src] on the ground.</span>",
    "<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
    if(do_after(user, activation_time, TRUE, 5, BUSY_ICON_FRIENDLY))
        user.transferItemToLoc(src, user.loc)
        anchored = 1
        w_class = 10
       

/obj/item/beacon/rescue/proc/make_noise()
    playsound(loc, 'sound/machines/twobeep.ogg', 15, 1)


/obj/item/beacon/rescue/proc/humans_win()
    SSticker.mode.round_finished = GAMEMODE_SURIVOR_HUMAN_WIN


/obj/item/beacon/rescue/proc/call_distress_team()
    var/datum/emergency_call/pmc/T = new
    T.mob_min = 5
    T.mob_max = length(GLOB.player_list) // everyone is allowed
    T.activate()
    addtimer(CALLBACK(src, .proc/humans_win), 5 MINUTES)


/*
SPAWNS
*/

/obj/effect/landmark/survivor/spawn/human/Initialize()
    . = ..()
    GLOB.survivor_spawn_human += loc
    flags_atom |= INITIALIZED
    return INITIALIZE_HINT_QDEL

/obj/effect/landmark/survivor/spawn/xeno/Initialize()
    . = ..()
    GLOB.survivor_spawn_xeno += loc
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

    var/xeno_ratio = 0.25 // ratio of xeno to humans

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


/datum/game_mode/survivor/post_setup()
    . = ..()

    for(var/i in xenos)
        var/datum/mind/M = i
        if(M.assigned_role == ROLE_XENO_QUEEN)
            transform_queen(M)
        else
            transform_xeno(M)

    for(var/i in humans)
        var/datum/mind/M = i
        transform_survivor(M)

    spawn_mission_items()

/datum/game_mode/survivor/proc/calculate_team_sizes()
    // TODO: Be smart?
    init_xeno_size = max(CEILING(GLOB.ready_players * xeno_ratio, 1), 1)
    init_human_size = GLOB.ready_players - init_xeno_size


    message_admins("calculate_team_sizes::\nhuman: [init_human_size]\nxeno: [init_xeno_size]")
    return TRUE
    // return (init_human_size > 0 && init_xeno_size > 0)

/datum/game_mode/survivor/proc/assign_players()
    var/list/possible_xeno_queens = get_players_for_role(BE_QUEEN)
    var/list/possible_xenos = get_players_for_role(BE_ALIEN)
    var/list/possible_humans = get_players_for_role(BE_SURVIVOR)
    for(var/I in possible_humans)
        var/datum/mind/new_surivor = I

        humans += new_surivor

        possible_humans -= I
        possible_xenos -= I
        if(length(humans) >= init_human_size)
            break

    for(var/I in possible_xeno_queens)
        var/datum/mind/new_xeno = I

        new_xeno.assigned_role = ROLE_XENO_QUEEN
        xenos += new_xeno

        possible_xenos -= I
        possible_humans -= I
        break

    for(var/I in possible_xenos)
        var/datum/mind/new_xeno = I

        new_xeno.assigned_role = ROLE_XENOMORPH
        xenos += new_xeno

        possible_xenos -= I
        possible_humans -= I
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

    for (var/I in world)
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
    var/mob/living/carbon/Xenomorph/Larva/X = new (pick(GLOB.survivor_spawn_xeno))

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
    var/mob/living/carbon/Xenomorph/Queen/X = new (pick(GLOB.survivor_spawn_xeno))

    if(isnewplayer(M.current))
        var/mob/new_player/N = M.current
        N.close_spawn_windows()
        N.new_character = X

    M.transfer_to(X, TRUE)

    to_chat(X, "<B>You are now the alien queen!</B>")
    to_chat(X, "<B>Your job is to spread the hive.</B>")
    to_chat(X, "Talk in Hivemind using <strong>;</strong> (e.g. ';My life for the hive!')")

    X.update_icons()


/datum/game_mode/survivor/proc/transform_survivor(datum/mind/M)
    var/mob/living/carbon/human/H = new (pick(GLOB.survivor_spawn_human))

    if(isnewplayer(M.current))
        var/mob/new_player/N = M.current
        N.close_spawn_windows()
        N.new_character = H

    M.transfer_to(H, TRUE)
    H.client.prefs.copy_to(H)

    var/survivor_job = pick(subtypesof(/datum/job/survivor))
    var/datum/job/J = new survivor_job

    H.set_rank(J.title)
    J.equip(H)

    H.mind.assigned_role = "Survivor"

    if(SSmapping.config.map_name == MAP_ICE_COLONY)
        H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(H), SLOT_HEAD)
        H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/snow_suit(H), SLOT_WEAR_SUIT)
        H.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather(H), SLOT_WEAR_MASK)
        H.equip_to_slot_or_del(new /obj/item/clothing/shoes/snow(H), SLOT_SHOES)
        H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)

    H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), SLOT_GLASSES)
    H.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/full(H), SLOT_R_STORE)
    H.equip_to_slot_or_del(new /obj/item/storage/pouch/survival/full(H), SLOT_L_STORE)

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



/datum/game_mode/survivor/proc/spawn_mission_items()
    var/list/all_key_items = key_items 

    if(player_size == MED_POP)
        all_key_items += key_items_medpop
    if(player_size == HIGH_POP)
        all_key_items += key_items_medpop + key_items_highpop

    for (var/key_item in all_key_items)
        new key_item(pick(GLOB.survivor_spawn_key_item)) 

    for (var/random_item in random_items)
        new random_item(pick(GLOB.survivor_spawn_random_item)) 


/datum/game_mode/survivor/proc/count_team_alive(list/team)
    var/count = 0
    for(var/mob/M in team)
        if(!M.client)
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