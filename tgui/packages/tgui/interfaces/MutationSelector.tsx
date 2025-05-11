import {
  Button,
  Collapsible,
  Flex,
  ProgressBar,
  Section,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Upgrade = {
  name: string;
  desc: string;
  owned: boolean;
};

type BiomassData = {
  biomass: number;
  cost_text: number;
};

type ShellMutationData = {
  shell_mutations: Upgrade[];
  already_has_shell_mutation: boolean;
  shell_chambers: number;
  cost: number;
  cost_text: string;
  biomass: number;
};

type SpurMutationData = {
  spur_mutations: Upgrade[];
  already_has_spur_mutation: boolean;
  spur_chambers: number;
  cost: number;
  cost_text: string;
  biomass: number;
};

type VeilMutationData = {
  veil_mutations: Upgrade[];
  already_has_veil_mutation: boolean;
  veil_chambers: number;
  cost: number;
  cost_text: string;
  biomass: number;
};

export const MutationSelector = (_props: any) => {
  return (
    <Window theme="xeno" width={500} height={600}>
      <Window.Content scrollable>
        <Section title="Biomass" key="Biomass">
          <BiomassBar />
        </Section>
        <ShellMutationSection />
        <SpurMutationSection />
        <VeilMutationSection />
      </Window.Content>
    </Window>
  );
};

const BiomassBar = (_props: any) => {
  const { data } = useBackend<BiomassData>();
  const { biomass, cost_text } = data;

  return (
    <Tooltip content={`Costs ${cost_text} biomass to buy an another mutation!`}>
      <Flex mb={1}>
        <Flex.Item grow>
          <ProgressBar color="green" value={biomass / 1800}>
            {`${biomass} / 1800 `}
          </ProgressBar>
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

const ShellMutationSection = (_props: any) => {
  const { act, data } = useBackend<ShellMutationData>();
  const {
    shell_mutations,
    already_has_shell_mutation,
    shell_chambers,
    cost,
    cost_text,
    biomass,
  } = data;

  return (
    <Collapsible
      title={`Shell Mutations | Shell Chambers: ${shell_chambers}/3`}
    >
      {shell_mutations &&
        shell_mutations.map((mutation) => (
          <Section
            title={`${mutation.name}`}
            mb={1}
            key={mutation.name}
            buttons={
              <Button
                content={`Buy (${cost_text})`}
                key={mutation.name}
                onClick={() => act('purchase', { upgrade_name: mutation.name })}
                disabled={
                  cost > biomass ||
                  shell_chambers === 0 ||
                  already_has_shell_mutation
                }
                selected={mutation.owned}
              />
            }
          >
            <Flex direction="column-reverse" align={'left'}>
              {mutation.desc}
            </Flex>
          </Section>
        ))}
    </Collapsible>
  );
};

const SpurMutationSection = (_props: any) => {
  const { act, data } = useBackend<SpurMutationData>();
  const {
    spur_mutations,
    already_has_spur_mutation,
    spur_chambers,
    cost,
    cost_text,
    biomass,
  } = data;

  return (
    <Collapsible title={`Spur Mutations | Spur Chambers: ${spur_chambers}/3`}>
      {spur_mutations &&
        spur_mutations.map((mutation) => (
          <Section
            title={`${mutation.name}`}
            mb={1}
            key={mutation.name}
            buttons={
              <Button
                content={`Buy (${cost_text})`}
                key={mutation.name}
                onClick={() => act('purchase', { upgrade_name: mutation.name })}
                disabled={
                  cost > biomass ||
                  spur_chambers === 0 ||
                  already_has_spur_mutation
                }
                selected={mutation.owned}
              />
            }
          >
            <Flex direction="column-reverse" align={'left'}>
              {mutation.desc}
            </Flex>
          </Section>
        ))}
    </Collapsible>
  );
};

const VeilMutationSection = (_props: any) => {
  const { act, data } = useBackend<VeilMutationData>();
  const {
    veil_mutations,
    already_has_veil_mutation,
    veil_chambers,
    cost,
    cost_text,
    biomass,
  } = data;

  return (
    <Collapsible title={`Veil Mutations | Veil Chambers: ${veil_chambers}/3`}>
      {veil_mutations &&
        veil_mutations.map((mutation) => (
          <Section
            title={`${mutation.name}`}
            mb={1}
            key={mutation.name}
            buttons={
              <Button
                content={`Buy (${cost_text})`}
                key={mutation.name}
                onClick={() => act('purchase', { upgrade_name: mutation.name })}
                disabled={
                  cost > biomass ||
                  veil_chambers === 0 ||
                  already_has_veil_mutation
                }
                selected={mutation.owned}
              />
            }
          >
            <Flex direction="column-reverse" align={'left'}>
              {mutation.desc}
            </Flex>
          </Section>
        ))}
    </Collapsible>
  );
};
