# HeMa Costos 🧁

<p align="center">
  <img src="assets/images/hemacostos_logo.png" alt="HeMa Costos Logo" width="140" style="border-radius: 20px;" />
</p>

<p align="center">
  <strong>Solución integral móvil y cloud para la gestión de costos, recetas y presupuestos profesionales gastronómicos.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" alt="Node.js" />
  <img src="https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white" alt="TypeScript" />
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
</p>

---

## 📌 Visión General

**HeMa Costos** es una solución Full-Stack diseñada para resolver uno de los mayores desafíos de emprendimientos gastronómicos y pastelerías: **la determinación precisa de costos, la fijación de precios con rentabilidad asegurada y la emisión ágil de cotizaciones formales**.

El ecosistema combina una **aplicación móvil Flutter (Local-First)** optimizada para trabajar con fluidez en el taller/cocina y un **backend en Node.js/TypeScript** con PostgreSQL en la nube para autenticación *passwordless*, control de dispositivos y gestión de licencias.

---

## 🚀 Características Principales

### 📊 Dashboard & Métricas de Negocio
- **KPIs en tiempo real:** Visualización instantánea del monto total presupuestado, cantidad de recetas activas e insumos cargados.
- **Alertas de costos desactualizados:** Detección automática de materias primas cuyos precios no han sido actualizados en más de 45 días para prevenir pérdidas por inflación.
- **Onboarding progresivo:** Flujo guiado por pasos para usuarios nuevos (*Insumos → Recetas → Costos → Presupuesto*).

### 🧁 Gestión de Insumos y Recetas
- Catálogo de insumos con precio unitario, unidad de medida (g, kg, ml, l, u) y fecha de última actualización.
- Constructor de recetas modular con cálculo dinámico de costo proporcional por ingrediente.
- Rendimiento por porciones o unidades y costo unitario resultante en tiempo real.

### 💰 Motor de Costos & Márgenes
- Agrupación de múltiples recetas en un cálculo consolidado.
- Adición de costos variables, packaging y costos extras de producción.
- Aplicación de margen de ganancia configurable con cálculo transparente de ganancia neta y precio sugerido.
- Persistencia y consulta de historial de cálculos para trazabilidad.

### 🧾 Generador de Presupuestos en PDF
- Emisión instantánea de cotizaciones comerciales en formato PDF con diseño visual corporativo.
- Inclusión de datos del cliente, datos de contacto del negocio, desglose de ítems, totales y condiciones de contratación (anticipo, vigencia).
- Integración nativa para previsualización, impresión y exportación directa a WhatsApp o correo electrónico.

### 🔐 Seguridad y Gestión de Licencias (Cloud)
- **Autenticación Passwordless:** Envío de códigos OTP de 6 dígitos vía correo electrónico transaccional con control de intentos y mitigación de fuerza bruta.
- **Hardware Binding:** Vinculación de sesión al identificador único del hardware (`device_id`) para prevenir uso concurrente no autorizado de licencias.
- **Arquitectura Híbrida / Offline-Resilient:** Los datos operativos se guardan localmente en SQLite, permitiendo trabajar sin conexión una vez validada la sesión.

---

## 🏗 Arquitectura del Sistema

El proyecto sigue una arquitectura desacoplada y orientada a capas:

```mermaid
graph TD
    subgraph Mobile ["App Móvil (Flutter / Dart)"]
        UI["UI Layer (Screens & Custom Widgets)"]
        Logic["Business Logic & Services"]
        DAO["Data Access Objects (DAOs)"]
        SQLite[("Local DB (SQLite / sqflite)")]
        HTTP["HTTP Client (Auth & License Sync)"]
        
        UI --> Logic
        Logic --> DAO
        DAO --> SQLite
        Logic --> HTTP
    end

    subgraph Cloud ["Cloud Backend (Node.js / Render)"]
        API["REST API (Express / TypeScript)"]
        AuthModule["OTP & License Validator"]
        MailService["Resend Mail Service"]
        Postgres[("Cloud DB (PostgreSQL)")]
        
        API --> AuthModule
        AuthModule --> MailService
        AuthModule --> Postgres
    end

    HTTP <-->|HTTPS / JSON| API
```

---

