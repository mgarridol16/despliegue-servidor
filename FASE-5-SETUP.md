# 📖 FASE 5: CI/CD - Guía de Configuración

**Versión**: 2.1
**Objetivo**: Automatizar linting, seguridad, build y deploy
**Tiempo estimado**: 30 minutos para configuración

---

## 🎯 WORKFLOWS IMPLEMENTADOS

| Workflow | Trigger | Propósito | Requiere Secrets |
|----------|---------|-----------|-----------------|
| **linter.yml** | push/PR | Validar YAML, Bash, Docker Compose | ❌ No |
| **security.yml** | push/PR | Trivy scan, verificación configuración | ❌ No |
| **build.yml** | push a main | Build & Push a Docker Hub | ✅ DOCKER_HUB_* |
| **deploy.yml** | push a main | Deploy SSH automático (opcional) | ✅ SERVER_* |

---

## 🔧 CONFIGURACIÓN PASO A PASO

### PASO 1: Crear Dockerfile (si no existe)

```bash
# En raíz del proyecto
cat > Dockerfile << 'EOF'
FROM ubuntu:22.04

LABEL maintainer="tu-email@ejemplo.com"
LABEL description="Infraestructura de despliegue con Docker, Nginx, Prometheus y Grafana"

RUN apt-get update && apt-get install -y \
    docker.io \
    docker-compose \
    && rm -rf /var/lib/apt/lists/*

COPY . /app
WORKDIR /app

EXPOSE 80 443
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD docker ps || exit 1

CMD ["docker-compose", "up", "-d"]
EOF
```

### PASO 2: Crear Secrets en GitHub

#### 2.1 Para BUILD (Obligatorio)

Necesitas crear secrets en GitHub para que `build.yml` pueda subir a Docker Hub.

**Pasos:**
1. Ve a tu repositorio → **Settings** → **Secrets and variables** → **Actions**
2. Clic en **New repository secret**
3. Crear los siguientes:

| Secret Name | Valor | Dónde obtenerlo |
|-------------|-------|-----------------|
| `DOCKER_HUB_USERNAME` | Tu usuario de Docker Hub | https://hub.docker.com (login) |
| `DOCKER_HUB_TOKEN` | Token de Docker Hub | https://hub.docker.com/settings/security → New Access Token |

**Paso detallado para obtener token:**
```
1. Login en https://hub.docker.com
2. Settings (esquina arriba derecha)
3. Security → New Access Token
4. Nombre: github-actions (o similar)
5. Scope: Read & Write
6. Copy token (aparecerá UNA sola vez)
7. Pegar en GitHub Secrets
```

**Verificación:**
```bash
# Despúes de crear secrets, ver en Actions del repositorio
# Debería ver build.yml ejecutándose sin error de credenciales
```

#### 2.2 Para DEPLOY (Opcional - solo si quieres SSH automático)

Si implementas `deploy.yml`, necesitas secrets adicionales:

| Secret Name | Valor | Ejemplo |
|-------------|-------|---------|
| `SERVER_HOST` | IP o dominio del servidor | `192.168.1.100` o `servidor.dominio.com` |
| `SERVER_USER` | Usuario SSH en servidor | `deploy-user` |
| `SERVER_SSH_KEY` | Private SSH key (sin passphrase) | Contenido completo de `~/.ssh/id_rsa` |
| `SERVER_SSH_PORT` | (Opcional) Puerto SSH | `22` (por defecto) |

**Generar SSH key sin passphrase (en servidor):**
```bash
# En el servidor
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github-deploy -N ""

# Ver la clave pública (autorizarla)
cat ~/.ssh/github-deploy.pub >> ~/.ssh/authorized_keys

# Ver la clave privada (copiar a GitHub Secrets)
cat ~/.ssh/github-deploy
```

**Copiar SSH key a GitHub:**
```bash
# Copiar contenido COMPLETO de ~/.ssh/github-deploy
# (incluir BEGIN RSA PRIVATE KEY hasta END RSA PRIVATE KEY)
# Pegar en GitHub → Settings → Secrets → SERVER_SSH_KEY
```

