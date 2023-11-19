import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

type ShuttleComputerData = {
  confirm_message?: string;
  shuttle_status: string;
  destinations: Destination[];
};

type Destination = {
  id: string;
  name: string;
  description: string;
};

export const ShuttleComputer = (props, context) => {
  const { act, data } = useBackend<ShuttleComputerData>(context);
  const { confirm_message, shuttle_status, destinations } = data;
};
