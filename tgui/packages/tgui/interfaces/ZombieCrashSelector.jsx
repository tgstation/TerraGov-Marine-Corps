import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  Modal,
  ProgressBar,
  Section,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ZombieCrashSelector = (props) => {
  const { act, data } = useBackend();
  const [showEmpty, setShowEmpty] = useState(false);
  const [showDesc, setShowDesc] = useState(null);

  const categories = Object.keys(data.displayed_products).map((key) => ({
    ...data.categories[key],
    name: key,
    entries: data.displayed_products[key],
  }));

  return (
    <Window width={650} height={700}>
      {!!showDesc && (
        <Modal width="400px">
          <Box>{showDesc}</Box>
          <Button content="Dismiss" onClick={() => setShowDesc(null)} />
        </Modal>
      )}

      <Window.Content scrollable>
        <Section title="Points">
          <PointsBar
            bar_name="Pooled Points"
            tooltip_content="These points are gained when your personal points reaches its limit or by hitting the vendor with your ID."
            remaining_points={data.pooled_points_remaining}
            total_points={data.pooled_points_total}
          />
          <PointsBar
            bar_name="Personal Points"
            tooltip_content="These points are gained as disk cycles are completed & tunnels are destroyed."
            remaining_points={data.personal_points_remaining}
            total_points={data.personal_points_total}
          />
        </Section>
        {categories.map((category) => (
          <ItemCategory
            key={category.id}
            categoryName={category.name}
            entries={category.entries}
            remaining_points={
              data.pooled_points_remaining + data.personal_points_remaining
            }
            showDesc={showDesc}
            setShowDesc={setShowDesc}
          />
        ))}
      </Window.Content>
    </Window>
  );
};

const PointsBar = (props) => {
  const { act, data } = useBackend();
  const { bar_name, tooltip_content, remaining_points, total_points } = props;

  return (
    <LabeledList.Item label={bar_name}>
      <Tooltip content={tooltip_content}>
        <ProgressBar
          color="green"
          value={remaining_points / total_points}
          ranges={{
            good: [0.67, Infinity],
            average: [0.33, 0.67],
            bad: [-Infinity, 0.33],
          }}
        >
          {`${remaining_points} / ${total_points}`}
        </ProgressBar>
      </Tooltip>
    </LabeledList.Item>
  );
};

const ItemCategory = (props) => {
  const { categoryName, entries, remaining_points, showDesc, setShowDesc } =
    props;

  return (
    <Section title={categoryName}>
      <LabeledList>
        {entries.map((display_record) => {
          return (
            <ItemLine
              key={display_record.id}
              display_record={display_record}
              remaining_points={remaining_points}
              showDesc={showDesc}
              setShowDesc={setShowDesc}
            />
          );
        })}
      </LabeledList>
    </Section>
  );
};

