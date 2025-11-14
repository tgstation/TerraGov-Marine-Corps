import { ReactNode } from 'react';
import { Box, Icon } from 'tgui-core/components';

import { ROUNDED_BORDER, SPACING_PIXELS } from './constants';

type Props = {
  children: ReactNode;
  icon?: string;
  textColor?: string;
  backgroundColor?: string;
  ml?: string;
  mr?: string;
};

/** Bold box with a background */
export function MedBoxedTag(props: Props) {
  const { children, icon, textColor, backgroundColor, ml, mr } = props;
  return (
    <Box
      inline
      bold
      ml={ml}
      mr={mr}
      px={SPACING_PIXELS}
      textColor={textColor || 'black'}
      backgroundColor={backgroundColor || 'white'}
      style={ROUNDED_BORDER}
    >
      {!!icon && (
        <Icon
          name={icon || 'warning'}
          color={textColor || 'black'}
          pr={SPACING_PIXELS}
        />
      )}
      {children}
    </Box>
  );
}
