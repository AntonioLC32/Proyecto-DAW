<template>
  <div class="body">
    <h1>Datos generales</h1>
    <div class="general">
      <div class="datos">ACIERTOS POR CATEGORÍA</div>
      <div class="datos">PARTICIPACIÓN USUARIOS SEMANAL</div>
      <div class="datos">ACIERTOS POR DIFICULTAD</div>
      <div class="datos">PARTIDAS JUGADAS DIARIAS</div>  
    </div>
  </div>
</template>


<style scoped>
.body {
  font-family: "Montserrat", sans-serif;
  background: linear-gradient(to bottom, #7D7DE6, #4D4D9D);
  height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

h1 {
  color: black;
  font-size: 24px;
  font-weight: bold;
  text-align: left;
  width: 80%;
  margin-bottom: 20px;
}

.general {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 40px;
  width: 80%;
}

.datos {
  background: white;
  padding: 20px;
  border-radius: 15px;
  box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.2);
  font-weight: bold;
  font-size: 16px;
  height: 350px;
}

</style>


<script>
export default {
  name: "Admin",
  data() {},
};
</script>