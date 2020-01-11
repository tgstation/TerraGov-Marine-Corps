workflow "auto-label merge conflicts" {
  on = "pull_request"
  resolves = ["Auto label merge conflicts"]
}

action "Auto label merge conflicts" {
  uses = "mschilde/auto-label-merge-conflicts@master"
  secrets = ["GITHUB_TOKEN"]
  env = {
    CONFLICT_LABEL_NAME = "Merge Conflict"
  }
}
