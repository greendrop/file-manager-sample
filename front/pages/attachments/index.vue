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

    <v-flex xs12 sm12 md12>
      <v-layout row wrap>
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
                  <div>
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
              <td></td>
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
      attachmentLoading: true
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
    openDirectory(attachment) {
      this.$router.push({
        path: '/attachments',
        query: { path: attachment.path }
      })
    }
  }
}
</script>
