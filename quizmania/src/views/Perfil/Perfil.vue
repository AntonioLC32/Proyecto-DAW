<template>
  <section>
    <div class="perfil">
      <div class="perfil-title">
        <h1>{{ textosTraducidos["PERFIL"] || "PERFIL" }}</h1>
      </div>

      <div class="division">
        <div class="perfil-vista">
          <div id="perfil_img">
            <img
              v-if="previewImage"
              :src="previewImage"
              alt="Preview Image"
              style="border-radius: 50%"
            />
            <img
              v-else-if="user?.imagen"
              :src="getImageUserUrl(user.imagen)"
              alt="Perfil Image"
              style="border-radius: 50%"
            />
            <img
              v-else
              src="../../assets/users/default/default.png"
              alt="Imagen predeterminada"
              style="border-radius: 50%"
            />
          </div>
          <div class="perfil_img_update">
            <input
              type="file"
              accept="image/*"
              style="display: none"
              @change="onImageSelected"
              ref="profileImageInput"
            />
            <button
              v-if="!selectedImage"
              class="btn btn-profile-update mb-3"
              @click="$refs.profileImageInput.click()"
            >
              {{ textosTraducidos["Cambiar Imagen"] || "Cambiar Imagen" }}
            </button>
            <button
              v-else
              class="btn btn-confirm-update mb-3"
              @click="confirmImageChange"
            >
              {{ textosTraducidos["Confirmar Cambio"] || "Confirmar Cambio" }}
            </button>
          </div>
          <h3 class="text-white">
            {{
              user?.nombre || textosTraducidos["Cargando..."] || "Cargando..."
            }}
          </h3>
          <h4 class="text-wrap">
            {{
              textosTraducidos["¡Comparte tu perfil con tus amigos!"] ||
              "¡Comparte tu perfil con tus amigos!"
            }}
          </h4>
          <div class="socials text-white">
            <a href="#instagram" class="social-button" aria-label="Instagram">
              <img
                src="../../assets/instagram2.png"
                alt="instagram"
                width="32px"
              />
            </a>
            <a href="#compartir" class="social-button">
              <img src="../../assets/share.png" alt="share" width="32px" />
            </a>
          </div>
        </div>

        <div class="ajustes">
          <div class="container-fluid p-0">
            <ul class="nav nav-tabs w-100">
              <li class="nav-item" style="width: 50%; text-align: center">
                <a
                  @click="setTab('ajustes')"
                  :class="{ active: activeTab === 'ajustes' }"
                  class="nav-link"
                >
                  {{
                    textosTraducidos["Ajustes de la cuenta"] ||
                    "Ajustes de la cuenta"
                  }}
                </a>
              </li>
              <li class="nav-item" style="width: 50%; text-align: center">
                <a
                  @click="setTab('estadisticas')"
                  :class="{ active: activeTab === 'estadisticas' }"
                  class="nav-link"
                >
                  {{
                    textosTraducidos["Resumen de tus estadísticas"] ||
                    "Resumen de tus estadísticas"
                  }}
                </a>
              </li>
            </ul>
            <div class="tab-content">
              <div
                v-if="activeTab === 'ajustes'"
                class="tab-pane"
                :class="{ 'show active': activeTab === 'ajustes' }"
              >
                <form @submit.prevent="perfilUpdate">
                  <label for="nombre">{{
                    textosTraducidos["Nombre de usuario"] || "Nombre de usuario"
                  }}</label
                  ><br />
                  <input
                    v-model="settings.nombre"
                    type="text"
                    placeholder="Tu nombre"
                    class="form-control mb-3"
                  />
                  <label for="correo">{{
                    textosTraducidos["Correo Electrónico"] ||
                    "Correo Electrónico"
                  }}</label
                  ><br />
                  <input
                    v-model="settings.correo"
                    type="email"
                    placeholder="Tu correo"
                    class="form-control mb-3"
                  />
                  
                  <button
                    class="btn btn-profile-update w-100 mt-3"
                    type="submit"
                    @click="perfilUpdate"
                  >
                    {{
                      textosTraducidos["Guardar Ajustes"] || "Guardar Ajustes"
                    }}
                  </button>
                </form>
              </div>

              <div
                v-if="activeTab === 'estadisticas'"
                class="tab-pane"
                :class="{ 'show active': activeTab === 'estadisticas' }"
              >
                <div class="estadisticas-container">
                  <div class="estadistica-item">
                    <h4>
                      {{
                        textosTraducidos["Pos. Última Partida"] ||
                        "Pos. Última Partida"
                      }}
                    </h4>
                    <p class="estadistica-valor">
                      {{ stats.posUltimaPartida || "--" }}
                    </p>
                  </div>
                  <div class="estadistica-item">
                    <h4>
                      {{
                        textosTraducidos["Puntos Última Partida"] ||
                        "Puntos Última Partida"
                      }}
                    </h4>
                    <p class="estadistica-valor">
                      {{ stats.puntosUltimaPartida || "--" }}
                    </p>
                  </div>
                  <div class="estadistica-item">
                    <h4>
                      {{
                        textosTraducidos["Categoría Destacada"] ||
                        "Categoría Destacada"
                      }}
                    </h4>
                    <p class="estadistica-valor">
                      <img
                        :src="obtenerImagenCategoria(stats.imagenCategoria)"
                        alt="Categoria Destacada"
                        width="50px"
                      />
                    </p>
                  </div>
                </div>
                <div class="my-5">
                  <a href="/estadisticas" class="btn btn-outline-light">
                    {{
                      textosTraducidos["Ver tus estadísticas completas"] ||
                      "Ver tus estadísticas completas"
                    }}
                  </a>
                </div>
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
  name: "Perfil",
  data() {
    return {
      activeTab: "ajustes",
      user: {
        nombre: "",
        imagen: "",
      },
      settings: {
        nombre: "",
        correo: "",
        notificaciones: "si",
      },
      stats: {
        posUltimaPartida: "--",
        puntosUltimaPartida: "--",
        imagenCategoria: "--",
      },
      textosTraducidos: {},
      traduccionesCargando: false,
      idiomaUsuario: "es",
      selectedImage: null,
      previewImage: null,
    };
  },
  async mounted() {
    await this.cargarPerfil();
    this.idiomaUsuario = navigator.language.split("-")[0] || "es";
    if (this.idiomaUsuario !== "es") {
      await this.traducirContenido();
    }
  },
  methods: {
    setTab(tab) {
      this.activeTab = tab;
    },
    getImageUserUrl(path) {
      return path ? `/src/${path}` : "/src/assets/users/default.png";
    },
    async cargarPerfil() {
      try {
        const response = await fetch("/api/perfil/select_perfil.php", {
          credentials: "include",
        });
        if (!response.ok)
          throw new Error(`HTTP error! status: ${response.status}`);
        const data = await response.json();

        this.user = {
          nombre: data.nombre || "",
          imagen: data.imagen || "",
        };

        this.settings = {
          nombre: data.nombre || "",
          correo: data.correo || "",
          notificaciones: data.notificaciones || "si",
        };

        this.stats = {
          posUltimaPartida: data.posicion || "--",
          puntosUltimaPartida: data.puntos || "--",
          imagenCategoria: data.imagen_categoria || "--",
        };
      } catch (error) {
        console.error("Error obteniendo el perfil:", error);
        this.user = { nombre: "Error", imagen: "" };
      }
    },
    obtenerImagenCategoria(imagen) {
      return imagen && imagen !== "--"
        ? `/src/${imagen}`
        : "/src/assets/users/default/default.png";
    },
    async traducirTexto(texto) {
      if (/^[\d:]/.test(texto) || this.idiomaUsuario === "es") return texto;
      try {
        const response = await axios.post("/api/index.php?action=traducir", {
          texto: texto,
          idioma_origen: "es",
          idioma_destino: this.idiomaUsuario,
        });
        return response.data.status === "success"
          ? response.data.traduccion
          : texto;
      } catch (error) {
        console.error("Error en traducción:", error);
        return texto;
      }
    },
    async traducirContenido() {
      this.traduccionesCargando = true;
      const textos = [
        "PERFIL",
        "Cambiar Imagen",
        "Confirmar Cambio",
        "¡Comparte tu perfil con tus amigos!",
        "Ajustes de la cuenta",
        "Resumen de tus estadísticas",
        "Nombre de usuario",
        "Correo Electrónico",
        "Guardar Ajustes",
        "Pos. Última Partida",
        "Puntos Última Partida",
        "Categoría Destacada",
        "Ver tus estadísticas completas",
        "Cargando...",
      ];
      const traducciones = await Promise.all(textos.map(this.traducirTexto));
      textos.forEach((texto, index) => {
        this.textosTraducidos[texto] = traducciones[index];
      });
      this.traduccionesCargando = false;
    },
    onImageSelected(event) {
      const file = event.target.files[0];
      if (!file) return;
      if (file.size > 5 * 1024 * 1024) {
        alert("El archivo es demasiado grande (máx 5MB)");
        return;
      }
      if (!["image/png", "image/jpeg", "image/jpg"].includes(file.type)) {
        alert("Formato no válido (solo PNG/JPG)");
        return;
      }
      this.selectedImage = file;
      const reader = new FileReader();
      reader.onload = (e) => (this.previewImage = e.target.result);
      reader.readAsDataURL(file);
    },
    async confirmImageChange() {
      if (!this.selectedImage) return;
      const reader = new FileReader();
      reader.onload = async () => {
        try {
          const response = await fetch("/api/perfil/updatePerfil.php", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              id_usuario: this.userData?.id_usuario,
              nombre: this.userData?.nombre,
              file: reader.result,
            }),
          });
          const data = await response.json();
          if (data.status === "success") {
            this.user.imagen = data.imagen;
            this.selectedImage = null;
            this.previewImage = null;
          }
        } catch (error) {
          console.error("Error actualizando imagen:", error);
        }
      };
      reader.readAsDataURL(this.selectedImage);
    },
    async perfilUpdate() {
      try {
        const response = await fetch("/api/perfil/updatePerfil.php", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(this.settings),
        });
        const data = await response.json();
        if (data.status === "success") {
          this.user.nombre = this.settings.nombre;
          document.cookie = `user=${encodeURIComponent(
            JSON.stringify(this.user)
          )}; path=/`;
        }
      } catch (error) {
        console.error("Error actualizando perfil:", error);
      }
    },
  },
};
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

