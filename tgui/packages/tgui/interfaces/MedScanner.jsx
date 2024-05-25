import { useBackend } from '../backend';
import {
  Box,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
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
        <Section title={'Patient: ' + patient}>
          {hugged ? (
            <NoticeBox danger>
              Patient has been implanted with an alien embryo!
            </NoticeBox>
          ) : null}
          {ssd ? <NoticeBox warning>{ssd}</NoticeBox> : null}
          <LabeledList>
            <LabeledList.Item label="Health">
              <ProgressBar
                value={health / max_health}
                ranges={{
                  good: [0.4, Infinity],
                  average: [0.2, 0.4],
                  bad: [-Infinity, 0.2],
                }}
              />
            </LabeledList.Item>
            {dead ? (
              <LabeledList.Item label="Revivable">
                <Box color={revivable_boolean ? 'yellow' : 'red'} bold={1}>
                  {revivable_string}
                </Box>
              </LabeledList.Item>
            ) : null}
            <LabeledList.Item label="Damage">
              <Box inline>
                <ProgressBar>
                  Brute:{' '}
                  <Box inline bold color={'red'}>
                    {total_brute}
                  </Box>
                </ProgressBar>
              </Box>
              <Box inline width={'5px'} />
              <Box inline>
                <ProgressBar>
                  Burn:{' '}
                  <Box inline bold color={'#ffb833'}>
                    {total_burn}
                  </Box>
                </ProgressBar>
              </Box>
              {species !== 'robot' ? (
                <>
                  <Box inline width={'5px'} />
                  <Box inline>
                    <ProgressBar>
                      Toxin:{' '}
                      <Box inline bold color={'green'}>
                        {toxin}
                      </Box>
                    </ProgressBar>
                  </Box>
                  <Box inline width={'5px'} />
                  <Box inline>
                    <ProgressBar>
                      Oxygen:{' '}
                      <Box inline bold color={'blue'}>
                        {oxy}
                      </Box>
                    </ProgressBar>
                  </Box>
                </>
              ) : null}
              <Box inline width={'5px'} />
              <Box inline>
                <ProgressBar>
                  {species === 'robot' ? 'Integrity' : 'Cloneloss'}:{' '}
                  <Box inline bold color={'teal'}>
                    {clone}
                  </Box>
                </ProgressBar>
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {has_chemicals ? (
          <Section title="Chemical Contents">
            {has_unknown_chemicals ? (
              <NoticeBox warning>Unknown reagents detected.</NoticeBox>
            ) : null}
            <LabeledList>
              {chemicals.map((chemical) => (
                <LabeledList.Item key={chemical.name}>
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
                    <Stack.Item color={'red'} bold={1}>
                      MISSING
                    </Stack.Item>
                  ) : (
                    <>
                      <Stack.Item>
                        <Box
                          inline
                          width="50px"
                          color={limb.brute > 0 ? 'red' : 'white'}
                        >
                          {limb.bandaged ? `${limb.brute}` : `{${limb.brute}}`}
                        </Box>
                        <Box inline width="5px" />
                        <Box
                          inline
                          width="40px"
                          color={limb.burn > 0 ? '#ffb833' : 'white'}
                        >
                          {limb.salved ? `${limb.burn}` : `{${limb.burn}}`}
                        </Box>
                        <Box inline width="5px" />
                      </Stack.Item>
                      <Stack.Item>
                        {limb.limb_status ? (
                          <Box
                            inline
                            color={
                              limb.limb_status === 'Splinted' ? 'lime' : 'white'
                            }
                            bold={1}
                          >
                            [{limb.limb_status}]
                          </Box>
                        ) : null}
                        {limb.limb_type ? (
                          <Box
                            inline
                            color={
                              limb.limb_type === 'Robotic' ? 'pink' : 'tan'
                            }
                            bold={1}
                          >
                            [{limb.limb_type}]
                          </Box>
                        ) : null}
                        {limb.bleeding ? (
                          <Box inline color={'red'} bold={1}>
                            [Bleeding]
                          </Box>
                        ) : null}
                        {limb.open_incision ? (
                          <Box inline color={'red'} bold={1}>
                            [Open Incision]
                          </Box>
                        ) : null}
                        {limb.infected ? (
                          <Box inline color={'olive'} bold={1}>
                            [Infected]
                          </Box>
                        ) : null}
                        {limb.necrotized ? (
                          <Box inline color={'brown'} bold={1}>
                            [Necrotizing]
                          </Box>
                        ) : null}
                        {limb.implant ? (
                          <Box inline color={'white'} bold={1}>
                            [Implant]
                          </Box>
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
          <Section title="Organ Damaged">
            <LabeledList>
              {damaged_organs.map((organ) => (
                <LabeledList.Item
                  key={organ.name}
                  label={organ.name[0].toUpperCase() + organ.name.slice(1)}
                >
                  <Box
                    inline
                    color={organ.status === 'Bruised' ? 'orange' : 'red'}
                    bold={1}
                  >
                    {organ.status + ' with ' + organ.damage + ' damage'}
                  </Box>
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        ) : null}
        {blood_amount < 560 || internal_bleeding ? (
          <Section>
            <LabeledList>
              <LabeledList.Item label={'Blood Type: ' + blood_type}>
                <ProgressBar
                  value={blood_amount / 560}
                  ranges={{
                    good: [0.9, Infinity],
                    average: [0.7, 0.8],
                    bad: [-Infinity, 0.7],
                  }}
                />
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
                  <Box inline>
                    <Icon name={advice.icon} ml={0.2} color={advice.color} />
                    <Box inline width={'5px'} />
                    {advice.advice}
                  </Box>
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        ) : null}
      </Window.Content>
    </Window>
  );
};
