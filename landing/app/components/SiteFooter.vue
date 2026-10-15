<script setup lang="ts">
import {Config} from '~/config'

const localePath = useLocalePath()
</script>

<template>
  <footer class="border-t">
    <div class="mx-auto grid max-w-6xl gap-6 px-4 py-8 text-sm sm:grid-cols-3 sm:gap-8 sm:py-12">
      <div class="flex flex-col gap-2">
        <span class="font-extrabold">{{ $t('site.name') }}</span>
        <a :href="`mailto:${Config.contactEmail}`" class="text-muted-foreground hover:text-foreground" @click="useTrackEvent('author')">
          {{ $t('footer.createdBy', {name: Config.authorName}) }}
        </a>
        <a :href="Config.partnerUrl" target="_blank" rel="noopener" class="text-muted-foreground hover:text-foreground" @click="useTrackEvent('partner')">
          {{ $t('footer.partner') }}
        </a>
      </div>
      <div class="flex flex-col gap-2">
        <NuxtLink :to="localePath('/privacy')" class="text-muted-foreground hover:text-foreground">{{ $t('footer.privacy') }}</NuxtLink>
        <NuxtLink :to="localePath('/terms')" class="text-muted-foreground hover:text-foreground">{{ $t('footer.terms') }}</NuxtLink>
        <a :href="Config.githubUrl" target="_blank" rel="noopener" class="text-muted-foreground hover:text-foreground" @click="useTrackEvent('sourcecode')">
          {{ $t('footer.sourceCode') }}
        </a>
      </div>
      <div class="flex flex-col gap-2">
        <a :href="Config.instagramUrl" target="_blank" rel="noopener" class="text-muted-foreground hover:text-foreground">Instagram</a>
        <a :href="`mailto:${Config.contactEmail}`" class="text-muted-foreground hover:text-foreground">{{ Config.contactEmail }}</a>
        <span class="text-muted-foreground">{{ $t('footer.dataLicense') }}</span>
      </div>
    </div>
  </footer>
</template>
