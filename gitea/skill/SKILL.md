---
name: gitea
description: Manage Gitea repositories, issues, branches, and pull requests via the Gitea REST API.
---

# Gitea Skill
Manage Gitea repositories, issues, branches, and pull requests directly from OpenClaw.

## Setup
1. Log into your Gitea instance
2. Go to: User Settings → Applications → Generate New Token
3. Grant the token: **repository** (Read and Write), **issue** (Read and Write), **user** (Read)
4. Set environment variables:
   ```bash
   export GITEA_URL="http://your-gitea-host:3000"
   export GITEA_TOKEN="your-token-here"
   export GITEA_USER="openclaw-agent"
   export GITEA_REPO_OWNER="your-username-or-org"
   ```

## Usage
All commands use curl to hit the Gitea REST API. The base API path is `$GITEA_URL/api/v1`.

### List repositories
```bash
curl -s "$GITEA_URL/api/v1/repos/search?owner=$GITEA_REPO_OWNER" \
  -H "Authorization: token $GITEA_TOKEN" | jq '.data[] | {name, id, description}'
```

### List open issues in a repo
```bash
curl -s "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/issues?type=issues&state=open" \
  -H "Authorization: token $GITEA_TOKEN" | jq '.[] | {number, title, assignee: .assignee.login}'
```

### Create an issue
```bash
curl -s -X POST "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/issues" \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Issue title",
    "body": "Issue description",
    "assignees": ["openclaw-agent"]
  }' | jq '{number, title, html_url}'
```

### Close an issue
```bash
curl -s -X PATCH "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/issues/{index}" \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"state": "closed"}'
```

### Add a comment to an issue
```bash
curl -s -X POST "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/issues/{index}/comments" \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"body": "Your comment here"}'
```

### List branches in a repo
```bash
curl -s "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/branches" \
  -H "Authorization: token $GITEA_TOKEN" | jq '.[] | {name}'
```

### Create a branch
```bash
curl -s -X POST "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/branches" \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "new_branch_name": "agent/42/short-slug",
    "old_branch_name": "main"
  }'
```

### Delete a branch
```bash
curl -s -X DELETE "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/branches/{branch}" \
  -H "Authorization: token $GITEA_TOKEN"
```
Note: URL-encode `/` in branch names as `%2F` (e.g. `agent%2F42%2Fshort-slug`).

### List open pull requests
```bash
curl -s "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/pulls?state=open" \
  -H "Authorization: token $GITEA_TOKEN" | jq '.[] | {number, title, head: .head.label, state}'
```

### Create a pull request
```bash
curl -s -X POST "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/pulls" \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "PR title",
    "body": "Description of changes. Closes #42",
    "head": "agent/42/short-slug",
    "base": "main"
  }' | jq '{number, title, html_url}'
```

### Merge a pull request
```bash
curl -s -X POST "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/pulls/{index}/merge" \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "Do": "merge",
    "merge_message_field": "Merge PR title into main"
  }'
```

## Git Operations
For cloning and pushing, embed credentials in the URL:
```bash
# Clone a repo
git clone http://$GITEA_USER:$GITEA_TOKEN@${GITEA_URL#http://}/$GITEA_REPO_OWNER/{repo}.git

# Push a branch
git push -u origin {branch-name}
```

## Notes
- Replace `{repo}`, `{index}`, `{branch}` with actual values — these are placeholders
- Issue and PR `{index}` is the number shown in the Gitea UI (e.g. `#42`)
- `closes #42` in a PR body will auto-close the linked issue on merge
- All tokens provide API access — keep `GITEA_TOKEN` secret and out of version control
- Gitea API docs: `$GITEA_URL/api/swagger` on your own instance

## Examples
```bash
# Find a repo by name
curl -s "$GITEA_URL/api/v1/repos/search?q=my-project&owner=$GITEA_REPO_OWNER" \
  -H "Authorization: token $GITEA_TOKEN" | jq '.data[] | {name, html_url}'

# Get a single issue by number
curl -s "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/issues/42" \
  -H "Authorization: token $GITEA_TOKEN" | jq '{number, title, body, state}'

# List all issues assigned to the agent
curl -s "$GITEA_URL/api/v1/repos/$GITEA_REPO_OWNER/{repo}/issues?type=issues&state=open&assigned_by=openclaw-agent" \
  -H "Authorization: token $GITEA_TOKEN" | jq '.[] | {number, title}'
```