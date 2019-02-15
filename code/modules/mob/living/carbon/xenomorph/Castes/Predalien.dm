/datum/xeno_caste/predalien
	caste_name = "Predalien"
	display_name = "Abomination"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/Xenomorph/Predalien
	tier = 1
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 65
	melee_damage_upper = 80
	attack_delay = -2 //Bonus or pen to time in between attacks. + makes slashes slower.

	// *** Tackle *** //
	tackle_damage = 50 //How much HALLOSS damage a xeno deals when tackling

	// *** RNG Attacks *** //
	bite_chance = 25 //Chance of doing a special bite attack in place of a claw. Set to 0 to disable.
	tail_chance = 25 //Chance of doing a special tail attack in place of a claw. Set to 0 to disable.

	// *** Speed *** //
	speed = -2.1

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 25

	// *** Health *** //
	max_health = 800

	hardcore = TRUE //Set to 1 in New() when Whiskey Outpost is active. Prevents healing and queen evolution

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT

	// *** Defense *** //
	armor_deflection = 50 //Chance of deflecting projectiles.

	charge_type = 4
	pounce_delay = 4 SECONDS

/datum/xeno_caste/predalien/handle_decay(mob/living/carbon/Xenomorph/X)
	if(prob(20))
		X.use_plasma(min(rand(1,2), X.plasma_stored))

/mob/living/carbon/Xenomorph/Predalien
	caste_base_type = /mob/living/carbon/Xenomorph/Predalien
	name = "Abomination"
	desc = "A strange looking creature with fleshy strands on its head. It appears like a mixture of armor and flesh, smooth, but well carapaced."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Predalien Walking"
	health = 800 //A lot of health, but it doesn't regenerate.
	maxHealth = 800
	plasma_stored = 300
	amount_grown = 0
	max_grown = 200
	wall_smash = TRUE
	tunnel_delay = 0
	pslash_delay = 0
	evo_points = 0
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	speed = -2.1
	tier = 1
	upgrade = -1 //Predaliens are already in their ultimate form, they don't get even better
	wound_type = "predalien" //used to match appropriate wound overlays
	var/butchered_last //world.time to prevent spam.
	var/butchered_sum = 0 //The number of people butchered. Lowers the health gained.

	#define PREDALIEN_BUTCHER_COOLDOWN 140 //14 seconds.
	#define PREDALIEN_BUTCHER_WAIT_TIME 120 //12 seconds.
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/pounce,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/Predalien/proc/claim_trophy
		)

	New()
		..()
		announce_spawn()

/mob/living/carbon/Xenomorph/Predalien/proc/announce_spawn()
	set waitfor = 0
	sleep(30)
	if(!loc) return FALSE
	if(length(SSticker?.mode?.predators))
		var/datum/mind/M
		for(var/i in SSticker.mode.predators)
			M = i
			if(M.current && M.current.stat != DEAD)
				to_chat(M.current, "<span class='event_announcement'>An abomination to your people has been brought onto the world at [get_area(src)]! Hunt it down and destroy it!</span>")
				M.current.emote("roar")

	to_chat(src,  {"
<span class='role_body'>|______________________|</span>
<span class='role_header'>You are a predator-alien hybrid!</span>
<span class='role_body'>You are a very powerful xenomorph creature that was born of a Yautja warrior body.
You are stronger, faster, and smarter than a regular xenomorph, but you must still listen to the queen.
You have a degree of freedom to where you can hunt and claim the heads of the hive's enemies, so check your verbs.
Your health meter will not regenerate normally, so kill and die for the hive!</span>
<span class='role_body'>|______________________|</span>
"})

	emote("roar")


/mob/living/carbon/Xenomorph/Predalien/proc/claim_trophy()
	set category = "Alien"
	set name = "Claim Trophy"
	set desc = "Butcher a corpse to attain a trophy from your kill."

	if(is_mob_incapacitated()|| lying || buckled)
		to_chat(src, "<span class='xenowarning'>You're not able to do that right now.</span>")
		return FALSE

	var/choices[] = new
	for(var/mob/M in view(1, src)) //We are only interested in humans and predators.
		if(Adjacent(M) && ishuman(M) && M.stat) choices += M

	var/mob/living/carbon/human/H = input(src, "From which corpse will you claim your trophy?") as null|anything in choices

	if(!H || !H.loc) return FALSE

	if(is_mob_incapacitated() || lying || buckled)
		to_chat(src, "<span class='xenowarning'>You're not able to do that right now.<span>")
		return FALSE

	if(!H.stat)
		to_chat(src, "<span class='xenowarning'>Your prey must be dead.</span>")
		return FALSE

	if(!Adjacent(H))
		to_chat(src, "<span class='xenowarning'>You have to be next to your target.</span>")
		return FALSE

	if(world.time <= butchered_last + PREDALIEN_BUTCHER_COOLDOWN)
		to_chat(src, "<span class='xenowarning'>You have recently attempted to butcher a carcass. Wait.</span>")
		return FALSE

	butchered_last = world.time

	visible_message("<span class='danger'>[src] reaches down, angling its body toward [H], claws outstretched.</span>",
	"<span class='xenonotice'>You stoop near the host's body, savoring the moment before you claim a trophy for your kill. You must stand still...</span>")
	if(do_after(src, PREDALIEN_BUTCHER_WAIT_TIME, FALSE, 5, BUSY_ICON_HOSTILE) && Adjacent(H))
		var/datum/limb/head/O = H.get_limb("head")
		if(!(O.status & LIMB_DESTROYED))
			H.apply_damage(150, BRUTE, "head", FALSE, TRUE, TRUE)
			if(!(O.status & LIMB_DESTROYED)) O.droplimb() //Still not actually detached?
			visible_message("<span class='danger'>[src] reaches down and rips off [H]'s spinal cord and skull!</span>",
			"<span class='xenodanger'>You slice and pull on [H]'s head until it comes off in a bloody arc!</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 25)
			emote("growl")
			var/to_heal = max(1, 5 - (0.2 * (health < maxHealth ? butchered_sum++ : butchered_sum)))//So we do not heal multiple times due to the inline proc below.
			heal_wounds(isyautja(H)? 15 : to_heal) //Predators give far better healing.
		else
			visible_message("<span class='danger'>[src] slices and dices [H]'s body like a ragdoll!</span>",
			"<span class='xenodanger'>You fly into a frenzy and butcher [H]'s body!</span>")
			playsound(loc, 'sound/weapons/bladeslice.ogg', 25)
			emote("growl")
			var/i = 4
			while(i--)
				H.apply_damage(100, BRUTE, pick("r_leg","l_leg","r_arm","l_arm"), FALSE, TRUE, TRUE)

	#undef PREDALIEN_BUTCHER_COOLDOWN
	#undef PREDALIEN_BUTCHER_WAIT_TIME
