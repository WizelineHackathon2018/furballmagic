class webappDashboard extends Polymer.Element
  is: ->
    return 'webapp-dashboard'
  constructor: ->
    super()

customElements.define webappDashboard.is, webappDashboard
