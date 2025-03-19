<template>
    <div class="temas">
        <div class="temas_completados">
            <img :src="getImageUrl('users/default/default.pnh')" alt="Perfil Image" style="border-radius: 50%" />
            <img v-for="theme in firstThemes" :key="theme.name" :src="theme.image" alt="theme image" />
        </div>
        <div class="temas_completados">
            <img v-for="theme in secondThemes" :key="theme.name" :src="theme.image" alt="theme image" />
        </div>
    </div>
</template>

<script>
export default {
    name: "TemasJugador",
    props: {
        themes: {
            type: Array,
            required: true,
        },
    },
    computed: {
        firstThemes() {
            return this.themes.slice(0, 4);
        },
        secondThemes() {
            return this.themes.slice(4);
        },
    },
    methods: {
        getImageUrl(path) {
            return `@/assets/${path}`;
        },
    },
};
</script>

<style scoped>
.temas {
    padding: 20px;
    background-color: #5759cd;
    border-radius: 8px;
    margin-bottom: 50px;
}

.temas_completados {
    display: flex;
    align-items: center;
    justify-content: space-evenly;
    margin-bottom: 1rem;
}

.temas_completados img {
    height: 80px;
    width: 80px;
}
</style>