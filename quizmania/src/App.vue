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
import { useCookies } from "vue3-cookies";
import Header from "./views/Header.vue";
import Sidebar from "./views/Admin/Sidebar.vue";

const router = useRouter();
const route = useRoute();
const { cookies } = useCookies();
const userData = null;

const rutasPublicas = ["/", "/login", "/register"];
const rutasAdmin = [
  "/admin",
  "/categorias",
  "/usuarios",
  "/preguntas",
  "/importar-csv",
];
const rutasUsuario = [
  "/perfil",
  "/ranking",
  "/estadisticas",
  "/juego",
  "/selecciontema",
  "/quizmania",
];

watch(
  () => route.path,
  (nuevoPath) => {
    const user = cookies.get("user");

    if (!user) {
      if (!rutasPublicas.includes(nuevoPath)) {
        router.push("/").then(() => {
          location.reload();
        });
      }
    } else {
      if (user.rol === "admin") {
        return;
      } else {
        if (![...rutasUsuario, ...rutasPublicas].includes(nuevoPath)) {
          router.push("/quizmania").then(() => {
            location.reload();
          });
        }
      }
    }
  },
  { immediate: true }
);
</script>

<style>
@import url("https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,100..900;1,100..900&display=swap");

body {
  margin: 0;
}
</style>
