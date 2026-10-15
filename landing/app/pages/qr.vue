<script setup lang="ts">
import {Config} from '~/config'

const {t} = useI18n()

useSeoMeta({
  title: () => t('seo.home.title'),
  description: () => t('seo.home.description'),
  ogTitle: () => t('seo.home.title'),
  ogDescription: () => t('seo.home.description'),
  robots: 'noindex',
})

defineOgImage('Default', {
  title: t('seo.home.title'),
  description: t('seo.home.description'),
  siteName: t('site.name'),
})

const route = useRoute()

onMounted(() => {
  const userAgent = navigator.userAgent
  const ios = /iPhone|iPad|iPod/.test(userAgent) || (/Macintosh/.test(userAgent) && navigator.maxTouchPoints > 1)
  const android = /Android/.test(userAgent)
  const storeUrl = ios ? Config.appStoreUrl : android ? Config.googlePlayUrl : undefined
  const redirect = () => storeUrl && window.location.replace(storeUrl)
  useTrackEvent('qr', {props: {platform: ios ? 'ios' : android ? 'android' : 'desktop', poster: String(route.query.p ?? '')}, callback: redirect})
  setTimeout(redirect, 1000)
})
</script>

<template>
  <section class="mx-auto flex max-w-xl flex-col items-center gap-5 px-4 py-16 text-center">
    <img src="/images/icon.png" alt="" width="80" height="80" class="size-20 rounded-[22%] shadow">
    <h1 class="text-3xl font-extrabold tracking-tight">{{ $t('site.name') }}</h1>
    <p>{{ $t('download.description') }}</p>
    <StoreBadges class="justify-center"/>
  </section>
</template>
