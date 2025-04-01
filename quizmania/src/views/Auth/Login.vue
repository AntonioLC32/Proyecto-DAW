<template>
  <div>
    <div class="login-container">
      <form class="login-form" @submit.prevent="handleLogin">
        <h2 class="form-title">
          {{ textosTraducidos["Iniciar Sesión"] || "Iniciar Sesión" }}
        </h2>
        <div class="form-group">
          <label for="user" class="form-label">
            {{ textosTraducidos["Nombre de usuario"] || "Nombre de usuario" }}
          </label>
          <input
            type="text"
            id="user"
            v-model="user"
            required
            autocomplete="username"
            class="form-input"
            :placeholder="
              textosTraducidos['Ingresa tu nombre de usuario'] ||
              'Ingresa tu nombre de usuario'
            "
          />
        </div>
        <div class="form-group">
          <label for="password" class="form-label">
            {{ textosTraducidos["Contraseña"] || "Contraseña" }}
          </label>
          <div class="password-input-container">
            <input
              :type="passwordVisible ? 'text' : 'password'"
              id="password"
              v-model="password"
              required
              autocomplete="current-password"
              class="form-input"
              :placeholder="
                textosTraducidos['Ingresa tu contraseña'] ||
                'Ingresa tu contraseña'
              "
            />
            <button
              type="button"
              class="password-toggle-btn"
              @click="togglePasswordVisibility"
              aria-label="Toggle password visibility"
            >
              <svg
                v-if="!passwordVisible"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="#8d89f9"
                class="eye-icon"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88"
                />
              </svg>
              <svg
                v-else
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="#8d89f9"
                class="eye-icon"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"
                />
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
                />
              </svg>
            </button>
          </div>
        </div>
        <button type="submit" class="submit-btn">
          {{ textosTraducidos["INICIAR SESIÓN"] || "INICIAR SESIÓN" }}
        </button>
        <button
          type="button"
          class="forgot-btn"
          @click="showForgotPasswordModal = true"
        >
          {{
            textosTraducidos["¿Te has olvidado de tu contraseña?"] ||
            "¿Te has olvidado de tu contraseña?"
          }}
        </button>
        <div
          v-show="showForgotPasswordModal"
          class="modal-overlay"
          @click="showForgotPasswordModal = false"
        >
          <div class="modal" @click.stop>
            <button
              class="modal-close"
              @click="showForgotPasswordModal = false"
            >
              ×
            </button>
            <h3>
              {{
                textosTraducidos["Recuperar Contraseña"] ||
                "Recuperar Contraseña"
              }}
            </h3>
            <form @submit.prevent="handleForgotPassword">
              <div class="form-group">
                <label for="email">
                  {{
                    textosTraducidos["Correo Electrónico"] ||
                    "Correo Electrónico"
                  }}
                </label>
                <input
                  type="email"
                  id="email"
                  v-model="forgotPasswordEmail"
                  required
                  class="form-input"
                  :placeholder="
                    textosTraducidos['Ingresa tu correo electrónico'] ||
                    'Ingresa tu correo electrónico'
                  "
                />
              </div>
              <button type="submit" class="submit-btn">
                {{ textosTraducidos["Enviar"] || "Enviar" }}
              </button>
            </form>
            <div v-if="forgotPasswordError" class="error-message">
              {{ forgotPasswordError }}
            </div>
          </div>
        </div>
        <div class="additional-options">
          <span class="register-span">
            {{
              textosTraducidos["¿No tienes una cuenta?"] ||
              "¿No tienes una cuenta?"
            }}
            <router-link to="/register" class="register-link">
              {{ textosTraducidos["Regístrate"] || "Regístrate" }}
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
import axios from "axios";
export default {
  name: "Login",
  data() {
    return {
      user: "",
      password: "",
      errorMessage: "",
      passwordVisible: false,
      textosTraducidos: {},
      traduccionesCargando: false,
      idiomaUsuario: "es",
      showForgotPasswordModal: false,
      forgotPasswordEmail: "",
      forgotPasswordError: "",
    };
  },
  async mounted() {
    this.idiomaUsuario = navigator.language.split("-")[0] || "es";
    if (this.idiomaUsuario !== "es") {
      await this.traducirContenido();
    }
  },
  methods: {
    async handleLogin() {
      try {
        if (this.password.length < 6) {
          throw new Error(
            this.textosTraducidos[
              "La contraseña debe tener al menos 6 caracteres"
            ] || "La contraseña debe tener al menos 6 caracteres"
          );
        }
        const response = await axios.post("/api/index.php?action=login", {
          username: this.user,
          password: this.password,
        });
        const data = response.data;
        if (data.status === "success") {
          this.$cookies.set("user", JSON.stringify(data.user), "7d");
          this.$router.push("/quizmania").then(() => {
            location.reload();
          });
        } else {
          throw new Error(
            data.mensaje ||
              this.textosTraducidos["Error al iniciar sesión"] ||
              "Error al iniciar sesión"
          );
        }
      } catch (error) {
        this.errorMessage =
          error.message ||
          this.textosTraducidos["Error al iniciar sesión"] ||
          "Error al iniciar sesión";
        setTimeout(() => {
          this.errorMessage = "";
        }, 3000);
      }
    },
    togglePasswordVisibility() {
      this.passwordVisible = !this.passwordVisible;
    },
    async handleForgotPassword() {
      try {
        const response = await axios.post("/api/perfil/comprobar_email.php", {
          email: this.forgotPasswordEmail,
        });
        if (response.data.status === "success") {
          this.$router.push({
            path: "/reset-password",
            query: {
              email: this.forgotPasswordEmail,
              token: response.data.token,
            },
          });
        } else {
          throw new Error(
            this.textosTraducidos["Correo no encontrado"] ||
              "Correo no encontrado"
          );
        }
      } catch (error) {
        this.forgotPasswordError =
          this.textosTraducidos["Error al verificar el correo"] ||
          "Error al verificar el correo";
        setTimeout(() => {
          this.forgotPasswordError = "";
        }, 3000);
      }
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
        "Iniciar Sesión",
        "Nombre de usuario",
        "Contraseña",
        "INICIAR SESIÓN",
        "¿No tienes una cuenta?",
        "Regístrate",
        "Ingresa tu nombre de usuario",
        "Ingresa tu contraseña",
        "La contraseña debe tener al menos 6 caracteres",
        "Error al iniciar sesión",
        "¿Te has olvidado de tu contraseña?",
        "Recuperar Contraseña",
        "Correo Electrónico",
        "Ingresa tu correo electrónico",
        "Enviar",
        "Correo no encontrado",
        "Error al verificar el correo",
        "La contraseña no cumple con los requisitos mínimos",
        "Usuario o contraseña incorrectos",
        "Por favor complete todos los campos",
        "Ha ocurrido un error, intente nuevamente",
      ];
      const traducciones = await Promise.all(textos.map(this.traducirTexto));
      textos.forEach((texto, index) => {
        this.textosTraducidos[texto] = traducciones[index];
      });
      this.traduccionesCargando = false;
    },
  },
};
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #cac5f5;
  padding: 1rem;
}
.login-form {
  color: white;
  background: #5759cd;
  padding: 2rem;
  border-radius: 20px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 500px;
}
.form-title {
  text-align: center;
  margin-bottom: 2rem;
  font-family: "Montserrat", sans-serif;
  font-size: 2rem;
  letter-spacing: 1px;
}
.form-group {
  margin-bottom: 1.5rem;
}
.form-label {
  display: block;
  margin-bottom: 0.6rem;
  font-size: 1rem;
  font-weight: 500;
}
.password-input-container {
  position: relative;
  width: 100%;
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
.form-input::placeholder {
  color: #b0b0b0;
  font-size: 0.9rem;
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
.forgot-btn {
  width: 100%;
  padding: 0.8rem;
  background-color: transparent;
  color: #8d89f9;
  border: none;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: bold;
  cursor: pointer;
  transition: color 0.3s;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-top: 1rem;
  text-decoration: underline;
}
.forgot-btn:hover {
  color: #6c69d4;
}
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

/* Enhanced Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(5px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease-in-out;
}

.modal {
  background: #fff;
  color: #333;
  border-radius: 20px;
  width: 90%;
  max-width: 450px;
  max-height: 450px;
  padding: 2rem;
  text-align: center;
  position: relative;
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  animation: slideUp 0.4s cubic-bezier(0.18, 0.89, 0.32, 1.28);
  border: 2px solid #8d89f9;
  overflow: auto;
}

.modal::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 8px;
  background: #5759cd;
}

.modal-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: #f0f0f7;
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 1.8rem;
  line-height: 0;
  cursor: pointer;
  color: #5759cd;
  transition: all 0.3s ease;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
}

.modal-close:hover {
  background: #5759cd;
  color: white;
  transform: rotate(90deg);
  box-shadow: 0 5px 15px rgba(87, 89, 205, 0.3);
}

.modal h3 {
  font-size: 1.8rem;
  color: #5759cd;
  font-weight: 700;
  text-align: center;
  margin-top: 0.5rem;
  margin-bottom: 1.5rem;
  letter-spacing: 0.5px;
}

.modal .form-group {
  margin-bottom: 1.8rem;
}

.modal label {
  display: block;
  margin-bottom: 0.8rem;
  font-weight: 600;
  color: #4a4a4a;
  font-size: 1rem;
  text-align: left;
}

.modal .form-input {
  width: 100%;
  padding: 1rem 1.2rem;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background-color: #f9f9fd;
}

.modal .form-input:focus {
  border-color: #8d89f9;
  box-shadow: 0 0 0 4px rgba(141, 137, 249, 0.15);
  background-color: #fff;
}

.modal .form-input::placeholder {
  color: #b0b0b0;
  font-size: 0.95rem;
}

.modal .submit-btn {
  width: 100%;
  padding: 1rem;
  background: #5759cd;
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 700;
  font-size: 1.1rem;
  transition: all 0.3s ease;
  letter-spacing: 1px;
  box-shadow: 0 5px 15px rgba(87, 89, 205, 0.3);
}

.modal .submit-btn:hover {
  background: #4547b0;
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(87, 89, 205, 0.4);
}

.modal .submit-btn:active {
  transform: translateY(-1px);
  box-shadow: 0 4px 10px rgba(87, 89, 205, 0.4);
}

.modal .error-message {
  margin-top: 1rem;
  color: #fff;
  background-color: rgba(220, 53, 69, 0.9);
  padding: 0.8rem;
  border-radius: 8px;
  text-align: center;
  font-size: 0.95rem;
  font-weight: 500;
  animation: shake 0.5s ease-in-out;
}

@keyframes shake {
  0%,
  100% {
    transform: translateX(0);
  }
  10%,
  30%,
  50%,
  70%,
  90% {
    transform: translateX(-5px);
  }
  20%,
  40%,
  60%,
  80% {
    transform: translateX(5px);
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

@media (max-width: 480px) {
  .modal {
    padding: 1.5rem;
    max-width: 90%;
  }

  .modal h3 {
    font-size: 1.5rem;
  }
}

@media (max-height: 600px) {
  .modal {
    padding: 1.2rem;
    max-height: 90vh;
  }
}

@media (max-width: 768px) {
  .login-form {
    max-width: 100%;
    padding: 1.5rem;
  }
  .form-title {
    font-size: 1.8rem;
    margin-bottom: 1.5rem;
  }
}
@media (max-width: 480px) {
  .login-form {
    padding: 1.2rem;
  }
  .form-title {
    font-size: 1.5rem;
    margin-bottom: 1.2rem;
  }
  .form-group {
    margin-bottom: 1.2rem;
  }
  .form-input {
    padding: 0.7rem;
  }
  .submit-btn {
    font-size: 1rem;
    padding: 0.7rem;
  }
  .modal {
    padding: 1.5rem 1rem;
    max-width: 90%;
  }
}
@media (max-height: 600px) {
  .modal {
    padding: 1rem 0.8rem;
  }
}
@media (min-height: 900px) {
  .login-container {
    padding: 2rem;
  }
}
@media (max-height: 600px) {
  .login-container {
    min-height: auto;
    padding-top: 2rem;
    padding-bottom: 2rem;
  }
  .login-form {
    padding: 1.2rem;
  }
  .form-group {
    margin-bottom: 1rem;
  }
}
@media (max-height: 500px) and (orientation: landscape) {
  .login-container {
    min-height: auto;
    padding: 1rem;
  }
  .login-form {
    max-width: 400px;
  }
}
</style>
