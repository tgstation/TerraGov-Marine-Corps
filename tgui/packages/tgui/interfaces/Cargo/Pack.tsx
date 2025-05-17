import { Box, Collapsible, Table } from 'tgui-core/components';

import { useSupplyPacks } from './constants';

interface PackProps {
  pack: string;
  amount?: number;
}

export const Pack = (props: PackProps) => {
  const { pack, amount } = props;
  const supplies = useSupplyPacks();
  if (!supplies) return;
  const { name, notes, cost, contains } = supplies[pack];
  return !!contains && contains.constructor === Object ? (
    <Collapsible
      color="transparent"
      title={<PackName cost={cost} name={name} pl={0} amount={amount} />}
    >
      <b>{notes ? 'Notes: ' : null} </b> {notes}
      <Table>
        <Table.Row>
          <Table.Cell bold>Item Type</Table.Cell>
          <Table.Cell bold>Quantity</Table.Cell>
        </Table.Row>
        {Object.entries(contains).map(([key, value], index) => (
          <Table.Row key={index}>
            <Table.Cell width="70%">{key}</Table.Cell>
            <Table.Cell>x {contains[key].amount}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Collapsible>
  ) : (
    <PackName cost={cost} name={name} pl="22px" />
  );
};
interface PackNameProps {
  cost: number;
  name: string;
  pl?: string | number;
  amount?: number;
}

const PackName = (props: PackNameProps) => {
  const { cost, name, pl, amount } = props;
  return (
    <Box inline pl={pl}>
      <Box textAlign="right" inline width="140px">
        {amount ? amount + 'x' : ''}
        {cost} points {amount ? '(' + amount * cost + ')' : ''}
      </Box>
      <Box width="15px" inline />
      <Box inline>{name}</Box>
    </Box>
  );
};
