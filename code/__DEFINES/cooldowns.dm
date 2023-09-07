#define COOLDOWN_CHEW "chew"
#define COOLDOWN_PUKE "puke"
#define COOLDOWN_POINT "point"
#define COOLDOWN_EMOTE "emote"
#define COOLDOWN_VENTCRAWL "ventcrawl"
#define COOLDOWN_BUCKLE "buckle"
#define COOLDOWN_RESIST "resist"
#define COOLDOWN_ORDER "order"
#define COOLDOWN_DISPOSAL "disposal"
#define COOLDOWN_ACID "acid"
#define COOLDOWN_GUT "gut"
#define COOLDOWN_ZOOM "zoom"
#define COOLDOWN_BUMP "bump"
#define COOLDOWN_ENTANGLE "entangle"
#define COOLDOWN_NEST "nest"
#define COOLDOWN_BUMP_ATTACK "bump_attack"
#define COOLDOWN_TASTE "taste"
#define COOLDOWN_VENTSOUND "vendsound"
#define COOLDOWN_ARMOR_LIGHT "armor_light"
#define COOLDOWN_ARMOR_ACTION "armor_action"
#define COOLDOWN_FRIENDLY_FIRE_CAUSED "friendly_fire_caused"
#define COOLDOWN_FRIENDLY_FIRE_TAKEN "friendly_fire_taken"
#define COOLDOWN_ORBIT_CHANGE "cooldown_orbit_change"
#define COOLDOWN_TOGGLE "toggle"
#define COOLDOWN_CPR "CPR"
#define COOLDOWN_IV_PING "iv_ping"
#define COOLDOWN_RACK_BOLT "rack_bolt"
#define COOLDOWN_LIGHT "cooldown_light"
#define COOLDOWN_JETPACK "jetpack"
#define COOLDOWN_CIC_ORDERS "cic_orders"
#define COOLDOWN_HUD_ORDER "hud_order"
#define COOLDOWN_CLOAK_IMPLANT "cloak_implant"
#define COOLDOWN_DRONE_CLOAK "drone_cloak"
#define COOLDOWN_XENO_TURRETS_ALERT "xeno_turrets_alert"
#define COOLDOWN_PARALYSE_ACID "acid_spray_paralyse"
#define COOLDOWN_RELAY_MOVE "remote_relay_moves"
#define COOLDOWN_PROJECTOR_LIGHT "projector_light"
#define COOLDOWN_BIOSCAN "cooldown_bioscan"
#define COOLDOWN_LOADOUT_EQUIPPED "cooldown_loadout_equipped"
#define COOLDOWN_LOADOUT_VISUALIZATION "cooldown_loadout_visualization"
#define COOLDOWN_TADPOLE_LAUNCHING "cooldown_tadpole_launching"
#define COOLDOWN_BOMBVEST_SHIELD_DROP "cooldown_bombvest_shield_drop"
#define COOLDOWN_HIVEMIND_MANIFESTATION "cooldown_hivemind_manifestation"
#define COOLDOWN_ORBITAL_SPOTLIGHT "orbital_spotlight"
#define COOLDOWN_GAS_BREATH "cooldown_gas_breath"
#define COOLDOWN_SIGNALLER_SEND "cooldown_signaller_send"
#define COOLDOWN_BIKE_FUEL_MESSAGE "cooldown_bikee_fuel_message"
#define COOLDOWN_WRAITH_PORTAL_TELEPORTED "cooldown_wraith_portal_teleported"
#define COOLDOWN_ITEM_TRICK "cooldown_item_trick"
#define COOLDOWN_RAVAGER_FLAMER_ACT "cooldown_ravager_flamer_act"
#define COOLDOWN_DROPPOD_TARGETTING "cooldown_droppod_targetting"
#define COOLDOWN_TRY_TTS "cooldown_try_tts"

//Mecha cooldowns
#define COOLDOWN_MECHA "mecha"
#define COOLDOWN_MECHA_MESSAGE "mecha_message"
#define COOLDOWN_MECHA_EQUIPMENT(type) ("mecha_equip_[type]")
#define COOLDOWN_MECHA_ARMOR "mecha_armor"
#define COOLDOWN_MECHA_MELEE_ATTACK "mecha_melee"
#define COOLDOWN_MECHA_SMOKE "mecha_smoke"
#define COOLDOWN_MECHA_SKYFALL "mecha_skyfall"
#define COOLDOWN_MECHA_MISSILE_STRIKE "mecha_missile_strike"

