<script setup lang="ts">
import {Config} from '~/config'
</script>

<template>
  <section class="bg-brand text-brand-foreground">
    <div class="mx-auto flex max-w-4xl flex-col items-center gap-6 px-4 py-16 text-center md:py-24">
      <h2 class="text-3xl font-extrabold tracking-tight md:text-5xl">{{ $t('survival.title') }}</h2>
      <p class="max-w-2xl text-lg opacity-90">{{ $t('survival.description') }}</p>
      <a :href="Config.aedInformationUrl" target="_blank" rel="noopener" class="font-semibold underline underline-offset-4" @click="useTrackEvent('learnmore')">
        {{ $t('survival.link') }}
      </a>
    </div>
  </section>
</template>
