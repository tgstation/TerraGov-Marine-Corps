import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, NoticeBox, Section, Box, TitleBar, ProgressBar } from '../components';

export const Sentry = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const cellgood = (0.67 * data.cell_maxcharge);
  const cellaver = (0.33 * data.cell_maxcharge);
  const healgood = (0.67 * data.health_max);
  const healaver = (0.33 * data.health_max);
  const roungood = (0.67 * data.rounds_max);
  const rounaver = (0.33 * data.rounds_max);
  return (
    <Fragment>
      <TitleBar>Sentry Gun</TitleBar>
      <Section title={data.name}
        buttons={
          <Button
            icon="power-off"
            selected={data.is_on}
            onClick={() => act(ref, 'power')}>
            {data.is_on ? 'On' : 'Off'}
          </Button>
        }>
        <LabeledList>
          <LabeledList.Item
            label="Power Cell Status">
            <ProgressBar
              content={data.has_cell?data.cell_charge + ' W out of ' + data.cell_maxcharge + ' W' : 'No cell inserted'}
              value={data.cell_charge/data.cell_maxcharge}
              color={(data.cell_charge > cellgood)?"good":((data.cell_charge > cellaver)?"average":"bad")} />
          </LabeledList.Item>
          <LabeledList.Item
            label="Structural Integrity">
            <ProgressBar
              value={data.health/data.health_max}
              color={(data.health > healgood) ? "good" : ((data.health > healaver) ? "average" : "bad")} />
          </LabeledList.Item>
          <LabeledList.Item
            label="Current Rounds">
            <ProgressBar
              value={data.rounds/data.rounds_max}
              content={data.rounds + ' out of ' +data.rounds_max}
              color={(data.rounds > roungood) ? "good" : ((data.rounds > rounaver) ? "average" : "bad")} />
          </LabeledList.Item>
          <LabeledList.Item
            buttons={
              <Button
                selected={data.burst_fire}
                onClick={() => act(ref, 'burst')}
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
                  onClick={() => act(ref, 'burstup')}
                  icon="plus"
                  disabled={!data.is_on} />
                <Box inline mr={1} ml={1}>{data.burst_size}</Box>
                <Button
                  onClick={() => act(ref, 'burstdown')}
                  icon="minus"
                  disabled={!data.is_on} />
              </Fragment>
            }
            label="Burst Count" />
          <LabeledList.Item
            buttons={
              <Button
                selected={data.safety_toggle}
                onClick={() => act(ref, 'safety')}
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
                  onClick={() => act(ref, 'manual')}
                  icon={data.manual_override ? "check" : "times"}
                  disabled={!data.is_on}>
                  Manual Override
                </Button>
              }
              label="Manual Override">
            </LabeledList.Item>
          )}
          <LabeledList.Item
            buttons={
              <Button
                selected={data.radial_mode}
                onClick={() => act(ref, 'toggle_radial')}
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
                onClick={() => act(ref, 'toggle_alert')}
                icon={data.alerts_on ? "check" : "times"}
                disabled={!data.is_on}>
                  Alert Mode
              </Button>
            }
            label="Alert Mode" />
        </LabeledList>
      </Section>
    </Fragment>); };
