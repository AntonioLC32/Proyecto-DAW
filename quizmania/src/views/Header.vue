<template>
  <div v-if="!['/juego', '/selecciontema'].includes($route.path)">
    <header class="header">
      <div class="logo">
        <router-link to="/" class="nav-link">
          <img src="../assets/logo.png" alt="Logo" />
        </router-link>
      </div>
      <h1 class="titulo titulo--default">
        <router-link to="/" class="nav-link">QuizMania</router-link>
      </h1>
      <nav class="nav">
        <ul class="nav-list">
          <li v-if="userData" class="nav-item">
            <router-link to="/perfil" class="nav-link perfil">
              <img
                :src="getImageUserUrl(userData.imagen)"
                alt="Foto de perfil"
                class="profile-pic"
              />
            </router-link>
          </li>
          <li v-else class="nav-item">
            <router-link to="/login" class="nav-link perfil">
              <img
                src="../assets/users/default/default.png"
                alt="Foto de perfil"
                class="profile-pic"
              />
            </router-link>
          </li>
          <li v-if="userData" class="nav-item">
            <button class="btn-sidebar" @click="toggleSidebar">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="hamburger-icon"
                :class="{ rotate: showSidebar }"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                />
              </svg>
            </button>
          </li>
        </ul>
      </nav>
    </header>
    <div class="sidebar" :class="{ 'sidebar-open': showSidebar }">
      <nav class="sidebar-nav">
        <ul class="sidebar-list">
          <li class="sidebar-item">
            <router-link to="/perfil" class="sidebar-link">
              <span>{{ textosTraducidos["PERFIL"] || "PERFIL" }}</span>
            </router-link>
          </li>
          <li class="sidebar-item">
            <router-link to="/ranking" class="sidebar-link">
              <span>{{ textosTraducidos["RANKING"] || "RANKING" }}</span>
            </router-link>
          </li>
          <li class="sidebar-item">
            <router-link to="/estadisticas" class="sidebar-link">
              <span>{{
                textosTraducidos["ESTADÍSTICAS"] || "ESTADÍSTICAS"
              }}</span>
            </router-link>
          </li>
          <li v-if="userData && userData.rol === 'admin'" class="sidebar-item">
            <router-link to="/admin" class="sidebar-link">
              <span>{{ textosTraducidos["ADMIN"] || "ADMIN" }}</span>
            </router-link>
          </li>
        </ul>
      </nav>
      <div class="logout-container">
        <button class="logout-button" @click="handleLogout">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="logout-icon"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15M12 9l-3 3m0 0l3 3m-3-3h12.75"
            />
          </svg>
          {{ textosTraducidos["Cerrar Sesión"] || "Cerrar Sesión" }}
        </button>
      </div>
    </div>
    <div v-if="showSidebar" class="overlay" @click="toggleSidebar"></div>
  </div>
  <div v-else-if="$route.path === '/juego'">
    <header class="header header--centered">
      <div v-if="width > 480" class="logo">
        <img src="../assets/logo.png" alt="Logo" />
      </div>
      <div class="juego-container">
        <div class="timer" :style="{ color: timerColor }">{{ timer }}</div>
        <div class="category-info">
          <h1 class="titulo">{{ nombreCategoria }}</h1>
          <img
            :src="getImageUrl(imagenCategoria)"
            :alt="nombreCategoria"
            class="category-image"
          />
        </div>
      </div>
    </header>
  </div>
  <div v-else-if="$route.path === '/selecciontema'">
    <header class="header header--centered">
      <div class="logo">
        <img src="../assets/logo.png" alt="Logo" />
      </div>
      <div class="seleccion-container">
        <h1 class="titulo">{{ tituloRonda }}</h1>
      </div>
    </header>
  </div>
</template>

