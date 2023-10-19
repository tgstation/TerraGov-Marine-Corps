/mob/living/carbon/xenomorph/puppet
	caste_base_type = /mob/living/carbon/xenomorph/puppet
	name = "Puppet"
	desc = "A reanimated body, crudely pieced together and held in place by an ominous energy tethered to some unknown force."
	icon = 'icons/Xeno/castes/puppet.dmi'
	icon_state = "Puppet Running"
	health = 250
	maxHealth = 250
	plasma_stored = 0
	pixel_x = 0
	old_x = 0
	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	pull_speed = -1
	allow_pass_flags = PASS_XENO
	pass_flags = PASS_XENO
	voice_filter = @{"[0:a] asplit [out0][out2]; [out0] asetrate=%SAMPLE_RATE%*0.9,aresample=%SAMPLE_RATE%,atempo=1/0.9,aformat=channel_layouts=mono,volume=0.2 [p0]; [out2] asetrate=%SAMPLE_RATE%*1.1,aresample=%SAMPLE_RATE%,atempo=1/1.1,aformat=channel_layouts=mono,volume=0.2[p2]; [p0][0][p2] amix=inputs=3"}
	///our masters weakref
	var/datum/weakref/weak_master

/mob/living/carbon/xenomorph/puppet/handle_special_state() //prevent us from using different run/walk sprites
	icon_state = "[xeno_caste.caste_name] Running"
	return TRUE

/mob/living/carbon/xenomorph/puppet/Initialize(mapload, mob/living/carbon/xenomorph/puppeteer)
	. = ..()
	if(puppeteer)
		weak_master = WEAKREF(puppeteer)
		transfer_to_hive(puppeteer.hivenumber)
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/puppet, puppeteer)

/mob/living/carbon/xenomorph/puppet/on_death()
	. = ..()
	if(!QDELETED(src))
		gib()

/mob/living/carbon/xenomorph/puppet/Life()
	. = ..()
	var/atom/movable/master = weak_master?.resolve()
	if(!master)
		return
	if(get_dist(src, master) > PUPPET_WITHER_RANGE)
		adjustBruteLoss(15)
	else
		adjustBruteLoss(-5)

/mob/living/carbon/xenomorph/puppet/can_receive_aura(aura_type, atom/source, datum/aura_bearer/bearer)
	. = ..()
	var/atom/movable/master = weak_master?.resolve()
	if(!master)
		return
	if(source != master) //puppeteer phero only
		return FALSE

/mob/living/carbon/xenomorph/puppet/med_hud_set_status()
	. = ..()
	hud_set_blessings()

/mob/living/carbon/xenomorph/puppet/proc/hud_set_blessings()
	var/image/holder = hud_list[XENO_BLESSING_HUD]
	if(!holder)
		return
	for(var/datum/status_effect/effect AS in status_effects)
		if(istype(effect, /datum/status_effect/blessing))
			holder.overlays += image('icons/mob/hud.dmi', icon_state = initial(effect.id))
