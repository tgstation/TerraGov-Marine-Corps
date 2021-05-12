import { useBackend } from '../../backend';
import { Button, Section, LabeledList, Grid, ColorBox } from '../../components';
import { ToggleFieldPreference, TextFieldPreference, SelectFieldPreference } from './FieldPreferences';

export const GameSettings = (props, context) => {
  const { act, data, config } = useBackend<PlayerPreferencesData>(context);
  const { ui_style_color } = data;
  return (
    <Section title="Game Settings">
      <Grid>
        <Grid.Column>
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
                label="Focus Chat"
                value="focus_chat"
                action="focus_chat"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Mute xeno health alert messages"
                value="mute_xeno_health_alert_messages"
                action="mute_xeno_health_alert_messages"
                leftLabel={'Muted'}
                rightLabel={'Enabled'}
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
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
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
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Show others combat messages"
                value="mute_others_combat_messages"
                action="mute_others_combat_messages"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
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
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column />
      </Grid>
    </Section>
  );
};
