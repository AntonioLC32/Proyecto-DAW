<template>
  <section>
    <div class="contenedor">
      <!-- Se muestra en modo multijugador -->
      <div class="jugadores d-flex gap-2" v-if="modo === 'multijugador'">
        <!-- Se utiliza el componente TemasJugador con la prop themes -->
        <TemasJugador :themes="themes" />
        <TemasJugador :themes="themes" />
      </div>

      <!-- Resto de contenido -->
      <Roulette
        ref="roulette"
        :items="rouletteItems"
        :firstItemIndex="{ value: 0 }"
        :wheelResultIndex="{ value: null }"
        :displayCenterIndicator="true"
        indicatorPosition="top"
        :size="size"
        :displayShadow="true"
        :duration="5"
        :resultVariation="10"
        easing="ease"
        :counterClockwise="false"
        :horizontalContent="false"
        :displayBorder="true"
        :displayIndicator="true"
        :baseDisplay="true"
        :baseDisplayIndicator="true"
        :baseSize="100"
        baseBackground="#5759cd"
        @wheelStart="onWheelStart"
        @wheelEnd="onWheelEnd"
      />

      <button @click="spinWheel" class="boton_girar">GIRA</button>

      <div v-if="selectedCategory" class="selected-theme">
        Tema seleccionado: {{ selectedCategory }}
      </div>

      <div>
        <!-- Botón para disparar el modal -->
        <button
          type="button"
          class="btn button_rendirte"
          data-bs-toggle="modal"
          data-bs-target="#modalRendirte"
        >
          <img
            :src="getImageUrl('bandera-blanca.webp')"
            alt="Rendirte Image"
            id="bandera"
          />
        </button>

        <!-- Modal -->
        <div
          class="modal fade"
          id="modalRendirte"
          ref="modalRendirte"
          tabindex="-1"
          aria-labelledby="modalRendirteLabel"
          aria-hidden="true"
        >
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
              <div class="modal-header border-bottom-0">
                <button
                  type="button"
                  class="btn-close"
                  data-bs-dismiss="modal"
                  aria-label="Close"
                ></button>
              </div>
              <div
                class="modal-body d-flex flex-column align-items-center mb-3"
              >
                <h5
                  class="modal-title text-center mb-3"
                  id="modalRendirteLabel"
                >
                  <b>¿Estás seguro que <br />quieres rendirte?</b>
                </h5>
                <button
                  @click="exit"
                  type="button"
                  class="btn button_rendirte_aceptar text-white text-uppercase"
                >
                  <b>Aceptar</b>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import Roulette from "../../components/Roulette.vue";
import TemasJugador from "@/components/TemasJugador.vue";

