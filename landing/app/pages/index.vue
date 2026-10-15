<script setup lang="ts">
const {t} = useI18n()

useSeoMeta({
  title: () => t('seo.home.title'),
  description: () => t('seo.home.description'),
  ogTitle: () => t('seo.home.title'),
  ogDescription: () => t('seo.home.description'),
})

defineOgImage('Default', {
  title: t('seo.home.title'),
  description: t('seo.home.description'),
  siteName: t('site.name'),
})

useSchemaOrg([
  defineSoftwareApp({
    '@type': 'MobileApplication',
    name: t('site.name'),
    description: t('seo.home.description'),
    operatingSystem: 'iOS, Android',
    applicationCategory: 'HealthApplication',
    offers: {price: 0, priceCurrency: 'PLN'},
  }),
])
</script>

<template>
  <div>
    <HeroSection/>
    <FeaturesSection/>
    <DataSection/>
    <SurvivalSection/>
    <FaqSection/>
    <DownloadSection/>
  </div>
</template>
