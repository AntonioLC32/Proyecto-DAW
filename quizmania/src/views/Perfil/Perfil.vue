<template>
  <section>
    <div class="container-fluid pantalla-ranking">
      <!-- Perfil -->
      <div class="perfil-ranking">
        <div class="perfil-title">
          <h1><b>PERFIL</b></h1>
        </div>
        <img src="../../assets/perfil.jpg" alt="Perfil Image" width="250px" height="275px" style="border-radius: 50%;" />
        <h3 class="text-white"><b>{{ username }}</b></h3>
      </div>

      <!-- Opciones (Tabs) -->
      <div class="ajustes">
        <div class="container-fluid p-0">
          <ul class="nav nav-tabs w-100">
            <li class="nav-item" style="width: 50%; text-align: center;">
              <a @click="setTab('ajustes')" :class="{ active: activeTab === 'ajustes' }" class="nav-link">
                Ajustes
              </a>
            </li>
            <li class="nav-item" style="width: 50%; text-align: center;">
              <a @click="setTab('estadisticas')" :class="{ active: activeTab === 'estadisticas' }" class="nav-link">
                Estadísticas
              </a>
            </li>
          </ul>
          <div class="tab-content">
            <div v-if="activeTab === 'ajustes'" class="tab-pane fade in active">
              <h1 class="ajustes-title text-white"><b>Ajustes de la Cuenta</b></h1>
              <form @submit.prevent="saveSettings">
                <label for="nombre">Nombre</label><br />
                <input v-model="settings.name" type="text" placeholder="PEPE_123ASD" class="form-control mb-3" />
                <label for="correo">Correo electrónico</label><br />
                <input v-model="settings.email" type="email" placeholder="pepe123asdf@correo.com" class="form-control mb-3" />
                <label>Desea recibir notificaciones?</label>
                <div class="form-check">
                  <input v-model="settings.notifications" type="radio" name="notificaciones" id="si" value="si" checked />
                  <label for="si">Sí</label><br />
                  <input v-model="settings.notifications" type="radio" name="notificaciones" id="no" value="no" />
                  <label for="no">No</label>
                </div>
                <button class="btn btn-dark w-100 mt-3">
                  <i class="fa fa-save"></i> Guardar Ajustes
                </button>
              </form>
            </div>

            <!-- Contenido de Estadísticas -->
            <div v-if="activeTab === 'estadisticas'" class="tab-pane fade">
              <h1 class="ajustes-title text-white"><b>Estadísticas</b></h1>
              <div class="estadisticas-container">
                <div class="estadistica-item">
                  <h4 class="me-5">Pos. Última Partida</h4>
                  <p class="estadistica-valor">{{ stats.lastPosition }}</p>
                </div>
                <div class="estadistica-item">
                  <h4 class="me-5">Puntos Última Partida</h4>
                  <p class="estadistica-valor">{{ stats.lastPoints }}</p>
                </div>
                <div class="estadistica-item">
                  <h4 class="me-5">Categoría Destacada</h4>
                  <p class="estadistica-valor">
                    <img :src="stats.featuredCategoryImage" alt="Categoría" style="width: 150px;" />
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: "Perfil",
  data() {
    return {
      activeTab: 'ajustes', // Estado para manejar las pestañas
      username: 'PEPE_123ASD',
      settings: {
        name: 'PEPE_123ASD',
        email: 'pepe123asdf@correo.com',
        notifications: 'si'
      },
      stats: {
        lastPosition: 1,
        lastPoints: 15648,
        featuredCategoryImage: 'imgs/entre.png'
      }
    };
  },
  methods: {
    setTab(tab) {
      this.activeTab = tab;
    },
    saveSettings() {
      console.log('Settings saved:', this.settings);
    }
  }
};
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "Montserrat", sans-serif;
}

html {
  height: 100vh !important;
  overflow: hidden;
}

body {
  background: conic-gradient(
    from 340deg,
    #8d89f9 0%,
    #5759cd 55%,
    #2c2d67 100%
  );
  color: #fff;
}

.navbar {
  background-color: #8d89f9;
  height: 92px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  box-shadow: 0 4px 4px rgba(0, 0, 0, 0.2);
}

.navbar .logo {
  margin-left: 20px;
}

.navbar a {
  color: #000;
  font-size: 16px;
  font-weight: bold;
  text-decoration: none;
  margin: 0 10px;
}

.perfil-title {
  background-color: #5759cd;
  color: #fff;
  font-size: 48px;
  font-weight: bold;
  height: 151px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.tab-content {
  display: flex;
  justify-content: center;
  width: 100%;
  flex-direction: column;
  align-items: stretch;
}

.tab-content form {
  background-color: #fff;
  padding: 24px;
  border: 1px solid #fff;
  border-radius: 8px;
  margin-left: 350px;
  margin-right: 350px;
}

.ajustes-title {
  font-size: 71px;
  font-weight: bold;
  text-align: center;
  margin-top: 100px;
  margin-bottom: 100px;
}

.pantalla-ranking {
  display: flex;
  justify-content: flex-start;
  padding: 20px;
  align-items: flex-start;
  height: 100%;
  overflow-x: hidden;
  padding-left: 50px !important;
  padding-right: 250px !important;
}

.perfil-ranking {
  width: 30%; /* 30% of the container width */
  height: 100%;
  background-color: #000;
  border-top: 10px solid #4a4da5;
  border-left: 10px solid #4a4da5;
  border-right: 10px solid #4a4da5;
  border-radius: 8px;
  align-items: center;
  text-align: center;
  padding: 20px;
  font-weight: bold;
}

.perfil-ranking img {
  border-radius: 50%;
  margin-bottom: 20px;
  margin-top: 47px;
}

.pantalla-ranking p,
h3.num {
  color: #fff !important;
  font-weight: bold;
}

.posicion {
  align-items: center;
  flex-wrap: nowrap;
}

.num {
  background-color: #4a4da5;
  width: 60px;
  height: 48px;
  line-height: 48px;
  margin: 10px auto;
  font-size: 24px;
  font-weight: bold;
}

.ajustes {
  width: 70%;
  height: 100%;
  margin-left: 30px;
  background-color: #4a4da5;
  border-radius: 8px !important;
}

.nav-tabs {
  display: flex;
  width: 100%; /* Ocupa todo el ancho */
}

.nav-tabs li {
  flex: 1;
  text-align: center;
}

.nav-tabs li a {
  display: block;
  padding: 15px 0;
  font-size: 18px;
  font-weight: bold;
  color: #fff;
  background-color: #2c2d67;
  text-decoration: none;
  border-radius: 0;
}

.nav-tabs li.active a {
  background-color: #8d89f9 !important;
  border-top: 8px solid #CAC5F5 !important;
  border-left: 8px solid #CAC5F5 !important;
  border-right: 8px solid #CAC5F5 !important;
  border-bottom: 2px solid transparent;
}

.nav-tabs li:hover a {
  background-color: #6a6ecb !important;
}

.estadisticas-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-left: 100px;
  margin-right: 100px;
}

.estadistica-item {
  background-color: #2c2d67;
  color: #fff;
  padding: 20px;
  border-radius: 10px;
  display: flex;
  text-align: left;
  justify-content: space-between;
}

.estadistica-valor {
  font-size: 24px;
  font-weight: bold;
}
</style>
