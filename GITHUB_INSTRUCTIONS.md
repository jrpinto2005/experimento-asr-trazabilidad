# 📤 Instrucciones para Subir el Proyecto a GitHub

## ✅ Paso 1: Repositorio Git Inicializado

El repositorio Git ya está inicializado y con el commit inicial realizado.

```bash
✓ git init
✓ git add .
✓ git commit -m "Initial commit..."
```

---

## 🚀 Paso 2: Crear Repositorio en GitHub

### Opción A: Desde la Web de GitHub (Recomendado)

1. Ve a [GitHub.com](https://github.com) e inicia sesión
2. Click en el botón **"+"** (arriba derecha) → **"New repository"**
3. Configura el repositorio:
   - **Repository name**: `experimento-asr-trazabilidad` (o el nombre que prefieras)
   - **Description**: "Experimento ASR - Sistema de Inventario con Trazabilidad de Operarios"
   - **Visibility**: 
     - ✅ **Public** (si quieres que sea público)
     - ✅ **Private** (si quieres que sea privado)
   - ❌ **NO marques** "Add a README file"
   - ❌ **NO marques** "Add .gitignore"
   - ❌ **NO marques** "Choose a license"
4. Click en **"Create repository"**

### Opción B: Desde la Terminal con GitHub CLI

```bash
# Si tienes GitHub CLI instalado
gh repo create experimento-asr-trazabilidad --public --source=. --remote=origin --push

# O para repositorio privado
gh repo create experimento-asr-trazabilidad --private --source=. --remote=origin --push
```

---

## 📤 Paso 3: Subir el Código a GitHub

Después de crear el repositorio en GitHub, ejecuta estos comandos:

### 3.1 Renombrar rama a 'main' (opcional pero recomendado)

```bash
git branch -M main
```

### 3.2 Agregar el repositorio remoto

```bash
# Reemplaza TU_USUARIO con tu nombre de usuario de GitHub
git remote add origin https://github.com/TU_USUARIO/experimento-asr-trazabilidad.git

# Ejemplo:
# git remote add origin https://github.com/julianpintocajiao/experimento-asr-trazabilidad.git
```

### 3.3 Subir el código

```bash
git push -u origin main
```

Si te pide autenticación, usa tu **Personal Access Token** (no la contraseña).

---

## 🔑 Paso 4: Configurar Personal Access Token (si es necesario)

Si GitHub te pide autenticación:

1. Ve a GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click en **"Generate new token"** → **"Generate new token (classic)"**
3. Configuración:
   - **Note**: "Token para experimento ASR"
   - **Expiration**: 90 days (o lo que prefieras)
   - **Scopes**: Marca ✅ **repo** (todos los permisos de repositorio)
4. Click en **"Generate token"**
5. **COPIA EL TOKEN** (solo se muestra una vez)
6. Usa este token como contraseña cuando Git te lo pida

---

## 📋 Paso 5: Comandos Completos (Copia y Pega)

```bash
# Ir al directorio del proyecto
cd /Users/julianpintocajiao/Downloads/Uniandes/ArquiSof/Trazabilidad

# Renombrar rama a main
git branch -M main

# Agregar repositorio remoto (REEMPLAZA TU_USUARIO)
git remote add origin https://github.com/TU_USUARIO/experimento-asr-trazabilidad.git

# Verificar que el remoto está configurado
git remote -v

# Subir el código
git push -u origin main
```

---

## ✅ Verificación

Después de ejecutar `git push`, deberías ver algo como:

```
Enumerating objects: 45, done.
Counting objects: 100% (45/45), done.
Delta compression using up to 8 threads
Compressing objects: 100% (40/40), done.
Writing objects: 100% (45/45), 50.12 KiB | 5.01 MiB/s, done.
Total 45 (delta 5), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (5/5), done.
To https://github.com/TU_USUARIO/experimento-asr-trazabilidad.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

---

## 🌐 Paso 6: Verificar en GitHub

1. Ve a `https://github.com/TU_USUARIO/experimento-asr-trazabilidad`
2. Deberías ver:
   - ✅ Todos los archivos y carpetas
   - ✅ El README.md como página principal
   - ✅ 33 archivos
   - ✅ El commit inicial

---

## 🔄 Clonar el Repositorio

Ahora cualquiera (o tú desde otra máquina) puede clonar el proyecto:

```bash
# Clonar repositorio público
git clone https://github.com/TU_USUARIO/experimento-asr-trazabilidad.git

# Clonar repositorio privado (requiere autenticación)
git clone https://github.com/TU_USUARIO/experimento-asr-trazabilidad.git

# Entrar al directorio
cd experimento-asr-trazabilidad

# Verificar archivos
./verify-project.sh

# Leer documentación
cat START_HERE.md
```

---

## 📝 Paso 7: Actualizar el README con la URL del Repo (Opcional)

Puedes agregar un badge al inicio del README:

```bash
# Editar README.md y agregar al inicio:
```

```markdown
# Experimento ASR - Sistema de Inventario con Trazabilidad

[![GitHub](https://img.shields.io/badge/GitHub-Repositorio-blue?logo=github)](https://github.com/TU_USUARIO/experimento-asr-trazabilidad)
```

Luego hacer commit:

```bash
git add README.md
git commit -m "docs: Agregar badge de GitHub al README"
git push
```

---

## 🎯 Comandos Útiles de Git

### Ver estado del repositorio
```bash
git status
```

### Ver historial de commits
```bash
git log --oneline
```

### Agregar archivos nuevos
```bash
git add .
git commit -m "Descripción del cambio"
git push
```

### Actualizar desde GitHub (pull)
```bash
git pull origin main
```

### Ver remoto configurado
```bash
git remote -v
```

---

## 🔧 Troubleshooting

### Error: "remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/TU_USUARIO/experimento-asr-trazabilidad.git
```

### Error: "failed to push some refs"
```bash
git pull origin main --rebase
git push origin main
```

### Error: "Authentication failed"
- Asegúrate de usar un Personal Access Token, no tu contraseña
- El token debe tener permisos de `repo`

### Cambiar URL del remoto
```bash
git remote set-url origin https://github.com/NUEVO_USUARIO/nuevo-nombre.git
```

---

## 📊 Información del Repositorio

Una vez subido, tu repositorio contendrá:

- 📄 **33 archivos**
- 📝 **~4400 líneas de código**
- 🗂️ **7 documentos markdown**
- 🔧 **2 backends en Go**
- 🎨 **1 frontend en React**
- 🗄️ **3 scripts SQL**
- 🛠️ **4 scripts de automatización**

---

## 🎉 ¡Listo!

Tu proyecto ahora está en GitHub y puede ser clonado desde cualquier lugar.

**URL de clonación**:
```
https://github.com/TU_USUARIO/experimento-asr-trazabilidad.git
```

Para compartir:
1. Envía la URL del repositorio
2. Los demás pueden clonarlo con `git clone [URL]`
3. Seguir las instrucciones en `START_HERE.md`

---

**Siguiente paso**: Comparte la URL del repositorio con tu equipo o profesor.
