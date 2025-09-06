//! Defines related to health analyzers and advice.

/// Default track distance for health scan functionality
#define TRACK_DISTANCE_DEFAULT 3
/// Disables live updating in effect
#define TRACK_DISTANCE_DISABLED 0

/// The actual advice text.
/// Should be short enough that it only spans one line on the default width
/// of the scanner window, otherwise it looks ugly.
#define ADVICE_TEXT "advice"
/// The tooltip when hovering over this advice
#define ADVICE_TOOLTIP "tooltip"
/// The FA_ICON for this advice
#define ADVICE_ICON "icon"
/// The color of the advice's icon.
/// Can be a HEX color code, TGUI map color or Juke map color.
#define ADVICE_ICON_COLOR "color"

/// High priority override for obvious reasons
#define ADVICE_PRIORITY_EMBRYO -2
/// Ditto: some chems react negatively with others and medics
/// should be made aware of this as fast as possible
#define ADVICE_PRIORITY_CHEM_MIX -1
/// This override is a relic from the old advice system.
/// This was the very first advice to be handled then so it'll be that way here too.
/// *(this is planned to be reworked in the future along with species advice)*
#define ADVICE_PRIORITY_MAX_HEALTH 1
/// This override is a relic from the old advice system.
/// This was the very second advice to be handled then so it'll be that way here too.
/// *(this is planned to be reworked in the future along with health advice)*
#define ADVICE_PRIORITY_SPECIES 2
/// Priority override for revival tips
#define ADVICE_PRIORITY_REVIVAL 3
/// Priority override for damage treatment
#define ADVICE_PRIORITY_DAMAGE 4
/// Priority override for critical condition
#define ADVICE_PRIORITY_CRIT 5
/// Priority override for pain advice
#define ADVICE_PRIORITY_SHOCK 6
/// Priority override for limb advice
#define ADVICE_PRIORITY_LIMBS 7
/// Default priority for advice datums
#define ADVICE_PRIORITY_DEFAULT 14
