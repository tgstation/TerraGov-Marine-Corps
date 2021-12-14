import { useBackend, useLocalState } from '../backend';
import { Box, Tooltip, Icon, Stack } from '../components';
import { Window } from '../layouts';

export const Minimap = (props, context) => {
  const { data } = useBackend(context);
  const {
    map_name,
    map_size_x,
    map_size_y,
    icon_size,
    player_data,
    player_coord,
    player_name,
    player_viewsize = 36,
  } = data;

  const [selectedName, setSelectedName] = useLocalState(context, "selected_name", null);

  const map_size_tile_x = (map_size_x/icon_size);
  const map_size_tile_y = (map_size_y/icon_size);

  const view_offset = player_viewsize/2;

  let background_loc = [
    Math.max(
      Math.min(0, -(player_coord[0]-view_offset)*icon_size),
      -(map_size_tile_x-player_viewsize)*icon_size
    ),
    Math.max(
      Math.min(0, -(map_size_tile_y-player_coord[1]-view_offset)*icon_size),
      -(map_size_tile_y-player_viewsize)*icon_size
    ),
  ];

  const globalToLocal = coord => {
    const newCoord = [];
    newCoord[0] = (coord[0])*icon_size + background_loc[0];
    newCoord[1] = ((map_size_tile_y-coord[1])*icon_size) + background_loc[1];

    if (newCoord[0] < 0 || newCoord[0] > icon_size*player_viewsize
      || newCoord[1] < 0 || newCoord[1] > icon_size*player_viewsize) {
      return null;
    }
    return newCoord;
  };

  return (
    <Window
      width={icon_size*player_viewsize + 25}
      height={icon_size*player_viewsize + 50}
      theme="engi"
    >
      <Window.Content id="minimap">
        <Stack justify="space-around">
          <Stack.Item>
            <Box
              className="Minimap__Map"
              style={{
                'background-image': `url('minimap.${map_name}.png')`,
                'background-repeat': "no-repeat",
                'background-position-x': `${background_loc[0]}px`,
                'background-position-y': `${background_loc[1]}px`,
                'width': `${icon_size*player_viewsize}px`,
                'height': `${icon_size*player_viewsize}px`,
              }}
              onClick={() => setSelectedName(null)}
            >
              {player_data.map(val => {
                let p_coord = val.coord;
                if (val.name === player_name) p_coord = player_coord;
                const local_coord = globalToLocal(p_coord);
                if (!local_coord) return;
                return (
                  <Player
                    key={val.name}
                    player_name={val.name}
                    player_coord={local_coord}
                    player_icon={val.icon}
                  />
                );
              })}
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const Player = (props, context) => {
  const { data } = useBackend(context);
  const { icon_size } = data;
  const {
    player_name,
    player_coord,
    player_icon,
    ...rest
  } = props;

  const [selectedName, setSelectedName] = useLocalState(context, "selected_name", null);

  return (
    <Box
      className="Minimap__Player"
      width="10%"
      onClick={e => {
        setSelectedName(player_name);
        e.stopPropagation();
      }}
      {...rest}
      position="absolute"
      left={`${player_coord[0]+icon_size/2}px`}
      top={`${player_coord[1]+icon_size}px`}
    >
      <Stack vertical fill>
        <Stack.Item>
          <Box
            as="span"
            className="Minimap__Player_Icon"
            position="absolute"
            backgroundColor="white"
            width={`${icon_size}px`}
            height={`${icon_size}px`}
          />
        </Stack.Item>
        <Stack.Item ml={`${icon_size}px`} mt={`${icon_size}px`}>
          <Box
            position="absolute"
            px={1}
            py={1}
            className={`Minimap__InfoBox${
              selectedName === player_name? "--detailed" : ""}`}
          >
            <Stack>
              {selectedName === player_name && (
                <Stack.Item>
                  <Icon name={player_icon} />
                </Stack.Item>
              )}
              <Stack.Item>
                {player_name}
              </Stack.Item>
            </Stack>
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
};
