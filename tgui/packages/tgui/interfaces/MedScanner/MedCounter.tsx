import { Box, Icon } from 'tgui-core/components';

import { COLOR_MID_GREY, COUNTER_MAX_SIZE, SPACING_PIXELS } from './constants';

type Props = {
  current: number;
  max?: number;
  units?: string;
  icon?: string;
  iconColor?: string;
  currentColor?: string;
  currentSize?: string;
  maxColor?: string;
  maxSize?: string;
  ml?: string;
  mr?: string;
};

/**
 * A counter that takes a current and max value and formats it like
 * `39/15`, with `/15` by default being 25% smaller, and also darker
 */
export function MedCounter(props: Props) {
  const {
    current,
    max,
    units,
    icon,
    iconColor,
    currentColor,
    maxColor,
    currentSize,
    maxSize,
    ml,
    mr,
  } = props;
  return (
    <Box inline color={currentColor || 'white'} bold ml={ml} mr={mr}>
      {icon && (
        <Icon
          name={icon}
          color={iconColor || currentColor}
          pr={SPACING_PIXELS}
        />
      )}
      <Box inline fontSize={currentSize || '100%'}>
        {current}
      </Box>
      <Box
        inline
        fontSize={maxSize || COUNTER_MAX_SIZE}
        color={maxColor || COLOR_MID_GREY}
      >
        {!!max && `/${max}`}
        {units}
      </Box>
    </Box>
  );
}
