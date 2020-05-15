import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Divider, Collapsible, AnimatedNumber, Box, Section } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { map } from 'common/collections';
import { FlexItem } from '../components/Flex';
import { Table, TableRow, TableCell } from '../components/Table';

export const Cargo = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  const {
    supplypacks,
    approvedrequests,
    deniedrequests,
    shopping_history,
  } = data;

  const selectedPackCat = supplypacks[selectedMenu]
    ? supplypacks[selectedMenu]
    : null;

  return (
    <Window resizable>
      <Flex height="650px" align="stretch">
        <Flex.Item width="280px">
          <Menu />
        </Flex.Item>
        <Flex.Item position="relative" grow={1} height="100%">
          <Window.Content scrollable>
            {selectedMenu==="Previous Purchases" && (
              <RequestsHistory type={shopping_history} />
            )}
            {selectedMenu==="Export History" && (
              <Exports />
            )}
            {selectedMenu==="Awaiting Delivery" && (
              <AwaitingDelivery />
            )}
            {selectedMenu==="Pending Order" && (
              <ShoppingCart />
            )}
            {selectedMenu==="Requests" && (
              <Requests />
            )}
            {selectedMenu==="Approved Requests" && (
              <RequestsHistory type={approvedrequests} />
            )}
            {selectedMenu==="Denied Requests" && (
              <RequestsHistory type={deniedrequests} />
            )}
            {!!selectedPackCat
              && (<Category selectedPackCat={selectedPackCat} />)}
          </Window.Content>
        </Flex.Item>
      </Flex>
    </Window>
  );
};



const Exports = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    export_history,
  } = data;

  return (
    <Section title="Exports">
      { export_history.map(entry => (
        <Box key={entry.id}>
          {entry}
        </Box>
      ))}
    </Section>
  );
};

const MenuButton = (props, context) => {
  const {
    condition,
    menuname,
    icon,
    width,
  } = props;

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  return (
    <Button
      icon={icon}
      selected={selectedMenu===menuname}
      onClick={() => setSelectedMenu(menuname)}
      disabled={condition}
      width={width}
      content={menuname} />
  );
};

const Menu = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  const {
    requests,
    currentpoints,
    categories,
    shopping_list_cost,
    shopping_list_items,
    elevator,
    elevator_dir,
    deniedrequests,
    approvedrequests,
    awaiting_delivery_items,
    export_history,
    shopping_history,
  } = data;

  const category_icon = {
    'Operations': "parachute-box",
    'Weapons': "fighter-jet",
    'Hardpoint Modules': "truck",
    'Attachments': "microchip",
    'Ammo': "space-shuttle",
    'Armor': "hard-hat",
    'Clothing': "tshirt",
    'Medical': "medkit",
    'Engineering': "tools",
    'Supplies': "hamburger",
    'Imports': "boxes",
  };

  const elev_status = elevator==="Raised" || elevator==="Lowered";

  return (
    <Section height="100%" p="5px">
      Points: <AnimatedNumber value={currentpoints} />
      <Divider />
      <Flex>
        <FlexItem grow={1}>
          <MenuButton
            icon="luggage-cart"
            menuname="Awaiting Delivery"
            condition={!awaiting_delivery_items} />
        </FlexItem>
        <FlexItem>
          <AnimatedNumber value={awaiting_delivery_items} /> item{
            awaiting_delivery_items !== 1 && "s"
          }
        </FlexItem>
      </Flex>
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
          <MenuButton
            icon="shopping-cart"
            menuname="Pending Order"
            condition={!shopping_list_items} />
        </FlexItem>
        <FlexItem><AnimatedNumber value={shopping_list_items} /> item{
          shopping_list_items !== 1 && "s"
        }
        </FlexItem>
        <FlexItem width="5px" />
        <FlexItem>Cost: <AnimatedNumber value={shopping_list_cost} /></FlexItem>
      </Flex>
      <MenuButton
        icon="history"
        menuname="Previous Purchases"
        condition={!shopping_history.length} />
      <MenuButton
        icon="shipping-fast"
        menuname="Export History"
        condition={!export_history.length} />
      <Divider />
      <Flex>
        <FlexItem grow={1}>
          <MenuButton
            icon="clipboard-list"
            menuname="Requests"
            condition={!requests.length} />
        </FlexItem>
        <FlexItem>{requests.length} pending</FlexItem>
      </Flex>
      <MenuButton
        icon="clipboard-check"
        menuname="Approved Requests"
        condition={!approvedrequests.length} />
      <MenuButton
        icon="trash"
        menuname="Denied Requests"
        condition={!deniedrequests.length} />
      <Divider />
      { categories.map(category => (
        <Fragment key={category.id}>
          <MenuButton
            key={category.id}
            icon={category_icon[category]}
            menuname={category}
            condition={0}
            width="100%" />
          <br />
        </Fragment>
      )) }
    </Section>
  );
};

const AwaitingDelivery = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    awaiting_delivery,
    supplypackscontents,
  } = data;

  return map((awaiting, path) => {
    const {
      name,
      count,
    } = awaiting;
    const contains = supplypackscontents[path];

    return (
      <Flex>
        <FlexItem width="50px" textAlign="center" fontSize="16pt">
          {count} x
        </FlexItem>
        <FlexItem grow={1}>
          <Collapsible
            title={name}
            color="gray">
            <Table>
              <PackContents contains={contains} />
            </Table>
            <Divider />
          </Collapsible>
        </FlexItem>
      </Flex>
    );
  })(awaiting_delivery);
};

