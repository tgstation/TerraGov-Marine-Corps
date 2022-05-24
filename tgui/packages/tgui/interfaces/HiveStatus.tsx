import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Divider, Box, Section } from '../components';

type InputPack = {
  hive_name: string,
  hive_max_tier_two: number, // Hardcode because hive datum is like this.
  hive_max_tier_three: number,
  xeno_info: XenoData[],
  static_info: StaticData[],
  user_ref: string,
  user_queen: boolean,
  user_watched_xeno: string,
};

type XenoData = {
  ref: string,
  name: string,
  location: string,
  health: number,
  plasma: number,
  is_leader: number, // boolean but is used in bitwise ops.
  is_ssd: boolean,
  index: number, // Corresponding to static data index.
};

type StaticData = {
  name: string,
  is_queen: number, // boolean but is used in bitwise ops.
  minimap: string, // Full minimap icon as string. Not icon_state!
  sort_mod: number,
  tier: number,
  is_unique: boolean,
  calculated_count: number, // Not set from Byond but instead calculated here.
};

export const HiveStatus = (_props, context) => {
  const { data } = useBackend<InputPack>(context);
  const { hive_name } = data;

  return (
    <Window
      title={hive_name + " Hive Status"}
      resizable
      width={700}
      height={800}>
      <Window.Content scrollable>
        <PopulationPyramid />
        <Divider />
        <XenoList />
        <Divider />
      </Window.Content>
    </Window>
  );
};

type PyramidCalc = { // Index is tier.
  caste: number[], // Index is sort_mod.
  index: number[], // Corresponds with static_info index.
  total: number, // Total xeno count for this tier.
};

const PopulationPyramid = (props, context) => {
  const { data } = useBackend<InputPack>(context);
  const {
    hive_max_tier_two,
    hive_max_tier_three,
    xeno_info,
    static_info,
  } = data;

  const pyramid_data: PyramidCalc[] = [];
  let hive_total: number = 0;

  // We could do the really fancy way of creating a list of uniques
  // and then generating equality from unique keys.
  // From there, we record the lengths of those lists
  // to find number of counts per caste.
  // But all these keys are numbers. And this is a lot simplier.

  static_info.map((static_entry, index) => {
    // Inititalizing arrays.
    if (pyramid_data[static_entry.tier] === undefined) {
      pyramid_data[static_entry.tier] = {
        caste: [],
        index: [],
        total: 0,
      };
    }
    pyramid_data[static_entry.tier].caste[static_entry.sort_mod] = 0;
    pyramid_data[static_entry.tier].index[static_entry.sort_mod] = index;
  });

  xeno_info.map((entry) => {
    // Accumulating counts.
    const static_entry = static_info[entry.index];
    pyramid_data[static_entry.tier].caste[static_entry.sort_mod]++;
    pyramid_data[static_entry.tier].total++;
    hive_total++;
  });

  return (
    <Section title={`Total Living Sisters: ${hive_total}`}>
      <Flex direction="column-reverse">
        {pyramid_data.map((tier_info, tier) => {
          // Hardcoded tier check for limited slots.
          const max_slots = tier === 2
            ? hive_max_tier_two
            : 0 + tier === 3
              ? hive_max_tier_three
              : 0;
          const slot_text = tier === 2 || tier === 3
            ? `(${tier_info.total}/${max_slots})`
            : tier_info.total;
          return (
            <Section title={`Tier ${tier}: ${slot_text} Sisters`} key={tier}>
              HELLO WORLD
            </Section>
          );
        })}
      </Flex>
    </Section>
  );
};

