<template>
  <v-layout row wrap>
    <v-flex xs12 sm12 md12>
      <v-layout row wrap>
        <v-flex xs12 sm12 md12 mb-1>
          <div class="headline">
            {{ $t('common.listModel', { model: $t('models.attachment') }) }}
          </div>
        </v-flex>
      </v-layout>
    </v-flex>

    <v-flex v-if="processing" xs12 sm12 md12>
      <v-progress-linear v-model="processValue" />
    </v-flex>

    <v-flex v-if="!processing" xs12 sm12 md12>
      <v-layout row wrap>
        <v-flex xs12 sm12 md12 mb-1>
          <v-layout justify-end>
            <v-dialog v-model="createDirectoryDialog" persistent>
              <template v-slot:activator="{ on }">
                <v-btn v-on="on">
                  {{ $t('pages.attachments.index.createDirectory') }}
                </v-btn>
              </template>
              <v-card>
                <v-card-title>
                  <span class="headline">
                    {{ $t('pages.attachments.index.createDirectory') }}
                  </span>
                </v-card-title>
                <v-card-text>
                  <v-container grid-list-md>
                    <v-layout wrap>
                      <v-flex xs12 sm12 md12>
                        <v-text-field
                          v-model="createDirectoryName"
                          v-validate="'required'"
                          :label="$t('pages.attachments.index.directoryName')"
                          :error-messages="
                            errors.collect('createDirectoryName')
                          "
                          :data-vv-as="
                            $t('pages.attachments.index.directoryName')
                          "
                          :data-vv-name="'createDirectoryName'"
                          required
                        />
                      </v-flex>
                    </v-layout>
                  </v-container>
                </v-card-text>
                <v-card-actions>
                  <v-spacer />
                  <v-btn @click="createDirectory()">
                    {{ $t('common.new') }}
                  </v-btn>
                  <v-btn @click="createDirectoryDialogClose()">
                    {{ $t('common.close') }}
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-layout>
        </v-flex>
        <v-flex xs12 sm12 md12>
          <v-layout row wrap>
            <v-flex xs12 sm12 md12 mb-1>
              <v-breadcrumbs :items="pathBreadcrumbItems" />
            </v-flex>
          </v-layout>
        </v-flex>
        <v-flex xs12 sm12 md12>
          <v-data-table
            :headers="attachmentHeaders"
            :items="attachments"
            :loading="attachmentLoading"
            hide-actions
          >
            <template slot="items" slot-scope="props">
              <td>
                <template v-if="props.item.type === 'directory'">
                  <div @dblclick="openDirectory(props.item)">
                    <v-icon small>
                      fas fa-folder
                    </v-icon>
                    {{ props.item.name }}
                  </div>
                </template>
                <template v-if="props.item.type === 'file'">
                  <div @dblclick="openFile(props.item)">
                    <v-icon small>
                      fas fa-file
                    </v-icon>
                    {{ props.item.name }}
                  </div>
                </template>
              </td>
              <td>{{ props.item.size }}</td>
              <td>{{ props.item.createdAt | datetime }}</td>
              <td>{{ props.item.updatedAt | datetime }}</td>
              <td>
                <v-layout justify-center>
                  <template v-if="props.item.type === 'file'">
                    <v-icon
                      small
                      class="mr-1"
                      @click="downloadFile(props.item)"
                    >
                      fas fa-download
                    </v-icon>
                    <v-icon
                      small
                      class="mr-1"
                      color="error"
                      @click="deleteAttachment(props.item)"
                    >
                      fas fa-trash-alt
                    </v-icon>
                  </template>
                  <template v-if="props.item.type === 'directory'">
                    <v-icon
                      small
                      class="mr-1"
                      color="error"
                      @click="deleteAttachment(props.item)"
                    >
                      fas fa-trash-alt
                    </v-icon>
                  </template>
                </v-layout>
              </td>
            </template>
          </v-data-table>
        </v-flex>
      </v-layout>
    </v-flex>
  </v-layout>
