import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Divider, Box, Section, Collapsible, ProgressBar } from '../components';
import { round } from 'common/math';

type InputPack = {
  // ------- Hive info --------
  hive_name: string,
  hive_max_tier_two: number,
  hive_max_tier_three: number,
  // ------- Data info --------
  xeno_info: XenoData[],
  static_info: StaticData[],
  // ------- User info --------
  user_ref: string,
  user_xeno: boolean,
  user_index: number,
  user_queen: boolean,
  user_watched_xeno: string,
  user_evolution: number,
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
  can_transfer_plasma: boolean,
  evolution_max: number,
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
        <Collapsible title="General Information" open>
          <GeneralInfo />
        </Collapsible>
        <Collapsible title="Hive Population" open>
          <PopulationPyramid />
        </Collapsible>
        <Divider />
        <Collapsible title="Xenomorph List" open>
          <XenoList />
        </Collapsible>
        <Divider />
      </Window.Content>
    </Window>
  );
};

const GeneralInfo = (props, context) => {
  const { data } = useBackend<InputPack>(context);
  const {
    user_ref,
    user_xeno,
    user_index,
    user_evolution,
    static_info,
  } = data;

  const static_entry = static_info[user_index];

  return (
    <Section align="center" title="Psy Points: 2400 | Burrowed: 15">
      <Flex>
        <Flex.Item grow>
          <EvolutionBar
            user_ref={user_ref}
            is_xeno={user_xeno}
            evolution={user_evolution}
            max={static_entry.evolution_max} />
        </Flex.Item>
      </Flex>
    </Section>
  );
};



type EvolutionProps = {
  user_ref: string,
  is_xeno: boolean,
  evolution: number,
  max: number,
};

