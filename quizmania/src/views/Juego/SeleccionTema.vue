<template>
  <section>
    <div class="contenedor">
      <!-- IF MULTIJUGADOR-->
      <div class="jugadores d-flex gap-2">
        <div class="temas">
          <div class="temas_completados">
            <img
              :src="getImageUrl('perfil.jpg')"
              alt="Perfil Image"
              style="border-radius: 50%"
            />
            <img
              v-for="theme in themes.slice(0, 4)"
              :key="theme.name"
              :src="theme.image"
              alt="theme image"
            />
          </div>
          <div class="temas_completados">
            <img
              v-for="theme in themes.slice(4)"
              :key="theme.name"
              :src="theme.image"
              alt="theme image"
            />
          </div>
        </div>
        <div class="temas" v-if="multijugador">
          <div class="temas_completados">
            <img
              :src="getImageUrl('perfil.jpg')"
              alt="Perfil Image"
              style="border-radius: 50%"
            />
            <img
              v-for="theme in themes.slice(0, 4)"
              :key="theme.name"
              :src="theme.image"
              alt="theme image"
            />
          </div>
          <div class="temas_completados">
            <img
              v-for="theme in themes.slice(4)"
              :key="theme.name"
              :src="theme.image"
              alt="theme image"
            />
          </div>
        </div>
      </div>
      <!-- ENDIF MULTIJUGADOR-->

      <div class="roulette">
        <div class="arrow"></div>
        <!-- Flecha indicadora -->
        <div
          class="roller"
          :style="{
            transform: `translateX(${position}px)`,
            transition: spinning
              ? 'transform 5s cubic-bezier(0.17, 0.67, 0.83, 0.67)'
              : 'none',
          }"
        >
          <div
            v-for="(item, index) in shuffledThemes"
            :key="index"
            class="theme"
            :class="{ selected: selectedIndex === index % themes.length }"
          >
            <img :src="item.image" alt="theme image" />
          </div>
        </div>
      </div>
      <button @click="spin" class="boton_girar">GIRA</button>
      <br>
      <div v-if="selectedTheme" class="selected-theme">
        Tema seleccionado: {{ selectedTheme }}
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: "SeleccionTema",
  data() {
    const themes = [
      { name: "Historia", image: this.getImageUrl("historia.png") },
      { name: "Ciencias", image: this.getImageUrl("ciencias.png") },
      { name: "Deportes", image: this.getImageUrl("deportes.png") },
      { name: "Música", image: this.getImageUrl("musica.png") },
      { name: "Entretenimiento", image: this.getImageUrl("entre.png") },
      { name: "Arte", image: this.getImageUrl("arte.png") },
      { name: "Geografía", image: this.getImageUrl("geografia.png") },
      { name: "Matemáticas", image: this.getImageUrl("mates.png") },
      { name: "Tecnología", image: this.getImageUrl("tecno.png") },
      { name: "Cultura", image: this.getImageUrl("cultura.png") },
    ];

    return {
      themes,
      shuffledThemes: [...themes, ...themes, ...themes, ...themes], // Se repite para efecto infinito
      position: 0,
      spinning: false,
      selectedTheme: null,
      selectedIndex: null,
      multijugador: false, // Definir según lógica
    };
  },
  methods: {
    getImageUrl(path) {
      return new URL(`../../assets/${path}`, import.meta.url).href;
    },
    spin() {
      if (this.spinning) return;

      this.spinning = true;
      this.selectedTheme = null;
      this.selectedIndex = null;

      const themeWidth = 300;
      const screenCenter = window.innerWidth / 2;
      const totalThemes = this.shuffledThemes.length;

      // Pick a safe stopping point inside shuffledThemes
      const targetIndex =
        Math.floor(Math.random() * this.themes.length) + this.themes.length * 2;
      const finalPosition = -(
        targetIndex * themeWidth -
        screenCenter +
        themeWidth / 2
      );

      this.position = finalPosition; // Adjusted to stop in the middle

      setTimeout(() => {
        this.spinning = false;
        this.selectedIndex = targetIndex % this.themes.length;
        this.selectedTheme = this.themes[this.selectedIndex].name;
        setTimeout(() => {
          this.$router.push("/juego");
        },3500);
      }, 4000);
    },
  },
};
</script>

<style scoped>
* {
  box-sizing: border-box;
  font-family: "Montserrat", sans-serif;
}

section {
  background-color: #e1e0ff;
  min-height: 100vh;
  overflow-y: hidden;
}

.contenedor {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 90px !important;
  padding-top: 50px;
}

.temas {
  padding: 20px;
  background-color: #5759cd;
  border-radius: 8px;
  margin-bottom: 50px;
}

.temas_completados {
  display: flex;
  align-items: center;
  justify-content: space-evenly;
}

.temas_completados img {
  height: 80px;
  width: 80px;
}

.roulette {
  width: 100vw;
  height: 200px;
  overflow: hidden;
  background-color: #5759cd;
  position: relative;
}

.roller {
  display: flex;
  flex-direction: row;
  transition: transform 3.5s cubic-bezier(0.25, 1, 0.5, 1);
}

.theme {
  width: 300px;
  height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #aeafdd;
  border-right: 1px solid #ccc;
}

.theme img {
  min-width: 300px !important;
  background: transparent;
  width: 100%;
  height: 100%;
  object-fit: contain;
  display: flex;
  align-items: center;
}

.theme.selected {
  background-color: #8d89f8; /* Resaltar el tema seleccionado */
}

.arrow {
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 0;
  height: 0;
  border-left: 15px solid transparent;
  border-right: 15px solid transparent;
  border-top: 20px solid #5759cd;
  z-index: 1;
}

.boton_girar {
  padding: 15px 50px;
  background-color: #5759cd;
  border: 0;
  border-radius: 8px;
  color: white;
  margin-top: 20px;
  font-size: 20px;
  font-weight: bold;
}

.boton_girar:hover {
  background-color: #8e8fcd;
}

.selected-theme {
  margin-top: 20px;
  font-size: 2em;
  font-weight: bold;
  color: #5759cd;
}

@media (max-width: 1024px) {

  .temas_completados img {
    height: 60px;
    width: 60px;
  }
}

@media (max-width: 768px) {

}

@media (max-width: 480px) {
  .temas {
    flex-direction: column;
  }
}
</style>
