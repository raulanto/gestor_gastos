<div align="center">
  <img src="icon.png" alt="Gestor de Gastos Personales Logo" width="150" />
  <h1>Gestor de Gastos Personales</h1>
  <p><em>Tu asistente financiero completo, moderno y altamente personalizable.</em></p>
</div>

---

**Gestor de Gastos Personales** es una aplicación móvil desarrollada en **Flutter** diseñada para ofrecer un control total sobre tus finanzas personales. A través de una interfaz moderna y un diseño intuitivo, facilita el registro de transacciones, la planificación financiera y el seguimiento de metas de ahorro, todo respaldado por una base de datos local rápida (SQLite) y un sistema de temas altamente personalizable.

---

## 🚀 Características Principales (Módulos)

### 📊 1. Transacciones y Gastos (Core)
El núcleo de la aplicación, diseñado para que no pierdas de vista ni un solo centavo.
- **Registro rápido e inteligente**: Registra gastos o ingresos ingresando monto, categoría, cuenta asociada (efectivo/tarjeta/banco), fecha, notas e incluso adjuntando fotos de recibos.
- **Categorías jerárquicas**: Crea categorías padre e hijo totalmente personalizables con iconos y colores para una organización minuciosa.
- **Sistema Multi-cuenta**: Administra billeteras separadas con saldos independientes (ej. Efectivo, Cuenta de Nómina, Tarjeta de Crédito).
- **Gastos Recurrentes**: Automatiza registros periódicos como la renta, suscripciones o servicios.
- **Split de Gastos (Gastos Divididos)**: Divide un solo ticket entre varias categorías (ej. separar la cuenta del súper entre "Comida" y "Limpieza").
- **Vistas dinámicas**: Analiza tus gastos diarios, semanales o mensuales con comparativas útiles contra periodos anteriores.

### 🎯 2. Caja de Ahorros y Metas
Diseñado para incentivar y visualizar el crecimiento de tu patrimonio.
- **Metas de ahorro visuales**: Define un nombre, monto objetivo, fecha límite y asigna un icono representativo a cada meta.
- **Progreso en tiempo real**: Visualiza barras de progreso (%), saldos acumulados y proyecciones de fecha estimada de cumplimiento basándose en tu ritmo de aportación.
- **Aportaciones y Retiros controlados**: Añade fondos manualmente o realiza retiros exigiendo un motivo obligatorio para mantener la disciplina.
- **Historial dedicado**: Consulta todos los movimientos específicos de cada meta de ahorro.

### 📅 3. Planificación y Presupuestos
Evita sorpresas a fin de mes manteniendo tus gastos dentro del límite establecido.
- **Presupuestos mensuales por categoría**: Define límites específicos para "Ocio", "Comida", etc.
- **Alertas de consumo**: Recibe indicadores visuales cuando te acerques al 80% o 100% de tu límite.
- **Comparativo real vs. planificado**: Monitorea tu desempeño financiero general o por categoría.
- **Proyecciones**: Sugerencias de presupuesto basadas en tu promedio histórico de los últimos meses.

### 👤 4. Perfil y Personalización (Settings)
Haz que la aplicación sea verdaderamente tuya con opciones de personalización avanzadas.
- **Gestión de Perfil**: Cambia tu nombre de usuario y sube una foto de perfil personalizada (almacenada localmente y gestionada en la base de datos).
- **Temas Dinámicos (FlexColorScheme)**: 
  - Elige entre **14 esquemas de colores vibrantes** (como Oro, Índigo, Rosa, Tiburón, y el Azul Original).
  - Integración completa con esquemas de **Material 3**.
  - **Modo Oscuro/Claro/Sistema**: Cambia el modo de contraste de manera independiente al color principal.
- **Persistencia garantizada**: Todas tus preferencias de personalización se guardan utilizando `SharedPreferences` y se aplican instantáneamente (sin parpadeos) al iniciar la app.

---

## 🛠️ Tecnologías y Arquitectura

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Navegación**: `go_router` para un manejo de rutas declarativo y limpio.
- **Gestión de Estado**: `flutter_riverpod` (uso de `AsyncNotifier` para una hidratación segura asíncrona).
- **Base de Datos**: `sqflite` (Base de datos local con un robusto sistema de migraciones automatizadas).
- **Diseño y Temas**: `flex_color_scheme` para la generación de temas Material 3 curados y consistentes.
- **Persistencia Ligera**: `shared_preferences` para ajustes como modos de color y configuraciones de arranque.

---

## 📱 Guía para probar el proyecto

Sigue estos pasos para ejecutar la aplicación localmente en tu entorno de desarrollo.

### Prerrequisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
- Un emulador (Android/iOS) configurado y corriendo, o un dispositivo físico conectado con el modo de depuración USB activado.

### Instalación y Ejecución

1. **Clona el repositorio** o ubícate en la carpeta del proyecto a través de la terminal:
   ```bash
   cd /ruta/a/tu/gestor_gastos
   ```

2. **Obtén las dependencias del proyecto**:
   ```bash
   flutter pub get
   ```

3. **Ejecuta la aplicación**:
   ```bash
   flutter run
   ```

### 💡 Flujo de prueba recomendado para revisar las novedades:

1. **Pestaña Configuración (Settings)**:
   - Haz clic en la cabecera de tu perfil para abrir la hoja inferior (*Bottom Sheet*). Prueba cambiar tu nombre y seleccionar una **Foto de perfil** de tu galería.
   - En la sección **Apariencia**, desplaza horizontalmente la lista de temas. Selecciona tus favoritos (como Oro, Tiburón o Expreso) y cambia entre los modos Claro y Oscuro para observar cómo toda la interfaz se adapta armoniosamente.
   - Haz un **Hot Restart** (`R` en la consola) y comprueba cómo todas tus preferencias se cargan perfectamente desde el primer *frame*.
2. **Pestañas Transacciones y Préstamos**: 
   - Abre las vistas de detalles y los formularios de agregar transacciones, préstamos o presupuestos. Comprueba que las vistas se hidraten y actualicen sin ningún error, gracias a la reciente reestructuración basada en componentes y controladores de estado seguros.