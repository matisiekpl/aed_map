<script setup lang="ts">
defineProps<{
  title: string
  description: string
}>()
</script>

<template>
  <div class="flex h-full w-full flex-col justify-between bg-[#029140] p-20 text-white">
    <div class="flex items-center gap-6">
      <img src="/images/icon.png" width="96" height="96" class="rounded-3xl">
      <span class="text-5xl font-extrabold">aedmapa.pl</span>
    </div>
    <div class="flex flex-col gap-6">
      <span class="text-7xl font-extrabold">{{ title }}</span>
      <span class="text-4xl opacity-90">{{ description }}</span>
    </div>
  </div>
</template>
