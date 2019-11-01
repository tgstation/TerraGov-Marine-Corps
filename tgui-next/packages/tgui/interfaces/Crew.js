import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, Box, Table } from '../components';

export const Crew = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const locations = [
    {
      label: "Ship",
      zlevel: "0",
    },
    {
      label: "Planet",
      zlevel: "1",
    },
    {
      label: "Low Orbit",
      zlevel: "2",
    },
  ];
  const tableheaders = [
    {
      label: "Name",
      sortkey: "name",
      icon: "user-alt",
    },
    {
      label: "Rank",
      sortkey: "rank",
      icon: "tag",
    },
    {
      label: "Status",
      sortkey: "status",
      icon: "heartbeat",
    },
    {
      label: "Area",
      sortkey: "area",
      icon: "map-marker-alt",
    },
  ];
  return (
    <Fragment>
      <Section label="Location to scan">
        {locations.map(location => (
          <Button
            key={location.id}
            selected={location.zlevel === data.zlevel}
            onClick={() => act(ref, 'zlevel', { zlevel: location.zlevel})}>
            {location.label}
          </Button>
        ))}
      </Section>
      <Section label="Found signals">
        <Table>
          <Table.Row>
            {tableheaders.map(header => (
              <Table.Cell key={header.id}>
                <Button
                  icon={header.icon}
                  onClick={() => act(ref, 'sortkey', { sortkey: header.sortkey})}>
                  {header.label}
                </Button>
              </Table.Cell>
            ))}
          </Table.Row>
          {data.crewmembers.map(crewmember => (
            <Table.Row key={crewmember.id}>
              <Table.Cell>{crewmember.name}</Table.Cell>
              <Table.Cell>{crewmember.rank}</Table.Cell>
              <Table.Cell
                color={crewmember.status === 0 ? "good" : (crewmember.status === 1 ? "average":"bad")}>
                {crewmember.status === 0 ? "Living" : (crewmember.status === 1 ? "Unconscious":"Deceased")}
              </Table.Cell>
              <Table.Cell>
                {crewmember.sensor_type === 1 && ("Not Available")}
                {crewmember.sensor_type === 2 && (
                  <Fragment>
                    <Box inline color="cyan">{crewmember.oxy}</Box>
                    <Box inline color="green">{crewmember.tox}</Box>
                    <Box inline color="orange">{crewmember.fire}</Box>
                    <Box inline color="red">{crewmember.brute}</Box>
                  </Fragment>
                )}
              </Table.Cell>
              <Table.Cell>
                {crewmember.sensor_type === 3 ? (
                  crewmember.area+" "+crewmember.x+", "+crewmember.y
                ) : (
                  "Not Available"
                )}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Fragment>); };
