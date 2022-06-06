import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Divider, Box, Section, ProgressBar, Tooltip, Collapsible } from '../components';
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
  hive_minion_count: number,
  hive_primos: PrimoUpgrades[],
  hive_queen_remaining: number,
  hive_queen_max: number,
  hive_structures: StructureData[],
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
  user_purchase_perms: boolean,
  user_maturity: number,
  user_next_mat_level: number,
  user_tracked: string,
  user_show_compact: boolean,
  user_show_empty: boolean,
  user_show_general: boolean,
  user_show_population: boolean,
  user_show_xeno_list: boolean,
  user_show_structures: boolean,
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

type StructureData = {
  ref: string,
  name: string,
  integrity: number,
  max_integrity: number,
  location: string,
}

type PrimoUpgrades = {
  tier: number,
  purchased: boolean,
}

export const HiveStatus = (_props, context) => {
  const { act, data } = useBackend<InputPack>(context);
  const {
    hive_name,
    user_ref,
    user_show_general,
    user_show_population,
    user_show_xeno_list,
    user_show_structures,
  } = data;

  return (
    <Window
      theme="xeno"
      title={hive_name + " Hive Status"}
      resizable
      width={700}
      height={800}>
      <Window.Content scrollable>
        <CachedCollapsible
          title="General Information"
          open={user_show_general}
          onClickXeno={() => act('ToggleGeneral', { xeno: user_ref })}>
          <GeneralInfo />
        </CachedCollapsible>
        <Divider />
        <CachedCollapsible
          title="Hive Population"
          open={user_show_population}
          onClickXeno={() => act('TogglePopulation', { xeno: user_ref })}>
          <PopulationPyramid />
        </CachedCollapsible>
        <Divider />
        <CachedCollapsible
          title="Xenomorph List"
          open={user_show_xeno_list}
          onClickXeno={() => act('ToggleXenoList', { xeno: user_ref })}>
          <XenoList />
        </CachedCollapsible>
        <Divider />
        <CachedCollapsible
          title="Hive Structures"
          open={user_show_structures}
          onClickXeno={() => act('ToggleStructures', { xeno: user_ref })}>
          <StructureList />
        </CachedCollapsible>
        <Divider />
      </Window.Content>
    </Window>
  );
};

const CachedCollapsible = (props: {title: string, open: boolean,
  children?: JSX.Element, onClickXeno: any}, context) => {
  const { data } = useBackend<InputPack>(context);
  const { user_xeno } = data;

  if (!user_xeno) {
    return (
      <Collapsible open title={props.title}>
        {props.children}
      </Collapsible>
    );
  }

  return (
    <Box mb={1}>
      <div className="Table">
        <div className="Table__cell">
          <Button
            fluid
            icon={props.open ? 'chevron-down' : 'chevron-right'}
            onClick={props.onClickXeno}>
            {props.title}
          </Button>
        </div>
      </div>
      {!!props.open && (
        <Box mt={1}>
          {props.children}
        </Box>
      )}
    </Box>
  );
};

const BlessingsButton = (_props, context) => {
  const { act, data } = useBackend<InputPack>(context);
  const {
    user_purchase_perms,
    user_ref,
  } = data;

  if (!user_purchase_perms) {
    return (<Box />);
  }

  return (
    <Box className="Section__buttons">
      <Button
        onClick={() => act('Blessings', { xeno: user_ref })}>
        Blessings
      </Button>
    </Box>
  );
};

