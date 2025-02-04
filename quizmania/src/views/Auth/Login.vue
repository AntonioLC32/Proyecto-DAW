<template>
  <div>
    <Header />
    <div class="login-container">
      <form class="login-form" @submit.prevent="handleLogin">
        <h2 class="form-title">Iniciar Sesión</h2>

        <div class="form-group">
          <label for="email" class="form-label">Nombre de usuario</label>
          <input
            type="user"
            id="user"
            v-model="user"
            required
            autocomplete="user"
            class="form-input"
            placeholder="Ingresa tu nombre de usuario"
          />
        </div>

        <div class="form-group">
          <label for="password" class="form-label">Contraseña</label>
          <div class="password-input-container">
            <input
              :type="passwordVisible ? 'text' : 'password'"
              id="password"
              v-model="password"
              required
              autocomplete="current-password"
              class="form-input"
              placeholder="Ingresa tu contraseña"
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

        <button type="submit" class="submit-btn">INICIAR SESIÓN</button>

        <div class="additional-options">
          <span class="register-span">
            ¿No tienes una cuenta?
            <router-link to="/register" class="register-link">
              Regístrate
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
  name: "Perfil",
  data() {
    return {
      email: "",
      password: "",
      errorMessage: "",
      passwordVisible: false,
    };
  },
  methods: {
    async handleLogin() {
      try {
        // Simulación de llamada a API
        if (this.password.length < 6) {
          throw new Error("La contraseña debe tener al menos 6 caracteres");
        }

        // Aquí iría tu lógica real de autenticación
        const response = await new Promise((resolve) => {
          setTimeout(() => {
            resolve({
              data: {
                user: {
                  email: this.email,
                  token: "fake-jwt-token",
                },
              },
            });
          }, 1000);
        });

        // Guardar en Vuex o localStorage
        localStorage.setItem("authToken", response.data.user.token);

        // Redireccionar
        this.$router.push("/");
      } catch (error) {
        this.errorMessage = error.message || "Error al iniciar sesión";
        setTimeout(() => {
          this.errorMessage = "";
        }, 3000);
      }
    },
    togglePasswordVisibility() {
      this.passwordVisible = !this.passwordVisible;
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
  padding: 2rem;
}

.login-form {
  color: white;
  background: #5759cd;
  padding: 4rem;
  border-radius: 20px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 600px;
  transform: scale(1.2);
}

.form-title {
  text-align: center;
  margin-bottom: 3rem;
  font-family: "Montserrat", sans-serif;
  font-size: 2.5rem;
  letter-spacing: 1px;
}

.form-group {
  margin-bottom: 2.5rem;
}

.form-label {
  display: block;
  margin-bottom: 0.8rem;
  font-size: 1.1rem;
  font-weight: 500;
}

.password-input-container {
  position: relative;
  width: 100%;
}

.form-input {
  width: 100%;
  padding: 1.2rem;
  border: 2px solid #ddd;
  border-radius: 15px;
  font-size: 1.2rem;
  transition: all 0.3s ease;
}

.form-input:focus {
  outline: none;
  border-color: #8d89f9;
  box-shadow: 0 0 0 3px rgba(141, 137, 249, 0.3);
}

.form-input::placeholder {
  color: #b0b0b0;
  font-size: 1rem;
}

.password-toggle-btn {
  position: absolute;
  right: 15px;
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
  width: 24px;
  height: 24px;
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

.additional-options {
  margin-top: 2.5rem;
  text-align: center;
}

.register-span {
  color: white;
  font-size: 1.1rem;
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
  color: #dc3545;
  margin-top: 2rem;
  text-align: center;
  font-size: 1.1rem;
}

@media (max-width: 768px) {
  .login-form {
    max-width: 95%;
    padding: 2.5rem;
    transform: scale(1);
  }

  .form-title {
    font-size: 2rem;
  }

  .form-label,
  .register-span,
  .error-message {
    font-size: 1rem;
  }
}
</style>
