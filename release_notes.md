## 🎉 v0.1.2-beta — Módulo de Préstamos, Rediseño UI y Respaldos

En esta nueva versión beta hemos integrado nuevas herramientas para la gestión de deudas, refinado completamente el aspecto visual de la aplicación para ofrecer una experiencia más moderna y añadido la capacidad de realizar respaldos de tu información.

### ✨ Lo Nuevo en esta Versión

**🤝 Módulo de Préstamos**
- Nuevo sistema para registrar y gestionar préstamos otorgados o recibidos.
- Seguimiento de fechas de vencimiento y estados.
- Posibilidad de registrar pagos parciales y abonos al capital.

**🎨 Rediseño Visual (Flat Design) y Experiencia**
- Renovación completa de las pantallas principales (Historial, Préstamos, Recurrentes, Ahorros y Presupuestos) eliminando el diseño de "tarjetas" (sombras y bordes duros) por una vista plana de borde a borde mucho más limpia.
- Animaciones suaves de transición (*crossfade*) al cambiar el fondo de pantalla o el tema de la app.
- Optimización de rendimiento en el scroll del historial de transacciones (memoización).

**💾 Respaldo y Restauración de Datos**
- Nueva opción en **Configuración** para exportar toda tu base de datos financiera a un archivo local `.json`.
- Permite importar y restaurar todos los registros (cuentas, transacciones, presupuestos, metas, préstamos, etc.) en cualquier momento.
- Por privacidad y seguridad, la exportación e importación **excluyen** tus credenciales y PIN de acceso.

---

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
Flutter (Dart) · go_router · flutter_riverpod (AsyncNotifier) · sqflite · flex_color_scheme · shared_preferences · file_picker

### ⚠️ Notas de la beta
- Disponible solo para **Android** en esta versión
- Puede contener errores propios de una primera entrega — se agradece reportarlos vía Issues
- Próximas versiones incluirán mejoras de estabilidad y posible soporte iOS