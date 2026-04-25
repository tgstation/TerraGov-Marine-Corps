import {
  Button,
  Collapsible,
  Flex,
  ProgressBar,
  Section,
  Tooltip,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Upgrade = {
  name: string;
  type: string;
  desc: string;
  owned: BooleanLike;
};

type MutationBarData = {
  already_has_shell: BooleanLike;
  already_has_spur: BooleanLike;
  already_has_veil: BooleanLike;
  disks_completed: number;
};

type MutationData = {
  shell_mutations: Upgrade[];
  spur_mutations: Upgrade[];
  veil_mutations: Upgrade[];
  already_has_shell: BooleanLike;
  already_has_spur: BooleanLike;
  already_has_veil: BooleanLike;
  shell_chambers: number;
  spur_chambers: number;
  veil_chambers: number;
};

export const MutationSelector = (_props: any) => {
  const { data } = useBackend<MutationData>();
  const {
    shell_mutations,
    spur_mutations,
    veil_mutations,
    already_has_shell,
    already_has_spur,
    already_has_veil,
    shell_chambers,
    spur_chambers,
    veil_chambers,
  } = data;

  return (
    <Window theme="xeno" width={500} height={600}>
      <Window.Content scrollable>
        <Section title="Mutation Evolution" key="Mutation Evolution">
          <MutationBar />
        </Section>
        <MutationSection
          category_name="Shell"
          mutations={shell_mutations}
          already_has={already_has_shell}
          chambers={shell_chambers}
        />
        <MutationSection
          category_name="Spur"
          mutations={spur_mutations}
          already_has={already_has_spur}
          chambers={spur_chambers}
        />
        <MutationSection
          category_name="Veil"
          mutations={veil_mutations}
          already_has={already_has_veil}
          chambers={veil_chambers}
        />
      </Window.Content>
    </Window>
  );
};

const MutationBar = (_props: any) => {
  const { data } = useBackend<MutationBarData>();
  const {
    already_has_shell,
    already_has_spur,
    already_has_veil,
    disks_completed,
  } = data;

  let mutationsCount = 0;
  if (already_has_shell) {
    mutationsCount += 1;
  }
  if (already_has_spur) {
    mutationsCount += 1;
  }
  if (already_has_veil) {
    mutationsCount += 1;
  }

  let tooltipContent = 'You are ready to buy another mutation.';
  if (mutationsCount === 3) {
    tooltipContent = 'You have the maximum amount of mutations!';
  } else if (mutationsCount >= disks_completed) {
    tooltipContent = "You can't buy another mutation yet...";
  }

  return (
    <Tooltip content={tooltipContent}>
      <Flex mb={1}>
        <Flex.Item grow>
          <ProgressBar color="green" value={disks_completed / 3}>
            {`${disks_completed} / 3 `}
          </ProgressBar>
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

const MutationSection = (props: {
  category_name: string;
  mutations: Upgrade[];
  already_has: BooleanLike;
  chambers: number;
}) => {
  const { act, data } = useBackend<MutationBarData>();
  const {
    already_has_shell,
    already_has_spur,
    already_has_veil,
    disks_completed,
  } = data;

  let mutationsCount = 0;
  if (already_has_shell) {
    mutationsCount += 1;
  }
  if (already_has_spur) {
    mutationsCount += 1;
  }
  if (already_has_veil) {
    mutationsCount += 1;
  }

  return (
    <Collapsible
      title={`${props.category_name} Mutations | ${props.category_name} Chambers: ${props.chambers}/3`}
    >
      {props.mutations &&
        props.mutations.map((mutation) => (
          <Section
            title={`${mutation.name}`}
            mb={1}
            key={mutation.name}
            buttons={
              <Button
                content={`Buy`}
                key={mutation.name}
                onClick={() => act('purchase', { upgrade_type: mutation.type })}
                disabled={
                  mutationsCount >= disks_completed ||
                  props.chambers === 0 ||
                  props.already_has
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
