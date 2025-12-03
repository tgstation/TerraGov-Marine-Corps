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
        Machinegun Ammo
      </Box>
    ),
    'smartgunner-minigun-ammo': (
      <Box inline mr="6px" ml="6px" color="#ff9900ff">
        Minigun Ammo
      </Box>
    ),
    'smartgunner-rifle-ammo': (
      <Box inline mr="6px" ml="6px" color="#ff9900ff">
        Rifle Ammo
      </Box>
    ),
    'smartgunner-underbarrel-ammo': (
      <Box inline mr="6px" ml="6px" color="#ff9900ff">
        Underbarrel Ammo
      </Box>
    ),
    tool: (
      <Box inline mr="6px" ml="6px" color="#FFE4C4">
        Tools
      </Box>
    ),
    artillery: (
      <Box inline mr="6px" ml="6px" color="#CD5C5C">
        Artillery
      </Box>
    ),
    'artillery-ammo': (
      <Box inline mr="6px" ml="6px" color="#ffc0c0ff">
        Ammo
      </Box>
    ),
    vehicle: (
      <Box inline mr="6px" ml="6px" color="#00e1ffff">
        Vehicle
      </Box>
    ),
    'vehicle-attachable': (
      <Box inline mr="6px" ml="6px" color="#7df0ffff">
        Attachable
      </Box>
    ),
    'vehicle-ammo': (
      <Box inline mr="6px" ml="6px" color="#7df0ffff">
        Ammo
      </Box>
    ),
    emplacement: (
      <Box inline mr="6px" ml="6px" color="#ffe600ff">
        Emplacement
      </Box>
    ),
    'emplacement-ammo': (
      <Box inline mr="6px" ml="6px" color="#fff385ff">
        Ammo
      </Box>
    ),
    'armor-module': (
      <Box inline mr="6px" ml="6px" color="#ae00ffff">
        Module
      </Box>
    ),
    grenade: (
      <Box inline mr="6px" ml="6px" color="#ffbb00ff">
        Grenade
      </Box>
    ),
    attachment: (
      <Box inline mr="6px" ml="6px" color="#c8ff00ff">
        Attachment
      </Box>
    ),
    melee: (
      <Box inline mr="6px" ml="6px" color="#ff0015ff">
        Melee
      </Box>
    ),
    gun: (
      <Box inline mr="6px" ml="6px" color="#ff0015ff">
        Gun
      </Box>
    ),
    'gun-ammo': (
      <Box inline mr="6px" ml="6px" color="#ff626fff">
        Ammo
      </Box>
    ),
    materials: (
      <Box inline mr="6px" ml="6px" color="#7FFFD4">
        Materials
      </Box>
    ),
    explosive: (
      <Box inline mr="6px" ml="6px" color="#FF7F50">
        Explosives
      </Box>
    ),
    other: (
      <Box inline mr="6px" ml="6px" color="#BA55D3">
        Other
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
