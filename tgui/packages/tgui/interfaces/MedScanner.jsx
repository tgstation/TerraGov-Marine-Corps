import { useBackend } from '../backend';
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
} from '../components';
import { Window } from '../layouts';

export const MedScanner = (props) => {
  const { act, data } = useBackend();
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

    revivable_boolean,
    revivable_string,
    has_chemicals,
    has_unknown_chemicals,
    chemicals_lists,

    limb_data_lists,
    limbs_damaged,

    damaged_organs,
    ssd,

    blood_type,
    blood_amount,
    body_temperature,
    pulse,
    infection,
    internal_bleeding,
    implants,
    hugged,
    advice,
  } = data;
  const chemicals = Object.values(chemicals_lists);
  const limb_data = Object.values(limb_data_lists);
  let row_transparency = 0;
  const row_bg_color = 'rgba(255, 255, 255, .05)';
  const theme = species === 'robot' ? 'hackerman' : 'default';
  return (
    <Window width={515} height={625} theme={theme}>
      <Window.Content scrollable>
        <Section
          title={'Patient: ' + patient}
          buttons={
            <Button
              icon="info"
              tooltip="Most elements of this window have a tooltip for additional information. Hover your mouse over something for clarification!"
              color="transparent"
              mt={theme === 'hackerman' ? '-5px' : '0px'}
            >
              Tooltips - hover for info
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
            <LabeledList.Item label="Health">
              <Tooltip
                content={
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
                <ProgressBar
                  value={health / max_health}
                  ranges={{
                    good: [0.4, Infinity],
                    average: [0.2, 0.4],
                    bad: [-Infinity, 0.2],
                  }}
                />
              </Tooltip>
            </LabeledList.Item>
            {dead ? (
              <LabeledList.Item label="Revivable">
                <Box color={revivable_boolean ? 'yellow' : 'red'} bold={1}>
                  {revivable_string}
                </Box>
              </LabeledList.Item>
            ) : null}
            <LabeledList.Item label="Damage">
              <Tooltip
                content={
                  species === 'robot'
                    ? 'Brute. Sustained from sources of physical trauma such as melee combat, firefights, etc. Repaired with a blowtorch or robotic cradle.'
                    : 'Brute. Sustained from sources of physical trauma such as melee combat, firefights, etc. Treated with Bicaridine or advanced trauma kits.'
                }
              >
                <Box inline>
                  <ProgressBar>
                    Brute:{' '}
                    <Box inline bold color={'red'}>
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
                  <ProgressBar>
                    Burn:{' '}
                    <Box inline bold color={'#ffb833'}>
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
                      <ProgressBar>
                        Tox:{' '}
                        <Box inline bold color={'green'}>
                          {toxin}
                        </Box>
                      </ProgressBar>
                    </Box>
                  </Tooltip>
                  <Box inline width={'5px'} />
                  <Tooltip content="Oxyloss. Sustained from being in critical condition, organ damage or extreme exhaustion. Treated with CPR, Dexalin Plus or decreases on its own if the patient isn't in critical condition.">
                    <Box inline>
                      <ProgressBar>
                        Oxy:{' '}
                        <Box inline bold color={'blue'}>
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
                  <ProgressBar>
                    {species === 'robot' ? 'Integrity' : 'Clone'}:{' '}
                    <Box inline bold color={'teal'}>
                      {clone}
                    </Box>
                  </ProgressBar>
                </Box>
              </Tooltip>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {has_chemicals ? (
          <Section title="Chemical Contents">
            {has_unknown_chemicals ? (
              <Tooltip content="There are unknown reagents detected inside the patient. Proceed with caution.">
                <NoticeBox warning>Unknown reagents detected.</NoticeBox>
              </Tooltip>
            ) : null}
            <LabeledList>
              {chemicals.map((chemical) => (
                <LabeledList.Item key={chemical.name}>
                  <Tooltip
                    content={
                      chemical.description +
                      (chemical.od
                        ? ' (OVERDOSING)'
                        : chemical.od_threshold > 0 && !chemical.dangerous
                          ? ' (OD: ' + chemical.od_threshold + 'u)'
                          : '')
                    }
                  >
                    <Box
                      inline
                      color={chemical.dangerous ? 'red' : 'white'}
                      bold={chemical.dangerous}
                    >
                      {chemical.amount + 'u ' + chemical.name}
                    </Box>
                    <Box inline width={'5px'} />
                    {chemical.od ? (
                      <Box inline color={'red'} bold={1}>
                        {'OD'}
                      </Box>
                    ) : null}
                  </Tooltip>
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        ) : null}
        {limbs_damaged ? (
          <Section title="Limbs Damaged">
            <Stack vertical fill>
              <Stack height="20px">
                <Stack.Item basis="80px" />
                <Stack.Item basis="50px" bold color="red">
                  Brute
                </Stack.Item>
                <Stack.Item bold color="#ffb833">
                  Burn
                </Stack.Item>
                <Stack.Item grow="1" textAlign="right" nowrap>
                  {'{ } = Untreated'}
                </Stack.Item>
              </Stack>
              {limb_data.map((limb) => (
                <Stack
                  key={limb.name}
                  width="100%"
                  py="3px"
                  backgroundColor={
                    row_transparency++ % 2 === 0 ? row_bg_color : ''
                  }
                >
                  <Stack.Item basis="80px" bold pl="3px">
                    {limb.name[0].toUpperCase() + limb.name.slice(1)}
                  </Stack.Item>
                  {limb.missing ? (
                    <Tooltip content="Missing limbs can only be fixed through surgical intervention. Head reattachment is only possible for combat robots and synthetics. Only printed limbs work as a replacement, except for head reattachment.">
                      <Stack.Item color={'red'} bold={1}>
                        MISSING
                      </Stack.Item>
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
                            {limb.bandaged
                              ? `${limb.brute}`
                              : `{${limb.brute}}`}
                          </Box>
                        </Tooltip>
                        <Box inline width="5px" />
                        <Tooltip
                          content={
                            limb.limb_type === 'Robotic'
                              ? 'Wire scorching. Can be repaired with a cable coil or nanopaste.'
                              : limb.bandaged
                                ? 'Salved burns will slowly heal on their own, or can be healed faster with chemicals.'
                                : 'Unsalved burns. Can be salved with ointment or advanced burn kits.'
                          }
                        >
                          <Box
                            inline
                            width="40px"
                            color={limb.burn > 0 ? '#ffb833' : 'white'}
                          >
                            {limb.salved ? `${limb.burn}` : `{${limb.burn}}`}
                          </Box>
                        </Tooltip>
                        <Box inline width="5px" />
                      </Stack.Item>
                      <Stack.Item>
                        {limb.limb_status ? (
                          <Tooltip
                            content={
                              limb.limb_status === 'Splinted'
                                ? 'This fracture is stabilized by a splint, suppressing most of its symptoms. If this limb sustains damage, the splint might come off. It can be fully treated with surgery or cryo treatment.'
                                : limb.limb_status === 'Stabilized'
                                  ? "This fracture is stabilized by the patient's armor, suppressing most of its symptoms. If their armor is removed, it'll stop being stabilized. It can be fully treated with surgery or cryo treatment."
                                  : 'This limb is broken. Use a splint to stabilize it. An unsplinted head, chest or groin will cause organ damage when the patient moves. Unsplinted arms or legs will frequently give out.'
                            }
                          >
                            <Box
                              inline
                              color={
                                limb.limb_status === 'Splinted'
                                  ? 'lime'
                                  : limb.limb_status === 'Stabilized'
                                    ? 'lime'
                                    : 'white'
                              }
                              bold={1}
                            >
                              [{limb.limb_status}]
                            </Box>
                          </Tooltip>
                        ) : null}
                        {limb.limb_type ? (
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
                                    ? 'lime'
                                    : 'pink'
                                  : 'tan'
                              }
                              bold={1}
                            >
                              [{limb.limb_type}]
                            </Box>
                          </Tooltip>
                        ) : null}
                        {limb.bleeding ? (
                          <Tooltip content="This limb is bleeding and the patient is losing blood. Can be stopped with gauze or an advanced trauma kit.">
                            <Box inline color={'red'} bold={1}>
                              [Bleeding]
                            </Box>
                          </Tooltip>
                        ) : null}
                        {limb.open_incision ? (
                          <Tooltip content="Open surgical incisions can usually be closed by a cautery depending on the stage of the surgery. Risk of infection if left untreated.">
                            <Box inline color={'red'} bold={1}>
                              [Open Incision]
                            </Box>
                          </Tooltip>
                        ) : null}
                        {limb.infected ? (
                          <Tooltip content="Infected limbs can be treated with spaceacillin. Risk of necrosis if left untreated.">
                            <Box inline color={'olive'} bold={1}>
                              [Infected]
                            </Box>
                          </Tooltip>
                        ) : null}
                        {limb.necrotized ? (
                          <Tooltip content="Necrotized arms or legs cause random dropping of items or falling over, respectively. Organ damage will occur if on the head, chest or groin. Treated by surgery.">
                            <Box inline color={'brown'} bold={1}>
                              [Necrotizing]
                            </Box>
                          </Tooltip>
                        ) : null}
                        {limb.implant ? (
                          <Tooltip content="Harmful implants are usually shrapnel from firefights. Moving with a harmful implant will inflict Brute damage occasionally. Removed with tweezers.">
                            <Box inline color={'white'} bold={1}>
                              [Implant]
                            </Box>
                          </Tooltip>
                        ) : null}
                      </Stack.Item>
                    </>
                  )}
                </Stack>
              ))}
            </Stack>
          </Section>
        ) : null}
        {damaged_organs.length ? (
          <Section title="Organs Damaged">
            <LabeledList>
              {damaged_organs.map((organ) => (
                <LabeledList.Item
                  key={organ.name}
                  label={organ.name[0].toUpperCase() + organ.name.slice(1)}
                >
                  <Tooltip content={organ.effects}>
                    <Box
                      inline
                      color={organ.status === 'Bruised' ? 'orange' : 'red'}
                      bold
                    >
                      {organ.status + ' with ' + organ.damage + ' damage'}
                    </Box>
                  </Tooltip>
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        ) : null}
        {blood_amount < 560 || internal_bleeding ? (
          <Section>
            <LabeledList>
              <LabeledList.Item label={'Blood Type: ' + blood_type}>
                <Tooltip content="Bloodloss causes symptoms that start as suffocation and pain, but get significantly worse as more blood is lost. Blood can be restored by eating and taking Isotonic solution.">
                  <ProgressBar
                    value={blood_amount / 560}
                    ranges={{
                      good: [0.9, Infinity],
                      average: [0.7, 0.8],
                      bad: [-Infinity, 0.7],
                    }}
                  />
                </Tooltip>
              </LabeledList.Item>
              <LabeledList.Item label={'Body Temperature'}>
                {body_temperature}
              </LabeledList.Item>
              <LabeledList.Item label={'Pulse'}>{pulse}</LabeledList.Item>
            </LabeledList>
            {internal_bleeding ? (
              <NoticeBox color={'red'} mt={'8px'} mb={'0px'} warning>
                Internal Bleeding Detected!
              </NoticeBox>
            ) : null}
          </Section>
        ) : null}
        {infection ? <NoticeBox warning>{infection}</NoticeBox> : null}
        {implants ? (
          <NoticeBox info>
            There are {implants} unknown implants detected within the patient.
          </NoticeBox>
        ) : null}
        {advice ? (
          <Section title="Treatment Advice">
            <Stack vertical>
              {advice.map((advice) => (
                <Stack.Item key={advice.advice}>
                  <Tooltip
                    content={
                      advice.tooltip
                        ? advice.tooltip
                        : 'No tooltip entry for this advice.'
                    }
                  >
                    <Box inline>
                      <Icon name={advice.icon} ml={0.2} color={advice.color} />
                      <Box inline width={'5px'} />
                      {advice.advice}
                    </Box>
                  </Tooltip>
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        ) : null}
      </Window.Content>
    </Window>
  );
};
