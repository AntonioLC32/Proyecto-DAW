import { createRouter, createWebHistory } from "vue-router";

import Home from "../views/Home.vue";
import Perfil from "../views/perfil/Perfil.vue";
import Ranking from "../views/Ranking/Ranking.vue";

const routes = [
  {
    path: "/",
    name: "Home",
    component: Home,
  },
  {
    path: "/perfil",
    name: "Perfil",
    component: Perfil,
  },
  {
    path: "/ranking",
    name: "Ranking",
    component: Ranking,
  },
];

// Crear el router
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

export default router;
