<template>
  <div class="usuarios">
    <h1 class="titulo-usuarios">GESTIÓN DE USUARIOS</h1>

    <div class="num-usuarios">
      <div class="total-usuarios">
        <span>{{ totalUsuarios }}</span> Usuarios Totales
      </div>
      <div class="usuarios-conectados">
        <span>{{ usuariosConectados }}</span> Usuarios Conectados
      </div>
    </div>

    <div class="content-wrapper">
      <div class="left-column">
        <section class="tabla">
          <Table
            :headers="headers"
            :rows="rows"
            @eliminar="deshabilitarUsuario"
            @info="abrirPopup"
          />
        </section>
      </div>

      <div class="right-column">
        <section class="edit-user">
          <!-- Imagen de perfil del administrador -->
          <img :src="getImageUrl(adminData.imagen)" alt="Admin" />

          <form action="" @submit.prevent="actualizarAdmin">
            <label for="username">Nombre de usuario</label>
            <input
              type="text"
              id="username"
              placeholder="Ej: admin123"
              v-model="adminData.nombre"
              required
            />

            <label for="email">Correo electrónico</label>
            <input
              type="email"
              id="email"
              placeholder="Ej: admin@dominio.com"
              v-model="adminData.email"
              required
            />

            <!-- Botón personalizado para seleccionar imagen -->
            <div class="custom-file-upload">
              <button
                v-if="!nuevaImagenPreview"
                @click="$refs.fileInput.click()"
                class="popup-btn cambiar-imagen-btn"
              >
                Seleccionar Imagen
              </button>
              <button
                v-else
                @click="guardarCambios"
                class="btn btn-confirm-update mb-3"
              >
                Confirmar Cambio
              </button>
              <input
                type="file"
                ref="fileInput"
                hidden
                accept="image/*"
                @change="handleImageUpload"
              />
            </div>

            <!-- Botones centrados -->
            <!--
            
            <div class="botones-form">
              <button @click="guardarCambios" class="popup-btn">GUARDAR</button>
              <button type="button" class="btn-cancel" @click="cancelarEdicion">
                Cancelar
              </button>
            </div>
             -->
          </form>
        </section>
      </div>
    </div>

    <div v-if="popupVisible" class="popup-backdrop" @click.self="cerrarPopup">
      <div class="popup" @click.stop>
        <span class="close" @click="cerrarPopup">&times;</span>
        <div class="popup-content">
          <div class="popup-text">
            <h2>{{ usuarioSeleccionado.user }}</h2>
            <p>{{ usuarioSeleccionado.correo }}</p>
            <p>Victorias: {{ usuarioSeleccionado.victorias }}</p>
            <p>Derrotas: {{ usuarioSeleccionado.derrotas }}</p>
            <p>Ranking: {{ usuarioSeleccionado.ranking }}</p>
            <p>Puntos: {{ usuarioSeleccionado.puntos }}</p>
          </div>
          <img
            :src="getImageUrl(usuarioSeleccionado.imagen)"
            :alt="usuarioSeleccionado.user"
            class="popup-img"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Table from "./Table.vue";

