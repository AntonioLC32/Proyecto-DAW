<template>
  <div>
    <div
      v-if="
        ![
          '/admin',
          '/categorias',
          '/usuarios',
          '/preguntas',
          '/importar-csv',
        ].includes($route.path)
      "
    >
      <Header />
    </div>
    <div v-else>
      <Sidebar />
    </div>
    <router-view />
  </div>
</template>

<script setup>
import { watch } from "vue";
import { useRouter, useRoute } from "vue-router";
import Header from "./views/Header.vue";
import Sidebar from "./views/Admin/Sidebar.vue";

const router = useRouter();
const route = useRoute();

const rutasValidas = [
  "/",
  "/perfil",
  "/ranking",
  "/estadisticas",
  "/juego",
  "/selecciontema",
  "/admin",
  "/categorias",
  "/usuarios",
  "/preguntas",
  "/importar-csv",
  "/login",
  "/register",
  "/quizmania",
];

watch(
  () => route.path,
  (nuevoPath) => {
    if (!rutasValidas.includes(nuevoPath)) {
      router.push("/");
    }
  }
);
</script>

<style>
@import url("https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,100..900;1,100..900&display=swap");

body {
  margin: 0;
}
</style>
