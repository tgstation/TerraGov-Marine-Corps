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
    total_xenos,
    xeno_counts,
    tier_slots
  } = data;

  return (
    <Flex
      direction="column-reverse"
      align="center"
    >
      {xeno_counts.map((counts, tier) => {
        const tier_str = (tier + 1).toString(); // Byond lists start at 1.
        return (
          <Flex.Item
            key={tier}
            margin-bottom={tier !== 0 ? 2 : 0}
          >
            <Flex
              direction="column"
              align="center"
            >
              <Flex.Item>
                <h1 className="whiteTitle">Tier {tier_str}</h1>
              </Flex.Item>
                {(tier == 2 || tier == 3) && (
                  <div>
                    {tier_slots[tier_str]} remaining slot{tier_slots[tier_str] !== 1 && "s"}
                  </div>
                )}
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
      width={400}
      height={750}
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
