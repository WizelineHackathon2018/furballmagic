googleapis = require './googleAPIClients'
request = require 'request-promise-native'
csv = require 'csvtojson'


module.exports.readFileAsCSV = (fileId) ->
  drive = googleapis.drive()
  drive.files.export({'fileId': fileId, 'mimeType': 'text/csv'})
  .then (file) ->
    throw 'error no csv' unless file.data?
    csv().fromString(file.data)
  .catch (error) ->
    console.log 'error', error
