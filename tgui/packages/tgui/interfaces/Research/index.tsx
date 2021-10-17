import { useBackend } from '../../backend';
import { Button, Flex, LabeledList, Section } from '../../components';
import { Window } from '../../layouts';
import { ResearchData } from './Types';
import { hexToRGB } from './Utility';

export const Research = (props, context) => {
  const { act, data } = useBackend<ResearchData>(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    init_resource,
  } = data;

  return (
    <Window
      resizable
      width={600}
      height={600}>
      <Window.Content
        scrollable
        align="stretch"
        backgroundColor={init_resource ? hexToRGB(init_resource.colour, 0.5) : ""}>
        <Section title="Base resource">
          {
            init_resource
              ? <LabeledList>
                <LabeledList.Item label="Name">
                  {init_resource.name}
                </LabeledList.Item>
                <LabeledList.Item>
                  <Button
                    content="Start research"
                    onClick={() => act('start_research')} />
                </LabeledList.Item>
              </LabeledList>
              : "No resource inserted"
          }
        </Section>
      </Window.Content>
    </Window>
  );
};
