import { useBackend } from '../../backend';
import { Button, Input, LabeledList } from '../../components';

export const TextFieldPreference = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    label,
    value,
    action,
    extra,
    onFocus,
    noAction,
  } = props;
  const itemLabel = label || value;

  const handler = noAction ? () => {} : act;

  return (
    <LabeledList.Item label={itemLabel}>
      <Input
        placeholder={data[value] || ''}
        value={data[value] || value}
        onChange={(e, newValue) =>
          !onFocus && handler(action || value, { newValue })}
      />
      {extra ? extra : null}
    </LabeledList.Item>
  );
};

export const SelectFieldPreference = (props, context) => {
  const { act, data, config } = useBackend(context);
  const {
    label,
    value,
    action,
  } = props;
  const itemLabel = label || value;

  return (
    <LabeledList.Item label={itemLabel}>
      <Button
        content={data[value]}
        onClick={() => act(action)}
      />
    </LabeledList.Item>
  );
};

export const ToggleFieldPreference = (props, context) => {
  const { act, data } = useBackend(context);
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


export const LoopingSelectionPreference = (props, context) => {
  const { act } = useBackend<PlayerPreferencesData>(context);
  const {
    label,
    value,
    action,
  } = props;

  return (
    <LabeledList.Item label={label}>
      <Button
        inline
        content={value}
        onClick={() => act(action)}
      />
    </LabeledList.Item>
  );
};
