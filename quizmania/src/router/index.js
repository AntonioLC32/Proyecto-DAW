import { createRouter, createWebHistory } from "vue-router";

import Home from "../views/Home.vue";
import Perfil from "../views/Perfil/Perfil.vue";
import Ranking from "../views/Ranking/Ranking.vue";
import Login from "../views/Auth/Login.vue";
import Register from "../views/Auth/Register.vue";
import Admin from "../views/Admin/Admin.vue";
import Quizmania from "../views/Quizmania.vue";
import Preguntas from "../views/admin/Preguntas.vue";


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
  {
    path: "/admin",
    name: "Admin",
    component: Admin,
  },
  {
    path: "/quizmania",
    name: "Index",
    component: Quizmania,
  },
  {
    path: "/preguntas",
    name: "Preguntas",
    component: Preguntas,
  }
];

// Crear el router
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

export default router;
