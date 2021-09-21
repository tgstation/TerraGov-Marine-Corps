import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Divider, Collapsible, AnimatedNumber, Box, Section, LabeledList, Icon, Input, Table } from '../components';
import { Window } from '../layouts';
import { map } from 'common/collections';

const category_icon = {
  'Operations': "parachute-box",
  'Weapons': "fighter-jet",
  'Attachments': "microchip",
  'Ammo': "space-shuttle",
  'Armor': "hard-hat",
  'Clothing': "tshirt",
  'Medical': "medkit",
  'Engineering': "tools",
  'Supplies': "hamburger",
  'Imports': "boxes",
  'Vehicles': "road",
  'Factory': "industry",
  'Pending Order': "shopping-cart",
};

export const Cargo = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  const {
    supplypacks,
    approvedrequests,
    export_history,
    deniedrequests,
    shopping_history,
    awaiting_delivery,
  } = data;

  const selectedPackCat = supplypacks[selectedMenu]
    ? supplypacks[selectedMenu]
    : null;

  return (
    <Window
      width={900}
      height={700}>
      <Flex height="650px" align="stretch">
        <Flex.Item width="280px">
          <Menu />
        </Flex.Item>
        <Flex.Item position="relative" grow={1} height="100%">
          <Window.Content scrollable>
            {selectedMenu==="Previous Purchases" && (
              <OrderList type={shopping_history} readOnly={1} />
            )}
            {selectedMenu==="Export History" && (
              <Exports />
            )}
            {selectedMenu==="Awaiting Delivery" && (
              <OrderList type={awaiting_delivery} readOnly={1} />
            )}
            {selectedMenu==="Pending Order" && (
              <ShoppingCart />
            )}
            {selectedMenu==="Requests" && (
              <Requests />
            )}
            {selectedMenu==="Approved Requests" && (
              <OrderList type={approvedrequests} />
            )}
            {selectedMenu==="Denied Requests" && (
              <OrderList type={deniedrequests} />
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
      <Table>
        {export_history.map(exp => (
          <Table.Row key={exp.id}>
            <Table.Cell>{exp.name}</Table.Cell>
            <Table.Cell>{exp.points} points</Table.Cell>
          </Table.Row>
        ))}
      </Table>
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
  const { readOnly } = props;

  const {
    requests,
    currentpoints,
    categories,
    shopping_list_cost,
    shopping_list_items,
    elevator,
    elevator_dir,
    export_history,
    deniedrequests,
    approvedrequests,
    awaiting_delivery_orders,
    shopping_history,
  } = data;

  const elev_status = elevator==="Raised" || elevator==="Lowered";

  return (
    <Section height="100%" p="5px">
      Points: <AnimatedNumber value={currentpoints} />
      { !readOnly && (
        <>
          <Divider />
          <Flex>
            <Flex.Item grow={1}>
              <MenuButton
                icon="luggage-cart"
                menuname="Awaiting Delivery"
                condition={!awaiting_delivery_orders} />
            </Flex.Item>
            <Flex.Item>
              <AnimatedNumber value={awaiting_delivery_orders} /> order{
                awaiting_delivery_orders !== 1 && "s"
              }
            </Flex.Item>
          </Flex>
          <Flex>
            <Flex.Item grow={1}>
              <Button
                onClick={() => act('send')}
                disabled={!elev_status}
                icon={"angle-double-"+elevator_dir}>
                {elevator_dir==="up"?"Raise":"Lower"}
              </Button>
            </Flex.Item>
            <Flex.Item>
              Elevator: {elevator}
            </Flex.Item>
          </Flex>
        </>
      )}
      <Divider />
      <Flex>
        <Flex.Item grow={1}>
          <MenuButton
            icon="shopping-cart"
            menuname="Pending Order"
            condition={!shopping_list_items} />
        </Flex.Item>
        <Flex.Item>
          <AnimatedNumber value={shopping_list_items} /> item{
            shopping_list_items !== 1 && "s"
          }
        </Flex.Item>
        <Flex.Item width="5px" />
        <Flex.Item>Cost:
          <AnimatedNumber value={shopping_list_cost} />
        </Flex.Item>
      </Flex>
      { !readOnly && (
        <>
          <MenuButton
            icon="history"
            menuname="Previous Purchases"
            condition={!shopping_history.length} />
          <MenuButton
            icon="shipping-fast"
            menuname="Export History"
            condition={!export_history.length} />
        </>
      )}
      <Divider />
      <Flex>
        <Flex.Item grow={1}>
          <MenuButton
            icon="clipboard-list"
            menuname="Requests"
            condition={!requests.length} />
        </Flex.Item>
        <Flex.Item>{requests.length} pending</Flex.Item>
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

const OrderList = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    type,
    buttons,
    readOnly,
  } = props;

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  return (
    <Section title={selectedMenu} buttons={buttons}>
      { type.map(request => {
        const {
          id,
          orderer_rank,
          orderer,
          authed_by,
          reason,
          cost,
          packs,
        } = request;
        const rank = orderer_rank || "";

        return (
          <Section key={id} level={2}
            title={"Order #"+id}
            buttons={!readOnly && (
              <>
                { (!authed_by || selectedMenu==="Denied Requests") && (
                  <Button
                    onClick={() => act('approve', { id: id })}
                    icon="check"
                    content="Approve" />) }
                { !authed_by && (
                  <Button
                    onClick={() => act('deny', { id: id })}
                    icon="times"
                    content="Deny" />)}
              </>
            )}>
            <LabeledList>
              <LabeledList.Item label="Requested by">
                {rank+" "+orderer}
              </LabeledList.Item>
              <LabeledList.Item label="Reason">
                {reason}
              </LabeledList.Item>
              <LabeledList.Item label="Total Cost">
                {cost} points
              </LabeledList.Item>
              <LabeledList.Item label="Contents">
                <Packs packs={packs} />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        );
      })}
    </Section>
  );
};

const Packs = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    packs,
  } = props;

  return packs.map(pack => (
    <Pack pack={pack} key={pack} />
  ));
};