const XenoList = (_props, context) => {
  const { act, data } = useBackend<InputPack>(context);
  const {
    xeno_info,
    static_info,
    user_ref,
    user_queen,
    user_watched_xeno,
  } = data;

  // First two bits are taken up by queen and leader flags.
  // Remaining bits 28 split 14 tiers, 14 sort mods.
  // For a total of 16,384 tiers and 16,384 castes per tier.
  // I think that's plenty for everyone.
  const queen = 30;
  const leader = 29;
  const tier = 14;

  return (
    <Section title="Xenomorph List">
      <Flex direction="column-reverse">
        <Flex.Item order={Number.MAX_SAFE_INTEGER}>{/* Header */}
          <Flex bold height="16px">
            <Flex.Item width="16px" mr="4px" />{/* SSD */}
            <Flex.Item width="40px" textAlign="center" mr="4px" />{/* Action Buttons */}
            <Flex.Item width="16px" mr="6px" />{/* Leadership */}
            <Flex.Item width="14px" mr="6px" />{/* Minimap Icon */}
            <Flex.Item width="30%">Caste (Name)</Flex.Item>
            <Flex.Item width="60px">Health</Flex.Item>
            <Flex.Item width="60px">Plasma</Flex.Item>
            <Flex.Item grow>Location</Flex.Item>
          </Flex>
        </Flex.Item>
        <Flex.Item order={1 << queen | 1 << leader | 1 << (leader - 1)}>
          <Divider />
        </Flex.Item>
        {xeno_info.map((entry, index) => {
          const static_entry = static_info[entry.index];
          const order = static_entry.sort_mod
            | static_entry.tier << tier
            | entry.is_leader << leader
            | static_entry.is_queen << queen;
          return (
            <Flex.Item order={order} mb={1} key={index}>
              <Flex height="16px">
                <Flex.Item width="16px" mr="4px">
                  {!!entry.is_ssd
                    && (<Box className="hivestatus16x16 ssdIcon" />)}
                </Flex.Item>
                <Flex.Item width="40px" mr="4px">
                  {user_ref !== entry.ref
                  && <ActionButtons
                    target_ref={entry.ref}
                    is_queen={user_queen}
                    watched_xeno={user_watched_xeno} />}
                </Flex.Item>
                <Flex.Item width="16px" mr="6px">
                  <Button
                    fluid
                    height="16px"
                    fontSize={0.75}
                    tooltip={user_queen ? "Toggle leadership" : ""}
                    verticalAlignContent="middle"
                    icon="star"
                    disabled={static_entry.is_queen}
                    selected={entry.is_leader}
                    opacity={entry.is_leader || user_queen
                      || static_entry.is_queen
                      ? 1
                      : 0.5}
                    onClick={() => act('Leader', { xeno: entry.ref })} />
                </Flex.Item>
                <Flex.Item width="14px" mr="6px">
                  <Box as="img"
                    src={`data:image/jpeg;base64,${static_entry.minimap}`}
                    style={{
                      transform: "scale(2) translateX(2px)", // Upscaled from 7x7 to 14x14.
                      "-ms-interpolation-mode": "nearest-neighbor",
                    }} />
                </Flex.Item>
                <Flex.Item width="30%"
                  nowrap
                  style={{
                    'overflow': 'hidden',
                    'text-overflow': 'ellipsis',
                  }}>
                  {entry.name}
                </Flex.Item>
                <Flex.Item width="60px">
                  {entry.health <= 10 // Health actually ranges from -30 to 100.
                    ? <Box bold textColor="bad">{entry.health}%</Box>
                    : entry.health <= 80
                      ? <Box textColor="average">{entry.health}%</Box>
                      : <Box textColor="good">{entry.health}%</Box>}
                </Flex.Item>
                <Flex.Item width="60px">
                  {entry.plasma <= 33 // Queen SSD?
                    ?<Box bold textColor="bad">{entry.plasma}%</Box>
                    : entry.plasma <= 75 // Queen give plasma plz.
                      ? <Box textColor="average">{entry.plasma}%</Box>
                      : <Box textColor="good">{entry.plasma}%</Box>}
                </Flex.Item>
                <Flex.Item grow
                  nowrap
                  style={{
                    'overflow': 'hidden',
                    'text-overflow': 'ellipsis',
                  }}>
                  {entry.location}
                </Flex.Item>
              </Flex>
            </Flex.Item>
          );
        })}
      </Flex>
    </Section>
  );
};

type ActionButtonProps = {
  target_ref: string,
  is_queen: boolean,
  watched_xeno: string,
};

const ActionButtons = (props: ActionButtonProps, context) => {
  const { act } = useBackend<InputPack>(context);
  const {
    target_ref,
    is_queen,
    watched_xeno,
  } = props;

  const observing = target_ref === watched_xeno;
  const overwatch_button = (<Button
    fluid
    height="16px"
    fontSize={0.75}
    tooltip={observing ? "Cancel" : "Overwatch"}
    align="center"
    verticalAlignContent="middle"
    icon="eye"
    selected={observing}
    onClick={() => act('Follow', { xeno: target_ref })} />);

  if (is_queen) {
    return (
      <Flex direction="row" justify="space-evenly">
        <Flex.Item grow mr="4px">
          {overwatch_button}
        </Flex.Item>
        <Flex.Item grow>
          <Button
            fluid
            height="16px"
            fontSize={0.75}
            tooltip="Transfer plasma"
            align="center"
            verticalAlignContent="middle"
            icon="arrow-down"
            onClick={() => act('Plasma', { xeno: target_ref })} />
        </Flex.Item>
      </Flex>
    );
  }

  return (
    <Flex direction="row">
      <Flex.Item grow>
        {overwatch_button}
      </Flex.Item>
    </Flex>
  );
};
