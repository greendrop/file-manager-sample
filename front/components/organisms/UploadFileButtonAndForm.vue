<template lang="pug">
  div
    input(
      ref="uploadFile"
      type="file"
      multiple
      style="display: none"
      @change="selectUploadFiles"
    )
    v-btn(@click="$refs.uploadFile.click()")
      v-icon(small class="mr-1") fas fa-upload
      = "{{ $t('labels.uploadFile') }}"
</template>

<template>
  <div>
    <input
      ref="uploadFile"
      type="file"
      multiple
      style="display: none"
      @change="selectUploadFiles"
    />
    <v-btn @click="$refs.uploadFile.click()">
      <v-icon small class="mr-1">
        fas fa-upload
      </v-icon>
      {{ $t('labels.uploadFile') }}
    </v-btn>
  </div>
</template>

<script>
export default {
  props: {
    currentPath: {
      type: String,
      required: true
    }
  },
  created() {
    this.$nuxt.$on('UploadFileButtonAndForm/uploadFiles', async files => {
      await this.uploadFiles(files)
      this.$nuxt.$emit('AttachmentList/getAttachments')
    })
  },
  methods: {
    async selectUploadFiles(event) {
      const files = []
      let basePath = this.currentPath
      if (!basePath || basePath === '/') {
        basePath = ''
      }

      for (const file of event.target.files) {
        files.push({ path: `${basePath}/${file.name}`, file: file })
      }

      if (files.length > 0) {
        await this.uploadFiles(files)
        this.$nuxt.$emit('AttachmentList/getAttachments')
      }
    },
    async uploadFiles(files) {
      this.localProcessing = true
      this.localProcessValue = 0

      const allCount = files.length
      let uploadedCount = 0

      for (const file of files) {
        await this.$store.dispatch('attachments/upload', {
          params: { path: file.path, file: file.file }
        })

        if (!this.$store.getters['attachments/uploaded']) {
          break
        }

        uploadedCount += 1
        this.processValue = (uploadedCount / allCount) * 100
      }

      this.localProcessValue = 100
      this.localProcessing = false

      if (this.$store.getters['attachments/uploaded']) {
        const message = this.$t('messages.uploaded')
        this.$toast.success(message)
      } else {
        const message = this.$t('messages.errorOccurred')
        this.$toast.error(message)
        this.$log.error(this.$store.getters['attachments/errorStatus'])
        this.$log.error(this.$store.getters['attachments/errorData'])
      }
    }
  }
}
</script>
