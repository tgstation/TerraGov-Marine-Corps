import { Flex, Button } from '../../components';
import { useBackend } from '../../backend';

export const ResearchAccessBar = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Flex align="center" justify="space-between">
      <Flex.Item>Research Access Restriction</Flex.Item>
      <Flex.Item>
        <Button
          icon={data.locked ? 'lock' : 'unlock'}
          content={data.locked ? 'locked' : 'unlocked'}
          onClick={() => act('lock')}
        />
      </Flex.Item>
    </Flex>
  );
};
