import { Fragment, SetStateAction } from 'react';
import { AnimatedNumber, Button, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { category_icon, StaticMenus, useSupplyPacks } from './constants';
import { getSupplyRequestCostFromTypepathMap } from './helpers';
import { CargoData } from './types';

type MenuButtonProps = {
  disablecondition?: BooleanLike;
  menuname: string;
  icon: string;
  selectedMenu: string;
  setSelectedMenu: React.Dispatch<SetStateAction<string | null>>;
};

const MenuButton = (props: MenuButtonProps) => {
  const { disablecondition, menuname, icon, selectedMenu, setSelectedMenu } =
    props;

  return (
    <Button
      fluid
      icon={icon}
      selected={selectedMenu === menuname}
      onClick={() => setSelectedMenu(menuname)}
      disabled={disablecondition}
    >
      {menuname}
    </Button>
  );
};

type MenuProps = {
  readOnly: boolean;
  selectedMenu: string;
  setSelectedMenu: React.Dispatch<SetStateAction<string | null>>;
};

export const Menu = (props: MenuProps) => {
  const { act, data } = useBackend<CargoData>();
  const { readOnly, selectedMenu, setSelectedMenu } = props;

  const {
    requests,
    currentpoints,
    shopping_list,
    elevator,
    elevator_dir,
    export_history,
    deniedrequests,
    approvedrequests,
    awaiting_delivery,
    shopping_history,
  } = data;
  const supplypacks = useSupplyPacks();
  if (!supplypacks) return;
  const categories = Array.from(
    new Set(Object.values(supplypacks || {}).map((pack) => pack.group)),
  );
  const shopping_list_items = Object.values(shopping_list || {}).reduce(
    (sum, item) => sum + item.amount,
    0,
  );
  const elev_status = elevator === 'Raised' || elevator === 'Lowered';

  const textcentermargin = 0.4;

  return (
    <Section height="100%" p="5px">
      Points: <AnimatedNumber value={currentpoints} />
      <Stack fill vertical>
        {!readOnly && (
          <>
            <Stack.Divider />
            <Stack.Item>
              <Stack>
                <Stack.Item grow>
                  <MenuButton
                    icon="luggage-cart"
                    menuname={StaticMenus.AwaitingDelivery}
                    disablecondition={!awaiting_delivery}
                    selectedMenu={selectedMenu}
                    setSelectedMenu={setSelectedMenu}
                  />
                </Stack.Item>
                <Stack.Item mt={textcentermargin}>
                  <AnimatedNumber
                    value={awaiting_delivery ? awaiting_delivery.length : 0}
                  />{' '}
                  order
                  {awaiting_delivery?.length !== 1 && 's'}
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    onClick={() => act('send')}
                    disabled={!elev_status}
                    icon={'angle-double-' + elevator_dir}
                  >
                    {elevator_dir === 'up' ? 'Raise' : 'Lower'}
                  </Button>
                </Stack.Item>
                <Stack.Item mt={textcentermargin}>
                  Elevator: {elevator}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </>
        )}
        <Stack.Divider />
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <MenuButton
                icon="shopping-cart"
                menuname={StaticMenus.PendingOrder}
                disablecondition={!shopping_list_items}
                selectedMenu={selectedMenu}
                setSelectedMenu={setSelectedMenu}
              />
            </Stack.Item>
            <Stack.Item mt={textcentermargin}>
              <AnimatedNumber value={shopping_list_items} /> item
              {shopping_list_items !== 1 && 's'}
            </Stack.Item>
            <Stack.Item width="5px" />
            <Stack.Item mt={textcentermargin}>
              Cost:
              <AnimatedNumber
                value={
                  shopping_list
                    ? getSupplyRequestCostFromTypepathMap(shopping_list)
                    : 0
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {!readOnly && (
          <>
            <Stack.Item>
              <MenuButton
                icon="history"
                menuname={StaticMenus.PreviousPurchases}
                disablecondition={!shopping_history?.length}
                selectedMenu={selectedMenu}
                setSelectedMenu={setSelectedMenu}
              />
            </Stack.Item>
            <Stack.Item>
              <MenuButton
                icon="shipping-fast"
                menuname={StaticMenus.ExportHistory}
                disablecondition={!export_history?.length}
                selectedMenu={selectedMenu}
                setSelectedMenu={setSelectedMenu}
              />
            </Stack.Item>
          </>
        )}
        <Stack.Divider />
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <MenuButton
                icon="clipboard-list"
                menuname={StaticMenus.Requests}
                disablecondition={!requests.length}
                selectedMenu={selectedMenu}
                setSelectedMenu={setSelectedMenu}
              />
            </Stack.Item>
            <Stack.Item mt={textcentermargin}>
              {requests.length} pending
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <MenuButton
            icon="clipboard-check"
            menuname={StaticMenus.ApprovedRequests}
            disablecondition={!approvedrequests.length}
            selectedMenu={selectedMenu}
            setSelectedMenu={setSelectedMenu}
          />
        </Stack.Item>
        <Stack.Item>
          <MenuButton
            icon="trash"
            menuname={StaticMenus.DeniedRequests}
            disablecondition={!deniedrequests.length}
            selectedMenu={selectedMenu}
            setSelectedMenu={setSelectedMenu}
          />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Stack vertical g={0}>
            {categories.map((category) => (
              <Stack.Item key={category}>
                <MenuButton
                  icon={category_icon[category]}
                  menuname={category}
                  selectedMenu={selectedMenu}
                  setSelectedMenu={setSelectedMenu}
                />
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
