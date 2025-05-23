import { Box, Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  InjectMode: BooleanLike;
  CurrentLabel: string;
  CurrentTag: string;
  TransferAmount: number;
  IsAdvanced: boolean;
};

export const Hypospray = (props) => {
  const { act, data } = useBackend<Data>();
  const { InjectMode, CurrentLabel, CurrentTag, TransferAmount, IsAdvanced } =
    data;
  return (
    <Window width={300} height={375}>
      <Section fill>
        <Box>
          <Button m={2} onClick={() => act('ActivateAutolabeler')}>
            Activate Autolabeler
          </Button>
          <Box ml={2}>
            <b>Current label: </b>
            {CurrentLabel}
          </Box>
          <Button m={2} onClick={() => act('ActivateTagger')}>
            Activate Tagger
          </Button>
          <Box ml={2}>
            <b>Current tag: </b>
            {CurrentTag}
          </Box>
          <Button m={2} onClick={() => act('ToggleMode')}>
            Toggle Mode
          </Button>
          <Box ml={2}>
            <b>Current mode: </b>
            {InjectMode ? 'Injecting' : 'Drawing'}
          </Box>
          <Button m={2} onClick={() => act('SetTransferAmount')}>
            Set Transfer Amount
          </Button>
          <Box ml={2}>
            <b>Current transfer amount: </b>
            {TransferAmount}
          </Box>
          {IsAdvanced ? (
            <Box>
              <Button m={2} onClick={() => act('DisplayReagentContent')}>
                Display Reagent Content
              </Button>
            </Box>
          ) : (
            <Box />
          )}
          <Button color={'red'} m={2} onClick={() => act('EmptyHypospray')}>
            Empty Hypospray
          </Button>
        </Box>
      </Section>
    </Window>
  );
};
