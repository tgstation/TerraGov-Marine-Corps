/datum/game_mode/infestation/extended_plus/secret_of_life
	name = "Secret of Life - Main"
	config_tag = "Secret of Life - Main"
	silo_scaling = 1
	round_type_flags = MODE_INFESTATION|MODE_PSY_POINTS|MODE_PSY_POINTS_ADVANCED|MODE_HIJACK_POSSIBLE|MODE_SILO_RESPAWN|MODE_ALLOW_XENO_QUICKBUILD|MODE_MUTATIONS_OBTAINABLE|MODE_BIOMASS_POINTS|MODE_XENO_GRAB_DEAD_ALLOWED
	shutters_drop_time = 15 MINUTES
	xeno_abilities_flags = ABILITY_NUCLEARWAR
	factions = list(FACTION_TERRAGOV, FACTION_SOM, FACTION_XENO, FACTION_CLF, FACTION_ICC, FACTION_VSD, FACTION_NANOTRASEN)
	human_factions = list(FACTION_TERRAGOV, FACTION_SOM, FACTION_CLF, FACTION_ICC, FACTION_VSD, FACTION_NANOTRASEN)
	valid_job_types = list(
		/datum/job/terragov/command/ceo = 1,
		/datum/job/terragov/command/nm_ceo = 1,
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/corpseccommander = 1,
		/datum/job/terragov/command/staffofficer = 4,
		/datum/job/terragov/command/vanguard = 2,
		/datum/job/terragov/command/pilot = 1,
		/datum/job/terragov/command/transportofficer = 2,
		/datum/job/terragov/command/assault_crewman = 2,
		/datum/job/terragov/command/transport_crewman = 2,
		/datum/job/terragov/command/mech_pilot = 1,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 6,
		/datum/job/terragov/security/security_officer = 6,
		/datum/job/terragov/medical/researcher = 3,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 4,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/specialist = 4,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/slut = -1,
		/datum/job/moraleofficer = -1,
		/datum/job/worker = -1,
		/datum/job/survivor/assistant = -1,
		/datum/job/survivor/scientist = 2,
		/datum/job/survivor/doctor = 6,
		/datum/job/survivor/liaison = 1,
		/datum/job/survivor/security = 6,
		/datum/job/survivor/civilian = -1,
		/datum/job/survivor/chef = 1,
		/datum/job/survivor/botanist = 1,
		/datum/job/survivor/atmos = 2,
		/datum/job/survivor/chaplain = 1,
		/datum/job/survivor/miner = 2,
		/datum/job/survivor/salesman = 1,
		/datum/job/survivor/marshal = 1,
		/datum/job/survivor/non_deployed_operative = 2,
		/datum/job/survivor/prisoner = 2,
		/datum/job/survivor/stripper = -1,
		/datum/job/survivor/maid = 3,
		/datum/job/other/prisoner = 4,
		/datum/job/survivor/synth = 2,
		/datum/job/xenomorph = FREE_XENO_AT_START,
		/datum/job/xenomorph/green = FREE_XENO_AT_START_CORRUPT,
		/datum/job/xenomorph/queen = 1,
		/datum/job/som/silicon/synthetic/som = 1,
		/datum/job/som/command/commander = 1,
		/datum/job/som/command/fieldcommander = 1,
		/datum/job/som/command/staffofficer = 2,
		/datum/job/som/command/pilot = 1,
		/datum/job/som/command/assault_crewman = 2,
		/datum/job/som/command/mech_pilot = 1,
		/datum/job/som/requisitions/officer = 1,
		/datum/job/som/engineering/chief = 1,
		/datum/job/som/engineering/tech = 2,
		/datum/job/som/medical/professor = 1,
		/datum/job/som/medical/medicalofficer = 2,
		/datum/job/som/squad/standard = -1,
		/datum/job/som/squad/medic = 2,
		/datum/job/som/squad/engineer = 2,
		/datum/job/som/squad/leader = 2,
		/datum/job/som/squad/veteran = 3,
		/datum/job/other/prisonersom = 2,
		/datum/job/clf/breeder = -1,
		/datum/job/clf/standard = -1,
		/datum/job/clf/medic = 2,
		/datum/job/clf/specialist = 3,
		/datum/job/clf/tech = 3,
		/datum/job/clf/leader = 2,
		/datum/job/clf/silicon/synthetic/clf = 1,
		/datum/job/other/prisonerclf = 2,
		/datum/job/vsd_squad/standard = -1,
		/datum/job/vsd_squad/medic = 1,
		/datum/job/vsd_squad/engineer = 1,
		/datum/job/vsd_squad/spec = 1,
		/datum/job/vsd_squad/leader = 1,
		/datum/job/icc_squad/standard = -1,
		/datum/job/icc_squad/medic = 2,
		/datum/job/icc_squad/tech = 2,
		/datum/job/icc_squad/spec = 2,
		/datum/job/icc_squad/leader = 2,
		/datum/job/terragov/civilian/liaison_archercorp = 1,
		/datum/job/terragov/civilian/liaison_novamed = 1,
		/datum/job/terragov/civilian/liaison_transco = 1,
		/datum/job/icc/liaison_cm = 1,
		/datum/job/clf/liaison_clf = 1,
		/datum/job/som/civilian/liaison_som = 1,
		/datum/job/vsd/liaison_kaizoku = 1,
		/datum/job/pmc/squad/standard = -1,
		/datum/job/pmc/squad/medic = 2,
		/datum/job/pmc/squad/engineer = 2,
		/datum/job/pmc/squad/gunner = 1,
		/datum/job/pmc/squad/sniper = 1,
		/datum/job/pmc/squad/leader = 1,
	)
	enable_fun_tads = TRUE
	xenorespawn_time = 2 MINUTES
	respawn_time = 5 MINUTES
	bioscan_interval = 30 MINUTES
	deploy_time_lock = 15 SECONDS
	var/list/datum/job/stat_restricted_jobs = list(/datum/job/survivor/prisoner,/datum/job/other/prisoner,/datum/job/other/prisonersom,/datum/job/other/prisonerclf)

	var/pop_lock = FALSE //turns false post setup
	evo_requirements = list(
		/datum/xeno_caste/queen = 0,
		/datum/xeno_caste/king = 0,
		/datum/xeno_caste/dragon = 0,
	)