<script>
import axios from "axios";
export default {
  name: "Header",
  data() {
    return {
      showSidebar: false,
      timer: 60,
      timerInterval: null,
      userData: null,
      width: window.innerWidth,
      height: window.innerHeight,
      idiomaUsuario: "es",
      textosTraducidos: {},
      traduccionesCargando: false,
      nombreCategoria: null,
      imagenCategoria: null,
      ronda: 1,
      imageMap: {
        Historia: "historia.png",
        Ciencia: "ciencia.png",
        Deportes: "deportes.png",
        Música: "musica.png",
        Entretenimiento: "entre.png",
        "Arte y Literatura": "arte.png",
        Geografía: "geografia.png",
        Matemáticas: "mates.png",
        Tecnología: "tecno.png",
        "Cultura General": "cultura.png",
      },
    };
  },
  computed: {
    timerColor() {
      if (this.timer > 40) {
        return "#36ec5f";
      } else if (this.timer > 20) {
        return "#ffc107";
      } else {
        return "#dc3545";
      }
    },
    tituloRonda() {
      return `${this.textosTraducidos["Ronda"] || "Ronda"} ${this.ronda}`;
    },
  },
  mounted() {
    this.userData = this.$cookies.get("user");
    this.ronda = parseInt(sessionStorage.getItem("ronda") || "1", 10);
    this.cargarUsuario();
    this.idiomaUsuario = navigator.language.split("-")[0] || "es";
    if (this.idiomaUsuario !== "es") {
      this.traducirContenido();
    }
    if (this.$route.path === "/juego") {
      this.iniciarTimer();
    }
    this.actualizarConexion();
  },
  beforeDestroy() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }
  },
  watch: {
    "$route.path"(newPath) {
      if (newPath === "/juego") {
        if (sessionStorage.getItem("nuevaPartida") === "true") {
          sessionStorage.setItem("tiempoRestante", "60");
          this.timer = 60;
          sessionStorage.removeItem("nuevaPartida"); // Limpia la marca
        }
        this.iniciarTimer();

        const categoriaOriginal = sessionStorage.getItem("categoria");
        if (categoriaOriginal) {
          if (this.idiomaUsuario !== "es") {
            this.traducirTexto(categoriaOriginal).then((trad) => {
              this.nombreCategoria = trad;
            });
          } else {
            this.nombreCategoria = categoriaOriginal;
          }
          this.imagenCategoria = this.imageMap[categoriaOriginal] || "";
        }
      } else if (this.timerInterval) {
        clearInterval(this.timerInterval);
        this.timerInterval = null;
      }
      if (newPath === "/selecciontema") {
        this.ronda = parseInt(sessionStorage.getItem("ronda") || "1", 10);
      }
    },
  },
  created() {
    window.addEventListener("resize", this.onResize);
  },
  destroyed() {
    window.removeEventListener("resize", this.onResize);
  },
  methods: {
    async cargarUsuario() {
      try {
        const response = await fetch("/api/perfil/select_perfil.php", {
          credentials: "include",
        });
        if (!response.ok)
          throw new Error(`Error HTTP! estado: ${response.status}`);
        const data = await response.json();
        if (data.error) {
          return;
        }
        this.userData = {
          ...this.userData,
          nombre: data.nombre || this.userData?.nombre,
          imagen: data.imagen || this.userData?.imagen,
        };
      } catch (error) {
        console.error("Error cargando perfil:", error.message);
      }
    },
    onResize() {
      this.width = window.innerWidth;
      this.height = window.innerHeight;
    },
    getImageUrl(path) {
      return new URL(`../assets/${path}`, import.meta.url).href;
    },
    getImageUserUrl(path) {
      return `src/${path}`;
    },
    iniciarTimer() {
      if (this.timerInterval) {
        clearInterval(this.timerInterval);
      }
      let tiempoGuardado = sessionStorage.getItem("tiempoRestante");
      if (tiempoGuardado !== null && parseInt(tiempoGuardado) > 0) {
        this.timer = parseInt(tiempoGuardado);
      } else {
        this.timer = 60;
        sessionStorage.setItem("tiempoRestante", "60");
      }
      this.timerInterval = setInterval(() => {
        if (this.timer > 0) {
          this.timer--;
          sessionStorage.setItem("tiempoRestante", this.timer.toString());
          const elapsed = 60 - this.timer;
          sessionStorage.setItem("tiempoTranscurrido", elapsed.toString());
          const minutes = Math.floor(elapsed / 60);
          const seconds = elapsed % 60;
          sessionStorage.setItem(
            "tiempoRonda",
            `${minutes.toString().padStart(2, "0")}:${seconds
              .toString()
              .padStart(2, "0")}`
          );
        } else {
          clearInterval(this.timerInterval);
          sessionStorage.removeItem("tiempoRestante");
          sessionStorage.setItem("tiempoTranscurrido", "60");
          sessionStorage.removeItem("tiempoRonda");
          window.dispatchEvent(new Event("tiempoAgotado"));
          this.resetTimer();
        }
      }, 1000);
    },
    resetTimer() {
      clearInterval(this.timerInterval);
      this.timer = 0;

      this.$nextTick(() => {
        this.timer = 60;
        sessionStorage.setItem("tiempoRestante", "60");
        this.iniciarTimer();
      });
    },
    preguntaContestada() {
      sessionStorage.removeItem("tiempoRestante");
      this.resetTimer();
    },
    toggleSidebar() {
      this.showSidebar = !this.showSidebar;
      document.body.style.overflow = this.showSidebar ? "hidden" : "auto";
    },
    handleLogout() {
      this.$cookies.remove("user");
      this.$router.push("/").then(() => {
        location.reload();
      });
    },
    async traducirTexto(texto) {
      if (/(^\d|:)/.test(texto) || this.idiomaUsuario === "es") return texto;
      try {
        const response = await axios.post("/api/index.php?action=traducir", {
          texto: texto,
          idioma_origen: "es",
          idioma_destino: this.idiomaUsuario,
        });
        return response.data.status === "success"
          ? response.data.traduccion
          : texto;
      } catch (error) {
        console.error("Error en traducción:", error);
        return texto;
      }
    },
    async traducirContenido() {
      this.traduccionesCargando = true;
      const textosOriginales = [
        "PERFIL",
        "RANKING",
        "ESTADÍSTICAS",
        "ADMIN",
        "Cerrar Sesión",
        "Ronda",
      ];
      const traducciones = await Promise.all(
        textosOriginales.map((texto) => this.traducirTexto(texto))
      );
      textosOriginales.forEach((texto, index) => {
        this.textosTraducidos[texto] = traducciones[index];
      });
      this.traduccionesCargando = false;
    },
    async actualizarConexion() {
      try {
        const response = await axios.post(
          "/api/index.php?action=actualizarConexion"
        );
        if (response.data.status === "success") {
          console.log("Conexión actualizada correctamente");
        } else {
          console.error(
            "Error al actualizar la conexión:",
            response.data.error
          );
        }
      } catch (error) {
        console.error("Error al realizar la solicitud:", error);
      }
    },
  },
};
</script>

