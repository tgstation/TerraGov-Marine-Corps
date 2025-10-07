import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  Modal,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';

export const JobPreferences = (props) => {
  const { act, data } = useBackend<JobPreferencesData>();
  const {
    alternate_option,
    squads,
    squads_som,
    preferred_squad,
    preferred_squad_som,
    overflow_job,
    special_occupations,
    special_occupation,
  } = data;
  const [shownDescription, setShownDescription] = useState(null);

  const xenoJobs = ['Xeno Queen', 'Xenomorph', 'Corrupted Xenomorph'];
  const commandRoles = [
    'Commander',
    'Field Commander',
    'Staff Officer',
    'Pilot Officer',
    'Transport Officer',
    'Synthetic',
    'AI',
    'Mech Pilot',
    'Vanguard Unit',
  ];
  const supportRoles = [
    'Chief Ship Engineer',
    'Ship Technician',
    'Requisitions Officer',
    'Chief Medical Officer',
    'Medical Doctor',
    'Medical Researcher',
    'Assault Crewman',
    'Transport Crewman',
    'CorpSec Officer',
  ];
  const marineJobs = [
    'Squad Slut',
    'Squad Operative',
    'Squad Engineer',
    'Squad Corpsman',
    'Squad Smartgunner',
    'Specialist Operative',
    'Squad Leader',
  ];
  const somJobs = [
    'SOM Squad Standard',
    'SOM Squad Engineer',
    'SOM Squad Medic',
    'SOM Squad Veteran',
    'SOM Squad Leader',
    'SOM Synthetic',
    'SOM Technician',
    'SOM Medical Doctor',
    'SOM Mech Pilot',
    'SOM Staff Officer',
    'SOM Pilot Officer',
    'SOM Assault Crewman',
    'SOM Chief Medical Officer',
    'SOM Chief Engineer',
    'SOM Requisitions Officer',
    'SOM Field Commander',
    'SOM Commander',
  ];
  const flavourJobs = [
    'Operations Officer',
    'Worker',
    'Morale Officer',
    'Prisoner',
    'SOM Prisoner',
    'CLF Prisoner',
  ];
  const clfJobs = [
    'CLF Breeder',
    'CLF Standard',
    'CLF Medic',
    'CLF Specialist',
    'CLF Synthetic',
    'CLF Leader',
    'CLF Base Technician',
  ];
  const cmJobs = [
    'CM Standard',
    'CM Medic',
    'CM Guardsman',
    'CM Squad Leader',
    'CM Base Technician',
  ];
  const kzJobs = [
    'KZ Standard',
    'KZ Medic',
    'KZ Engineer',
    'KZ Specialist',
    'KZ Squad Leader',
  ];
  const survivorJobs = [
    'Assistant Survivor',
    'Scientist Survivor',
    'Doctor Survivor',
    'Liaison Survivor',
    'Security Guard Survivor',
    'Civilian Survivor',
    'Chef Survivor',
    'Botanist Survivor',
    'Technician Survivor',
    'Chaplain Survivor',
    'Miner Survivor',
    'Salesman Survivor',
    'Colonial Marshal Survivor',
    'Bartender Survivor',
    'Pharmacy Technician Survivor',
    'Roboticist Survivor',
    'Non-Deployed Operative Survivor',
    'Prisoner Survivor',
    'Stripper Survivor',
    'Maid Survivor',
  ];

  const JobList = ({ name, jobs }) => (
    <Section title={name}>
      <LabeledList>
        {jobs.map((job) => (
          <JobPreference
            key={job}
            job={job}
            setShownDescription={setShownDescription}
          />
        ))}
      </LabeledList>
    </Section>
  );

  return (
    <Section
      title="Job Preferences"
      buttons={
        <Button color="bad" icon="power-off" onClick={() => act('jobreset')}>
          Reset everything!
        </Button>
      }
    >
      {shownDescription && (
        <Modal width="500px" min-height="300px">
          <Box dangerouslySetInnerHTML={{ __html: shownDescription }} />
          <Box align="right">
            <Button align="right" onClick={() => setShownDescription(null)}>
              X
            </Button>
          </Box>
        </Modal>
      )}
      <Stack>
        <Stack.Item grow>
          <JobList name="Command Jobs" jobs={commandRoles} />
        </Stack.Item>
        <Stack.Item grow>
          <JobList name="Support Jobs" jobs={supportRoles} />
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <JobList name="Xenomorph Jobs" jobs={xenoJobs} />
        </Stack.Item>
        <Stack.Item grow>
          <JobList name="Flavour Jobs" jobs={flavourJobs} />
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <JobList name="Marine Jobs" jobs={marineJobs} />
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Other settings">
            <Flex direction="column" height="100%">
              <Flex.Item>
                <h4>If failed to qualify for job</h4>
                <Button.Checkbox
                  inline
                  content={'Take a random job'}
                  checked={alternate_option === 0}
                  onClick={() => act('jobalternative', { newValue: 0 })}
                />
                <Button.Checkbox
                  inline
                  content={`Spawn as ${overflow_job}`}
                  checked={alternate_option === 1}
                  onClick={() => act('jobalternative', { newValue: 1 })}
                />
                <Button.Checkbox
                  inline
                  content={'Return to lobby'}
                  checked={alternate_option === 2}
                  onClick={() => act('jobalternative', { newValue: 2 })}
                />
              </Flex.Item>
              <Flex.Item>
                <h4>Preferred Squad</h4>
                {Object.values(squads).map((squad) => (
                  <Button.Checkbox
                    key={squad}
                    inline
                    content={squad}
                    checked={preferred_squad === squad}
                    onClick={() => act('squad', { newValue: squad })}
                  />
                ))}
              </Flex.Item>
              <Flex.Item>
                <h4>Preferred Squad - SOM</h4>
                {Object.values(squads_som).map((squad_som) => (
                  <Button.Checkbox
                    key={squad_som}
                    inline
                    content={squad_som}
                    checked={preferred_squad_som === squad_som}
                    onClick={() => act('squad_som', { newValue: squad_som })}
                  />
                ))}
              </Flex.Item>
              <Flex.Item>
                <h4>Occupational choices</h4>
                {Object.keys(special_occupations).map((special, idx) => (
                  <>
                    <Button.Checkbox
                      key={special_occupations[special]}
                      inline
                      content={special}
                      checked={
                        special_occupation & special_occupations[special]
                      }
                      onClick={() =>
                        act('be_special', {
                          flag: special_occupations[special],
                        })
                      }
                    />
                    {idx === 1 && <br />}
                  </>
                ))}
              </Flex.Item>
            </Flex>
          </Section>
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <JobList name="SOM Jobs" jobs={somJobs} />
        </Stack.Item>
        <Stack.Item grow>
          <JobList name="CLF Jobs" jobs={clfJobs} />
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <JobList name="CM Jobs" jobs={cmJobs} />
        </Stack.Item>
        <Stack.Item grow>
          <JobList name="KZ Jobs" jobs={kzJobs} />
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <JobList name="Survivor Jobs" jobs={survivorJobs} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const JobPreference = (props) => {
  const { act, data } = useBackend<JobPreferenceData>();
  const { jobs, job_preferences } = data;
  const { job, setShownDescription } = props;
  const jobData = jobs[job];
  const preference = job_preferences[job];

  if (jobData.banned) {
    return (
      <LabeledList.Item label={job}>
        <Box align="right">
          <Button.Checkbox
            inline
            icon="ban"
            color="bad"
            content={'Banned from Role'}
            onClick={() => act('bancheck', { role: job })}
          />
        </Box>
      </LabeledList.Item>
    );
  }

  return (
    <LabeledList.Item label={job}>
      <Box align="right">
        <Button.Checkbox
          inline
          content={'High'}
          checked={preference === 3}
          onClick={() => act('jobselect', { job, level: 3 })}
        />
        <Button.Checkbox
          inline
          content={'Medium'}
          checked={preference === 2}
          onClick={() => act('jobselect', { job, level: 2 })}
        />
        <Button.Checkbox
          inline
          content={'Low'}
          checked={preference === 1}
          onClick={() => act('jobselect', { job, level: 1 })}
        />
        <Button.Checkbox
          inline
          content={'Never'}
          checked={!preference}
          onClick={() => act('jobselect', { job, level: 0 })}
        />
        {jobData.description && (
          <Button
            content="?"
            onClick={() => setShownDescription(jobData.description)}
          />
        )}
      </Box>
    </LabeledList.Item>
  );
};
