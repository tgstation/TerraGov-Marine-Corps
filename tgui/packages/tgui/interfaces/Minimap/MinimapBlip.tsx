import { Box, Stack } from '../../components';
import { MinimapBlipProp, icon_size } from './Types';
import { createLogger } from '../../logging';

const logger = createLogger('coordinate');

export const MinimapBlip = (props: MinimapBlipProp, context) => {

  const {
    coordinate,
    ...rest
  } = props;

  return (
    <Box
      className="Minimap__Blip"
      width="10%"
      {...rest}
      position="absolute"
      left={`${coordinate.x + icon_size}px`}
      top={`${coordinate.y - icon_size * 2}px`}
    >
      <Stack vertical fill>
        <Stack.Item>
          <Box
            as="span"
            className="Minimap__Blip_icon"
            position="absolute"
            backgroundColor="white"
            width={`${icon_size}px`}
            height={`${icon_size}px`}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};