const GeneralInfo = (_props, context) => {
  const { data } = useBackend<InputPack>(context);
  const {
    hive_larva_burrowed,
    hive_psy_points,
    hive_silo_collapse,
    hive_orphan_collapse,
    hive_queen_remaining,
    hive_silo_max,
    hive_orphan_max,
    hive_queen_max,
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
        <BlessingsButton />
      </Box>
      <Flex direction="column" className="Section__content">
        <Flex.Item>
          <LarvaBar />
        </Flex.Item>
        <Flex.Item>
          <MaturityBar />
        </Flex.Item>
        <Flex.Item>
          <EvolutionBar />
        </Flex.Item>
        {(hive_silo_collapse > 0 || hive_orphan_collapse > 0
          || hive_queen_remaining > 0) && <Divider />}
        <Flex.Item>
          <XenoCountdownBar time={hive_queen_remaining} max={hive_queen_max}
            tooltip="When new queen can evolve." left_side="Next Queen:" />
        </Flex.Item>
        <Flex.Item>
          <XenoCountdownBar time={hive_silo_collapse} max={hive_silo_max}
            tooltip="Hive must construct a silo!" left_side="Silo Collapse:" />
        </Flex.Item>
        <Flex.Item>
          <XenoCountdownBar time={hive_orphan_collapse} max={hive_orphan_max}
            tooltip="Hive must evolve a ruler!" left_side="Orphan Hivemind:" />
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const bar_text_width = 10.25;

const XenoCountdownBar = (props: { time: number, max: number,
  tooltip: string, left_side: string }, _context) => {
  if (props.time === 0) {
    return (<Box />);
  }

  return (
    <Tooltip content={props.tooltip}>
      <Flex mb={1}>
        <Flex.Item bold ml={1} mr={1} width={bar_text_width} align="center">
          {props.left_side}
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

const MaturityBar = (_props, context) => {
  const { data } = useBackend<InputPack>(context);
  const {
    user_xeno,
    user_maturity,
    user_next_mat_level,
  } = data;

  if (!user_xeno || user_next_mat_level === 0) {
    return (<Box />); // Empty.
  }

  return (
    <Tooltip content="Your next maturity upgrade">
      <Flex mb={1}>
        <Flex.Item ml={1} mr={1} width={bar_text_width} align="center">
          Upgrade Progress:
        </Flex.Item>
        <Flex.Item grow>
          <ProgressBar
            ranges={{
              good: [0.75, Infinity],
              average: [-Infinity, 0.75],
            }}
            value={user_maturity / user_next_mat_level}>
            {round(user_maturity / user_next_mat_level * 100, 0)}%
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
  const { act, data } = useBackend<InputPack>(context);
  const {
    hive_max_tier_two,
    hive_max_tier_three,
    hive_minion_count,
    hive_primos,
    xeno_info,
    static_info,
    user_ref,
    user_xeno,
    user_show_empty,
    user_show_compact,
  } = data;

  const [
    showEmpty,
    toggleEmpty,
  ] = useLocalState(context, "showEmpty", true);

  const [
    showCompact,
    toggleCompact,
  ] = useLocalState(context, "showCompact", false);

  const primos: boolean[] = []; // Index is tier.
  const pyramid_data: PyramidCalc[] = [];
  let hive_total: number = 0;

  // We could do the really fancy way of creating a list of uniques
  // and then generating equality from unique keys.
  // From there, we record the lengths of those lists
  // to find number of counts per caste.
  // But all these keys are numbers. And this is a lot simplier.

  hive_primos.map((entry) => {
    primos[entry.tier] = entry.purchased;
  });

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

  const ShowButtons = (_props, _context) => {
    if (!user_xeno) {
      // Observers will not be able to cache empty toggle.
      return (
        <div>
          <Button.Checkbox
            checked={showCompact}
            onClick={() => toggleCompact(!showCompact)}>
            Compact Mode
          </Button.Checkbox>
          <Button.Checkbox
            checked={showEmpty}
            tooltip="Display all castes"
            onClick={() => toggleEmpty(!showEmpty)}>
            Show Empty
          </Button.Checkbox>
        </div>
      );
    }

    return (
      <div>
        <Button.Checkbox
          checked={user_show_compact}
          onClick={() => act("ToggleCompact", { xeno: user_ref })}>
          Compact Mode
        </Button.Checkbox>
        <Button.Checkbox
          checked={user_show_empty}
          tooltip="Display all castes"
          onClick={() => act("ToggleEmpty", { xeno: user_ref })}>
          Show Empty
        </Button.Checkbox>
      </div>
    );
  };

  const compact_disp = user_xeno ? user_show_compact : showCompact;
  const empty_disp = user_xeno ? user_show_empty : showEmpty;

  return (
    <Section title={`Total Living Sisters: ${hive_total}`}
      align={compact_disp ? "left" : "center"}
      buttons={<ShowButtons />}>
      <Flex direction="column-reverse" align={compact_disp ? "left" : "center"}>
        {pyramid_data.map((tier_info, tier) => {
          // Hardcoded tier check for limited slots.
          const max_slots = tier === 2
            ? hive_max_tier_two
            : 0 + tier === 3
              ? hive_max_tier_three
              : 0;
          const TierSlots = (_props, _context) => {
            return (
              <Box as="span"
                textColor={tier_info.total === max_slots
                  ? "bad" : "good"}>
                ({tier_info.total}/{max_slots})
              </Box>
            );
          };
          const slot_text = tier === 2 || tier === 3
            ? <TierSlots />
            : tier_info.total;
          // Praetorian name way too long. Clips into Rav.
          const row_width = tier === 3
            ? 8 : 7;
          const primordial = primos[tier]
            ? (<Box as="span" textColor="good">[Primordial]</Box>)
            : "";
          if (compact_disp) {
            // Display less busy compact mode
            if (tier === 0) {
              return (
                <Box key={tier}>
                  <Flex.Item>
                    Larvas: {tier_info.caste[1] /* 1 = larva */} Sisters
                  </Flex.Item>
                  <Flex.Item>
                    Minions: {hive_minion_count} Sisters
                  </Flex.Item>
                  <Flex.Item>
                    Hivemind: {tier_info.caste[0] ? "Active" : "Inactive"}
                  </Flex.Item>
                </Box>
              );
            }
            return (
              <Box key={tier}>
                Tier {tier}: {(tier === 2 || tier === 3)
                  ? ` (${tier_info.total}/${max_slots || 0}) `
                  : ` ${tier_info.total} `}
                Sisters {!empty_disp && tier_info.total === 0 ? '' : '| '}
                {tier_info.index.map((value, idx) => {
                  const count = tier_info.caste[idx];
                  if (!empty_disp && count === 0) {
                    return null;
                  }
                  const static_entry = static_info[value];
                  return `${static_entry.name}: ${count}`;
                }).filter((ti) => ti !== null).join(" | ")}
              </Box>
            );
          }
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
                  if (!empty_disp && count === 0) {
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
                  if (!empty_disp && count === 0) {
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
};

const default_sort: sort_by = {
  category: caste,
  down: true,
};

const XenoList = (_props, context) => {
  const { act, data } = useBackend<InputPack>(context);
  const {
    xeno_info,
    static_info,
    user_ref,
    user_queen,
    user_watched_xeno,
    user_tracked,
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
          down: sortingBy.category === props.text ? !sortingBy.down : true,
        })}>
        {props.text}
      </Button>
    );
  };

  const HeaderDivider = (props: {order: number}, _context) => {
    return (
      <Flex.Item order={props.order}>
        <Divider />{/* Located after the header. */}
      </Flex.Item>
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
  const name_width = "33%";
  const status_width = "60px";

  const sorting_direction = sortingBy.down
    ? "column-reverse"
    : "column";

  const header_order = sortingBy.down
    ? Number.MAX_SAFE_INTEGER
    : Number.MIN_SAFE_INTEGER;

  if (sortingBy.category === location) {
    // Sorting value inversed because direction is inversed.
    xeno_info.sort((a, b) => -a.location.localeCompare(b.location));
  }

  return (
    <Section>
      <Flex direction={sorting_direction}>
        {sortingBy.down && (<HeaderDivider order={Number.MAX_SAFE_INTEGER} />)}
        <Flex.Item order={header_order}>{/* Header */}
          <Flex bold height={row_height} align="center">
            <Flex.Item width={ssd_width} mr={ssd_mr} />{/* SSD */}
            <Flex.Item width={action_width} mr={action_mr} />{/* Actions */}
            <Flex.Item width={leader_width} mr={leader_mr} />{/* Leadership */}
            <Flex.Item width={minimap_width} mr={minimap_mr} />{/* Minimaps */}
            <Flex.Item width={name_width}>
              <SortingButton text={caste} />
            </Flex.Item>
            <Flex.Item width={status_width}>
              <SortingButton text={health} tip="Health" />
            </Flex.Item>
            <Flex.Item width={status_width}>
              <SortingButton text={plasma} tip="Plasma" />
            </Flex.Item>
            <Flex.Item grow>
              <SortingButton text={location} />
            </Flex.Item>
          </Flex>
        </Flex.Item>
        {!sortingBy.down && (<HeaderDivider order={Number.MIN_SAFE_INTEGER} />)}
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
              order = 0; // Sorted by xeno_info.sort()
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
                  style={{
                    'overflow': 'hidden',
                    'text-overflow': 'ellipsis',
                  }}>
                  <Button
                    italic={user_tracked === entry.ref
                      && user_ref !== entry.ref}
                    nowrap
                    verticalAlignContent="middle"
                    style={{
                      'overflow': 'hidden', // hiding overflow prevents the button being slightly scrollable
                      'margin-top': '-3px', // magic number, lines up button text with other cols
                    }}
                    backgroundColor="transparent"
                    tooltip={user_ref !== entry.ref ? (user_tracked === entry.ref ? "Stop tracking" : "Track") : ""}
                    onClick={() => { if (user_ref !== entry.ref) act('Compass', { xeno: user_ref, target: entry.ref }); }} >
                    {entry.name}
                  </Button>
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

  let timer: NodeJS.Timeout;
  const overwatch_button = (<Button
    fluid
    height="16px"
    fontSize={0.75}
    tooltip={observing ? "Cancel" : "Watch"}
    align="center"
    verticalAlignContent="middle"
    icon="eye"
    selected={observing}
    onClick={() => { act('Follow', { xeno: props.target_ref }); }} />);

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

const StructureList = (_props, context) => {
  const { act, data } = useBackend<InputPack>(context);

  const {
    user_ref,
    hive_structures,
    user_tracked,
  } = data;

  const track_margin = 1;
  const track_width = "100px";
  const name_width = "33%"; // Matches xeno list name width.
  const integrity_width = "60px";
  const max_integ_width = "60px";

  hive_structures.sort((a, b) => a.name.localeCompare(b.name));
  hive_structures.sort((a, b) => {
    const silo_a = a.name.includes("silo");
    const silo_b = b.name.includes("silo");
    if (silo_a && silo_b) return 0;
    if (silo_a && !silo_b) return -1;
    if (!silo_a && silo_b) return 1;
    return 0;
  });

  return (
    // Not sortable. Silos first then mixed turrets.
    <Section>
      <Flex direction="column">
        <Flex.Item>
          <Flex bold> {/* Header */}
            <Flex.Item width={track_width} mr={track_margin} /> {/* Track */}
            <Flex.Item width={name_width}>
              Name
            </Flex.Item>
            <Flex.Item width={integrity_width}> {/* Integrity */}
              Health
            </Flex.Item>
            <Flex.Item width={max_integ_width}> {/* Max integrity */}
              Max
            </Flex.Item>
            <Flex.Item grow>
              Location
            </Flex.Item>
          </Flex>
        </Flex.Item>
        <Flex.Item><Divider /></Flex.Item>
        <Flex.Item>
          {hive_structures.map((entry) => {
            return (
              <Flex key={entry.ref} mb={1}>
                <Flex.Item width={track_width} mr={track_margin} align="center">
                  <Button
                    fluid
                    height="16px"
                    fontSize={0.8}
                    tooltip={"Track structure"}
                    align="center"
                    verticalAlignContent="middle"
                    selected={user_tracked === entry.ref}
                    onClick={() => act('Compass', {
                      xeno: user_ref,
                      target: entry.ref,
                    })}>
                    Track
                  </Button>
                </Flex.Item>
                <Flex.Item width={name_width}
                  italic={user_tracked === entry.ref}>
                  {entry.name}
                </Flex.Item>
                <Flex.Item width={integrity_width}>
                  {entry.integrity < entry.max_integrity / 3
                    ? <Box bold textColor="bad">{entry.integrity}</Box>
                    : entry.integrity < entry.max_integrity / 3 * 2
                      ? <Box textColor="average">{entry.integrity}</Box>
                      : <Box textColor="good">{entry.integrity}</Box>}
                </Flex.Item>
                <Flex.Item width={max_integ_width}>
                  {entry.max_integrity}
                </Flex.Item>
                <Flex.Item
                  grow
                  nowrap
                  style={{
                    'overflow': 'hidden',
                    'text-overflow': 'ellipsis',
                  }}>
                  {entry.location}
                </Flex.Item>
              </Flex>
            );
          })}
        </Flex.Item>
      </Flex>
    </Section>
  );
};
