#!/bin/sh -l

set -eu

SLACK_BOT_TOKEN="${1?Must provide slack bot token}"
SLACK_CHANNEL_ID="${2?Must provide slack channel ID}"
SLACK_MESSAGE_TS="${3?Must provide slack message timestamp}"
SLACK_PROMPT="${4?Must provide slack prompt}"

APP_ENDPOINT="${5?Must provide app endpoint}"
APP_ENVIRONMENT="${6?Must provide app environment}"
APP_NAME="${7?Must provide app name}"

COMMIT_MESSAGE_SUBJECT="${8?Must provide commit message subject}"
COMMITTER_NAME="${9?Must provide committer name}"
COMMIT_SHA="${10?Must provide commit sha}"
COMMIT_SHA_SHORT="$(echo "$COMMIT_SHA" | head -c 10)"


curl -X POST https://slack.com/api/chat.update \
  -H "Content-type: application/json; charset=utf-8" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  --data-binary @- << EOF
{
  "channel": "$SLACK_CHANNEL_ID",
  "ts": "$SLACK_MESSAGE_TS",
  "icon_emoji": ":github-actions:",
  "blocks": [
    {
      "block_id": "header",
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*<https://github.com/$GITHUB_REPOSITORY/actions|[$APP_NAME] deployed to $APP_ENVIRONMENT>* :rocket:"
      }
    },
    {
      "block_id": "prompt",
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*$SLACK_PROMPT*"
      }
    },
    {
      "block_id": "commit",
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Commit*: $COMMIT_MESSAGE_SUBJECT"
      }
    },
    {
      "block_id": "committer_name",
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Committer*: $COMMITTER_NAME"
      }
    },
    {
      "block_id": "commit_sha",
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Sha*: $COMMIT_SHA_SHORT (<https://github.com/$GITHUB_REPOSITORY/$COMMIT_SHA|Details>)"
      }
    },
    {
      "block_id": "divider_1",
      "type": "divider"
    },
    {
      "block_id": "post_deployment_actions",
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "View Endpoint :mag:",
            "emoji": true
          },
          "value": "view_endpoint",
          "url": "$APP_ENDPOINT"
        }
      ]
    }
  ]
}
EOF
