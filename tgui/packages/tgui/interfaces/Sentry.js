import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Box, TitleBar, ProgressBar } from '../components';
import { Window } from '../layouts';

export const Sentry = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window>
      <Window.Content>
        <Section title={data.name}
          buttons={
            <Button
              icon="power-off"
              selected={data.is_on}
              onClick={() => act('power')}>
              {data.is_on ? 'On' : 'Off'}
            </Button>
          }>
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
                  selected={data.burst_fire}
                  onClick={() => act('burst')}
                  icon={data.burst_fire ? "step-forward" : "play"}
                  disabled={!data.is_on}>
                  Burst Fire
                </Button>
              }
              label="Burst Fire" />
            <LabeledList.Item
              buttons={
                <Fragment>
                  <Button
                    onClick={() => act('burstup')}
                    icon="plus"
                    disabled={!data.is_on} />
                  <Box inline mr={1} ml={1}>{data.burst_size}</Box>
                  <Button
                    onClick={() => act('burstdown')}
                    icon="minus"
                    disabled={!data.is_on} />
                </Fragment>
              }
              label="Burst Count" />
            <LabeledList.Item
              buttons={
                <Button
                  selected={data.safety_toggle}
                  onClick={() => act('safety')}
                  icon={data.safety_toggle ? "check" : "times"}
                  disabled={!data.is_on}>
                  Safety
                </Button>
              }
              label="Weapon Safety">
              {data.safety_toggle ? "Only Xenos" : "Everything"}
            </LabeledList.Item>
            {!data.mini && (
              <LabeledList.Item
                buttons={
                  <Button
                    selected={data.manual_override}
                    onClick={() => act('manual')}
                    icon={data.manual_override ? "check" : "times"}
                    disabled={!data.is_on}>
                    Manual Override
                  </Button>
                }
                label="Manual Override" />
            )}
            <LabeledList.Item
              buttons={
                <Button
                  selected={data.radial_mode}
                  onClick={() => act('toggle_radial')}
                  icon={data.radial_mode ? "check" : "times"}
                  disabled={!data.is_on}>
                  Radial Mode
                </Button>
              }
              label="Radial Mode" />
            <LabeledList.Item
              buttons={
                <Button
                  selected={data.alerts_on}
                  onClick={() => act('toggle_alert')}
                  icon={data.alerts_on ? "check" : "times"}
                  disabled={!data.is_on}>
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
