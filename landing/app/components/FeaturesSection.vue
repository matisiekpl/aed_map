<script setup lang="ts">
import {Camera, Clock, Footprints, LocateFixed, PencilLine, WifiOff} from 'lucide-vue-next'

const features = [
  {key: 'nearest', icon: LocateFixed},
  {key: 'route', icon: Footprints},
  {key: 'details', icon: Clock},
  {key: 'edit', icon: PencilLine},
  {key: 'photos', icon: Camera},
  {key: 'offline', icon: WifiOff},
]
</script>

<template>
  <section id="features" class="scroll-mt-16 bg-muted/50">
    <div class="mx-auto max-w-6xl px-4 py-16 md:py-24">
      <h2 class="mb-10 text-3xl font-extrabold tracking-tight md:text-4xl">{{ $t('features.title') }}</h2>
      <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <article v-for="feature in features" :key="feature.key" class="flex flex-col gap-3 rounded-xl border bg-background p-6">
          <component :is="feature.icon" class="size-6 text-brand"/>
          <h3 class="text-lg font-bold">{{ $t(`features.items.${feature.key}.title`) }}</h3>
          <p class="text-muted-foreground">{{ $t(`features.items.${feature.key}.description`) }}</p>
        </article>
      </div>
    </div>
  </section>
</template>
