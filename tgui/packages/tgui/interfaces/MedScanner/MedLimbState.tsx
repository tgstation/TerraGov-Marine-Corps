import { Box, Icon, Tooltip } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { SPACING_PIXELS } from './constants';

type SharedProps = {
  condition: string | BooleanLike;
  tooltip: string;
  name: string;
  color?: string;
};

/**
 * If `condition` resolves to non-null, display a textbox
 * that reads like **[Fracture]**, using `color` (if color exists)
 */
export function MedLimbStateText(props: SharedProps) {
  const { condition, tooltip, name, color } = props;
  return (
    !!condition && (
      <Tooltip content={tooltip}>
        <Box inline color={color || 'white'} bold>
          [{name}]
        </Box>
      </Tooltip>
    )
  );
}

/**
 * If `condition` resolves to non-null, display an icon
 * using `name` and `color` (if color exists)
 */
export function MedLimbStateIcon(props: SharedProps) {
  const { condition, tooltip, name, color } = props;
  return (
    !!condition && (
      <Tooltip content={tooltip}>
        <Icon name={name} inline color={color} pr={SPACING_PIXELS} />
      </Tooltip>
    )
  );
}
