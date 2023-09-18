/mob/living/carbon/xenomorph/predalien
	caste_base_type = /mob/living/carbon/xenomorph/predalien
	name = "Abomination" //snowflake name
	desc = "A strange looking creature with fleshy strands on its head. It appears like a mixture of armor and flesh, smooth, but well carapaced."
	icon = 'modular_RUtgmc/icons/Xeno/castes/predalien.dmi'
	icon_state = "Predalien Walking"
	wall_smash = TRUE
	pixel_x = -16
	old_x = -16
	bubble_icon = "alienroyal"
	talk_sound = "predalien_talk"
	mob_size = MOB_SIZE_BIG

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_NORMAL

	var/max_bonus_life_kills = 10
	var/butcher_time = 6 SECONDS

/mob/living/carbon/xenomorph/predalien/Initialize(mapload, mob/living/carbon/xenomorph/oldxeno, h_number)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(announce_spawn)), 3 SECONDS)
	hunter_data.dishonored = TRUE
	hunter_data.dishonored_reason = "An abomination upon the honor of us all!"
	hunter_data.dishonored_set = src
	hud_set_hunter()

/mob/living/carbon/xenomorph/predalien/Stat()
	. = ..()
	if(statpanel("Game"))
		stat("Life Kills Bonus:", "[min(life_kills_total, max_bonus_life_kills)] / [max_bonus_life_kills]")

/mob/living/carbon/xenomorph/predalien/proc/announce_spawn()
	if(!loc)
		return FALSE

	to_chat(src, {"
<span class='role_body'>|______________________|</span>
<span class='role_header'>You are a predator-alien hybrid!</span>
<span class='role_body'>You are a very powerful xenomorph creature that was born of a Yautja warrior body.
You are stronger, faster, and smarter than a regular xenomorph, but you must still listen to the hive ruler.
You have a degree of freedom to where you can hunt and claim the heads of the hive's enemies, so check your verbs.
Your health meter will not regenerate normally, so kill and die for the hive!</span>
<span class='role_body'>|______________________|</span>
"})
	emote("roar")
