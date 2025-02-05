<template>
    <div class="preguntas">
        <section class="gestion-preguntas">

            <h1 class="titulo-preguntas">GESTIÓN DE PREGUNTAS</h1>



            <input type="text" v-model="input" placeholder="Buscar pregunta..." />
            <button @click="buscarPregunta">Buscar</button>

            <div class="filtro-categorias">
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
                <input type="checkbox" v-model="Historia" @change="filtrarCategorias" /> Historia
            </div>

            <div class="tabla">
                <Table :headers="headers" :rows="rows" />
            </div>
        </section>
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
import Table from './Table.vue'; // Ajusta la ruta según tu estructura

export default {
    name: "Preguntas",
    components: {
        Table
    },
    data() {
        return {
            input: '', // Para la búsqueda
            pregunta: '', // Para añadir pregunta
            dificultad: '',
            categoria: '',
            respuestas: '',
            correcta: '',
            // Datos de ejemplo para la tabla
            headers: [
                { key: 'id', label: 'ID' },
                { key: 'pregunta', label: 'Pregunta' },
                { key: 'dificultad', label: 'Dificultad' },
                { key: 'categoria', label: 'Categoría' },
                { key: 'acciones', label: 'Acciones' }
            ],
            rows: [
                {
                    id: 1,
                    pregunta: '¿Quién pintó la Mona Lisa?',
                    dificultad: 'Fácil',
                    categoria: 'Arte',
                    acciones: 'Editar | Eliminar'
                },
                {
                    id: 2,
                    pregunta: '¿Cuál es la capital de Francia?',
                    dificultad: 'Fácil',
                    categoria: 'Geografía',
                    acciones: 'Editar | Eliminar'
                },
                {
                    id: 3,
                    pregunta: '¿En qué año llegó el hombre a la luna?',
                    dificultad: 'Media',
                    categoria: 'Historia',
                    acciones: 'Editar | Eliminar'
                }
            ]
        };
    },
    methods: {
        buscarPregunta() {
            // Lógica para buscar preguntas
            console.log('Buscando:', this.input);
        },
        filtrarCategorias() {
            // Lógica para filtrar por categorías
            console.log('Filtrando categorías');
        },
        addPregunta() {
            // Lógica para añadir una pregunta
            const nuevaPregunta = {
                id: this.rows.length + 1,
                pregunta: this.pregunta,
                dificultad: this.dificultad,
                categoria: this.categoria,
                acciones: 'Editar | Eliminar'
            };
            this.rows.push(nuevaPregunta);
            this.pregunta = '';
            this.dificultad = '';
            this.categoria = '';
            this.respuestas = '';
            this.correcta = '';
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
    font-family: Arial, sans-serif;
}

.gestion-preguntas,
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

input[type="text"],
textarea {
    width: 100%;
    padding: 12px;
    margin-bottom: 15px;
    border: 1px solid #ddd;
    border-radius: 8px;
    background: #fff;
    color: #333;
}

button {
    padding: 8px 20px;
    border: none;
    border-radius: 6px;
    background: #6c5ce7;
    color: #fff;
    cursor: pointer;
    margin-right: 10px;
    font-size: 14px;
}

button:hover {
    background: #5b4bc4;
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