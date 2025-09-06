/**
 * Holds TGUI data from [/datum/health_scan/ui_data] and [COMSIG_HEALTH_SCAN_DATA] for later viewing.
 * These can be read (or written to, if you have something using a health scanner) wherever needed.
 *
 * Example read usage:
 * ```
 * /obj/structure/closet/bodybag/examine(...)
 * 	var/datum/data/record/medical_record = find_medical_record(some_patient)
 * 	if(!isnull(medical_record?.fields["historic_scan"]))
 * 		. += "<a href='byond://?src=[text_ref(src)];scanreport=1'>Occupant's body scan from [medical_record.fields["historic_scan_time"]]...</a>"
 * // shown to users later in Topic
 * ```
 * Example write usage:
 * ```
 * /obj/machinery/computer/body_scanconsole/proc/on_scanner_data(...)
 * 	SIGNAL_HANDLER
 * 	var/datum/data/record/medical_record = find_medical_record(patient, TRUE)
 * 	var/datum/historic_scan/historic_scan = (medical_record.fields["historic_scan"] ||= new /datum/historic_scan(patient))
 * 	medical_record.fields["historic_scan_time"] = worldtime2text()
 * 	historic_scan.data = data
 * ```
 */
/datum/historic_scan
	/// Archived TGUI health scan data
	var/list/data

/datum/historic_scan/New(mob/living/carbon/human/patient)
	if(!ishuman(patient))
		stack_trace("[type] created with an invalid patient")
		return qdel(src)
	RegisterSignal(patient, COMSIG_QDELETING, PROC_REF(patient_qdeleted))

/// Signal handler to self destruct when the assigned patient is deleted
/// because this datum will be orphaned and unviewable permanently anyway
/datum/historic_scan/proc/patient_qdeleted(mob/living/carbon/human/source, force)
	SIGNAL_HANDLER
	var/datum/data/record/final_record = find_medical_record(source)
	if(isnull(final_record))
		return qdel(src)
	final_record.fields["historic_scan"] = null
	final_record.fields["historic_scan_time"] = 0
	qdel(src)

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