/datum/game_mode/infestation/extended_plus/secret_of_life/pre_setup()
	. = ..()
	RegisterSignals(SSdcs, list(COMSIG_GLOB_PLAYER_ROUNDSTART_SPAWNED, COMSIG_GLOB_PLAYER_LATE_SPAWNED), PROC_REF(things_after_spawn))

/datum/game_mode/infestation/extended_plus/secret_of_life/proc/things_after_spawn(datum/source, mob/living/carbon/human/new_member)
	SIGNAL_HANDLER
	//no prisoner guns.
	if(new_member.job in stat_restricted_jobs)
		return
	//we use pdas for this
	var/datum/action/campaign_loadout/loadout = locate() in new_member.actions
	if(loadout)
		loadout.remove_action(new_member)

/datum/game_mode/infestation/extended_plus/secret_of_life/proc/toggle_pop_locks()
	// Apply Evolution Xeno Population Locks:
	var/funnysound
	pop_lock = !pop_lock
	if(!pop_lock)
		evo_requirements = list(
			/datum/xeno_caste/queen = 0,
			/datum/xeno_caste/king = 0,
			/datum/xeno_caste/dragon = 0,
		)
		// respawn_time = 30 MINUTES (it may be too disruptive for other parties, and greenos.)
		xenorespawn_time = 5 MINUTES
		bioscan_interval = 15 MINUTES
		round_type_flags &= ~MODE_XENO_GRAB_DEAD_ALLOWED
		funnysound = pick('sound/misc/airraid.ogg', 'sound/misc/hell_march.ogg', 'sound/misc/queen_alarm.ogg',)
	else
		evo_requirements = list(
			/datum/xeno_caste/queen = 8,
			/datum/xeno_caste/king = 12,
			/datum/xeno_caste/dragon = 12,
		)
		// respawn_time = initial(respawn_time)
		xenorespawn_time = initial(xenorespawn_time)
		bioscan_interval = initial(bioscan_interval)
		round_type_flags |= MODE_XENO_GRAB_DEAD_ALLOWED
		funnysound = pick('sound/theme/neutral_melancholy2.ogg', 'sound/theme/neutral_hopeful1.ogg', 'sound/theme/winning_triumph2.ogg')
	for(var/datum/xeno_caste/caste AS in evo_requirements)
		GLOB.xeno_caste_datums[caste][XENO_UPGRADE_BASETYPE].evolve_min_xenos = evo_requirements[caste]
	send_ooc_announcement(
		sender_override = "War phase [pop_lock ? "OFF" : "ON"].",
		title = "It's so over.",
		text = "Pop locks for xeno castes, dead dragging, respawn timers, bioscans and possibly other things will be affected.",
		sound_override = funnysound,
		style = OOC_ALERT_GAME
	)
	SSvote.initiate_vote()

