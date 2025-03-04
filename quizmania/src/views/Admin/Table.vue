<template>
  <div class="table-container">
    <table class="dynamic-table">
      <thead>
        <tr>
          <th v-for="header in headers" :key="header.key" class="table-header">
            {{ header.label }}
          </th>
        </tr>
      </thead>
    </table>
    <div class="tbody-wrapper" v-if="rows.length > 15">
      <table class="dynamic-table">
        <tbody>
          <tr v-for="(row, index) in rows" :key="index" class="table-row">
            <td
              v-for="(header, colIndex) in headers"
              :key="header.key"
              class="table-cell"
            >
              <template v-if="header.key === 'acciones'">
                <div class="actions">
                  <button
                    v-if="row.acciones?.editar"
                    class="action-btn editar-btn"
                    @click="editar(row)"
                  >
                    Editar
                  </button>
                  <button
                    v-if="row.acciones?.eliminar"
                    class="action-btn eliminar-btn"
                    @click="eliminar(row)"
                  >
                    Eliminar
                  </button>
                  <button
                    v-if="row.acciones?.info"
                    class="action-btn info-btn"
                    @click="info(row)"
                  >
                    Info
                  </button>
                </div>
              </template>
              <template v-else-if="header.key === 'imagen'">
                <img
                  :src="getImageUrl(row[header.key])"
                  :alt="`Imagen de ${row.nombre}`"
                  class="table-image"
                />
              </template>
              <template v-else>
                {{ row[header.key] }}
              </template>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <table class="dynamic-table" v-else>
      <tbody>
        <tr v-for="(row, index) in rows" :key="index" class="table-row">
          <td
            v-for="(header, colIndex) in headers"
            :key="header.key"
            class="table-cell"
          >
            <template v-if="header.key === 'acciones'">
              <div class="actions">
                <button
                  v-if="row.acciones?.editar"
                  class="action-btn editar-btn"
                  @click="editar(row)"
                >
                  Editar
                </button>
                <button
                  v-if="row.acciones?.eliminar"
                  class="action-btn eliminar-btn"
                  @click="eliminar(row)"
                >
                  Eliminar
                </button>
                <button
                  v-if="row.acciones?.info"
                  class="action-btn info-btn"
                  @click="info(row)"
                >
                  Info
                </button>
              </div>
            </template>
            <template v-else-if="header.key === 'imagen'">
              <img
                :src="getImageUrl(row[header.key])"
                :alt="`Imagen de ${row.nombre}`"
                class="table-image"
              />
            </template>
            <template v-else>
              {{ row[header.key] }}
            </template>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: "DynamicTable",
  props: {
    headers: {
      type: Array,
      required: true,
      validator: (value) => value.every((h) => "key" in h && "label" in h),
    },
    rows: {
      type: Array,
      required: true,
    },
  },
  methods: {
    editar(row) {
      this.$emit("editar", row);
    },
    eliminar(row) {
      this.$emit("eliminar", row);
    },
    info(row) {
      this.$emit("info", row);
    },
    getImageUrl(path) {
      return new URL(`../../assets/${path}`, import.meta.url).href;
    },
  },
};
</script>

<style scoped>
.table-container {
  overflow-x: hidden;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  background: white;
  max-height: 69vh;
}

.dynamic-table {
  min-width: 1024px;
  width: 100%;
  border-collapse: collapse;
  background: white;
  table-layout: fixed;
}

.table-header {
  padding: 1rem 1.5rem;
  text-align: left;
  font-weight: 600;
  color: white;
  background-color: rgba(74, 77, 165, 0.87);
  transition: background-color 0.3s ease;
}

.table-header:first-child {
  width: 80px;
}

.tbody-wrapper {
  max-height: 600px;
  overflow-y: auto;
  margin-top: -1px;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.tbody-wrapper::-webkit-scrollbar {
  display: none;
}

.table-row {
  transition: background-color 0.3s ease;
  border-bottom: 1px solid #edf2f7;
}

.table-row:hover {
  background-color: #cac5f5;
}

.table-cell {
  padding: 1rem 1.5rem;
  font-size: 0.95rem;
  vertical-align: middle;
}

.table-cell:first-child {
  width: 80px;
}

.table-image {
  width: 40px;
  height: 40px;
  object-fit: cover;
  border-radius: 4px;
}
.actions {
  display: flex;
  gap: 10px;
  flex-wrap: nowrap;
}

.action-btn {
  padding: 8px 16px;
  min-width: 80px;
  font-size: 0.9rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 500;
  letter-spacing: 0.5px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.editar-btn {
  background-color: #6c5ce7;
  color: white;
}

.editar-btn:hover {
  background-color: #5b4bc4;
  box-shadow: 0 3px 6px rgba(108, 92, 231, 0.2);
}

.eliminar-btn {
  background-color: #e74c3c;
  color: white;
}

.eliminar-btn:hover {
  background-color: #c44133;
  box-shadow: 0 3px 6px rgba(231, 76, 60, 0.2);
}

.info-btn {
  background-color: #3498db;
  color: white;
}

.info-btn:hover {
  background-color: #2c81ba;
  box-shadow: 0 3px 6px rgba(52, 152, 219, 0.2);
}

@media (max-width: 480px) {
  .action-btn {
    min-width: 70px;
    padding: 6px 12px;
    font-size: 0.75rem;
  }
}

@media (min-width: 481px) and (max-width: 1023px) {
  .action-btn {
    min-width: 75px;
    padding: 7px 14px;
    font-size: 0.8rem;
  }
}
</style>