export default {
  name: "Usuarios",
  components: { Table },
  data() {
    return {
      nuevaImagenPreview: null,
      totalUsuarios: 0,
      usuariosConectados: 0,
      headers: [
        { key: "id", label: "ID" },
        { key: "user", label: "USER" },
        { key: "correo", label: "CORREO" },
        { key: "acciones", label: "ACCIONES" },
      ],
      rows: [],
      popupVisible: false,
      usuarioSeleccionado: {},
      mensaje: "",
      mensajeTipo: "",
      adminData: {
        id: "",
        nombre: "",
        email: "",
        imagen: "",
      },
      selectedImage: null,
    };
  },
  mounted() {
    this.usuariosTotales();
    this.obtenerUsuariosConectados();
    this.fetchUsuarios();
    // Asignamos datos de las cookies
    //const cookieData = this.$cookies.get("user");
    /*if (cookieData) {
      this.adminData = {
        id: cookieData.id_usuario || "",
        nombre: cookieData.nombre || "",
        email: cookieData.correo || "",
        // Si en la cookie hay imagen, se asigna; si no, se deja default.
        imagen: cookieData.imagen
          ? "src/" + cookieData.imagen
          : "src/assets/users/admin/default.png",
      };
    }*/
    this.cargarUsuario();
  },
  methods: {
    async cargarUsuario() {
      try {
        const response = await fetch("/api/perfil/select_perfil.php", {
          credentials: "include",
        });

        if (!response.ok)
          throw new Error(`Error HTTP! estado: ${response.status}`);

        const data = await response.json();

        if (data.error) {
          console.error("Error en la API:", data.error);
          return;
        }

        this.adminData = {
          ...this.adminData,
          nombre: data.nombre || this.adminData?.nombre,
          imagen: data.imagen || this.adminData?.imagen,
          email: data.correo || this.adminData?.email,
        };
      } catch (error) {
        console.error("Error cargando perfil:", error.message);
      }
    },
    abrirPopup(usuario) {
      this.usuarioSeleccionado = { ...usuario };
      this.popupVisible = true;
    },
    cerrarPopup() {
      this.popupVisible = false;
    },
    // Si usas getUserImage para mostrar la imagen en el popup:
    /*getUserImage(imagePath) {
      const timestamp = new Date().getTime(); // Para evitar caché
      return "../../" + imagePath
        ? `${imagePath}?t=${timestamp}`
        : "src/assets/users/admin/default.png";
    },*/
    async deshabilitarUsuario(usuario) {
      try {
        const confirmar = confirm(
          `¿Deshabilitar al usuario "${usuario.user}"?`
        );
        if (!confirmar) return;
        const response = await fetch(
          "/api/index.php?action=deshabilitarUsuario",
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ id_usuario: usuario.id }),
          }
        );
        const data = await response.json();
        if (data.status === "success") {
          this.mensaje = "Usuario deshabilitado correctamente";
          this.mensajeTipo = "success";
          this.fetchUsuarios();
        } else {
          this.mensaje = data.mensaje || "Error al deshabilitar el usuario";
          this.mensajeTipo = "error";
        }
      } catch (error) {
        this.mensaje = "Error de conexión: " + error.message;
        this.mensajeTipo = "error";
      } finally {
        setTimeout(() => (this.mensaje = ""), 5000);
      }
    },
    async fetchUsuarios() {
      try {
        const response = await fetch("/api/index.php?action=obtenerUsuarios");
        const data = await response.json();
        if (data.status === "success") {
          this.rows = data.data.map((usuario) => ({
            ...usuario,
            acciones: { editar: false, eliminar: true, info: true },
          }));

          // Buscar el administrador (por ejemplo, rol "admin")
          const admin = data.data.find(
            (u) => u.rol && u.rol.toLowerCase() === "admin"
          );
          if (admin) {
            // Si la imagen en BD es válida y no es "default.png", se actualiza adminData.imagen
            if (
              admin.imagen &&
              admin.imagen !== "assets/users/admin/default.png"
            ) {
              // admin.imagen ya debería contener la ruta correcta, por ejemplo: "assets/users/admin/andres.png"
              this.adminData.imagen = admin.imagen;
            } else {
              // Si no hay imagen o es default, se mantiene la default
              this.adminData.imagen = "src/assets/users/admin/default.png";
            }
          }
        }
      } catch (error) {
        console.error("Error al obtener usuarios:", error);
      }
    },
    async usuariosTotales() {
      try {
        const response = await fetch("/api/index.php?action=usuariosTotales");
        const json = await response.json();
        if (json.status === "success") {
          this.totalUsuarios = json.data;
        } else {
          console.error("Error en API:", json.error);
        }
      } catch (error) {
        console.error("Error al obtener usuarios totales:", error);
      }
    },
    async obtenerUsuariosConectados() {
      try {
        const response = await fetch(
          "/api/index.php?action=usuariosConectados"
        );
        const json = await response.json();
        if (json.status === "success") {
          this.usuariosConectados = json.data;
        } else {
          console.error("Error en API:", json.error);
        }
      } catch (error) {
        console.error("Error al obtener usuarios conectados:", error);
      }
    },
    handleImageUpload(event) {
      const file = event.target.files[0];
      if (file && file.type.startsWith("image/")) {
        if (this.nuevaImagenPreview) {
          URL.revokeObjectURL(this.nuevaImagenPreview);
        }
        this.nuevaImagenPreview = URL.createObjectURL(file);
        this.selectedImage = file; // Track the selected image
      } else {
        alert("Por favor selecciona un archivo de imagen válido.");
      }
    },
    convertFileToBase64(file) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = () => resolve(reader.result);
        reader.onerror = (error) => reject(error);
      });
    },
    async guardarCambios() {
      try {
        let base64Image = null;
        if (this.selectedImage) {
          base64Image = await this.convertFileToBase64(this.selectedImage);
        }
        const payload = {
          action: "actualizarUsuario",
          id_usuario: this.adminData.id,
          nombre: this.adminData.nombre,
          email: this.adminData.email,
          file: base64Image,
        };
        const response = await fetch(
          "/api/index.php?action=actualizarUsuario",
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
          }
        );
        const data = await response.json();
        if (data.status === "success") {
          alert("Usuario actualizado correctamente");
          this.adminData.imagen = data.nuevaImagen || this.adminData.imagen;
          this.nuevaImagenPreview = null;
          this.selectedImage = null;

          const updatedAdminData = {
            id_usuario: this.adminData.id,
            nombre: this.adminData.nombre,
            correo: this.adminData.email,
            imagen: this.adminData.imagen,
          };
          this.$cookies.set("user", updatedAdminData, "1d");
        } else {
          alert(data.mensaje || "Error al actualizar usuario");
        }
      } catch (error) {
        alert("Error de conexión: " + error.message);
      }
    },
    getImageUrl(path) {
      if (!path) {
        return "/src/assets/users/default/default.png";
      } else {
        return `/src/${path}`;
      }
    },
    cancelarEdicion() {
      window.location.reload();
    },
  },
};
</script>

