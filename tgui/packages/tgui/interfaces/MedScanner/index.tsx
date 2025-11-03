import {
  BlockQuote,
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  COLOR_BRUTE,
  COLOR_BURN,
  COLOR_DARKER_ORANGE,
  COLOR_DARKER_RED,
  COLOR_DARKER_YELLOW,
  COLOR_MID_GREY,
  COLOR_ROBOTIC_LIMB,
  COLOR_ZEBRA_BG,
  COUNTER_MAX_SIZE,
  ROUNDED_BORDER,
  SPACING_PIXELS,
} from './constants';
import { MedScannerData } from './data';
import { getLimbColor } from './helpers';
import { MedBoxedTag } from './MedBoxedTag';
import { MedConditionalBox, MedConditionalIcon } from './MedConditional';
import { MedCounter } from './MedCounter';
import { MedDamageType } from './MedDamageType';

export function MedScanner() {
  const { data } = useBackend<MedScannerData>();
  const {
    species,
    has_chemicals,
    limbs_damaged,
    damaged_organs,
    blood_amount,
    regular_blood_amount,
    body_temperature,
    internal_bleeding,
    advice,
    accessible_theme,
  } = data;
  return (
    <Window
      width={520}
      height={620}
      theme={
        accessible_theme
          ? species.is_robotic_species
            ? 'hackerman'
            : 'default'
          : species.is_robotic_species
            ? 'ntos_rusty'
            : 'ntos_healthy'
      }
    >
      <Window.Content scrollable>
        <PatientBasics />
        {!!has_chemicals && <PatientChemicals />}
        {!!limbs_damaged && <PatientLimbs />}
        {!!damaged_organs?.length && <PatientOrgans />}
        {!!(
          blood_amount < regular_blood_amount ||
          internal_bleeding ||
          body_temperature.warning
        ) && <PatientFooter />}
        {!!advice && <PatientAdvice />}
      </Window.Content>
    </Window>
  );
}

