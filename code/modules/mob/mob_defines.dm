/mob
	name = "nameless mob"

	density = 1
	layer = MOB_LAYER
	animate_movement = 2
	datum_flags = DF_USE_TAG
	var/datum/mind/mind

	var/datum/click_intercept

	var/static/next_mob_id = 0

	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak
	var/obj/screen/hands = null //robot

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/zone_selected = "chest"

	var/use_me = 1 //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/damageoverlaytemp = 0
	var/computer_id = null //to track the players
	var/lastattacker = null
	var/lastattacked = null
	var/list/logging = list()
	var/atom/movable/interactee //the thing that the mob is currently interacting with (e.g. a computer, another mob (stripping a mob), manning a hmg)
	var/poll_answer = 0.0
	var/sdisabilities = 0	//Carbon
	var/disabilities = 0	//Carbon
	var/atom/movable/pulling = null
	var/next_move = null
	var/next_move_slowdown = 0	// Amount added during the next movement_delay(), then is reset.
	var/monkeyizing = null	//Carbon
	var/hand = null
	var/eye_blind = null	//Carbon
	var/eye_blurry = null	//Carbon
	var/ear_deaf = null		//Carbon
	var/ear_damage = null	//Carbon
	var/real_name = null
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""
	var/antitoxs = null
	var/sleeping = 0		//Carbon
	var/resting = 0			//Carbon
	var/lying = 0
	var/lying_prev = 0
	var/canmove = 1
	var/lastpuke = 0
	var/unacidable = 0
	var/mob_size = MOB_SIZE_HUMAN
	var/list/embedded = list()          // Embedded items, since simple mobs don't have organs.
	var/list/languages = list()         // For speaking/listening.
	var/list/speak_emote = list("says") // Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	var/emote_type = 1		// Define emote default type, 1 for seen emotes, 2 for heard emotes

	var/name_archive //For admin things like possession

	var/luminosity_total = 0 //For max luminosity stuff.

	var/timeofdeath = 0.0//Living

	var/turf/listed_turf = null	//the current turf being examined in the stat panel

	var/bodytemperature = 310.055	//98.7 F
	var/old_x = 0
	var/old_y = 0
	var/drowsyness = 0.0//Carbon
	var/dizziness = 0//Carbon
	var/jitteriness = 0//Carbon
	var/is_floating = 0
	var/floatiness = 0
	var/charges = 0.0
	var/nutrition = 400.0//Carbon

	var/specset //Simple way to track which set has the player taken

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/knocked_out = 0.
	var/stunned = 0
	var/frozen = 0
	var/knocked_down = 0
	var/losebreath = 0 //Carbon
	var/shakecamera = 0
	var/a_intent = INTENT_HELP //Living
	var/m_intent = MOVE_INTENT_RUN//Living
	var/lastKnownIP = null
	var/obj/buckled = null//Living
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/obj/item/back = null//Human/Monkey
	var/obj/item/tank/internal = null//Human/Monkey
	var/obj/item/storage/s_active = null//Carbon
	var/obj/item/clothing/mask/wear_mask = null//Carbon

	// 1 decisecond click delay (above and beyond mob/next_move)
	//This is mainly modified by click code, to modify click delays elsewhere, use next_move and changeNext_move()
	var/next_click	= 0

	// THESE DO NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK
	var/next_move_adjust = 0 //Amount to adjust action/click delays by, + or -
	var/next_move_modifier = 1 //Value to multiply action/click delays by

	var/datum/hud/hud_used = null

	var/grab_level = GRAB_PASSIVE //if we're pulling a mob, tells us how aggressive our grab is.

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/canEnterVentWith = "/obj/item/implant=0&/obj/item/clothing/mask/facehugger=0&/obj/item/device/radio/borg=0&/obj/machinery/camera=0&/obj/item/verbs=0" // Vent crawling whitelisted items, whoo


	var/coughedtime = null

	var/inertia_dir = 0

	var/music_lastplayed = "null"

	var/job = null//Living

	var/const/blindness = 1//Carbon
	var/const/deafness = 2//Carbon
	var/const/muteness = 4//Carbon


	var/datum/dna/dna = null//Carbon
	var/radiation = 0.0//Carbon

	var/list/viruses = list()
	var/list/mutations = list() //Carbon -- Doohl
	//see: setup.dm for list of mutations

	var/voice_name = "unidentifiable voice"

	var/faction = "Neutral"

//Monkey/infected mode
	var/list/resistances = list()

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/status_flags = CANSTUN|CANKNOCKDOWN|CANKNOCKOUT|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea = null

	var/digitalcamo = 0 // Can they be tracked by the AI?

	var/list/radar_blips = list() // list of screen objects, radar blips
	var/radar_open = 0 	// nonzero is radar is open


	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/universal_understand = 0 // Set to 1 to enable the mob to understand everyone, not necessarily speak

	var/immune_to_ssd = 0

	//Emotes
	var/audio_emote_time = 1

	var/list/active_genes=list()

	var/away_timer = 0 //How long the player has been disconnected

	var/recently_pointed_to = 0 //used as cooldown for the pointing verb.

	var/list/image/hud_list //This mob's HUD (med/sec, etc) images. Associative list.

	var/list/hud_possible //HUD images that this mob can provide.

	var/action_busy //whether the mob is currently doing an action that takes time (do_after or do_mob procs)

	var/accuracy_modifier = 0 //Applies a penalty or bonus to projectile accuracy in projectile.dm
	var/scatter_modifier = 0 //Applies a penalty or bonus to scatter probability in gun_system.dm

	var/list/fullscreens = list()

	var/list/light_sources = list()

	var/notransform

	var/typing
	var/last_typed
	var/last_typed_time