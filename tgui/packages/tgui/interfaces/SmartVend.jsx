import { map } from 'common/collections';
import { Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const SmartVend = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={440} height={550}>
      <Window.Content scrollable>
        <Section
          title="Storage"
          buttons={
            !!data.isdryer && (
              <Button
                icon={data.drying ? 'stop' : 'tint'}
                onClick={() => act('Dry')}
              >
                {data.drying ? 'Stop drying' : 'Dry'}
              </Button>
            )
          }
        />
        <Section>
          {data.contents.length === 0 ? (
            <NoticeBox>Unfortunately, this {data.name} is empty.</NoticeBox>
          ) : (
            <Table>
              <Table.Row>
                <Table.Cell>Item</Table.Cell>
                <Table.Cell>Quantity</Table.Cell>
                <Table.Cell>{data.verb ? data.verb : 'Dispense'}</Table.Cell>
              </Table.Row>
              {map((value, key) => {
                return (
                  <Table.Row key={key}>
                    <Table.Cell>{key}</Table.Cell>
                    <Table.Cell>{value}</Table.Cell>
                    <Table.Cell>
                      <Button
                        disabled={value < 1}
                        onClick={() => act('Release', { name: key, amount: 1 })}
                      >
                        One
                      </Button>
                      <Button
                        disabled={value <= 1}
                        onClick={() => act('Release', { name: key })}
                      >
                        Many
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                );
              })(data.contents)}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
