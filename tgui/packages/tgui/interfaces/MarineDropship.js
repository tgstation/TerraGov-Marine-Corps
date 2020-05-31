import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const MarineDropship = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window>
      <Window.Content scrollable>
        {!data.hijack_state ? (
          <NoticeBox>
            <Box>POSSIBLE HIJACK</Box>
            <Box>SYSTEMS REBOOTING...</Box>
          </NoticeBox>
        ) : (
          <NormalOperation />
        )}
      </Window.Content>
    </Window>
  );
};

const NormalOperation = (props, context) => {
  const { act, data } = useBackend(context);
  const doorLocks = [
    {
      label: "Left",
      name: "left",
      lockdown: data.left,
    },
    {
      label: "Right",
      name: "right",
      lockdown: data.right,
    },
    {
      label: "Rear",
      name: "rear",
      lockdown: data.rear,
    },
  ];
  return (
    <Fragment>
      <Section title="Ship Status">
        {data.ship_status}
      </Section>
      <Section title="Destinations">
        {data.destinations.map(destination => (
          <Box key={destination.id}>
            <Button
              onClick={() => act("move", { move: destination.id })}
              disabled={data.shuttle_mode}>
              {destination.name}
            </Button>
          </Box>
        ))}
      </Section>
      <Section title="Door Controls">
        <LabeledList>
          <LabeledList.Item label="All">
            <Button
              onClick={() => act("lockdown")}
              disabled={data.lockdown === 2}>
              Lockdown
            </Button>
            <Button
              onClick={() => act("release")}
              disabled={data.lockdown === 0}>
              Release
            </Button>
          </LabeledList.Item>
          {doorLocks.map(doorLock => (
            <LabeledList.Item key={doorLock.id} label={doorLock.label}>
              <Button
                onClick={() => act("lock", { lock: doorLock.name })}
                disabled={doorLock.lockdown===2}>
                Lockdown
              </Button>
              <Button
                onClick={() => act("unlock", { unlock: doorLock.name })}
                disabled={doorLock.lockdown===0}>
                Unlock
              </Button>
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    </Fragment>
  );
};

