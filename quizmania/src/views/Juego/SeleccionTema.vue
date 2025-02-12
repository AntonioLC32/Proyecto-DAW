<template>
    <section>
        <div class="container">
            <div class="roulette">
                <div class="roller" :style="{ transform: `translateY(${position}px)` }">
                    <div v-for="(theme, index) in shuffledThemes" :key="index" class="theme">
                        {{ theme }}
                    </div>
                </div>
            </div>
            <button @click="spin">Girar</button>
        </div>
    </section>
</template>

<script setup>
import { ref } from "vue";

import arteImage from "../../assets/arte.png";
import cienciasImage from "../../assets/ciencias.png";
import culturaImage from "../../assets/cultura.png";
import entreImage from "../../assets/entre.png";
import geoImage from "../../assets/geografia.png";
import historiaImage from "../../assets/historia.png";
import matesImage from "../../assets/mates.png";
import tecnoImage from "../../assets/tecno.png";
import musicaImage from "../../assets/musica.png";
import deportesImage from "../../assets/deportes.png";

const themes = ["Historia", "Ciencia", "Deportes", "Música", "Cine", "Arte"];
const shuffledThemes = ref([...themes, ...themes, ...themes]); // Para efecto infinito
const position = ref(0);
const spinning = ref(false);

const spin = () => {
  if (spinning.value) return;

  spinning.value = true;
  let totalScroll = -(Math.random() * 2000 + 1000); // Scroll aleatorio
  position.value = totalScroll;

  setTimeout(() => {
    const finalIndex = Math.floor(Math.abs(totalScroll) / 50) % themes.length;
    position.value = -(finalIndex * 50); // Ajuste final
    spinning.value = false;
  }, 3000); // Duración total de la animación
};
</script>

<style scoped>
.container {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 50px;
}

.roulette {
  width: 200px;
  height: 50px;
  overflow: hidden;
  border: 2px solid black;
  position: relative;
}

.roller {
  display: flex;
  flex-direction: column;
  transition: transform 3s cubic-bezier(0.25, 1, 0.5, 1);
}

.theme {
  width: 100%;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  border-bottom: 1px solid #ccc;
}

* {
    box-sizing: border-box;
    font-family: "Montserrat", sans-serif;
}

.division {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    min-height: 100vh;
    position: relative;
    margin-top: 20px;
}

.left {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 60%;
}

.right {
    width: 20%;
    position: absolute;
    right: 10%;
    top: 15%;
    /* Ajusta la posición vertical para subir los corazones */
    display: flex;
    flex-direction: column;
    align-items: center;
    /* Centra los corazones con respecto al contenedor */
    gap: 10px;
}

.right .encase {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    /* Centra verticalmente los corazones */
}

.encase {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    width: 100%;
}

section {
    background-color: #e1e0ff;
    min-height: 100vh;
    overflow-y: hidden;
}

.pregunta {
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #5759cd;
    border-radius: 15px;
    width: 80%;
    padding: 150px;
    margin-bottom: 20px;
    text-align: center;
    filter: drop-shadow(0 10px 0px #5759cd35);
}

.pregunta p {
    font-size: 24px;
    font-weight: bold;
    color: white;
    margin: 0;
}

.respuesta {
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #5759cd;
    border-radius: 10px;
    width: 80%;
    padding: 15px;
    margin-bottom: 20px;
    filter: drop-shadow(0 10px 0px #5759cd35);
    border: 0px;
    transition: background-color 0.3s ease-in-out;
}

.respuesta:hover {
    background-color: #8e8fcd;
}

.respuesta p {
    font-size: 20px;
    font-weight: bold;
    color: white;
    margin: 0;
}

/* Colores de respuestas */
.correcta {
    background-color: #26fb09 !important;
    filter: drop-shadow(0 10px 0px #26fb0935);
}

.incorrecta {
    background-color: #ff0707 !important;
    filter: drop-shadow(0 10px 0px #ff070735);
}

/* Contenedor de progreso y botones */
.misc {
    display: flex;
    flex-direction: row;
    gap: 30px;
    max-height: 70px;
    margin-top: 20px;
    align-items: center;
}

.misc img,
.right img {
    transition: all 0.3s ease-in-out;
}

.misc img:hover,
.right img:hover {
    transform: scale(1.1);
}

/* Estilo del progreso */
.progreso {
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    border-radius: 50%;
    width: 70px;
    height: 70px;
    background-color: #5759cd;
    border: 5px solid #4a4da5;
    font-size: 24px;
}

/* --- MEDIA QUERIES --- */

/* Pantallas medianas (hasta 1024px) */
@media (max-width: 1024px) {
    .pregunta {
        width: 100%;
        padding: 120px;
    }

    .right {
        padding-left: 10%;
    }


}

/* Tablets (hasta 768px) */
@media (max-width: 768px) {
    .division {
        flex-direction: column;
        align-items: center;
        text-align: center;
    }

    .left,
    .right {
        width: 100%;
    }

    .right {
        flex-direction: row !important;
        justify-content: center;
        gap: 15px;
        margin-top: 20px;
    }

    .right .encase {
        display: flex;
        flex-direction: row;
        justify-content: center;
        width: 100%;
    }

    .pregunta {
        width: 95%;
        padding: 40px;
        font-size: 22px;
        margin-top: 180px !important;

    }

    .respuesta {
        width: 95%;
        font-size: 18px;
        padding: 12px;
    }

    .progreso {
        width: 60px;
        height: 60px;
        font-size: 20px;
    }
}

/* Móviles (hasta 480px) */
@media (max-width: 480px) {
    .pregunta {
        font-size: 16px;
        padding: 60px;
        margin-top: 200px !important;
    }

    .respuesta {
        font-size: 14px;
        padding: 10px;

    }

    .right {
        display: flex;
        flex-direction: row !important;
        justify-content: center;
        gap: 15px;
        margin-top: 20px;

    }

    .right img {
        width: 50px;
        height: 50px;
    }

    .right .encase {
        display: flex;
        flex-direction: row;
        justify-content: center;
        width: 100%;
    }

    .misc {
        gap: 15px;
    }

    .progreso {
        width: 50px;
        height: 50px;
        font-size: 16px;
    }

    .right img {
        width: 60px;
        height: 60px;
    }
}
</style>