.perfil {
  margin-top: 110px;
  margin-left: 48px;
  margin-right: 48px;
}

.perfil-title {
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

.perfil-title h1 {
  filter: drop-shadow(0 4px 4px #00000073);
  /* drop shadow */
  font-weight: bold;
  font-size: 48px;
  color: #fff;
}

.division {
  width: 100%;
  display: flex;
  height: auto;
  min-height: 680px;
  max-height: 680px;
  padding-bottom: 30px;
}

.perfil-vista {
  display: flex;
  flex-direction: column;
  background-color: #5759cd;
  filter: drop-shadow(0 2px 2px #00000073);
  /* drop shadow */

  border-radius: 8px;
  width: 30%;
  height: auto;
  align-items: center;
  text-align: center;
  padding: 20px;
  font-weight: bold;
}

.perfil-vista > #perfil_img > img {
  margin-bottom: 20px;
  width: 100%;
  max-width: 250px;
  height: 250px;
  object-fit: cover;
}

.perfil-vista > #perfil_img {
  margin: 20px;
}

.btn-profile-update {
  background-color: #8d89f9;
  filter: drop-shadow(0 2px 2px #00000073);
  /* drop shadow */
  color: #fff;
  font-weight: bold;
}
.btn-confirm-update {
  background-color: #8d89f9;
  filter: drop-shadow(0 2px 2px #00000073);
  /* drop shadow */
  color: #fff;
  font-weight: bold;
}

.btn-confirm-update:hover {
  background-color: #6acb72;
  color: #fff;
}

.btn-profile-update {
  background-color: #8d89f9;
  filter: drop-shadow(0 2px 2px #00000073);
  /* drop shadow */
  color: #fff;
  font-weight: bold;
}

.btn-profile-update:hover {
  background-color: #6acb72;
  color: #fff;
}

.perfil-vista h3 {
  font-weight: bold;
  font-size: 28px;
}

.perfil-vista > .socials {
  display: flex;
  flex-direction: row;
  justify-content: center;
  filter: drop-shadow(0 2px 2px #00000073);
  /* drop shadow */
  background: #8d89f9;
  border-radius: 8px;
  padding: 5px;
  gap: 5px;
}

.perfil-vista .socials .social-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 8px;
  transition: all 0.3s ease-in-out;
}

.perfil-vista .socials .social-button:hover {
  transform: scale(1.1);
}

.perfil-vista .socials .social-button img {
  margin: 0;
  filter: drop-shadow(0 2px 2px #00000071);
}

.perfil-vista i {
  filter: drop-shadow(0 4px 4px #00000073);
}

.perfil-vista h4 {
  padding: 20px;
  font-weight: bold;
  font-size: 20px;
  color: #fff;
  filter: drop-shadow(0 2px 2px #00000071);
}

.ajustes {
  background-color: #5759cd;
  filter: drop-shadow(0 2px 2px #00000073);
  /* drop shadow */
  width: 70%;
  height: auto;
  margin-left: 30px;
  border-radius: 8px;
}

.tab-content {
  border-radius: 8px;
  display: flex;
  width: 100%;
  flex-direction: column;
  align-items: center;
  height: auto;
  justify-content: center;
}

.tab-content > .active {
  display: flex;
  align-items: center;
  flex-direction: column;
  width: 100%;
  padding: 30px;
}

.tab-content form {
  background-color: #5759cd;
  color: #fff;
  padding: 24px;
  border-radius: 8px;
  height: auto;
  width: 100%;
  min-width: 320px;
}

.tab-content form > input {
  padding: 1.2rem;
  border: 2px solid #ddd;
  border-radius: 15px;
  transition: all 0.3s ease;
}

.tab-content form > label {
  display: block;
  font-size: 1.1rem;
  font-weight: 500;
}

.tab-content form > input:focus {
  outline: none;
  border-color: #8d89f9;
  box-shadow: 0 0 0 3px rgba(141, 137, 249, 0.3);
}

.tab-content form > button {
  background-color: #8d89f9;
  filter: drop-shadow(0 2px 2px #00000073);
  /* drop shadow */
  color: #fff;
  font-weight: bold;
}

.estadisticas-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding-left: 100px;
  padding-right: 100px;
  width: 100%;
}

.estadistica-item {
  background-color: #4a4da5;
  color: #fff;
  padding: 20px;
  border-radius: 10px;
  display: flex;
  text-align: left;
  justify-content: space-between;
  filter: drop-shadow(0 4px 4px #00000073);
  /* drop shadow */
  align-items: center;
  width: 100%;
  height: auto;
  max-height: 80px;
}

.estadistica-item h4 {
  font-size: 24px;
  filter: drop-shadow(0 4px 4px #00000073);
  /* drop shadow */
  margin: 0;
}

.estadistica-valor {
  font-size: 24px;
  font-weight: bold;
  margin: 0;
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
  font-size: 24px;
  font-weight: bold;
}

.nav-tabs {
  display: flex;
  width: 100%;
  border: 0;
  filter: drop-shadow(0 2px 2px #00000073);
  /* drop shadow */
}

.nav-tabs li {
  flex: 1;
  text-align: center;
}

.nav-tabs li a {
  display: block;
  padding: 15px 0;
  font-size: 18px;
  font-weight: bold;
  color: #fff;
  background-color: #4a4da5;
  text-decoration: none;
  border: 0;
  border-radius: 8px;
  align-content: center;
}

.nav-link {
  height: 100%;
}

.nav-link.active {
  background-color: #8d89f9;
  color: #fff;
  border: 0;
  border-radius: 8px;
}

.nav-tabs li.active a {
  background-color: #8d89f9 !important;
  border: 0;
}

.nav-tabs li:hover a {
  background-color: #6a6ecb !important;
  border: 0;
}

@media (max-width: 1024px) {
  .perfil {
    margin-left: 20px;
    margin-right: 20px;
  }

  .perfil-vista > #perfil_img > img {
    height: 250px;
  }

  .perfil-vista > #perfil_img {
    margin: 20px;
  }

  .division {
    flex-direction: column;
    align-items: center;
    height: auto;
    max-height: unset;
    width: 100%;
  }

  .perfil-vista {
    width: 100%;
    margin-bottom: 20px;
  }

  .ajustes {
    width: 100%;
    margin-left: 0;
  }

  .tab-content {
    min-height: 510px;
  }
}

@media (max-width: 768px) {
  .division {
    height: 100%;
    max-height: unset;
  }

  .perfil-title h1 {
    font-size: 36px;
  }

  .perfil-vista {
    width: 100%;
    padding: 15px;
  }

  .perfil-vista h3 {
    font-size: 24px;
  }

  .perfil-vista h4 {
    font-size: 18px;
  }

  .perfil-vista img {
    max-width: 200px;
  }

  .ajustes {
    width: 100%;
  }

  .estadisticas-container {
    padding-left: 20px;
    padding-right: 20px;
  }
}

@media (max-width: 480px) {
  .perfil-title h1 {
    font-size: 28px;
  }

  .perfil-vista img {
    max-width: 150px;
  }

  .perfil-vista h3 {
    font-size: 20px;
  }

  .perfil-vista h4 {
    font-size: 16px;
  }

  .nav-tabs li {
    width: 100%;
  }

  .nav-tabs li a {
    font-size: 14px;
    padding: 10px 0;
  }

  .tab-content {
    min-height: 460px;
  }

  .tab-content form > label,
  input {
    font-size: 14px;
  }

  .tab-content form > input {
    height: 40px;
  }

  .tab-content form {
    min-width: 130px;
    max-width: 250px;
  }

  .estadisticas-container {
    flex-direction: column;
    padding-left: 10px;
    padding-right: 10px;
  }

  .estadistica-item {
    flex-direction: column;
    text-align: center;
    padding: 10px;
    max-height: 100%;
  }

  .estadistica-item h4,
  .estadistica-valor {
    font-size: 18px;
  }

  .estadistica-valor img {
    margin-top: 10px;
    width: 100px;
  }
}

.password-input-container {
  position: relative;
  width: 100%;
}

.password-toggle-btn {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.eye-icon {
  width: 20px;
  height: 20px;
}
</style>
