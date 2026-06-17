# 📨 Guía: Workflow de Outreach Multi-Servicio — AndCode

> **Sistema de envío de emails personalizados** para prospectar empresas y registrarlas en HubSpot.  
> Adapta automáticamente el mensaje según si el lead necesita **Web, App o Automatización**.

---

## 📋 Índice

- [¿Qué hace este workflow?](#-qué-hace-este-workflow)
- [Arquitectura del flujo](#-arquitectura-del-flujo)
- [Requisitos y cuentas necesarias](#-requisitos-y-cuentas-necesarias)
- [Paso 1: Preparar el Google Sheets](#paso-1-preparar-el-google-sheets)
- [Paso 2: Configurar Gmail](#paso-2-configurar-gmail)
- [Paso 3: Configurar HubSpot](#paso-3-configurar-hubspot)
- [Paso 4: Importar y configurar el workflow en n8n](#paso-4-importar-y-configurar-el-workflow-en-n8n)
- [Paso 5: Añadir leads y ejecutar](#paso-5-añadir-leads-y-ejecutar)
- [Plantillas de email generadas](#-plantillas-de-email-generadas)
- [Expresiones dinámicas usadas](#-expresiones-dinámicas-usadas)
- [Solución de problemas](#-solución-de-problemas)

---

## 🎯 ¿Qué hace este workflow?

```
📋 Lee leads de Google Sheets
         ↓
🔎 Salta los ya procesados (email_enviado = SI)
         ↓
🔀 Detecta qué servicio necesita cada lead
     ↙       ↓       ↘
  🌐 Web   📱 App  🤖 Auto
     ↘       ↓       ↙
📧 Envía email HTML personalizado
         ↓
👤 Crea contacto en HubSpot CRM
         ↓
💼 Crea trato en HubSpot con etiqueta de servicio
         ↓
✅ Marca la fila en Sheets como procesada
```

**Capacidad:** 20–30 empresas por ejecución (ajustable).  
**Cadencia recomendada:** Ejecutar 1–2 veces por semana.

---

## 🏗️ Arquitectura del flujo

| # | Nodo | Función |
|---|------|---------|
| 1 | 🕐 Ejecutar Manualmente | Trigger manual para iniciar el proceso |
| 2 | 📋 Leer Leads | Lee todas las filas del Google Sheets |
| 3 | 🔎 Filtrar No Procesados | Omite las filas donde `email_enviado = SI` |
| 4 | 🔀 Switch Servicio | Divide el flujo según `servicio_objetivo` |
| 5 | 🌐 Variables Web | Genera asunto, problema, propuesta y CTA para leads de Web |
| 6 | 📱 Variables App | Genera contenido para leads de Software a Medida |
| 7 | 🤖 Variables Automatización | Genera contenido para leads de Automatización e IA |
| 8 | 📧 Enviar Email | Manda el email HTML usando las variables del paso anterior |
| 9 | 👤 Crear Contacto HubSpot | Registra el contacto en el CRM gratuito |
| 10 | 💼 Crear Trato HubSpot | Crea el deal con etiqueta de servicio |
| 11 | ✅ Marcar Procesado | Actualiza `email_enviado = SI` y `fecha_envio` en el Sheet |

---

## 📦 Requisitos y cuentas necesarias

| Herramienta | Plan | Coste | Enlace |
|-------------|------|-------|--------|
| **n8n** | Self-hosted | Gratis | Ya instalado |
| **Google Sheets** | Cualquier cuenta Google | Gratis | [sheets.google.com](https://sheets.google.com) |
| **Gmail** | Cuenta Google | Gratis | [gmail.com](https://gmail.com) |
| **HubSpot** | Free CRM | Gratis | [hubspot.com](https://hubspot.com) |

> ⚠️ **Google Sheets y Gmail requieren configurar OAuth en Google Cloud Console.**  
> Si no quieres hacerlo, ve a la [alternativa SMTP](#alternativa-smtp-sin-google-cloud) al final de esta sección.

### Alternativa SMTP (sin Google Cloud)

Si configurar Google OAuth te resulta complicado, puedes usar cualquier cuenta de correo con SMTP:

1. En n8n, en vez del nodo **Gmail**, usa el nodo **"Send Email"** (SMTP)
2. Configura con tu proveedor de email:
   - **Gmail con contraseña de app:** host `smtp.gmail.com`, puerto `587`
   - **Outlook/Hotmail:** host `smtp-mail.outlook.com`, puerto `587`
3. En Gmail: activa la verificación en 2 pasos → "Contraseñas de aplicaciones" → genera una contraseña de 16 caracteres

---

## Paso 1: Preparar el Google Sheets

### 1.1 Crear la hoja

1. Ve a [sheets.google.com](https://sheets.google.com) y crea una hoja nueva
2. Llámala **"Leads"** (así se llama en el workflow)
3. En la **primera fila**, crea estas columnas exactamente con estos nombres:

| Columna | Descripción | Obligatorio |
|---------|-------------|-------------|
| `nombre_empresa` | Nombre de la empresa | ✅ |
| `nombre_contacto` | Nombre y apellidos del contacto | ✅ |
| `email_contacto` | Email del contacto (se usará para enviar y para deduplicar en HubSpot) | ✅ |
| `cargo` | Cargo en la empresa | Opcional |
| `telefono` | Teléfono de contacto | Opcional |
| `sector` | Sector de la empresa | Opcional |
| `ciudad` | Ciudad | Opcional |
| `servicio_objetivo` | **`web`**, **`app`** o **`automatizacion`** | ✅ |
| `fuente` | Cómo encontramos este lead | Opcional |
| `notas` | Notas internas | Opcional |
| `email_enviado` | El workflow escribe aquí `SI` cuando procesa la fila | Automático |
| `fecha_envio` | El workflow escribe aquí la fecha de envío | Automático |

### 1.2 Importar la plantilla

Puedes importar el archivo `plantilla-leads-sheets.csv` incluido en este repo:
1. En Google Sheets: **Archivo → Importar → Subir**
2. Selecciona `plantilla-leads-sheets.csv`
3. Elige "Reemplazar hoja de cálculo actual"

### 1.3 Obtener el ID del Sheet

La URL de tu Sheet tiene este formato:
```
https://docs.google.com/spreadsheets/d/ESTE_ES_EL_ID/edit
```
Copia ese ID — lo necesitarás en el workflow.

---

## Paso 2: Configurar Gmail

### Opción A: Gmail OAuth (recomendado para producción)

#### A.1 — Activar las APIs necesarias

1. Ve a [console.cloud.google.com](https://console.cloud.google.com) y selecciona tu proyecto
2. Menú izquierdo → **APIs y servicios → Biblioteca**
3. Busca y activa **Gmail API**
4. Vuelve a Biblioteca, busca y activa **Google Sheets API**

#### A.2 — Configurar la Pantalla de consentimiento OAuth

1. Menú izquierdo → **APIs y servicios → Pantalla de consentimiento de OAuth**
2. Si te pregunta el tipo, elige **Externo** → Crear
3. Rellena solo lo obligatorio:
   - Nombre de la app: `AndCode n8n`
   - Email de asistencia: tu email
   - Email del desarrollador (abajo del todo): tu email
4. Pulsa **Guardar y continuar** en todos los pasos hasta llegar al resumen
5. En el resumen verás el estado **"En prueba"** — esto es correcto

#### A.3 — Añadir tu email como usuario de prueba

> ⚠️ Esta sección está en **Pantalla de consentimiento de OAuth**, NO en Credenciales.

1. Menú izquierdo → **APIs y servicios → Pantalla de consentimiento de OAuth**
2. En la pestaña **"Usuarios de prueba"** (barra superior de la página)  
   — si no ves la pestaña, desplázate hacia abajo en la misma página hasta la sección **"Usuarios de prueba"**
3. Haz clic en **"+ Add Users"**
4. Escribe `andcodeinfo@gmail.com`
5. Guarda

#### A.4 — Configurar el cliente OAuth (la pantalla que tienes ahora)

En la pantalla **"ID de cliente para Aplicación web"** que tienes abierta:

1. En **"URIs de redireccionamiento autorizados"** → haz clic en **`+ Agregar URI`**
2. Escribe exactamente:
   ```
   http://localhost:5678/rest/oauth2-credential/callback
   ```
3. Pulsa **Guardar**

> ℹ️ Los "Orígenes autorizados de JavaScript" puedes dejarlo vacío — n8n no lo necesita.

#### A.5 — Copiar credenciales a n8n

1. Haz clic en el icono ✏️ del cliente para ver el **Client ID** y **Client Secret**
2. En n8n (http://localhost:5678):
   - Ve a **Credenciales → Nueva credencial → Google Sheets OAuth2**
   - Pega el **Client ID** y el **Client Secret**
   - Haz clic en **"Sign in with Google"**
   - Selecciona `andcodeinfo@gmail.com`
   - Si Google avisa de que la app no está verificada → haz clic en **"Avanzado" → "Ir a AndCode n8n (no seguro)"**
   - Acepta los permisos
3. Repite el proceso para crear otra credencial **Gmail OAuth2** con los mismos Client ID y Secret

### Opción B: SMTP con App Password (más rápido)

1. En tu cuenta Google: [myaccount.google.com/security](https://myaccount.google.com/security)
2. Activa **Verificación en 2 pasos** si no la tienes
3. Busca **"Contraseñas de aplicaciones"** → Crear → Selecciona "Correo" y "Mac"
4. Copia la contraseña de 16 caracteres generada
5. En n8n: cambia el nodo **📧 Enviar Email** por el nodo **"Send Email"**:
   - Host: `smtp.gmail.com`
   - Puerto: `587`
   - SSL/TLS: `STARTTLS`
   - Usuario: `tu@gmail.com`
   - Contraseña: la de 16 caracteres del paso 4

---

## Paso 3: Configurar HubSpot

### 3.1 Crear cuenta gratuita

1. Ve a [hubspot.com](https://hubspot.com) → **"Empezar gratis"**
2. Crea la cuenta con el email de AndCode
3. El **CRM gratuito** incluye:
   - Contactos ilimitados
   - Tratos (deals)
   - Pipeline de ventas

### 3.2 Crear un Private App Token

1. En HubSpot: **⚙️ Configuración → Integraciones → Aplicaciones privadas**
2. **Crear aplicación privada**
3. Nombre: `n8n-andcode`
4. En la pestaña **Scopes**, activa:
   - `crm.objects.contacts.write`
   - `crm.objects.deals.write`
   - `crm.objects.contacts.read`
5. **Crear aplicación** → Copia el token (`pat-...`)
6. En n8n: **Credenciales → Nueva → HubSpot App Token**
7. Pega el token

### 3.3 Configurar el Pipeline en HubSpot

El workflow crea tratos en la etapa `appointmentscheduled` (primera etapa por defecto). Para cambiarla:
1. En HubSpot: **CRM → Negocios → ⚙️ Editar etapas**
2. Copia el nombre interno de la etapa que prefieras
3. En n8n, en el nodo **💼 Crear Trato HubSpot**, cambia `dealStage` por ese valor

---

## Paso 4: Importar y configurar el workflow en n8n

### 4.1 Iniciar n8n

```bash
# SIEMPRE usar este comando (permite escribir archivos locales)
N8N_RESTRICT_FILE_ACCESS_TO="" n8n start
```

Abre **http://localhost:5678**

### 4.2 Importar el workflow

1. En n8n: **"..."** (menú lateral) → **"Import from File"**
2. Selecciona `workflow-andcode-outreach.json`

### 4.3 Configurar credenciales

Para cada nodo con ⚠️ (error de credenciales), haz doble clic y configura:

| Nodo | Credencial necesaria |
|------|---------------------|
| 📋 Leer Leads | Google Sheets OAuth2 |
| 📧 Enviar Email | Gmail OAuth2 (o SMTP) |
| 👤 Crear Contacto HubSpot | HubSpot App Token |
| 💼 Crear Trato HubSpot | HubSpot App Token |
| ✅ Marcar Procesado | Google Sheets OAuth2 |

### 4.4 Configurar el ID del Google Sheets

Hay **dos nodos** que necesitan el ID de tu Sheet:

1. **Nodo 📋 Leer Leads** → campo `Document ID` → pega el ID
2. **Nodo ✅ Marcar Procesado** → campo `Document ID` → pega el mismo ID

### 4.5 Verificar el nombre de la hoja

Ambos nodos de Sheets deben tener `Sheet Name = Leads` (o el nombre que uses en tu hoja).

---

## Paso 5: Añadir leads y ejecutar

### 5.1 Añadir leads al Sheet

Rellena las filas con los datos de tus prospectos. El campo más importante es `servicio_objetivo`:

| Si el cliente necesita... | Escribe en `servicio_objetivo` |
|---------------------------|-------------------------------|
| Una web corporativa nueva o rediseño | `web` |
| Una aplicación o software a medida | `app` |
| Automatizar procesos o integrar IA | `automatizacion` |

Deja siempre `email_enviado` en blanco (el workflow lo rellena automáticamente).

### 5.2 Ejecutar el workflow

1. En n8n, abre el workflow
2. Asegúrate de que está **activo** (toggle verde arriba a la derecha)
3. Haz clic en **"Test workflow"** para una prueba manual

### 5.3 Verificar resultados

Tras la ejecución:
- ✅ Los emails aparecen en la carpeta **Enviados** de tu Gmail
- ✅ En HubSpot verás los contactos y tratos nuevos
- ✅ En el Sheet, las filas procesadas tendrán `SI` en `email_enviado`

---

## 📧 Plantillas de email generadas

### 🌐 Plantilla Web

**Asunto:** `¿Tu web está perdiendo clientes sin que lo sepas, [Nombre]?`

> Muchas empresas como **[Empresa]** operan con una web desactualizada o directamente sin presencia online, perdiendo entre un 30 y 50% de sus clientes potenciales antes de que lleguen a contactarles.
>
> En AndCode llevamos más de 50 empresas al entorno digital con webs corporativas modernas, rápidas y diseñadas para convertir visitas en consultas reales...
>
> **¿Tienes 15 minutos esta semana para una auditoría gratuita de tu presencia online?**

---

### 📱 Plantilla App / Software

**Asunto:** `¿Cuántas horas pierde [Empresa] al mes en procesos manuales?`

> La mayoría de empresas gestionan procesos críticos con hojas de cálculo y herramientas desconectadas entre sí. **[Empresa]** probablemente tampoco es una excepción...
>
> En AndCode desarrollamos software a medida y aplicaciones internas que digitalizan exactamente lo que tu empresa necesita...
>
> **¿Te interesa ver en 15 minutos cómo podríamos digitalizar uno de tus procesos clave?**

---

### 🤖 Plantilla Automatización

**Asunto:** `¿Qué pasaría si [Empresa] automatizara sus tareas repetitivas?`

> Cada semana, equipos como el de **[Empresa]** dedican horas a tareas repetitivas: enviar emails manualmente, copiar datos entre sistemas, generar informes...
>
> En AndCode implementamos automatizaciones con IA que conectan todas tus herramientas y eliminan el trabajo manual. Nuestros clientes ahorran de media 15-20 horas semanales por empleado...
>
> **¿Hablamos 15 minutos esta semana sobre qué procesos de [Empresa] podríamos automatizar?**

---

## 🧩 Expresiones dinámicas usadas

Estas son las fórmulas n8n que hacen el email personalizado:

```javascript
// Asunto dinámico (ejemplo Web)
={{ '¿Tu web está perdiendo clientes sin que lo sepas, ' + $json.nombre_contacto + '?' }}

// Problema dinámico (referencia al nombre de empresa)
={{ 'Muchas empresas como ' + $json.nombre_empresa + ' operan con...' }}

// CTA dinámico (ejemplo Automatización)
={{ '¿Hablamos 15 minutos sobre qué procesos de ' + $json.nombre_empresa + ' podríamos automatizar?' }}

// Nombre en el trato HubSpot
={{ $json.servicio_label + ' — ' + $json.nombre_empresa }}
// Ejemplo resultado: "Desarrollo Web — Fontanería García SL"

// Fecha de cierre del trato (30 días desde hoy)
={{ new Date(Date.now() + 30*24*60*60*1000).toISOString().split('T')[0] }}
```

---

## 🔧 Solución de problemas

### ❌ "No se puede leer la hoja de cálculo"
- Verifica que el `Document ID` es correcto (la parte larga de la URL)
- Asegúrate de que la hoja se llama exactamente `Leads`
- Confirma que la credencial de Google Sheets está conectada

### ❌ Error 403: access_denied — "no ha completado la verificación de Google"

Esto pasa porque tu app está en modo **"En prueba"** y tu email no está en la lista de testers, O porque falta configurar la URI de redirección.

**Checklist completo:**

1. **¿Tienes la URI de redirección añadida?**  
   Google Cloud → Credenciales → edita tu cliente OAuth → **URIs de redireccionamiento autorizados** debe tener:
   ```
   http://localhost:5678/rest/oauth2-credential/callback
   ```

2. **¿Está tu email como usuario de prueba?**  
   Google Cloud → **APIs y servicios → Pantalla de consentimiento de OAuth**  
   → pestaña o sección **"Usuarios de prueba"** → **+ Add Users** → añade tu email

3. **¿Ves "La app no está verificada"?** → normal → haz clic en **"Avanzado"** → **"Ir a AndCode n8n (no seguro)"**

### ❌ "Error de autenticación Gmail"
- La credencial OAuth ha caducado → reconecta desde n8n → Credenciales
- Si usas SMTP, verifica que la App Password es correcta

### ❌ "Contacto ya existe en HubSpot"
- HubSpot no permite duplicar emails — si el contacto ya existe, el nodo fallará
- Solución: activa `Continue on Fail` en el nodo 👤 Crear Contacto HubSpot

### ❌ El Switch no enruta correctamente
- Verifica que `servicio_objetivo` en el Sheet está escrito exactamente: `web`, `app` o `automatizacion` (sin tildes, en minúsculas)
- Los leads sin ninguno de esos valores van a la salida "extra" del Switch (no se procesan)

### ❌ El email llega como spam
- Añade el dominio de tu Gmail a la lista de remitentes de confianza
- Envía primero a una cuenta propia para verificar que no hay problemas
- Evita enviar más de 20-30 emails seguidos (límite de Gmail gratuito: 500/día)

---

## 💡 Próximos pasos recomendados

- [ ] **Añadir un nodo Wait** entre email y HubSpot para evitar rate limiting
- [ ] **Programar ejecución automática** con Schedule Trigger (ej: lunes a las 9:00)
- [ ] **Añadir seguimiento**: crear un segundo workflow para reenviar si no hubo respuesta en 5 días
- [ ] **Conectar el workflow de captación** (`workflow-leads-MANUAL`) con este para un pipeline end-to-end completo

---

*Parte del sistema de automatización comercial de AndCode — [ALJE-Solutions/automatizacion-leads](https://github.com/ALJE-Solutions/automatizacion-leads)*
