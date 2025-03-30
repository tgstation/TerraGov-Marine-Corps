import {
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
  DARKER_ORANGE,
  DARKER_RED,
  MID_GREY,
  RESERVE_FONT_SIZE,
  ROBOT_LIMB_COLOR,
  SPACING_PIXELS,
  ZEBRA_BG_COLOR,
} from './constants';
import { MedScannerData } from './data';
import { getLimbColor } from './helpers';

export function MedScanner() {
  const { data } = useBackend<MedScannerData>();
  const {
    species,
    has_chemicals,
    limbs_damaged,
    damaged_organs,
    blood_amount,
    regular_blood_amount,
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
          ? species === 'robot'
            ? 'hackerman'
            : 'default'
          : species === 'robot'
            ? 'ntos_rusty'
            : 'ntos_healthy'
      }
    >
      <Window.Content scrollable>
        <PatientBasics />
        {has_chemicals ? <PatientChemicals /> : null}
        {limbs_damaged ? <PatientLimbs /> : null}
        {damaged_organs?.length ? <PatientOrgans /> : null}
        {blood_amount < regular_blood_amount || internal_bleeding ? (
          <PatientBlood />
        ) : null}
        {advice ? <PatientAdvice /> : null}
      </Window.Content>
    </Window>
  );
}

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
      title={(species === 'robot' ? 'Robot: ' : 'Patient: ') + patient}
      buttons={
        <Button
          icon="info"
          tooltip="For information on something, hover over it - most elements have tooltips. Additionally, situational advice will appear under Treatment Advice."
          color="transparent"
          mt={
            /* with the "hackerman" theme, the buttons have this ugly outline that messes with the section titlebar, let's fix that */
            accessible_theme ? (species === 'robot' ? '-5px' : '0px') : '0px'
          }
        >
          Information
        </Button>
      }
    >
      {hugged ? (
        <NoticeBox danger>
          Patient has been implanted with an alien embryo!
        </NoticeBox>
      ) : null}
      {ssd ? <NoticeBox warning>{ssd}</NoticeBox> : null}
      <LabeledList>
        <LabeledList.Item
          label="Health"
          tooltip={
            'How healthy the patient is.' +
            (species === 'robot'
              ? ''
              : " If the patient's health dips below " +
                crit_threshold +
                '%, they enter critical condition and suffocate rapidly.') +
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
            <ProgressBar
              value={1 + health / max_health}
              ranges={{
                bad: [-Infinity, Infinity],
              }}
            >
              {Math.trunc((health / max_health) * 100)}%
            </ProgressBar>
          )}
        </LabeledList.Item>
        {dead ? (
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
        ) : null}
        <LabeledList.Item
          label="Damage"
          tooltip="Unique damage types. Each one has a tooltip describing how it is sustained, and possible treatments."
        >
          <Tooltip
            content={
              species === 'robot'
                ? 'Brute. Sustained from sources of physical trauma such as melee combat, firefights, etc. Repaired with a blowtorch or robotic cradle.'
                : 'Brute. Sustained from sources of physical trauma such as melee combat, firefights, etc. Treated with Bicaridine or advanced trauma kits.'
            }
          >
            <Box inline>
              <ProgressBar value={0}>
                Brute:{' '}
                <Box inline bold color={COLOR_BRUTE}>
                  {total_brute}
                </Box>
              </ProgressBar>
            </Box>
          </Tooltip>
          <Box inline width={'5px'} />
          <Tooltip
            content={
              species === 'robot'
                ? 'Burn. Sustained from sources of burning such as energy weapons, acid, fire, etc. Repaired with cable coils or a robotic cradle.'
                : 'Burn. Sustained from sources of burning such as overheating, energy weapons, acid, fire, etc. Treated with Kelotane or advanced burn kits.'
            }
          >
            <Box inline>
              <ProgressBar value={0}>
                Burn:{' '}
                <Box inline bold color={COLOR_BURN}>
                  {total_burn}
                </Box>
              </ProgressBar>
            </Box>
          </Tooltip>
          {species !== 'robot' ? (
            <>
              <Box inline width={'5px'} />
              <Tooltip content="Toxin. Sustained from chemicals or organ damage. Treated with Dylovene.">
                <Box inline>
                  <ProgressBar value={0}>
                    Tox:{' '}
                    <Box inline bold color="green">
                      {toxin}
                    </Box>
                  </ProgressBar>
                </Box>
              </Tooltip>
              <Box inline width={'5px'} />
              <Tooltip content="Oxyloss. Sustained from being in critical condition, organ damage or extreme exhaustion. Treated with CPR, Dexalin Plus or decreases on its own if the patient isn't in critical condition.">
                <Box inline>
                  <ProgressBar value={0}>
                    Oxy:{' '}
                    <Box inline bold color="blue">
                      {oxy}
                    </Box>
                  </ProgressBar>
                </Box>
              </Tooltip>
            </>
          ) : null}
          <Box inline width={'5px'} />
          <Tooltip
            content={
              species === 'robot'
                ? 'Integrity Damage. Sustained from xenomorph psychic draining. Treated with a robotic cradle.'
                : 'Cloneloss. Sustained from xenomorph psychic draining or special chemicals. Treated with cryogenics or sleep.'
            }
          >
            <Box inline>
              <ProgressBar value={0}>
                {species === 'robot' ? 'Integrity' : 'Clone'}:{' '}
                <Box inline bold color="teal">
                  {clone}
                </Box>
              </ProgressBar>
            </Box>
          </Tooltip>
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
      {has_unknown_chemicals ? (
        <Tooltip content="There are unknown reagents detected inside the patient. Proceed with caution.">
          <NoticeBox color="orange">Unknown reagents detected.</NoticeBox>
        </Tooltip>
      ) : null}
      <Stack vertical>
        {Object.values(chemicals_lists).map((chemical) => (
          <Stack.Item
            key={chemical.name}
            backgroundColor={row_transparency++ % 2 === 0 ? ZEBRA_BG_COLOR : ''}
            style={{
              borderRadius: '0.16em',
            }}
          >
            <Box inline p={'2.5px'}>
              <Icon
                name={'flask'}
                ml={0.2}
                pr={SPACING_PIXELS}
                color={chemical.dangerous ? 'red' : chemical.color}
              />
              <Box
                inline
                color={chemical.dangerous ? 'red' : 'white'}
                bold={chemical.dangerous}
              >
                <Tooltip
                  content={`The chemical's current units. OD at ${chemical.od_threshold}u. Critical OD at ${chemical.crit_od_threshold}u.`}
                >
                  <Box
                    inline
                    bold
                    color={chemical.dangerous ? 'red' : 'white'}
                    mr={SPACING_PIXELS}
                  >
                    {chemical.amount}
                    <Box
                      inline
                      color={chemical.dangerous ? DARKER_RED : MID_GREY}
                      fontSize={RESERVE_FONT_SIZE}
                    >
                      /{chemical.od_threshold}u
                    </Box>
                  </Box>
                </Tooltip>
                <Tooltip content={chemical.description}>
                  <Box inline italic>
                    {chemical.name}
                  </Box>
                </Tooltip>
              </Box>
              <Box inline width={'5px'} />
              {chemical.dangerous ? (
                chemical.od ? (
                  /* Only show the OD warning if the OD is why this is dangerous */
                  <Tooltip
                    content={
                      'Purge below ' +
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
                    <Box
                      inline
                      color="white"
                      bold
                      backgroundColor={'red'}
                      px={SPACING_PIXELS}
                      style={{
                        borderRadius: '0.16em',
                      }}
                    >
                      <Icon name="temperature-full" mr={SPACING_PIXELS} />
                      {Math.trunc(
                        (chemical.amount / chemical.od_threshold) * 100,
                      ) +
                        '% OD' +
                        (chemical.amount > chemical.crit_od_threshold
                          ? ', CRIT'
                          : '')}
                      <Icon name="temperature-arrow-down" mx={SPACING_PIXELS} />
                      {Math.trunc(
                        (chemical.amount - chemical.od_threshold) /
                          chemical.metabolism_factor,
                      ) + 's'}
                    </Box>
                  </Tooltip>
                ) : (
                  <Tooltip
                    content={
                      'Harmful chemical. Purge immediately. ' +
                      Math.trunc(
                        (chemical.amount - chemical.od_threshold) /
                          chemical.metabolism_factor,
                      ) +
                      's remaining before this is cleared on its own.'
                    }
                  >
                    <Box
                      inline
                      color="white"
                      bold
                      backgroundColor="red"
                      px={SPACING_PIXELS}
                      style={{
                        borderRadius: '0.16em',
                      }}
                    >
                      HARMFUL
                    </Box>
                  </Tooltip>
                )
              ) : (
                <Tooltip
                  content={
                    (chemical.amount / chemical.od_threshold) * 100 > 92
                      ? 'This chemical is getting close to overdosing. (>92%)'
                      : (chemical.amount / chemical.od_threshold) * 100 < 8
                        ? 'This chemical is getting close to being cleared out. (<8%)'
                        : 'How close this chemical is to its overdose threshold. This chemical is holding steady.'
                  }
                >
                  <Box
                    inline
                    color={
                      (chemical.amount / chemical.od_threshold) * 100 < 8
                        ? 'white'
                        : 'black'
                    }
                    bold
                    backgroundColor={
                      (chemical.amount / chemical.od_threshold) * 100 > 92
                        ? 'yellow'
                        : (chemical.amount / chemical.od_threshold) * 100 < 8
                          ? 'grey'
                          : 'white'
                    }
                    px={SPACING_PIXELS}
                    style={{
                      borderRadius: '0.16em',
                    }}
                  >
                    <Icon
                      name={
                        (chemical.amount / chemical.od_threshold) * 100 > 90
                          ? 'temperature-three-quarters'
                          : (chemical.amount / chemical.od_threshold) * 100 < 10
                            ? 'temperature-empty'
                            : 'temperature-half'
                      }
                      mr={SPACING_PIXELS}
                    />
                    {Math.trunc(
                      (chemical.amount / chemical.od_threshold) * 100,
                    ) + '%'}
                  </Box>
                </Tooltip>
              )}
              <Tooltip content="Estimated time before this chemical is purged. May vary based on time dilation and other chemicals.">
                <Box
                  inline
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
                  bold
                  px={SPACING_PIXELS}
                  ml={SPACING_PIXELS}
                  style={{
                    borderRadius: '0.16em',
                  }}
                >
                  <Icon name="clock" mr={SPACING_PIXELS} />
                  {/* Getting the /estimated/ time for when this chemical will wear off.
                      It's mostly accurate, but chemicals with lower metab rates will be slower to update
                      and chemicals with higher metab rates will be faster to update. */}
                  {Math.trunc(chemical.amount / chemical.metabolism_factor) +
                    's'}
                </Box>
              </Tooltip>
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
        <Stack height="20px">
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
            width="100%"
            py="3px"
            backgroundColor={row_transparency++ % 2 === 0 ? ZEBRA_BG_COLOR : ''}
            style={{
              borderRadius: '0.16em',
            }}
          >
            <Stack.Item
              basis="80px"
              pl="3px"
              bold={limb.brute + limb.burn !== 0 || limb.missing}
              textColor={
                limb.missing
                  ? 'grey'
                  : species === 'robot'
                    ? 'white'
                    : getLimbColor(
                        (limb.brute + limb.burn) / limb.max_damage,
                        limb.limb_type,
                      )
              }
            >
              {limb.name[0].toUpperCase() + limb.name.slice(1)}
            </Stack.Item>
            {limb.missing ? (
              <Tooltip
                content={
                  species === 'robot'
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
                      color={limb.brute > 0 ? 'red' : 'white'}
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
                  <Box inline width={SPACING_PIXELS} />
                </Stack.Item>
                <Stack.Item>
                  {!!limb.bleeding && (
                    <Tooltip content="The patient is losing blood from this limb. Bleeding can be stopped with gauze or an advanced trauma kit.">
                      <Icon
                        name="droplet"
                        inline
                        color="red"
                        bold
                        px={SPACING_PIXELS}
                      />
                    </Tooltip>
                  )}
                  {!!limb.limb_status && (
                    <Tooltip
                      content={
                        (limb.limb_status !== 'Fracture'
                          ? limb.limb_status === 'Stable'
                            ? "This fracture is stabilized by the patient's armor, suppressing most of its symptoms. If their armor is removed, it'll stop being stabilized."
                            : 'This fracture is stabilized by a splint, suppressing most of its symptoms. If this limb sustains damage, the splint might come off.'
                          : 'This limb is broken. Use a splint to stabilize it. An unsplinted head, chest or groin will cause organ damage when the patient moves. Unsplinted arms or legs will frequently give out.') +
                        ' It can be fully treated with surgery or cryo treatment.'
                      }
                    >
                      <Box
                        inline
                        color={
                          limb.limb_status !== 'Fracture' ? 'lime' : 'white'
                        }
                        bold
                      >
                        [{limb.limb_status}]
                      </Box>
                    </Tooltip>
                  )}
                  {!!limb.limb_type && (
                    <Tooltip
                      content={
                        limb.limb_type === 'Robotic'
                          ? 'Robotic limbs are only fixed by welding or cable coils.'
                          : 'Biotic limbs take more damage, but can be fixed through normal methods.'
                      }
                    >
                      <Box
                        inline
                        color={
                          limb.limb_type === 'Robotic'
                            ? species === 'robot'
                              ? accessible_theme
                                ? 'lime'
                                : 'label'
                              : ROBOT_LIMB_COLOR
                            : 'tan'
                        }
                        bold
                      >
                        [{limb.limb_type}]
                      </Box>
                    </Tooltip>
                  )}
                  {!!limb.open_incision && (
                    <Tooltip content="Open surgical incisions can usually be closed by a cautery depending on the stage of the surgery. Risk of infection if left untreated.">
                      <Box inline color="red" bold>
                        [Open Incision]
                      </Box>
                    </Tooltip>
                  )}
                  {!!limb.infected && (
                    <Tooltip content="Infected limbs can be treated with spaceacillin. Risk of necrosis if left untreated.">
                      <Box inline color="olive" bold>
                        [Infected]
                      </Box>
                    </Tooltip>
                  )}
                  {!!limb.necrotized && (
                    <Tooltip content="Necrotized arms or legs cause random dropping of items or falling over, respectively. Organ damage will occur if on the head, chest or groin. Treated by surgery.">
                      <Box inline color="brown" bold>
                        [Necrotizing]
                      </Box>
                    </Tooltip>
                  )}
                  {!!limb.implants && (
                    <Tooltip content="Harmful implants are usually shrapnel from firefights. Moving with a harmful implant will inflict Brute damage occasionally. Removed with tweezers.">
                      <Box inline color="white" bold>
                        [Implant x{limb.implants}]
                      </Box>
                    </Tooltip>
                  )}
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
            backgroundColor={row_transparency++ % 2 === 0 ? ZEBRA_BG_COLOR : ''}
            style={{
              borderRadius: '0.16em',
            }}
          >
            <Box inline p={'3px'}>
              <Icon
                name={organ.status === 'Failing' ? 'circle-dot' : 'circle'}
                ml={0.2}
                pr={SPACING_PIXELS}
                color={
                  organ.status === 'Damaged'
                    ? 'orange'
                    : organ.status === 'Failing'
                      ? 'red'
                      : 'grey'
                }
              />
              <Box inline>
                <Tooltip
                  content={`Considered damaged at ${organ.bruised_damage}, failing at ${organ.broken_damage}.`}
                >
                  <Box
                    inline
                    color={
                      organ.status === 'Damaged'
                        ? 'orange'
                        : organ.status === 'Failing'
                          ? 'red'
                          : 'grey'
                    }
                    bold
                    mr={'5px'}
                  >
                    {Math.trunc(organ.damage)}
                    <Box
                      inline
                      fontSize={RESERVE_FONT_SIZE}
                      color={
                        organ.status === 'Failing'
                          ? DARKER_RED
                          : organ.status === 'Damaged'
                            ? DARKER_ORANGE
                            : 'grey'
                      }
                    >
                      /{organ.broken_damage}
                    </Box>
                  </Box>
                </Tooltip>
                <Tooltip
                  content={
                    organ.status === 'Functional'
                      ? 'This organ is considered fully functional and not damaged or failing. It may still be causing very minor effects like pain.'
                      : organ.effects
                  }
                >
                  <Box inline italic mr={'5px'}>
                    {organ.name[0].toUpperCase() + organ.name.slice(1)}
                  </Box>
                </Tooltip>
              </Box>
              {organ.status ? (
                <Box
                  inline
                  color="white"
                  bold
                  backgroundColor={
                    organ.status === 'Damaged'
                      ? 'orange'
                      : organ.status === 'Failing'
                        ? 'red'
                        : 'grey'
                  }
                  px={SPACING_PIXELS}
                  style={{
                    borderRadius: '0.16em',
                  }}
                >
                  {organ.status.toUpperCase()}
                </Box>
              ) : null}
            </Box>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}

function PatientBlood() {
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
  let blood_warning =
    blood_amount / regular_blood_amount < 0.8 || internal_bleeding;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item
          label={'Blood Volume'}
          tooltip="Bloodloss causes symptoms that start as suffocation and pain, but get significantly worse as more blood is lost. Blood can be restored by eating and taking Isotonic solution."
        >
          <Box
            mr={SPACING_PIXELS}
            inline
            color={blood_warning ? 'red' : 'white'}
            bold={blood_warning ? true : false}
          >
            {Math.trunc((blood_amount / regular_blood_amount) * 100)}%
            <Box
              inline
              color={blood_warning ? DARKER_RED : MID_GREY}
              pl={SPACING_PIXELS}
              fontSize={RESERVE_FONT_SIZE}
            >
              ({Math.trunc(blood_amount)}/{Math.trunc(regular_blood_amount)}cl)
            </Box>
          </Box>
          <Box
            mr={SPACING_PIXELS}
            inline
            bold
            px={SPACING_PIXELS}
            backgroundColor={blood_warning ? 'red' : 'grey'}
            style={{
              borderRadius: '0.16em',
            }}
          >
            {blood_type}
          </Box>
          {!!internal_bleeding && (
            <Box
              inline
              bold
              px={SPACING_PIXELS}
              backgroundColor="red"
              style={{
                borderRadius: '0.16em',
              }}
            >
              INTERNAL BLEEDING
            </Box>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Body Temperature">
          {body_temperature}
        </LabeledList.Item>
        <LabeledList.Item label="Pulse">{pulse}</LabeledList.Item>
      </LabeledList>
      {infection ? (
        <NoticeBox color="orange" mt="8px" mb="0px">
          {infection}
        </NoticeBox>
      ) : null}
      {total_unknown_implants ? (
        <NoticeBox color="orange" mt="8px" mb="0px">
          There {total_unknown_implants !== 1 ? 'are' : 'is'}{' '}
          {total_unknown_implants} unknown implant
          {total_unknown_implants !== 1 ? 's' : ''} detected within the patient.
        </NoticeBox>
      ) : null}
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
              content={
                advice.tooltip
                  ? advice.tooltip
                  : 'No tooltip entry for this advice.'
              }
            >
              <Box inline>
                <Icon
                  name={advice.icon}
                  ml={0.2}
                  color={
                    accessible_theme
                      ? advice.color
                      : species === 'robot'
                        ? 'label'
                        : advice.color
                  }
                />
                <Box inline width={'5px'} />
                {advice.advice}
              </Box>
            </Tooltip>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}
