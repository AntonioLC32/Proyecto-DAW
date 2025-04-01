import { createRouter, createWebHistory } from "vue-router";

import Home from "../views/Home.vue";
import Perfil from "../views/Perfil/Perfil.vue";
import Estadisticas from "../views/Estadisticas/Estadisticas.vue";
import Ranking from "../views/Ranking/Ranking.vue";
import Login from "../views/Auth/Login.vue";
import ResetContraseña from "../views/Auth/ResetContraseña.vue";
import Register from "../views/Auth/Register.vue";
import Admin from "../views/Admin/Admin.vue";
import Quizmania from "../views/Quizmania.vue";
import Juego from "../views/Juego/Juego.vue";
import Seleccion from "../views/Juego/SeleccionTema.vue";
import Preguntas from "../views/admin/Preguntas.vue";
import Usuarios from "../views/admin/Usuarios.vue";
import Categorias from "../views/admin/Categorias.vue";
import CSV from "../views/admin/CSV.vue";

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
    path: "/estadisticas",
    name: "Estadisticas",
    component: Estadisticas,
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
    path: "/resetcontraseña",
    name: "ResetContraseña",
    component: ResetContraseña,
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
    path: "/selecciontema",
    name: "Seleccion",
    component: Seleccion,
  },
  {
    path: "/juego",
    name: "Juego",
    component: Juego,
  },
  {
    path: "/preguntas",
    name: "Preguntas",
    component: Preguntas,
  },
  {
    path: "/usuarios",
    name: "Usuarios",
    component: Usuarios,
  },
  {
    path: "/categorias",
    name: "Categorias",
    component: Categorias,
  },
  {
    path: "/importar-csv",
    name: "CSV",
    component: CSV,
  },
];

// Crear el router
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

export default router;
