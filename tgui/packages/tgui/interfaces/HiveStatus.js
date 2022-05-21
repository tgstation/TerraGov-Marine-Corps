import { useBackend } from '../backend';
import { Window } from '../layouts';
import { classes } from 'common/react';
import { Input, Button, Flex, Divider, Collapsible, Icon, NumberInput, Table, ProgressBar } from '../components';

/**
 * General: Psy points - number of xenos, pooled larva, number of minions
 *    Progress bars: Next larva generated. Queen death timer. Hivemind death timer. Silo collapse timer.
 * TODO: Generate hive tier pyramid dynamically from caste type list.
 */
const CasteCounts = (props, context) => {
  const { data } = useBackend(context);
  const {
    xeno_counts,
    is_unique,
    tier_slots,
    user_nicks
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
                    <div>{xeno["Total"]} sister{xeno["Total"] !== 1 && "s"}</div>
                  </i>
                </center>
              </Flex.Item>
              <Flex.Item>
                <center>
                  <Table collapsing>
                    <Table.Row header>
                      {Object.keys(xeno).map((name) => (
                        name !== "Total" && (<Table.Cell width={6} textAlign="center">{name}</Table.Cell>)
                      ))}
                    </Table.Row>
                    <Table.Row>
                      {Object.keys(xeno).map((name) => (
                          name !== "Total" && (<Table.Cell width={6} textAlign="center">{
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
        <Collapsible
          title = "Caste Population Pyramid"
          open
        >
          <CasteCounts />
        </Collapsible>
      </Window.Content>
    </Window>
  );
};
