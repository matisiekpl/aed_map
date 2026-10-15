<script setup lang="ts">
const props = defineProps<{
  name: 'privacy' | 'terms'
}>()

const {t, locale} = useI18n()

const {data: page} = await useAsyncData(`legal-${props.name}-${locale.value}`, () =>
  queryCollection('legal').path(`/legal/${locale.value}/${props.name}`).first())

useSeoMeta({
  title: () => t(`seo.${props.name}.title`),
  description: () => t(`seo.${props.name}.description`),
  ogTitle: () => t(`seo.${props.name}.title`),
  ogDescription: () => t(`seo.${props.name}.description`),
})

defineOgImage('Default', {
  title: page.value?.title ?? '',
  description: t(`seo.${props.name}.description`),
  siteName: t('site.name'),
})
</script>

<template>
  <article v-if="page" class="prose prose-neutral mx-auto max-w-3xl px-4 py-8 sm:py-16 dark:prose-invert">
    <p class="mb-4 text-sm text-muted-foreground">{{ $t('legal.updatedAt', {date: $d(new Date(page.updatedAt))}) }}</p>
    <ContentRenderer :value="page"/>
  </article>
</template>
