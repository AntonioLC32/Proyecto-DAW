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
            
            <table class="preguntas-table">
                <tr>
                    <th>Id</th>
                    <th>Pregunta</th>
                    <th>Dificultad</th>
                <th>Categoría</th>
                <th>Acciones</th>
            </tr>
            <tr v-for="pregunta in preguntas" :key="pregunta.id">
                <td>{{pregunta.id}}</td>
                <td>{{pregunta.pregunta}}</td>
                <td>{{pregunta.dificultad}}</td>
                <td>{{pregunta.categoria}}</td>
                <td>
                    <router-link :to="{name: 'EditarPregunta', params: {id: pregunta.id}}">Editar</router-link>
                    <button @click="eliminarPregunta(pregunta.id)">Eliminar</button>
                </td>
            </tr>
        </table>
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
export default {
    name: "Preguntas",
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

.gestion-preguntas, .add-pregunta {
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

input[type="text"], textarea {
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

.preguntas-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0 8px;
    margin-bottom: 20px;
}

.preguntas-table th {
    padding: 12px;
    text-align: left;
    color: #666;
    font-weight: normal;
    border-bottom: 2px solid #eee;
}

.preguntas-table td {
    padding: 12px;
    background: white;
}

.preguntas-table tr td:first-child {
    border-top-left-radius: 8px;
    border-bottom-left-radius: 8px;
}

.preguntas-table tr td:last-child {
    border-top-right-radius: 8px;
    border-bottom-right-radius: 8px;
}

.preguntas-table button {
    background: #ff4757;
    padding: 6px 12px;
    font-size: 12px;
}

.preguntas-table button:hover {
    background: #ff3748;
}

.preguntas-table a {
    color: #6c5ce7;
    text-decoration: none;
    margin-right: 10px;
}

.preguntas-table a:hover {
    text-decoration: underline;
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