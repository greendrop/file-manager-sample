import qs from 'qs'
import apiUrl from '~/lib/api-url'
import changeCaseObject from '~/lib/change-case-object'

export const state = () => ({
  attachments: [],
  errorStatus: null,
  errorData: null
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
  }
}