/*

alt gamemodes

*/
/datum/game_mode/infestation/extended_plus/secret_of_life/nosub
	name = "Secret of Life - No subfactions"
	config_tag = "Secret of Life - No Subfactions"
	factions = list(FACTION_TERRAGOV, FACTION_SOM,FACTION_XENO, FACTION_CLF)
	human_factions = list(FACTION_TERRAGOV, FACTION_SOM, FACTION_CLF)
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/corpseccommander = 1,
		/datum/job/terragov/command/staffofficer = 2,
		/datum/job/terragov/command/vanguard = 2,
		/datum/job/terragov/command/pilot = 2,
		/datum/job/terragov/command/transportofficer = 2,
		/datum/job/terragov/command/transport_crewman = 3,
		/datum/job/terragov/command/mech_pilot = 1,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 2,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 3,
		/datum/job/terragov/security/security_officer = 3,
		/datum/job/terragov/medical/researcher = 1,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 4,
		/datum/job/clf/silicon/synthetic/clf = 1,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 4,
		/datum/job/terragov/squad/corpsman = 4,
		/datum/job/terragov/squad/smartgunner = 2,
		/datum/job/terragov/squad/leader = 2,
		/datum/job/terragov/squad/specialist = 2,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/slut = -1,
		/datum/job/moraleofficer = -1,
		/datum/job/worker = -1,
		/datum/job/other/prisoner = 4,
		/datum/job/xenomorph = FREE_XENO_AT_START,
		/datum/job/xenomorph/queen = 1,
		/datum/job/clf/leader = 2,
		/datum/job/clf/specialist = 2,
		/datum/job/clf/tech = 2,
		/datum/job/clf/medic = 4,
		/datum/job/clf/standard = -1,
		/datum/job/clf/breeder = -1,
		/datum/job/other/prisonerclf = 2,
		/datum/job/som/silicon/synthetic/som = 1,
		/datum/job/som/command/commander = 1,
		/datum/job/som/command/fieldcommander = 1,
		/datum/job/som/command/staffofficer = 2,
		/datum/job/som/command/pilot = 1,
		/datum/job/som/command/assault_crewman = 2,
		/datum/job/som/command/mech_pilot = 1,
		/datum/job/som/requisitions/officer = 1,
		/datum/job/som/engineering/chief = 1,
		/datum/job/som/engineering/tech = 2,
		/datum/job/som/medical/professor = 1,
		/datum/job/som/medical/medicalofficer = 2,
		/datum/job/som/squad/standard = -1,
		/datum/job/som/squad/medic = 2,
		/datum/job/som/squad/engineer = 2,
		/datum/job/som/squad/leader = 2,
		/datum/job/som/squad/veteran = 3,
		/datum/job/other/prisonersom = 2,
		/datum/job/terragov/civilian/liaison_archercorp = 1,
		/datum/job/terragov/civilian/liaison_novamed = 1,
		/datum/job/terragov/civilian/liaison_transco = 1,
		/datum/job/clf/liaison_clf = 1,
		/datum/job/som/civilian/liaison_som = 1,
	)

