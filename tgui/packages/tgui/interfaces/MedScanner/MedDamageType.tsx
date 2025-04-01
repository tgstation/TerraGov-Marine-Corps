import { Box, ProgressBar, Tooltip } from 'tgui-core/components';

import { SPACING_PIXELS } from './constants';

type Props = {
  tooltip: string;
  name: string;
  color?: string;
  damage?: number;
  disabled?: boolean;
  noPadding?: boolean;
};

/**
 * A component for damage types on the health analyzer
 *
 * `disabled` will color the entire component grey if true.
 *
 * `noPadding` will not put padding to the left of this if true, use for
 * things that are the first entry in an inline list (brute damage!)
 */
export function MedDamageType(props: Props) {
  const { tooltip, name, color, damage, disabled, noPadding } = props;
  return (
    <Tooltip content={tooltip}>
      <Box inline color={disabled && 'grey'} pl={!noPadding && SPACING_PIXELS}>
        <ProgressBar value={0} color={(disabled && 'grey') || ''}>
          {(!disabled && name) || <del>{name}</del>}
          {!disabled && ': '}
          {!disabled && (
            <Box inline bold color={(disabled && 'grey') || color}>
              {damage}
            </Box>
          )}
        </ProgressBar>
      </Box>
    </Tooltip>
  );
}
