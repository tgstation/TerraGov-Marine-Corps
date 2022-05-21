export type ResearchData =
{
  acquired_points: number,
  anchored: boolean,
  researching: boolean,
  init_resource: ResearchResource,
}

export type ResearchResource =
{
  name: string,
  colour: string,
  icon: string,
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
