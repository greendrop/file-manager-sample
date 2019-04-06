import qs from 'qs'
import apiUrl from '~/lib/api-url'
import changeCaseObject from '~/lib/change-case-object'

export const state = () => ({
  attachments: [],
  errorStatus: null,
  errorData: null,
  createdDirectory: false,
  deleted: false
})

export const actions = {
  async getAttachments({ commit }, { params = {} }) {
    const url = `${apiUrl.getApiBaseUrl()}/api/v1/files/list`
    await this.$axios
      .get(url, {
        params: changeCaseObject.snakeCase(params),
        paramsSerializer: function(params) {
          return qs.stringify(params, { arrayFormat: 'brackets' })
        }
      })
      .then(response => {
        commit('setAttachments', changeCaseObject.camelCase(response.data))
        commit('setErrorStatus', null)
        commit('setErrorData', null)
      })
      .catch(error => {
        commit('setAttachments', [])
        commit('setErrorStatus', error.response.status)
        commit('setErrorData', changeCaseObject.camelCase(error.response.data))
      })
  },
  async createDirectory({ commit }, { params = {} }) {
    const url = `${apiUrl.getApiBaseUrl()}/api/v1/files/create_directory`
    await this.$axios
      .post(url, params)
      .then(() => {
        commit('setCreatedDirectory', true)
        commit('setErrorStatus', null)
        commit('setErrorData', null)
      })
      .catch(error => {
        commit('setCreatedDirectory', false)
        commit('setErrorStatus', error.response.errorStatus)
        commit('setErrorData', error.response.errorData)
      })
  },
  async delete({ commit }, { params = {} }) {
    const url = `${apiUrl.getApiBaseUrl()}/api/v1/files/delete`
    await this.$axios
      .post(url, params)
      .then(() => {
        commit('setDeleted', true)
        commit('setErrorStatus', null)
        commit('setErrorData', null)
      })
      .catch(error => {
        commit('setDeleted', false)
        commit('setErrorStatus', error.response.errorStatus)
        commit('setErrorData', error.response.errorData)
      })
  }
}

export const mutations = {
  setAttachments(state, data) {
    state.attachments = data
  },
  setErrorStatus(state, data) {
    state.errorStatus = data
  },
  setErrorData(state, data) {
    state.errorData = data
  },
  setCreatedDirectory(state, data) {
    state.createdDirectory = data
  },
  setDeleted(state, data) {
    state.deleted = data
  }
}

export const getters = {
  attachments(state) {
    return state.attachments
  },
  errorStatus(state) {
    return state.errorStatus
  },
  errorData(state) {
    return state.errorData
  },
  createdDirectory(state) {
    return state.createdDirectory
  },
  deleted(state) {
    return state.deleted
  }
}
