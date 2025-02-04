<template>
  <div>
    <section>
      <div class="container-fluid title">
        <h1><b>Ránking Global</b></h1>
      </div>
      <div class="container-fluid pantalla-ranking">
        <div class="perfil-vista">
          <img
            src="../../assets/perfil.jpg"
            alt="Perfil Image"
            width="250"
            height="275"
            style="border-radius: 50%"
          />
          <h3 class="text-white">{{ perfil.nombre }}</h3>
          <div>
            <p><u>Estadísticas</u></p>
            <div class="d-flex posicion">
              <p class="me-2"><u>Última posición:</u></p>
              <div class="num text-white">
                <u><b>{{ perfil.posicion }}</b></u>
              </div>
            </div>
          </div>
        </div>
        <div class="ranking">
          <table>
            <thead>
              <tr>
                <th>Jugador</th>
                <th>Posición</th>
                <th>Puntos</th>
                <th>Categoría Destacada</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(jugador, index) in ranking" :key="index">
                <td class="jugador">{{ jugador.nombre }}</td>
                <td class="posicion">{{ jugador.posicion }}</td>
                <td class="puntos">{{ jugador.puntos }}</td>
                <td class="categoria">
                  <img :src="jugador.entreImage" alt="" width="100%" height="60" />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref } from "vue";
import entreImage from "../../assets/entre.png";

const perfil = ref({
  nombre: "PEPE_123ASD",
  posicion: 1,
});

const ranking = ref([
  {
    nombre: "PEPE_123ASD",
    posicion: 1,
    puntos: 15648,
    categoria: entreImage,
  },
  {
    nombre: "PEPESITO",
    posicion: 2,
    puntos: 15648,
    categoria: entreImage,
  },
  {
    nombre: "PEPE",
    posicion: 3,
    puntos: 15648,
    categoria: entreImage,
  },
  {
    nombre: "MARIA_ABCD",
    posicion: 4,
    puntos: 15432,
    categoria: entreImage,
  },
  {
    nombre: "JUAN_XYZ",
    posicion: 5,
    puntos: 15210,
    categoria: entreImage,
  },
  {
    nombre: "ANA_321",
    posicion: 6,
    puntos: 15100,
    categoria: entreImage,
  },
  {
    nombre: "LUIS_654",
    posicion: 7,
    puntos: 15000,
    categoria: entreImage,
  },
  {
    nombre: "CARLA_987",
    posicion: 8,
    puntos: 14850,
    categoria: entreImage,
  },
  {
    nombre: "PEDRO_KLM",
    posicion: 9,
    puntos: 14700,
    categoria: entreImage,
  },
  {
    nombre: "SOFIA_GHI",
    posicion: 10,
    puntos: 14560,
    categoria: entreImage,
  },
]);
</script>

<style scoped>
* {
  box-sizing: border-box;
  font-family: "Montserrat", sans-serif;
}

