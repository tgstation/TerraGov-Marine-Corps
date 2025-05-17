import { Suspense, useEffect, useState } from 'react';
import { Stack } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { logger } from '../../logging';
import { LoadingScreen } from '../common/LoadingScreen';
import { Category } from './Category';
import { StaticMenus, SupplyPacks, useSupplyPacks } from './constants';
import { Menu } from './Menu';
import { Exports, OrderList, Requests, ShoppingCart } from './StaticMenus';
import { CargoData, SupplyPackData } from './types';

export const Cargo = (props) => {
  const { readOnly } = props;
  return (
    <Window width={1100} height={700}>
      <Suspense fallback={<LoadingScreen />}>
        <InnerCargo readOnly={readOnly} />
      </Suspense>
    </Window>
  );
};

export const CargoRequest = (props) => {
  return <Cargo readOnly />;
};

// inner layer for suspense in case we need to wait for data
function InnerCargo(props: { readOnly: boolean }) {
  const { act, data } = useBackend<CargoData>();
  const [selectedMenu, setSelectedMenu] = useState('');
  const [supplypackData, setSupplypackData] = useState<SupplyPackData>();
  const { readOnly } = props;

  useEffect(() => {
    fetchRetry(resolveAsset('supply_packs.json'))
      .then((response) => response.json())
      .then((packdata) => {
        setSupplypackData(
          Object.fromEntries(
            Object.entries(packdata as SupplyPackData).filter(
              ([_, pack]) =>
                !(pack.available_against_xeno_only && !data.is_xeno_only),
            ),
          ),
        );
      })
      .catch((error) => {
        logger.log('Failed to fetch supply_packs.json', error);
      });
  }, []);

  return (
    <SupplyPacks.Provider value={supplypackData}>
      <Stack height="650px" align="stretch">
        <Stack.Item width="280px">
          <Menu
            readOnly={readOnly}
            selectedMenu={selectedMenu}
            setSelectedMenu={setSelectedMenu}
          />
        </Stack.Item>
        <Stack.Item position="relative" grow height="100%">
          <Window.Content scrollable>
            <CargoDisplay
              readOnly={readOnly}
              selectedMenu={selectedMenu}
              setSelectedMenu={setSelectedMenu}
            />
          </Window.Content>
        </Stack.Item>
      </Stack>
    </SupplyPacks.Provider>
  );
}

interface CargoDisplayProps {
  readOnly: boolean;
  selectedMenu: string;
  setSelectedMenu: React.Dispatch<React.SetStateAction<string>>;
}

function CargoDisplay(props: CargoDisplayProps) {
  const { act, data } = useBackend<CargoData>();
  const { readOnly, selectedMenu, setSelectedMenu } = props;

  const {
    approvedrequests,
    deniedrequests,
    shopping_history,
    awaiting_delivery,
  } = data;

  const supplypacks = useSupplyPacks();
  const selectedPackCat = supplypacks
    ? Object.keys(supplypacks).filter(
        (key) => supplypacks[key].group === selectedMenu,
      )
    : null;

  switch (selectedMenu) {
    case StaticMenus.PreviousPurchases:
      return (
        <OrderList
          type={shopping_history}
          readOnly
          selectedMenu={selectedMenu}
        />
      );
    case StaticMenus.ExportHistory:
      return <Exports />;
    case StaticMenus.AwaitingDelivery:
      return (
        <OrderList
          type={awaiting_delivery}
          readOnly
          selectedMenu={selectedMenu}
        />
      );
    case StaticMenus.PendingOrder:
      return (
        <ShoppingCart
          readOnly={readOnly}
          selectedMenu={selectedMenu}
          setSelectedMenu={setSelectedMenu}
        />
      );
    case StaticMenus.Requests:
      return <Requests readOnly={readOnly} selectedMenu={selectedMenu} />;
    case StaticMenus.ApprovedRequests:
      return <OrderList type={approvedrequests} selectedMenu={selectedMenu} />;
    case StaticMenus.DeniedRequests:
      return (
        <OrderList
          readOnly={readOnly}
          type={deniedrequests}
          selectedMenu={selectedMenu}
        />
      );
    default:
      if (selectedPackCat) {
        return (
          <Category
            selectedPackCat={selectedPackCat}
            should_filter
            selectedMenu={selectedMenu}
          />
        );
      }
  }
}
