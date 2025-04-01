<template>
  <div class="reset-password-container">
    <form class="reset-password-form" @submit.prevent="handleResetPassword">
      <h2>
        {{
          textosTraducidos["Restablecer Contraseña"] || "Restablecer Contraseña"
        }}
      </h2>
      <div class="form-group">
        <label for="email">{{
          textosTraducidos["Correo Electrónico"] || "Correo Electrónico"
        }}</label>
        <input
          type="email"
          id="email"
          v-model="email"
          required
          readonly
          class="form-input"
          :placeholder="
            textosTraducidos['Ingresa tu correo electrónico'] ||
            'Ingresa tu correo electrónico'
          "
        />
      </div>
      <div class="form-group">
        <label for="new-password">{{
          textosTraducidos["Nueva Contraseña"] || "Nueva Contraseña"
        }}</label>
        <div class="password-input-container">
          <input
            :type="newPasswordVisible ? 'text' : 'password'"
            id="new-password"
            v-model="newPassword"
            required
            class="form-input"
            :placeholder="
              textosTraducidos['Ingresa tu nueva contraseña'] ||
              'Ingresa tu nueva contraseña'
            "
          />
          <button
            type="button"
            class="password-toggle-btn"
            @click="toggleNewPasswordVisibility"
            aria-label="Toggle password visibility"
          >
            <svg
              v-if="!newPasswordVisible"
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
      <div class="form-group">
        <label for="confirm-password">{{
          textosTraducidos["Confirmar Contraseña"] || "Confirmar Contraseña"
        }}</label>
        <div class="password-input-container">
          <input
            :type="confirmPasswordVisible ? 'text' : 'password'"
            id="confirm-password"
            v-model="confirmPassword"
            required
            class="form-input"
            :placeholder="
              textosTraducidos['Confirma tu nueva contraseña'] ||
              'Confirma tu nueva contraseña'
            "
          />
          <button
            type="button"
            class="password-toggle-btn"
            @click="toggleConfirmPasswordVisibility"
            aria-label="Toggle password visibility"
          >
            <svg
              v-if="!confirmPasswordVisible"
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
        {{ textosTraducidos["Restablecer"] || "Restablecer" }}
      </button>
      <div v-if="errorMessage" class="error-message">
        {{ errorMessage }}
      </div>
      <div v-if="successMessage" class="success-message">
        {{ successMessage }}
      </div>
    </form>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "ResetPassword",
  data() {
    return {
      email: "",
      token: "",
      newPassword: "",
      confirmPassword: "",
      errorMessage: "",
      successMessage: "",
      textosTraducidos: {},
      newPasswordVisible: false,
      confirmPasswordVisible: false,
    };
  },
  mounted() {
    const { email, token } = this.$route.query;
    if (!token) {
      this.$router.push("/login");
      return;
    }
    this.email = email;
    this.token = token;
    history.replaceState({}, document.title, window.location.pathname);
  },
  methods: {
    toggleNewPasswordVisibility() {
      this.newPasswordVisible = !this.newPasswordVisible;
    },
    toggleConfirmPasswordVisibility() {
      this.confirmPasswordVisible = !this.confirmPasswordVisible;
    },
    async handleResetPassword() {
      try {
        if (this.newPassword !== this.confirmPassword) {
          throw new Error(
            this.textosTraducidos["Las contraseñas no coinciden"] ||
              "Las contraseñas no coinciden"
          );
        }

        const response = await axios.post("/api/perfil/reset_password.php", {
          email: this.email,
          newPassword: this.newPassword,
        });

        if (response.data.status === "success") {
          this.successMessage =
            this.textosTraducidos["Contraseña restablecida con éxito"] ||
            "¡Contraseña restablecida correctamente! Redirigiendo...";

          setTimeout(() => {
            this.$router.push("/login");
          }, 3000);
        } else {
          throw new Error(
            response.data.mensaje ||
              this.textosTraducidos["Error al restablecer la contraseña"] ||
              "Error al restablecer la contraseña"
          );
        }
      } catch (error) {
        this.errorMessage = error.message;
        setTimeout(() => {
          this.errorMessage = "";
        }, 3000);
      }
    },
  },
};
</script>

<style scoped>
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

.reset-password-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #cac5f5;
  padding: 1rem;
}

.reset-password-form {
  background: #5759cd;
  padding: 2rem;
  border-radius: 20px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 500px;
  color: white;
}

h2 {
  text-align: center;
  margin-bottom: 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-input {
  width: 100%;
  padding: 0.8rem 1rem;
  border: 2px solid #ddd;
  border-radius: 12px;
  font-size: 1rem;
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
  margin-top: 1rem;
}

.error-message {
  color: #ffcccb;
  background-color: rgba(220, 53, 69, 0.2);
  padding: 0.5rem;
  border-radius: 8px;
  margin-top: 1.5rem;
  text-align: center;
}

.success-message {
  color: #d4edda;
  background-color: rgba(72, 180, 97, 0.2);
  padding: 0.5rem;
  border-radius: 8px;
  margin-top: 1.5rem;
  text-align: center;
  border: 1px solid #4caf50;
}
</style>
