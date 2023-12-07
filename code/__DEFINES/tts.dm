#define TTS_SOUND_OFF "Disabled"
#define TTS_SOUND_ENABLED "Enabled"
#define TTS_SOUND_BLIPS "Blips Only"
GLOBAL_LIST_INIT(all_tts_options, list(TTS_SOUND_OFF, TTS_SOUND_ENABLED, TTS_SOUND_BLIPS))

///TTS filter to activate start/stop radio clicks on speech.
#define TTS_FILTER_RADIO "radio"
///TTS filter to activate a silicon effect on speech.
#define TTS_FILTER_SILICON "silicon"