<style scoped>
.usuarios {
  margin-left: 60px;
  background: linear-gradient(to bottom, #8d89f8 0%, #8682eb 54%, #535192 100%);
  min-height: 100vh;
  padding: 20px;
  color: #333;
  font-family: Roboto, sans-serif;
  width: calc(100% - 60px);
}

.titulo-usuarios {
  margin-bottom: 20px;
  color: #fff;
  text-align: center;
  font-weight: bold;
}

.num-usuarios {
  display: flex;
  justify-content: space-between;
  gap: 20px;
}

.total-usuarios,
.usuarios-conectados {
  text-align: center;
  flex: 1;
  padding: 20px;
  border-radius: 10px;
  font-size: 24px;
  font-weight: bold;
  color: #8d89f8;
  background-color: #fff;
}

.total-usuarios span,
.usuarios-conectados span {
  display: block;
  font-size: 40px;
  font-weight: 900;
  color: #5759cd;
}

.content-wrapper {
  display: flex;
  gap: 20px;
  align-items: stretch;
  margin-top: 20px;
}

.left-column {
  flex: 2;
}

.right-column {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.tabla {
  margin-top: 20px;
}

.edit-user {
  margin-top: 20px;
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  align-items: center;
}

.edit-user img {
  width: 150px;
  height: 150px;
  object-fit: cover;
  border-radius: 50%;
  margin-bottom: 15px;
}

.edit-user form {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.edit-user label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 8px;
}

.edit-user input[type="text"],
.edit-user input[type="email"] {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.3s, box-shadow 0.3s;
}

.edit-user input:focus {
  outline: 2px solid #6c5ce7;
  border-color: transparent;
}

.custom-file-upload {
  text-align: center;
  margin: 10px 0;
}

.custom-file-upload input[type="file"] {
  display: none;
}

.popup-btn {
  background-color: #6c5ce7;
  color: white;
  padding: 12px 20px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  text-transform: uppercase;
  transition: all 0.3s ease;
  margin-top: 10px;
  align-self: center;
  width: 100%;
}

/*
.btn-file-upload {
  display: inline-block;
  padding: 10px 20px;
  background-color: #6c5ce7;
  color: #fff;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
  transition: background-color 0.3s;
}
*/

.btn-file-upload:hover {
  background-color: #5b4bc4;
}

.botones-form {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-top: 20px;
}

.botones-form button {
  padding: 12px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  text-transform: uppercase;
  transition: background-color 0.3s;
}

.btn-submit {
  background-color: #6c5ce7;
  color: #fff;
}

.btn-submit:hover {
  background-color: #5b4bc4;
}

.btn-cancel {
  background-color: #ddd;
  color: #333;
}

.btn-cancel:hover {
  background-color: #ccc;
}

/* Popup styles */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translate(-50%, -50%) scale(0.7);
  }
  to {
    opacity: 1;
    transform: translate(-50%, -50%) scale(1);
  }
}

.popup-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 999;
  display: flex;
  justify-content: center;
  align-items: center;
  animation: backdropFadeIn 0.3s ease-out;
}

@keyframes backdropFadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.popup {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  width: 500px;
  max-width: 90%;
  z-index: 1000;
  animation: fadeIn 0.3s cubic-bezier(0.25, 0.1, 0.25, 1);
  border: 1px solid rgba(108, 92, 231, 0.2);
}

.popup-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  max-width: 100%;
  flex-wrap: wrap;
}

.popup-text {
  flex: 1;
  min-width: 0;
}

.popup-text p {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
  display: block;
}

.popup-img {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.popup-content h2 {
  color: #4a4aa6;
  font-size: 20px;
  margin-bottom: 20px;
  border-bottom: 2px solid rgba(108, 92, 231, 0.1);
  padding-bottom: 10px;
}

.close {
  position: absolute;
  right: 8px;
  top: -2px;
  cursor: pointer;
  font-size: 24px;
  color: #888;
  transition: color 0.3s ease;
}

.close:hover {
  color: #6c5ce7;
}

@media (max-width: 1300px) {
  .content-wrapper {
    flex-direction: column;
  }
  .right-column {
    margin-top: 20px;
  }
}

/* Boton actualizar imagen */
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
</style>
