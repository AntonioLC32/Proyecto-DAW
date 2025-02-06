<template>
  <section>
    <div class="encase">
      <div class="container-fluid title text-white">
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
            <p class="pos"><u>ESTADÍSTICAS</u></p>
            <div class="d-flex posicion">
              <p class="me-2">Última posición:</p>
              <div class="num text-white">
                <u
                  ><b>{{ perfil.posicion }}</b></u
                >
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
                  <img
                    :src="jugador.categoria"
                    alt=""
                    width="60px"
                    height="60px"
                  />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref } from "vue";
import arteImage from "../../assets/arte.png";
import cienciasImage from "../../assets/ciencias.png";
import culturaImage from "../../assets/cultura.png";
import entreImage from "../../assets/entre.png";
import geoImage from "../../assets/geografia.png";
import historiaImage from "../../assets/historia.png";
import matesImage from "../../assets/mates.png";
import tecnoImage from "../../assets/tecno.png";
import musicaImage from "../../assets/musica.png";
import deportesImage from "../../assets/deportes.png";

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
    categoria: arteImage,
  },
  {
    nombre: "PEPE",
    posicion: 3,
    puntos: 15648,
    categoria: geoImage,
  },
  {
    nombre: "MARIA_ABCD",
    posicion: 4,
    puntos: 15432,
    categoria: musicaImage,
  },
  {
    nombre: "JUAN_XYZ",
    posicion: 5,
    puntos: 15210,
    categoria: matesImage,
  },
  {
    nombre: "ANA_321",
    posicion: 6,
    puntos: 15100,
    categoria: tecnoImage,
  },
  {
    nombre: "LUIS_654",
    posicion: 7,
    puntos: 15000,
    categoria: cienciasImage,
  },
  {
    nombre: "CARLA_987",
    posicion: 8,
    puntos: 14850,
    categoria: culturaImage,
  },
  {
    nombre: "PEDRO_KLM",
    posicion: 9,
    puntos: 14700,
    categoria: historiaImage,
  },
  {
    nombre: "SOFIA_GHI",
    posicion: 10,
    puntos: 14560,
    categoria: deportesImage,
  },
]);
</script>

<style scoped lang="css">
* {
  box-sizing: border-box;
  font-family: "Montserrat", sans-serif;
}

section {
  background-color: #cac5f5;
  min-height: 100vh;
  height: 100%;
  overflow-y: hidden;
}

.encase {
  margin-top: 110px;
  margin-left: 48px;
  margin-right: 48px;
}

.title {
  background-color: #5759cd;
  border: 5px solid #4a4da5;
  border-radius: 8px;
  padding-top: 20px;
  padding-bottom: 20px;
  margin-bottom: 20px;
  height: auto;
  max-height: 150px;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}

.pantalla-ranking {
  display: flex;
  justify-content: flex-end;
  padding: 20px;
  align-items: flex-start;
  height: auto;
  width: 100%;
  padding-top: 0;
  padding-bottom: 30px;
  padding-left: 0;
  padding-right: 0;
}

.perfil-vista {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex-wrap: nowrap;
  background-color: #5759cd;
  border-radius: 8px;
  width: 30%; /* 30% of the container width */
  text-align: center;
  padding: 30px;
  font-weight: bold;
  max-height: 80vh;
  min-height: 680px;
  filter: drop-shadow(0 4px 4px #00000073);
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

.pos > u {
  color: #5759cd !important;
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
  max-height: 680px;
  overflow: auto;
  display: flex;
  flex-direction: column;
  margin-left: 30px;
  background-color: #5759cd;
  border-radius: 8px !important;
  padding-left: 20px !important;
  padding-right: 20px !important;
  margin-bottom: 20px;
  filter: drop-shadow(0 4px 4px #00000073);
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
  background-color: #2c2d67;
  box-shadow: 0 4px 4px rgba(0, 0, 0, 0.2);
  font-size: 15px;
  font-weight: bold;
  overflow: hidden;
}

.ranking .puntos {
  background-color: #aeafdd;
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
  background-color: #8d89f9;
  font-size: 25px;
  text-decoration: underline;
  font-weight: bold;
  text-shadow: 0 4px 4px rgba(0, 0, 0, 0.2);
}

/*SCROLLBAR*/
*::-webkit-scrollbar {
    width: 12px;
    padding-right: 5px;
}

*::-webkit-scrollbar-track {
    background-color: #8d89f9;
}

*::-webkit-scrollbar-thumb {
    background: #4943f0; 
    border-radius: 20px;       
}

*::-webkit-scrollbar-thumb:hover {
    background: #332fac; 
    border-radius: 20px;  
    transform: 0.2 color ease;     
}

@media (max-width: 1024px) {
  .pantalla-ranking {
    flex-direction: column;
    align-items: center;
    width: 100%;
    gap: 20px;
    max-height: unset;
    padding: 0;
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
    flex-direction: row;
    align-items: center;
    gap: 20px;
    padding: 20px;
    min-height: auto;
    text-align: center;
  }

  .perfil-vista img {
    width: 100px;
    height: 100px;
    border-radius: 50%;
    margin: 0;
  }

  .perfil-vista h3 {
    margin: 0;
  }

  .perfil-vista p {
    margin: 0;
  }

  .perfil-vista .num {
    margin: 0;
  }

  .posicion {
    align-items: normal;
  }
}
@media (max-width: 768px) {
  .pantalla-ranking {
    flex-direction: column;
    align-items: center;
    width: 100%;
    gap: 20px;
    max-height: unset;
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

  .ranking {
    width: 100%;
    overflow-x: auto;
    padding: 10px;
  }

  .ranking table {
    width: 100%;
    display: block;
    overflow-x: auto;
    white-space: nowrap;
  }

  .ranking th,
  .ranking td {
    font-size: 14px;
    padding: 5px;
  }

  .ranking .categoria img {
    height: 40px;
    width: auto;
  }
}
</style>
