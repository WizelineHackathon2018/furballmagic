googleapis = require 'googleapis'
path = require 'path'
fs = require 'fs'

SCOPE = 'https://www.googleapis.com/auth/drive'
SERVICE_ACCOUNT_KEY_FILE =
  process.env.GKEY_PATH or path.join __dirname, './bishop-38a558e04dc4.json'

keyJSON = { redirect_uris: [''] }
if fs.existsSync(SERVICE_ACCOUNT_KEY_FILE)
  console.log 'keyfile exists'
  keyJSON = require(SERVICE_ACCOUNT_KEY_FILE)
# Follows JWT authorization server - server with a service account
# https://github.com/google/google-auth-library-nodejs#json-web-tokens
#
JWTAuthClient = new googleapis.google.auth.JWT(
  keyJSON.client_email,
  null,
  keyJSON.private_key,
  [SCOPE])

module.exports.drive = ->
  googleapis.google.drive({version: 'v3', auth: JWTAuthClient})
