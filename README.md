# 🚀 Sistema de Captación y Outreach — AndCode

<div align="center">

![n8n](https://img.shields.io/badge/n8n-v2.14.2-orange?style=for-the-badge&logo=n8n)
![SerpApi](https://img.shields.io/badge/SerpApi-Google_Maps-blue?style=for-the-badge)
![HubSpot](https://img.shields.io/badge/HubSpot-CRM_Free-orange?style=for-the-badge&logo=hubspot)
![Estado](https://img.shields.io/badge/Estado-✅_Funcional-brightgreen?style=for-the-badge)

**Pipeline completo de captación de leads para AndCode:**  
Encuentra negocios locales sin web → los enriquece → les envía un email personalizado → los registra en HubSpot CRM.

</div>

---

## 🗺️ Los dos workflows del sistema

Este repositorio contiene **dos workflows complementarios** que forman un pipeline end-to-end:

| # | Workflow | Archivo | Qué hace |
|---|----------|---------|----------|
| 1️⃣ | **Captación de Leads** | `workflow-leads-MANUAL-public.json` | Busca negocios sin web en Google Maps y los guarda en CSV |
| 2️⃣ | **Outreach Multi-Servicio** | `workflow-andcode-outreach.json` | Lee leads de Google Sheets, envía emails personalizados por servicio y registra en HubSpot |

```
[Workflow 1] Buscar negocios sin web → leads.csv
                    ↓ (exporta manualmente a Google Sheets)
[Workflow 2] Google Sheets → Email personalizado → HubSpot CRM
```

---

## 📋 Índice

- [Workflow 1: Captación de Leads](#workflow-1-captación-de-leads)
- [Workflow 2: Outreach Multi-Servicio](#workflow-2-outreach-multi-servicio)
- [Requisitos previos](#-requisitos-previos)
- [Instalación paso a paso](#-instalación-paso-a-paso)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Solución de problemas](#-solución-de-problemas)
- [Contribuir](#-contribuir)

---

## Workflow 1: Captación de Leads

> 📄 Archivo: `workflow-leads-MANUAL-public.json`

## 🎯 ¿Qué hace este sistema?

```
📝 Introduces ciudad + tipo de negocio
        ↓
🔍 Busca en Google Maps (vía SerpApi)
        ↓
📊 Extrae datos de todos los negocios
        ↓
🔎 Filtra solo los que NO tienen web
        ↓
💾 Guarda los leads en un CSV local
```

**Ejemplo:** Buscas `"peluquería"` en `"Sanlúcar de Barrameda"` y obtienes una lista de peluquerías sin página web con su teléfono, dirección, valoración, etc.

---

## 📦 Requisitos previos

| Requisito | Versión mínima | Cómo verificar |
|-----------|---------------|----------------|
| **Node.js** | v18+ | `node --version` |
| **npm** | v8+ | `npm --version` |
| **n8n** | v2.0+ | `n8n --version` |
| **SerpApi** | Cuenta gratuita | [serpapi.com](https://serpapi.com) |

> 💡 **No necesitas Docker**, Google Cloud, ni tarjeta de crédito.

---

## 🛠️ Instalación paso a paso

### 1. Instalar Node.js (si no lo tienes)

```bash
# macOS con Homebrew
brew install node

# Windows — descarga de https://nodejs.org
# Linux
sudo apt install nodejs npm
```

### 2. Instalar n8n

```bash
npm install n8n -g
```

### 3. Obtener API Key de SerpApi (GRATIS)

1. Ve a [serpapi.com](https://serpapi.com) y crea una cuenta
2. **No requiere tarjeta de crédito**
3. El plan gratuito incluye **250 búsquedas/mes**
4. Copia tu API Key desde el [dashboard](https://serpapi.com/manage-api-key)

### 4. Clonar este repositorio

```bash
git clone https://github.com/ALJE-Solutions/automatizacion-leads.git
cd automatizacion-leads
```

---

## ⚙️ Configuración del workflow

### Paso 1: Iniciar n8n

```bash
# ⚠️ IMPORTANTE: Usar siempre este comando (permite guardar archivos locales)
N8N_RESTRICT_FILE_ACCESS_TO="" n8n start
```

Abre tu navegador en: **http://localhost:5678**

### Paso 2: Importar el workflow

1. En n8n, haz clic en **"..."** (menú) → **"Import from File"**
2. Selecciona el archivo **`workflow-leads-MANUAL.json`**
3. Verás el workflow completo con todos los nodos conectados

### Paso 3: Configurar tu API Key

1. Haz doble clic en el nodo **🔍 SerpApi**
2. En los Query Parameters, busca `api_key`
3. Reemplaza el valor por **tu propia API Key** de SerpApi
4. Guarda los cambios

### Paso 4: Configurar la ruta del CSV

1. Haz doble clic en el nodo **💾 Guardar CSV**
2. Cambia la ruta del archivo a la ubicación donde quieras guardar el CSV en **tu máquina**
3. Ejemplo: `/Users/tu-usuario/Documents/leads.csv`

---

## ▶️ Cómo usarlo

### Ejecución manual (formulario web)

1. **Activa** el workflow (botón rojo/verde arriba a la derecha)
2. n8n te mostrará una **URL del formulario** (algo como `http://localhost:5678/form/leads-buscar`)
3. Abre esa URL en tu navegador
4. Rellena los campos:
   - **Ciudad:** La ciudad donde buscar (ej: `Madrid`, `Sevilla`, `Barcelona`)
   - **Nicho:** El tipo de negocio (ej: `peluquería`, `dentista`, `fontanero`)
5. Pulsa **"Submit"**
6. Espera unos segundos...
7. ✅ Verás un mensaje de confirmación
8. Abre el archivo **`leads.csv`** para ver los resultados

### Ejecución de prueba (sin formulario)

1. Haz clic en **"Test workflow"** en n8n
2. Se abrirá el formulario automáticamente
3. Rellena y envía

---

## 📁 Estructura del proyecto

```
automatizacion-leads/
│
├── 📄 README.md                          ← Este manual
│
├── ── WORKFLOW 1: Captación ──
├── 🔧 workflow-leads-MANUAL-public.json  ← Busca negocios sin web en Google Maps
│
├── ── WORKFLOW 2: Outreach ──
├── � workflow-andcode-outreach.json     ← Envía emails y registra en HubSpot
├── 📖 guia-andcode-outreach.md           ← Guía paso a paso del Workflow 2
├── 📊 plantilla-leads-sheets.csv         ← Plantilla para el Google Sheets
│
└── 📜 instrucciones.xml                  ← Especificaciones originales
```

---

## 📊 Datos que se obtienen

Cada lead en el CSV incluye los siguientes campos:

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| `nombre` | Nombre del negocio | Peluquería Algorez |
| `direccion` | Dirección completa | C. Puerto, 1, 11540 Sanlúcar... |
| `telefono` | Teléfono de contacto | +34 956 92 78 54 |
| `rating` | Valoración en Google | 4.6 |
| `num_reviews` | Número de reseñas | 183 |
| `website` | Web (vacío = no tiene) | *(vacío)* |
| `google_maps_url` | Enlace a Google Maps | https://www.google.com/maps?q=... |
| `place_id` | ID único de Google | ChIJodY1dDHeDQ0RRx... |
| `ciudad` | Ciudad buscada | Madrid |
| `nicho` | Tipo de negocio | peluquería |
| `fecha` | Fecha de la búsqueda | 2026-04-04 |

---

## 📌 Ejemplo de resultados

Búsqueda: **"Peluquería" en "Sanlúcar de Barrameda"**

| Nombre | Teléfono | Rating | Reseñas |
|--------|----------|--------|---------|
| Peluquería Algorez | +34 956 92 78 54 | ⭐ 4.6 | 183 |
| Daniel Bayón Barber | +34 635 89 18 08 | ⭐ 4.9 | 106 |
| Peluquería Valle | +34 856 13 10 95 | ⭐ 4.8 | 89 |
| Barbería Cabildo | +34 956 36 70 66 | ⭐ 4.8 | 57 |
| Gleni Vargas | +34 697 90 07 15 | ⭐ 4.8 | 53 |

> Todos estos negocios **no tienen página web** → son potenciales clientes.

---

## 🏗️ Arquitectura del workflow

```
┌─────────────────┐     ┌──────────────┐     ┌───────────────────┐
│  📝 Formulario  │────▶│  🔍 SerpApi  │────▶│ 📊 Extraer datos  │
│  (Form Trigger) │     │ (HTTP Request)│     │   (Code Node)     │
└─────────────────┘     └──────────────┘     └───────┬───────────┘
                                                      │
                                                      ▼
                                              ┌──────────────┐
                                              │ 🔎 ¿Sin Web? │
                                              │   (IF Node)   │
                                              └──┬────────┬──┘
                                                 │        │
                                           SÍ ──┘        └── NO
                                                 │              │
                                                 ▼              ▼
                                    ┌─────────────────┐  ┌───────────┐
                                    │ 📄 Convertir CSV │  │ ❌ Descarta│
                                    │ (ConvertToFile)  │  │  (NoOp)   │
                                    └────────┬────────┘  └───────────┘
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │ 💾 Guardar CSV   │
                                    │ (ReadWriteFile)  │
                                    └─────────────────┘
```

### Descripción de cada nodo

| # | Nodo | Tipo | Función |
|---|------|------|---------|
| 1 | 📝 Formulario | Form Trigger | Muestra un formulario web para introducir ciudad y nicho |
| 2 | 🔍 SerpApi | HTTP Request | Llama a la API de SerpApi con motor Google Maps |
| 3 | 📊 Extraer Negocios | Code | Procesa la respuesta JSON y extrae los datos relevantes |
| 4 | 🔎 ¿Sin Web? | IF | Filtra: solo pasan los negocios sin campo `website` |
| 5 | 📄 Convertir a CSV | ConvertToFile | Convierte los datos filtrados a formato CSV binario |
| 6 | 💾 Guardar CSV | ReadWriteFile | Escribe el archivo CSV en disco |
| 7 | ❌ Tiene Web | NoOp | Descarta negocios que ya tienen web |

---

## Workflow 2: Outreach Multi-Servicio

> 📄 Archivo: `workflow-andcode-outreach.json` · 📖 Guía detallada: [`guia-andcode-outreach.md`](guia-andcode-outreach.md)

Toma los leads captados (o cualquier lista de prospectos en Google Sheets) y les envía un email **completamente personalizado según el servicio que necesitan**, registrándolos automáticamente en HubSpot CRM.

### Flujo del Workflow 2

```
📋 Google Sheets (leads con columna servicio_objetivo)
         ↓
🔎 Filtra leads ya contactados
         ↓
🔀 Switch por servicio_objetivo
    ↙          ↓          ↘
🌐 Web     📱 App     🤖 Auto
    ↘          ↓          ↙
    Variables personalizadas (asunto, problema, propuesta, CTA)
         ↓
📧 Email HTML personalizado (Gmail)
         ↓
👤 Crear contacto en HubSpot CRM
         ↓
💼 Crear trato con etiqueta de servicio
         ↓
✅ Marcar como procesado en Google Sheets
```

### Nodos del Workflow 2

| # | Nodo | Función |
|---|------|---------|
| 1 | 🕐 Ejecutar Manualmente | Trigger manual |
| 2 | 📋 Leer Leads | Lee todas las filas de Google Sheets |
| 3 | 🔎 Filtrar No Procesados | Omite filas con `email_enviado = SI` |
| 4 | 🔀 Switch Servicio | Divide el flujo: `web` / `app` / `automatizacion` |
| 5 | 🌐 Variables Web | Genera contenido para leads de Desarrollo Web |
| 6 | 📱 Variables App | Genera contenido para leads de Software a Medida |
| 7 | 🤖 Variables Automatización | Genera contenido para leads de Automatización e IA |
| 8 | 📧 Enviar Email | Email HTML con diseño profesional y contenido dinámico |
| 9 | 👤 Crear Contacto HubSpot | Registra el prospecto en el CRM |
| 10 | 💼 Crear Trato HubSpot | Deal con etiqueta WEB / APP / AUTOMATIZACION |
| 11 | ✅ Marcar Procesado | Escribe `SI` y la fecha en el Sheet |

### Expresiones dinámicas clave

```javascript
// Asunto del email — se adapta según el servicio
// Web:
"¿Tu web está perdiendo clientes sin que lo sepas, {{ nombre_contacto }}?"
// App:
"¿Cuántas horas pierde {{ nombre_empresa }} al mes en procesos manuales?"
// Auto:
"¿Qué pasaría si {{ nombre_empresa }} automatizara sus tareas repetitivas?"

// Nombre del trato en HubSpot
{{ $json.servicio_label + ' — ' + $json.nombre_empresa }}
// Ejemplo: "Desarrollo Web — Fontanería García SL"
```

**→ [Ver guía completa de configuración del Workflow 2](guia-andcode-outreach.md)**

---

## 🔧 Solución de problemas

### ❌ El puerto 5678 está ocupado

```bash
lsof -ti :5678 | xargs kill -9
sleep 1
N8N_RESTRICT_FILE_ACCESS_TO="" n8n start
```

### ❌ "The file is not writable"

Asegúrate de iniciar n8n con la variable de entorno:
```bash
N8N_RESTRICT_FILE_ACCESS_TO="" n8n start
```

Y dale permisos al archivo:
```bash
chmod 666 /ruta/a/tu/leads.csv
```

### ❌ No aparecen resultados

- Verifica que tu API Key de SerpApi es correcta
- Comprueba que no has agotado las 250 búsquedas mensuales gratuitas
- Prueba con una ciudad grande (ej: `Madrid`) y un nicho común (ej: `peluquería`)

### ❌ Los nodos aparecen desconectados

1. Borra el workflow importado
2. Reimporta el archivo `workflow-leads-MANUAL.json`
3. Verifica que las flechas conectan todos los nodos en orden

### ❌ Error "Cannot read properties of undefined"

- Probablemente la versión de n8n no coincide con los nodos del workflow
- Actualiza n8n: `npm update n8n -g`
- Reimporta el workflow

---

## ⚠️ Limitaciones

| Limitación | Detalle |
|------------|---------|
| **250 búsquedas/mes** | Plan gratuito de SerpApi. Cada ejecución del formulario = 1 búsqueda |
| **~20 resultados por búsqueda** | Google Maps devuelve aprox. 20 negocios por consulta |
| **Sobrescribe el CSV** | Cada nueva búsqueda reemplaza el CSV anterior. Haz copia antes si quieres conservar datos anteriores |
| **Solo negocios en Google Maps** | Si un negocio no está en Google Maps, no aparecerá |
| **Ejecución local** | El workflow corre en tu máquina. Si cierras n8n, no funciona |

---

## 💡 Ideas de mejora

- [ ] Conectar Workflow 1 con Workflow 2 automáticamente (pipeline end-to-end)
- [ ] Añadir un nodo Wait entre leads para evitar filtros anti-spam
- [ ] Programar ejecución automática con Schedule Trigger (ej: lunes 9:00)
- [ ] Añadir seguimiento: reenviar si no hay respuesta en 5 días
- [ ] Búsqueda paginada en Google Maps (más de 20 resultados)
- [ ] Deduplicación de leads entre ejecuciones

---

## 🤝 Contribuir

1. Haz fork del repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Haz commit (`git commit -m 'Añadir nueva funcionalidad'`)
4. Push (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 👥 Equipo

**ALJE Solutions** — Automatización y soluciones digitales.

---

<div align="center">

Hecho con ❤️ usando [n8n](https://n8n.io) y [SerpApi](https://serpapi.com)

</div>
