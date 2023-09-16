import { CampaignData,} from './index';
import { useBackend } from '../../backend';

export const CampaignOverview = (props, context) => {
  const { act, data } = useBackend<CampaignData>(context);
  return (
    );
};
