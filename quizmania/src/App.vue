<template>
  <div>
    <Header />
    <router-view />
  </div>
</template>

<script setup>
import Header from "./views/Header.vue";
</script>

<style>
@import url("https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,100..900;1,100..900&display=swap");

body {
  margin: 0;
}
</style>
