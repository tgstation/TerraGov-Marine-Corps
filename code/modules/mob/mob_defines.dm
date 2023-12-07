/mob
	name = "mob"
	density = TRUE
	layer = MOB_LAYER
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	animate_movement = SLIDE_STEPS
	datum_flags = DF_USE_TAG
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	flags_atom = PREVENT_CONTENTS_EXPLOSION
	resistance_flags = NONE

	//Mob
	///Whether a mob is alive or dead. TODO: Move this to living - Nodrak
	var/stat = CONSCIOUS
	var/datum/mind/mind
	var/real_name
	var/mob_size = MOB_SIZE_HUMAN
	var/timeofdeath = 0
	var/a_intent = INTENT_HELP
	var/m_intent = MOVE_INTENT_RUN
	var/in_throw_mode = FALSE
	/// Whether or not the mob can hit themselves.
	var/do_self_harm = FALSE
	var/notransform = FALSE
	///The list of people observing this mob.
	var/list/observers
	/// Verbs used when speaking instead of the default ones.
	var/list/speak_emote = list("says")
	var/zone_selected = BODY_ZONE_CHEST
	var/bodytemperature = 310.055	//98.7 F
	var/hand
	var/bloody_hands = 0
	var/track_blood = 0
	var/feet_blood_color
	var/datum/skills/skills


	//Movement
	///List of movement speed modifiers applying to this mob. Lazy list, see mob_movespeed.dm
	var/list/movespeed_modification
	///The calculated mob speed slowdown based on the modifiers list.
	var/cached_multiplicative_slowdown
	var/next_click = 0
	var/next_move = 0
	///Amount added during the next movement_delay(), then is reset.
	var/next_move_slowdown = 0
	///Amount to adjust action/click delays by, + or -
	var/next_move_adjust = 0
	//Value to multiply action/click delays by
	var/next_move_modifier = 1
	var/last_move_intent
	var/area/lastarea
	var/old_x = 0
	var/old_y = 0
	var/inertia_dir = 0
	///Can move on the shuttle.
	var/move_on_shuttle = TRUE
	var/canmove = TRUE
	///Mob's angle in BYOND degrees. 0 is north (up/standing for humans), 90 and 270 are east and west respectively (lying horizontally), and 90 is south (upside-down).
	var/lying_angle = 0
	var/lying_prev = 0

	//Security
	var/computer_id
	var/ip_address
	var/list/logging = list()
	var/static/next_mob_id = 0
	var/immune_to_ssd = FALSE

	//HUD and overlays
	var/hud_type = /datum/hud
	var/datum/hud/hud_used
	///for stacking do_after bars
	var/list/progressbars
	///for stacking the total pixel height of the aboves.
	var/list/progbar_towers
	var/list/fullscreens = list()
	///contains /atom/movable/screen/alert only, used by alerts.dm
	var/list/alerts = list()
	var/list/datum/action/actions = list()
	var/list/actions_by_path = list()
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

	//Interaction
	///Lazylist assoc list of do_after and do_mob actions the mob is currently performing: list([target] = amount)
	var/list/do_actions
	var/datum/click_intercept
	///the thing that the mob is currently interacting with (e.g. a computer, another mob (stripping a mob), manning a hmg)
	var/atom/movable/interactee
	///Used by admins to possess objects.
	var/obj/control_object
	///Calls relaymove() to whatever it is
	var/atom/movable/remote_control
	var/obj/item/l_hand //Living
	var/obj/item/r_hand //Living
	var/obj/item/storage/s_active //Carbon
	var/obj/item/clothing/mask/wear_mask //Carbon
	///the current turf being examined in the stat panel
	var/turf/listed_turf
	///Has enough dexterity to interact with advanced objects?
	var/dextrous = FALSE

	/// The machine the mob is interacting with (this is very bad old code btw)
	var/obj/machinery/machine = null

	//Input
	///What receives our keyboard inputs. src by default
	var/datum/focus
	var/memory_throttle_time = 0
	///Whether the mob is updating glide size when movespeed updates or not
	var/updating_glide_size = TRUE

	/// Can they interact with station electronics
	var/has_unlimited_silicon_privilege = 0
	///The faction this mob belongs to
	var/faction = FACTION_NEUTRAL

	/// what icon the mob uses for speechbubbles
	var/bubble_icon = "default"
	///the icon currently used for the typing indicator's bubble
	var/active_typing_indicator
	///the icon currently used for the thinking indicator's bubble
	var/active_thinking_indicator
	/// User is thinking in character. Used to revert to thinking state after stop_typing
	var/thinking_IC = FALSE
	/// The current client inhabiting this mob. Managed by login/logout
	/// This exists so we can do cleanup in logout for occasions where a client was transfere rather then destroyed
	/// We need to do this because the mob on logout never actually has a reference to client
	/// We also need to clear this var/do other cleanup in client/Destroy, since that happens before logout
	/// HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
	var/client/canon_client