/** The most basic info: name, species, health, damage, revivability and hugged state */
function PatientBasics() {
  const { data } = useBackend<MedScannerData>();
  const {
    patient,
    species,
    dead,

    health,
    max_health,
    crit_threshold,
    dead_threshold,

    total_brute,
    total_burn,
    toxin,
    oxy,
    clone,

    hugged,

    revivable_boolean,
    revivable_string,

    ssd,

    accessible_theme,
  } = data;
  return (
    <Section
      title={`${species.name}: ${patient}`}
      buttons={
        <Button
          icon="info"
          tooltip="For information on something, hover over it - nearly every element has a tooltip. Additionally, situational advice will appear under Treatment Advice."
          color="transparent"
          mt={
            // with the "hackerman" theme, the buttons have this ugly outline that messes with the section titlebar, let's fix that
            accessible_theme && species.is_robotic_species ? '-5px' : '0px'
          }
        >
          Information
        </Button>
      }
    >
      {!!hugged && (
        <NoticeBox danger>
          Patient has been implanted with an alien embryo!
        </NoticeBox>
      )}
      {!!ssd && <NoticeBox>{ssd}</NoticeBox>}
      <LabeledList>
        <LabeledList.Item
          label="Health"
          tooltip={
            'How healthy the patient is.' +
            ((!species.is_robotic_species &&
              " If the patient's health dips below " +
                crit_threshold +
                '%, they enter critical condition and suffocate rapidly.') ||
              '') +
            " If the patient's health hits " +
            (dead_threshold / max_health) * 100 +
            '%, they die.'
          }
        >
          {health >= 0 ? (
            <ProgressBar
              value={health / max_health}
              ranges={{
                good: [0.4, Infinity],
                average: [0.2, 0.4],
                bad: [-Infinity, 0.2],
              }}
            />
          ) : (
            <ProgressBar value={1 + health / max_health} color="bad">
              {Math.trunc((health / max_health) * 100)}%
            </ProgressBar>
          )}
        </LabeledList.Item>
        {!!dead && (
          <LabeledList.Item label="Revivable">
            <Box
              color={
                revivable_boolean
                  ? accessible_theme
                    ? 'yellow'
                    : 'label'
                  : 'red'
              }
              bold
            >
              {revivable_string}
            </Box>
          </LabeledList.Item>
        )}
        <LabeledList.Item
          label="Damage"
          tooltip="Unique damage types. Each one has a tooltip describing how it is sustained, and possible treatments."
        >
          <MedDamageType
            name="Brute"
            color={COLOR_BRUTE}
            damage={total_brute}
            tooltip={
              species.is_robotic_species
                ? 'Brute. Sustained from sources of physical trauma such as melee combat, firefights, etc. Repaired with a blowtorch or robotic cradle.'
                : 'Brute. Sustained from sources of physical trauma such as melee combat, firefights, etc. Treated with Bicaridine or advanced trauma kits.'
            }
            noPadding
          />
          <MedDamageType
            name="Burn"
            color={COLOR_BURN}
            damage={total_burn}
            tooltip={
              species.is_robotic_species
                ? 'Burn. Sustained from sources of burning such as energy weapons, acid, fire, etc. Repaired with cable coils or a robotic cradle.'
                : 'Burn. Sustained from sources of burning such as overheating, energy weapons, acid, fire, etc. Treated with Kelotane or advanced burn kits.'
            }
          />
          {!species.is_robotic_species && (
            <>
              <MedDamageType
                name="Tox"
                color="green"
                damage={toxin}
                tooltip="Toxin. Sustained from chemicals or organ damage. Treated with Dylovene."
              />
              <MedDamageType
                name="Oxy"
                color="blue"
                damage={oxy}
                tooltip="Oxyloss. Sustained from being in critical condition, organ damage or extreme exhaustion. Treated with CPR, Dexalin/Dexalin Plus or decreases on its own if the patient isn't in critical condition."
              />
            </>
          )}
          {!species.is_synthetic && (
            <MedDamageType
              name={species.is_combat_robot ? 'Integrity' : 'Clone'}
              color="teal"
              damage={clone}
              tooltip={
                species.is_robotic_species
                  ? 'Integrity Damage. Sustained from xenomorph psychic draining. Treated with a robotic cradle.'
                  : 'Cloneloss. Sustained from xenomorph psychic draining or special chemicals. Treated with cryogenics or sleep.'
              }
            />
          )}
          {!!species.is_robotic_species && (
            <>
              <MedDamageType
                name="Tox"
                tooltip="Robotic species cannot build up toxins."
                disabled
              />
              <MedDamageType
                name="Oxy"
                tooltip="Robotic species do not suffocate."
                disabled
              />
              {!!species.is_synthetic && (
                <MedDamageType
                  name="Clone"
                  tooltip="Synthetics do not suffer cellular damage or long term integrity loss."
                  disabled
                />
              )}
            </>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}

function PatientChemicals() {
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
        {Object.values(chemicals_lists).map((chemical) => (
          <Stack.Item
            order={chemical.ui_priority}
            key={chemical.name}
            backgroundColor={row_transparency++ % 2 === 0 ? COLOR_ZEBRA_BG : ''}
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
                            chemical.od || chemical.dangerous ? 'red' : 'label'
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
                                chemical.amount > chemical.crit_od_threshold &&
                                'red'
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
                  bold={(chemical.dangerous || chemical.od) as boolean}
                >
                  <MedCounter
                    current={chemical.amount}
                    max={chemical.dangerous ? 0 : chemical.od_threshold}
                    units="u"
                    icon="flask"
                    iconColor={
                      chemical.dangerous || chemical.od ? 'red' : chemical.color
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
                  content={
                    chemical.dangerous
                      ? 'Harmful chemical. Purge immediately.'
                      : 'Purge below ' +
                        chemical.od_threshold +
                        'u' +
                        ' to stabilize. ' +
                        (chemical.amount > chemical.crit_od_threshold
                          ? 'This is a critical OD, so its effects are worse than normal. '
                          : '') +
                        Math.trunc(
                          (chemical.amount - chemical.od_threshold) /
                            chemical.metabolism_factor,
                        ) +
                        's remaining before this returns to non-OD levels on its own.'
                  }
                >
                  <MedBoxedTag
                    icon={chemical.od ? 'gauge-high' : 'virus'}
                    textColor="white"
                    backgroundColor="red"
                    ml={SPACING_PIXELS}
                  >
                    {chemical.od
                      ? 'OD' +
                        (chemical.amount > chemical.crit_od_threshold
                          ? ', CRIT'
                          : '')
                      : 'HARMFUL'}
                  </MedBoxedTag>
                </Tooltip>
              )}
              {!!chemical.metabolism_factor && (
                <Tooltip content="Estimated time before this chemical is purged. May vary based on time dilation and other chemicals.">
                  <MedBoxedTag
                    icon="clock"
                    textColor={
                      chemical.dangerous
                        ? 'white'
                        : chemical.amount / chemical.metabolism_factor < 10
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
                    {Math.trunc(chemical.amount / chemical.metabolism_factor) +
                      's'}
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

function PatientLimbs() {
  let row_transparency = 0;
  const { data } = useBackend<MedScannerData>();
  const { limb_data_lists = {}, species, accessible_theme } = data;
  return (
    <Section title="Limbs Damaged">
      <Stack vertical fill>
        <Stack height="20px" mb="-4px">
          <Stack.Item basis="80px" />
          <Stack.Item basis="50px" bold color={COLOR_BRUTE}>
            Brute
          </Stack.Item>
          <Stack.Item bold color={COLOR_BURN}>
            Burn
          </Stack.Item>
          <Stack.Item grow textAlign="right" color="grey" nowrap>
            <Icon name="droplet" inline bold px={SPACING_PIXELS} />
            {'= Bleeding '}
            {'{ } = Untreated'}
          </Stack.Item>
        </Stack>
        {Object.values(limb_data_lists).map((limb) => (
          <Stack
            key={limb.name}
            fill
            py="2.5px"
            backgroundColor={row_transparency++ % 2 === 0 ? COLOR_ZEBRA_BG : ''}
            style={ROUNDED_BORDER}
            my="-2px"
          >
            <Stack.Item
              basis="80px"
              pl="2.5px"
              bold={limb.brute + limb.burn !== 0 || limb.missing}
              textColor={
                limb.missing
                  ? 'grey'
                  : species.is_robotic_species
                    ? 'white'
                    : getLimbColor(
                        limb.brute,
                        limb.burn,
                        limb.max_damage,
                        limb.limb_type,
                      )
              }
            >
              {limb.name[0].toUpperCase() + limb.name.slice(1)}
            </Stack.Item>
            {limb.missing ? (
              <Tooltip
                content={
                  species.is_robotic_species
                    ? 'Missing limbs on robotic patients can be fixed easily through a robotic cradle. Head reattachment can only be done through surgical intervention.'
                    : 'Missing limbs can only be fixed through surgical intervention. Head reattachment is only possible for combat robots and synthetics. Only printed limbs work as a replacement, except for head reattachment.'
                }
              >
                <Stack.Item color="grey">Missing</Stack.Item>
              </Tooltip>
            ) : (
              <>
                <Stack.Item>
                  <Tooltip
                    content={
                      limb.limb_type === 'Robotic'
                        ? 'Limb denting. Can be welded with a blowtorch or nanopaste.'
                        : limb.bandaged
                          ? 'Treated wounds will slowly heal on their own, or can be healed faster with chemicals.'
                          : 'Untreated physical trauma. Can be bandaged with gauze or advanced trauma kits.'
                    }
                  >
                    <Box
                      inline
                      width="50px"
                      color={limb.brute > 0 ? COLOR_BRUTE : 'white'}
                    >
                      {limb.bandaged ? `${limb.brute}` : `{${limb.brute}}`}
                    </Box>
                  </Tooltip>
                  <Box inline width={SPACING_PIXELS} />
                  <Tooltip
                    content={
                      limb.limb_type === 'Robotic'
                        ? 'Wire scorching. Can be repaired with a cable coil or nanopaste.'
                        : limb.salved
                          ? 'Salved burns will slowly heal on their own, or can be healed faster with chemicals.'
                          : 'Unsalved burns. Can be salved with ointment or advanced burn kits.'
                    }
                  >
                    <Box
                      inline
                      width="40px"
                      color={limb.burn > 0 ? COLOR_BURN : 'white'}
                    >
                      {limb.salved ? `${limb.burn}` : `{${limb.burn}}`}
                    </Box>
                  </Tooltip>
                </Stack.Item>
                <Stack.Item>
                  <MedConditionalIcon
                    condition={limb.bleeding}
                    name="droplet"
                    color="red"
                    tooltip="The patient is losing blood from this limb. Bleeding can be stopped with gauze or an advanced trauma kit."
                  />
                  <MedConditionalBox
                    condition={limb.limb_status}
                    color={limb.limb_status !== 'Fracture' ? 'lime' : 'white'}
                    tooltip={
                      (limb.limb_status !== 'Fracture'
                        ? limb.limb_status === 'Stable'
                          ? "This fracture is stabilized by the patient's armor, suppressing most of its symptoms. If their armor is removed, it'll stop being stabilized."
                          : 'This fracture is stabilized by a splint, suppressing most of its symptoms. If this limb sustains damage, the splint might come off.'
                        : 'This limb is broken. Use a splint to stabilize it. An unsplinted head, chest or groin will cause organ damage when the patient moves. Unsplinted arms or legs will frequently give out.') +
                      ' It can be fully treated with surgery or cryo treatment.'
                    }
                  >
                    [{limb.limb_status}]
                  </MedConditionalBox>
                  <MedConditionalBox
                    condition={limb.limb_type}
                    color={
                      limb.limb_type === 'Robotic'
                        ? species.is_robotic_species
                          ? accessible_theme
                            ? 'lime'
                            : 'label'
                          : COLOR_ROBOTIC_LIMB
                        : 'tan'
                    }
                    tooltip={
                      limb.limb_type === 'Robotic'
                        ? 'Robotic limbs are only fixed by welding or cable coils.'
                        : 'Biotic limbs take more damage, but can be fixed through normal methods.'
                    }
                  >
                    [{limb.limb_type}]
                  </MedConditionalBox>
                  <MedConditionalBox
                    condition={limb.implants}
                    tooltip="Use tweezers to remove the implants. Risk of brute damage and internal bleeding if left untreated."
                  >
                    [Implant x{limb.implants}]
                  </MedConditionalBox>
                  <MedConditionalBox
                    condition={limb.open_incision}
                    color="red"
                    tooltip="Open surgical incisions can usually be closed by a cautery depending on the stage of the surgery. Risk of infection if left untreated."
                  >
                    [Open Incision]
                  </MedConditionalBox>
                  <MedConditionalBox
                    condition={limb.infected}
                    color="olive"
                    tooltip="Infected limbs can be treated with spaceacillin. Risk of necrosis if left untreated."
                  >
                    [Infected]
                  </MedConditionalBox>
                  <MedConditionalBox
                    condition={limb.necrotized}
                    color="brown"
                    tooltip="Necrotized arms or legs cause random dropping of items or falling over, respectively. Organ damage will occur if on the head, chest or groin. Treated by surgery."
                  >
                    [Necrosis]
                  </MedConditionalBox>
                </Stack.Item>
              </>
            )}
          </Stack>
        ))}
      </Stack>
    </Section>
  );
}

function PatientOrgans() {
  let row_transparency = 0;
  const { data } = useBackend<MedScannerData>();
  const { damaged_organs = {} } = data;
  return (
    <Section title="Organs Damaged">
      <Stack vertical>
        {Object.values(damaged_organs).map((organ) => (
          <Stack.Item
            key={organ.name}
            backgroundColor={row_transparency++ % 2 === 0 ? COLOR_ZEBRA_BG : ''}
            style={ROUNDED_BORDER}
          >
            <Box inline p="3px">
              <Tooltip
                content={
                  <>
                    <NoticeBox
                      color={
                        organ.status === 'Damaged'
                          ? 'orange'
                          : organ.status === 'Failing'
                            ? 'red'
                            : null
                      }
                      textAlign="center"
                    >
                      <Icon
                        name={
                          organ.status === 'Failing' ? 'circle-dot' : 'circle'
                        }
                        pr={SPACING_PIXELS}
                      />
                      {organ.name[0].toUpperCase() + organ.name.slice(1)}
                      {organ.status !== 'Functional' && ` (${organ.status})`}
                    </NoticeBox>
                    <BlockQuote>
                      {organ.status === 'Functional'
                        ? 'This organ is considered fully functional and not damaged or failing. It may still be causing very minor effects like pain.'
                        : organ.effects}
                    </BlockQuote>
                    <Box mt={SPACING_PIXELS} />
                    <LabeledList>
                      <LabeledList.Item
                        label="Thresholds"
                        labelColor={
                          organ.damage >= organ.bruised_damage
                            ? organ.damage >= organ.broken_damage
                              ? 'red'
                              : 'orange'
                            : 'label'
                        }
                      >
                        <Box
                          mb={SPACING_PIXELS}
                          color={
                            organ.damage >= organ.bruised_damage && 'orange'
                          }
                          bold={organ.damage >= organ.bruised_damage}
                        >
                          {organ.bruised_damage} (damaged)
                        </Box>
                        <Box
                          color={organ.damage >= organ.broken_damage && 'red'}
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
                    icon={organ.status === 'Failing' ? 'circle-dot' : 'circle'}
                    mr={SPACING_PIXELS}
                    currentColor={
                      organ.status === 'Damaged'
                        ? 'orange'
                        : organ.status === 'Failing'
                          ? 'red'
                          : 'grey'
                    }
                    maxColor={
                      organ.status === 'Failing'
                        ? COLOR_DARKER_RED
                        : organ.status === 'Damaged'
                          ? COLOR_DARKER_ORANGE
                          : 'grey'
                    }
                  />
                  <Box inline italic mr={SPACING_PIXELS}>
                    {organ.name[0].toUpperCase() + organ.name.slice(1)}
                  </Box>
                </Box>
              </Tooltip>
              {!!organ.status && (
                <MedBoxedTag
                  textColor="white"
                  backgroundColor={
                    organ.status === 'Damaged'
                      ? 'orange'
                      : organ.status === 'Failing'
                        ? 'red'
                        : 'grey'
                  }
                >
                  {organ.status.toUpperCase()}
                </MedBoxedTag>
              )}
            </Box>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}

function PatientFooter() {
  const { data } = useBackend<MedScannerData>();
  const {
    blood_amount,
    regular_blood_amount,
    blood_type,
    body_temperature,
    internal_bleeding,
    pulse,
    total_unknown_implants,
    infection,
  } = data;
  const bloodWarning =
    blood_amount / regular_blood_amount < 0.6 || internal_bleeding
      ? 'red'
      : blood_amount / regular_blood_amount < 0.9
        ? 'yellow'
        : 'white';
  const darkBloodWarning =
    bloodWarning === 'red'
      ? COLOR_DARKER_RED
      : bloodWarning === 'yellow'
        ? COLOR_DARKER_YELLOW
        : COLOR_MID_GREY;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item
          label="Blood Volume"
          tooltip="Bloodloss causes symptoms that start as suffocation and pain, but get significantly worse as more blood is lost. Blood can be restored by eating and taking Isotonic solution."
        >
          <Box
            mr={SPACING_PIXELS}
            inline
            color={bloodWarning}
            bold={bloodWarning !== 'white' ? true : false}
          >
            {Math.trunc((blood_amount / regular_blood_amount) * 100)}%
          </Box>
          <MedCounter
            current={Math.trunc(blood_amount)}
            max={Math.trunc(regular_blood_amount)}
            units="cl"
            currentColor={darkBloodWarning}
            maxColor={darkBloodWarning}
            currentSize={COUNTER_MAX_SIZE}
            mr={SPACING_PIXELS}
          />
          <MedBoxedTag
            mr={SPACING_PIXELS}
            textColor={bloodWarning === 'yellow' ? 'black' : 'white'}
            backgroundColor={bloodWarning === 'white' ? 'grey' : bloodWarning}
          >
            {blood_type}
          </MedBoxedTag>
          {!!internal_bleeding && (
            <MedBoxedTag textColor="white" backgroundColor="red">
              INTERNAL BLEEDING
            </MedBoxedTag>
          )}
        </LabeledList.Item>
        <LabeledList.Item
          label="Body Temperature"
          color={body_temperature.color}
        >
          <Box bold={body_temperature.warning}>{body_temperature.current}</Box>
        </LabeledList.Item>
        <LabeledList.Item label="Pulse">{pulse}</LabeledList.Item>
      </LabeledList>
      {!!infection && (
        <NoticeBox color="orange" mt="8px" mb="0px">
          {infection}
        </NoticeBox>
      )}
      {!!total_unknown_implants && (
        <NoticeBox color="orange" mt="8px" mb="0px">
          There {total_unknown_implants !== 1 ? 'are' : 'is'}{' '}
          {total_unknown_implants} unknown implant
          {total_unknown_implants !== 1 ? 's' : ''} detected within the patient.
        </NoticeBox>
      )}
    </Section>
  );
}

function PatientAdvice() {
  const { data } = useBackend<MedScannerData>();
  const { advice = {}, species, accessible_theme } = data;
  return (
    <Section title="Treatment Advice">
      <Stack vertical>
        {Object.values(advice).map((advice) => (
          <Stack.Item key={advice.advice}>
            <Tooltip
              content={advice.tooltip || 'No tooltip entry for this advice.'}
            >
              <Box inline>
                <Icon
                  name={advice.icon}
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
