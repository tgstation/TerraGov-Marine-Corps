import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  Modal,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  LoadoutItemData,
  LoadoutListData,
  LoadoutManagerData,
  LoadoutTabData,
} from './Types';

const LoadoutItem = (props: LoadoutItemData) => {
  const { act } = useBackend();
  const { loadout, setShowDesc } = props;

  return (
    <LabeledList.Item
      labelColor="white"
      buttons={
        <Button
          onClick={() => {
            act('selectLoadout', { loadout_outfit: loadout.outfit });
          }}
        >
          Select Loadout
        </Button>
      }
      label={loadout.name}
    >
      {!!loadout.desc && (
        <Button onClick={() => setShowDesc(loadout.desc)}>?</Button>
      )}
      <div> </div>
    </LabeledList.Item>
  );
};

const LoadoutList = (props: LoadoutListData) => {
  const { loadout_list, setShowDesc } = props;
  return (
    <Stack.Item>
      <Section height={23} fill scrollable>
        <LabeledList>
          {loadout_list.map((loadout_visible) => {
            return (
              <LoadoutItem
                key={loadout_visible.name}
                loadout={loadout_visible}
                setShowDesc={setShowDesc}
              />
            );
          })}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const JobTabs = (props: LoadoutTabData) => {
  const { job, setJob } = props;
  const { data } = useBackend<any>();
  const categories_to_use = data.vendor_categories;
  return (
    <Section>
      <Flex>
        <Flex.Item grow={1}>
          <div> </div>
        </Flex.Item>
        <Flex.Item>
          <Tabs>
            {categories_to_use.map((role, i) => (
              <Tabs.Tab
                key={i}
                selected={job === role}
                onClick={() => setJob(role)}
              >
                {role}
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

export const Quickload = (props) => {
  const { act, data } = useBackend<LoadoutManagerData>();
  const { loadout_list } = data;
  const ui_theme_to_use = data.ui_theme;
  const default_job_tab = data.vendor_categories[0];

  const [showDesc, setShowDesc] = useState(null);

  const [job, setJob] = useState(default_job_tab);

  return (
    <Window
      title="Quick Equip vendor"
      width={700}
      height={400}
      theme={ui_theme_to_use}
    >
      {showDesc && (
        <Modal width="400px">
          <Box>{showDesc}</Box>
          <Button content="Dismiss" onClick={() => setShowDesc(null)} />
        </Modal>
      )}
      <Window.Content>
        <Stack vertical>
          <JobTabs job={job} setJob={setJob} />
          <LoadoutList
            loadout_list={loadout_list.filter((loadout) => loadout.job === job)}
            setShowDesc={setShowDesc}
          />
        </Stack>
      </Window.Content>
    </Window>
  );
};
