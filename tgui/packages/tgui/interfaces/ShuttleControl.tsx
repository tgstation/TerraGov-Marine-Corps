import { useBackend } from '../backend';
import { Button, Section, Box, NoticeBox, Table } from '../components';
import { Window } from '../layouts';

type ShuttleControlData = {
  linked_shuttle_name: string;
  // shuttle status is a string that describes the shuttle's status
  shuttle_status: string;
  destinations: Destination[];
  takeoff_delay: number;
  // shuttle mode is a one word string for all types of shuttle modes, igniting etc
};

type Destination = {
  id: string;
  name: string;
  locked: boolean;
};

const DestinationSelection = (props, context) => {
  const { id, name, locked, selectDestination, confirm_message } = props;
  return (
    <Table.Row textAlign="center">
      <Button.Confirm
        my="1px"
        mx={1}
        color="good"
        content={name}
        confirmContent={confirm_message}
        disabled={locked}
        onClick={() => selectDestination(id)}
      />
    </Table.Row>
  );
};

const TakeOffDisplay = (props, context) => {
  const { takeoff_delay } = props;
  if (takeoff_delay <= 0) {
    return null;
  }
  let takeoff_seconds = takeoff_delay * 0.1;
  let takeoff_minutes = Math.round(takeoff_seconds / 60);
  if (!takeoff_delay) {
    return null;
  }
  return (
    <Section class="text-bold" textAlign="center">
      <Box>
        This shuttle takes
        {takeoff_delay > 60
          ? ` ${takeoff_minutes} minutes`
          : ` ${takeoff_delay} seconds`}{' '}
        to ignite it&apos;s engines before takeoff.
      </Box>
    </Section>
  );
};

export const ShuttleControl = (props, context) => {
  const { act, data } = useBackend<ShuttleControlData>(context);
  const {
    linked_shuttle_name,
    shuttle_status,
    destinations = [],
    takeoff_delay,
  } = data;
  return (
    <Window title="Shuttle Control Console" width={400} height={230}>
      <Window.Content>
        <Section>
          {shuttle_status ? (
            <Box class="text-bold" textAlign="center">
              {linked_shuttle_name} - {shuttle_status}
            </Box>
          ) : (
            <NoticeBox class="text-bold" textAlign="center">
              No linked shuttle detected
            </NoticeBox>
          )}
        </Section>
        <TakeOffDisplay takeoff_delay={takeoff_delay} />
        {destinations.length >= 1 ? (
          <Section title="Destinations">
            <Table>
              {destinations.map((DT) => (
                <DestinationSelection
                  key={DT.id}
                  id={DT.id}
                  name={DT.name}
                  locked={DT.locked || destinations.length <= 0}
                  selectDestination={(id) =>
                    act('selectDestination', {
                      destination: id,
                    })
                  }
                />
              ))}
            </Table>
          </Section>
        ) : (
          <NoticeBox textAlign="center">
            No available destinations found!
          </NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};
