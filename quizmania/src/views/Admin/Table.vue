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
  },
};
</script>

<style scoped>
.table-container {
  overflow-x: hidden;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  background: white;
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

.actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  padding: 4px 8px;
  font-size: 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.editar-btn {
  background-color: #6c5ce7;
  color: white;
}

.eliminar-btn {
  background-color: #e74c3c;
  color: white;
}

.info-btn {
  background-color: #3498db;
  color: white;
}

@media (max-width: 480px) {
  .table-header {
    padding: 0.5rem 0.75rem;
    font-size: 0.75rem;
  }

  .table-cell {
    padding: 0.5rem 0.75rem;
    font-size: 0.75rem;
  }

  .action-btn {
    padding: 2px 4px;
    font-size: 0.7rem;
  }

  /* Ajusta el ancho mínimo para dispositivos móviles */
  .dynamic-table {
    min-width: 100%;
  }
}

@media (min-width: 481px) and (max-width: 1023px) {
  .table-header {
    padding: 0.75rem 1rem;
    font-size: 0.875rem;
  }

  .table-cell {
    padding: 0.75rem 1rem;
    font-size: 0.85rem;
  }

  .action-btn {
    padding: 3px 6px;
    font-size: 0.8rem;
  }
}
</style>
