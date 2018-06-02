module.exports.formatStatusMsg = (data) ->
  replyTxt = "#{data.name} head count is *#{data.member_count}* \n"
  if Math.floor(Math.random * 2) is 1
    replyTxt += ":face_with_rolling_eyes: what a bunch of slackers"
  replyTxt

module.exports.formatCompletedTrainingMsg = (statusList, parameters) ->
  allCount = statusList.completed.length + statusList.noCompleted.length
  replyTxt = "`#{parameters.entityName}` staff size is: `#{allCount}`" +
    " from which `#{statusList.completed.length}` have completed training \n"
  for entry in statusList.completed
    replyTxt += "*#{entry.Name}* \n"

  replyTxt += "and `#{statusList.noCompleted.length}` haven't \n"

  for entry in statusList.noCompleted
    replyTxt += "*#{entry.Name}* \n"

  return replyTxt

module.exports.formatTeamListMsg = (list, parameters) ->
  replyTxt = "`#{parameters.entityName}` staff size is: `#{list.length}`: \n"
  for entry in list
    replyTxt += "*#{entry.Name}* \n"
  return replyTxt
