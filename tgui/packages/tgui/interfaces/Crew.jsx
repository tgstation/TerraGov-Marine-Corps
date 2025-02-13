import { Box, Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Crew = (props) => {
  const { act, data } = useBackend();
  const locations = [
    {
      label: 'Ship',
      zlevel: '0',
    },
    {
      label: 'Planet',
      zlevel: '1',
    },
    {
      label: 'Low Orbit',
      zlevel: '2',
    },
  ];
  const tableheaders = [
    {
      label: 'Name',
      sortkey: 'name',
      icon: 'user-alt',
    },
    {
      label: 'Rank',
      sortkey: 'rank',
      icon: 'tag',
    },
    {
      label: 'Status',
      sortkey: 'status',
      icon: 'heartbeat',
    },
    {
      label: 'Area',
      sortkey: 'area',
      icon: 'map-marker-alt',
    },
  ];
  return (
    <Window width={900} height={800}>
      <Window.Content scrollable>
        <Section title="Location to scan">
          {locations.map((location) => (
            <Button
              key={location.id}
              selected={location.zlevel === data.zlevel}
              onClick={() => act('zlevel', { zlevel: location.zlevel })}
            >
              {location.label}
            </Button>
          ))}
        </Section>
        <Section title="Found signals">
          <Table>
            <Table.Row>
              {tableheaders.map((header) => (
                <Table.Cell key={header.id}>
                  <Button
                    icon={header.icon}
                    onClick={() => act('sortkey', { sortkey: header.sortkey })}
                  >
                    {header.label}
                  </Button>
                </Table.Cell>
              ))}
            </Table.Row>
            {data.crewmembers.map((crewmember) => (
              <Table.Row key={crewmember.id}>
                <Table.Cell>{crewmember.name}</Table.Cell>
                <Table.Cell>{crewmember.rank}</Table.Cell>
                <Table.Cell
                  color={
                    crewmember.status === 0
                      ? 'good'
                      : crewmember.status === 1
                        ? 'average'
                        : 'bad'
                  }
                >
                  {crewmember.status === 0
                    ? 'Living'
                    : crewmember.status === 1
                      ? 'Unconscious'
                      : 'Deceased'}
                </Table.Cell>
                <Table.Cell>
                  {crewmember.sensor_type === 1 && 'Not Available'}
                  {crewmember.sensor_type === 2 && (
                    <>
                      <Box inline color="cyan">
                        {crewmember.oxy}
                      </Box>
                      <Box inline color="green">
                        {crewmember.tox}
                      </Box>
                      <Box inline color="orange">
                        {crewmember.fire}
                      </Box>
                      <Box inline color="red">
                        {crewmember.brute}
                      </Box>
                    </>
                  )}
                </Table.Cell>
                <Table.Cell>
                  {crewmember.sensor_type === 3
                    ? crewmember.area + ' ' + crewmember.x + ', ' + crewmember.y
                    : 'Not Available'}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
