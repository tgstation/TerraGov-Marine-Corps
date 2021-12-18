import { useBackend } from '../../backend';
import { Box, Stack } from '../../components';
import { Window } from '../../layouts';
import { MinimapBlip } from './MinimapBlip';
import { MinimapData, Coordinate, icon_size, minimapPadding } from './Types';
import { createLogger } from '../../logging';

const logger = createLogger('coordinate');

export const Minimap = (props, context) => {
  const { data } = useBackend<MinimapData>(context);
  const {
    map_name,
    map_size_x,
    map_size_y,
    view_size,
    player_data,
    visible_objects_data,
  } = data;

  const map_size_tile_x = (map_size_x / icon_size);
  const map_size_tile_y = (map_size_y / icon_size);

  const view_offset = view_size / 2;

  const background_loc : Coordinate = {
    x: Math.max(
      Math.min(0, -(player_data.coordinate.x - view_offset +1.5) * icon_size),
      -(map_size_tile_x - view_size) * icon_size
    ),
    y: Math.max(
      Math.min(0,
        -(map_size_tile_y - player_data.coordinate.y -view_offset -1.5)
         * icon_size),
      -(map_size_tile_y - view_size) * icon_size
    ),
  };

  const globalToLocal = (coord : Coordinate) => {
    const newCoord : Coordinate = {
      x: coord.x * icon_size + background_loc.x,
      y: (map_size_tile_y - coord.y) * icon_size + background_loc.y,
    };
    if (newCoord.x < -icon_size || newCoord.x > icon_size * view_size
      || newCoord.y < 0 || newCoord.y > icon_size * view_size) {
      return null;
    }
    return newCoord;
  };

  return (
    <Window
      width={icon_size * view_size + minimapPadding * 2}
      height={icon_size * view_size + minimapPadding * 2 + 30}
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
                'background-position-x': `${background_loc.x}px`,
                'background-position-y': `${background_loc.y}px`,
                'width': `${icon_size * view_size}px`,
                'height': `${icon_size * view_size}px`,
              }}
              position="absolute"
              left={`${minimapPadding}px`}
              top={`${minimapPadding}px`}
            >
              {globalToLocal(player_data.coordinate) 
              && <MinimapBlip
                coordinate={globalToLocal(player_data.coordinate)!}
                image="player"
              />}
              {visible_objects_data.map(objet_data => {
                if (!objet_data.image 
                  || objet_data.name === player_data.name) return;
                if (!(player_data.minimap_flags 
                  & objet_data.marker_flags)) return;
                const local_coord : Coordinate|null
                  = globalToLocal(objet_data.coordinate);
                if (!local_coord) return;
                return (
                  <MinimapBlip
                    key={objet_data.name}
                    coordinate={local_coord}
                    image={objet_data.image}
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
