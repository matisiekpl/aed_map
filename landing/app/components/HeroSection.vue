<script setup lang="ts">
const {worldCount, countryCount} = useAedStatistics()
</script>

<template>
  <section class="mx-auto grid max-w-6xl items-center gap-12 px-4 py-16 md:grid-cols-2 md:py-24">
    <div class="flex flex-col gap-7">
      <span v-if="worldCount" class="w-fit rounded-full bg-brand/10 px-4 py-1.5 text-base font-semibold text-brand">
        {{ $t('hero.statistics', {count: $n(worldCount), countries: countryCount}) }}
      </span>
      <h1 class="text-5xl font-extrabold tracking-tight md:text-7xl lg:text-8xl">{{ $t('hero.title') }}</h1>
      <p class="text-xl leading-relaxed text-muted-foreground">{{ $t('hero.description') }}</p>
      <StoreBadges/>
    </div>
    <NuxtImg
        src="/images/banner.webp"
        :alt="$t('hero.imageAlt')"
        width="555"
        height="696"
        format="webp"
        preload
        class="mx-auto w-full max-w-lg"/>
  </section>
</template>
