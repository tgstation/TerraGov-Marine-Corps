import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

export const MarineDropship = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
      width={500}
      height={600}>
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
  const delayBetweenFlight = [
    0,
    15,
    30,
    45,
    60,
  ];
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
    <>
      <Section title="Ship Status">
        {data.ship_status}
      </Section>
      <Section title="Automation Status">
        <Button
          onClick={() => act("automation_on", { automation_on: 1 })}
          selected={data.automatic_cycle_on}>
          On
        </Button>
        <Button
          onClick={() => act("automation_on", { automation_on: 0 })}
          selected={!data.automatic_cycle_on}>
          Off
        </Button>
      </Section>
      <Section title="Cycle Time">
        <Stack>
          {delayBetweenFlight.map(time_between_cycle => {
            return (
              <Stack.Item
                key={time_between_cycle}>
                <Button
                  onClick={() => act("cycle_time_change", { cycle_time_change: time_between_cycle })}
                  selected={data.time_between_cycle === time_between_cycle}>
                  {time_between_cycle ? time_between_cycle + " Seconds" : "Instantaneous"}
                </Button>
              </Stack.Item>
            );
          })}
        </Stack>
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
    </>
  );
};
