<script setup lang="ts">
import {Download} from 'lucide-vue-next'

const {t, locale} = useI18n()

useSeoMeta({
  title: () => t('seo.brand.title'),
  description: () => t('seo.brand.description'),
  ogTitle: () => t('seo.brand.title'),
  ogDescription: () => t('seo.brand.description'),
})

defineOgImage('Default', {
  title: t('seo.brand.title'),
  description: t('seo.brand.description'),
  siteName: t('site.name'),
})
</script>

<template>
  <section class="mx-auto grid max-w-6xl items-center gap-8 px-4 py-8 sm:gap-12 sm:py-16 md:grid-cols-2">
    <div class="flex flex-col gap-5">
      <h1 class="text-4xl font-extrabold tracking-tight md:text-6xl">{{ $t('brand.title') }}</h1>
      <p class="text-lg leading-relaxed">{{ $t('brand.description') }}</p>
      <div class="flex flex-wrap gap-3">
        <Button v-for="format in ['a4', 'a5']" :key="format" as="a" size="lg" class="cursor-pointer" :variant="format === 'a4' ? 'default' : 'outline'" :href="`/posters/${locale}/${format}.pdf`" :download="`aedmap_${format}_${locale}.pdf`" @click="useTrackEvent('poster', {props: {format, locale}})">
          <Download/>
          {{ $t(`brand.download.${format}`) }}
        </Button>
      </div>
    </div>
    <div class="mx-auto w-full max-w-md shadow-lg ring-1 ring-border">
      <PosterSheet format="a4"/>
    </div>
  </section>
</template>
