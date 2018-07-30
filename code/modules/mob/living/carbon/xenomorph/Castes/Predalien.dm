/mob/living/carbon/Xenomorph/Predalien
	caste = "Predalien"
	name = "Abomination"
	desc = "A strange looking creature with fleshy strands on its head. It appears like a mixture of armor and flesh, smooth, but well carapaced."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Predalien Walking"
	melee_damage_lower = 65
	melee_damage_upper = 80
	health = 800 //A lot of health, but it doesn't regenerate.
	maxHealth = 800
	plasma_stored = 300
	plasma_max = 300
	amount_grown = 0
	max_grown = 200
	plasma_gain = 25
	evolution_allowed = FALSE
	tacklemin = 6
	tacklemax = 10
	tackle_chance = 80

	wall_smash = TRUE
	is_intelligent = TRUE
	hardcore = TRUE

	charge_type = 4
	armor_deflection = 50
	tunnel_delay = 0

	pslash_delay = 0
	bite_chance = 25
	tail_chance = 25
	evo_points = 0

	pixel_x = -16
	old_x = -16

	mob_size = MOB_SIZE_BIG
	attack_delay = -2
	speed = -2.1
	tier = 1
	upgrade = -1 //Predaliens are already in their ultimate form, they don't get even better

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
	if(!loc) r_FAL
	if(ticker && ticker.mode && ticker.mode.predators.len)
		var/datum/mind/M
		for(var/i in ticker.mode.predators)
			M = i
			if(M.current && M.current.stat != DEAD)
				M.current << "<span class='event_announcement'>An abomination to your people has been brought onto the world at [get_area(src)]! Hunt it down and destroy it!</span>"
				M.current.emote("roar")

	src << {"
<span class='role_body'>|______________________|</span>
<span class='role_header'>You are a predator-alien hybrid!</span>
<span class='role_body'>You are a very powerful xenomorph creature that was born of a Yautja warrior body.
You are stronger, faster, and smarter than a regular xenomorph, but you must still listen to the queen.
You have a degree of freedom to where you can hunt and claim the heads of the hive's enemies, so check your verbs.
Your health meter will not regenerate normally, so kill and die for the hive!</span>
<span class='role_body'>|______________________|</span>
"}

	emote("roar")


/mob/living/carbon/Xenomorph/Predalien/proc/claim_trophy()
	set category = "Alien"
	set name = "Claim Trophy"
	set desc = "Butcher a corpse to attain a trophy from your kill."

	if(is_mob_incapacitated()|| lying || buckled)
		src << "<span class='xenowarning'>You're not able to do that right now.</span>"
		r_FAL

	var/choices[] = new
	for(var/mob/M in view(1, src)) //We are only interested in humans and predators.
		if(Adjacent(M) && ishuman(M) && M.stat) choices += M

	var/mob/living/carbon/human/H = input(src, "From which corpse will you claim your trophy?") as null|anything in choices

	if(!H || !H.loc) r_FAL

	if(is_mob_incapacitated() || lying || buckled)
		src << "<span class='xenowarning'>You're not able to do that right now.<span>"
		r_FAL

	if(!H.stat)
		src << "<span class='xenowarning'>Your prey must be dead.</span>"
		r_FAL

	if(!Adjacent(H))
		src << "<span class='xenowarning'>You have to be next to your target.</span>"
		r_FAL

	if(world.time <= butchered_last + PREDALIEN_BUTCHER_COOLDOWN)
		src << "<span class='xenowarning'>You have recently attempted to butcher a carcass. Wait.</span>"
		r_FAL

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
			XENO_HEAL_WOUNDS(isYautja(H)? 15 : to_heal) //Predators give far better healing.
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