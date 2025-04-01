import { useState } from 'react';

import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from '../../components';
import { Window } from '../../layouts';
import { NameInputModal } from './NameInputModal';
import {
  LoadoutItemData,
  LoadoutListData,
  LoadoutManagerData,
  LoadoutTabData,
} from './Types';

const jobListByFaction = {
  Neutral: [
    'Squad Marine',
    'Squad Engineer',
    'Squad Corpsman',
    'Squad Smartgunner',
    'Squad Leader',
    'Field Commander',
    'Synthetic',
  ],
  Crash: [
    'Squad Marine',
    'Squad Engineer',
    'Squad Corpsman',
    'Squad Smartgunner',
    'Squad Leader',
    'Field Commander',
    'Synthetic',
  ],
  Valhalla: [
    'Squad Marine',
    'Squad Engineer',
    'Squad Corpsman',
    'Squad Smartgunner',
    'Squad Leader',
    'Field Commander',
    'Synthetic',
  ],
  SOM: [
    'SOM Squad Standard',
    'SOM Squad Engineer',
    'SOM Squad Medic',
    'SOM Squad Veteran',
    'SOM Squad Leader',
  ],
  PMC: [
    'PMC Standard',
    'PMC Engineer',
    'PMC Medic',
    'PMC Gunner',
    'PMC Specialist',
    'PMC Squad Leader',
  ],
  ICC: [
    'ICC Standard',
    'ICC Medic',
    'ICC Guardsman',
    'ICC Squad Leader',
  ],
  CLF: [
    'CLF Standard',
    'CLF Medic',
    'CLF Breeder',
    'CLF Leader',
  ],
  VSD: [
    'VSD Standard',
    'VSD Engineer',
    'VSD Medic',
    'VSD Specialist',
    'VSD Squad Leader',
  ],
  default: ['null'],
};

const LoadoutItem = (props: LoadoutItemData) => {
  const { act } = useBackend();
  const { loadout } = props;

  return (
    <Box>
      <LabeledList.Item
        labelColor="white"
        buttons={
          <>
            <Button
              icon="arrow-up"
              onClick={() =>
                act('edit_loadout_position', {
                  direction: 'up',
                  loadout_name: loadout.name,
                  loadout_job: loadout.job,
                })
              }
            />
            <Button
              icon="arrow-down"
              onClick={() =>
                act('edit_loadout_position', {
                  direction: 'down',
                  loadout_name: loadout.name,
                  loadout_job: loadout.job,
                })
              }
            />
            <Button
              onClick={() => {
                act('selectLoadout', {
                  loadout_name: loadout.name,
                  loadout_job: loadout.job,
                });
              }}
            >
              Select Loadout
            </Button>
          </>
        }
        label={loadout.name}
      />
    </Box>
  );
};

const LoadoutList = (props: LoadoutListData) => {
  const { loadout_list } = props;
  return (
    <Stack.Item>
      <Section height={23} fill scrollable>
        <LabeledList>
          {loadout_list.map((loadout_visible) => {
            return (
              <LoadoutItem
                key={loadout_visible.name}
                loadout={loadout_visible}
              />
            );
          })}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

export const JobTabs = (props: LoadoutTabData, context) => {
  const { job, setJob } = props;
  const { data } = useBackend(context);
  const { faction } = data;

  const jobList = jobListByFaction[faction] || jobListByFaction['default'];

  return (
    <Section>
      <Flex>
        <Flex.Item grow={1}>
          <div> </div>
        </Flex.Item>
        <Flex.Item>
          <Tabs>
            {jobList.map((jobOption) => (
              <Tabs.Tab
                key={jobOption}
                selected={job === jobOption}
                onClick={() => setJob(jobOption)}
              >
                {jobOption} {}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1}>
          <div> </div>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const LoadoutManager = (props) => {
  const { act, data } = useBackend<LoadoutManagerData>();
  const { loadout_list, faction } = data;

  const [job, setJob] = useState(jobListByFaction[faction][0]);
  const [saveNewLoadout, setSaveNewLoadout] = useState(false);
  const [importNewLoadout, setImportNewLoadout] = useState(false);
  const themeMap = {
    SOM: "som",
    VSD: "syndicate",
    CLF: "xeno",
  };
  const ui_theme = themeMap[faction] || "ntos";

  return (
    <Window title="Loadout Manager" width={800} height={400} theme={ui_theme}>
      <Window.Content>
        <Stack vertical>
          <JobTabs job={job} setJob={setJob} />
          <LoadoutList
            loadout_list={loadout_list.filter((loadout) => loadout.job === job)}
          />
          <Flex>
            <Flex.Item grow={1}>
              <div> </div>
            </Flex.Item>
            <Flex.Item>
              <Button onClick={() => setSaveNewLoadout(true)}>
                Save your equipped loadout
              </Button>
            </Flex.Item>
            <Flex.Item grow={1}>
              <div> </div>
            </Flex.Item>
            <Flex.Item>
              <Button onClick={() => setImportNewLoadout(true)}>
                Import Loadout
              </Button>
            </Flex.Item>
            <Flex.Item grow={1}>
              <div> </div>
            </Flex.Item>
          </Flex>
        </Stack>
        {saveNewLoadout && (
          <NameInputModal
            label="Name of the new Loadout"
            button_text="Save"
            onBack={() => setSaveNewLoadout(false)}
            onSubmit={(name) => {
              act('saveLoadout', {
                loadout_name: name,
                loadout_job: job,
              });
              setSaveNewLoadout(false);
            }}
          />
        )}
        {importNewLoadout && (
          <NameInputModal
            label="Format requested : ckey//job//name_of_loadout "
            button_text="Import the loadout"
            onBack={() => setImportNewLoadout(false)}
            onSubmit={(id) => {
              act('importLoadout', {
                loadout_id: id,
              });
              setImportNewLoadout(false);
            }}
          />
        )}
      </Window.Content>
    </Window>
  );
};