export default {
  name: "SeleccionTema",
  components: {
    Roulette,
    TemasJugador,
  },
  data() {
    const themes = [
      { name: "Historia", image: this.getImageUrl("historia.png") },
      { name: "Ciencia", image: this.getImageUrl("ciencia.png") },
      { name: "Deportes", image: this.getImageUrl("deportes.png") },
      { name: "Música", image: this.getImageUrl("musica.png") },
      { name: "Entretenimiento", image: this.getImageUrl("entre.png") },
      { name: "Arte y Literatura", image: this.getImageUrl("arte.png") },
      { name: "Geografía", image: this.getImageUrl("geografia.png") },
      { name: "Matemáticas", image: this.getImageUrl("mates.png") },
      { name: "Tecnología", image: this.getImageUrl("tecno.png") },
      { name: "Cultura General", image: this.getImageUrl("cultura.png") },
    ];

    return {
      themes,
      shuffledThemes: [...themes, ...themes, ...themes, ...themes],
      position: 0,
      spinning: false,
      selectedTheme: null,
      selectedIndex: null,
      modo: "",
      selectedCategory: null,
      size: 300,
      userData: null,
      id_partida: null,
    };
  },
  computed: {
    rouletteItems() {
      return this.themes.map((theme) => ({
        id: theme.name,
        background: "#8D89F8",
        htmlContent: `<img src="${theme.image}" alt="${theme.name}" style="width:15%; height:auto;">`,
        textColor: "#000",
      }));
    },
  },
  mounted() {
    this.modo = sessionStorage.getItem("modo-juego");
    this.userData = this.$cookies.get("user");
    //sessionStorage.removeItem("modo-juego");
    this.handleResize();
    window.addEventListener("resize", this.handleResize);
    if (this.modo === "multijugador") {
      this.size = 300;
    }

    if (sessionStorage.getItem("id_partida")) {
      this.id_partida = sessionStorage.getItem("id_partida");
    } else {
      this.crearPartida(this.modo);
    }
  },

  beforeUnmount() {
    window.removeEventListener("resize", this.handleResize);
  },

  methods: {
    async crearPartida(modo) {
      if (modo === "multijugador") {
      } else if (modo === "solitario") {
        try {
          const response = await fetch(
            "/api/index.php?action=crearPartidaSolitario",
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
              },
              body: JSON.stringify({
                id_usuario: this.userData.id_usuario,
              }),
            }
          );

          const data = await response.json();

          if (data.status === "error") {
            this.$router.push("/");
          } else {
            sessionStorage.setItem("id_partida", data.id_partida);
          }
        } catch (e) {
          console.error("Error al crear la partida", e);
        }
      } else {
        this.$router.push("/");
      }
    },

    handleResize() {
      const screenWidth = window.innerWidth;
      this.size = screenWidth > 768 ? 500 : screenWidth * 0.8;
    },
    spinWheel() {
      this.$refs.roulette.launchWheel();
    },
    onWheelStart(selectedItem) {
      console.log("Wheel started:", selectedItem);
    },
    onWheelEnd(selectedItem) {
      // console.log("Wheel ended:", selectedItem);
      sessionStorage.setItem("categoria", selectedItem.id);
      this.selectedCategory = selectedItem.id;

      setTimeout(() => {
        this.$router.push("/juego");
      }, 2000);
    },
    getImageUrl(path) {
      return new URL(`../../assets/${path}`, import.meta.url).href;
    },

    async exit() {
      try {
        const id_partida = sessionStorage.getItem("id_partida");

        const response = await fetch(
          "/api/index.php?action=rendirsePartidaSolitario",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({ id_partida }),
          }
        );

        const data = await response.json();

        if (data.status === "success") {
          sessionStorage.removeItem("id_partida");
          sessionStorage.removeItem("ronda");
          this.$router.push("/").then(() => {
            location.reload();
          });
        } else {
          console.error("Error al rendirse:", data.mensaje);
        }
      } catch (error) {
        console.error("Error al rendirse:", error);
      }
    },
    spin() {
      if (this.spinning) return;

      this.spinning = true;
      this.selectedTheme = null;
      this.selectedIndex = null;

      const themeWidth = 300;
      const screenCenter = window.innerWidth / 2;
      const targetIndex =
        Math.floor(Math.random() * this.themes.length) + this.themes.length * 2;
      const finalPosition = -(
        targetIndex * themeWidth -
        screenCenter +
        themeWidth / 2
      );

      this.position = finalPosition;

      setTimeout(() => {
        this.spinning = false;
        this.selectedIndex = targetIndex % this.themes.length;
        this.selectedTheme = this.themes[this.selectedIndex].name;
        setTimeout(() => {
          this.$router.push("/juego");
        }, 3500);
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

/* Resto de estilos igual... */
.button_rendirte {
  background-color: #5759cd;
  padding: 15px 70px;
  border-radius: 8px;
  position: fixed;
  bottom: 20px;
  left: 20px;
  z-index: 999;
}

.button_rendirte_aceptar {
  background-color: #5759cd;
  padding: 15px 70px;
  border-radius: 8px;
}

#bandera {
  height: 40px;
  width: 40px;
}

.modal-body {
  font-weight: 700;
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
  padding: 20px;
  padding-top: 50px;
  min-height: calc(100vh - 90px);
  justify-content: center;
  gap: 20px;
  padding-bottom: 150px;
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
  background-color: #8d89f8;
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
  padding: 12px 40px;
  background-color: #5759cd;
  border: 0;
  border-radius: 8px;
  color: white;
  margin-top: 20px;
  font-size: 1.2rem;
  font-weight: bold;
}

.boton_girar:hover {
  background-color: #8e8fcd;
}

.selected-theme {
  position: relative;
  z-index: 1000;
  margin-top: 20px;
  font-size: 2em;
  font-weight: bold;
  color: #5759cd;
  text-align: center;
}

@media (max-width: 1024px) {
  .temas_completados img {
    height: 60px;
    width: 60px;
  }
}

@media (max-width: 480px) {
  .temas {
    flex-direction: column;
  }

  .boton_girar {
    font-size: 1rem;
    padding: 10px 30px;
  }

  .wheel-wrapper {
    max-width: 95vw;
  }

  .button_rendirte {
    padding: 10px 40px;
  }

  .selected-theme {
    font-size: 1.5em;
    margin-bottom: 20px;
  }
}
</style>
