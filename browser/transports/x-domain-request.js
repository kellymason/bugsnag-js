const makePayload = require('./lib/payload')
const jsonStringify = require('@bugsnag/safe-json-stringify')
const { isoDate } = require('../../base/lib/es-utils')

module.exports = {
  sendReport: (logger, config, report, cb = () => {}) => {
    const url = getApiUrl(config, 'notify')
    const req = new window.XDomainRequest()
    req.onload = function () {
      cb(null, req.responseText)
    }
    req.open('POST', url)
    setTimeout(() => {
      try {
        req.send(makePayload(report))
      } catch (e) {
        logger.error(e)
      }
    }, 0)
  },
  sendSession: (logger, config, session, cb = () => {}) => {
    const url = getApiUrl(config, 'sessions')
    const req = new window.XDomainRequest()
    req.onload = function () {
      cb(null, req.responseText)
    }
    req.open('POST', url)
    setTimeout(() => {
      try {
        req.send(jsonStringify(session))
      } catch (e) {
        logger.error(e)
      }
    }, 0)
  }
}

const getApiUrl = (config, endpoint) =>
  `${matchPageProtocol(config.endpoints[endpoint], window.location.protocol)}?apiKey=${encodeURIComponent(config.apiKey)}&payloadVersion=1.0&sentAt=${encodeURIComponent(isoDate())}`

const matchPageProtocol = module.exports._matchPageProtocol = (endpoint, pageProtocol) =>
  pageProtocol === 'http:'
    ? endpoint.replace(/^https:/, 'http:')
    : endpoint
