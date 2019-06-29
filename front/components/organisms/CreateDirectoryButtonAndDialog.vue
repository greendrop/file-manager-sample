<template>
  <v-dialog v-model="dialog" persistent>
    <template v-slot:activator="{ on }">
      <v-btn v-on="on">
        <v-icon small class="mr-1">
          fas fa-folder-plus
        </v-icon>
        {{ $t('labels.createDirectory') }}
      </v-btn>
    </template>
    <v-card>
      <v-card-title>
        <span class="headline">
          {{ $t('labels.createDirectory') }}
        </span>
      </v-card-title>
      <v-card-text>
        <v-container grid-list-md>
          <CreateDirectoryForm :directory-name.sync="directoryName" />
        </v-container>
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn @click="createDirectory()">
          {{ $t('labels.new') }}
        </v-btn>
        <v-btn @click="dialogClose()">
          {{ $t('labels.close') }}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
import CreateDirectoryForm from '~/components/molecules/CreateDirectoryForm.vue'

export default {
  components: {
    CreateDirectoryForm
  },
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
      dialog: false,
      directoryName: ''
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
    }
  },
  mounted() {
    this.localProcessing = this.processing
    this.localProcessValue = this.processValue
  },
  methods: {
    createDirectory() {
      this.$validator.validateAll().then(async result => {
        if (result) {
          this.dialog = false
          this.localProcessing = true
          this.localProcessValue = 0

          let path = ''
          if (this.currentPath === '') {
            path = `/${this.directoryName}`
          } else {
            path = `${this.currentPath}/${this.directoryName}`
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
            this.$log.error(this.$store.getters['attachments/errorStatus'])
            this.$log.error(this.$store.getters['attachments/errorData'])
          }

          this.localProcessValue = 100
          this.localProcessing = false
          this.directoryName = ''
          this.$validator.reset()

          this.$nuxt.$emit('AttachmentList/getAttachments')
        }
      })
    },
    dialogClose() {
      this.dialog = false
      this.directoryName = ''
      this.$validator.reset()
    }
  }
}
</script>
