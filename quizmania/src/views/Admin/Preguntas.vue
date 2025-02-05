<template>
    <div class="preguntas">
        <h1 class="titulo-preguntas">GESTIÓN DE PREGUNTAS</h1>
        <section class="gestion-preguntas">

            <div class="searchBar">
                <div class="input-container">
                    <input type="text" v-model="input" class="search-input" placeholder="Buscar pregunta..." />
                    <button @click="buscarPregunta" class="buscar-btn">
                        <i class="fas fa-search"></i>
                    </button>
                </div>
            </div>


            <div class="filtro-categorias">
                <input type="checkbox" v-model="Ciencia" @change="filtrarCategorias" /> Ciencia
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
                <input type="checkbox" v-model="Geografia" @change="filtrarCategorias" /> Geografía
                <input type="checkbox" v-model="Deportes" @change="filtrarCategorias" /> Deportes
                <input type="checkbox" v-model="AyL" @change="filtrarCategorias" /> Arte y Literatura
                <input type="checkbox" v-model="Entretenimiento" @change="filtrarCategorias" /> Entretenimiento
                <input type="checkbox" v-model="Tecnologia" @change="filtrarCategorias" /> Tecnología
                <input type="checkbox" v-model="Matematicas" @change="filtrarCategorias" /> Matemáticas
                <input type="checkbox" v-model="CulturaGeneral" @change="filtrarCategorias" /> Cultura General
                <input type="checkbox" v-model="Musica" @change="filtrarCategorias" /> Música
            </div>

        </section>
        <section class="tabla">
            <Table :headers="headers" :rows="rows" />
        </section>
        <br>
        <section class="add-pregunta">
            <h1 class="titulo-preguntas">AÑADIR PREGUNTA</h1>
            <form @submit.prevent="addPregunta">
                <textarea v-model="pregunta" placeholder="Pregunta"></textarea>
                <input type="text" v-model="dificultad" placeholder="Dificultad" />
                <input type="text" v-model="categoria" placeholder="Categoría" />
                <textarea v-model="respuestas" placeholder="Respuestas"></textarea>
                <input type="text" v-model="correcta" placeholder="Respuesta correcta" />
                <button type="submit">Añadir pregunta</button>
            </form>

        </section>

    </div>

</template>

<script>
import Table from './Table.vue';

export default {
    name: "Preguntas",
    components: {
        Table
    },
    data() {
        return {
            headers: [
                { key: 'id', label: 'ID' },
                { key: 'pregunta', label: 'PREGUNTA' },
                { key: 'dificultad', label: 'DIFICULTAD' },
                { key: 'categoria', label: 'CATEGORÍA' },
                { key: 'acciones', label: 'ACCIONES' }
            ],
            rows: [
                {
                    id: 1,
                    pregunta: '¿Quién pintó la Mona Lisa?',
                    dificultad: 'Fácil',
                    categoria: 'Arte',
                    acciones: {
                        editar: true,
                        eliminar: true,
                        info: false
                    }
                },
                {
                    id: 2,
                    pregunta: '¿Cuál es la capital de Francia?',
                    dificultad: 'Fácil',
                    categoria: 'Geografía',
                    acciones: {
                        editar: true,
                        eliminar: true,
                        info: false
                    }
                },
                {
                    id: 3,
                    pregunta: '¿En qué año llegó el hombre a la luna?',
                    dificultad: 'Media',
                    categoria: 'Historia',
                    acciones: {
                        editar: true,
                        eliminar: true,
                        info: false
                    }
                }
            ]
        };
    },
    methods: {
        buscarPregunta() {

        },
        filtrarCategorias() {

        },
        addPregunta() {

        }
    }
};
</script>

<style scoped>
.preguntas {
    margin-left: 60px;
    background: linear-gradient(to bottom, #8D89F8 0%, #8682EB 54%, #535192 100%);
    min-height: 100vh;
    padding: 20px;
    color: #333;
    font-family: Roboto, sans-serif;
}

.add-pregunta {
    background: #fff;
    padding: 20px;
    border-radius: 10px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.titulo-preguntas {
    font-size: 18px;
    margin-bottom: 20px;
    color: #333;
    text-align: left;
    font-weight: bold;
}

textarea {
    width: 100%;
    padding: 6px;
    margin-bottom: 15px;
    border: 1px solid #ddd;
    border-radius: 8px;
    background: #fff;
}

.searchBar {
    display: flex;
    align-items: center;
    justify-content: center;
}

.input-container {
    position: relative;
    width: 100%;
}

.search-input {
    width: 100%;
    padding: 10px 40px 10px 12px;
    border: 1px solid #ddd;
    border-radius: 20px;
    background: #fff;
    font-size: 14px;
    transition: all 0.3s ease-in-out;
    outline: none;
}

.search-input:focus {
    border-color: #6c5ce7;
    box-shadow: 0 0 5px rgba(108, 92, 231, 0.5);
}

.buscar-btn {
    position: absolute;
    right: 10px;
    top: 50%;
    transform: translateY(-50%);
    border: none;
    background: transparent;
    color: #6c5ce7;
    cursor: pointer;
    font-size: 16px;
}

.buscar-btn:hover {
    color: #5b4bc4;
}

.filtro-categorias {
    margin: 20px 0;
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.filtro-categorias input[type="checkbox"] {
    margin-right: 5px;
}

.add-pregunta form {
    display: flex;
    flex-direction: column;
}

.add-pregunta textarea {
    height: 120px;
    resize: vertical;
}

.add-pregunta button[type="submit"] {
    background: #6c5ce7;
    padding: 12px 24px;
    align-self: flex-end;
    font-size: 14px;
}

.add-pregunta button[type="submit"]:hover {
    background: #5b4bc4;
}
</style>