//old school mode, no ship, one map with bases in it, no subfactions.
/datum/game_mode/infestation/extended_plus/secret_of_life/classic
	name = "Secret of Life - Classic"
	config_tag = "Secret of Life - Classic"
	factions = list(FACTION_TERRAGOV, FACTION_SOM,FACTION_XENO, FACTION_CLF)
	human_factions = list(FACTION_TERRAGOV, FACTION_SOM, FACTION_CLF)
	whitelist_ship_maps = list(MAP_EAGLE_CLASSIC)
	whitelist_ground_maps = list(MAP_LV_624BASES)
	whitelist_antag_maps = list(MAP_ANTAGMAP_NOSPAWN)
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/corpseccommander = 1,
		/datum/job/terragov/command/staffofficer = 2,
		/datum/job/terragov/command/vanguard = 2,
		/datum/job/terragov/command/pilot = 2,
		/datum/job/terragov/command/transportofficer = 2,
		/datum/job/terragov/command/transport_crewman = 3,
		/datum/job/terragov/command/mech_pilot = 1,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 2,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 3,
		/datum/job/terragov/security/security_officer = 3,
		/datum/job/terragov/medical/researcher = 1,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 4,
		/datum/job/clf/silicon/synthetic/clf = 1,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 4,
		/datum/job/terragov/squad/corpsman = 4,
		/datum/job/terragov/squad/smartgunner = 2,
		/datum/job/terragov/squad/leader = 2,
		/datum/job/terragov/squad/specialist = 2,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/slut = -1,
		/datum/job/moraleofficer = -1,
		/datum/job/worker = -1,
		/datum/job/other/prisoner = 4,
		/datum/job/xenomorph =  FREE_XENO_AT_START,
		/datum/job/xenomorph/queen = 1,
		/datum/job/clf/leader = 2,
		/datum/job/clf/specialist = 2,
		/datum/job/clf/tech = 2,
		/datum/job/clf/medic = 4,
		/datum/job/clf/standard = -1,
		/datum/job/clf/breeder = -1,
		/datum/job/som/silicon/synthetic/som = 1,
		/datum/job/som/command/commander = 1,
		/datum/job/som/command/fieldcommander = 1,
		/datum/job/som/command/staffofficer = 2,
		/datum/job/som/command/pilot = 1,
		/datum/job/som/command/assault_crewman = 2,
		/datum/job/som/command/mech_pilot = 1,
		/datum/job/som/requisitions/officer = 1,
		/datum/job/som/engineering/chief = 1,
		/datum/job/som/engineering/tech = 2,
		/datum/job/som/medical/professor = 1,
		/datum/job/som/medical/medicalofficer = 2,
		/datum/job/som/squad/standard = -1,
		/datum/job/som/squad/medic = 2,
		/datum/job/som/squad/engineer = 2,
		/datum/job/som/squad/leader = 2,
		/datum/job/som/squad/veteran = 3,
		/datum/job/other/prisonersom = 2,
		/datum/job/terragov/civilian/liaison_archercorp = 1,
		/datum/job/terragov/civilian/liaison_novamed = 1,
		/datum/job/terragov/civilian/liaison_transco = 1,
		/datum/job/clf/liaison_clf = 1,
		/datum/job/som/civilian/liaison_som = 1,
	)

