<template>
  <v-flex xs12 sm12 md12>
    <v-layout row wrap>
      <v-flex xs12 sm12 md12>
        <v-layout row wrap>
          <v-flex xs12 sm12 md12 mb-1>
            <v-breadcrumbs :items="pathBreadcrumbItems" />
          </v-flex>
        </v-layout>
      </v-flex>
      <v-flex
        xs12
        sm12
        md12
        @dragleave.prevent
        @dragover.prevent
        @drop.prevent="dropFiles"
      >
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
                  <v-icon small class="mr-1" @click="downloadFile(props.item)">
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
</template>

<script>
export default {
  props: {
    currentPath: {
      type: String,
      required: true
    },
    processing: {
      type: Boolean,
      required: true
    },
    processValue: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      localProcessing: false,
      localProcessValue: 0,
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
      attachmentLoading: true
    }
  },
  computed: {
    pathBreadcrumbItems() {
      let currentPath = this.currentPath
      if (!currentPath) {
        currentPath = '/'
      }
      let queryPath = '/'

      const items = [
        {
          text: this.$i18n.t('labels.root'),
          to: { path: '/attachments', query: { path: queryPath } },
          exact: true,
          disabled: false
        }
      ]
      currentPath.split('/').forEach(value => {
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
    processing: {
      handler(val, oldVal) {
        if (val !== oldVal) {
          this.localProcessing = val
        }
      }
    },
    processValue: {
      handler(val, oldVal) {
        if (val !== oldVal) {
          this.localProcessValue = val
        }
      }
    },
    localProcessing: {
      handler(val, oldVal) {
        if (val !== oldVal) {
          this.$emit('update:processing', val)
        }
      }
    },
    localProcessValue: {
      handler(val, oldVal) {
        if (val !== oldVal) {
          this.$emit('update:processValue', val)
        }
      }
    },
    currentPath() {
      this.getAttachments()
    }
  },
  mounted() {
    this.localProcessing = this.processing
    this.localProcessValue = this.processValue
    this.getAttachments()
  },
  created() {
    this.$nuxt.$on('AttachmentList/getAttachments', () => {
      this.getAttachments()
    })
  },
  methods: {
    async getAttachments() {
      this.attachmentLoading = true
      const params = { path: this.currentPath }
      await this.$store.dispatch('attachments/getAttachments', {
        params: params
      })
      this.attachments = this.$store.getters['attachments/attachments']
      this.attachmentLoading = false
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
        this.localProcessing = true
        this.localProcessValue = 0

        await this.$store.dispatch('attachments/delete', {
          params: { path: attachment.path }
        })

        if (this.$store.getters['attachments/deleted']) {
          const message = this.$t('messages.deleted')
          this.$toast.success(message)
        } else {
          const message = this.$t('messages.errorOccurred')
          this.$toast.error(message)
          this.$log.error(this.$store.getters['attachments/errorStatus'])
          this.$log.error(this.$store.getters['attachments/errorData'])
        }

        this.localProcessValue = 100
        this.localProcessing = false

        this.getAttachments()
      }
    },
    async dropFiles(event) {
      const files = []
      if (event.dataTransfer && event.dataTransfer.items) {
        const items = event.dataTransfer.items
        for (const item of items) {
          let entry = null
          if (item.getAsEntry) {
            entry = item.getAsEntry()
          } else if (item.webkitGetAsEntry) {
            entry = item.webkitGetAsEntry()
          }
          if (entry) {
            await this.addFilesByEntry(files, entry)
          }
        }
        if (files.length > 0) {
          this.$nuxt.$emit('UploadFileButtonAndForm/uploadFiles', files)
        }
      }
    },
    async addFilesByEntry(files, entry) {
      if (entry.isFile) {
        const file = await new Promise((resolve, reject) =>
          entry.file(resolve, reject)
        )
        let basePath = this.currentPath
        if (!basePath || basePath === '/') {
          basePath = ''
        }
        files.push({ path: `${basePath}${entry.fullPath}`, file: file })
      } else if (entry.isDirectory) {
        const reader = entry.createReader()
        const results = await new Promise((resolve, reject) =>
          reader.readEntries(resolve, reject)
        )
        for (const result of results) {
          await this.addFilesByEntry(files, result)
        }
      }
    }
  }
}
</script>
