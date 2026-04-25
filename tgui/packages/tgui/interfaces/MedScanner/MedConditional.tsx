import { ReactNode } from 'react';
import { Box, Icon, Tooltip } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { SPACING_PIXELS } from './constants';

type SharedProps = {
  condition: string | BooleanLike;
  tooltip: string;
  color?: string;
};

/**
 * If `condition` resolves to non-null, display a textbox
 * that reads like **children**, using `color` (if color exists)
 */
export function MedConditionalBox(
  props: SharedProps & {
    children: ReactNode;
  },
) {
  const { children, condition, tooltip, color } = props;
  if (condition) {
    return (
      <Tooltip content={tooltip}>
        <Box inline color={color} bold>
          {children}
        </Box>
      </Tooltip>
    );
  }
}

/**
 * If `condition` resolves to non-null, display an icon
 * using `name` and `color` (if color exists)
 */
export function MedConditionalIcon(props: SharedProps & { name: string }) {
  const { condition, tooltip, name, color } = props;
  if (condition) {
    return (
      <Tooltip content={tooltip}>
        <Icon name={name} inline color={color} pr={SPACING_PIXELS} />
      </Tooltip>
    );
  }
}
