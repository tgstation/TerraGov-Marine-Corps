import { useBackend } from '../../backend';
import {
  Button,
  ColorBox,
  LabeledList,
  Section,
  Stack,
  Tooltip,
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
              <Tooltip content="Use more accessible TGUI themes/layouts wherever possible.">
                <ToggleFieldPreference
                  label="Accessible TGUI themes"
                  value="accessible_tgui_themes"
                  action="accessible_tgui_themes"
                />
              </Tooltip>
              <ToggleFieldPreference
                label="Fullscreen mode"
                value="fullscreen_mode"
                action="fullscreen_mode"
                leftLabel={'Fullscreen'}
                rightLabel={'Windowed'}
              />
              <ToggleFieldPreference
                label="Status Bar (Bottom left text)"
                value="show_status_bar"
                action="show_status_bar"
                leftLabel={'Show'}
                rightLabel={'Hide'}
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
                label="Runechat message limit"
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
                label={'UI Alpha'}
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
            <Section title="Administration (admin only)">
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
                />
                <ToggleFieldPreference
                  label="Toggle adminhelp sound"
                  value="toggle_adminhelp_sound"
                  action="toggle_adminhelp_sound"
                  leftLabel={'Enabled'}
                  rightLabel={'Disabled'}
                />
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
