#define TTS_SOUND_OFF "Disabled"
#define TTS_SOUND_ENABLED "Enabled"
#define TTS_SOUND_BLIPS "Blips Only"
GLOBAL_LIST_INIT(all_tts_options, list(TTS_SOUND_OFF, TTS_SOUND_ENABLED, TTS_SOUND_BLIPS))

#define RADIO_TTS_SL (1<<0)
#define RADIO_TTS_SQUAD (1<<1)
#define RADIO_TTS_COMMAND (1<<2)
#define RADIO_TTS_ALL (1<<3)
#define RADIO_TTS_HIVEMIND (1<<4)

GLOBAL_LIST_INIT(all_radio_tts_options, list(RADIO_TTS_SL, RADIO_TTS_SQUAD, RADIO_TTS_COMMAND, RADIO_TTS_ALL, RADIO_TTS_HIVEMIND))

///TTS filter to activate start/stop radio clicks on speech.
#define TTS_FILTER_RADIO "radio"
///TTS filter to activate a silicon effect on speech.
#define TTS_FILTER_SILICON "silicon"