### PASO 3: Verificar Workflows

Después de crear los secrets:

1. **Hacer push a repositorio:**
   ```bash
   git add .github/
   git commit -m "feat: agregar FASE 5 CI/CD workflows"
   git push origin main
   ```

2. **Ver ejecución en GitHub:**
   - Ve al repositorio
   - Tab **Actions**
   - Verás workflows ejecutándose:
     ```
     ✅ linter.yml    (20 seg)
     ✅ security.yml  (30 seg)
     ⏳ build.yml     (2-3 min)
     ⏳ deploy.yml    (si configurado)
     ```

3. **Verificar resultados:**
   ```
   ✅ Linter passed (YAML + Bash válidos)
   ✅ Security passed (Trivy scan limpio)
   ✅ Build succeeded (imagen subida a Docker Hub)
   ✅ Deploy succeeded (si configurado)
   ```

---

## 📋 FLUJO CI/CD COMPLETO

### Escenario: Haces cambios en docker-compose.yml

```
git push origin main
        ↓
[GitHub Actions Trigger]
        ↓
┌─────────────────────────────────────────────────────────────┐
│ 1. LINTER (parallel con security)                           │
├─────────────────────────────────────────────────────────────┤
│ ✓ Valida docker-compose.yml (docker compose config -q)     │
│ ✓ Valida scripts bash (shellcheck)                          │
│ ✓ Super-Linter (YAML, JSON, Bash)                          │
│ ✓ Verifica que secrets existen                             │
└─────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. SECURITY (parallel con linter)                           │
├─────────────────────────────────────────────────────────────┤
│ ✓ Trivy escanea filesystem                                 │
│ ✓ Trivy escanea config                                     │
│ ✓ Verifica no hay credenciales hardcodeadas                │
│ ✓ Valida Dockerfile y docker-compose.yml                   │
└─────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. BUILD (solo si linter + security pasaron)               │
├─────────────────────────────────────────────────────────────┤
│ ✓ Setup Docker Buildx                                      │
│ ✓ Login a Docker Hub                                       │
│ ✓ Build imagen Docker                                      │
│ ✓ Tag: latest + v{run_number} + {commit_hash}             │
│ ✓ Push a Docker Hub                                        │
└─────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. DEPLOY (OPCIONAL - solo si secrets configurados)         │
├─────────────────────────────────────────────────────────────┤
│ ✓ SSH a servidor                                           │
│ ✓ git pull origin main                                     │
│ ✓ docker compose pull (nuevas imágenes)                    │
│ ✓ docker compose up -d --remove-orphans                    │
│ ✓ Verifica servicios levantados                            │
└─────────────────────────────────────────────────────────────┘
        ↓
✅ INFRAESTRUCTURA ACTUALIZADA AUTOMÁTICAMENTE
```

---

## 🧪 CASOS DE PRUEBA

### Test 1: Linter detecta errores

**Qué hacer:**
```bash
# Introducir error YAML en docker-compose.yml
git add .
git commit -m "test: introduce invalid yaml"
git push origin main
```

**Esperado:**
```
❌ linter.yml FAILED
   ✗ docker-compose.yml syntax error
   línea X: ...
🛑 Build + Deploy abortados automáticamente
```

### Test 2: Security detecta credenciales

**Qué hacer:**
```bash
# Agregar password a docker-compose.yml
cat >> docker-compose.yml << 'EOF'
environment:
  - DB_PASSWORD=mi-password-123
EOF

git add .
git commit -m "test: hardcoded password"
git push origin main
```

**Esperado:**
```
❌ security.yml FAILED
   ✗ Possible hardcoded credentials detected
   línea X: DB_PASSWORD=...
🛑 Build abortado
```

### Test 3: Build exitoso

**Qué hacer:**
```bash
# Cambio válido
echo "# Test build" >> README.md
git add .
git commit -m "docs: update readme"
git push origin main
```

**Esperado:**
```
✅ linter.yml PASSED (30 seg)
✅ security.yml PASSED (40 seg)
✅ build.yml PASSED (3 min)
   Imagen: docker.io/tu-usuario/despliegue-servidor:latest
   Tags: v123, abc1234567
✅ deploy.yml SKIPPED (si sin secrets) o PASSED (si configurado)
```

