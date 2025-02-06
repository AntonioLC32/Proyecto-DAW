<template>
  <section>
    <div class="encase">
      <div class="container-fluid title text-white">
        <h1>Tus Estadísticas</h1>
      </div>
      <div class="container-fluid pantalla-estadisticas">
        <div class="perfil-vista">
          <div class="d-flex nombre-img">
            <img
              src="../../assets/perfil.jpg"
              alt="Perfil Image"
              width="250"
              height="275"
              class="perfil-img"
            />
            <h3 class="text-white">{{ perfil.nombre }}</h3>
          </div>
          <br />
          <p><u>ESTADÍSTICAS GENERALES</u></p>
          <div class="est-generales">
            <div class="stat-item">
              <p class="me-2">Última posición:</p>
              <div class="num text-white">
                <b>{{ perfil.posicion }}</b>
              </div>
            </div>
            <div class="stat-item">
              <p class="me-2">Puntos Totales:</p>
              <div class="num text-white">
                <b>{{ perfil.puntos }}</b>
              </div>
            </div>
            <div class="stat-item">
              <p class="me-2">Juegos Jugados:</p>
              <div class="num text-white">
                <b>{{ perfil.juegosJugados }}</b>
              </div>
            </div>
            <div class="stat-item">
              <p class="me-2">Categoria Destacada:</p>
              <div class="num text-white">
                <img
                :src="perfil.categoria"
                alt="Categoría"
                class="cat-img"
              />
              </div>
            </div>
          </div>
        </div>

        <div class="estadisticas">
          <div class="estadisticas-grid">
            <div
              v-for="(categoria, index) in estadisticas"
              :key="index"
              class="estadisticas-item"
            >
              <img
                :src="categoria.categoria"
                alt="Categoría"
                class="estadisticas-img"
              />
              <p class="puntos">{{ categoria.puntos }} pts</p>
              <p class="posicion">#{{ categoria.mejorPosicion }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref } from "vue";
import entreImage from "../../assets/entre.png";

const perfil = ref({
  nombre: "PEPE_123ASD",
  posicion: 1,
  puntos: 15648,
  juegosJugados: 120,
  categoria: entreImage,
});

const estadisticas = ref([
  { categoria: entreImage, puntos: 5600, mejorPosicion: 1 },
  { categoria: entreImage, puntos: 4200, mejorPosicion: 3 },
  { categoria: entreImage, puntos: 3200, mejorPosicion: 5 },
  { categoria: entreImage, puntos: 2648, mejorPosicion: 7 },
  { categoria: entreImage, puntos: 2400, mejorPosicion: 8 },
  { categoria: entreImage, puntos: 2000, mejorPosicion: 10 },
  { categoria: entreImage, puntos: 1800, mejorPosicion: 12 },
  { categoria: entreImage, puntos: 1500, mejorPosicion: 15 },
  { categoria: entreImage, puntos: 1200, mejorPosicion: 18 },
]);
</script>

<style scoped>
* {
  box-sizing: border-box;
  font-family: "Montserrat", sans-serif;
}

section {
  background-color: #cac5f5;
  min-height: 100vh;
  overflow-y: hidden;
}

.encase {
  margin: 110px 48px 0 48px;
}

.title {
  background-color: #5759cd;
  border: 5px solid #4a4da5;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.title h1 {
  color: #fff;
  font-size: 48px;
  font-weight: bold;
  filter: drop-shadow(0 4px 4px #00000073);
}

.pantalla-estadisticas {
  display: flex;
  align-items: flex-start;
  width: 100%;
  padding: 0;
  gap: 50px;
}

.perfil-vista {
  display: flex;
  flex-direction: column;
  align-items: center;
  background-color: #5759cd;
  filter: drop-shadow(0 2px 2px #00000073);
  border-radius: 8px;
  width: 30%;
  text-align: center;
  padding: 30px;
  font-weight: bold;
  min-height: 680px;
}

.perfil-img {
  border-radius: 50%;
  height: auto;
  width: 200px;
}

.perfil-vista h3 {
  font-size: 32px;
  font-weight: bold;
  color: #fff;
}

.perfil-vista p {
  font-size: 20px;
  color: #fff;
}

.nombre-img {
  display: flex;
  align-items: center;
  gap: 30px;
  padding: 20px 0;
}

.est-generales {
  display: flex;
  flex-direction: column;
  gap: 10px;
  width: 100%;
  background-color: #4a4da5;
  padding: 20px;
  border-radius: 8px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.num {
  background-color: #8d89f8;
  padding: 10px 20px;
  border-radius: 5px;
  font-size: 24px;
  font-weight: 400;
  color: #fff;
}

/* estadisticas GRID */
.estadisticas {
  width: 70%;
  background-color: #5759cd;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  filter: drop-shadow(0 2px 2px #00000073);
}

.estadisticas-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 15px;
  width: 100%;
}

.estadisticas-item {
  background-color: #4a4da5;
  padding: 15px;
  border-radius: 8px;
  text-align: center;
  color: #fff;
  font-weight: bold;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  filter: drop-shadow(0 2px 2px #00000073);
}

.cat-img {
  width: 60px !important;
  height: 60px !important;
  border-radius: 8px;
}


.estadisticas-img {
  width: 60px;
  height: 60px;
  margin-bottom: 10px;
  border-radius: 8px;
}

.puntos {
  font-size: 20px;
}

.posicion {
  font-size: 18px;
}

/* RESPONSIVE */
@media (max-width: 1024px) {
  .pantalla-estadisticas {
    flex-direction: column;
    align-items: center;
    width: 100%;
    gap: 20px;
    padding: 0;
  }

  .perfil-vista,
  .estadisticas {
    width: 100%;
    margin-left: 0;
  }

  .perfil-vista {
    min-height: auto;
    text-align: center;
  }

  .perfil-vista img {
    width: 150px;
    height: 150px;
  }

  .estadisticas-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .pantalla-estadisticas {
    gap: 20px;
    padding: 20px;
  }

  .perfil-vista {
    width: 100%;
    padding: 20px;
    text-align: center;
  }

  .perfil-vista img {
    width: 120px;
    height: 120px;
  }

  .perfil-vista h3 {
    font-size: 20px;
  }

  .estadisticas {
    width: 100%;
    padding: 10px;
  }

  .estadisticas-grid {
    grid-template-columns: repeat(1, 1fr);
  }

  .estadisticas-img {
    width: 50px;
    height: 50px;
  }

  .puntos,
  .posicion {
    font-size: 16px;
  }
}
</style>
