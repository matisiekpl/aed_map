<script setup lang="ts">
import {Config} from '~/config'

const {t} = useI18n()
const localeHead = useLocaleHead()

useHead(() => ({
  htmlAttrs: localeHead.value.htmlAttrs,
  link: [
    ...(localeHead.value.link || []),
    {rel: 'icon', type: 'image/png', href: '/favicon.png'},
    {rel: 'apple-touch-icon', href: '/apple-touch-icon.png'},
  ],
  meta: [
    ...(localeHead.value.meta || []),
    {name: 'apple-itunes-app', content: `app-id=${Config.appStoreId}`},
    {property: 'og:site_name', content: t('site.name')},
    {name: 'twitter:card', content: 'summary_large_image'},
    {name: 'theme-color', content: '#029140'},
  ],
}))
</script>

<template>
  <NuxtLayout>
    <NuxtPage/>
  </NuxtLayout>
</template>
