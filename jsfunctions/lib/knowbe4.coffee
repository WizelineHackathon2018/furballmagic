request = require 'request-promise-native'
util = require 'util'
gdriveCSV = require './gdriveCSV'
formatter = require './knowbe4ResponseFormatter'


fileId = '1OTCldODGaUsRfId3JZcfxMmCXNUAAt9PmPNRZeDBGCU'

_buildHeaders = () ->
  'Authorization': "Bearer #{process.env.KNOWBE4_API_TOKEN}"

module.exports.groups = () ->
  console.log _buildHeaders()
  request
    uri: 'https://us.api.knowbe4.com/v1/groups'
    headers: _buildHeaders()
    json: true
  .then (groupsList) ->
    groupsList
  .catch (error) ->
    console.error error

module.exports.status = () ->
  data = {}
  request
    uri: 'https://us.api.knowbe4.com/v1/groups/588463'
    headers: _buildHeaders()
    json: true
  .then (completedGroupData) ->
    data.completed = completedGroupData
    request
      uri: 'https://us.api.knowbe4.com/v1/groups/585783'
      headers: _buildHeaders()
      json: true
  .then (allMembersGroup) ->
    data.all = allMembersGroup
    data
  .catch (error) ->
    console.error error

module.exports.formatAsStatus = (apiResponse) ->
  formatter.formatStatusMsg(apiResponse)

module.exports.completed = (parameters) ->
  statusList =
    completed: []
    noCompleted: []
  usersInKnowbe4Group = []
  request
    uri: 'https://us.api.knowbe4.com/v1/groups/588463/members'
    headers:
      'Authorization': "Bearer #{process.env.KNOWBE4_API_TOKEN}"
    json: true
  .then (apiResponse) ->
    usersInKnowbe4Group = apiResponse
    gdriveCSV.readFileAsCSV(fileId)
  .then (gdriveResponse) ->
    unless parameters.accountOrProject is 'account' or
      parameters.accountOrProject is 'project'
        throw 'not matching account or project'
    #
    # if this is an account, the obj key is Account
    # if this is project, the obj key is project
    # TODO: maybe there is a better way, like uppercase the first letter
    #
    key = 'Project'
    if parameters.accountOrProject is 'account'
      key = 'Account'
    for person in gdriveResponse
      skip = false
      continue unless parameters.entityName.toLowerCase() is
        person["#{key}"].toLowerCase()

      for anotherPerson in usersInKnowbe4Group
        continue unless person.Email is anotherPerson.email
        statusList.completed.push person
        skip = true

      statusList.noCompleted.push person unless skip
      skip = false

    statusList

module.exports.formatAsCompletedStatus = (statusList, parameters) ->
  formatter.formatCompletedTrainingMsg(statusList, parameters)

module.exports.teammembers = (parameters) ->
  list = []
  unless parameters.accountOrProject is 'account' or
    parameters.accountOrProject is 'project'
      throw 'not matching account or project'
  key = 'Project'
  if parameters.accountOrProject is 'account'
    key = 'Account'
  gdriveCSV.readFileAsCSV(fileId)
  .then (gdriveResponse) ->
    for person in gdriveResponse
      continue unless parameters.entityName.toLowerCase() is
        person["#{key}"].toLowerCase()
      list.push person
    list

module.exports.formatAsTeamList = (list, parameters) ->
  formatter.formatTeamListMsg(list, parameters)