const RequestsHistory = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    type,
  } = props;

  const {
    supplypackscontents,
  } = data;

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  return (
    <Section title={selectedMenu}>
      {type.map(request => {
        const {
          id,
          orderer_rank,
          orderer,
          reason,
          name,
          cost,
          path,
        } = request;
        const contains = supplypackscontents[path];
        const rank = orderer_rank || "";
        return (
          <Section
            key={id}
            level={2}
            title={"Requested by: "+rank+" "+orderer}
            buttons={cost+" points"}
            pl="10px">
            <Box>
              Reason: {reason}
            </Box>
            <Flex>
              <Flex.Item grow={1}>
                <Collapsible
                  title={name}
                  color="gray">
                  <Table>
                    <PackContents contains={contains} />
                  </Table>
                </Collapsible>
              </Flex.Item>
            </Flex>
          </Section>
        );
      })}
    </Section>
  );
};

const Requests = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    requests,
    supplypackscontents,
  } = data;

  return (
    <Section title="Requests"
      buttons={
        <Fragment>
          <Button
            icon="check-double"
            onClick={() => act('approveall')}
            content="Approve All" />
          <Button
            icon="times-circle"
            onClick={() => act('denyall')}
            content="Deny All" />
        </Fragment>
      }
      minHeight="100%">
      { requests.map(request => {
        const {
          id,
          orderer_rank,
          orderer,
          reason,
          name,
          cost,
          path,
        } = request;
        const rank = orderer_rank || "";
        const contains = supplypackscontents[path];
        return (
          <Section key={id} level={2}
            title={"Requested by: "+rank+" "+orderer}
            buttons={
              <Fragment>
                <Button
                  onClick={() => act('approve', { id: id })}
                  icon="check"
                  content="Approve" />
                <Button
                  onClick={() => act('deny', { id: id })}
                  icon="times"
                  content="Deny" />
              </Fragment>
            }>
            <Box>
              Reason: {reason}
            </Box>
            <Flex>
              <Flex.Item grow={1}>
                <Collapsible
                  title={name}
                  color="gray">
                  <Table>
                    <PackContents contains={contains} />
                  </Table>
                </Collapsible>
              </Flex.Item>
              <Flex.Item basis="80px" shrink={0} textAlign="right">
                {cost} points
              </Flex.Item>
            </Flex>
          </Section>
        );
      })}
    </Section>
  );
};


const ShoppingCart = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    shopping_list,
    currentpoints,
    shopping_list_cost,
    shopping_list_items,
  } = data;

  const shopping_list_array = Object.values(shopping_list);

  return (
    <Fragment>
      <Box textAlign="center">
        <Button
          p="5px"
          icon="dollar-sign"
          content="Purchase Cart"
          disabled={shopping_list_cost>currentpoints || !shopping_list_items}
          onClick={() => act('buycart')} />
        <Button
          p="5px"
          content="Clear Cart"
          disabled={!shopping_list_items}
          icon="snowplow"
          onClick={() => act('clearcart')} />
      </Box>
      <Category selectedPackCat={shopping_list_array} />
    </Fragment>
  );
};

const Category = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    shopping_list,
    shopping_list_cost,
    currentpoints,
    supplypackscontents,
  } = data;

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  const spare_points = currentpoints - shopping_list_cost;

  const {
    selectedPackCat,
  } = props;

  return (
    <Section title={selectedMenu}>
      <Table>
        { selectedPackCat.map(entry => {
          const shop_list = shopping_list[entry.path] || 0;
          const count = shop_list ? shop_list.count : 0;
          return (
            <TableRow key={entry.id}>
              <TableCell>
                <Button
                  icon="fast-backward"
                  disabled={!count}
                  onClick={() => act('cart', {
                    id: entry.path,
                    mode: "removeall" })}
                />
                <Button
                  icon="backward"
                  disabled={!count}
                  onClick={() => act('cart', {
                    id: entry.path,
                    mode: "removeone" })}
                />
                <Box width="15px" inline textAlign="center">
                  { !!count && (
                    <AnimatedNumber value={count} />
                  )}
                </Box>
                <Button
                  icon="forward"
                  disabled={entry.cost > spare_points}
                  onClick={() => act('cart', {
                    id: entry.path,
                    mode: "addone" })} />
                <Button
                  icon="fast-forward"
                  disabled={entry.cost > spare_points}
                  onClick={() => act('cart', {
                    id: entry.path,
                    mode: "addall" })} />
              </TableCell>
              <TableCell>
                <Collapsible
                  color="gray"
                  title={
                    <Fragment>
                      <Box textAlign="right" inline>
                        {entry.cost} points
                      </Box>
                      <Box width="15px" inline />
                      <Box inline>
                        {entry.name}
                      </Box>
                    </Fragment>
                  }>
                  <Table>
                    <TableRow>
                      <TableCell>
                        Container Type: {entry.container_name}
                      </TableCell>
                    </TableRow>
                    <PackContents contains={supplypackscontents[entry.path]} />
                  </Table>
                </Collapsible>
              </TableCell>
            </TableRow>
          );
        }) }
      </Table>
    </Section>
  );
};

const PackContents = (props, context) => {
  const {
    contains,
  } = props;

  return (
    <Fragment>
      <TableRow>
        <TableCell bold>
          Item Type
        </TableCell>
        <TableCell bold>
          Quantity
        </TableCell>
      </TableRow>
      {map(contententry => (
        <TableRow>
          <TableCell width="70%">
            {contententry.name}
          </TableCell>
          <TableCell>
            x {contententry.count}
          </TableCell>
        </TableRow>
      ))(contains)}
    </Fragment>
  );
};
