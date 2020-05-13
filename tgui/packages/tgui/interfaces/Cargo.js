import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Divider, Collapsible, AnimatedNumber, Box } from '../components';
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

  //logger.log(shopping_list);

  return (
    <Window resizable>
      <Flex height="650px">
        <Flex.Item width="250px">
          <Menu />
        </Flex.Item>
        <Flex.Item position="relative" grow={1}>
          <Window.Content scrollable>
            {selectedMenu==="pendingorder" && (
              <ShoppingCart />
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
    shopping_list_items,
    elevator,
    elevator_dir,
  } = data;

  const elev_status = elevator==="Raised" || elevator==="Lowered";

  return (
    <Fragment>
      Points: <AnimatedNumber value={currentpoints} />
      <Divider />
      <Flex>
        <FlexItem grow={1}>
          <Button
            onClick={() => act('send')}
            disabled={!elev_status}
            icon={"angle-double-"+elevator_dir}>
            {elevator_dir==="up"?"Raise":"Lower"}
          </Button>
        </FlexItem>
        <FlexItem>
          Elevator: {elevator}
        </FlexItem>
      </Flex>
      <Divider />
      <Flex>
        <FlexItem grow={1}>
          <Button
            onClick={() => setSelectedMenu("pendingorder")}
            disabled={!shopping_list_items}
            selected={selectedMenu==="pendingorder"}>Pending Order
          </Button>
        </FlexItem>
        <FlexItem><AnimatedNumber value={shopping_list_items} /> items
        </FlexItem>
        <FlexItem width="5px" />
        <FlexItem>Cost: <AnimatedNumber value={shopping_list_cost} /></FlexItem>
      </Flex>
      <Flex>
        <FlexItem grow={1}>
          <Button
            onClick={() => setSelectedMenu("requests")}
            disabled={!requests.length}
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

const ShoppingCart = (props, context) => {
  const { act, data } = useBackend(context);

  const { shopping_list } = data;

  const shopping_list_array = Object.values(shopping_list)

  //logger.log(shopping_list_array);

  return ( <Category selectedPackCat={shopping_list_array} /> );
};

const Category = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    shopping_list,
    shopping_list_cost,
    currentpoints,
  } = data;

  const spare_points = currentpoints - shopping_list_cost;

  const {
    selectedPackCat,
  } = props;

  return selectedPackCat.map(entry => {
    const shop_list = shopping_list[entry.path] || 0;
    const count = shop_list ? shop_list.count : 0;
    return (
    <Flex key={entry.id}>
      <FlexItem shrink={0}>
        <Button
          icon="fast-backward"
          disabled={!count}
          onClick={() => act('cart', { id: entry.path, mode: "removeall" })} />
        <Button
          icon="backward"
          disabled={!count}
          onClick={() => act('cart', { id: entry.path, mode: "removeone" })} />
        <Box width="15px" inline textAlign="center">
        { !!count && (
        <AnimatedNumber value={count} />
        )}
        </Box>
        <Button
          icon="forward"
          disabled={entry.cost > spare_points}
          onClick={() => act('cart', { id: entry.path, mode: "addone" })} />
        <Button
          icon="fast-forward"
          disabled={entry.cost > spare_points}
          onClick={() => act('cart', { id: entry.path, mode: "addall" })} />
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
  )});

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