## 🛠 Stack Tecnológico

### Frontend Móvil (Flutter)
- **Framework:** Flutter SDK (Dart 3.x)
- **Almacenamiento Local:** `sqflite` (SQLite) + `path_provider`
- **Generación de Documentos:** `pdf` + `printing` + `open_file`
- **Gestión de Sesión & Hardware:** `shared_preferences`, `device_info_plus`, `uuid`
- **Diseño & Tipografía:** `google_fonts` (Poppins & DM Sans), Material 3

### Backend & Cloud Services
- **Runtime & Lenguaje:** Node.js, TypeScript
- **Framework Web:** Express
- **Base de Datos Cloud:** PostgreSQL (`pg`)
- **Servicio de Emails:** Resend API
- **Infraestructura:** Render Cloud Platform

---

## 📂 Estructura del Proyecto

```text
presupuestoapp/
├── assets/                     # Recursos visuales (logos, tipografías)
├── backend/                    # Microservicio de licencias y autenticación
│   ├── src/
│   │   ├── server.ts           # Endpoints REST y middleware
│   │   └── utils/              # Generación de códigos, hashing y correo
│   ├── schema.sql              # Esquema DDL de PostgreSQL (licenses, users, auth_codes)
│   ├── package.json
│   └── tsconfig.json
├── lib/                        # Código fuente cliente Flutter
│   ├── data/
│   │   ├── database/           # SQLite singleton y DAOs (Insumos, Recetas, etc.)
│   │   └── models/             # Modelos inmutables de dominio
│   ├── logic/                  # Lógica de cálculo y reglas de negocio
│   ├── pdf/                    # Motor de maquetación de presupuestos en PDF
│   ├── services/               # Integración HTTP, Session y Device ID
│   ├── ui/
│   │   ├── components/         # Widgets modulares y elementos reutilizables
│   │   ├── screens/            # Vistas (Dashboard, Login, Insumos, Recetas, Presupuestos)
│   │   └── theme/              # Paleta cromática y estilos tipográficos
│   ├── utils/                  # Helpers transversales
│   └── main.dart               # Entrypoint de la aplicación y ruteo
└── pubspec.yaml                # Dependencias y configuración de assets
```

---

## ⚡ Instalación y Puesta en Marcha

### Prerrequisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión 3.10 o superior)
- [Node.js](https://nodejs.org/) (versión 18 o superior)
- [PostgreSQL](https://www.postgresql.org/) o instancia en la nube (ej. Neon / Supabase / Render)

---

### 1. Backend (Servicio de Autenticación)

1. Ingresar a la carpeta de backend e instalar dependencias:
   ```bash
   cd backend
   npm install
   ```

2. Configurar variables de entorno creando un archivo `.env`:
   ```env
   PORT=3000
   DATABASE_URL=postgres://usuario:password@host:5432/hema_auth
   RESEND_API_KEY=tu_api_key_de_resend
   EMAIL_FROM=no-reply@tudominio.com
   ```

3. Inicializar el esquema de la base de datos:
   ```bash
   psql -d hema_auth -f schema.sql
   ```

4. Ejecutar el servidor en modo desarrollo:
   ```bash
   npm run dev
   ```

---

### 2. Aplicación Móvil (Flutter)

1. En la raíz del proyecto, instalar los paquetes de Flutter:
   ```bash
   flutter pub get
   ```

2. Ejecutar la aplicación en emulador o dispositivo físico:
   ```bash
   flutter run
   ```

> [!NOTE]
> Para pruebas locales en emulador Android, la URL base del servicio apunta por defecto a `http://10.0.2.2:3000` o al servidor de staging en la nube configurado en `lib/services/auth_service.dart`.

---

## 📈 Roadmap & Próximas Mejoras

- [ ] Sincronización bidireccional de recetas e insumos en la nube.
- [ ] Módulo de exportación e importación masiva de insumos vía Excel / CSV.
- [ ] Panel web administrativo para gestión centralizada de licencias de usuarios.
- [ ] Soporte para pasarela de pagos integrada para suscripciones recurrentes.

---

<p align="center">
  Desarrollado con dedicación técnica y enfoque en usabilidad para potenciar el crecimiento de emprendimientos gastronómicos.
</p>
