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
            <tbody>
                <tr v-for="(row, index) in rows" :key="index" class="table-row">
                    <td v-for="header in headers" :key="header.key" class="table-cell">
                        {{ row[header.key] }}
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
            validator: (value) => value.every(h => 'key' in h && 'label' in h)
        },
        rows: {
            type: Array,
            required: true
        }
    }
}
</script>

<style scoped>
.table-container {
    overflow-x: auto;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    background: white;
}

.dynamic-table {
    width: 100%;
    border-collapse: collapse;
    background: white;
    animation: fadeIn 0.4s ease;
}

.table-header {
    padding: 1rem 1.5rem;
    text-align: left;
    font-weight: 600;
    color: #2d3748;
    background-color: #f8fafc;
    border-bottom: 2px solid #e2e8f0;
    transition: background-color 0.3s ease;
}

.table-row {
    transition: all 0.3s ease;
    border-bottom: 1px solid #edf2f7;
}

.table-row:hover {
    background-color: #f8fafc;
}

.table-cell {
    padding: 1rem 1.5rem;
    color: #4a5568;
    font-size: 0.95rem;
    vertical-align: middle;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@media (max-width: 768px) {
    .table-header {
        padding: 0.75rem 1rem;
        font-size: 0.875rem;
    }

    .table-cell {
        padding: 0.75rem 1rem;
        font-size: 0.85rem;
    }
}
</style>