JiraAPI = require 'jira-client'

module.exports = (robot) ->

  robot.on 'security.jira.issuestatus', (response) ->

    response.reply 'Jira API said: you find it!'
