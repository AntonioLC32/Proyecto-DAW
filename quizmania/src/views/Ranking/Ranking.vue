<template>
  <div>
    <section>
      <div class="container-fluid title">
        <h1><b>Ranking Global</b></h1>
      </div>
    </section>
    <section>
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
              <p><u>Última posición:</u></p>
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
                  <img :src="jugador.categoria" alt="" width="100%" height="60" />
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

const perfil = ref({
  nombre: "PEPE_123ASD",
  posicion: 1,
});

const ranking = ref([
  {
    nombre: "PEPE_123ASD",
    posicion: 1,
    puntos: 15648,
    categoria: "../../assets/entre.png",
  },
  {
    nombre: "PEPE",
    posicion: 2,
    puntos: 15648,
    categoria: "../../assets/entre.png",
  },
  {
    nombre: "PEPE",
    posicion: 3,
    puntos: 15648,
    categoria: "../../assets/entre.png",
  },
  {
    nombre: "MARIA_ABCD",
    posicion: 4,
    puntos: 15432,
    categoria: "imgs/tecno.png",
  },
  {
    nombre: "JUAN_XYZ",
    posicion: 5,
    puntos: 15210,
    categoria: "../../assets/entre.png",
  },
  {
    nombre: "ANA_321",
    posicion: 6,
    puntos: 15100,
    categoria: "../../assets/entre.png",
  },
  {
    nombre: "LUIS_654",
    posicion: 7,
    puntos: 15000,
    categoria: "../../assets/entre.png",
  },
  {
    nombre: "CARLA_987",
    posicion: 8,
    puntos: 14850,
    categoria: "../../assets/entre.png",
  },
  {
    nombre: "PEDRO_KLM",
    posicion: 9,
    puntos: 14700,
    categoria: "../../assets/entre.png",
  },
  {
    nombre: "SOFIA_GHI",
    posicion: 10,
    puntos: 14560,
    categoria: "../../assets/entre.png",
  },
]);
</script>

<style scoped>
/* Incluye aquí los estilos de tu código original */
* {
  box-sizing: border-box;
  font-family: "Montserrat", sans-serif;
}

section {
  background: conic-gradient(
    from 340deg,
    #8d89f9 0%,
    #5759cd 55%,
    #2c2d67 100%
  ) !important;
  color: #fff;
  height: auto;
  overflow: auto;
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
  background-color: #5759cd;
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
  justify-content: flex-start;
  padding: 20px;
  align-items: flex-start;
  height: auto;
  max-height: 100vh;
  width: 100%;
  padding-left: 50px !important;
  padding-right: 50px !important;
}

.perfil-vista {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex-wrap: nowrap;
  background-color: #2c2d67;
  border: 5px solid #21224f;
  border-radius: 8px;
  width: 30%;
  /* 30% of the container width */
  height: 100%;
  text-align: center;
  padding: 20px;
  font-weight: bold;
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
  font-size: 25px;
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
  font-size: 15px;
  font-weight: bold;
}

.ranking {
  width: 70%; /* 70% of the container width */
  height: 100%;
  max-height: 80vh;
  overflow: auto;
  display: flex;
  flex-direction: column;
  border-top: 10px solid #4a4da5;
  border-left: 10px solid #4a4da5;
  border-right: 10px solid #4a4da5;
  margin-left: 30px;
  background-color: #000;
  border-radius: 8px !important;
  padding-left: 20px !important;
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
  }

  .perfil-ranking {
    margin-left: 0;
    margin-bottom: 20px;
  }

  .perfil-ranking,
  .ranking {
    width: 100%; /* Ensure both sections take full width on smaller screens */
  }
}

.sidebar {
  position: fixed;
  top: 0;
  right: -250px;
  width: 250px;
  height: 100%;
  background-color: #4a4da5;
  padding: 20px;
  box-shadow: 2px 0 5px rgba(0, 0, 0, 0.2);
  transform: translateX(-100%);
  transition: transform 0.3s ease-in-out;
  margin-top: 92px;
}

.sidebar.open {
  transform: translateX(0);
}

.sidebar img {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: block;
  margin: 0 auto 20px auto;
}

.sidebar ul {
  list-style: none;
  padding: 0;
}

.sidebar ul li {
  margin: 15px 0;
  text-align: center;
  font-weight: bold;
  font-size: 18px;
  color: #fff;
}

.sidebar ul li a {
  color: #fff;
  text-decoration: none;
}

.sidebar ul li a:hover {
  text-decoration: underline;
}

.sidebar .bottom {
  position: absolute;
  bottom: 20px;
  width: 100%;
  text-align: center;
}

.sidebar .bottom li {
  margin: 10px 0;
}

.menu-toggle {
  top: 20px;
  left: 20px;
  background-color: transparent;
  border: none;
  color: #fff;
  font-size: 24px;
  cursor: pointer;
}
</style>
