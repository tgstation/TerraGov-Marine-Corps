/mob/living/carbon/Xenomorph/Predalien
	caste = "Predalien"
	name = "Predalien"
	desc = "A strange looking creature with fleshy strands on its head. It appears like a mixture of armor and flesh, smooth, but well carapaced."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Predalien Walking"
	melee_damage_lower = 65
	melee_damage_upper = 80
	wall_smash = 1
	health = 800 //A lot of health, but it doesn't regenerate.
	maxHealth = 800
	storedplasma = 300
	maxplasma = 300
	amount_grown = 0
	max_grown = 200
	plasma_gain = 25
	jelly = 0 //variable to check if they ate delicious jelly or not
	jellyGrow = 0 //how much the jelly has grown
	jellyMax = 0 //max amount jelly will grow till evolution
	tacklemin = 6
	tacklemax = 10
	tackle_chance = 80
	is_intelligent = 1

	middle_mouse_toggle = 1 //This toggles middle mouse clicking for certain abilities.
	shift_mouse_toggle = 0 //The same, but for shift clicking.
	charge_type = 4
	armor_deflection = 50
	tunnel_delay = 0

	pslash_delay = 0
	bite_chance = 25 //Chance of doing a special bite attack in place of a claw. Set to 0 to disable.
	evo_points = 0

	pixel_x = -16

	mob_size = MOB_SIZE_BIG
	attack_delay = -2
	speed = -1.8
	tier = 1
	upgrade = -1
	hardcore = 1

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/Pounce,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/Predalien/proc/claim_trophy
		)

	New()
		..()
		announce_spawn()


/mob/living/carbon/Xenomorph/Predalien/proc/announce_spawn()
	set waitfor = 0
	sleep(30)
	if(!loc) return
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

/mob/living/carbon/Xenomorph/Predalien/ClickOn(atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		Pounce(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		Pounce(A)
		return
	..()

/mob/living/carbon/Xenomorph/Predalien/proc/claim_trophy()
	set category = "Alien"
	set name = "Claim Trophy"
	set desc = "Butcher a corpse to attain a trophy from your kill."

	if(stat || paralysis || stunned || weakened || lying || is_mob_restrained() || buckled)
		src << "<span class='xenowarning'>You're not able to do that right now.</span>"
		return

	var/list/choices = list()
	for(var/mob/M in view(1,src)) //We are only interested in humans and predators.
		if(Adjacent(M) && ishuman(M) && M.stat) choices += M

	var/mob/living/carbon/human/H = input(src,"From which corpse will you claim your trophy?") as null|anything in choices

	if(!H || !H.loc) return

	if(stat || paralysis || stunned || weakened || lying || is_mob_restrained() || buckled)
		src << "<span class='xenowarning'>You're not able to do that right now.<span>"
		return

	if(!H.stat)
		src << "<span class='xenowarning'>Your prey must be dead.</span>"
		return

	if(!Adjacent(H))
		src << "<span class='xenowarning'>You have to be next to your target.</span>"
		return

	visible_message("<span class='danger'>[src] reaches down, angling its body toward [H], claws outstretched.</span>",
	"<span class='xenonotice'>You stoop near the host's body, savoring the moment before you claim a trophy for your kill. You must stand still...</span>")
	if(do_after(src, 120, FALSE) && Adjacent(H))
		var/datum/organ/external/head/O = H.get_organ("head")
		if(!(O.status & ORGAN_DESTROYED))
			H.apply_damage(150,BRUTE,"head",0,1,1)
			if(!(O.status & ORGAN_DESTROYED)) O.droplimb(1,1) //Still not actually detached?
			visible_message("<span class='danger'>[src] reaches down and rips off [H]'s spinal cord and skull!</span>",
			"<span class='xenodanger'>You slice and pull on [H]'s head until it comes off in a bloody arc!</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 50)
			emote("growl")
			XENO_HEAL_WOUNDS(isYautja(H)? 15 : 5)
		else
			visible_message("<span class='danger'>[src] slices and dices [H]'s body like a ragdoll!</span>",
			"<span class='xenodanger'>You fly into a frenzy and butcher [H]'s body!</span>")
			playsound(loc, 'sound/weapons/bladeslice.ogg', 50)
			emote("growl")
			var/i = 4
			while(i--)
				H.apply_damage(100,BRUTE,pick("r_leg","l_leg","r_arm","l_arm"),0,1,1)