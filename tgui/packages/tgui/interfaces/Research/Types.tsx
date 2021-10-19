export type ResearchData =
{
  anchored: boolean,
  researching: boolean,
  init_resource: ResearchResource,
}

export type ResearchResource =
{
  name: string,
  colour: string,
  rewards: RewardTier[],
}

export type RewardTier =
{
  type: string,
  probability: number,
  rewards_list: string[],
}

export type ResearchButtonData =
{
  act: Function,
}
