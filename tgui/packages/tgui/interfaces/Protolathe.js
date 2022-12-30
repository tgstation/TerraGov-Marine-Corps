import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { ResearchAccessBar } from './Research/access';
import { logger } from '../logging';

export const Protolathe = (props, context) => {
  const { data } = useBackend(context);
  return (
    <Window width={465} height={550}>
      <ResearchAccessBar />
      <DesignSelector />
    </Window>
  );
};

/* const onDesignSelected = (design, materials) => {
  setSelectedDesign(design.name);
};*/

export const DesignSelector = (props, context) => {
  const { act, data } = useBackend(context);
  const { designs = [], busy } = data;
  // const [buildable, setBuildable] = useLocalState(context, 'buildable', false);
  const [selectedDesign, setSelectedDesign] = useLocalState(context, 'Design');
  logger.log(designs);
  return (
    <Section
      title="Designs"
      buttons={
        <Button
          disabled={busy}
          icon="lock"
          content="Build"
          onClick={act('build', { ref: selectedDesign })}
        />
      }>
      {/*
      <Stack fill vertical>
        {designs.map((design) => {
          return (
            <Stack.Item key={design.name} grow>
              <Tabs.Tab
                selected={design.name === selectedDesign}
                onClick={() => setSelectedDesign(design.name)}>
                {design.name}
              </Tabs.Tab>
            </Stack.Item>
          );
        })}
      </Stack>*/}
    </Section>
  );
};
