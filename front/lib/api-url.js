export default class {
  static getApiBaseUrl() {
    return process.server
      ? process.env.INTERNAL_API_BASE_URL
      : process.env.EXTERNAL_API_BASE_URL
  }
}
