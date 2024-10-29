import { useBackend } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { Window } from '../layouts';

type Upgrade = {
  name: string;
  desc: string;
};

type MutationData = {
  shell_chambers: number;
  spur_chambers: number;
  veil_chambers: number;
  biomass: number;
  cost: number;
  survival_mutations: Upgrade[];
  attack_mutations: Upgrade[];
  utility_mutations: Upgrade[];
};

export const MutationSelector = (props) => {
  const { act, data } = useBackend<MutationData>();
  const {
    shell_chambers,
    spur_chambers,
    veil_chambers,
    biomass,
    cost,
    survival_mutations,
    attack_mutations,
    utility_mutations,
  } = data;

  return (
    <Window width={900} height={625}>
      <Window.Content>
        <Section title={`Biomass: ${biomass}/100`} align={'center'}>
          <Flex direction="column-reverse" align={'center'}>
            Shell Chambers: {shell_chambers}
          </Flex>
          <Flex direction="column-reverse" align={'center'}>
            Spur Chambers: {spur_chambers}
          </Flex>

          <Flex direction="column-reverse" align={'center'}>
            Veil Chambers: {veil_chambers}
          </Flex>
        </Section>
        <Section title="Survival" key="Survival">
          {survival_mutations.map((mutation) => (
            <Box key={mutation.name}>
              <Button
                content={`${mutation.name} (${cost})`}
                key={mutation.name}
                onClick={() => act('purchase', { upgrade_name: mutation.name })}
              />
              <Flex direction="column-reverse" align={'left'}>
                {mutation.desc}
              </Flex>
            </Box>
          ))}
        </Section>
        <Section title="Attack" key="Attack">
          {attack_mutations.map((mutation) => (
            <Box key={mutation.name}>
              <Button
                content={`${mutation.name} (${cost})`}
                key={mutation.name}
                onClick={() => act('purchase', { upgrade_name: mutation.name })}
              />
              <Flex direction="column-reverse" align={'left'}>
                {mutation.desc}
              </Flex>
            </Box>
          ))}
        </Section>
        <Section title="Utility" key="Utility">
          {utility_mutations.map((mutation) => (
            <Box key={mutation.name}>
              <Button
                content={`${mutation.name} (${cost})`}
                key={mutation.name}
                onClick={() => act('purchase', { upgrade_name: mutation.name })}
              />
              <Flex direction="column-reverse" align={'left'}>
                {mutation.desc}
              </Flex>
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
