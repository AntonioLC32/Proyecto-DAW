<template>
  <header class="header">
    <div class="logo">
      <router-link to="/" class="nav-link">
        <img src="../assets/logo.png" alt="Logo" />
      </router-link>
    </div>
    <h1 class="titulo">
      <router-link to="/" class="nav-link"> QuizMania </router-link>
    </h1>
    <nav class="nav">
      <ul class="nav-list">
        <li class="nav-item">
          <router-link to="/perfil" class="nav-link">
            <img
              src="https://cdn-icons-png.flaticon.com/512/6522/6522581.png"
              alt="Foto de perfil"
            />
          </router-link>
        </li>
        <li class="nav-item">
          <button class="btn-sidebar">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="size-6"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
              />
            </svg>
          </button>
        </li>
      </ul>
    </nav>
  </header>
</template>

<script>
export default {
  name: "Header",
};
</script>

<style scoped>
.header {
  font-family: "Roboto", sans-serif;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 2rem;
  background-color: #8d89f9;
  color: #fff;
  height: 60px;
}

.titulo {
  font-family: "Montserrat", sans-serif;
}

.nav-link img {
  width: 32px;
  height: 32px;
  object-fit: contain;
}

.logo img {
  height: 75px;
  width: 75px;
  object-fit: contain;
}

.nav-list {
  list-style: none;
  display: flex;
  align-items: center;
  margin: 0;
  padding: 0;
  gap: 1rem;
}

.nav-item {
  margin-left: 0;
}

.nav-link {
  color: #fff;
  text-decoration: none;
  font-size: 1rem;
  display: flex;
  align-items: center;
}

.btn-sidebar {
  background-color: transparent;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  display: flex;
  align-items: center;
}

.btn-sidebar svg {
  width: 32px;
  height: 32px;
}
</style>
