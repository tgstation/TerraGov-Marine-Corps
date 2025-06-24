import {
  Button,
  ColorBox,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  LoopingSelectionPreference,
  SelectFieldPreference,
  TextFieldPreference,
  ToggleFieldPreference,
} from './FieldPreferences';

const MultiZPerfToString = (integer) => {
  let returnval = '';
  switch (integer) {
    case -1:
      returnval = 'No Culling';
      break;
    case 0:
      returnval = 'Low';
      break;
    case 1:
      returnval = 'Medium';
      break;
    case 2:
      returnval = 'High';
      break;
    default:
      returnval = 'Error!';
  }
  return returnval;
};

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
  const {
    ui_style_color,
    scaling_method,
    pixel_size,
    parallax,
    multiz_performance,
    is_admin,
  } = data;

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
              />
              <TextFieldPreference
                label="Text to speech volume"
                value="volume_tts"
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
                tooltip="Prefer more accessible/default TGUI themes wherever implemented and possible."
              />
              <ToggleFieldPreference
                label="Allow health scan sharing"
                value="allow_being_shown_health_scan"
                action="allow_being_shown_health_scan"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="Governs if others can show you your health scan."
              />
              <ToggleFieldPreference
                label="Fullscreen mode"
                value="fullscreen_mode"
                action="fullscreen_mode"
                leftLabel={'Fullscreen'}
                rightLabel={'Windowed'}
                tooltip="Toggles Windowed Borderless mode"
              />
              <ToggleFieldPreference
                label="Status Bar"
                value="show_status_bar"
                action="show_status_bar"
                leftLabel={'Show'}
                rightLabel={'Hide'}
                tooltip="Whether to show or hide the status bar in the bottom left of the screen"
              />
              <ToggleFieldPreference
                label="Ambient Occlusion"
                value="ambient_occlusion"
                action="ambient_occlusion"
                leftLabel={'On'}
                rightLabel={'Off'}
                tooltip="Whether to render ambient occlusion, which adds a shadow-like effect to floors. Increases performance when off."
              />
              <ToggleFieldPreference
                label="Multi-Z (3D) parallax"
                value="multiz_parallax"
                action="multiz_parallax"
                leftLabel={'On'}
                rightLabel={'Off'}
                tooltip="Toggles parallax applying through multiple Zs. Increases performance when off."
              />
              <LoopingSelectionPreference
                label="Multi-Z Detail"
                value={MultiZPerfToString(multiz_performance)}
                action="multiz_performance"
                tooltip="How many Multi-Z levels are rendered before they start getting culled. Decrease this to improve performance in case of lag on multi-z maps."
              />
              <ToggleFieldPreference
                label="TGUI Window Mode"
                value="tgui_fancy"
                action="tgui_fancy"
                leftLabel={'Fancy (default)'}
                rightLabel={'Compatible (slower)'}
              />
              <ToggleFieldPreference
                label="TGUI Window Placement"
                value="tgui_lock"
                action="tgui_lock"
                leftLabel={'Free (default)'}
                rightLabel={'Primary monitor'}
              />
              <ToggleFieldPreference
                label="UI scaling"
                value="ui_scale"
                action="ui_scale"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="Whether UIs should scale up to match your monitor scaling"
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
              />
              <TextFieldPreference label={'FPS'} value={'clientfps'} />
              <ToggleFieldPreference
                label="Auto Fit viewport"
                value="auto_fit_viewport"
                action="auto_fit_viewport"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Auto interact with Deployables"
                value="autointeractdeployablespref"
                action="autointeractdeployablespref"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Use directional attacks"
                value="directional_attacks"
                action="directional_attacks"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Toggle Click-dragging"
                value="toggle_clickdrag"
                action="toggle_clickdrag"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Toggle Xeno Move Intent Keybind"
                value="toggle_xeno_move_intent_keybind"
                action="toggle_xeno_move_intent_keybind"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
                tooltip="Toggles whether the Toggle Move Intent keybind works when you are a xeno."
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
              />
              <TextFieldPreference
                label="Runechat character limit"
                value="max_chat_length"
              />
              <ToggleFieldPreference
                label="Show non-mob runechat"
                value="see_chat_non_mob"
                action="see_chat_non_mob"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Show emotes in runechat"
                value="see_rc_emotes"
                action="see_rc_emotes"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Show typing indicator"
                value="show_typing"
                action="show_typing"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Toggle bump attacking"
                value="toggle_bump_attacking"
                action="toggle_bump_attacking"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
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
              />
              <ToggleFieldPreference
                label="Widescreen mode"
                value="widescreenpref"
                action="widescreenpref"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Radial medical wheel"
                value="radialmedicalpref"
                action="radialmedicalpref"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Radial stacks wheel"
                value="radialstackspref"
                action="radialstackspref"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Radial laser gun wheel"
                value="radiallasersgunpref"
                action="radiallasersgunpref"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <LoopingSelectionPreference
                label="Scaling Method"
                value={scaling_method}
                action="scaling_method"
              />
              <LoopingSelectionPreference
                label="Pixel Size Scaling"
                value={pixel_size}
                action="pixel_size"
              />
              <LoopingSelectionPreference
                label="Parallax"
                value={ParallaxNumToString(parallax)}
                action="parallax"
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
              />
              <ToggleFieldPreference
                label="Toggle ambience sound"
                value="toggle_ambience_sound"
                action="toggle_ambience_sound"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Toggle lobby music"
                value="toggle_lobby_music"
                action="toggle_lobby_music"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Toggle instruments sound"
                value="toggle_instruments_sound"
                action="toggle_instruments_sound"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
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
                  label="Hear OOC from anywhere"
                  value="hear_ooc_anywhere_as_staff"
                  action="hear_ooc_anywhere_as_staff"
                  leftLabel={'Enabled'}
                  rightLabel={'Disabled'}
                  tooltip="Enables hearing OOC channels from anywhere in any situation."
                />
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
