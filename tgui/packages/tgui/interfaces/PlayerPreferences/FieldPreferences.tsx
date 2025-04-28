import { Button, Input, LabeledList } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const TextFieldPreference = (props) => {
  const { act, data } = useBackend<any>();
  const { label, value, action, extra, onFocus, noAction } = props;
  const itemLabel = label || value;

  const handler = noAction ? () => {} : act;

  return (
    <LabeledList.Item label={itemLabel}>
      <Input
        placeholder={data[value] || ''}
        value={data[value] || value}
        onChange={(e, newValue) =>
          !onFocus && handler(action || value, { newValue })
        }
      />
      {extra ? extra : null}
    </LabeledList.Item>
  );
};

export const SelectFieldPreference = (props) => {
  const { act, data, config } = useBackend<any>();
  const { label, value, action } = props;
  const itemLabel = label || value;

  return (
    <LabeledList.Item label={itemLabel}>
      <Button content={data[value]} onClick={() => act(action)} />
    </LabeledList.Item>
  );
};

export const ToggleFieldPreference = (props) => {
  const { act, data } = useBackend<any>();
  const {
    label,
    value,
    leftValue = 1,
    leftLabel = 'True',
    rightValue = 0,
    rightLabel = 'False',
    action,
  } = props;
  const itemLabel = label || value;

  let labelLeft = leftLabel || leftValue;
  let labelRight = rightLabel || rightValue;

  return (
    <LabeledList.Item label={itemLabel}>
      <Button.Checkbox
        inline
        content={labelLeft}
        checked={data[value] === leftValue}
        onClick={() => act(action)}
      />
      <Button.Checkbox
        inline
        content={labelRight}
        checked={data[value] === rightValue}
        onClick={() => act(action)}
      />
    </LabeledList.Item>
  );
};

export const LoopingSelectionPreference = (props) => {
  const { act } = useBackend<PlayerPreferencesData>();
  const { label, value, action } = props;

  return (
    <LabeledList.Item label={label}>
      <Button inline content={value} onClick={() => act(action)} />
    </LabeledList.Item>
  );
};
