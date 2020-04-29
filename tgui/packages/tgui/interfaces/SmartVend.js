import { useBackend } from '../backend';
import { Button, Section, Table, NoticeBox } from '../components';
import { map } from 'common/collections';
import { Window } from '../layouts';

export const SmartVend = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content scrollable>
        <Section
          title="Storage"
          buttons={!!data.isdryer && (
            <Button
              icon={data.drying ? "stop" : "tint"}
              onClick={() => act('Dry')}>
              {data.drying ? "Stop drying" : "Dry"}
            </Button>
          )} />
        <Section>
          {data.contents.length === 0 ? (
            <NoticeBox>Unfortunately, this {data.name} is empty.</NoticeBox>
          ) : (
            <Table>
              <Table.Row>
                <Table.Cell>Item</Table.Cell>
                <Table.Cell>Quantity</Table.Cell>
                <Table.Cell>{data.verb ? data.verb : "Dispense"}</Table.Cell>
              </Table.Row>
              {map((value, key) => {
                return (
                  <Table.Row key={key}>
                    <Table.Cell>{value.name}</Table.Cell>
                    <Table.Cell>{value.amount}</Table.Cell>
                    <Table.Cell>
                      <Button
                        disabled={value.amount < 1}
                        onClick={() => act(
                          'Release',
                          { name: value.name, amount: 1 })}>
                        One
                      </Button>
                      <Button
                        disabled={value.amount <= 1}
                        onClick={() => act(
                          'Release',
                          { name: value.name })}>
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
