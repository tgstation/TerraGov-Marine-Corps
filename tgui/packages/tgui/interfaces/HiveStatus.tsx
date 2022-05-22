import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Divider, Collapsible, Icon, Box, ProgressBar } from '../components';

type InputPack = {
  hive_name: string,
  xeno_info: XenoData[],
  static_info: StaticData[],
  user_ref: string,
  user_queen: boolean,
}

type XenoData = {
  ref: string,
  name: string,
  location: string,
  health: number,
  plasma: number,
  is_leader: number, // boolean but is used in bitwise ops.
  is_ssd: boolean,
  index: number, // Corresponding to static data index.
}

type StaticData = {
  name: string,
  is_queen: number, // boolean but is used in bitwise ops.
  minimap: string, // Full minimap icon as string. Not icon_state!
  sort_mod: number,
  tier: number,
}

export const HiveStatus = (props, context) => {
  const { data } = useBackend<InputPack>(context);
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

const XenoList = (props, context) => {
  const { data } = useBackend<InputPack>(context);
  const {
    xeno_info,
    static_info,
    user_ref,
    user_queen,
  } = data;

  // First two bits are taken up by queen and leader flags.
  // Remaining bits 28 split 14 tiers, 14 sort mods.
  // For a total of 16,384 tiers and 16,384 castes per tier.
  // I think that's plenty for everyone.
  const queen = 30;
  const leader = 29;
  const tier = 14;

  return (
    <Flex direction="column-reverse">
      <Flex.Item order={Number.MAX_SAFE_INTEGER} mb={1}>{/*Header*/}
        <Flex bold height="16px">
          <Flex.Item width="75px" />{/*Action Buttons*/}
          <Flex.Item width="16px" mr="2px"/>{/*SSD*/}
          <Flex.Item width="16px" mr="2px"/>{/*Leadership*/}
          <Flex.Item width="14px" mr="6px"/>{/*Minimap*/}
          <Flex.Item width="30%" textAlign="center">Caste (Name)</Flex.Item>
          <Flex.Item textAlign="center" grow>Location</Flex.Item>
          <Flex.Item width="60px">Health</Flex.Item>
          <Flex.Item width="60px">Plasma</Flex.Item>
        </Flex>
      </Flex.Item>
      {xeno_info.map((entry) => {
        const static_entry = static_info[entry.index];
        const order = static_entry.sort_mod | static_entry.tier << tier | entry.is_leader << leader | static_entry.is_queen << queen;
        return (
          <Flex.Item order={order} mb={1}>
            <Flex height="16px">
              <Flex.Item width="75px">{user_ref !== entry.ref && <ActionButtons
                target_ref={entry.ref}
                is_queen={user_queen}
                is_leader={entry.is_leader}
              />}</Flex.Item>
              <Flex.Item width="16px" mr="2px">{!!entry.is_ssd && (<Box className={'hivestatus16x16 ssdIcon'} />)}</Flex.Item>
              <Flex.Item width="16px" mr="2px">{
                (!!entry.is_leader || !!static_entry.is_queen) && (<Box className={'hivestatus16x16 leaderIcon'}><Icon name="star" ml={0.2} /></Box>)
              }</Flex.Item>
              <Flex.Item width="14px" mr="6px"><Box
                as="img"
                src={`data:image/jpeg;base64,${static_entry.minimap}`}
                style={{
                  transform: "scale(2) translateX(2px)",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              </Flex.Item>
              <Flex.Item width="30%" nowrap style={{'overflow': 'hidden','text-overflow': 'ellipsis'}}>{entry.name}</Flex.Item>
              <Flex.Item grow nowrap style={{'overflow': 'hidden','text-overflow': 'ellipsis'}}>{entry.location}</Flex.Item>
              <Flex.Item width="60px">{
                entry.health <= 10 //Health actually ranges from -30 to 100.
                  ? <Box bold textColor="red">{entry.health}%</Box>
                  : entry.health <= 80
                    ? <Box textColor="orange">{entry.health}%</Box>
                    : <Box textColor="green">{entry.health}%</Box>
              }</Flex.Item>
              <Flex.Item width="60px">{
                entry.plasma <= 33 //Queen SSD?
                  ?<Box bold textColor="red">{entry.plasma}%</Box>
                  : entry.plasma <= 75 //Queen give plasma plz.
                    ? <Box textColor="orange">{entry.plasma}%</Box>
                    : <Box textColor="green">{entry.plasma}%</Box>
              }</Flex.Item>
            </Flex>
          </Flex.Item>
        );})}
    </Flex>
  );
}

type ActionButtonProps = {
  target_ref: string,
  is_queen: boolean,
  is_leader: number,
}

const ActionButtons = (props: ActionButtonProps, context) => {
  const { act } = useBackend<InputPack>(context);
  const {
    target_ref,
    is_queen,
    is_leader
  } = props;

  if(is_queen)
    return (
      <Flex direction="row" justify="space-evenly">
          <Flex.Item width="22px" mr="2px">
            <Button
              fluid
              tooltip="Overwatch"
              icon="eye"
              onClick={() => act('Follow', { xeno: target_ref })} />
          </Flex.Item>
          <Flex.Item width="22px" mr="2px">
            <Button
              fluid
              tooltip="Toggle leadership"
              icon="star"
              selected={is_leader}
              onClick={() => act('Leader', { xeno: target_ref })} />
          </Flex.Item>
          <Flex.Item width="22px">
            <Button
              fluid
              tooltip="Transfer plasma"
              icon="arrow-down"
              onClick={() => act('Plasma', { xeno: target_ref })} />
          </Flex.Item>
      </Flex>
    )

  return (
    <Flex direction="row" justify="space-evenly">
        <Flex.Item grow>
          <Button
            fluid
            align="center"
            onClick={() => act('Follow', { xeno: target_ref })}>
            Follow
          </Button>
        </Flex.Item>
    </Flex>
  )
}
