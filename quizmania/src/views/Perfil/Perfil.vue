<template>
  <section>
    <div class="perfil">
      <div class="perfil-title">
        <h1>PERFIL</h1>
      </div>

      <div class="division">
        <!-- Perfil -->
        <div class="perfil-vista">
          <img src="../../assets/perfil.jpg" alt="Perfil Image"
            style="border-radius: 50%;" />
          <h3 class="text-white">PEPE_123ASD</h3>
          <h4>¡Comparte tu perfil <br> con tus amigos!</h4>
          <div class="d-flex text-white">
            <i class="fa-brands fa-instagram"></i>
            <i class="fa-solid fa-share"></i>
          </div>
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
              <div v-if="activeTab === 'ajustes'" class="tab-pane" :class="{ 'show active': activeTab === 'ajustes' }">
                <h1 class="ajustes-title text-white">Ajustes de la Cuenta</h1>

                <form @submit.prevent="saveSettings">
                  <label for="nombre">Nombre</label><br />
                  <input v-model="settings.name" type="text" placeholder="PEPE_123ASD" class="form-control mb-3" />
                  <label for="correo">Correo electrónico</label><br />
                  <input v-model="settings.email" type="email" placeholder="pepe123asdf@correo.com"
                    class="form-control mb-3" />
                  <label>Desea recibir notificaciones?</label>
                  <div class="form-check">
                    <input v-model="settings.notifications" type="radio" name="notificaciones" id="si" value="si"
                      checked />
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
              <div v-if="activeTab === 'estadisticas'" class="tab-pane"
                :class="{ 'show active': activeTab === 'estadisticas' }">
                <h1 class="ajustes-title text-white">Estadísticas</h1>
                <div class="estadisticas-container">
                  <div class="estadistica-item">
                    <h4>Pos. Última Partida</h4>
                    <p class="estadistica-valor">{{ stats.lastPosition }}</p>
                  </div>
                  <div class="estadistica-item">
                    <h4>Puntos Última Partida</h4>
                    <p class="estadistica-valor">{{ stats.lastPoints }}</p>
                  </div>
                  <div class="estadistica-item">
                    <h4>Categoría Destacada</h4>
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
        featuredCategoryImage: '../../assets/entre.png'
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
  box-sizing: border-box;
  font-family: "Montserrat", sans-serif;
}

section {
  background: linear-gradient(340deg, #8d89f9 0%, #2c2d67 100%);
  min-height: 100vh;
  height: auto;
  overflow: auto;
}

.perfil {
  margin-top: 46px;
  margin-left: 48px;
  margin-right: 48px;
}

.perfil-title {
  background-color: #2C2D67;
  border: 5px solid #21224F;
  border-radius: 8px;
  padding-top: 25px;
  padding-bottom: 25px;
  margin-bottom: 25px;
  height: auto;
  max-height: 150px;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}

.perfil-title h1 {
  filter: drop-shadow(0 4px 4px #00000073);
  /* drop shadow */
  font-weight: bold;
  font-size: 48px;
  color: #fff;
}

.division {
  width: 100%;
  display: flex;
  height: auto;
  min-height: 680px;
  max-height: 680px;
}

.perfil-vista {
  background-color: #2C2D67;
  border: 5px solid #21224F;
  border-radius: 8px;
  width: 30%;
  /* 30% of the container width */
  height: auto;
  align-items: center;
  text-align: center;
  padding: 20px;
  font-weight: bold;
}

.perfil-vista img {
  margin-bottom: 20px;
  margin-top: 47px;
  width: 100%;
  height: auto;
  max-width:250px; 
  max-height:275px;
}

.perfil-vista h3 {
  font-weight: bold;
  font-size: 32px;
}

.perfil-vista i {
  filter: drop-shadow(0 4px 4px #00000073);
  /* drop shadow */
}

.perfil-vista h4 {
  font-weight: bold;
  font-size: 20px;
  color: #8D89F9;
  filter: drop-shadow(0 4px 4px #00000073);
  /* drop shadow */
}

.ajustes {
  background-color: #2C2D67;
  border: 5px solid #21224F;
  width: 70%;
  height: auto;
  margin-left: 30px;
  border-radius: 8px;
}

.tab-content {
  border-radius: 8px;
  display: flex;
  width: 100%;
  flex-direction: column;
  align-items: center;
  height: auto;
}

.tab-content>.active {
  display: flex;
  align-items: center;
  flex-direction: column;
  width: 100%;
}


.tab-content form {
  background-color: #fff;
  padding: 24px;
  border: 1px solid #fff;
  border-radius: 8px;
  height: auto;
  width: 100%;
  max-width: 320px;
  max-height: 400px;
}

.ajustes-title {
  font-size: 48px;
  font-weight: bold;
  text-align: center;
  margin-top: 35px;
  margin-bottom: 35px;
}

.estadisticas-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding-left: 100px;
  padding-right: 100px;
  width: 100%;
}

.estadistica-item {
  background-color: #4A4DA5;
  color: #fff;
  padding: 20px;
  border-radius: 10px;
  display: flex;
  text-align: left;
  justify-content: space-between;
  filter: drop-shadow(0 4px 4px #00000073);
  /* drop shadow */
  align-items: center;
  width: 100%;
  height: auto;
  max-height: 80px;
}

.estadistica-item h4 {
  font-size: 24px;
  filter: drop-shadow(0 4px 4px #00000073);
  /* drop shadow */
  margin: 0;
}

.estadistica-valor {
  font-size: 24px;
  font-weight: bold;
  margin: 0;
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

.nav-tabs {
  display: flex;
  width: 100%;
  border-radius: 8px;
  /* Ocupa todo el ancho */
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
  border: 5px solid #21224F;
  border-bottom: 0px;
  text-decoration: none;
  border-radius: 8px;
}

.nav-link.active {
  background-color: #8d89f9;
  border: 5px solid #21224F;
}

.nav-link.active:hover {
  border: 5px solid #21224F;

}

.nav-tabs li:hover a {
  border: 5px solid #8d89f9;

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
</style>
