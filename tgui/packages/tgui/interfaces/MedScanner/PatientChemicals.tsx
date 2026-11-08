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
import {
  COLOR_DARKER_RED,
  COLOR_MID_GREY,
  COLOR_ZEBRA_BG,
  ROUNDED_BORDER,
  SPACING_PIXELS,
} from './constants';
import { MedScannerData } from './data';
import { MedBoxedTag } from './MedBoxedTag';
import { MedCounter } from './MedCounter';

export function PatientChemicals() {
  let row_transparency = 0;
  const { data } = useBackend<MedScannerData>();
  const { has_unknown_chemicals, chemicals_lists = {} } = data;
  return (
    <Section title="Chemical Contents">
      {!!has_unknown_chemicals && (
        <NoticeBox color="orange">
          Unknown reagents detected. Proceed with caution.
        </NoticeBox>
      )}
      <Stack vertical>
        {Object.values(chemicals_lists)
          .sort((a, b) => {
            return a.ui_priority - b.ui_priority;
          })
          .map((chemical) => (
            <Stack.Item
              key={chemical.name}
              backgroundColor={
                row_transparency++ % 2 === 0 ? COLOR_ZEBRA_BG : ''
              }
              style={ROUNDED_BORDER}
            >
              <Box inline p="2.5px">
                <Tooltip
                  content={
                    <>
                      <NoticeBox
                        danger={!!(chemical.od || chemical.dangerous)}
                        textAlign="center"
                      >
                        <Icon name="flask" italic pr={SPACING_PIXELS} />
                        {chemical.name}
                        {!!chemical.od && ' (Overdose)'}
                        {!!chemical.dangerous && ' (Harmful)'}
                      </NoticeBox>
                      <BlockQuote>{chemical.description}</BlockQuote>
                      <Box mt={SPACING_PIXELS} />
                      <LabeledList>
                        {!!chemical.metabolism_factor && (
                          <LabeledList.Item
                            label="Metabolism"
                            labelColor={
                              chemical.od || chemical.dangerous
                                ? 'red'
                                : 'label'
                            }
                          >
                            {chemical.metabolism_factor}u per tick{' '}
                            <Box inline textColor="grey">
                              (~
                              {Math.trunc(
                                chemical.amount / chemical.metabolism_factor,
                              )}
                              s)
                            </Box>
                          </LabeledList.Item>
                        )}
                        {!!chemical.od_threshold && !chemical.dangerous && (
                          <LabeledList.Item
                            label="OD Units"
                            labelColor={chemical.od ? 'red' : 'label'}
                          >
                            <Box
                              color={chemical.od && 'red'}
                              bold={!!chemical.od}
                            >
                              {chemical.od_threshold}u (normal)
                            </Box>
                            {!!chemical.crit_od_threshold && (
                              <Box
                                pt={SPACING_PIXELS}
                                color={
                                  chemical.amount >
                                    chemical.crit_od_threshold && 'red'
                                }
                                bold={
                                  chemical.amount > chemical.crit_od_threshold
                                }
                              >
                                {chemical.crit_od_threshold}u (critical)
                              </Box>
                            )}
                          </LabeledList.Item>
                        )}
                      </LabeledList>
                    </>
                  }
                >
                  <Box
                    inline
                    color={chemical.dangerous || chemical.od ? 'red' : 'white'}
                    bold={!!(chemical.dangerous || chemical.od)}
                  >
                    <MedCounter
                      current={chemical.amount}
                      max={chemical.dangerous ? 0 : chemical.od_threshold}
                      units="u"
                      icon="flask"
                      iconColor={
                        chemical.dangerous || chemical.od
                          ? 'red'
                          : chemical.color
                      }
                      currentColor={
                        chemical.dangerous || chemical.od ? 'red' : 'white'
                      }
                      maxColor={
                        chemical.dangerous || chemical.od
                          ? COLOR_DARKER_RED
                          : COLOR_MID_GREY
                      }
                      mr={SPACING_PIXELS}
                    />
                    <Box inline italic>
                      {chemical.name}
                    </Box>
                  </Box>
                </Tooltip>
                {!!(chemical.dangerous || chemical.od) && (
                  <Tooltip
                    content={`
                    ${
                      chemical.dangerous
                        ? 'Harmful chemical. Purge immediately.'
                        : `Purge below ${chemical.od_threshold}u to stabilize.
                        ${
                          chemical.amount > chemical.crit_od_threshold
                            ? `This is a critical OD. Its effects are worse than normal. `
                            : ``
                        }${Math.trunc(
                          (chemical.amount - chemical.od_threshold) /
                            chemical.metabolism_factor,
                        )}s remaining before this returns to non-OD levels on its own.`
                    }
                  `}
                  >
                    <MedBoxedTag
                      icon={chemical.od ? 'gauge-high' : 'virus'}
                      textColor="white"
                      backgroundColor="red"
                      ml={SPACING_PIXELS}
                    >
                      {chemical.od
                        ? `OD${chemical.amount > chemical.crit_od_threshold ? ', CRIT' : ''}`
                        : 'HARMFUL'}
                    </MedBoxedTag>
                  </Tooltip>
                )}
                {!!chemical.metabolism_factor && (
                  <Tooltip content="Estimated time before this chemical is purged. May vary based on time dilation and other chemicals.">
                    <MedBoxedTag
                      icon="clock"
                      textColor={
                        chemical.dangerous ||
                        chemical.amount / chemical.metabolism_factor < 10
                          ? 'white'
                          : 'black'
                      }
                      backgroundColor={
                        chemical.dangerous
                          ? 'red'
                          : chemical.amount / chemical.metabolism_factor < 10
                            ? 'grey'
                            : 'white'
                      }
                      ml={SPACING_PIXELS}
                    >
                      {Math.trunc(
                        chemical.amount / chemical.metabolism_factor,
                      ) + 's'}
                    </MedBoxedTag>
                  </Tooltip>
                )}
              </Box>
            </Stack.Item>
          ))}
      </Stack>
    </Section>
  );
}
