<script setup lang="ts">
import {ArrowUpRight} from 'lucide-vue-next'
import {Config} from '~/config'

const {worldCount, polandCount} = useAedStatistics()
</script>

<template>
  <section class="bg-muted/50">
    <div class="mx-auto flex max-w-6xl flex-col gap-5 px-4 py-8 sm:gap-8 sm:py-20 md:py-28">
      <h2 class="max-w-4xl text-4xl font-extrabold tracking-tight text-balance tabular-nums md:text-6xl md:leading-[1.05]">
        <template v-if="worldCount">{{ $t('data.headline', {world: $n(worldCount), poland: $n(polandCount)}) }}</template>
        <template v-else>{{ $t('data.title') }}</template>
      </h2>
      <div class="flex max-w-2xl flex-col items-start gap-5 sm:gap-6">
        <p class="text-lg leading-relaxed">{{ $t('data.description') }}</p>
        <Button as="a" :href="Config.openAedMapUrl" target="_blank" rel="noopener" size="lg" class="group h-12 cursor-pointer gap-2 rounded-full px-6 text-base font-semibold shadow-sm transition-[filter] hover:brightness-110 focus-visible:ring-4" @click="useTrackEvent('checkosm')">
          {{ $t('data.openAedMap') }}
          <ArrowUpRight class="size-5 transition-transform group-hover:translate-x-0.5 group-hover:-translate-y-0.5 motion-reduce:transition-none"/>
        </Button>
      </div>
    </div>
  </section>
</template>
