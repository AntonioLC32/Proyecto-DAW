<template>
  <section>
    <div class="encase">
      <div class="container-fluid title text-white">
        <h1>
          {{ textosTraducidos["Tus Estadísticas"] || "Tus Estadísticas" }}
        </h1>
      </div>
      <div class="container-fluid pantalla-estadisticas">
        <div class="perfil-vista">
          <div class="d-flex nombre-img flex-column">
            <img
              v-if="perfil.imagen && perfil.imagen !== defaultImagePath"
              :src="getImageUserUrl(perfil.imagen)"
              alt="Perfil Image"
              style="border-radius: 50%; max-width: 250px"
            />
            <img
              v-else
              :src="defaultImagePath"
              alt="Imagen predeterminada"
              style="border-radius: 50%"
            />
            <h3 class="text-white">{{ perfil.nombre }}</h3>
          </div>

          <div class="est-generales">
            <div class="stat-item">
              <p class="me-2">
                {{ textosTraducidos["Última posición"] || "Última posición" }}:
              </p>
              <div class="num text-white">
                <b>{{ perfil.posicion }}</b>
              </div>
            </div>
            <div class="stat-item">
              <p class="me-2">
                {{ textosTraducidos["Puntos Totales"] || "Puntos Totales" }}:
              </p>
              <div class="num text-white">
                <b>{{ perfil.puntos }}</b>
              </div>
            </div>
            <div class="stat-item">
              <p class="me-2">
                {{ textosTraducidos["Rondas Jugadas"] || "Rondas Jugadas" }}:
              </p>
              <div class="num text-white">
                <b>{{ perfil.rondasJugadas }}</b>
              </div>
            </div>
            <div class="stat-item">
              <p class="me-2">
                {{ textosTraducidos["Victorias"] || "Victorias" }}:
              </p>
              <div class="num text-white">
                <b>{{ perfil.victorias }}</b>
              </div>
            </div>
            <div class="stat-item">
              <p class="me-2">
                {{ textosTraducidos["Derrotas"] || "Derrotas" }}:
              </p>
              <div class="num text-white">
                <b>{{ perfil.derrotas }}</b>
              </div>
            </div>
            <div class="stat-item">
              <p class="me-2">
                {{
                  textosTraducidos["Categoría Destacada"] ||
                  "Categoría Destacada"
                }}:
              </p>
              <div class="num text-white">
                <img
                  :src="obtenerImagenCategoria(perfil.categoria_destacada)"
                  :alt="`Categoría destacada: ${perfil.categoria_destacada}`"
                  class="cat-img"
                />
              </div>
            </div>
          </div>
        </div>

        <div class="estadisticas">
          <div v-if="estadisticas.length === 0" class="no-records">
            <p>
              {{
                textosTraducidos["No hay estadísticas para este usuario"] ||
                "No hay estadísticas para este usuario"
              }}
            </p>
          </div>
          <div v-else class="estadisticas-grid">
            <div
              v-for="(categoria, index) in estadisticas"
              :key="index"
              class="estadisticas-item"
            >
              <img
                :src="obtenerImagenCategoria(categoria.categoria)"
                :alt="`Categoría: ${categoria.categoria}`"
                class="estadisticas-img"
              />
              <div class="d-flex ptot">
                <p class="puntos">{{ categoria.puntos }} pts</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      perfil: {},
      estadisticas: [],
      imagenesCategorias: {},
      defaultImagePath: "/src/assets/users/default/default.png",
      idiomaUsuario: "es",
      textosTraducidos: {},
      traduccionesCargando: false,
    };
  },
  methods: {
    async obtenerEstadisticasPerfil() {
      try {
        const response = await axios.get(
          "/api/estadisticas/select_perfil.php",
          {
            withCredentials: true,
          }
        );

        const data = response.data;
        if (!data || data.error) {
          console.error("API Error:", data?.error || "Invalid response");
          return;
        }

        this.perfil = {
          ...this.perfil,
          nombre: data.nombre || this.perfil.nombre || "--",
          posicion: data.posicion ?? "--",
          puntos: data.puntos ?? "--",
          rondasJugadas: data.rondasJugadas ?? "--",
          victorias: data.victorias ?? this.perfil.num_victorias ?? "--",
          derrotas: data.derrotas || this.perfil.num_derrotas || "--",
          categoria_destacada:
            data.categoria_destacada || this.perfil.imagen_categoria || "",
          imagen: data.imagen || this.perfil.imagen || this.defaultImagePath,
        };
      } catch (error) {
        console.error("Error obteniendo el perfil:", error);
      }
    },
    obtenerImagenCategoria(imagen) {
      if (!imagen) return ""; // Si no hay imagen, devolver vacío
      try {
        return `/src/${imagen}`; // ruta de las imágenes
      } catch (error) {
        console.error("Error cargando la imagen:", error);
        return "";
      }
    },
    async obtenerCategorias() {
      try {
        const response = await axios.get(
          "/api/estadisticas/select_categorias.php"
        );
        const data = response.data;

        if (data.length > 0) {
          this.imagenesCategorias = data.reduce((acc, categoria) => {
            acc[categoria.id_categoria] = categoria.imagen_categoria;
            return acc;
          }, {});
        }
      } catch (error) {
        console.error("Error obteniendo las categorías:", error);
      }
    },
    obtenerImagenCategoria(categoriaId) {
      return this.imagenesCategorias[categoriaId]
        ? `/src/${this.imagenesCategorias[categoriaId]}`
        : "";
    },
    async obtenerEstadisticasCompletas() {
      try {
        const response = await axios.get(
          "/api/estadisticas/select_estadisticas_usuario.php"
        );
        const data = response.data;

        if (data.error) {
          console.error("Error:", data.error);
          this.estadisticas = [];
          return;
        }

        if (data.message) {
          console.warn(data.message);
          this.estadisticas = [];
          return;
        }

        if (data && data.length > 0) {
          this.estadisticas = data.map((categoria) => ({
            categoria: categoria.categoria,
            puntos: categoria.puntos_totales,
          }));
        }
      } catch (error) {
        console.error("Error obteniendo las estadísticas del perfil:", error);
        this.estadisticas = [];
      }
    },
    getImageUserUrl(path) {
      return path ? `/src/${path}` : this.defaultImagePath; // Use the defined defaultImagePath
    },
    async traducirTexto(texto) {
      if (this.idiomaUsuario === "es") return texto;
      try {
        this.traduccionesCargando = true;
        const response = await axios.post("/api/index.php?action=traducir", {
          texto,
          idioma_origen: "es",
          idioma_destino: this.idiomaUsuario,
        });
        return response.data.status === "success"
          ? response.data.traduccion
          : texto;
      } catch (error) {
        console.error("Error en traducción:", error);
        return texto;
      } finally {
        this.traduccionesCargando = false;
      }
    },
    async traducirContenido() {
      this.traduccionesCargando = true;
      const textosOriginales = [
        "Tus Estadísticas",
        "Última posición",
        "Puntos Totales",
        "Rondas Jugadas",
        "Victorias",
        "Derrotas",
        "Categoría Destacada",
        "No hay estadísticas para este usuario",
      ];
      const traducciones = await Promise.all(
        textosOriginales.map((texto) => this.traducirTexto(texto))
      );
      textosOriginales.forEach((texto, index) => {
        this.textosTraducidos[texto] = traducciones[index];
      });
      this.traduccionesCargando = false;
    },
  },
  mounted() {
    this.idiomaUsuario = navigator.language.split("-")[0] || "es";
    if (this.idiomaUsuario !== "es") {
      this.traducirContenido();
    }

    const userCookie = document.cookie
      .split("; ")
      .find((row) => row.startsWith("user="))
      ?.split("=")[1];

    if (userCookie) {
      try {
        const userData = JSON.parse(decodeURIComponent(userCookie));
        this.perfil = { ...this.perfil, ...userData };
        this.perfil.imagen =
          this.perfil.imagen || "../../assets/users/default/default.png";

        this.obtenerEstadisticasPerfil();
        this.obtenerCategorias();
        this.obtenerEstadisticasCompletas();
      } catch (error) {
        console.error("Error parsing user cookie:", error.message);
      }
    } else {
      this.obtenerEstadisticasPerfil();
      this.obtenerCategorias();
      this.obtenerEstadisticasCompletas();
    }
  },
};
</script>

