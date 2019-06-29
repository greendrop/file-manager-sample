<template>
  <v-layout row wrap>
    <v-flex xs12 sm12 md12>
      <v-layout row wrap>
        <v-flex xs12 sm12 md12 mb-1>
          <div class="headline">
            {{ $t('labels.listModel', { model: $t('models.attachment') }) }}
          </div>
        </v-flex>
      </v-layout>
    </v-flex>

    <v-flex v-show="processing" xs12 sm12 md12>
      <v-progress-linear v-model="processValue" />
    </v-flex>

    <v-flex v-show="!processing" xs12 sm12 md12>
      <v-layout row wrap>
        <v-flex xs12 sm12 md12 mb-1>
          <v-layout justify-end>
            <UploadFileButtonAndForm :current-path="currentPath" />
            <CreateDirectoryButtonAndDialog
              :current-path="currentPath"
              :processing.sync="processing"
              :process-value.sync="processValue"
            />
          </v-layout>
        </v-flex>
        <AttachmentList
          :current-path="currentPath"
          :processing.sync="processing"
          :process-value.sync="processValue"
        />
      </v-layout>
    </v-flex>
  </v-layout>
</template>

<script>
import CreateDirectoryButtonAndDialog from '~/components/organisms/CreateDirectoryButtonAndDialog.vue'
import UploadFileButtonAndForm from '~/components/organisms/UploadFileButtonAndForm.vue'
import AttachmentList from '~/components/organisms/AttachmentList.vue'

export default {
  components: {
    CreateDirectoryButtonAndDialog,
    UploadFileButtonAndForm,
    AttachmentList
  },
  data() {
    return {
      processing: false,
      processValue: 0
    }
  },
  computed: {
    currentPath() {
      const currentPath = this.$route.query.path
      if (currentPath) {
        return currentPath
      } else {
        return '/'
      }
    }
  }
}
</script>
