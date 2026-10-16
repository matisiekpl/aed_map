<script setup lang="ts">
const localePath = useLocalePath()
</script>

<template>
  <header class="sticky top-0 z-40 border-b bg-background/80 backdrop-blur">
    <div class="mx-auto flex h-18 max-w-5xl items-center justify-between px-4">
      <NuxtLink :to="localePath('/')" class="flex items-center gap-2.5 text-lg font-extrabold">
        <img src="/images/icon.png" alt="" width="32" height="32" class="size-9 rounded-[22%]">
        {{ $t('site.name') }}
      </NuxtLink>
      <nav class="flex items-center gap-1">
        <NuxtLink :to="{path: localePath('/'), hash: '#features'}" class="hidden px-3 text-sm font-medium text-muted-foreground hover:text-foreground sm:block">{{ $t('nav.features') }}</NuxtLink>
        <NuxtLink :to="{path: localePath('/'), hash: '#faq'}" class="hidden px-3 text-sm font-medium text-muted-foreground hover:text-foreground sm:block">{{ $t('nav.faq') }}</NuxtLink>
        <NuxtLink :to="{path: localePath('/'), hash: '#download'}" class="hidden px-3 text-sm font-medium text-muted-foreground hover:text-foreground sm:block">{{ $t('nav.download') }}</NuxtLink>
        <LanguageSwitcher/>
      </nav>
    </div>
  </header>
</template>
