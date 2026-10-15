<template>
  <section id="download" class="scroll-mt-16 bg-muted/50">
    <div class="mx-auto flex max-w-4xl flex-col items-center gap-6 px-4 py-16 text-center md:py-24">
      <img src="/images/icon.png" alt="" width="80" height="80" class="size-20 rounded-[22%] shadow">
      <h2 class="text-3xl font-extrabold tracking-tight md:text-4xl">{{ $t('download.title') }}</h2>
      <p class="text-muted-foreground">{{ $t('download.description') }}</p>
      <StoreBadges class="justify-center"/>
    </div>
  </section>
</template>