/datum/game_mode/infestation/extended_plus/secret_of_life/alienonly
	name = "Secret of Life - NTF vs Alien only"
	config_tag = "Secret of Life - Alien only"
	factions = list(FACTION_TERRAGOV, FACTION_XENO)
	human_factions = list(FACTION_TERRAGOV)
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/corpseccommander = 1,
		/datum/job/terragov/command/staffofficer = 2,
		/datum/job/terragov/command/vanguard = 2,
		/datum/job/terragov/command/pilot = 2,
		/datum/job/terragov/command/transportofficer = 2,
		/datum/job/terragov/command/transport_crewman = 3,
		/datum/job/terragov/command/mech_pilot = 1,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 2,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 3,
		/datum/job/terragov/security/security_officer = 3,
		/datum/job/terragov/medical/researcher = 1,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 4,
		/datum/job/clf/silicon/synthetic/clf = 1,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 4,
		/datum/job/terragov/squad/corpsman = 4,
		/datum/job/terragov/squad/smartgunner = 2,
		/datum/job/terragov/squad/leader = 2,
		/datum/job/terragov/squad/specialist = 2,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/slut = -1,
		/datum/job/moraleofficer = -1,
		/datum/job/worker = -1,
		/datum/job/other/prisoner = 4,
		/datum/job/xenomorph = FREE_XENO_AT_START,
		/datum/job/xenomorph/queen = 1,
		/datum/job/terragov/civilian/liaison_archercorp = 1,
		/datum/job/terragov/civilian/liaison_novamed = 1,
		/datum/job/terragov/civilian/liaison_transco = 1,
	)

/datum/game_mode/infestation/extended_plus/secret_of_life/ntf_vs_clf
	name = "Secret of Life - NTF vs CLF"
	config_tag = "Secret of Life - NTF vs CLF"
	factions = list(FACTION_TERRAGOV, FACTION_XENO, FACTION_CLF)
	human_factions = list(FACTION_TERRAGOV, FACTION_CLF)
	valid_job_types = list(
		/datum/job/terragov/command/ceo = 1,
		/datum/job/terragov/command/nm_ceo = 1,
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/corpseccommander = 1,
		/datum/job/terragov/command/staffofficer = 2,
		/datum/job/terragov/command/vanguard = 2,
		/datum/job/terragov/command/pilot = 1,
		/datum/job/terragov/command/transportofficer = 2,
		/datum/job/terragov/command/assault_crewman = 2,
		/datum/job/terragov/command/transport_crewman = 2,
		/datum/job/terragov/command/mech_pilot = 1,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 3,
		/datum/job/terragov/security/security_officer = 3,
		/datum/job/terragov/medical/researcher = 3,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 3,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 4,
		/datum/job/terragov/squad/corpsman = 4,
		/datum/job/terragov/squad/leader = 2,
		/datum/job/terragov/squad/specialist = 2,
		/datum/job/terragov/squad/smartgunner = 2,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/slut = -1,
		/datum/job/moraleofficer = -1,
		/datum/job/worker = -1,
		/datum/job/survivor/assistant = 1,
		/datum/job/survivor/scientist = 1,
		/datum/job/survivor/doctor = 1,
		/datum/job/survivor/liaison = 1,
		/datum/job/survivor/security = 1,
		/datum/job/survivor/civilian = 4,
		/datum/job/survivor/chef = 1,
		/datum/job/survivor/botanist = 1,
		/datum/job/survivor/atmos = 1,
		/datum/job/survivor/chaplain = 1,
		/datum/job/survivor/miner = 1,
		/datum/job/survivor/salesman = 1,
		/datum/job/survivor/marshal = 1,
		/datum/job/survivor/non_deployed_operative = 2,
		/datum/job/survivor/prisoner = 4,
		/datum/job/survivor/stripper = -1,
		/datum/job/survivor/maid = 4,
		/datum/job/survivor/synth = 1,
		/datum/job/other/prisoner = 4,
		/datum/job/xenomorph = FREE_XENO_AT_START,
		/datum/job/xenomorph/green = FREE_XENO_AT_START_CORRUPT,
		/datum/job/xenomorph/queen = 1,
		/datum/job/clf/breeder = -1,
		/datum/job/clf/standard = -1,
		/datum/job/clf/medic = 6,
		/datum/job/clf/tech = 6,
		/datum/job/clf/specialist = 4,
		/datum/job/clf/leader = 2,
		/datum/job/clf/silicon/synthetic/clf = 1,
		/datum/job/other/prisonerclf = 2,
		/datum/job/terragov/civilian/liaison_archercorp = 1,
		/datum/job/terragov/civilian/liaison_novamed = 1,
		/datum/job/terragov/civilian/liaison_transco = 1,
		/datum/job/clf/liaison_clf = 1,
	)
