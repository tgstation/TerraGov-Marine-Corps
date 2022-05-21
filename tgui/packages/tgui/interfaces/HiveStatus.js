import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Divider, Collapsible, Icon, Table, ProgressBar } from '../components';

/**
 * General: Psy points - number of xenos, pooled larva, number of minions
 *    Progress bars: Next larva generated. Queen death timer. Hivemind death timer. Silo collapse timer.
 * TODO: Generate hive tier pyramid dynamically from caste type list.
 */
const CasteCounts = (_props, context) => {
  const { data } = useBackend(context);
  const {
    xeno_counts,
    is_unique,
    tier_slots
  } = data;

  return (
    <Flex direction="column-reverse">
      {xeno_counts.map((xeno, tier) => {
        const tier_str = (tier + 1).toString(); // Byond lists start at 1.
        return (
          <Flex.Item mb={tier !== 0 ? 2 : 0}>
            <Flex direction="column">
              <Flex.Item mb={1}>
                <center>
                  <h1 className="whiteTitle">Tier {tier}</h1>
                  <i>
                    {(tier === 2 || tier === 3) && (
                      <div>{tier_slots[tier_str]} remaining slot{tier_slots[tier_str] !== 1 && "s"}</div>
                    )}
                    <div>{xeno.total} sister{xeno.total !== 1 && "s"}</div>
                  </i>
                </center>
              </Flex.Item>
              <Flex.Item>
                <center>
                  <Table collapsing>
                    <Table.Row header>
                      {Object.keys(xeno).map((name) => (
                        name !== "total" && (<Table.Cell width={6} textAlign="center">{name}</Table.Cell>)
                      ))}
                    </Table.Row>
                    <Table.Row>
                      {Object.keys(xeno).map((name) => (
                          name !== "total" && (<Table.Cell width={6} textAlign="center">{
                            !!is_unique[tier][name]
                              ? xeno[name] >= 1
                                ? "Alive"
                                : "N/A"
                              : xeno[name]
                          }</Table.Cell>)
                      ))}
                    </Table.Row>
                  </Table>
                </center>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        );
      })}
    </Flex>
  );
}

const critical = {
  color: "red"
}

const damaged = {
  color: "orange"
}

const healthy = {
  color: "green"
}

const XenoList = (props, context) => {
  const { data } = useBackend(context);
  const {
    xeno_info
  } = data;

  return (
    <Flex direction="column">
    <Table>
      <Table.Row header>
        <Table.Cell width="50px" />
        <Table.Cell width="30%" textAlign="center">Name</Table.Cell>
        <Table.Cell textAlign="center">Location</Table.Cell>
        <Table.Cell width="75px">Health</Table.Cell>
        <Table.Cell width="75px">Plasma</Table.Cell>
        <Table.Cell width="10%" />
      </Table.Row>
      {xeno_info.map((entry) => (
        <Table.Row>
          <Table.Cell />
          <Table.Cell>{entry.name}</Table.Cell>
          <Table.Cell>{entry.location}</Table.Cell>
          <Table.Cell>{
            entry.health <= 10 //Health actually ranges from -30 to 100.
              ? <b style={critical}>{entry.health}%</b>
              : entry.health <= 80
                ? <span style={damaged}>{entry.health}%</span>
                : <span style={healthy}>{entry.health}%</span>
            }
          </Table.Cell>
          <Table.Cell>{
            entry.plasma <= 33
              ? <b style={critical}>{entry.plasma}%</b>
              : entry.plasma <= 66
                ? <span style={damaged}>{entry.plasma}%</span>
                : <span style={healthy}>{entry.plasma}%</span>
            }</Table.Cell>
          <Table.Cell />
        </Table.Row>
      ))}
    </Table>
    </Flex>
  );
}

export const HiveStatus = (props, context) => {
  const { data } = useBackend(context);
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
