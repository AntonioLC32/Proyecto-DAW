<template>
  <!-- Botón instrucciones -->
  <section class="inicio">
    <button class="instrucciones-btn" @click="showPopup = true">
      INSTRUCCIONES
    </button>
  <!-- POP UP -->
    <div v-if="showPopup" class="popup">
      <div class="popup-content">
        <button class="close-btn" @click="showPopup = false">✖</button>
        <section class="instrucciones">
          <div class="modos">
            <div class="modo">
              <h2><u>Modo solitario</u></h2>
              <p>Acierta tantas preguntas como puedas y supérate a ti mismo.</p>
              <p>Tienes 3 vidas y pierdes una cada vez que fallas.</p>
              <p>El juego termina cuando pierdas todas tus vidas.</p>
            </div>
            <div class="barra"></div>
            <div class="modo">
              <h2><u>Modo multijugador</u></h2>
              <p>Responde preguntas de todo tipo.</p>
              <p>Cada 3 preguntas correctas, en la siguiente puedes ganar una corona.</p>
              <p>Cada categoría tiene una corona propia.</p>
              <p>Consigue las 10 coronas y gana la partida.</p>
            </div>
            <div class="barra2"></div>
          </div>
          <div class="comodines">
            <h2><u>Comodines</u></h2>
            <p>50/50: Se eliminarán 2 opciones incorrectas de las opciones a elegir de la pregunta.</p>
            <p>Pista: Se eliminará 1 opción incorrecta de las opciones a elegir de la pregunta.</p>
            <p>Salto: Se salta la pregunta actual y se continúa con otra pregunta (no cuenta como correcta).</p>
          </div>
        </section>
      </div>
    </div>
    <!-- Botones juego -->
    <div class="juegos">
      <button class="juego">Modo solitario</button>
      <button class="juego">Modo multijugador</button>
    </div>
  </section>
</template>

<style scoped>
.inicio{
  background: url("../assets/background_inicio.png") no-repeat center center fixed;
  background-size: cover;
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.instrucciones-btn{
  position: absolute;
  top: 100px;
  left: 30px;
  background-color: #5759CD;
  color: #fff;
  font-family: "Montserrat", sans-serif;
  font-weight: bold;
  width: 300px;
  height: 80px;
  font-size: 26px;
  border-radius: 25px;
  border: none;
}

.instrucciones-btn:hover{
  background-color: #4a4da5;
}

.popup {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(0, 0, 0, 0.8);
  display: flex;
  justify-content: center;
  align-items: center;
}

.popup-content {
  color: #fff;
  padding: 30px;
  width: 100%;
  position: relative;
}

.close-btn {
  position: absolute;
  top: 55px;
  right: 20px;
  background: none;
  border: none;
  font-size: 30px;
  color: #fff;
  cursor: pointer;
}

.close-btn:hover {
  color: #ddd;
}

.instrucciones h2{
  font-size: 50px;
  font-weight: bold;
}

.instrucciones p{
  margin-top: 20px;
  font-size: 24px;
  font-weight: bold;
}

.modos {
  display: flex;
  justify-content: center;
  gap: 50px;
}

.modo {
  width: 40%;
  margin-top: 70px;
  margin-left: 10px;
}

.barra {
  background-color: #fff;
  width: 5px;
  height: auto;
  margin-top: 70px;
}

.barra2 {
  background-color: #fff;
  width: 0px;
  height: auto;
  margin-top: 70px;
}

.comodines {
  width: 90%;
  margin-top: 20px;
  padding-left: 5%;
  margin-left: 5%;
  padding-bottom: 5%;
}

.juegos{
  display: flex;
  justify-content: center;
  flex-direction: row;
  margin: 0 10%;
  height: 30%;
  gap: 20%;
}

.juego {
  background-color: #5759CD;
  border: none;
  border-radius: 25px;
  width: 100%;
  height: 100%;
  margin-top: 50px;
  font-size: 50px;
  color: white;
  font-weight: bold;
  cursor: pointer;
}

.juego:hover{
  background-color:#4a4da5;
}

@media (max-width: 1200px) {
  .popup{
    align-items: flex-start;
    overflow-y: auto;
  }

  .popup-content{
    margin-top: 10%; 
    max-height: none;
    height: auto;
    overflow-y: visible;
    padding-bottom: 50px;
  }

  .instrucciones-btn{
    width: 250px;
    height: 70px;
    font-size: 22px;
}
  .instrucciones h2 {
    font-size: 3vw;
    font-weight: bold;
  }

  .instrucciones p {
    font-size: 2vw;
    font-weight: bold;
  }

  .juegos {
    flex-direction: column; 
    gap: 30px;
    align-items: center;
  }

  .juego {
    width: 90%;
    min-height: 200px;
    font-size: 40px;
  }

  .modos {
    padding-top: 40px;
    flex-direction: column;
    align-items: center;
  }
  

  .modo {
    width: 80%;
    margin-top: 10px;
  }

  .barra {
    width: 80%;
    height: 3px;
    margin-top: 5px;
  }

  .barra2 {
    width: 80%;
    height: 3px;
    margin-top: 5px;
  }

  .comodines{
    margin-top: 50px;
  }
}

</style>

<script>
export default {
  name: "Quizmania",
  data() {
    return {
      showPopup: false,
    };
  },
};
</script>