const Pack = (props, context) => {
  const { act, data } = useBackend(context);
  const { pack } = props;
  const {
    supplypackscontents,
  } = data;
  const {
    name,
    cost,
    contains,
  } = supplypackscontents[pack];
  return (
    !!contains && (contains.constructor === Object) ? (
      <Collapsible
        color="gray"
        title={
          <PackName cost={cost} name={name} pl={0} />
        }>
        <Table>
          <PackContents contains={contains} />
        </Table>
      </Collapsible>
    ) : (
      <PackName cost={cost} name={name} pl="22px" />
    )
  );
};

const PackName = (props, context) => {
  const {
    cost,
    name,
    pl,
  } = props;

  return (
    <Box inline pl={pl}>
      <Box textAlign="right" inline width="65px">
        {cost} points
      </Box>
      <Box width="15px" inline />
      <Box inline>
        {name}
      </Box>
    </Box>
  );
};

const Requests = (props, context) => {
  const { act, data } = useBackend(context);
  const { readOnly } = props;
  const {
    requests,
  } = data;

  return (
    <OrderList type={requests}
      readOnly={readOnly}
      buttons={!readOnly && (
        <>
          <Button
            icon="check-double"
            onClick={() => act('approveall')}
            content="Approve All" />
          <Button
            icon="times-circle"
            onClick={() => act('denyall')}
            content="Deny All" />
        </>
      )} />
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
  const { readOnly } = props;
  const shopping_list_array = Object.keys(shopping_list);
  const [
    reason,
    setReason,
  ] = useLocalState(context, 'reason', null);

  return (
    <Section>
      <Box textAlign="center">
        <Button
          p="5px"
          icon="dollar-sign"
          content={readOnly?"Submit Request":"Purchase Cart"}
          disabled={
            (readOnly && !reason)
            || !shopping_list_items
          }
          onClick={() => act((readOnly ? 'submitrequest' : 'buycart'), {
            reason: reason,
          })} />
        <Button
          p="5px"
          content="Clear Cart"
          disabled={!shopping_list_items}
          icon="snowplow"
          onClick={() => act('clearcart')} />
      </Box>
      { readOnly && (
        <>
          <Box width="10%" inline>Reason: </Box>
          <Input
            width="89%"
            inline value={reason}
            onInput={(e, value) => setReason(value)} />
        </>
      )}
      <Category selectedPackCat={shopping_list_array} level={2} />
    </Section>
  );
};

const CategoryButton = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    icon,
    disabled,
    id,
    mode,
  } = props;

  return (
    <Button
      icon={icon}
      disabled={disabled}
      onClick={() => act('cart', {
        id: id,
        mode: mode })} />
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
    level,
  } = props;

  return (
    <Section level={level || 1} title={
      <>
        <Icon name={category_icon[selectedMenu]} mr="5px" />
        {selectedMenu}
      </>
    }>
      <Table>
        { selectedPackCat.map(entry => {
          const shop_list = shopping_list[entry] || 0;
          const count = shop_list ? shop_list.count : 0;
          const {
            cost,
          } = supplypackscontents[entry];
          return (
            <Table.Row key={entry.id}>
              <Table.Cell width="130px">
                <CategoryButton
                  icon="fast-backward"
                  disabled={!count}
                  id={entry}
                  mode="removeall" />
                <CategoryButton
                  icon="backward"
                  disabled={!count}
                  id={entry}
                  mode="removeone" />
                <Box width="25px" inline textAlign="center">
                  { !!count && (
                    <AnimatedNumber value={count} />
                  )}
                </Box>
                <CategoryButton
                  icon="forward"
                  id={entry}
                  mode="addone" />
                <CategoryButton
                  icon="fast-forward"
                  disabled={cost > spare_points}
                  id={entry}
                  mode="addall" />
              </Table.Cell>
              <Table.Cell>
                <Pack pack={entry} />
              </Table.Cell>
            </Table.Row>
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
    <>
      <Table.Row>
        <Table.Cell bold>
          Item Type
        </Table.Cell>
        <Table.Cell bold>
          Quantity
        </Table.Cell>
      </Table.Row>
      {map(contententry => (
        <Table.Row>
          <Table.Cell width="70%">
            {contententry.name}
          </Table.Cell>
          <Table.Cell>
            x {contententry.count}
          </Table.Cell>
        </Table.Row>
      ))(contains)}
    </>
  );
};


export const CargoRequest = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  const {
    supplypacks,
    approvedrequests,
    deniedrequests,
    awaiting_delivery,
  } = data;

  const selectedPackCat = supplypacks[selectedMenu]
    ? supplypacks[selectedMenu]
    : null;

  return (
    <Window
      width={900}
      height={700}>
      <Flex height="650px" align="stretch">
        <Flex.Item width="280px">
          <Menu readOnly={1} />
        </Flex.Item>
        <Flex.Item position="relative" grow={1} height="100%">
          <Window.Content scrollable>
            {selectedMenu==="Awaiting Delivery" && (
              <OrderList type={awaiting_delivery} readOnly={1} />
            )}
            {selectedMenu==="Pending Order" && (
              <ShoppingCart readOnly={1} />
            )}
            {selectedMenu==="Requests" && (
              <Requests readOnly={1} />
            )}
            {selectedMenu==="Approved Requests" && (
              <OrderList type={approvedrequests} />
            )}
            {selectedMenu==="Denied Requests" && (
              <OrderList type={deniedrequests} readOnly={1} />
            )}
            {!!selectedPackCat
              && (<Category selectedPackCat={selectedPackCat} />)}
          </Window.Content>
        </Flex.Item>
      </Flex>
    </Window>
  );
};
