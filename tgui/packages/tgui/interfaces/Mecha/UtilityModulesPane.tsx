import { useBackend } from '../../backend';
import { Box, Button, Section, Tooltip } from '../../components';
import { MechaUtility, OperatorData } from './data';

const UtilityName = (props: { name: string }) => {
  const { name } = props;
  return (
    <Tooltip content={name} position="top">
      <span className="UtilityModulePane__UtilityName">{`${name}:`}</span>
    </Tooltip>
  );
};

type EquipmentProps = {
  module: MechaUtility;
};

const Equipment = (props: EquipmentProps) => {
  const { module } = props;
  const { act } = useBackend<OperatorData>();

  return (
    <div className="UtilityModulePane__Equipment">
      <UtilityName name={module.name} />
      <Button
        className="UtilityModulePane__Equipment__button"
        content={(module.activated ? 'En' : 'Dis') + 'abled'}
        onClick={() =>
          act('equip_act', {
            ref: module.ref,
            gear_action: 'toggle',
          })
        }
        selected={module.activated}
      />
      <Button
        className="UtilityModulePane__Equipment__button"
        content={'Detach'}
        onClick={() =>
          act('equip_act', {
            ref: module.ref,
            gear_action: 'detach',
          })
        }
      />
    </div>
  );
};

export const UtilityModulesPane = (props) => {
  const { data } = useBackend<OperatorData>();
  const { mech_equipment } = data;
  return (
    <Box style={{ height: '15rem' }}>
      <Section fill>
        <div>
          {mech_equipment['utility'].map((module, i) => {
            return module.snowflake.snowflake_id ? (
              <Snowflake module={module} />
            ) : (
              <Equipment module={module} />
            );
          })}
        </div>
      </Section>
    </Box>
  );
};

const MECHA_SNOWFLAKE_ID_EJECTOR = 'ejector_snowflake';

// Handles all the snowflake buttons and whatever
const Snowflake = (props: { module: MechaUtility }) => {
  const { snowflake } = props.module;
  switch (snowflake['snowflake_id']) {
    case MECHA_SNOWFLAKE_ID_EJECTOR:
      return <SnowflakeEjector module={props.module} />;
    default:
      return null;
  }
};

const SnowflakeEjector = (props: { module: MechaUtility }) => {
  const { act, data } = useBackend<OperatorData>();
  const { cargo } = props.module.snowflake;
  return (
    <>
      {cargo && cargo.length > 0 && <Box>Cargo</Box>}
      <Box style={{ marginLeft: '1rem' }}>
        {cargo.map((item) => (
          <div
            key={props.module.ref}
            className="UtilityModulePane__SnowflakeEjector__entry"
          >
            <UtilityName name={item.name} />
            <Button
              onClick={() =>
                act('equip_act', {
                  ref: props.module.ref,
                  cargoref: item.ref,
                  gear_action: 'eject',
                })
              }
            >
              {'Eject'}
            </Button>
          </div>
        ))}
      </Box>
    </>
  );
};
