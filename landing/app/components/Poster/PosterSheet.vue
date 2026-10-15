<script setup lang="ts">
import {Config} from '~/config'

defineProps<{ format: 'a4' | 'a5' }>()

const {locale} = useI18n()
const sheet = useTemplateRef<HTMLElement>('sheet')
const headline = useTemplateRef<HTMLElement>('headline')
const lead = useTemplateRef<HTMLElement>('lead')

function fitToWidth() {
  for (const element of [headline.value, lead.value]) {
    if (!element || !sheet.value) {
      continue
    }
    element.style.fontSize = ''
    const fontSize = parseFloat(getComputedStyle(element).fontSize) * element.clientWidth * 0.99 / element.scrollWidth
    element.style.fontSize = `${fontSize / sheet.value.clientWidth * 100}cqw`
  }
}

onMounted(() => document.fonts.ready.then(fitToWidth))
watch(locale, () => nextTick(fitToWidth))
</script>

<template>
  <div ref="sheet" class="@container aspect-[210/297] w-full bg-white text-[#111111]">
    <div class="flex size-full flex-col gap-[2.8cqw] p-[7cqw]">
      <div class="flex items-center justify-between text-[2.6cqw]">
        <div class="flex items-center gap-[2cqw] font-extrabold tracking-[0.06em] uppercase">
          <img src="/images/icon.png" alt="" class="size-[7cqw] rounded-[1.4cqw]">
          {{ $t('site.name') }}
        </div>
        <span class="font-semibold text-[#444444]">{{ Config.domain }}</span>
      </div>
      <h2 ref="headline" class="text-[4.95cqw] leading-[1.04] font-extrabold tracking-[-0.03em] whitespace-nowrap">{{ $t('posters.headline') }}</h2>
      <p ref="lead" class="text-[3.5cqw] leading-[1.4] whitespace-nowrap text-[#222222]">{{ $t('posters.lead') }}</p>
      <div class="grid grid-cols-[1.15fr_1fr] items-center gap-[5cqw]">
        <div class="flex flex-col gap-[1.4cqw] text-[2.6cqw] leading-[1.4]">
          <h2 class="text-[3.2cqw] font-extrabold">{{ $t('posters.aed.title') }}</h2>
          <p>{{ $t('posters.aed.description') }}</p>
        </div>
        <div class="border-l-[0.9cqw] border-[#029140] pl-[2.4cqw] text-[2.7cqw] leading-[1.3] font-bold">
          <strong class="block text-[5.8cqw] leading-[1.1] whitespace-nowrap text-[#029140]">{{ $t('posters.survival.value') }}</strong>
          {{ $t('posters.survival.description') }}
        </div>
      </div>
      <div class="flex flex-col gap-[1.2cqw] border-t-[0.3cqw] border-[#111111] pt-[2.8cqw]">
        <h2 class="mb-[0.6cqw] text-[3.2cqw] font-extrabold">{{ $t('posters.steps.title') }}</h2>
        <div v-for="(step, index) in ['call', 'compressions', 'aed']" :key="step" class="grid grid-cols-[5cqw_1fr] items-baseline gap-[2cqw] text-[2.6cqw] leading-[1.35]">
          <span class="text-[3.8cqw] leading-none font-extrabold text-[#029140]">{{ index + 1 }}</span>
          <p>{{ $t(`posters.steps.${step}`) }}</p>
        </div>
      </div>
      <div class="mt-auto grid grid-cols-[31cqw_1fr] gap-[4cqw]">
        <div class="border-[0.5cqw] border-[#111111] p-[2cqw]">
          <PosterQrCode :url="`${Config.siteUrl}/qr?p=${format}-${locale}`"/>
        </div>
        <div class="flex min-w-0 flex-col justify-between gap-[3cqw]">
          <i18n-t keypath="posters.download" tag="p" class="text-[2.8cqw] leading-[1.4] font-semibold text-pretty">
            <template #domain><b>{{ Config.domain }}</b></template>
          </i18n-t>
          <div class="grid grid-cols-[auto_1fr] items-center gap-[3cqw] border-[0.5cqw] border-[#111111] px-[3.4cqw] py-[2cqw]">
            <b class="text-[7.4cqw] leading-none font-extrabold tracking-[-0.03em]">112</b>
            <p class="text-[2.8cqw] leading-[1.38] font-semibold text-balance">{{ $t('posters.emergency') }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
