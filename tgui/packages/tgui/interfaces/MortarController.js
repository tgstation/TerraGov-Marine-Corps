import { useBackend, useLocalState } from '../backend';
import { Knob, Button, NumberInput } from '../components';
import { Window } from '../layouts';


export const MortarController = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { x, y, z } = data;

  const [xCoord, setXCoord] = useLocalState(context, 'xCoord', 0);
  const [yCoord, setYCoord] = useLocalState(context, 'yCoord', 0);
  const [zCoord, setZCoord] = useLocalState(context, 'zCoord', 0);

  return (
    <Window resizable>
      <div>
        X: <NumberInput
              inline
              value={xCoord}
              minValue={-100}
              maxValue={100}
              onChange={(e, value) => setXCoord(value)} />
      </div>
      <div>
        Y: <NumberInput
              inline
              value={yCoord}
              minValue={-100}
              maxValue={100}
              onDrag={(e, value) => setYCoord(value)} />
      </div>

      <Button onClick={() => act('send')}>Send</Button>
    </Window>
  );
};