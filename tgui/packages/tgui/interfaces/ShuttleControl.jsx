import { Box, Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const DestinationSelection = (props) => {
  const { id, name, locked, selectDestination } = props;
  return (
    <Table.Row textAlign="center">
      <Button
        my="1px"
        mx={1}
        color="good"
        content={name}
        disabled={locked}
        onClick={() => selectDestination(id)}
      />
    </Table.Row>
  );
};

export const ShuttleControl = (props) => {
  const { act, data } = useBackend();
  const { linked_shuttle_name, shuttle_status, destinations = [] } = data;

  return (
    <Window title="Shuttle Control Console" width={400} height={230}>
      <Window.Content>
        <Section>
          {shuttle_status ? (
            <Box textAlign="center">
              <b>{linked_shuttle_name}</b> - <b>{shuttle_status}</b>
            </Box>
          ) : (
            <NoticeBox textAlign="center">
              <b>No linked shuttle detected</b>
            </NoticeBox>
          )}
        </Section>
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
