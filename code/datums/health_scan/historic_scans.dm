/// Holds `/datum/historic_scan` instances for viewing old body scanner/autodoc scans
GLOBAL_DATUM_INIT(historic_scan_index, /datum/historic_scan_index, new)

/// Holds `/datum/historic_scan` instances for viewing old body scanner/autodoc scans
/datum/historic_scan_index
	/// Associative list of `ref` -> `/datum/historic_scan`
	VAR_PRIVATE/list/datum/historic_scan/scans = list()

/// Shows `patient`'s old scan to `user`, if it exists, otherwise gives feedback
/datum/historic_scan_index/proc/show_old_scan_by_human(mob/living/carbon/human/patient, mob/user)
	var/datum/historic_scan/temp = scans[ref(patient)]
	if(!temp)
		to_chat(user, span_warning("No historic scan found for [patient]!"))
		return
	temp.ui_interact(user)

/// Gets the scan time of `patient`'s old scan, if it exists, otherwise returns null
/datum/historic_scan_index/proc/get_last_scan_time(mob/living/carbon/human/patient)
	var/datum/historic_scan/temp = scans[ref(patient)]
	if(!temp || !istext(temp.last_scan_time))
		return
	return temp.last_scan_time

/// Updates or creates a scan datum for `patient`
/datum/historic_scan_index/proc/modify_or_add_patient(mob/living/carbon/human/patient, list/data)
	if(!islist(data))
		CRASH("Data provided to [type]/modify_or_add_patient is not a list")
	if(!ishuman(patient))
		CRASH("Patient provided to [type]/modify_or_add_patient is not a carbon human")
	var/datum/historic_scan/temp = scans[ref(patient)]
	if(isnull(temp))
		temp = new
		scans[ref(patient)] = temp
		RegisterSignal(patient, COMSIG_QDELETING, PROC_REF(patient_qdeleted))
	temp.last_scan_time = worldtime2text()
	temp.data = data

/// Signal handler to, when a patient is being deleted,
/// delete the datum assigned to them as it won't be viewable anyway
/datum/historic_scan_index/proc/patient_qdeleted(datum/source, force)
	SIGNAL_HANDLER
	var/datum/historic_scan/temp = scans[ref(source)]
	scans.Remove(ref(source))
	qdel(temp)

/// Holds an old body scanner/autodoc scan's TGUI data for later viewing
/datum/historic_scan
	/// `worldtime2text` of when the scan was made
	var/last_scan_time
	/// Archived TGUI health scan data
	var/list/data

/datum/historic_scan/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MedScanner", "Historic Health Scan")
		ui.open()
	ui.set_autoupdate(FALSE)

/datum/historic_scan/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/datum/historic_scan/ui_data(mob/user)
	return data
