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

    revivable,
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
  const theme = species === 'robot' ? 'hackerman' : 'default';
  return (
    <Window width={500} height={600} theme={theme}>
      <Window.Content>
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
                <Box color={revivable ? 'green' : 'red'} bold={1}>
                  {revivable ? 'TRUE' : 'False'}
                </Box>
              </LabeledList.Item>
            ) : null}
            <LabeledList.Item label="Damage">
              <Box inline>
                <ProgressBar
                  value={total_brute}
                  maxvalue={total_brute}
                  color='bad'
                >
                  Brute:{total_brute}
                </ProgressBar>
              </Box>
              <Box inline width={'5px'} />
              <Box inline>
                <ProgressBar
                  value={total_burn}
                  maxvalue={total_burn}
                  color='average'
                >
                  Burn:{total_burn}
                </ProgressBar>
              </Box>
              <Box inline width={'5px'} />
              <Box inline>
                <ProgressBar
                  value={toxin}
                  maxvalue={toxin}
                  color='green'
                >
                  Toxin:{toxin}
                </ProgressBar>
              </Box>
              <Box inline width={'5px'} />
              <Box inline>
                <ProgressBar
                  value={oxy}
                  maxvalue={oxy}
                  color='blue'
                >
                  Oxygen:{oxy}
                </ProgressBar>
              </Box>
              <Box inline width={'5px'} />
              <Box inline>
                <ProgressBar
                  value={clone}
                  maxvalue={clone}
                  color='teal'
                >
                  {species === 'robot' ? 'Integrity' : 'Cloneloss'}:{clone}
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
            <LabeledList>
              {limb_data.map((limb) => (
                <LabeledList.Item key={limb.name} label={limb.name}>
                  {limb.missing ? (
                    <Box inline color={'red'} bold={1}>
                      MISSING
                    </Box>
                  ) : (
                    <>
                      {limb.brute > 0 ? (
                        <>
                          <Box inline>
                            <ProgressBar
                              value={limb.brute}
                              maxvalue={limb.brute}
                              color='bad'
                            >
                              Brute:{limb.brute}
                            </ProgressBar>
                          </Box>
                          <Box inline width={'5px'} />
                        </>
                      ) : null}
                      {limb.burn > 0 ? (
                        <>
                          <Box inline>
                            <ProgressBar
                              value={limb.burn}
                              maxvalue={limb.burn}
                              color='average'
                            >
                              Burn:{limb.burn}
                            </ProgressBar>
                          </Box>
                          <Box inline width={'5px'} />
                        </>
                      ) : null}
                      {!limb.bandaged ? (
                        <>
                          <Box inline color={'green'}>
                          {species === 'robot' ? 'Dented' : 'Unbandanged'}
                          </Box>
                          <Box inline width={'5px'} />
                        </>
                      ) : null}
                      {!limb.salved ? (
                        <>
                          <Box inline color={'orange'}>
                          {species === 'robot' ? 'Scorched' : 'Unsalved'}
                          </Box>
                          <Box inline width={'5px'} />
                        </>
                      ) : null}
                      {limb.bleeding && species !== 'robot' ? (
                        <>
                          <Box inline color={'red'} bold={1}>
                            Bleeding
                          </Box>
                          <Box inline width={'5px'} />
                        </>
                      ) : null}
                      {limb.limb_status ? (
                        <>
                          <Box
                            inline
                            color={
                              limb.limb_status === 'Splinted' ? 'green' : 'red'
                            }
                            bold={1}
                          >
                            {limb.limb_status}
                          </Box>
                          <Box inline width={'5px'} />
                        </>
                      ) : null}
                      {limb.open_incision ? (
                        <>
                          <Box inline color={'red'} bold={1}>
                            Open Surgical Incision
                          </Box>
                          <Box inline width={'5px'} />
                        </>
                      ) : null}
                      {limb.infected ? (
                        <>
                          <Box inline color={'olive'} bold={1}>
                            Infected
                          </Box>
                          <Box inline width={'5px'} />
                        </>
                      ) : null}
                      {limb.necrotized ? (
                        <>
                          <Box inline color={'brown'} bold={1}>
                            Necrotizing
                          </Box>
                          <Box inline width={'5px'} />
                        </>
                      ) : null}
                      {limb.implant ? (
                        <>
                          <Box inline color={'white'} bold={1}>
                            Implant
                          </Box>
                          <Box inline width={'5px'} />
                        </>
                      ) : null}
                    </>
                  )}
                </LabeledList.Item>
              ))}
            </LabeledList>
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
              <NoticeBox color={'red'} warning>
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
          <Section title="Medication Advice">
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
