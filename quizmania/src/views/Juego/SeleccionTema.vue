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
              <img :src="getImageUrl('cultura.png')" alt="theme image" />
              <img :src="getImageUrl('tecno.png')" alt="theme image" />
              <img :src="getImageUrl('deportes.png')" alt="theme image" />
              <img :src="getImageUrl('geografia.png')" alt="theme image" />
            </div>
            <div class="temas_completados">
              <img :src="getImageUrl('mates.png')" alt="theme image" />
              <img :src="getImageUrl('historia.png')" alt="theme image" />
              <img :src="getImageUrl('musica.png')" alt="theme image" />
              <img :src="getImageUrl('arte.png')" alt="theme image" />
              <img :src="getImageUrl('ciencias.png')" alt="theme image" />
              <img :src="getImageUrl('entre.png')" alt="theme image" />
            </div>
          </div>
          <div class="temas">
            <div class="temas_completados">
              <img
                :src="getImageUrl('perfil.jpg')"
                alt="Perfil Image"
                style="border-radius: 50%"
              />
              <img :src="getImageUrl('cultura.png')" alt="theme image" />
              <img :src="getImageUrl('tecno.png')" alt="theme image" />
              <img :src="getImageUrl('deportes.png')" alt="theme image" />
              <img :src="getImageUrl('geografia.png')" alt="theme image" />
            </div>
            <div class="temas_completados">
              <img :src="getImageUrl('mates.png')" alt="theme image" />
              <img :src="getImageUrl('historia.png')" alt="theme image" />
              <img :src="getImageUrl('musica.png')" alt="theme image" />
              <img :src="getImageUrl('arte.png')" alt="theme image" />
              <img :src="getImageUrl('ciencias.png')" alt="theme image" />
              <img :src="getImageUrl('entre.png')" alt="theme image" />
            </div>
          </div>
        </div>
        <!-- ENDIF MULTIJUGADOR-->
  
        <div class="roulette">
          <div class="arrow"></div>
          <!-- Flecha indicadora -->
          <div class="roller" :style="{ transform: `translateX(${position}px)` }">
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
        // Arreglo de temas y variables de estado
        themes,
        shuffledThemes: [...themes, ...themes, ...themes], // Para efecto infinito
        position: 0,
        spinning: false,
        selectedTheme: null,
        selectedIndex: null,
      };
    },
    methods: {
      // Función auxiliar para obtener la URL de la imagen
      getImageUrl(path) {
        return new URL(`../../assets/${path}`, import.meta.url).href;
      },
      // Función para iniciar el giro de la ruleta
      spin() {
        if (this.spinning) return;
  
        this.spinning = true;
        this.selectedTheme = null;
        this.selectedIndex = null;
  
        // Genera un scroll aleatorio
        let totalScroll = -(Math.random() * 2000 + 1000);
        this.position = totalScroll;
  
        setTimeout(() => {
          // Calcula el índice final basado en el scroll y el ancho de cada elemento (200px)
          const finalIndex =
            Math.floor(Math.abs(totalScroll) / 200) % this.themes.length;
          // Ajusta la posición para alinear el tema seleccionado
          this.position = -(finalIndex * 200);
          this.spinning = false;
  
          // Muestra el tema seleccionado
          this.selectedTheme = this.themes[finalIndex].name;
          this.selectedIndex = finalIndex;
  
          // Redirige a /juego después de 7 segundos
          setTimeout(() => {
            this.$router.push("/juego");
          }, 5500);
        }, 3000);
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
    height: 150px;
    overflow: hidden;
    background-color: #5759cd;
    position: relative;
  }
  
  .roller {
    display: flex;
    flex-direction: row;
    transition: transform 3s cubic-bezier(0.25, 1, 0.5, 1);
  }
  
  .theme {
    width: 200px;
    height: 150px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #aeafdd;
    border-right: 1px solid #ccc;
  }
  
  .theme img {
    min-width: 150px !important;
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
    font-size: 1.5em;
    font-weight: bold;
    color: #5759cd;
  }

@media (max-width: 1024px) {
    .temas{

    }

    .temas_completados img {
        height: 60px;
        width: 60px;
    }
}

@media (max-width: 768px) {

}

@media (max-width: 480px) {
    .temas{
        flex-direction: column;
    }

}
  </style>