const EvolutionBar = (props : EvolutionProps, context) => {
  const { act } = useBackend(context);

  if (!props.is_xeno || props.max == 0)
    return (
      <Box /> // Empty.
    );

  return (
    <Flex>
      <Flex.Item mr={1} align="center">
        <Button
          tooltip="Open Panel"
          onClick={() => act('Evolve', { xeno: props.user_ref })}>
          Evolution Progress:
        </Button>
      </Flex.Item>
      <Flex.Item grow>
        <ProgressBar
          ranges={{
            good: [0.75, Infinity],
            average: [-Infinity, 0.75],
          }}
          value={props.evolution / props.max}>
          {round(props.evolution / props.max * 100, 0)}%
        </ProgressBar>
      </Flex.Item>
    </Flex>
  );
}

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

  const [
    showEmpty,
    toggleEmpty,
  ] = useLocalState(context, "showEmpty", true);

  const toggleButton = (<Button.Checkbox
    checked={showEmpty}
    onClick={() => toggleEmpty(!showEmpty)}>
      Show Empty
    </Button.Checkbox>)

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
    <Section title={`Total Living Sisters: ${hive_total}`}
      align="center"
      buttons={toggleButton}>
      <Flex direction="column-reverse" align="center">
        {pyramid_data.map((tier_info, tier) => {
          // Hardcoded tier check for limited slots.
          const max_slots = tier === 2
            ? hive_max_tier_two
            : 0 + tier === 3
              ? hive_max_tier_three
              : 0;

          const slot_text = tier === 2 || tier === 3
            ? <Box as="span"
              textColor={tier_info.total == max_slots ? "bad" : "good"}>
                ({tier_info.total}/{max_slots})
              </Box>
            : tier_info.total;

          // Praetorian name way too long. Clips into Rav.
          const row_width = tier === 3
            ? 8 : 7;

          return (
            <Box
              key={tier}
              mb={0.5}>
              {/* Manually creating section because I need stuff in title. */}
              <Box className="Section__title">
                <Box as="span" className="Section__titleText" fontSize={1.1}>
                  Tier {tier}: {slot_text} Sisters
                </Box>
              </Box>
              <Flex className="Section__content">
                {tier_info.index.map((value, idx) => {
                  const count = tier_info.caste[idx];
                  if (!showEmpty && count == 0) {
                    return (<Box />)
                  }
                  const static_entry = static_info[value];
                  return (
                    <Flex.Item width="100%"
                      minWidth={row_width}
                      bold
                      key={static_entry.name}>
                      <Box as="img"
                        src={`data:image/jpeg;base64,${static_entry.minimap}`}
                        style={{
                          transform: "scale(3) translateX(-3.5px)",
                          "-ms-interpolation-mode": "nearest-neighbor",
                        }} />
                      {static_entry.name}
                    </Flex.Item>
                  );
                })}
              </Flex>
              <Flex>
                {tier_info.caste.map((count, idx) => {
                  if (!showEmpty && count == 0) {
                    return (<Box />)
                  }
                  const static_entry = static_info[tier_info.index[idx]];
                  return (
                    <Flex.Item width="100%"
                      minWidth={row_width}
                      key={static_entry.name}
                      fontSize={static_entry.is_unique ? 1 : 1.25}>
                      {static_entry.is_unique
                        ? count >= 1
                          ? "Active" : "N/A"
                        : count}
                    </Flex.Item>
                  );
                })}
              </Flex>
            </Box>
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

  // Hardcode dimensions.
  const row_height = "16px";
  const ssd_width = "16px";
  const ssd_mr = "4px";
  const action_width = "40px";
  const action_mr = "4px";
  const leader_width = "16px";
  const leader_mr = "6px";
  const minimap_width = "14px";
  const minimap_mr = "6px";
  const name_width = "30%";
  const status_width = "60px";

  return (
    <Section>
      <Flex direction="column-reverse">
        <Flex.Item order={Number.MAX_SAFE_INTEGER}>{/* Header */}
          <Flex bold height={row_height}>
            <Flex.Item width={ssd_width} mr={ssd_mr} />{/* SSD */}
            <Flex.Item width={action_width} mr={action_mr} />{/* Action Buttons */}
            <Flex.Item width={leader_width} mr={leader_mr} />{/* Leadership */}
            <Flex.Item width={minimap_width} mr={minimap_mr} />{/* Minimap Icon */}
            <Flex.Item width={name_width}>Caste (Name)</Flex.Item>
            <Flex.Item width={status_width}>Health</Flex.Item>
            <Flex.Item width={status_width}>Plasma</Flex.Item>
            <Flex.Item grow>Location</Flex.Item>
          </Flex>
        </Flex.Item>
        <Flex.Item order={1 << queen | 1 << leader | 1 << (leader - 1)}>
          <Divider />
        </Flex.Item>
        {xeno_info.map((entry) => {
          const static_entry = static_info[entry.index];
          const order = static_entry.sort_mod
            | static_entry.tier << tier
            | entry.is_leader << leader
            | static_entry.is_queen << queen;
          return (
            <Flex.Item order={order} mb={1} key={entry.ref}>
              <Flex height={row_height}>
                <Flex.Item width={ssd_width} mr={ssd_mr}>
                  {!!entry.is_ssd
                    && (<Box className="hivestatus16x16 ssdIcon" />)}
                </Flex.Item>
                <Flex.Item width={action_width} mr={action_mr}>
                  {user_ref !== entry.ref
                  && <ActionButtons
                    target_ref={entry.ref}
                    is_queen={user_queen}
                    watched_xeno={user_watched_xeno}
                    can_transfer_plasma={static_entry.can_transfer_plasma} />}
                </Flex.Item>
                <Flex.Item width={leader_width} mr={leader_mr}>
                  <Button
                    fluid
                    height="16px"
                    fontSize={0.75}
                    tooltip={user_queen && !static_entry.is_queen ? "Toggle leadership" : ""}
                    verticalAlignContent="middle"
                    icon="star"
                    disabled={static_entry.is_queen}
                    selected={entry.is_leader}
                    opacity={entry.is_leader || user_queen
                      || static_entry.is_queen ? 1 : 0.5}
                    onClick={() => act('Leader', { xeno: entry.ref })} />
                </Flex.Item>
                <Flex.Item width={minimap_width} mr={minimap_mr}>
                  <Box as="img"
                    src={`data:image/jpeg;base64,${static_entry.minimap}`}
                    style={{
                      transform: "scale(2) translateX(2px)", // Upscaled from 7x7 to 14x14.
                      "-ms-interpolation-mode": "nearest-neighbor",
                    }} />
                </Flex.Item>
                <Flex.Item width={name_width}
                  nowrap
                  style={{
                    'overflow': 'hidden',
                    'text-overflow': 'ellipsis',
                  }}>
                  {entry.name}
                </Flex.Item>
                <Flex.Item width={status_width}>
                  {entry.health <= 10 // Health actually ranges from -30 to 100.
                    ? <Box bold textColor="bad">{entry.health}%</Box>
                    : entry.health <= 80
                      ? <Box textColor="average">{entry.health}%</Box>
                      : <Box textColor="good">{entry.health}%</Box>}
                </Flex.Item>
                <Flex.Item width={status_width}>
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
  can_transfer_plasma: boolean,
};

const ActionButtons = (props: ActionButtonProps, context) => {
  const { act } = useBackend<InputPack>(context);
  const observing = props.target_ref === props.watched_xeno;
  const overwatch_button = (<Button
    fluid
    height="16px"
    fontSize={0.75}
    tooltip={observing ? "Cancel" : "Overwatch"}
    align="center"
    verticalAlignContent="middle"
    icon="eye"
    selected={observing}
    onClick={() => act('Follow', { xeno: props.target_ref })} />);

  if (props.is_queen) {
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
            tooltip={props.can_transfer_plasma ? "Give plasma" : ""}
            align="center"
            verticalAlignContent="middle"
            icon="arrow-down"
            disabled={!props.can_transfer_plasma}
            onClick={() => act('Plasma', { xeno: props.target_ref })} />
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
