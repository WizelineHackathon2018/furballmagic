# Description:
#   knowbe4 training
#
# Dependencies:
#   request
#   request-promise-native
#
# Configuration:
#   None
#
# Commands:
#
#
# Author:
#   maligno
knowbe4 = require '../lib/knowbe4'
formatter = require '../lib/knowbe4ResponseFormatter'

module.exports.groups = () ->
  knowbe4.groups()

module.exports.campaignstatus = (parameters) ->
  knowbe4.status()
  .then (apiResponse) ->
    console.log apiResponse
    apiResponse
  .catch (error) ->
    console.error 'error getting the group data', error
    console.error  'knowbe4 servers are having the hiccups'

module.exports.completed = (parameters) ->
  throw 'please specify project' unless parameters.entityName?
  knowbe4.completed(parameters)
  .then (statusList) ->
    console.log 'got the status list', statusList
    statusList
  .catch (error) ->
    robot.logger.error 'error getting the group data',  error
    response.reply  'knowbe4 servers are having the hiccups'

module.exports.teammembers = (parameters) ->
  knowbe4.teammembers(parameters)
  .then (list) ->
    console.log list
    list
  .catch (error) ->
    console.error 'error getting the group data', error
    console.error  'knowbe4 servers are having the hiccups'
