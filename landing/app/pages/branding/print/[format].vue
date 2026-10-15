<script setup lang="ts">
definePageMeta({layout: false})

const route = useRoute()
const format = route.params.format as 'a4' | 'a5'

useHead({
  style: [{innerHTML: `@page { size: A4 ${format === 'a4' ? 'portrait' : 'landscape'}; margin: 0 }`}],
  meta: [{name: 'robots', content: 'noindex'}],
})
</script>

<template>
  <div class="flex">
    <div v-for="copy in format === 'a4' ? 1 : 2" :key="copy" :class="format === 'a4' ? 'w-[210mm]' : 'w-[148.5mm]'">
      <PosterSheet :format="format"/>
    </div>
  </div>
</template>
