import { Box, Icon, Section, Stack, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SPACING_PIXELS } from './constants';
import { MedScannerData } from './data';

/**
 * Guides users on how to treat a patient based on context.
 *
 * This should always go last. Advice is intended to *complement*
 * scan info and not get in the way for users who don't need it.
 */
export function PatientAdvice() {
  const { data } = useBackend<MedScannerData>();
  const { advice, species, accessible_theme } = data;
  if (!advice) return;
  return (
    <Section title="Treatment Advice">
      <Stack vertical>
        {advice.map((advice) => (
          <Stack.Item key={advice.advice}>
            <Tooltip
              content={advice.tooltip || 'No tooltip entry for this advice.'}
            >
              <Box inline>
                <Icon
                  name={advice.icon || 'triangle-exclamation'}
                  ml={0.2}
                  color={
                    accessible_theme
                      ? advice.color
                      : species.is_robotic_species
                        ? 'label'
                        : advice.color
                  }
                />
                <Box inline width={SPACING_PIXELS} />
                {advice.advice}
              </Box>
            </Tooltip>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}
