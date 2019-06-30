<template lang="pug">
  v-layout(wrap)
    v-flex(xs12 sm12 md12)
      v-text-field(
        v-model="localDirectoryName"
        v-validate="'required'"
        :label="$t('labels.directoryName')"
        :error-messages="errors.collect('directoryName')"
        :data-vv-as="$t('labels.directoryName')"
        :data-vv-name="'directoryName'"
        required
      )
</template>

<script>
export default {
  props: {
    directoryName: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      localDirectoryName: ''
    }
  },
  watch: {
    directoryName: {
      handler(val, oldVal) {
        if (val !== oldVal) {
          this.localDirectoryName = val
        }
      }
    },
    localDirectoryName: {
      handler(val, oldVal) {
        if (val !== oldVal) {
          this.$emit('update:directoryName', val)
        }
      }
    }
  },
  mounted() {
    this.localDirectoryName = this.directoryName
  }
}
</script>
