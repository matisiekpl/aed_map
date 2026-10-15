<script setup lang="ts">
import {renderSVG} from 'uqr'

const props = defineProps<{ url: string }>()

const svg = computed(() => renderSVG(props.url, {ecc: 'M', border: 0, blackColor: '#111111', whiteColor: '#ffffff'}))
</script>

<template>
  <div class="aspect-square w-full [&>svg]:block [&>svg]:size-full" v-html="svg"/>
</template>
