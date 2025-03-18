<template>
  <div>
    <div class="register-container">
      <form class="register-form" @submit.prevent="handleRegister">
        <h2 class="form-title">Registro de Usuario</h2>
        <div class="form-content">
          <!-- Campos del formulario -->
          <div class="form-column">
            <div class="form-group">
              <label for="username" class="form-label">Nombre de usuario</label>
              <input
                type="text"
                id="username"
                v-model="username"
                required
                class="form-input"
                placeholder="Ingresa tu nombre de usuario"
              />
            </div>
            <div class="form-group">
              <label for="email" class="form-label">Correo electrónico</label>
              <input
                type="email"
                id="email"
                v-model="email"
                required
                class="form-input"
                placeholder="Ingresa tu correo electrónico"
              />
            </div>
            <div class="form-group">
              <label for="password" class="form-label">Contraseña</label>
              <input
                :type="passwordVisible ? 'text' : 'password'"
                id="password"
                v-model="password"
                required
                class="form-input"
                placeholder="Crea una contraseña"
              />
            </div>
            <div class="form-group">
              <label for="confirmPassword" class="form-label">
                Confirmar Contraseña
              </label>
              <input
                :type="passwordVisible ? 'text' : 'password'"
                id="confirmPassword"
                v-model="confirmPassword"
                required
                class="form-input"
                placeholder="Repite tu contraseña"
              />
            </div>
          </div>
          <!-- Vista previa de imagen -->
          <div class="preview-column">
            <div class="image-preview">
              <div v-if="!previewImage" class="image-placeholder">
                Vista previa
              </div>
              <img
                v-else
                :src="previewImage"
                alt="Preview"
                class="preview-image"
              />
            </div>
            <div class="form-group file-upload-group">
              <input
                type="file"
                accept="image/*"
                @change="handleImageUpload"
                class="file-input"
                id="fileInput"
              />
              <label for="fileInput" class="upload-btn">
                {{ imageFile ? "Cambiar imagen" : "Subir imagen" }}
              </label>
            </div>
          </div>
        </div>
        <button type="submit" class="submit-btn">REGISTRARSE</button>
        <div class="additional-options">
          <span class="register-span">
            ¿Ya tienes una cuenta?
            <router-link to="/login" class="register-link">
              Inicia Sesión
            </router-link>
          </span>
        </div>
        <div v-if="errorMessage" class="error-message">
          {{ errorMessage }}
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: "Register",
  data() {
    return {
      username: "",
      email: "",
      password: "",
      confirmPassword: "",
      imageFile: null,
      previewImage: "",
      imageBase64: "", // 🔹 Almacena la imagen convertida en Base64
      errorMessage: "",
      passwordVisible: false,
    };
  },
  methods: {
    async handleRegister() {
      try {
        if (this.password !== this.confirmPassword) {
          throw new Error("Las contraseñas no coinciden");
        }

        const formData = {
          username: this.username,
          email: this.email,
          password: this.password,
          image: this.imageBase64, // Enviamos la imagen en formato Base64
        };

        const response = await fetch("/api/index.php?action=register", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(formData),
        });

        const result = await response.json();
        if (result.status === "success") {
          this.$cookies.set("user", JSON.stringify(result.user), "7d");
          //console.log(this.$cookies.get("user"));
          this.$router.push("/quizmania").then(() => {
            location.reload();
          });
        } else {
          throw new Error(result.mensaje || "Error en el registro");
        }
      } catch (error) {
        this.errorMessage = error.message;
        setTimeout(() => {
          this.errorMessage = "";
        }, 3000);
      }
    },

    handleImageUpload(event) {
      const file = event.target.files[0];
      if (file) {
        this.imageFile = file;
        this.previewImage = URL.createObjectURL(file);

        // Convertir la imagen a Base64
        const reader = new FileReader();
        reader.onload = (e) => {
          this.imageBase64 = e.target.result; // Guardamos la imagen convertida
        };
        reader.readAsDataURL(file);
      }
    },
  },
};
</script>

<style scoped>
/* Contenedor general */
.register-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding-top: 80px; /* Ajusta este valor según el alto de tu header */
  background-color: #cac5f5;
  padding-left: 1rem;
  padding-right: 1rem;
  box-sizing: border-box;
}

/* Formulario compacto */
.register-form {
  background: #5759cd;
  padding: 2rem;
  border-radius: 20px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 600px;
  box-sizing: border-box;
}

/* Título del formulario */
.form-title {
  text-align: center;
  margin-bottom: 2rem;
  font-family: "Montserrat", sans-serif;
  font-size: 2rem;
  letter-spacing: 1px;
  color: white;
}

/* Contenido en dos columnas */
.form-content {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
}

.form-column {
  flex: 1;
  min-width: 250px;
}

.preview-column {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-width: 150px;
}

/* Vista previa de imagen */
.image-preview {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  background-color: #6c69d4;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  border: 4px solid #8d89f9;
  margin-bottom: 1rem;
}

.image-placeholder {
  color: #c4c2ff;
  font-size: 1rem;
  text-align: center;
}

.preview-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* Input de archivo oculto */
.file-input {
  display: none;
}

.upload-btn {
  display: inline-block;
  padding: 0.6rem 1rem;
  background-color: #8d89f9;
  color: white;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
  width: 100%;
}

.upload-btn:hover {
  background-color: #6c69d4;
  transform: translateY(-2px);
}

/* Grupos y campos del formulario */
.form-group {
  margin-bottom: 1.5rem;
}

.form-label {
  display: block;
  margin-bottom: 0.6rem;
  font-size: 1rem;
  font-weight: 500;
  color: white;
}

.form-input {
  width: 100%;
  padding: 0.8rem 1rem;
  border: 2px solid #ddd;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.form-input:focus {
  outline: none;
  border-color: #8d89f9;
  box-shadow: 0 0 0 3px rgba(141, 137, 249, 0.3);
}

/* Botón de registro */
.submit-btn {
  width: 100%;
  padding: 0.8rem;
  background-color: #8d89f9;
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-top: 1rem;
}

.submit-btn:hover {
  background-color: #6c69d4;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.submit-btn:active {
  transform: translateY(-1px);
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}

/* Opciones adicionales */
.additional-options {
  margin-top: 1.5rem;
  text-align: center;
}

.register-span {
  color: white;
  font-size: 0.9rem;
}

.register-link {
  color: white;
  text-decoration: none;
  font-weight: bold;
  transition: all 0.3s ease;
}

.register-link:hover {
  color: #74eaff;
  text-decoration: underline;
}

.error-message {
  color: #ffcccb;
  background-color: rgba(220, 53, 69, 0.2);
  padding: 0.5rem;
  border-radius: 8px;
  margin-top: 1.5rem;
  text-align: center;
  font-size: 0.9rem;
}

/* Responsividad: en pantallas pequeñas se apilan los elementos y se reordena la vista previa arriba */
@media (max-width: 767px) {
  .register-container {
    margin-top: 20px;
  }
  .form-content {
    flex-direction: column;
  }
  /* Reordena la sección de imagen para que aparezca primero */
  .preview-column {
    order: -1;
  }
}

/* Ajustes para pantallas de poca altura */
@media (max-height: 600px) {
  .register-container {
    padding-top: 1rem;
    padding-bottom: 1rem;
  }
}
</style>
