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
      <TitleBar>{data.name}</TitleBar>
      <NoticeBox>
        The {data.name} is currently {data.is_on ? (
          <Box inline color="good">ON</Box>
        ) : (
          <Box inline color="bad">OFF</Box>
        )}
        <Button
          icon="power-off"
          onClick={() => act(ref, 'power')}>
          {data.is_on ? 'Turn Off' : 'Turn On'}
        </Button>
      </NoticeBox>
      <LabeledList>
        <LabeledList.Item
          label="Power Cell Status">
          <Box>
            <ProgressBar
              value={data.cell_charge/data.cell_maxcharge}
              color={(data.cell_charge > cellgood)?"good":((data.cell_charge > cellaver)?"average":"bad")} />
          </Box>
          <Box>
            {data.has_cell ? data.cell_charge + ' W out of ' + data.cell_maxcharge + ' W' : 'No cell inserted'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item
          label="Structural Integrity">
          <ProgressBar
            value={data.health/data.health_max}
            color={(data.health > healgood) ? "good" : ((data.health > healaver) ? "average" : "bad")} />
        </LabeledList.Item>
        <LabeledList.Item
          label="Current Rounds">
          <Box>
            <ProgressBar
              value={data.rounds/data.rounds_max}
              color={(data.rounds > roungood) ? "good" : ((data.rounds > rounaver) ? "average" : "bad")} />
          </Box>
          <Box>
            {data.rounds} out of {data.rounds_max}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item
          label="Burst Fire">
          Burst fire is currently
          {data.burst_fire ? (<Box inline color="good">ON</Box>) : (<Box inline color="bad">OFF</Box>)}
          <br />
          Burst count set to: {data.burst_size}
          <br />
          <Button
            onClick={() => act(ref, 'burst')}
            icon={data.burst_fire ? "step-forward" : "play"}
            disabled={!data.is_on}>
            {data.burst_fire ? "Turn off burst fire" : "Turn on burst fire"}
          </Button>
          <br />
          <Button
            onClick={() => act(ref, 'burstup')}
            icon="plus"
            disabled={!data.is_on}>
            Increment Burst Count
          </Button>
          <br />
          <Button
            onClick={() => act(ref, 'burstdown')}
            icon="minus"
            disabled={!data.is_on}>
            Decrement Burst Count
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="Weapon Safety">
          Safety is currently
          {data.safety_toggle ? (
            <Box inline color="good">ON</Box> +'(Only Xenos will be targeted.)'
          ) : (
            <Box inline color="bad">OFF</Box> +'(Non-Xenos without IFF clearance will be targeted.)'
          )}
          <br />
          <Button
            onClick={() => act(ref, 'safety')}
            icon={data.safety_toggle ? "times" : "check"}
            disabled={!data.is_on}>
            {data.safety_toggle ? "Turn off the safety" : "Turn on the safety"}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="Manual Override">
          Manual override is currently
          {data.manual_override ? (
            <Box inline color="good">ON</Box>
          ) : (
            <Box inline color="bad">OFF</Box>
          )}
          <br />
          <Button
            onClick={() => act(ref, 'manual')}
            icon={data.manual_override ? "times" : "check"}
            disabled={!data.is_on}>
            {data.manual_override ? "Turn off Manual Override" : "Turn on Manual Override"}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="Radial Mode">
          Radial Mode is currently
          {data.radial_mode ? (
            <Box inline color="good">ON</Box>
          ) : (
            <Box inline color="bad">OFF</Box>
          )}
          <br />
          <Button
            onClick={() => act(ref, 'toggle_radial')}
            icon={data.radial_mode ? "times" : "check"}
            disabled={!data.is_on}>
            {data.radial_mode ? "Turn off Radial Mode" : "Turn on Radial Mode"}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="Alert Mode">
          Alert Mode is currently
          {data.alerts_on ? (
            <Box inline color="good">ON</Box>
          ) : (
            <Box inline color="bad">OFF</Box>
          )}
          <br />
          <Button
            onClick={() => act(ref, 'toggle_alert')}
            icon={data.alerts_on ? "times" : "check"}
            disabled={!data.is_on}>
            {data.alerts_on ? "Turn off Alert Mode" : "Turn on Alert Mode"}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Fragment>); };
