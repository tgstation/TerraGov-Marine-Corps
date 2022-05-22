import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Divider, Collapsible, Icon, Table, Box, ProgressBar } from '../components';
import { TableCell } from '../components/Table';

/**
 * General: Psy points - number of xenos, pooled larva, number of minions
 *    Progress bars: Next larva generated. Queen death timer. Hivemind death timer. Silo collapse timer.
 * TODO: Generate hive tier pyramid dynamically from caste type list.
 */
const CasteCounts = (props, context) => {
  const { data } = useBackend<HiveData>(context);
  const {
    xeno_counts,
    is_unique,
    tier_slots
  } = data;

  return (
    <Flex direction="column-reverse" align="center">
      {xeno_counts.map((xeno, tier: number) => {
        const tier_str = (tier + 1).toString(); // Byond lists start at 1.
        return (
          <Flex.Item mb={tier !== 0 ? 2 : 0}>
            <Flex direction="column">
              <Flex.Item mb={1}>
                <h1 className="whiteTitle" style="text-align:center">Tier {tier}</h1>
                {(tier === 2 || tier === 3) && (
                  <Box italic textAlign="center">{tier_slots[tier_str]} remaining slot{tier_slots[tier_str] !== 1 && "s"}</Box>
                )}
                <Box italic textAlign="center">{xeno.total} sister{xeno.total !== 1 && "s"}</Box>
              </Flex.Item>
              <Flex.Item>
                <Table collapsing>
                  <Table.Row header>
                    {Object.keys(xeno).map((name) => (
                      name !== "total" && (<Table.Cell width={6} textAlign="center">{name}</Table.Cell>)
                    ))}
                  </Table.Row>
                  <Table.Row>
                    {Object.keys(xeno).map((name) => (
                        name !== "total" && (<Table.Cell width={6} textAlign="center">{
                          is_unique[tier][name]
                            ? xeno[name] >= 1
                              ? "Alive"
                              : "N/A"
                            : xeno[name]
                        }</Table.Cell>)
                    ))}
                  </Table.Row>
                </Table>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        );
      })}
    </Flex>
  );
}

const XenoList = (props, context) => {
  const { data } = useBackend<HiveData>(context);
  const {
    xeno_info
  } = data;

  return (
    <Flex width="100%">
      <Flex.Item width="16px" />
      <Flex.Item width="16px" />
      <Flex.Item width="30%" textAlign="center">Name</Flex.Item>
      <Flex.Item textAlign="center" grow={1}>Location</Flex.Item>
      <Flex.Item width="75px">Health</Flex.Item>
      <Flex.Item width="75px">Plasma</Flex.Item>
      <Flex.Item width="10%" />
    </Flex>
    // <Flex direction="column">
    // <Table>
    //   <Table.Row header>
    //     <Table.Cell width="16px" />
    //     <Table.Cell width="16px" />
    //     <Table.Cell width="30%" textAlign="center">Name</Table.Cell>
    //     <Table.Cell textAlign="center">Location</Table.Cell>
    //     <Table.Cell width="75px">Health</Table.Cell>
    //     <Table.Cell width="75px">Plasma</Table.Cell>
    //     <Table.Cell width="10%" />
    //   </Table.Row>
    //   {xeno_info.map((entry) => (
    //     <Table.Row>
    //       <Table.Cell>{(!!entry.is_leader || !!entry.is_queen) && (<Box className={'hivestatus16x16 leaderIcon'} />)}</Table.Cell>
    //       <Table.Cell>{!!entry.is_ssd && (<Box className={'hivestatus16x16 ssdIcon'} />)}</Table.Cell>
    //       <Table.Cell>{entry.name}</Table.Cell>
    //       <Table.Cell>{entry.location}</Table.Cell>
    //       <Table.Cell>{
    //         entry.health <= 10 //Health actually ranges from -30 to 100.
    //           ? <Box bold textColor="red">{entry.health}%</Box>
    //           : entry.health <= 80
    //             ? <Box textColor="orange">{entry.health}%</Box>
    //             : <Box textColor="green">{entry.health}%</Box>
    //         }
    //       </Table.Cell>
    //       <Table.Cell>{
    //         entry.plasma <= 33
    //           ?<Box bold textColor="red">{entry.plasma}%</Box>
    //           : entry.plasma <= 75 // Queen give plasma plz.
    //             ? <Box textColor="orange">{entry.plasma}%</Box>
    //             : <Box textColor="green">{entry.plasma}%</Box>
    //         }</Table.Cell>
    //       <Table.Cell />
    //     </Table.Row>
    //   ))}
    // </Table>
    // </Flex>
  );
}

type HiveData = {
  hive_name: string,
  is_unique: Boolean[],
  xeno_counts: any,
  tier_slots: any,
  xeno_info: InfoData[]
}

type InfoData = {
  ref: string,
  name: string,
  location: string,
  health: number,
  plasma: number,
  is_leader: Boolean,
  is_queen: Boolean,
  is_ssd: Boolean
}

export const HiveStatus = (props, context) => {
  const { data } = useBackend<HiveData>(context);
  const { hive_name } = data;

  return (
    <Window
      title={hive_name + " Hive Status"}
      resizable
      width={700}
      height={800}
    >
      <Window.Content scrollable>
        <Collapsible title = "Caste Population Pyramid" open>
          <CasteCounts />
        </Collapsible>
        <Divider />
        <Collapsible title = "Xenomorph List" open>
          <XenoList />
        </Collapsible>
        <Divider />
      </Window.Content>
    </Window>
  );
};
