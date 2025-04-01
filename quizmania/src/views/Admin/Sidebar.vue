<template>
  <nav
    :class="['main-menu', { expanded: isExpanded }]"
    @mouseenter="expandMenu"
    @mouseleave="collapseMenu"
  >
    <div class="logo-container">
      <router-link to="/admin">
        <img src="/src/assets/logo.png" alt="QuizManía Logo" class="logo" />
      </router-link>
    </div>

    <div class="menu-header">
      <span class="menu-title">{{ textosTraducidos["MENU"] || "MENU" }}</span>
      <div class="menu-divider"></div>
    </div>

    <ul class="menu-items">
      <li v-for="item in menuItems" :key="item.text">
        <router-link :to="item.route">
          <i class="fa" :class="item.icon"></i>
          <span class="nav-text">{{
            textosTraducidos[item.text] || item.text
          }}</span>
        </router-link>
      </li>
    </ul>

    <ul class="logout">
      <li>
        <router-link to="/">
          <i class="fa fa-power-off"></i>
          <span class="nav-text">{{
            textosTraducidos["SALIR"] || "SALIR"
          }}</span>
        </router-link>
      </li>
    </ul>
  </nav>
</template>

<script>
import axios from "axios";

export default {
  name: "Sidebar",
  data() {
    return {
      isExpanded: false,
      idiomaUsuario: "es",
      textosTraducidos: {},
      traduccionesCargando: false,
      menuItems: [
        { text: "PREGUNTAS", route: "/preguntas", icon: "fa-question-circle" },
        { text: "CATEGORÍAS", route: "/categorias", icon: "fa-list" },
        { text: "USUARIOS", route: "/usuarios", icon: "fa-user" },
        { text: "DATOS GENERALES", route: "/admin", icon: "fa-database" },
        {
          text: "IMPORTAR CSV",
          route: "/importar-csv",
          icon: "fa-file-upload",
        },
      ],
    };
  },
  mounted() {
    this.idiomaUsuario = navigator.language.split("-")[0] || "es";
    if (this.idiomaUsuario !== "es") {
      this.traducirContenido();
    }
  },
  methods: {
    expandMenu() {
      this.isExpanded = true;
    },
    collapseMenu() {
      this.isExpanded = false;
    },
    async traducirTexto(texto) {
      if (this.idiomaUsuario === "es") return texto;
      try {
        this.traduccionesCargando = true;
        const response = await axios.post("/api/index.php?action=traducir", {
          texto,
          idioma_origen: "es",
          idioma_destino: this.idiomaUsuario,
        });
        return response.data.status === "success"
          ? response.data.traduccion
          : texto;
      } catch (error) {
        console.error("Error en traducción:", error);
        return texto;
      } finally {
        this.traduccionesCargando = false;
      }
    },
    async traducirContenido() {
      this.traduccionesCargando = true;
      const textosOriginales = [
        "MENU",
        "PREGUNTAS",
        "CATEGORÍAS",
        "USUARIOS",
        "DATOS GENERALES",
        "IMPORTAR CSV",
        "SALIR",
      ];
      const traducciones = await Promise.all(
        textosOriginales.map((texto) => this.traducirTexto(texto))
      );
      textosOriginales.forEach((texto, index) => {
        this.textosTraducidos[texto] = traducciones[index];
      });
      this.traduccionesCargando = false;
    },
  },
};
</script>

<style scoped>
.main-menu {
  background: #cac5f5;
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  width: 60px;
  height: 100vh;
  overflow: hidden;
  transition: width 0.3s ease;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-between;
}

.main-menu.expanded {
  width: 300px;
}

.menu-header {
  width: 100%;
  text-align: center;
  padding: 15px 0;
}

.menu-title {
  font-size: 16px;
  font-weight: bold;
  color: #4a4da5;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.main-menu.expanded .menu-title {
  opacity: 1;
}

.menu-divider {
  width: 60%;
  height: 2px;
  background: #4a4da5;
  margin: 5px auto;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.main-menu.expanded .menu-divider {
  opacity: 1;
}

.logo-container {
  width: 100%;
  text-align: center;
  margin: 10px 0;
}

.logo {
  width: 40px;
  transition: width 0.3s ease;
}

.main-menu.expanded .logo {
  width: 120px;
}

.menu-items {
  flex-grow: 1;
  width: 100%;
  padding: 0;
  list-style: none;
}

.main-menu li {
  display: block;
}

.main-menu li a {
  display: flex;
  align-items: center;
  padding: 12px;
  text-decoration: none;
  color: #4a4da5;
  transition: background 0.2s, color 0.2s;
  justify-content: flex-start;
  width: 100%;
  box-sizing: border-box;
}

.main-menu:not(.expanded) li a {
  padding: 12px 0;
  justify-content: center;
}

.main-menu li a:hover {
  background: #b3adea;
  color: white;
}

.main-menu .fa {
  min-width: 40px;
  text-align: center;
  font-size: 20px;
  color: #4a4da5;
  flex-shrink: 0;
}

.nav-text {
  font-weight: bold;
  opacity: 0;
  transition: opacity 0.3s ease;
  white-space: nowrap;
  overflow: hidden;
  max-width: 0;
}

.main-menu.expanded .nav-text {
  opacity: 1;
  max-width: 200px;
}

.logout {
  width: 100%;
  list-style: none;
  padding: 0;
  margin-bottom: 20px;
}

.logout li a {
  display: flex;
  align-items: center;
  padding: 12px;
  text-decoration: none;
  color: #4a4da5;
  font-weight: bold;
  transition: background 0.2s, color 0.2s;
  justify-content: flex-start;
  width: 100%;
  box-sizing: border-box;
}

.main-menu:not(.expanded) .logout li a {
  padding: 12px 0;
  justify-content: center;
}

.logout li a:hover {
  background: #b3adea;
  color: white;
}

.logout .nav-text {
  font-size: 1em;
  opacity: 0;
  max-width: 0;
}

.main-menu.expanded .logout .nav-text {
  opacity: 1;
  max-width: 200px;
}
</style>
