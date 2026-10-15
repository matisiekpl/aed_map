<script setup lang="ts">
const props = withDefaults(defineProps<{
  title: string
  description?: string
  siteName?: string
}>(), {description: '', siteName: 'Mapa AED'})

const titleSize = computed(() => {
  const length = props.title.length
  if (length > 68) return 40
  if (length > 46) return 48
  if (length > 28) return 58
  return 72
})
</script>

<template>
  <div
    style="width: 1200px; height: 630px; display: flex; flex-direction: column; justify-content: space-between;
           padding: 64px 72px; font-family: 'Manrope', sans-serif; color: #111111; background-color: #ffffff;"
  >
    <div style="display: flex; align-items: center;">
      <img src="/images/icon.png" width="72" height="72" style="border-radius: 16px; margin-right: 18px;">
      <div style="font-size: 34px; font-weight: 800; letter-spacing: -0.02em;">
        {{ siteName }}
      </div>
    </div>

    <div style="display: flex; flex-direction: column;">
      <div :style="`display: flex; font-size: ${titleSize}px; font-weight: 800; letter-spacing: -0.03em; line-height: 1.08;`">
        {{ title }}
      </div>
      <div v-if="description" style="display: flex; margin-top: 22px; font-size: 30px; color: #555555; line-height: 1.35;">
        {{ description }}
      </div>
    </div>

    <div style="display: flex; padding-top: 28px; border-top: 2px solid #e5e5e5; font-size: 26px; font-weight: 700; color: #029140;">
      aedmapa.pl
    </div>
  </div>
</template>
