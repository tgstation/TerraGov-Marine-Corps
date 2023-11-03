import { useBackend, useLocalState } from '../../backend';
import { Button, Section, TextArea, Box, Stack } from '../../components';

export const BackgroundInformation = (props, context) => {
  const { act, data } = useBackend<BackgroundInformationData>(context);
  const {
    slot,
    flavor_text,
    med_record,
    gen_record,
    sec_record,
    exploit_record,
  } = data;

  const [characterDesc, setCharacterDesc] = useLocalState(
    context,
    'characterDesc' + slot,
    flavor_text
  );
  const [medicalDesc, setMedicalDesc] = useLocalState(
    context,
    'medicalDesc' + slot,
    med_record
  );
  const [employmentDesc, setEmploymentDesc] = useLocalState(
    context,
    'employmentDesc' + slot,
    gen_record
  );
  const [securityDesc, setSecurityDesc] = useLocalState(
    context,
    'securityDesc' + slot,
    sec_record
  );
  const [exploitsDesc, setExploitsDesc] = useLocalState(
    context,
    'exploitsDesc' + slot,
    exploit_record
  );
  return (
    <Section title="Background information">
      <Section
        title="Character Description"
        buttons={
          <Box>
            <Button
              icon="save"
              disabled={characterDesc === flavor_text}
              onClick={() => act('flavor_text', { characterDesc })}>
              Save
            </Button>
            <Button icon="times" onClick={() => setCharacterDesc(flavor_text)}>
              Reset
            </Button>
          </Box>
        }>
        <TextArea
          key="character"
          height="100px"
          value={characterDesc}
          onChange={(e, value) => setCharacterDesc(value)}
        />
      </Section>

      <Stack>
        <Stack.Item grow>
          <Section
            title="Medical Records"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={medicalDesc === med_record}
                  onClick={() => act('med_record', { medicalDesc })}>
                  Save
                </Button>
                <Button icon="times" onClick={() => setMedicalDesc(med_record)}>
                  Reset
                </Button>
              </Box>
            }>
            <TextArea
              height="100px"
              maxLength={1024}
              value={medicalDesc}
              onChange={(e, value) => setMedicalDesc(value)}
            />
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section
            title="Employment Records"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={employmentDesc === gen_record}
                  onClick={() => act('gen_record', { employmentDesc })}>
                  Save
                </Button>
                <Button
                  icon="times"
                  onClick={() => setEmploymentDesc(gen_record)}>
                  Reset
                </Button>
              </Box>
            }>
            <TextArea
              height="100px"
              maxLength={1024}
              value={employmentDesc}
              onChange={(e, value) => setEmploymentDesc(value)}
            />
          </Section>
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <Section
            title="Security Records"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={securityDesc === sec_record}
                  onClick={() => act('sec_record', { securityDesc })}>
                  Save
                </Button>
                <Button
                  icon="times"
                  onClick={() => setSecurityDesc(sec_record)}>
                  Reset
                </Button>
              </Box>
            }>
            <TextArea
              height="100px"
              maxLength={1024}
              value={securityDesc}
              onChange={(e, value) => setSecurityDesc(value)}
            />
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section
            title="Exploit Records"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={exploitsDesc === exploit_record}
                  onClick={() => act('exploit_record', { exploitsDesc })}>
                  Save
                </Button>
                <Button
                  icon="times"
                  onClick={() => setExploitsDesc(exploit_record)}>
                  Reset
                </Button>
              </Box>
            }>
            <TextArea
              height="100px"
              maxLength={1024}
              value={exploitsDesc}
              onChange={(e, value) => setExploitsDesc(value)}
            />
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
