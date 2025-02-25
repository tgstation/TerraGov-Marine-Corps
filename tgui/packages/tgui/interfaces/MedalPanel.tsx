import { useState } from 'react';
import {
  Button,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Medal = {
  id: number;
  ckey: string;
  real_name: string;
  medal_citation: string;
  issued_by_real_name: string;
  issued_at: string;
  is_posthumous: BooleanLike;
};

type MedalPanelData = {
  medals?: Medal[];
};

export const MedalPanel = () => {
  const { act, data } = useBackend<MedalPanelData>();
  const { medals } = data;
  const ckeys = medals?.map((medal) => medal.ckey);
  const [selectedCkey, setSelectedCkey] = useState(
    ckeys?.length ? ckeys[0] : null,
  );
  const medalsForCkey = medals?.filter((medal) => medal.ckey === selectedCkey);
  const [selectedMedal, setSelectedMedal] = useState(
    medalsForCkey?.length ? medalsForCkey[0] : null,
  );
  return (
    <Window width={600} height={500} title="Medal Panel">
      <Window.Content scrollable>
        <Stack>
          <Stack.Item>
            <Section title="Ckeys">
              <Tabs>
                {ckeys?.map((ckey, index) => (
                  <Tabs.Tab
                    selected={ckey === selectedCkey}
                    key={index}
                    onClick={() => setSelectedCkey(ckey)}
                  >
                    {ckey}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Medals">
              <Tabs>
                {medalsForCkey?.map((medal, index) => (
                  <Tabs.Tab
                    selected={medal === selectedMedal}
                    key={index}
                    onClick={() => setSelectedMedal(medal)}
                  >
                    {medal.id}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Medal Details">
              {selectedMedal && (
                <>
                  <LabeledList>
                    <LabeledList.Item label="Recipient">
                      {selectedMedal.real_name}
                    </LabeledList.Item>
                    <LabeledList.Item label="Citation">
                      {selectedMedal.medal_citation}
                    </LabeledList.Item>
                    <LabeledList.Item label="Issued By">
                      {selectedMedal.issued_by_real_name}
                    </LabeledList.Item>
                    <LabeledList.Item label="Issued At">
                      {selectedMedal.issued_at}
                    </LabeledList.Item>
                    <LabeledList.Item label="Posthumous">
                      {selectedMedal.is_posthumous ? 'Yes' : 'No'}
                    </LabeledList.Item>
                  </LabeledList>
                  <Button
                    color="red"
                    onClick={() =>
                      act('delete', {
                        ckey: selectedMedal.ckey,
                        id: selectedMedal.id,
                        real_name: selectedMedal.real_name,
                      })
                    }
                  >
                    Delete Medal
                  </Button>
                </>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
