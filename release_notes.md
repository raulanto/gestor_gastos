## 🎉 v0.1.0-beta — Primera versión beta

**Gestor de Gastos Personales** llega a su primera versión beta pública, disponible para **Android**. Esta es una entrega inicial pensada para pruebas y retroalimentación antes del lanzamiento estable.

### ✨ Características incluidas

**📊 Transacciones y Gastos**
- Registro de gastos e ingresos (monto, categoría, cuenta, fecha, notas y foto de recibo)
- Categorías jerárquicas personalizables (padre/hijo, iconos y colores)
- Sistema multi-cuenta (efectivo, tarjeta, banco)
- Gastos recurrentes automatizados
- División de gastos entre varias categorías
- Vistas diarias, semanales y mensuales con comparativas

**🎯 Caja de Ahorros y Metas**
- Metas de ahorro con monto objetivo, fecha límite e icono
- Progreso visual y proyección de fecha de cumplimiento
- Aportaciones y retiros con motivo obligatorio
- Historial por meta

**📅 Planificación y Presupuestos**
- Presupuestos mensuales por categoría
- Alertas al 80% / 100% del límite
- Comparativo real vs. planificado
- Proyecciones basadas en histórico

**👤 Perfil y Personalización**
- Edición de perfil (nombre y foto)
- 14 esquemas de color (Material 3, vía FlexColorScheme)
- Modo claro / oscuro / sistema
- Preferencias persistentes sin parpadeos al iniciar

### 🛠️ Stack técnico
Flutter (Dart) · go_router · flutter_riverpod (AsyncNotifier) · sqflite · flex_color_scheme · shared_preferences

### ⚠️ Notas de la beta
- Disponible solo para **Android** en esta versión
- Puede contener errores propios de una primera entrega — se agradece reportarlos vía Issues
- Próximas versiones incluirán mejoras de estabilidad y posible soporte iOS