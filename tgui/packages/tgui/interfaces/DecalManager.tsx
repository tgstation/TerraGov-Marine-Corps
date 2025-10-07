import { useState } from 'react';
import {
  Button,
  ImageButton,
  Input,
  LabeledList,
  Modal,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

const BUTTON_SIZE = 10;
enum SortType {
  name = 'Name',
  creator = 'Creator',
  favourites = 'Favourites',
  tags = 'Tags',
  md5 = 'MD5',
}

type DecalManagerData = {
  favourite_decals: string[];
  ckey: string;
  decals?: Decal[];
  admin_mode: BooleanLike;
};

type Decal = {
  name: string;
  md5: string;
  creator_ckey: string;
  creation_date: string;
  creation_round_id: number;
  tags: string[];
  width: number;
  height: number;
  favourites: number;
};

type DecalEntryProps = {
  decal: Decal;
  setViewedDecal: React.Dispatch<React.SetStateAction<Decal | null>>;
};

export const DecalManager = (props) => {
  const { act, data } = useBackend<DecalManagerData>();
  const [deletingDecal, setdeletingDecal] = useState<Decal | null>(null);
  const [deletingReason, setdeletingReason] = useState('');

  const [viewedDecal, setViewedDecal] = useState<Decal | null>(null);
  const [search_string, setSearchString] = useState('');
  const [sortType, setSortType] = useState(SortType.favourites);
  const { admin_mode, ckey, favourite_decals } = data;
  const filteredDecals = data.decals
    ?.filter((decal) =>
      decal.name.toLowerCase().includes(search_string.toLowerCase()),
    )
    ?.sort((a, b) => {
      const aIsFavourite = favourite_decals.includes(a.md5);
      const bIsFavourite = favourite_decals.includes(b.md5);

      if (aIsFavourite !== bIsFavourite) {
        return aIsFavourite ? -1 : 1;
      }

      switch (sortType) {
        case SortType.name:
          return a.name.localeCompare(b.name);
        case SortType.creator:
          return a.creator_ckey.localeCompare(b.creator_ckey);
        case SortType.favourites:
          return b.favourites - a.favourites;
        case SortType.tags:
          return a.tags.length - b.tags.length;
        case SortType.md5:
          return a.md5.localeCompare(b.md5);
        default:
          return 0;
      }
    });
  return (
    <Window width={600} height={600}>
      <Window.Content>
        {admin_mode && deletingDecal && (
          <Modal>
            <TextArea
              fluid
              value={deletingReason}
              placeholder="You must provide a reason to delete this decal"
              onChange={(value) => setdeletingReason(value)}
            />
            <Stack>
              <Button
                color="green"
                fluid
                onClick={() => {
                  setdeletingDecal(null);
                  setdeletingReason('');
                }}
              >
                Cancel
              </Button>
              <Button
                color="red"
                icon="trash"
                tooltip="Permanently admin-delete this decal"
                onClick={() => {
                  act('delete_decal', {
                    md5: deletingDecal.md5,
                    reason: deletingReason,
                  });
                  setdeletingDecal(null);
                  setdeletingReason('');
                }}
              >
                DELETE PERMANENTLY
              </Button>
              <Button
                color="green"
                fluid
                onClick={() => {
                  setdeletingDecal(null);
                  setdeletingReason('');
                }}
              >
                Cancel
              </Button>
            </Stack>
          </Modal>
        )}
        {viewedDecal && (
          <Modal>
            <Section
              title={viewedDecal.name}
              buttons={
                <>
                  {(admin_mode || viewedDecal.creator_ckey === ckey) && (
                    <Input
                      placeholder="Rename this decal"
                      onBlur={(input) => {
                        act('rename_decal', {
                          md5: viewedDecal.md5,
                          new_name: input,
                        });
                      }}
                    />
                  )}
                  {admin_mode && (
                    <Button
                      color="danger"
                      icon="trash"
                      tooltip="Permanently admin-delete this decal"
                      onClick={() => {
                        setdeletingDecal(viewedDecal);
                        setViewedDecal(null);
                      }}
                    />
                  )}
                  <Button
                    color="red"
                    icon="x"
                    onClick={() => setViewedDecal(null)}
                  />
                </>
              }
            >
              <Stack>
                <Stack.Item>
                  <ImageButton
                    width={BUTTON_SIZE}
                    height={BUTTON_SIZE}
                    imageSize={BUTTON_SIZE * 11}
                    imageSrc={resolveAsset(`decal_${viewedDecal.md5}.png`)}
                    buttons={
                      <Button
                        icon="star"
                        selected={favourite_decals.includes(viewedDecal.md5)}
                        iconColor="yellow"
                        tooltip="Favourite this decal"
                        color="transparent"
                        onClick={() =>
                          act('toggle_favourite', { md5: viewedDecal.md5 })
                        }
                      />
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item
                      label="Created By"
                      tooltip="Ckey of the user who drew the decal"
                    >
                      {viewedDecal.creator_ckey}
                    </LabeledList.Item>

                    <LabeledList.Item
                      label="Created at"
                      tooltip={'Round ID: ' + viewedDecal.creation_round_id}
                    >
                      {viewedDecal.creation_date}
                    </LabeledList.Item>
                    <LabeledList.Item label="Favourites">
                      {viewedDecal.favourites}
                    </LabeledList.Item>
                    <LabeledList.Item label="Tags">
                      {viewedDecal.tags.length > 0
                        ? viewedDecal.tags.join(', ')
                        : 'None'}
                    </LabeledList.Item>
                    <LabeledList.Item label="Size">
                      {viewedDecal.width} x {viewedDecal.height}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="MD5"
                      tooltip="Unique MD5 hash identifier"
                    >
                      <Button
                        onClick={() => {
                          navigator.clipboard.writeText(viewedDecal.md5);
                        }}
                        tooltip={viewedDecal.md5}
                      >
                        Copy to clipboard
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Modal>
        )}
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Input
                fluid
                placeholder="Search Decals..."
                value={search_string}
                onChange={(value) => {
                  setSearchString(value);
                }}
              />
              <Button onClick={() => act('new_decal')}>Draw New Decal</Button>
              <Button
                icon="sort"
                onClick={() => {
                  const sortValues = Object.values(SortType);
                  const currentIndex = sortValues.indexOf(sortType);
                  const nextIndex = (currentIndex + 1) % sortValues.length;
                  setSortType(sortValues[nextIndex]);
                }}
              >
                {sortType}
              </Button>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            {filteredDecals?.map((slot, index) => (
              <DecalEntry
                key={index}
                decal={slot}
                setViewedDecal={setViewedDecal}
              />
            ))}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

function DecalEntry(props: DecalEntryProps) {
  const { decal, setViewedDecal } = props;
  const { act, data } = useBackend<DecalManagerData>();
  return (
    <ImageButton
      width={BUTTON_SIZE}
      height={BUTTON_SIZE}
      imageSize={BUTTON_SIZE * 11}
      imageSrc={resolveAsset(`decal_${decal.md5}.png`)}
      onClick={() => setViewedDecal(decal)}
      tooltip={decal.name}
      buttons={
        <Stack>
          <Button
            icon="star"
            className={
              !data.favourite_decals.includes(decal.md5)
                ? 'DecalManager__favouritecount'
                : null
            }
            selected={data.favourite_decals.includes(decal.md5)}
            iconColor="yellow"
            tooltip="Favourite this decal"
            color="transparent"
            onClick={() => act('toggle_favourite', { md5: decal.md5 })}
          >
            {decal.favourites}
          </Button>
        </Stack>
      }
    />
  );
}