</template>

<script>
export default {
  data() {
    return {
      attachmentHeaders: [
        {
          text: this.$i18n.t('models.attributes.attachment.name'),
          value: 'sortName'
        },
        {
          text: this.$i18n.t('models.attributes.attachment.size'),
          value: 'size'
        },
        {
          text: this.$i18n.t('models.attributes.attachment.createdAt'),
          value: 'createdAt'
        },
        {
          text: this.$i18n.t('models.attributes.attachment.updatedAt'),
          value: 'updatedAt'
        },
        { text: '', sortable: false }
      ],
      attachments: [],
      attachmentLoading: true,
      processing: false,
      processValue: 0,
      createDirectoryDialog: false,
      createDirectoryName: ''
    }
  },
  computed: {
    path() {
      return this.$route.path
    },
    query() {
      return this.$route.query
    },
    pathBreadcrumbItems() {
      let currentQueryPath = this.query.path
      if (!currentQueryPath) {
        currentQueryPath = '/'
      }
      let queryPath = '/'

      const items = [
        {
          text: this.$i18n.t('common.root'),
          to: { path: '/attachments', query: { path: queryPath } },
          exact: true,
          disabled: false
        }
      ]
      currentQueryPath.split('/').forEach(value => {
        if (value !== '') {
          queryPath += queryPath === '/' ? value : `/${value}`
          items.push({
            text: value,
            to: { path: '/attachments', query: { path: queryPath } },
            exact: true,
            disabled: false
          })
        }
      })
      items[items.length - 1].disabled = true
      return items
    }
  },
  watch: {
    query() {
      this.getAttachments()
    }
  },
  mounted() {
    this.getAttachments()
  },
  methods: {
    async getAttachments() {
      this.attachmentLoading = true
      const params = { path: this.query.path }
      await this.$store.dispatch('attachments/getAttachments', {
        params: params
      })
      this.attachments = this.$store.getters['attachments/attachments']
      this.attachmentLoading = false
    },
    createDirectory() {
      this.$validator.validateAll().then(async result => {
        if (result) {
          this.createDirectoryDialog = false
          this.processing = true
          this.processValue = 0

          let path = ''
          if (this.path || this.path === '') {
            path = `/${this.createDirectoryName}`
          } else {
            path = `${this.path}/${this.createDirectoryName}`
          }

          await this.$store.dispatch('attachments/createDirectory', {
            params: { path: path }
          })

          if (this.$store.getters['attachments/createdDirectory']) {
            const message = this.$t('messages.createDirectory')
            this.$toast.success(message)
          } else {
            const message = this.$t('messages.errorOccurred')
            this.$toast.error(message)
          }

          this.processValue = 100
          this.processing = false
          this.createDirectoryName = ''
          this.$validator.reset()

          this.getAttachments()
        }
      })
    },
    createDirectoryDialogClose() {
      this.createDirectoryDialog = false
      this.createDirectoryName = ''
      this.$validator.reset()
    },
    openDirectory(attachment) {
      this.$router.push({
        path: '/attachments',
        query: { path: attachment.path }
      })
    },
    openFile(attachment) {
      window.open(attachment.url, '_blank')
    },
    downloadFile(attachment) {
      const link = document.createElement('a')
      link.href = attachment.downloadUrl
      link.download = attachment.name
      link.click()
    },
    async deleteAttachment(attachment) {
      if (confirm(this.$t('messages.destroyConfirm'))) {
        this.processing = true
        this.processValue = 0

        await this.$store.dispatch('attachments/delete', {
          params: { path: attachment.path }
        })

        if (this.$store.getters['attachments/deleted']) {
          const message = this.$t('messages.deleted')
          this.$toast.success(message)
        } else {
          const message = this.$t('messages.errorOccurred')
          this.$toast.error(message)
        }

        this.processValue = 100
        this.processing = false

        this.getAttachments()
      }
    }
  }
}
</script>
