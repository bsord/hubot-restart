# hubot-reboot
Hubot commands to restart the hubot service or reboot the machine (if running locally)

## Installation

In your hubot project, run:

`npm install hubot-restart --save`

Then add **hubot-restart** to your `external-scripts.json`:

```json
[
  "hubot-restart"
]
```

## Dependencies

hubot-redis-brain

hubot must be registered as hubot.service

## Use - Restart Service

hubot restart

## Use - Reboot Host

hubot reboot 