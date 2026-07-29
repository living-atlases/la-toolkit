#!/bin/bash

# Script para diagnosticar corrupción de datos en projetos la_toolkit

echo "🔍 Iniciando diagnóstico de integridad de datos..."
echo ""

# Ejecutar tests de integridad
echo "📋 Ejecutando tests de integridad de datos..."
cd "$(dirname "$0")"

flutter test test/src/data_integrity_test.dart -v

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Todos los tests de integridad pasaron!"
    echo ""
    echo "📖 Información sobre cómo usar las nuevas funciones:"
    echo ""
    echo "1. VALIDAR un proyecto por corrupción:"
    echo "   final errors = project.validateDataIntegrity();"
    echo "   if (errors.isNotEmpty) print('Problemas: \$errors');"
    echo ""
    echo "2. PREVENCIÓN automática:"
    echo "   - fromJson() previene duplicados automáticamente via _rebuildEmptyClusterServices()"
    echo "   - assignByType() enforza exclusividad entre serverServices y clusterServices"
    echo "   - No hay auto-fix necesario: la inconsistencia se previene desde el origen"
    echo ""
    echo "3. USAR en fromJson() para cargar desde servidor:"
    echo "   final project = LAProject.fromJson(json);"
    echo "   // Ya se valida automáticamente, y se previene duplicados"
    echo ""
    echo "4. PREVENCIÓN AUTOMÁTICA en assignByType():"
    echo "   p.assign(vm1, [collectory]); // Va a serverServices"
    echo "   p.assignByType(clusterId, dockerCompose, [alaHub]);"
    echo "   // Si alaHub estaba en VM, se remueve automáticamente"
    echo ""
    echo "Ver DATA_INTEGRITY_FIXES.md para más detalles"
else
    echo ""
    echo "❌ Algunos tests fallaron. Revisar salida arriba."
    exit 1
fi
