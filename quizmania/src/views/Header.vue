<template>
  <div>
    <!-- Header se mantiene igual -->
    <header class="header">
      <div class="logo">
        <router-link to="/" class="nav-link">
          <img src="../assets/logo.png" alt="Logo" />
        </router-link>
      </div>
      <h1 class="titulo">
        <router-link to="/" class="nav-link"> QuizMania </router-link>
      </h1>
      <nav class="nav">
        <ul class="nav-list">
          <li class="nav-item">
            <router-link to="/perfil" class="nav-link">
              <img
                src="https://cdn-icons-png.flaticon.com/512/6522/6522581.png"
                alt="Foto de perfil"
                class="profile-pic"
              />
            </router-link>
          </li>
          <li class="nav-item">
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

    <!-- Sidebar con logout fijo abajo -->
    <div class="sidebar" :class="{ 'sidebar-open': showSidebar }">
      <nav class="sidebar-nav">
        <ul class="sidebar-list">
          <li class="sidebar-item">
            <router-link to="/perfil" class="sidebar-link">
              <span>PERFIL</span>
            </router-link>
          </li>
          <li class="sidebar-item">
            <router-link to="/ranking" class="sidebar-link">
              <span>RÁNKING</span>
            </router-link>
          </li>
          <li class="sidebar-item">
            <router-link to="/estadisticas" class="sidebar-link">
              <span>ESTADÍSTICAS</span>
            </router-link>
          </li>
        </ul>
      </nav>
      <!-- Botón de logout fijo abajo -->
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
          Cerrar Sesión
        </button>
      </div>
    </div>

    <!-- Overlay se mantiene igual -->
    <div v-if="showSidebar" class="overlay" @click="toggleSidebar"></div>
  </div>
</template>

<script>
export default {
  name: "Header",
  data() {
    return {
      showSidebar: false,
    };
  },
  methods: {
    toggleSidebar() {
      this.showSidebar = !this.showSidebar;
      document.body.style.overflow = this.showSidebar ? "hidden" : "auto";
    },
    handleLogout() {
      // Aquí puedes agregar la lógica para cerrar sesión
      console.log("Cerrando sesión...");
      // Por ejemplo:
      // this.$store.dispatch('logout');
      // this.$router.push('/login');
    },
  },
};
</script>

<style scoped>
.header {
  font-family: "Roboto", sans-serif;
  display: flex;
  justify-content: space-between;
  align-items: center;
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
  margin: 0;
  transition: transform 0.3s ease;
  font-size: 3rem;
}

.titulo .nav-link {
  font-size: inherit;
  color: inherit;
  text-decoration: none;
}

.titulo:hover {
  transform: scale(1.05);
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
}
</style>
