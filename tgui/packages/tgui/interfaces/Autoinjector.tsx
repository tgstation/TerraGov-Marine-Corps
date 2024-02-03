import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { Window } from '../layouts';

type Data = {
  InjectMode: BooleanLike;
  CurrentLabel: string;
  CurrentTag: string;
  TransferAmount: number;
};

export const Autoinjector = (props) => {
  const { act, data } = useBackend<Data>();
  const { InjectMode, CurrentLabel, CurrentTag, TransferAmount } = data;
  return (
    <Window width={400} height={260}>
      <Box>
        <Button m={2} onClick={() => act('ActivateAutolabeler')}>
          Activate Autolabeler
        </Button>
        <b>CURRENT LABEL: </b>
        {CurrentLabel}
        <br />
        <Button m={2} onClick={() => act('ActivateTagger')}>
          ActivateTagger
        </Button>
        <b>CURRENT TAG: </b>
        {CurrentTag}
        <br />
        <Button m={2} onClick={() => act('ToggleMode')}>
          Toggle Mode
        </Button>
        <b>CURRENT MODE: </b>
        {InjectMode ? 'Injecting' : 'Drawing'}
        <br />
        <Button m={2} onClick={() => act('SetTransferAmount')}>
          Set Transfer Amount
        </Button>
        <b>CURRENT TRANSFER AMOUNT: </b>
        {TransferAmount}
        <br />
        <Button color={'red'} m={2} onClick={() => act('EmptyHypospray')}>
          Empty Hypospray
        </Button>
      </Box>
    </Window>
  );
};
