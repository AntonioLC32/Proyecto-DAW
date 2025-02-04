<template>
  <section class="aJugar">
    <div class="aJugar-content">
      <button class="aJugar-btn">
        A JUGAR!
      </button>
    </div>
    <img src="../assets/background_inicio.png" alt="background_inicio">
  </section>
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
</template>

<style scoped>
.aJugar {
    position: relative;
    text-align: center;
    overflow: hidden;
}

.aJugar img {
    width: 100%;
    height: 650px;
    object-fit: cover;
    display: block;
}

.aJugar-content {
    position: absolute; 
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    color: white;
    text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.8);
}

.aJugar-btn{
  background-color: #5759CD;
  color: #fff;
  font-family: "Montserrat", sans-serif;
  font-weight: bold;
  width: 350px;
  height: 100px;
  font-size: 50px;
  border-radius: 25px;
  border: none;
  transition: all ease 0.3s;
}

.aJugar-btn:hover{
  background-color: #4a4da5;
}

.instrucciones{
  background-color: #8D89F8;
  color: #fff;
}

.instrucciones h2 {
  font-size: 2.7vw;
  font-weight: bold;
}

.instrucciones p {
  margin-top: 2vw;
  font-size: 1.5vw;
  font-weight: bold;
}

.modos {
  display: flex;
  justify-content: center;
  gap: 50px;
}

.modo {
  margin-left: 10px;
  width: 40%;
  margin-top: 70px;
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


@media (max-width: 1200px) {
  .aJugar-btn{
    width: 250px;
    height: 80px;
    font-size: 40px;
  }

  .instrucciones{
  background-color: #8D89F8;
  color: #fff;
  }

  .instrucciones h2 {
    font-size: 3vw;
    font-weight: bold;
  }

  .instrucciones p {
    font-size: 2vw;
    font-weight: bold;
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
  name: "Home",
};
</script>
