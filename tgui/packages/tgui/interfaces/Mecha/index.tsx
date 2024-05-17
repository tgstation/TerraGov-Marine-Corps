import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { MainData } from './data';
import { OperatorMode } from './OperatorMode';

export const Mecha = (props) => {
  const { data } = useBackend<MainData>();
  if (data.isoperator) {
    return (
      <Window theme={'ntos'} width={1240} height={670}>
        <Window.Content>
          <OperatorMode />
        </Window.Content>
      </Window>
    );
  }
};
