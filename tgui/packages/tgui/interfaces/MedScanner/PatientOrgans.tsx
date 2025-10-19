import {
  BlockQuote,
  Box,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { COLOR_ZEBRA_BG, ROUNDED_BORDER, SPACING_PIXELS } from './constants';
import { MedColorIndexes, MedScannerData, OrganStatuses } from './data';
import { getOrganColor } from './helpers';
import { MedBoxedTag } from './MedBoxedTag';
import { MedCounter } from './MedCounter';

export function PatientOrgans() {
  let row_transparency = 0;
  const { data } = useBackend<MedScannerData>();
  const { damaged_organs = {} } = data;
  return (
    <Section title="Organs Damaged">
      <Stack vertical>
        {Object.values(damaged_organs).map((organ) => {
          const colors = getOrganColor(organ.status);
          return (
            <Stack.Item
              key={organ.name}
              backgroundColor={
                row_transparency++ % 2 === 0 ? COLOR_ZEBRA_BG : ''
              }
              style={ROUNDED_BORDER}
            >
              <Box inline p="3px">
                <Tooltip
                  content={
                    <>
                      <NoticeBox
                        color={
                          organ.status
                            ? colors[MedColorIndexes.Background]
                            : undefined
                        }
                        textAlign="center"
                      >
                        <Icon
                          name={
                            organ.status === OrganStatuses.Broken
                              ? 'circle-dot'
                              : 'circle'
                          }
                          pr={SPACING_PIXELS}
                        />
                        {organ.name[0].toUpperCase() + organ.name.slice(1)}
                        {organ.status !== OrganStatuses.OK &&
                          ` (${organ.status})`}
                      </NoticeBox>
                      <BlockQuote>
                        {organ.status === OrganStatuses.OK
                          ? 'This organ is considered fully functional and not damaged or failing. It may still be causing very minor effects like pain.'
                          : organ.effects}
                      </BlockQuote>
                      <Box mt={SPACING_PIXELS} />
                      <LabeledList>
                        <LabeledList.Item
                          label="Thresholds"
                          labelColor={colors[MedColorIndexes.Background]}
                        >
                          <Box
                            mb={SPACING_PIXELS}
                            color={
                              organ.damage >= organ.bruised_damage &&
                              colors[MedColorIndexes.Background]
                            }
                            bold={organ.damage >= organ.bruised_damage}
                          >
                            {organ.bruised_damage} (damaged)
                          </Box>
                          <Box
                            color={
                              organ.damage >= organ.broken_damage &&
                              colors[MedColorIndexes.Background]
                            }
                            bold={organ.damage >= organ.broken_damage}
                          >
                            {organ.broken_damage} (failing)
                          </Box>
                        </LabeledList.Item>
                      </LabeledList>
                    </>
                  }
                >
                  <Box inline>
                    <MedCounter
                      current={organ.damage}
                      max={organ.broken_damage}
                      icon={
                        organ.status === OrganStatuses.Broken
                          ? 'circle-dot'
                          : 'circle'
                      }
                      mr={SPACING_PIXELS}
                      currentColor={colors[MedColorIndexes.Background]}
                      maxColor={colors[MedColorIndexes.Darker]}
                    />
                    <Box inline italic mr={SPACING_PIXELS}>
                      {organ.name[0].toUpperCase() + organ.name.slice(1)}
                    </Box>
                  </Box>
                </Tooltip>
                {!!organ.status && (
                  <MedBoxedTag
                    textColor={colors[MedColorIndexes.Foreground]}
                    backgroundColor={colors[MedColorIndexes.Background]}
                  >
                    {organ.status.toUpperCase()}
                  </MedBoxedTag>
                )}
              </Box>
            </Stack.Item>
          );
        })}
      </Stack>
    </Section>
  );
}
