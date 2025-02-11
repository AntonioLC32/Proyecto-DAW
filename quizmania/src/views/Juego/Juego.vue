<template>
    <section>
      <div class="division">
        <div class="left">
          <div class="encase">
            <div class="pregunta">
              <p>¿Quién hizo la canción Thriller?</p>
            </div>
  
            <button
              class="respuesta"
              v-for="opcion in opcionesVisibles"
              :key="opcion"
              :class="{
                correcta: seleccionado && opcion === 'Michael Jackson',
                incorrecta: seleccionado && opcion !== 'Michael Jackson'
              }"
              @click="seleccionarRespuesta(opcion)"
            >
              <p>{{ opcion }}</p>
            </button>
  
            <div class="misc">
              <div class="progreso">{{ progreso }}%</div>
              <a href="#" @click.prevent="usarPista">
                <img src="../../assets/pista.png" alt="Pista" width="70px" height="70px" />
              </a>
              <a href="#siguientePregunta">
                <img src="../../assets/siguiente.png" alt="Siguiente" width="70px" height="70px" />
              </a>
            </div>
          </div>
        </div>
        <div class="right">
          <div class="encase flex-column gap-5">
            <img src="../../assets/corazon.png" alt="" width="80px" height="80px" />
            <img src="../../assets/corazon.png" alt="" width="80px" height="80px" />
            <img src="../../assets/corazon.png" alt="" width="80px" height="80px" />
          </div>
        </div>
      </div>
    </section>
  </template>
  
  <script setup>
  import { ref } from "vue";
  
  const opciones = ref(["Jason Derulo", "Bon Jovi", "Miley Cyrus", "Michael Jackson"]);
  const opcionesVisibles = ref([...opciones.value]);
  const respuestaSeleccionada = ref(null);
  const seleccionado = ref(false);
  const pistaUsada = ref(false);
  const progreso = ref(50);
  
  const seleccionarRespuesta = (opcion) => {
    if (!seleccionado.value) {
      respuestaSeleccionada.value = opcion;
      seleccionado.value = true;
    }
  };
  
  const usarPista = () => {
    if (!pistaUsada.value) {
      const incorrectas = opcionesVisibles.value.filter(opcion => opcion !== "Michael Jackson");
  
      if (incorrectas.length > 0) {
        const eliminarIndex = opcionesVisibles.value.indexOf(
          incorrectas[Math.floor(Math.random() * incorrectas.length)]
        );
        opcionesVisibles.value.splice(eliminarIndex, 1);
      }
  
      pistaUsada.value = true;
    }
  };
  </script>
  
  
  
  <style scoped>
  * {
    box-sizing: border-box;
    font-family: "Montserrat", sans-serif;
  }
  
  .division {
    display: flex;
    width: 100%;
    padding: 20%;
    padding-top: 0;
    padding-bottom: 0;
  }
  
  .left {
    width: 80%;
  }
  
  .right {
    width: 20%;
  }
  
  .encase {
    margin: 110px 48px 0 48px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }
  
  section {
    background-color: #e1e0ff;
    min-height: 100vh;
    overflow-y: hidden;
  }
  
  .pregunta {
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #5759cd;
    border-radius: 15px;
    width: 100%;
    padding: 150px;
    margin-bottom: 50px;
    filter: drop-shadow(0 10px 0px #5759cd35);
  }
  
  .pregunta p {
    font-size: 20px;
    font-weight: bold;
    color: white;
    margin: 0;
  }
  
  .respuesta {
    display: flex;
    align-items: center;
    justify-content: left;
    background-color: #5759cd;
    border-radius: 10px;
    width: 98%;
    padding: 15px;
    margin-bottom: 30px;
    filter: drop-shadow(0 10px 0px #5759cd35);
    border: 0px;
    transition: background-color 0.3s ease-in-out;
  }
  
  .respuesta:hover {
    background-color: #8e8fcd;
  }
  
  .respuesta p {
    font-size: 20px;
    font-weight: bold;
    color: white;
    margin: 0;
    padding-left: 40px;
  }
  
  /* Cambia el color del botón si la respuesta es correcta */
  .correcta {
    background-color: #26fb09 !important;
    filter: drop-shadow(0 10px 0px #26fb0935);
  }
  
  /* Cambia el color de todas las respuestas incorrectas */
  .incorrecta {
    background-color: #ff0707 !important;
    filter: drop-shadow(0 10px 0px #ff070735);
  }
  
  .misc {
    display: flex;
    flex-direction: row;
    gap: 30px;
    max-height: 70px;
  }
  
  .misc img {
    transition: all 0.3s ease-in-out;
  }
  
  .misc img:hover {
    transform: scale(1.1);
  }
  
  .progreso {
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    border-radius: 50%;
    width: 70px;
    background-color: #5759cd;
    border: 5px solid #4a4da5;
    font-size: 30px;
  }
  </style>
  