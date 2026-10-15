<script setup lang="ts">
const {t} = useI18n()

useSeoMeta({
  title: () => t('seo.home.title'),
  description: () => t('seo.home.description'),
  ogTitle: () => t('seo.home.title'),
  ogDescription: () => t('seo.home.description'),
  twitterCard: 'summary_large_image',
})

defineOgImage('AedMap', {
  title: t('hero.title'),
  description: t('seo.home.description'),
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
