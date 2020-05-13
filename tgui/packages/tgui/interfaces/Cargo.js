import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Divider, Collapsible, AnimatedNumber } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { map } from 'common/collections';
import { FlexItem } from '../components/Flex';
import { Table, TableRow, TableCell } from '../components/Table';
import { logger } from '../logging';

export const Cargo = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  const [
    selectedCategory,
    setSelectedCategory,
  ] = useLocalState(context, 'selectedCategory', 0);

  const {
    categories,
    supplypacks,
    currentpoints,
    awaiting_delivery,
    shopping_list,
    requests,
  } = data;

  const selectedPackCat = selectedCategory ? supplypacks[selectedMenu] : null;

  return (
    <Window resizable>
      <Flex height="650px">
        <Flex.Item width="250px">
          <Menu />
        </Flex.Item>
        <Flex.Item position="relative" grow={1}>
          <Window.Content scrollable>
            {selectedMenu==="pendingorder" && (
              <Category selectedPackCat={shopping_list} />
            )}
            {selectedMenu==="requests" && (
              requests.map(request => (
                <Fragment key={request.id}>
                  <Flex>
                    <Flex.Item>
                      Requested by: {request.orderer_rank} {request.orderer}
                    </Flex.Item>
                    <Flex.Item textAlign="right" grow={1}>
                      Reason: {request.reason}
                    </Flex.Item>
                  </Flex>
                  <Flex>
                    <Flex.Item grow={1}>
                      <Collapsible
                        title={request.name}
                        color="gray">
                        <Table>
                          <PackContents contains={request.contains} />
                        </Table>
                        <Divider />
                      </Collapsible>
                    </Flex.Item>
                    <Flex.Item basis="80px" shrink={0} textAlign="right">
                      {request.cost} points
                    </Flex.Item>
                  </Flex>
                </Fragment>
              ))
            )}
            {!!selectedPackCat
              && (<Category selectedPackCat={selectedPackCat} />)}
          </Window.Content>
        </Flex.Item>
      </Flex>
    </Window>
  );
};

const Menu = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  const [
    selectedCategory,
    setSelectedCategory,
  ] = useLocalState(context, 'selectedCategory', 0);

  const {
    requests,
    currentpoints,
    categories,
    shopping_list,
    shopping_list_cost,
  } = data;

  return (
    <Fragment>
      Points: <AnimatedNumber value={currentpoints} />
      <Divider />
      <Flex>
        <FlexItem grow={1}>
          <Button
            onClick={() => setSelectedMenu("pendingorder")}
            selected={selectedMenu==="pendingorder"}>Pending Order
          </Button>
        </FlexItem>
        <FlexItem><AnimatedNumber value={shopping_list.length} /> items
        </FlexItem>
        <FlexItem width="5px" />
        <FlexItem>Cost: <AnimatedNumber value={shopping_list_cost} /></FlexItem>
      </Flex>
      <Flex>
        <FlexItem grow={1}>
          <Button
            onClick={() => setSelectedMenu("requests")}
            selected={selectedMenu==="requests"}>Requests
          </Button>
        </FlexItem>
        <FlexItem>{requests.length} pending</FlexItem>
      </Flex>
      <Divider />
      { categories.map(category => (
        <Fragment key={category.id}>
          <Button key={category.id} selected={selectedMenu === category}
            onClick={() => {
              setSelectedMenu(category);
              setSelectedCategory(1); }}>{category}
          </Button>
          <br />
        </Fragment>
      )) }
    </Fragment>
  );
};

const Category = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    selectedPackCat,
  } = props;

  return selectedPackCat.map(entry => (
    <Flex key={entry.id}>
      <FlexItem>
        <Button
          onClick={() =>
            act('addtocart', { id: entry.path })}
          content="Add to Cart" />
      </FlexItem>
      <FlexItem basis="80px" shrink={0} textAlign="right">
        {entry.cost} points
      </FlexItem>
      <FlexItem grow={1}>
        <Collapsible
          title={entry.name}
          color="gray">
          <Table>
            <TableRow>
              <TableCell>
                Container Type:
              </TableCell>
              <TableCell>
                {entry.container_name}
              </TableCell>
            </TableRow>
            <PackContents contains={entry.contains} />
          </Table>
          <Divider />
        </Collapsible>
      </FlexItem>
    </Flex>
  ));

};

const PackContents = (props, context) => {
  const {
    contains,
  } = props;

  return map(contententry => (
    <TableRow>
      <TableCell width="50%">
        {contententry.name}
      </TableCell>
      <TableCell>
        x {contententry.count}
      </TableCell>
    </TableRow>
  ))(contains);
};
