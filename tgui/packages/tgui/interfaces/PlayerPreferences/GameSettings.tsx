import { useBackend } from '../../backend';
import {
  Button,
  ColorBox,
  LabeledList,
  Section,
  Stack,
} from '../../components';
import {
  LoopingSelectionPreference,
  SelectFieldPreference,
  TextFieldPreference,
  ToggleFieldPreference,
} from './FieldPreferences';

const ParallaxNumToString = (integer) => {
  let returnval = '';
  switch (integer) {
    case -1:
      returnval = 'Insane';
      break;
    case 0:
      returnval = 'High';
      break;
    case 1:
      returnval = 'Medium';
      break;
    case 2:
      returnval = 'Low';
      break;
    case 3:
      returnval = 'Disabled';
      break;
    default:
      returnval = 'Error!';
  }
  return returnval;
};

export const GameSettings = (props) => {
  const { act, data } = useBackend<GameSettingData>();
  const { ui_style_color, scaling_method, pixel_size, parallax, is_admin } =
    data;

  // Remember to update this alongside defines
  // todo: unfuck. Bruh why is this being handled in the tsx?
  const TTSRadioSetting = ['sl', 'squad', 'command', 'hivemind', 'all'];
  const TTSRadioSettingToBitfield = {
    sl: 1 << 0,
    squad: 1 << 1,
    command: 1 << 2,
    all: 1 << 3,
    hivemind: 1 << 4,
  };
  const TTSRadioSettingToName = {
    sl: 'Squad Leader',
    squad: 'Squad',
    command: 'Command/Hive Leader',
    hivemind: 'Hivemind',
    all: 'All Channels',
  };

  return (
    <Section title="Game Settings">
      <Stack fill>
        <Stack.Item grow>
          <Section title="Window settings">
            <LabeledList>
              <ToggleFieldPreference
                label="Window flashing"
                value="windowflashing"
                action="windowflashing"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="Enables the game icon to flash on your taskbar."
              />
              <ToggleFieldPreference
                label="Unique action behaviour"
                value="unique_action_use_active_hand"
                action="unique_action_use_active_hand"
                leftLabel={'Use on active hand'}
                rightLabel={'Use on both hands'}
              />
              <ToggleFieldPreference
                label="Mute xeno health alert messages"
                value="mute_xeno_health_alert_messages"
                action="mute_xeno_health_alert_messages"
                leftLabel={'Muted'}
                rightLabel={'Enabled'}
              />
              <SelectFieldPreference
                label="Play Text-to-Speech"
                value="sound_tts"
                action="sound_tts"
                tooltip="Enables receiving TTS lines, only blips, or nothing at all."
              />
              <TextFieldPreference
                label="Text to speech volume"
                value="volume_tts"
                tooltip="Controls the volume of TTS lines/blips."
              />
              <LabeledList.Item label={'Text to Speech radio configuration'}>
                {TTSRadioSetting.map((setting) => (
                  <Button.Checkbox
                    inline
                    key={setting}
                    content={TTSRadioSettingToName[setting]}
                    checked={
                      TTSRadioSettingToBitfield[setting] &
                      data['radio_tts_flags']
                    }
                    onClick={() =>
                      act('toggle_radio_tts_setting', {
                        newsetting: setting,
                      })
                    }
                  />
                ))}
              </LabeledList.Item>
              <ToggleFieldPreference
                label="Accessible TGUI themes"
                value="accessible_tgui_themes"
                action="accessible_tgui_themes"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="Try to use more accessible or default TGUI themes/layouts wherever possible."
              />
              <ToggleFieldPreference
                label="Fullscreen mode"
                value="fullscreen_mode"
                action="fullscreen_mode"
                leftLabel={'Fullscreen'}
                rightLabel={'Windowed'}
              />
              <ToggleFieldPreference
                label="TGUI Window Mode"
                value="tgui_fancy"
                action="tgui_fancy"
                leftLabel={'Fancy (default)'}
                rightLabel={'Compatible (slower)'}
                tooltip="Fancy will use a baked-in web view topbar for TGUI window title/exit button. Compatible will use the Dream Seeker native topbar."
              />
              <ToggleFieldPreference
                label="TGUI Window Placement"
                value="tgui_lock"
                action="tgui_lock"
                leftLabel={'Free (default)'}
                rightLabel={'Primary monitor'}
              />
              <ToggleFieldPreference
                label="TGUI Input boxes"
                value="tgui_input"
                action="tgui_input"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="TGUI Input Buttons"
                value="tgui_input_big_buttons"
                action="tgui_input_big_buttons"
                leftLabel={'Normal'}
                leftValue={0}
                rightLabel={'Large'}
                rightValue={1}
              />
              <ToggleFieldPreference
                label="TGUI Input Buttons placement"
                value="tgui_input_buttons_swap"
                action="tgui_input_buttons_swap"
                leftLabel={'Submit/Cancel'}
                rightLabel={'Cancel/Submit'}
              />
              <ToggleFieldPreference
                label="Tooltips"
                value="tooltips"
                action="tooltips"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="This controls if HTML tooltips on screen alerts/abilities and such are active. No effect on TGUI content."
              />
              <TextFieldPreference
                label={'FPS'}
                value={'clientfps'}
                tooltip="The limit for the game viewport's FPS."
              />
              <ToggleFieldPreference
                label="Auto Fit viewport"
                value="auto_fit_viewport"
                action="auto_fit_viewport"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="When your view range changes, this will automatically run the Fit Viewport command."
              />
              <ToggleFieldPreference
                label="Auto interact with Deployables"
                value="autointeractdeployablespref"
                action="autointeractdeployablespref"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="When enabled, automatically interacts with deployables after you set them up."
              />
              <ToggleFieldPreference
                label="Use directional attacks"
                value="directional_attacks"
                action="directional_attacks"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="When enabled, allows you to attack directionally with melee weapons by clicking in a direction, in addition to bump attacks and sprite clicking."
              />
            </LabeledList>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Message settings">
            <LabeledList>
              <ToggleFieldPreference
                label="Runechat bubbles"
                value="chat_on_map"
                action="chat_on_map"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
                tooltip="Shows messages above other humans/xenos when they are speaking."
              />
              <TextFieldPreference
                label="Runechat character limit"
                value="max_chat_length"
                tooltip="How long a runechat bubble can be before it's truncated."
              />
              <ToggleFieldPreference
                label="Show non-mob runechat"
                value="see_chat_non_mob"
                action="see_chat_non_mob"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
                tooltip="If runechat bubbles are enabled, shows messages above objects when they are speaking."
              />
              <ToggleFieldPreference
                label="Show emotes in runechat"
                value="see_rc_emotes"
                action="see_rc_emotes"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
                tooltip="Whether emotes will also appear in runechat."
              />
              <ToggleFieldPreference
                label="Show typing indicator"
                value="show_typing"
                action="show_typing"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
                tooltip="Enables speech indicators when you are typing into tgui say windows."
              />
              <ToggleFieldPreference
                label="Show self combat messages"
                value="mute_self_combat_messages"
                action="mute_self_combat_messages"
                leftValue={0}
                leftLabel={'Enabled'}
                rightValue={1}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Show others combat messages"
                value="mute_others_combat_messages"
                action="mute_others_combat_messages"
                leftValue={0}
                leftLabel={'Enabled'}
                rightValue={1}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Show xeno rank"
                value="show_xeno_rank"
                action="show_xeno_rank"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <Section title="UI settings">
            <LabeledList>
              <SelectFieldPreference
                label={'UI Style'}
                value={'ui_style'}
                action={'ui'}
              />
              <TextFieldPreference
                label={'UI Color'}
                value={'ui_style_color'}
                noAction
                extra={
                  <>
                    <ColorBox color={ui_style_color} mr={1} />
                    <Button icon="edit" onClick={() => act('uicolor')} />
                  </>
                }
              />
              <TextFieldPreference
                label={'UI Opacity'}
                value={'ui_style_alpha'}
                action={'uialpha'}
                tooltip="The opacity of the game UI. Higher = more visible."
              />
              <ToggleFieldPreference
                label="Widescreen mode"
                value="widescreenpref"
                action="widescreenpref"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="When enabled, the game viewport will be wider to look better with modern aspect ratios."
              />
              <ToggleFieldPreference
                label="Radial medical wheel"
                value="radialmedicalpref"
                action="radialmedicalpref"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="When enabled, medical items will use a radial menu for targeting limbs. Otherwise, they will use your selected limb zone."
              />
              <ToggleFieldPreference
                label="Radial stacks wheel"
                value="radialstackspref"
                action="radialstackspref"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="When enabled, stacks with a radial menu implemented will use that by default. Otherwise, a window will open for viewing recipes."
              />
              <ToggleFieldPreference
                label="Radial laser gun wheel"
                value="radiallasersgunpref"
                action="radiallasersgunpref"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="When enabled, laser weapons with multiple modes will use a radial mode for choosing modes on Unique Action. Otherwise, pressing Unique Action will cycle through modes."
              />
              <LoopingSelectionPreference
                label="Scaling Method"
                value={scaling_method}
                action="scaling_method"
                tooltip="How the game viewport will adjust to the window size. Distort recommended for large screens."
              />
              <LoopingSelectionPreference
                label="Pixel Size Scaling"
                value={pixel_size}
                action="pixel_size"
                tooltip="Changes the size of pixels in the game viewport. Values other than default may change the difficulty of the game."
              />
              <LoopingSelectionPreference
                label="Parallax"
                value={ParallaxNumToString(parallax)}
                action="parallax"
                tooltip="The quality level of parallaxing on space tiles."
              />
            </LabeledList>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Sound settings">
            <LabeledList>
              <ToggleFieldPreference
                label="Toggle admin music"
                value="toggle_admin_music"
                action="toggle_admin_music"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="Enable or disable hearing admin MIDIs and web sounds."
              />
              <ToggleFieldPreference
                label="Toggle ambience sound"
                value="toggle_ambience_sound"
                action="toggle_ambience_sound"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="Enable or disable hearing SS13 and map ambience."
              />
              <ToggleFieldPreference
                label="Toggle lobby music"
                value="toggle_lobby_music"
                action="toggle_lobby_music"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="Enable or disable hearing music in the lobby."
              />
              <ToggleFieldPreference
                label="Toggle instruments sound"
                value="toggle_instruments_sound"
                action="toggle_instruments_sound"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="Enable or disable hearing instruments from others and yourself."
              />
              <ToggleFieldPreference
                label="Toggle weather sound"
                value="toggle_weather_sound"
                action="toggle_weather_sound"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Toggle round end sounds"
                value="toggle_round_end_sounds"
                action="toggle_round_end_sounds"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="Enable or disable hearing jingles when the server restarts."
              />
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
      {!!is_admin && (
        <Stack>
          <Stack.Item grow>
            <Section title="Staff settings">
              <LabeledList>
                <ToggleFieldPreference
                  label="Fast MC Refresh"
                  value="fast_mc_refresh"
                  action="fast_mc_refresh"
                  leftLabel={'Enabled'}
                  rightLabel={'Disabled'}
                />
                <ToggleFieldPreference
                  label="Split admin tabs"
                  value="split_admin_tabs"
                  action="split_admin_tabs"
                  leftLabel={'Enabled'}
                  rightLabel={'Disabled'}
                  tooltip="When enabled, staff commands will be split into multiple tabs (Admin/Fun/etc). Otherwise, non-debug commands will remain in one statpanel tab."
                />
                <ToggleFieldPreference
                  label="Toggle adminhelp sound"
                  value="toggle_adminhelp_sound"
                  action="toggle_adminhelp_sound"
                  leftLabel={'Enabled'}
                  rightLabel={'Disabled'}
                />
                <ToggleFieldPreference
                  label="Hear LOOC from anywhere"
                  value="hear_looc_anywhere_as_staff"
                  action="hear_looc_anywhere_as_staff"
                  leftLabel={'Enabled'}
                  rightLabel={'Disabled'}
                  tooltip="Enables hearing LOOC from anywhere in any situation. For Mentors, this setting is only relevant when observing."
                />
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
