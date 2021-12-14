import { Box, Stack } from '../../components';
import { MinimapObjectProp, icon_size } from './Types';
import { createLogger } from '../../logging';

const logger = createLogger('coordinate');

export const MinimapObject = (props: MinimapObjectProp, context) => {
  
  const {
    objectdata,
    ...rest
  } = props;

  return (
    <Box
      className="Minimap__Object"
      width="10%"
      {...rest}
      position="absolute"
      left={`${objectdata.coordinate.x+icon_size/2}px`}
      top={`${objectdata.coordinate.y+icon_size}px`}
    >
      <Stack vertical fill>
        <Stack.Item>
          <Box
            as="span"
            className="Minimap__Object_Icon"
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