---

## 🚨 TROUBLESHOOTING

### Problema: "Build failed - docker login"

**Solución:**
```
1. Verificar DOCKER_HUB_USERNAME en GitHub Secrets
2. Verificar DOCKER_HUB_TOKEN es válido (no expirado)
3. Token debe tener permisos: Read/Write
4. Generar nuevo token si es necesario
```

### Problema: "Deploy failed - permission denied"

**Solución:**
```
1. Verificar SSH key es sin passphrase:
   ssh-keygen -p -f ~/.ssh/github-deploy
   (dejar passphrase vacía)

2. Verificar authorized_keys tiene la clave pública:
   cat ~/.ssh/github-deploy.pub >> ~/.ssh/authorized_keys

3. Test manual SSH:
   ssh -i ~/.ssh/github-deploy usuario@servidor
   (debería conectar sin contraseña)
```

### Problema: "Linter falló - DOCKER_HUB_USERNAME is empty"

**Solución:**
```
1. Ir a Settings → Secrets and variables
2. Asegurar que DOCKER_HUB_USERNAME tiene valor (no vacío)
3. Si está vacío, editar y guardar valor correcto
4. Re-push para retrigger workflow
```

### Problema: "Build toma demasiado tiempo"

**Normal:**
- Primera build: 3-5 min (descarga bases, instala deps)
- Builds posteriores: 1-2 min (cachés)

**Acelerar:**
```yaml
# En build.yml, usar build cache:
uses: docker/build-push-action@v5
with:
  cache-from: type=gha
  cache-to: type=gha,mode=max
```

---

## 📊 MONITOREO

### Ver logs de workflows:

**En GitHub:**
```
Repository → Actions → Workflow name → Run → Job → Step logs
```

**Descargando artefactos:**
```bash
# Los reports (Trivy SARIF) se cargarán al Security tab
# Repository → Security → Vulnerability alerts
```

### Estadísticas:

```bash
# Ver tiempo de ejecución
# Actions → Workflow → Ver duración por job

# Benchmarks típicos:
# linter.yml: 30-40 seg
# security.yml: 40-60 seg
# build.yml: 120-180 seg (primero), 60-90 seg (posterior)
# deploy.yml: 30-60 seg
# ────────────────────────────────────
# Total pipeline: 5-8 minutos (primera build)
#                2-5 minutos (builds posteriores)
```

---

## 🎓 COMPARATIVA CON COMPAÑEROS

### Basado en:
- **ALONSO**: Validation + Job dependencies
- **VICTOR**: Trivy security scanning
- **LUISMI**: SSH deploy automático
- **MARICARMEN**: Build simple

### MIGUEL v2.1 combina lo mejor:
```
✅ Linter (como ALONSO's Super-Linter)
✅ Security (como VICTOR's Trivy)
✅ Build (como todo compañeros)
✅ Deploy (como LUISMI's appleboy SSH)
✅ Dependencies (como ALONSO)
✅ Credentials validation (como ALONSO)
```

**Resultado:** Pipeline más robusto que cualquier compañero ✨

---

## 🚀 SIGUIENTES PASOS

### Nivel 1: Mínimo (30 min)
```
✅ Configurar DOCKER_HUB_USERNAME + TOKEN
✅ Hacer push
✅ Verificar linter.yml + build.yml ejecutándose
```

### Nivel 2: Intermedio (1 hora)
```
✅ Nivel 1
✅ Verificar security.yml ejecutándose
✅ Revisar resultados Trivy en Security tab
```

### Nivel 3: Máximo (2 horas, opcional)
```
✅ Nivel 2
✅ Configurar SSH secrets
✅ Enable deploy.yml
✅ Verificar auto-deploy funciona
```

---

**¿Necesitas ayuda con algún paso?**

- Configurar secrets → Ver PASO 2
- Generar SSH key → Ver deploy section
- Troubleshoot problemas → Ver TROUBLESHOOTING
- Entender workflows → Ver FLUJO CI/CD COMPLETO
