import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, NoticeBox } from '../components';

export const MarineDropship = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const doorLocks = [
    {
      label: "Left",
      name: "left",
    },
    {
      label: "Right",
      name: "right",
    },
    {
      label: "Rear",
      name: "rear",
    },
  ];

  return (
    data.hijack_state ? (
      <NoticeBox>
        <Box>POSSIBLE HIJACK</Box>
        <Box>SYSTEMS REBOOTING...</Box>
      </NoticeBox>
    ) : (
      <Fragment>
        <NoticeBox>
          Ship Status <br />
          {data.ship_status}
        </NoticeBox>
        <LabeledList>
          {data.destinations.map(destination => (
            <LabeledList.Item key={destination.id}>
              <Button
                onClick={() => act(ref, "move", {
                  move: destination.id,
                })}
                disabled={!(data.shuttle_mode === "idle" || data.shuttle_mode === "call")}
                content={destination.name} />
            </LabeledList.Item>
          ))}
        </LabeledList>
        <LabeledList label="Door Controls">
          <LabeledList.Item label="All">
            <Button
              onClick={() => act(ref, "lockdown")}
              content="Lockdown" />
            <Button
              onClick={() => act(ref, "release")}
              content="Release" />
          </LabeledList.Item>
          {doorLocks.map(doorLock => (
            <LabeledList.Item key={doorLock.id} label={doorLock.label}>
              <Button
                onClick={() => act(ref, "lock", {
                  lock: doorLock.name,
                })}
                content="Lockdown" />
              <Button
                onClick={() => act(ref, "unlock", {
                  unlock: doorLock.name,
                })}
                content="Unlock" />
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Fragment>
    )
  ); };
