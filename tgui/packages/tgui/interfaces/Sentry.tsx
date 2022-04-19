import { useBackend } from '../backend';
import { Button, LabeledList, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

type SentryData = {
  name: string
  rounds: number
  rounds_max: number
  fire_mode: string
  health: number
  health_max: number
  safety_toggle: boolean
  manual_override: string
  alerts_on: boolean
  radial_mode: boolean
}
export const Sentry = (props, context) => {
  const { act, data } = useBackend<SentryData>(context);
  const {
    name,
    rounds,
    rounds_max,
    fire_mode,
    health,
    health_max,
    safety_toggle,
    manual_override,
    alerts_on,
    radial_mode,
  } = data;
  return (
    <Window
      width={360}
      height={320}>
      <Window.Content>
        <Section title={name}>
          <LabeledList>
            <LabeledList.Item
              label="Structural Integrity">
              <ProgressBar
                value={health/health_max}
                ranges={{
                  good: [0.67, Infinity],
                  average: [0.33, 0.67],
                  bad: [-Infinity, 0.33],
                }} />
            </LabeledList.Item>
            <LabeledList.Item
              label="Current Rounds">
              <ProgressBar
                value={rounds/rounds_max}
                content={rounds + ' out of ' + rounds_max}
                ranges={{
                  good: [0.67, Infinity],
                  average: [0.33, 0.67],
                  bad: [-Infinity, 0.33],
                }} />
            </LabeledList.Item>
            <LabeledList.Item
              buttons={
                <Button
                  selected={safety_toggle}
                  onClick={() => act('safety')}
                  icon={safety_toggle ? "check" : "times"}>
                  Safety
                </Button>
              }
              label="Weapon Safety">
              {safety_toggle ? "Only Xenos" : "Everything"}
            </LabeledList.Item>
            <LabeledList.Item
              buttons={
                <Button
                  onClick={() => act('firemode')}>
                  Fire Mode
                </Button>
              }
              label="Fire Mode">
              {fire_mode}
            </LabeledList.Item>
            <LabeledList.Item
              buttons={
                <Button
                  selected={manual_override}
                  onClick={() => act('manual')}
                  icon={manual_override ? "check" : "times"}>
                  Manual Override
                </Button>
              }
              label="Manual Override" />
            <LabeledList.Item
              buttons={
                <Button
                  selected={radial_mode}
                  onClick={() => act('toggle_radial')}
                  icon={radial_mode ? "check" : "times"}>
                  Radial Mode
                </Button>
              }
              label="Radial Mode" />
            <LabeledList.Item
              buttons={
                <Button
                  selected={alerts_on}
                  onClick={() => act('toggle_alert')}
                  icon={alerts_on ? "check" : "times"}>
                  Alert Mode
                </Button>
              }
              label="Alert Mode" />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
