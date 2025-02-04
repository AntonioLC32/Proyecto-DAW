<template>
  <div>
    <Header />
    <div class="register-container">
      <form class="register-form" @submit.prevent="handleRegister">
        <h2 class="form-title">Registro de Usuario</h2>

        <div class="form-content">
          <!-- Columna izquierda - Campos del formulario -->
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
              <label for="confirmPassword" class="form-label"
                >Confirmar Contraseña</label
              >
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

          <!-- Columna derecha - Vista previa de imagen -->
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

        <div class="submit-btn-container">
          <button type="submit" class="submit-btn">REGISTRARSE</button>
        </div>

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

        // Aquí iría la lógica de registro
        console.log("Datos de registro:", {
          username: this.username,
          email: this.email,
          password: this.password,
          image: this.imageFile,
        });

        // Redirección temporal
        this.$router.push("/login");
      } catch (error) {
        this.errorMessage = error.message || "Error en el registro";
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
      }
    },
    togglePasswordVisibility() {
      this.passwordVisible = !this.passwordVisible;
    },
  },
};
</script>

<style scoped>
.register-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #cac5f5;
  padding: 2rem;
  box-sizing: border-box;
}

.register-form {
  color: white;
  background: #5759cd;
  padding: 4rem;
  border-radius: 20px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 1000px;
  transform: scale(1);
}

.form-content {
  display: flex;
  justify-content: space-between;
  gap: 3rem;
}

.form-column {
  flex: 1;
}

.preview-column {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.image-preview {
  width: 350px;
  height: 350px;
  border-radius: 50%;
  background-color: #6c69d4;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  border: 4px solid #8d89f9;
  margin-bottom: 1.5rem;
}

.image-placeholder {
  color: #c4c2ff;
  font-size: 1.2rem;
}

.preview-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.file-input {
  display: none;
}

.upload-btn {
  display: inline-block;
  padding: 0.6rem 1rem;
  background-color: #8d89f9;
  color: white;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
  width: auto;
}

.upload-btn:hover {
  background-color: #6c69d4;
  transform: translateY(-2px);
}

.submit-btn {
  width: 100%;
  padding: 1rem;
  background-color: #8d89f9;
  color: white;
  border: none;
  border-radius: 15px;
  font-size: 1.2rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.submit-btn:hover {
  background-color: #6c69d4;
  transform: translateY(-3px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.submit-btn:active {
  transform: translateY(-1px);
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}

@media (max-width: 768px) {
  .register-container {
    padding: 2rem;
    align-items: flex-start;
    padding-top: 80px;
  }

  .register-form {
    width: 100%;
    max-width: 100%;
    margin-top: 1rem;
    padding: 1.5rem;
    overflow-y: auto;
    max-height: calc(100vh - 100px);
  }

  .image-preview {
    width: 200px;
    height: 200px;
    margin-top: 1rem;
  }

  .form-title {
    margin-bottom: 1.5rem;
    font-size: 2rem;
  }
}

@media (max-width: 480px) {
  .form-content {
    flex-direction: column-reverse;
    align-items: center;
  }

  .preview-column {
    margin-top: 1rem;
  }

  .image-preview {
    width: 250px;
    height: 250px;
    margin-bottom: 1rem;
  }
}

.form-title {
  text-align: center;
  margin-bottom: 3rem;
  font-family: "Montserrat", sans-serif;
  font-size: 2.5rem;
  letter-spacing: 1px;
}

.form-group {
  margin-bottom: 2rem;
}

.form-label {
  display: block;
  margin-bottom: 0.8rem;
  font-size: 1.1rem;
  font-weight: 500;
}

.form-input {
  width: 100%;
  padding: 1rem;
  border: 2px solid #ddd;
  border-radius: 15px;
  font-size: 1rem;
  transition: all 0.3s ease;
  margin-bottom: 0.5rem;
}

.submit-btn-container {
  margin-top: 2rem;
}

.additional-options {
  text-align: center;
  margin-top: 1.5rem;
}

.register-link {
  color: white;
  text-decoration: none;
  font-weight: bold;
  transition: color 0.3s ease;
}

.register-link:hover {
  color: #6c69d4;
}
</style>
