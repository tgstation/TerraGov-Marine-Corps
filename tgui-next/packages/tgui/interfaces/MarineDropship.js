import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';

export const MarineDropship = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
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
    data.hijack_state !== "hijack_state_normal" ? (
      <NoticeBox>
        <Box>POSSIBLE HIJACK</Box>
        <Box>SYSTEMS REBOOTING...</Box>
      </NoticeBox>
    ) : (
      <Fragment>
        <Section title="Ship Status">
          {data.ship_status}
        </Section>
        <Section title="Destinations">
          {data.destinations.map(destination => (
            <Box key={destination.id}>
              <Button
                onClick={() => act(ref, "move", {
                  move: destination.id,
                })}
                disabled={!(data.shuttle_mode === "idle" || data.shuttle_mode === "call")}>
                {destination.name}
              </Button>
            </Box>
          ))}
        </Section>
        <Section title="Door Controls">
          <LabeledList>
            <LabeledList.Item label="All">
              <Button
                onClick={() => act(ref, "lockdown")}
                disabled={data.lockdown === 2}>
                Lockdown
              </Button>
              <Button
                onClick={() => act(ref, "release")}
                disabled={data.lockdown === 0}>
                Release
              </Button>
            </LabeledList.Item>
            {doorLocks.map(doorLock => (
              <LabeledList.Item key={doorLock.id} label={doorLock.label}>
                <Button
                  onClick={() => act(ref, "lock", {
                    lock: doorLock.name,
                  })}
                  disabled={doorLock.lockdown===2}>
                  Lockdown
                </Button>
                <Button
                  onClick={() => act(ref, "unlock", {
                    unlock: doorLock.name,
                  })}
                  disabled={doorLock.lockdown===0}>
                  Unlock
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Fragment>
    )
  ); };
