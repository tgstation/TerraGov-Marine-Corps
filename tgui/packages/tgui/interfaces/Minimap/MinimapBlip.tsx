import { Box } from '../../components';
import { MinimapBlipProp, icon_size } from './Types';
import { resolveAsset } from '../../assets';
import { createLogger } from '../../logging';

const logger = createLogger('coordinate');

export const MinimapBlip = (props: MinimapBlipProp, context) => {

  const {
    coordinate,
    image,
    ...rest
  } = props;

  return (
    <Box
      position="absolute"
      left={`${coordinate.x + icon_size}px`}
      top={`${coordinate.y - icon_size * 2}px`}
    >
      <img
        src={resolveAsset(image)}
      />
    </Box>
  );
};
