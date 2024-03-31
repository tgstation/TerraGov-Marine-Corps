import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { MainData } from './data';
import { MaintMode } from './MaintMode';
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
  return (
    <Window theme={'retro'} width={640} height={670}>
      <Window.Content>
        <MaintMode />
      </Window.Content>
    </Window>
  );
};