//// COOLDOWN SYSTEMS
/*
 * We have 2 cooldown systems: timer cooldowns (divided between stoppable and regular) and world.time cooldowns.
 *
 * When to use each?
 *
 * * Adding a commonly-checked cooldown, like on a subsystem to check for processing
 * * * Use the world.time ones, as they are cheaper.
 *
 * * Adding a rarely-used one for special situations, such as giving an uncommon item a cooldown on a target.
 * * * Timer cooldown, as adding a new variable on each mob to track the cooldown of said uncommon item is going too far.
 *
 * * Triggering events at the end of a cooldown.
 * * * Timer cooldown, registering to its signal.
 *
 * * Being able to check how long left for the cooldown to end.
 * * * Either world.time or stoppable timer cooldowns, depending on the other factors. Regular timer cooldowns do not support this.
 *
 * * Being able to stop the timer before it ends.
 * * * Either world.time or stoppable timer cooldowns, depending on the other factors. Regular timer cooldowns do not support this.
*/


/*
 * Cooldown system based on an datum-level associative lazylist using timers.
*/

//INDEXES
#define COOLDOWN_BORG_SELF_REPAIR "borg_self_repair"
#define COOLDOWN_EXPRESSPOD_CONSOLE "expresspod_console"


//TIMER COOLDOWN MACROS

#define COMSIG_CD_STOP(cd_index) "cooldown_[cd_index]"
#define COMSIG_CD_RESET(cd_index) "cd_reset_[cd_index]"

#define TIMER_COOLDOWN_START(cd_source, cd_index, cd_time) LAZYSET(cd_source.cooldowns, cd_index, addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(end_cooldown), cd_source, cd_index), cd_time))

#define TIMER_COOLDOWN_CHECK(cd_source, cd_index) LAZYACCESS(cd_source.cooldowns, cd_index)

#define TIMER_COOLDOWN_END(cd_source, cd_index) LAZYREMOVE(cd_source.cooldowns, cd_index)

/**
 * Stoppable timer cooldowns.
 * Use indexes the same as the regular tiemr cooldowns.
 * They make use of the TIMER_COOLDOWN_CHECK() and TIMER_COOLDOWN_END() macros the same, just not the TIMER_COOLDOWN_START() one.
 * A bit more expensive than the regular timers, but can be reset before they end and the time left can be checked.
 */

#define S_TIMER_COOLDOWN_START(cd_source, cd_index, cd_time) LAZYSET(cd_source.cooldowns, cd_index, addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(end_cooldown), cd_source, cd_index), cd_time, TIMER_STOPPABLE))

#define S_TIMER_COOLDOWN_RESET(cd_source, cd_index) reset_cooldown(cd_source, cd_index)

#define S_TIMER_COOLDOWN_TIMELEFT(cd_source, cd_index) (timeleft(TIMER_COOLDOWN_CHECK(cd_source, cd_index)))


/**
 * Cooldown system based on storing world.time on a variable, plus the cooldown time.
 * Better performance over timer cooldowns, lower control. Same functionality.
 */

#define COOLDOWN_DECLARE(cd_index) var/##cd_index = 0

#define COOLDOWN_START(cd_source, cd_index, cd_time) (cd_source.cd_index = world.time + cd_time)

//Returns true if the cooldown has run its course, false otherwise
#define COOLDOWN_CHECK(cd_source, cd_index) (cd_source.cd_index < world.time)

#define COOLDOWN_RESET(cd_source, cd_index) cd_source.cd_index = 0

#define COOLDOWN_TIMELEFT(cd_source, cd_index) (max(0, cd_source.cd_index - world.time))

//railgun cooldown define
#define COOLDOWN_RAILGUN_FIRE 300 SECONDS

//AI bioscan cooldown define
#define COOLDOWN_AI_BIOSCAN 10 MINUTES

//ping cooldown define
#define COOLDOWN_AI_PING_NORMAL 45 SECONDS
#define COOLDOWN_AI_PING_LOW 30 SECONDS
#define COOLDOWN_AI_PING_EXTRA_LOW 15 SECONDS
