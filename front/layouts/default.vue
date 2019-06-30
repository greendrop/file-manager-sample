<template lang="pug">
  v-app(dark)
    v-navigation-drawer(
      v-model="drawer"
      :mini-variant="miniVariant"
      :clipped="clipped"
      fixed
      app
    )
      v-list
        v-list-tile(
          v-for="(item, i) in items"
          :key="i"
          :to="item.to"
          router
          exact
        )
          v-list-tile-action
            v-icon(small)
              = "{{ item.icon }}"

          v-list-tile-content
            v-list-tile-title(v-text="item.title")

    v-toolbar(:clipped-left="clipped" fixed app)
      v-toolbar-side-icon(@click="drawer = !drawer")
      v-toolbar-title(v-text="title")

    v-content
      v-container
        nuxt

    v-footer(:fixed="fixed" app)
</template>

<script>
export default {
  data() {
    return {
      clipped: true,
      drawer: null,
      fixed: false,
      items: [
        {
          icon: 'fas fa-home',
          title: this.$i18n.t('labels.home'),
          to: '/'
        },
        {
          icon: 'fas fa-list',
          title: this.$i18n.t('models.attachment'),
          to: '/attachments'
        }
      ],
      miniVariant: false,
      right: true,
      rightDrawer: false,
      title: 'File Manager Sample'
    }
  }
}
</script>
