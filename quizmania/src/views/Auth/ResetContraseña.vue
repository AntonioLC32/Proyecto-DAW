<template>
  <div class="reset-password-container">
    <form class="reset-password-form" @submit.prevent="handleResetPassword">
      <h2>{{ textosTraducidos["Restablecer Contraseña"] || "Restablecer Contraseña" }}</h2>
      <div class="form-group">
        <label for="email">{{ textosTraducidos["Correo Electrónico"] || "Correo Electrónico" }}</label>
        <input
          type="email"
          id="email"
          v-model="email"
          required
          class="form-input"
          :placeholder="textosTraducidos['Ingresa tu correo electrónico'] || 'Ingresa tu correo electrónico'"
        />
      </div>
      <div class="form-group">
        <label for="new-password">{{ textosTraducidos["Nueva Contraseña"] || "Nueva Contraseña" }}</label>
        <input
          type="text"
          id="new-password"
          v-model="newPassword"
          required
          class="form-input"
          :placeholder="textosTraducidos['Ingresa tu nueva contraseña'] || 'Ingresa tu nueva contraseña'"
        />
      </div>
      <div class="form-group">
        <label for="confirm-password">{{ textosTraducidos["Confirmar Contraseña"] || "Confirmar Contraseña" }}</label>
        <input
          type="text"
          id="confirm-password"
          v-model="confirmPassword"
          required
          class="form-input"
          :placeholder="textosTraducidos['Confirma tu nueva contraseña'] || 'Confirma tu nueva contraseña'"
        />
      </div>
      <button type="submit" class="submit-btn">
        {{ textosTraducidos["Restablecer"] || "Restablecer" }}
      </button>
      <div v-if="errorMessage" class="error-message">
        {{ errorMessage }}
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
      email: this.$route.query.email || "",
      newPassword: "",
      confirmPassword: "",
      errorMessage: "",
      textosTraducidos: {},
    };
  },
  methods: {
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
          this.$router.push("/login");
        } else {
          throw new Error(
            response.data.mensaje ||
              this.textosTraducidos["Error al restablecer la contraseña"] ||
              "Error al restablecer la contraseña"
          );
        }
      } catch (error) {
        this.errorMessage =
          error.message ||
          this.textosTraducidos["Error al restablecer la contraseña"] ||
          "Error al restablecer la contraseña";
        setTimeout(() => {
          this.errorMessage = "";
        }, 3000);
      }
    },
  },
};
</script>

<style scoped>
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
</style>