section {
  background: linear-gradient(190deg, #8d89f9 0%, #2c2d67 100%);
  color: #fff;
  overflow: auto;
  margin-top: 60px;
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

.title {
  height: 98px;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #fff;
  font-size: 48px;
  text-shadow: 0 4px 4px rgba(0, 0, 0, 0.2);
}

.pantalla-ranking {
  display: flex;
  justify-content: flex-end;
  padding: 20px;
  align-items: flex-start;
  height: auto;
  max-height: 100vh;
  width: 100%;
  padding-left: 50px;
  padding-right: 50px;
}

.perfil-vista {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex-wrap: nowrap;
  background-color: #000;
  border: 5px solid #21224f;
  border-radius: 8px;
  width: 30%; /* 30% of the container width */
  text-align: center;
  padding: 30px;
  font-weight: bold;
  margin-top: 80px;
  max-height: 80vh;
  min-height: 680px;
}

.perfil-vista img {
  margin-bottom: 20px;
  margin-top: 47px;
  width: 100%;
  height: auto;
  max-width: 250px;
  max-height: 275px;
}

.perfil-vista h3 {
  font-weight: bold;
  font-size: 20px;
}

.perfil-vista i {
  filter: drop-shadow(0 4px 4px #00000073);
  /* drop shadow */
}

.perfil-vista h4 {
  font-weight: bold;
  font-size: 15px;
  color: #8d89f9;
  filter: drop-shadow(0 4px 4px #00000073);
  /* drop shadow */
}

.perfil-vista p {
  font-weight: bold;
  font-size: 15px;
}

.pantalla-ranking p,
h3.num {
  color: #fff !important;
}

.posicion {
  align-items: center;
  flex-wrap: nowrap;
}

.num {
  display: flex;
  align-items: center;
  background-color: #4a4da5;
  padding: 20px;
  height: 48px;
  line-height: 48px;
  margin: 10px auto;
  font-size: 15px;
}

.ranking {
  width: 70%; /* 70% of the container width */
  height: 100%;
  max-height: 80vh;
  overflow: auto;
  display: flex;
  flex-direction: column;
  border: 5px solid #21224f;
  margin-left: 30px;
  background-color: #000;
  border-radius: 8px !important;
  padding-left: 20px !important;
  padding-right: 20px !important;
}

.ranking table {
  height: 100%;
  width: 100%;
  table-layout: fixed;
  border-collapse: unset;
  text-align: center;
  border-spacing: 7px !important;
}
.ranking tbody {
  flex-grow: 1;
}
.ranking tr {
  height: 50px !important;
}

.ranking th {
  padding: 10px;
  font-size: 15px;
  text-decoration: underline;
  color: #fff !important;
  text-align: center;
}

.ranking .jugador,
.ranking .posicion,
.ranking .puntos,
.ranking .categoria {
  border-radius: 8px;
  color: #fff !important;
  padding: 10px;
  padding-top: 5px;
  padding-bottom: 5px;
  text-align: center;
}

.ranking .jugador {
  background: linear-gradient(#2c2d67 0%, #5759cd 50%, #2c2d67 100%);
  box-shadow: 0 4px 4px rgba(0, 0, 0, 0.2);
  font-size: 15px;
  font-weight: bold;
}

.ranking .puntos {
  background-color: #2c2d67;
  box-shadow: 0 4px 4px rgba(0, 0, 0, 0.2);
  font-size: 20px;
  font-weight: bold;
  text-shadow: 0 4px 4px rgba(0, 0, 0, 0.2);
}

.ranking .categoria {
  background-color: #fff;
  color: #000 !important;
}

.ranking .posicion {
  background-color: #cac5f5;
  font-size: 25px;
  text-decoration: underline;
  font-weight: bold;
  text-shadow: 0 4px 4px rgba(0, 0, 0, 0.2);
}

@media (max-width: 768px) {
  .pantalla-ranking {
    flex-direction: column;
    align-items: center;
    width: 100%;
    gap: 20px;
    max-height: unset;
    padding: 20px;

  }

  .perfil-ranking,
  .ranking {
    width: 100%;
    margin-left: 0;
    padding-left: 0;
  }

  .perfil-vista {
    width: 100%;
    margin-top: 0;
    height: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 15px;
    padding: 20px;
    min-height: auto;
    text-align: center;
  }

  .perfil-vista img {
    width: 90px;
    height: 90px;
    border-radius: 50%;
  }

  .perfil-vista h3 {
    font-size: 20px;
    margin: 0;
  }

  .perfil-vista > div {
    display: flex;
    flex-direction: column;
    align-items: center; 
    width: 100%;
  }

  .perfil-vista .posicion {
    display: flex;
    align-items: center;
    gap: 5px;
  }

  /* Tabla responsive */
  .ranking {
    width: 100%;
    overflow-x: auto; /* Permite desplazamiento horizontal */
    padding: 10px;
  }

  .ranking table {
    width: 100%;
    display: block;
    overflow-x: auto;
    white-space: nowrap; /* Evita que las celdas se rompan en varias líneas */
  }

  .ranking th,
  .ranking td {
    font-size: 14px; /* Reduce tamaño de fuente */
    padding: 5px; /* Reduce espacio en celdas */
  }

  .ranking .categoria img {
    height: 40px; /* Reduce tamaño de imágenes */
    width: auto;
  }
}


</style>
