<script setup lang="ts">
import {Languages} from 'lucide-vue-next'

const {locale, locales} = useI18n()
const switchLocalePath = useSwitchLocalePath()

const currentLocaleName = computed(() => locales.value.find(item => item.code === locale.value)?.name)
</script>

<template>
  <DropdownMenu>
    <DropdownMenuTrigger as-child>
      <Button variant="ghost" size="sm" class="cursor-pointer">
        <Languages/>
        {{ currentLocaleName }}
      </Button>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end">
      <DropdownMenuItem v-for="item in locales" :key="item.code" as-child>
        <NuxtLink :to="switchLocalePath(item.code)" :hreflang="item.language">{{ item.name }}</NuxtLink>
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
</template>