<style scoped>
.header {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 2rem;
  background-color: #8d89f9;
  color: #fff;
  height: 90px;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.titulo {
  font-family: "Montserrat", sans-serif;
  font-weight: 700;
  font-size: 3rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.titulo--default {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  margin: 0;
  transition: transform 0.3s ease;
}

.titulo .nav-link {
  font-size: inherit;
  color: inherit;
  text-decoration: none;
}

.nav-link img {
  width: 32px;
  height: 32px;
  object-fit: cover;
  border-radius: 50%;
  transition: transform 0.3s ease;
}

.nav-link img:hover {
  transform: scale(1.1);
}

.logo img {
  height: 75px;
  width: 75px;
  object-fit: contain;
  transition: transform 0.3s ease;
}

.logo img:hover {
  transform: scale(1.05);
}

.nav-list {
  list-style: none;
  display: flex;
  align-items: center;
  margin: 0;
  padding: 0;
  gap: 1.5rem;
}

.nav-item {
  margin-left: 0;
}

.nav-link {
  color: #fff;
  text-decoration: none;
  font-size: 1.1rem;
  display: flex;
  align-items: center;
}

.btn-sidebar {
  background-color: transparent;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  display: flex;
  align-items: center;
  transition: transform 0.3s ease;
}

.btn-sidebar:hover {
  transform: scale(1.1);
}

.hamburger-icon {
  width: 32px;
  height: 32px;
  color: white;
  transition: transform 0.3s ease;
}

.hamburger-icon.rotate {
  transform: rotate(90deg);
}

.sidebar {
  font-family: "Roboto", sans-serif;
  position: fixed;
  top: 90px;
  right: -280px;
  width: 280px;
  height: calc(100vh - 90px);
  background-color: #5759cd;
  transition: right 0.3s ease;
  z-index: 99;
  box-shadow: -2px 0 4px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
}

.sidebar-open {
  right: 0;
}

.sidebar-nav {
  flex-grow: 1;
  overflow-y: auto;
}

.sidebar-list {
  list-style: none;
  padding: 1rem 0;
  margin: 0;
}

.sidebar-item {
  padding: 0.5rem 1.5rem;
}

.sidebar-link {
  color: white;
  text-decoration: none;
  font-size: 1.1rem;
  display: block;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.sidebar-link:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

.logout-container {
  padding: 1.5rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: #5759cd;
}

.logout-button {
  width: 100%;
  padding: 0.75rem;
  background-color: rgba(255, 255, 255, 0.1);
  border: none;
  border-radius: 8px;
  color: white;
  font-size: 1.1rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
}

.logout-button:hover {
  background-color: rgba(255, 255, 255, 0.2);
}

.logout-icon {
  width: 20px;
  height: 20px;
}

.overlay {
  position: fixed;
  top: 60px;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 98;
}

.juego-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 2rem;
  width: 100%;
}

.timer {
  font-size: 2rem;
  font-weight: bold;
  font-family: "Montserrat", sans-serif;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.category-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.category-title {
  font-size: 2rem;
  margin: 0;
}

.category-image {
  height: 50px;
  width: 50px;
  object-fit: contain;
}

.header--centered {
  justify-content: center;
}

.header--centered .logo {
  position: absolute;
  left: 2rem;
}

.seleccion-container,
.juego-container {
  display: flex;
  align-items: center;
  justify-content: center;
}

@media (max-width: 768px) {
  .header {
    padding: 0.5rem 1rem;
  }

  .logo img {
    height: 60px;
    width: 60px;
  }

  .titulo {
    font-size: 2rem;
  }
}

@media (max-width: 480px) {
  .titulo {
    font-size: 2rem;
  }

  .perfil {
    display: none;
  }
}
</style>
