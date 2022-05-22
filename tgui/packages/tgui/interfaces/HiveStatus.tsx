import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Divider, Collapsible, Icon, Box, ProgressBar } from '../components';

type InputPack = {
  hive_name: string
  xeno_info: XenoData[],
  static_info: StaticData[],
}

type XenoData = {
  ref: string,
  name: string,
  location: string,
  health: number,
  plasma: number,
  is_leader: boolean,
  is_ssd: boolean,
  index: number, // Corresponding to static data index.
}

type StaticData = {
  name: string,
  is_queen: boolean,
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
    static_info
  } = data;

  // Order magic numbers:
  // 30,000 - Header
  // 20,000 - Queen
  // 10,000 - Leaders
  //    X00 - Tier (max 99)
  //      X - Sort_Mod (max 99)

  return (
    <Flex direction="column-reverse">
      <Flex.Item order={30000} mb={1}>{/*Header*/}
        <Flex bold width="100%" height="16px">
          <Flex.Item width="16px" mr="2px"/>{/*SSD*/}
          <Flex.Item width="16px" mr="2px"/>{/*Leadership*/}
          <Flex.Item width="14px" mr="6px"/>{/*Minimap*/}
          <Flex.Item width="30%" textAlign="center">Caste (Name)</Flex.Item>
          <Flex.Item textAlign="center" grow={1}>Location</Flex.Item>
          <Flex.Item width="75px">Health</Flex.Item>
          <Flex.Item width="75px">Plasma</Flex.Item>
          <Flex.Item width="10%" />
        </Flex>
      </Flex.Item>
      {xeno_info.map((entry) => {
        let static_entry = static_info[entry.index]
        return (
          <Flex.Item mb={1} order={0}>
            <Flex width="100%" height="16px">
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
              <Flex.Item width="30%">{entry.name}</Flex.Item>
              <Flex.Item grow={1}>{entry.location}</Flex.Item>
              <Flex.Item width="75px">{
                entry.health <= 10 //Health actually ranges from -30 to 100.
                  ? <Box bold textColor="red">{entry.health}%</Box>
                  : entry.health <= 80
                    ? <Box textColor="orange">{entry.health}%</Box>
                    : <Box textColor="green">{entry.health}%</Box>
              }</Flex.Item>
              <Flex.Item width="75px">{
                entry.plasma <= 33
                  ?<Box bold textColor="red">{entry.plasma}%</Box>
                  : entry.plasma <= 75 //Queen give plasma plz.
                    ? <Box textColor="orange">{entry.plasma}%</Box>
                    : <Box textColor="green">{entry.plasma}%</Box>
              }</Flex.Item>
              <Flex.Item width="10%" />
            </Flex>
          </Flex.Item>
        );})}
    </Flex>
  );
}
