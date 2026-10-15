<script setup lang="ts">
import {Config} from '~/config'

const {locale} = useI18n()
</script>

<template>
  <div class="flex flex-wrap gap-3">
    <a :href="Config.appStoreUrl" target="_blank" rel="noopener" class="transition-transform hover:-translate-y-0.5 motion-reduce:transition-none" @click="useTrackEvent('appstore')">
      <img :src="`/badges/appstore-black-${locale}.svg`" :alt="$t('download.appStore')" width="168" height="56" class="h-14 w-auto dark:hidden">
      <img :src="`/badges/appstore-white-${locale}.svg`" :alt="$t('download.appStore')" width="168" height="56" class="hidden h-14 w-auto dark:block">
    </a>
    <a :href="Config.googlePlayUrl" target="_blank" rel="noopener" class="transition-transform hover:-translate-y-0.5 motion-reduce:transition-none" @click="useTrackEvent('googleplay')">
      <img :src="`/badges/googleplay-${locale}.png`" :alt="$t('download.googlePlay')" width="188" height="56" class="h-14 w-auto">
    </a>
  </div>
</template>
