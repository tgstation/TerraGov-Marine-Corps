import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Divider, Box, Section, Collapsible, ProgressBar, Tooltip } from '../components';
import { round } from 'common/math';

type InputPack = {
  // ------- Hive info --------
  hive_name: string,
  hive_max_tier_two: number,
  hive_max_tier_three: number,
  hive_larva_current: number,
  hive_larva_threshold: number,
  hive_larva_rate: number,
  hive_larva_burrowed: number,
  hive_psy_points: number,
  hive_silo_collapse: number,
  hive_orphan_collapse: number,
  hive_silo_max: number,
  hive_orphan_max: number,
  hive_primos: PrimoUpgrades[],
  // ----- Per xeno info ------
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

type PrimoUpgrades = {
  tier: number,
  purchased: boolean,
}

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

const GeneralInfo = (_props, context) => {
  const { data } = useBackend<InputPack>(context);
  let {
    hive_larva_burrowed,
    hive_psy_points,
    hive_silo_collapse,
    hive_orphan_collapse,
    hive_silo_max,
    hive_orphan_max,
  } = data;

  return (
    // Manually creating section because I need stuff in title.
    <Box className="Section">
      <Box className="Section__title">
        <Box as="span" className="Section__titleText">
          Psy Points:
          <Box
            as="span"
            color={hive_psy_points < 600
              ? "bad"
              : hive_psy_points < 800
                ? "average"
                : "good"}>
            {" " + hive_psy_points + " "}
          </Box>
          | Burrowed Larva:
          <Box
            as="span"
            color={hive_larva_burrowed > 0 ? "good" : "bad"}>
            {" " + hive_larva_burrowed}
          </Box>
        </Box>
      </Box>
      <Flex direction="column" className="Section__content">
        <Flex.Item>
          <LarvaBar />
        </Flex.Item>
        <Flex.Item>
          <EvolutionBar />
        </Flex.Item>
        {(hive_silo_collapse > 0 || hive_orphan_collapse > 0) && <Divider />}
        <Flex.Item>
          <SiloCollapseBar time={hive_silo_collapse} max={hive_silo_max} />
        </Flex.Item>
        <Flex.Item>
          <OrphanHiveBar time={hive_orphan_collapse} max={hive_orphan_max} />
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const bar_text_width = 10.25;

const OrphanHiveBar = (props: { time: number, max: number, }, _context) => {
  if (props.time === 0) {
    return (<Box />);
  }

  return (
    <Tooltip content="Hive must evolve a ruler!">
      <Flex mb={1}>
        <Flex.Item bold ml={1} mr={1} width={bar_text_width} align="center">
          Orphan Hivemind:
        </Flex.Item>
        <Flex.Item grow>
          <ProgressBar
            color="red"
            value={1 - props.time / props.max}>
            {props.time} seconds
          </ProgressBar>
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

const SiloCollapseBar = (props: { time: number, max: number, }, _context) => {
  if (props.time === 0) {
    return (<Box />);
  }

  return (
    <Tooltip content="Hive must construct a silo!">
      <Flex mb={1}>
        <Flex.Item bold ml={1} mr={1} width={bar_text_width} align="center">
          Silo Collapse:
        </Flex.Item>
        <Flex.Item grow>
          <ProgressBar
            color="red"
            value={1 - props.time / props.max}>
            {props.time} seconds
          </ProgressBar>
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

const LarvaBar = (_props, context) => {
  const { data } = useBackend<InputPack>(context);
  const {
    hive_larva_current,
    hive_larva_threshold,
    hive_larva_rate,
  } = data;

  return (
    <Tooltip content="Progress to next burrowed larva">
      <Flex mb={1}>
        <Flex.Item ml={1} mr={1} width={bar_text_width} align="center">
          Larva Generation:
        </Flex.Item>
        <Flex.Item grow>
          <ProgressBar
            color="green"
            value={hive_larva_current / hive_larva_threshold}>
            {`${hive_larva_rate} per minute ` // Linters eating my white space.
            + `(${hive_larva_current}/${hive_larva_threshold})`}
          </ProgressBar>
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

const EvolutionBar = (_props, context) => {
  const { act, data } = useBackend<InputPack>(context);
  const {
    static_info,
    user_ref,
    user_xeno,
    user_index,
    user_evolution,
  } = data;

  const max = static_info[user_index].evolution_max;

  if (!user_xeno || max === 0) {
    return (<Box />); // Empty.
  }

  return (
    <Flex>
      <Flex.Item mr={2} width={bar_text_width}>
        <Button
          tooltip="Open Panel"
          onClick={() => act('Evolve', { xeno: user_ref })}>
          Evolution Progress:
        </Button>
      </Flex.Item>
      <Flex.Item grow>
        <ProgressBar
          ranges={{
            good: [0.75, Infinity],
            average: [-Infinity, 0.75],
          }}
          value={user_evolution / max}>
          {round(user_evolution / max * 100, 0)}%
        </ProgressBar>
      </Flex.Item>
    </Flex>
  );
};

type PyramidCalc = { // Index is tier.
  caste: number[], // Index is sort_mod.
  index: number[], // Corresponds with static_info index.
  total: number, // Total xeno count for this tier.
};

const PopulationPyramid = (_props, context) => {
  const { data } = useBackend<InputPack>(context);
  const {
    hive_max_tier_two,
    hive_max_tier_three,
    hive_primos,
    xeno_info,
    static_info,
  } = data;

  const [
    showEmpty,
    toggleEmpty,
  ] = useLocalState(context, "showEmpty", true);

  const toggleButton =
  (<Button.Checkbox
    checked={showEmpty}
    tooltip="Display castes with no members"
    onClick={() => toggleEmpty(!showEmpty)}>
    Show Empty
  </Button.Checkbox>);

  const primos: boolean[] = []; // Index is tier.
  const pyramid_data: PyramidCalc[] = [];
  let hive_total: number = 0;

  // We could do the really fancy way of creating a list of uniques
  // and then generating equality from unique keys.
  // From there, we record the lengths of those lists
  // to find number of counts per caste.
  // But all these keys are numbers. And this is a lot simplier.

  hive_primos.map((entry) => {
    primos[entry.tier - 1] = entry.purchased;
  })

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
          const slot_text = tier === 2 || tier === 3 ?
            (<Box as="span"
              textColor={tier_info.total === max_slots
              ? "bad" : "good"}>
              ({tier_info.total}/{max_slots})
            </Box>)
            : tier_info.total;
          // Praetorian name way too long. Clips into Rav.
          const row_width = tier === 3
            ? 8 : 7;
          const primordial = primos[tier]
            ? (<Box as="span" textColor="good">[Primordial]</Box>)
            : "";
          return (
            <Box
              key={tier}
              mb={0.5}>
              {/* Manually creating section because I need stuff in title. */}
              <Box className="Section__title">
                <Box as="span" className="Section__titleText" fontSize={1.1}>
                  Tier {tier}: {slot_text} Sisters {primordial}
                </Box>
              </Box>
              <Flex className="Section__content">
                {tier_info.index.map((value, idx) => {
                  const count = tier_info.caste[idx];
                  if (!showEmpty && count === 0) {
                    return (<Box />);
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
                  if (!showEmpty && count === 0) {
                    return (<Box />);
                  }
                  const static_entry = static_info[tier_info.index[idx]];
                  return (
                    <Flex.Item width="100%"
                      minWidth={row_width}
                      key={static_entry.name}
                      fontSize={static_entry.is_unique ? 1 : 1.25}>
                      <Box as="span" color={count >= 1 ? "good" : "average"}>
                        {static_entry.is_unique
                          ? count >= 1
                            ? "Active"
                            : "N/A"
                          : count}
                      </Box>
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

// Header text.
const caste = "Caste (Name)";
const health = "HP";
const plasma = "PL";
const location = "Location";

type sort_by = {
  category: string,
  down: boolean, // Reverse sort. Down is normal.
}

const default_sort: sort_by = {
  category: caste,
  down: true,
};

const min = (left: number, right: number) => {
  // Why the fuck is this not already implemented?
  return left > right ? right : left;
}

const HashString = (input: string) =>{
  // ------ No mixing but not alphabetical. -------
  // let hash = 0, i: number, chr: number;
  // if (input.length === 0) return hash;
  // for (i = 0; i < input.length; i++) {
  //   chr   = input.charCodeAt(i);
  //   hash  = ((hash << 5) - hash) + chr;
  //   hash |= 0; // Convert to 32bit integer
  // }
  // return hash;
  // ------ Alphabetical but might mix. -------
  let hash = 0, i: number, chr: number;
  // 32 bit max. 6 letters = 30 bits used.
  for (i = 0; i < min(6, input.length); i++) {
    // Subtracting from 26 in order to reverse the order.
    chr = 26 - input.charCodeAt(i) - 97;
    hash |= chr << (i * 5);
  }
  return hash;
}

const XenoList = (_props, context) => {
  const { act, data } = useBackend<InputPack>(context);
  const {
    xeno_info,
    static_info,
    user_ref,
    user_queen,
    user_watched_xeno,
  } = data;

  const [
    sortingBy,
    setSortBy,
  ] = useLocalState(context, "sortingBy", default_sort);

  const SortingButton = (props: {text: string, tip?: string}, _context) => {
    return (
      <Button ml={-1}
        backgroundColor="transparent"
        tooltip={props.tip}
        icon={sortingBy.category !== props.text
          ? "chevron-right"
          : sortingBy.down
            ? "chevron-down"
            : "chevron-up"}
        onClick={() => setSortBy({
          category: props.text,
          down: sortingBy.category === props.text ? !sortingBy.down : true
        })}>
        {props.text}
      </Button>
    );
  };

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

  const sorting_direction = sortingBy.down
    ? "column-reverse"
    : "column";

  const header_order = sortingBy.down
    ? Number.MAX_SAFE_INTEGER
    : Number.MIN_SAFE_INTEGER;

  return (
    <Section>
      <Flex direction={sorting_direction}>
        {sortingBy.down && (<Flex.Item order={Number.MAX_SAFE_INTEGER}>
          <Divider />{/* Located after the header on reverse order. */}
        </Flex.Item>)}
        <Flex.Item order={header_order}>{/* Header */}
          <Flex bold height={row_height} align="center">
            <Flex.Item width={ssd_width} mr={ssd_mr} />{/* SSD */}
            <Flex.Item width={action_width} mr={action_mr} />{/* Actions */}
            <Flex.Item width={leader_width} mr={leader_mr} />{/* Leadership */}
            <Flex.Item width={minimap_width} mr={minimap_mr} />{/* Minimaps */}
            <Flex.Item width={name_width}>
              <SortingButton text={caste}/>
            </Flex.Item>
            <Flex.Item width={status_width}>
              <SortingButton text={health} tip="Health"/>
            </Flex.Item>
            <Flex.Item width={status_width}>
              <SortingButton text={plasma} tip="Plasma"/>
            </Flex.Item>
            <Flex.Item grow>
              <SortingButton text={location}/>
            </Flex.Item>
          </Flex>
        </Flex.Item>
        {!sortingBy.down && (<Flex.Item order={Number.MIN_SAFE_INTEGER}>
          <Divider />{/* Place after header since sort order is iffy */}
        </Flex.Item>)}
        {xeno_info.map((entry) => {
          const static_entry = static_info[entry.index];
          let order: number;
          switch (sortingBy.category) {
            case caste:
              order = static_entry.sort_mod
                | static_entry.tier << tier
                | entry.is_leader << leader
                | static_entry.is_queen << queen;
              break;
            case health:
              order = entry.health;
              break;
            case plasma:
              order = entry.plasma;
              break;
            case location:
              order = HashString(entry.location);
              break;
            default:
              order = 0;
              break;
          }
          return (
            <Flex.Item order={order} mb={1} key={entry.ref}>
              <Flex height={row_height}>
                {/* SSD */}
                <Flex.Item width={ssd_width} mr={ssd_mr}>
                  {!!entry.is_ssd
                    && (<Box className="hivestatus16x16 ssdIcon" />)}
                </Flex.Item>
                {/* Action buttons */}
                <Flex.Item width={action_width} mr={action_mr}>
                  {user_ref !== entry.ref
                  && <ActionButtons
                    target_ref={entry.ref}
                    is_queen={user_queen}
                    watched_xeno={user_watched_xeno}
                    can_transfer_plasma={static_entry.can_transfer_plasma} />}
                </Flex.Item>
                {/* Leadership */}
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
                {/* Minimap icons */}
                <Flex.Item width={minimap_width} mr={minimap_mr}>
                  <Box as="img"
                    src={`data:image/jpeg;base64,${static_entry.minimap}`}
                    style={{
                      transform: "scale(2) translateX(2px)", // Upscaled from 7x7 to 14x14.
                      "-ms-interpolation-mode": "nearest-neighbor",
                    }} />
                </Flex.Item>
                {/* Caste type and nickname */}
                <Flex.Item width={name_width}
                  nowrap
                  style={{
                    'overflow': 'hidden',
                    'text-overflow': 'ellipsis',
                  }}>
                  {entry.name}
                </Flex.Item>
                {/* Health percentage */}
                <Flex.Item width={status_width}>
                  {entry.health <= 10 // Health actually ranges from -30 to 100.
                    ? <Box bold textColor="bad">{entry.health}%</Box>
                    : entry.health <= 80
                      ? <Box textColor="average">{entry.health}%</Box>
                      : <Box textColor="good">{entry.health}%</Box>}
                </Flex.Item>
                {/* Plasma percentage */}
                <Flex.Item width={status_width}>
                  {entry.plasma <= 33 // Queen SSD?
                    ?<Box bold textColor="bad">{entry.plasma}%</Box>
                    : entry.plasma <= 75 // Queen give plasma plz.
                      ? <Box textColor="average">{entry.plasma}%</Box>
                      : <Box textColor="good">{entry.plasma}%</Box>}
                </Flex.Item>
                {/* Area name */}
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
        {/* Overwatch */}
        <Flex.Item grow mr="4px">
          {overwatch_button}
        </Flex.Item>
        {/* Transfer plasma */}
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
