import { useBackend } from '../backend';
import { Button, Stack, Collapsible } from '../components';
import { Window } from '../layouts';

export const StaffWho = (props, context) => {
  const { data } = useBackend(context);
  const { admin, administrators } = data;

  return (
    <Window resizable width={600} height={600}>
      <Window.Content scrollable>
        {administrators !== undefined ? (
          <Stack fill vertical>
            <Stack.Item mt={0.2} grow>
              {administrators.map((x, index) => (
                <StaffWhoCollapsible
                  key={x.index}
                  title={x.category + ' - ' + x.category_administrators}
                  color={x.category_color}>
                  {x.admins.map((x, index) => (
                    <GetAdminInfo
                      key={x.index}
                      admin={admin}
                      content={x.content}
                      color={x.color}
                      text={x.text}
                    />
                  ))}
                </StaffWhoCollapsible>
              ))}
            </Stack.Item>
          </Stack>
        ) : null}
      </Window.Content>
    </Window>
  );
};

const StaffWhoCollapsible = (props, context) => {
  const { title, color, children } = props;
  return (
    <Collapsible title={title} color={color} open>
      {children}
    </Collapsible>
  );
};

const GetAdminInfo = (props, context) => {
  const { admin, content, color, text } = props;
  return admin ? (
    <Button
      color={'transparent'}
      style={{
        'border-color': color,
        'border-style': 'solid',
        'border-width': '1px',
        'color': color,
      }}
      tooltip={text}
      tooltipPosition="bottom-start">
      <b style={{ 'color': color }}>{content}</b>
    </Button>
  ) : (
    <Button
      color={'transparent'}
      style={{
        'border-color': '#2185d0',
        'border-style': 'solid',
        'border-width': '1px',
        'color': 'white',
      }}>
      {content}
    </Button>
  );
};
