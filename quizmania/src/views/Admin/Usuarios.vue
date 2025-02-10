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
          <Table :headers="headers" :rows="rows" @info="abrirPopup" />
        </section>
      </div>

      <div class="right-column">
        <section class="edit-user">
          <img
            src="https://static-00.iconduck.com/assets.00/profile-default-icon-2048x2045-u3j7s5nj.png"
            alt="Admin"
          />
          <form action="">
            <input type="text" placeholder="Nombre de usuario" required />
            <input type="email" placeholder="Correo electrónico" required />
            <button type="submit">EDITAR</button>
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
          </div>
          <img
            :src="usuarioSeleccionado.imagen"
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
  components: {
    Table,
  },
  data() {
    return {
      totalUsuarios: 120,
      usuariosConectados: 25,
      headers: [
        { key: "id", label: "ID" },
        { key: "user", label: "USER" },
        { key: "correo", label: "CORREO" },
        { key: "acciones", label: "ACCIONES" },
      ],
      rows: [
        {
          id: 1,
          user: "Usuario 1",
          correo: "usuario1@mail.com",
          victorias: "37",
          derrotas: "12",
          puntos: "400",
          ranking: "1",
          imagen:
            "https://static-00.iconduck.com/assets.00/profile-default-icon-2048x2045-u3j7s5nj.png",
          acciones: {
            editar: false,
            eliminar: true,
            info: true,
          },
        },
        {
          id: 2,
          user: "Usuario 2",
          correo: "usuario2@mail.com",
          victorias: "25",
          derrotas: "8",
          puntos: "300",
          ranking: "2",
          imagen:
            "https://static-00.iconduck.com/assets.00/profile-default-icon-2048x2045-u3j7s5nj.png",
          acciones: {
            editar: false,
            eliminar: true,
            info: true,
          },
        },
      ],
      popupVisible: false,
      usuarioSeleccionado: {},
    };
  },
  methods: {
    abrirPopup(usuario) {
      this.usuarioSeleccionado = { ...usuario };
      this.popupVisible = true;
    },
    cerrarPopup() {
      this.popupVisible = false;
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

.titulo-form,
.titulo-usuarios {
  font-size: 24px;
  margin-bottom: 20px;
  color: #333;
  text-align: left;
  font-weight: bold;
}

.titulo-usuarios {
  color: #fff;
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
}

.popup-text {
  flex: 1;
  text-align: left;
}

.popup-img {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  object-fit: cover;
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
  right: 0;
  top: -2px;
  right: 8px;
  cursor: pointer;
  font-size: 24px;
  color: #888;
  transition: color 0.3s ease;
}

.close:hover {
  color: #6c5ce7;
}

.edit-user {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  margin-top: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  flex: 1;
  display: flex;
  flex-direction: column;
}

.edit-user img {
  width: 150px;
  height: 150px;
  object-fit: cover;
  margin: 0 auto 15px;
}

.edit-user form {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 15px;
  justify-content: space-around;
}

.edit-user input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.3s, box-shadow 0.3s;
}

.edit-user button {
  background-color: #6c5ce7;
  color: white;
  padding: 12px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  text-transform: uppercase;
  transition: background-color 0.3s;
}

.edit-user button:hover {
  background-color: #5b4bc4;
}

@media (max-width: 1300px) {
  .content-wrapper {
    flex-direction: column;
  }

  .right-column {
    margin-top: 20px;
  }
}
</style>
