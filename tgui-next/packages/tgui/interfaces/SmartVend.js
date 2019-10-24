
import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, Table, NoticeBox } from '../components';

export const SmartVend = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Section
        title="Storage"
        buttons={data.isdryer && (
          <Button
            icon={data.drying ? "stop" : "tint"}
            onClick={() => act(ref, 'Dry')}>
            {data.drying ? "Stop drying" : "Dry"}
          </Button>
        )}>
      </Section>
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
            {data.contents.map(content => (
              <Table.Row key={content.id}>
                <Table.Cell>{content.name}</Table.Cell>
                <Table.Cell>{content.amount}</Table.Cell>
                <Table.Cell>
                  <Button
                    disabled={content.amount < 1}
                    onClick={() => act(ref, 'Release', {name: content.name, amount: 1})}>
                    One
                  </Button>
                  <Button
                    disabled={content.amount <= 1}
                    onClick={() => act(ref, 'Release', {name: content.name})}>
                    Many
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )}
      </Section>
    </Fragment>); };