const ItemLine = (props) => {
  const { act, data } = useBackend();

  const {
    display_record: {
      id,
      product_cost,
      product_index,
      product_color,
      product_name,
      product_desc,
    },
    remaining_points,
    showDesc,
    setShowDesc,
  } = props;
  const colorToElement = {
    'medical-stamina': (
      <Box inline mr="6px" ml="6px" color="#00fff2ff">
        Stamina
      </Box>
    ),
    'medical-emergency': (
      <Box inline mr="6px" ml="6px" color="#00fff2ff">
        Emergency
      </Box>
    ),
    'medical-antitoxin': (
      <Box inline mr="6px" ml="6px" color="#00fff2ff">
        Antitoxin
      </Box>
    ),
    'engineering-material': (
      <Box inline mr="6px" ml="6px" color="#fbff00ff">
        Materials
      </Box>
    ),
    'engineering-placeable': (
      <Box inline mr="6px" ml="6px" color="#fbff00ff">
        Placeable
      </Box>
    ),
    'engineering-explosive': (
      <Box inline mr="6px" ml="6px" color="#fbff00ff">
        Explosive
      </Box>
    ),
    'engineering-grenade': (
      <Box inline mr="6px" ml="6px" color="#fbff00ff">
        Grenade
      </Box>
    ),
    'smartgunner-machinegun-ammo': (
      <Box inline mr="6px" ml="6px" color="#ff9900ff">
        Machinegun
      </Box>
    ),
    'smartgunner-minigun-ammo': (
      <Box inline mr="6px" ml="6px" color="#ff9900ff">
        Minigun
      </Box>
    ),
    'smartgunner-rifle-ammo': (
      <Box inline mr="6px" ml="6px" color="#ff9900ff">
        Rifle
      </Box>
    ),
    'smartgunner-underbarrel-ammo': (
      <Box inline mr="6px" ml="6px" color="#ff9900ff">
        Underbarrel
      </Box>
    ),
    'artillery-tool': (
      <Box inline mr="6px" ml="6px" color="#CD5C5C">
        Tool
      </Box>
    ),
    'artillery-mortar': (
      <Box inline mr="6px" ml="6px" color="#CD5C5C">
        Mortar
      </Box>
    ),
    'artillery-howitzer': (
      <Box inline mr="6px" ml="6px" color="#CD5C5C">
        Howitzer
      </Box>
    ),
    'vehicle-tool': (
      <Box inline mr="6px" ml="6px" color="#00ff0dff">
        Tool
      </Box>
    ),
    vehicle: (
      <Box inline mr="6px" ml="6px" color="#00ff0dff">
        Vehicle
      </Box>
    ),
    'vehicle-attachable': (
      <Box inline mr="6px" ml="6px" color="#00ff0dff">
        Attachable
      </Box>
    ),
    'vehicle-ammo': (
      <Box inline mr="6px" ml="6px" color="#00ff0dff">
        Ammo
      </Box>
    ),
    'emplacement-laser': (
      <Box inline mr="6px" ml="6px" color="#fff385ff">
        Laser
      </Box>
    ),
    'emplacement-heavysmartgun': (
      <Box inline mr="6px" ml="6px" color="#fff385ff">
        Heavy Smartgun
      </Box>
    ),
    'emplacement-heavymachinegun': (
      <Box inline mr="6px" ml="6px" color="#fff385ff">
        Heavy Machinegun
      </Box>
    ),
    'emplacement-minigun': (
      <Box inline mr="6px" ml="6px" color="#fff385ff">
        Minigun
      </Box>
    ),
    'emplacement-autocannon': (
      <Box inline mr="6px" ml="6px" color="#fff385ff">
        Autocannon
      </Box>
    ),
    'armor-module-tyr': (
      <Box inline mr="6px" ml="6px" color="#ae00ffff">
        Extra Armor
      </Box>
    ),
    'armor-module-valk': (
      <Box inline mr="6px" ml="6px" color="#ae00ffff">
        Automatic Healing
      </Box>
    ),
    'armor-module-hlin': (
      <Box inline mr="6px" ml="6px" color="#ae00ffff">
        Explosion Protection
      </Box>
    ),
    'armor-module-mimir': (
      <Box inline mr="6px" ml="6px" color="#ae00ffff">
        Biological Protection
      </Box>
    ),
    'armor-module-surt': (
      <Box inline mr="6px" ml="6px" color="#ae00ffff">
        Fire Protection
      </Box>
    ),
    'grenade-explosive': (
      <Box inline mr="6px" ml="6px" color="#ffbb00ff">
        Explosive
      </Box>
    ),
    'grenade-incendiary': (
      <Box inline mr="6px" ml="6px" color="#ffbb00ff">
        Incendiary
      </Box>
    ),
    'grenade-gas': (
      <Box inline mr="6px" ml="6px" color="#ffbb00ff">
        Anti-Gas
      </Box>
    ),
    attachment: (
      <Box inline mr="6px" ml="6px" color="#c8ff00ff">
        Attachment
      </Box>
    ),
    'weapon-melee': (
      <Box inline mr="6px" ml="6px" color="#ff00b3ff">
        Melee
      </Box>
    ),
    'weapon-shield': (
      <Box inline mr="6px" ml="6px" color="#ff00b3ff">
        Shield
      </Box>
    ),
    'weapon-revolver': (
      <Box inline mr="6px" ml="6px" color="#ff00b3ff">
        Revolver
      </Box>
    ),
    'weapon-plasma': (
      <Box inline mr="6px" ml="6px" color="#ff00b3ff">
        Plasma
      </Box>
    ),
    'weapon-iff': (
      <Box inline mr="6px" ml="6px" color="#ff00b3ff">
        IFF
      </Box>
    ),
    'weapon-minigun': (
      <Box inline mr="6px" ml="6px" color="#ff00b3ff">
        Minigun
      </Box>
    ),
    'weapon-flamer': (
      <Box inline mr="6px" ml="6px" color="#ff00b3ff">
        Flamer
      </Box>
    ),
    'fun-random': (
      <Box inline mr="6px" ml="6px" color="#BA55D3">
        Random
      </Box>
    ),
  };
  return (
    <LabeledList.Item
      key={id}
      buttons={
        <>
          {colorToElement[product_color]}
          {product_cost > 0 && (
            <Box inline width="75px" mr="6px" ml="6px">
              {product_cost} points
            </Box>
          )}
          <Button
            disabled={product_cost > remaining_points}
            onClick={() => act('vend', { vend: product_index })}
            selected={product_color === 'white'}
          >
            Vend
          </Button>
        </>
      }
      label={product_name}
      labelColor="white"
    >
      {!!product_desc && (
        <Button onClick={() => setShowDesc(product_desc)}>?</Button>
      )}
    </LabeledList.Item>
  );
};
