import { createRouter, createWebHistory } from "vue-router";

import Home from "../views/Home.vue";
import Perfil from "../views/Perfil/Perfil.vue";
import Ranking from "../views/Ranking/Ranking.vue";
import Login from "../views/Auth/Login.vue";
import Register from "../views/Auth/Register.vue";

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
  {
    path: "/login",
    name: "Login",
    component: Login,
  },
  {
    path: "/register",
    name: "Register",
    component: Register,
  },
];

// Crear el router
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

export default router;
