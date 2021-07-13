import { useBackend } from '../backend';
import { Button, LabeledList, Section, Box, ProgressBar } from '../components';
import { Window } from '../layouts';

export const Sentry = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
      width={360}
      height={320}>
      <Window.Content>
        <Section title={data.name}>
          <LabeledList>
            <LabeledList.Item
              label="Power Cell Status">
              <ProgressBar
                content={data.has_cell
                  ?data.cell_charge + ' W out of ' + data.cell_maxcharge + ' W'
                  : 'No cell inserted'}
                value={data.cell_charge/data.cell_maxcharge}
                ranges={{
                  good: [0.67, Infinity],
                  average: [0.33, 0.67],
                  bad: [-Infinity, 0.33],
                }} />
            </LabeledList.Item>
            <LabeledList.Item
              label="Structural Integrity">
              <ProgressBar
                value={data.health/data.health_max}
                ranges={{
                  good: [0.67, Infinity],
                  average: [0.33, 0.67],
                  bad: [-Infinity, 0.33],
                }} />
            </LabeledList.Item>
            <LabeledList.Item
              label="Current Rounds">
              <ProgressBar
                value={data.rounds/data.rounds_max}
                content={data.rounds + ' out of ' +data.rounds_max}
                ranges={{
                  good: [0.67, Infinity],
                  average: [0.33, 0.67],
                  bad: [-Infinity, 0.33],
                }} />
            </LabeledList.Item>
            <LabeledList.Item
              buttons={
                <Button
                  selected={data.safety_toggle}
                  onClick={() => act('safety')}
                  icon={data.safety_toggle ? "check" : "times"}>
                  Safety
                </Button>
              }
              label="Weapon Safety">
              {data.safety_toggle ? "Only Xenos" : "Everything"}
            </LabeledList.Item>
            <LabeledList.Item
              buttons={
                <Button
                  selected={data.manual_override}
                  onClick={() => act('manual')}
                  icon={data.manual_override ? "check" : "times"}>
                  Manual Override
                </Button>
              }
              label="Manual Override">
            </LabeledList.Item>
            <LabeledList.Item
              buttons={
                <Button
                  selected={data.radial_mode}
                  onClick={() => act('toggle_radial')}
                  icon={data.radial_mode ? "check" : "times"}
                  disabled={!data.has_cell}>
                  Radial Mode
                </Button>
              }
              label="Radial Mode" />
            <LabeledList.Item
              buttons={
                <Button
                  selected={data.alerts_on}
                  onClick={() => act('toggle_alert')}
                  icon={data.alerts_on ? "check" : "times"}>
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
