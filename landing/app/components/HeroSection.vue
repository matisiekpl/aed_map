<script setup lang="ts">
const {worldCount, countryCount} = useAedStatistics()
const {locale} = useI18n()
</script>

<template>
  <section class="mx-auto grid max-w-5xl items-center gap-8 px-4 pt-6 pb-8 sm:gap-12 sm:py-16 md:grid-cols-[5fr_6fr] md:py-8">
    <div class="flex flex-col gap-5 sm:gap-7">
      <span v-if="worldCount" class="w-fit rounded-full bg-brand/10 px-4 py-1.5 text-base font-semibold text-brand">
        {{ $t('hero.statistics', {count: $n(worldCount), countries: countryCount}) }}
      </span>
      <h1 class="text-5xl font-extrabold tracking-tight md:text-6xl lg:text-7xl">{{ $t('hero.title') }}</h1>
      <p class="text-xl leading-relaxed">{{ $t('hero.description') }}</p>
      <StoreBadges/>
    </div>
    <div class="relative mx-auto w-full md:mr-0 max-w-[min(36rem,calc((100svh-7rem)*0.72))]">
      <NuxtImg :src="`/screenshots/${locale}/map.webp`" :alt="$t('hero.imageAlt')" width="720" height="1382" class="absolute top-0 left-0 w-[58%]"/>
      <NuxtImg :src="`/screenshots/${locale}/details.webp`" :alt="$t('hero.detailsImageAlt')" width="720" height="1382" preload class="relative mt-[12%] ml-auto w-[66%]"/>
    </div>
  </section>
</template>