<style scoped>
* {
  box-sizing: border-box;
  font-family: "Montserrat", sans-serif;
}

section {
  background-color: #cac5f5;
  min-height: 100vh;
  overflow-y: hidden;
}

.encase {
  margin: 110px 48px 0 48px;
}

.title {
  background-color: #5759cd;
  border: 5px solid #4a4da5;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.title h1 {
  color: #fff;
  font-size: 48px;
  font-weight: bold;
  filter: drop-shadow(0 4px 4px #00000073);
}

.pantalla-estadisticas {
  display: flex;
  align-items: flex-start;
  width: 100%;
  padding: 0;
  margin-bottom: 50px;
  gap: 50px;
}

.perfil-vista {
  display: flex;
  flex-direction: column;
  align-items: center;
  background-color: #5759cd;
  filter: drop-shadow(0 2px 2px #00000073);
  border-radius: 8px;
  width: 30%;
  text-align: center;
  padding: 30px;
  font-weight: bold;
  min-height: 680px;
}

.perfil-vista > .nombre-img > img {
  width: 250px;
  height: 250px;
  max-width: 250px;
}

.ptot {
  gap: 10px;
  align-items: center;
}
.perfil-vista h3 {
  font-weight: bold;
  color: #fff;
}

.perfil-vista p {
  font-size: 20px;
  color: #fff;
}

.nombre-img {
  display: flex;
  align-items: center;
  gap: 30px;
  padding: 20px 0;
}

.est-generales {
  display: flex;
  flex-direction: column;
  gap: 10px;
  width: 100%;
  overflow-y: scroll;
  background-color: #4a4da5;
  padding: 20px;
  border-radius: 8px;
  max-height: 260px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.num {
  background-color: #8d89f8;
  padding: 10px 20px;
  border-radius: 5px;
  font-size: 24px;
  font-weight: 400;
  color: #fff;
}

/* estadisticas GRID */
.estadisticas {
  width: 70%;
  background-color: #5759cd;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  filter: drop-shadow(0 2px 2px #00000073);
  height: 680px;
}

.estadisticas-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 15px;
  width: 100%;
  max-height: 600px;
  overflow-y: auto;
  padding-right: 10px;
}

.estadisticas-item {
  background-color: #4a4da5;
  padding: 5px;
  border-radius: 8px;
  text-align: center;
  color: #fff;
  font-weight: bold;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  filter: drop-shadow(0 2px 2px #00000073);
}

.cat-img {
  width: 60px !important;
  height: 60px !important;
  border-radius: 8px;
}

.estadisticas-img {
  width: 100px;
  height: 100px;
  margin-top: 20px;
  margin-bottom: 10px;
  border-radius: 8px;
}

.puntos {
  font-size: 25px;
}

.posicion {
  font-size: 18px;
}

.no-records {
  text-align: center;
  color: #fff;
  font-size: 18px;
  font-weight: bold;
  padding: 20px;
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

/* RESPONSIVE */
@media (max-width: 1024px) {
  .est-generales {
    max-height: 100%;
    overflow-y: auto;
  }

  .pantalla-estadisticas {
    flex-direction: column;
    align-items: center;
    width: 100%;
    gap: 20px;
    padding: 0;
  }

  .perfil-vista,
  .estadisticas {
    width: 100%;
    margin-left: 0;
  }

  .perfil-vista {
    min-height: auto;
    text-align: center;
  }

  .perfil-vista img {
    width: 150px;
    height: 150px;
  }

  .estadisticas-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .pantalla-estadisticas {
    gap: 20px;
    padding: 20px;
  }

  .est-generales {
    max-height: unset;
  }

  .perfil-vista {
    width: 100%;
    padding: 20px;
    text-align: center;
  }

  .perfil-vista img {
    width: 120px;
    height: 120px;
  }

  .perfil-vista h3 {
    font-size: 20px;
  }

  .estadisticas {
    width: 100%;
    padding: 10px;
  }

  .estadisticas-grid {
    grid-template-columns: repeat(1, 1fr);
  }

  .estadisticas-img {
    width: 50px;
    height: 50px;
  }

  .puntos,
  .posicion {
    font-size: 16px;
  }
}
</style>
