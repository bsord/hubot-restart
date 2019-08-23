# Description:
#   Restarts the hubot.service and/or reboots the server
#
# Dependencies:
#   None
#
# Configuration:
#   defaultChannel
#   respDefaultHello
#
# Commands:
#   hubot restart - restarts the hubot service via systemd call via shell
#   hubot reboot - reboots the server via shell call
#
# Notes:
#   Need hubot setup as a service and set to start automatically
#   sudoers file needs to allow the account the service is running under to call reboot without password
#   preferred to set /etc/redis/redis.conf : 'appendonly' set to yes, and 'appendfsync' set to 'always'
#
# Author:
#   Brandon Sorgdrager
#

respDefaultHello = 'Im back online'

module.exports = (robot) ->

  robot.brain.on 'connected', ->
    #debug output on module load
    console.log("LastChannel: " + robot.brain.get('lastChannel'))
    console.log("LastId: " + robot.brain.get('lastId'))

    # Check if lastChannel defined and modify response on start up
    lastChannel = robot.brain.get('lastChannel')
    lastId = robot.brain.get('lastId')

    if lastChannel == null
      #robot.adapter.client.web.chat.postMessage(defaultChannel, respDefaultHello, {as_user: true} )
    else
      robot.adapter.client.web.reactions.remove('stopwatch', {channel: lastChannel, timestamp: lastId})
      robot.adapter.client.web.reactions.add('white_check_mark', {channel: lastChannel, timestamp: lastId})
      robot.brain.set('lastChannel', null)
      robot.brain.set('lastId', null)


  robot.respond /reboot/i, (msg) ->
    # Check Auth
    if(msg.message.user.slack.is_admin != true)
      msg.send('You don\'t have permission to do that. :closed_lock_with_key:')
    else
      #Set brain
      robot.brain.set('lastChannel', msg.message.room)
      robot.brain.set('lastId', msg.message.id)

      #Send confirmation
      robot.adapter.client.web.reactions.add('stopwatch', {channel: msg.message.room, timestamp: msg.message.id})

      #Exit the process (some external process monitor required to restart process.)
      process.exit 0

  robot.respond /restart/i, (msg) ->
    # Check Auth
    if(msg.message.user.slack.is_admin != true)
      msg.send('You don\'t have permission to do that. :closed_lock_with_key:')
    else
      #Set brain
      robot.brain.set('lastChannel', msg.message.room)
      robot.brain.set('lastId', msg.message.id)

      #Send confirmation
      robot.adapter.client.web.reactions.add('stopwatch', {channel: msg.message.room, timestamp: msg.message.id})

      #Actually reboot
      @exec = require('child_process').exec
      command = "sleep 5; sudo /bin/systemctl restart hubot.service"
      @exec command, (error, stdout, stderr) ->
        msg.send error
        msg.send stdout
        msg.send stderr
