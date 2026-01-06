 KALI-SENTINEL v2.0
Automated Security Auditing & Hardening Script for Linux Systems

 Descripción
Kali-Sentinel v2.0 es una herramienta automatizada diseñada para auditores de seguridad y administradores de sistemas. Su objetivo es establecer una "línea base de seguridad" (Security Baseline) en estaciones de trabajo Linux (específicamente Kali Linux y derivados Debian).

El script combina la potencia de Lynis para la auditoría con rutinas personalizadas de Hardening (endurecimiento), cerrando brechas comunes de seguridad, configurando firewalls y optimizando el kernel contra ataques de red, todo en una sola ejecución.

 Funcionalidades Principales
Este script realiza un ciclo completo de Auditoría -> Remediación -> Verificación:

Auditoría Inicial: Ejecuta un escaneo silencioso con Lynis para calcular el índice de seguridad actual.

Instalación de Defensas: Despliega herramientas críticas como UFW (Firewall), Fail2Ban (Anti-Bruteforce) y utilidades de integridad.

Hardening de Red y Kernel:

Protección contra ataques Man-in-the-Middle (MITM) y Spoofing.

Deshabilitación de redirecciones ICMP.

Protección de memoria (ASLR).

Configuración de DNS seguros (Google DNS) con bloqueo de modificación (chattr).

Hardening de Accesos (SSH & Usuarios):

Deshabilita el login directo de root.

Bloquea contraseñas vacías y reenvío de X11.

Configura banners legales de advertencia en /etc/issue.

Configuración de Firewall: Política de "Denegar todo el tráfico entrante" por defecto, permitiendo solo conexiones salientes y SSH.

Reporte Ejecutivo: Genera automáticamente un archivo Informe_Ejecutivo_Seguridad.txt con el resumen de métricas (Score Inicial vs. Final) y las acciones tomadas, listo para presentar a gerencia.

 Instalación y Uso
Prerrequisitos
Sistema Operativo: Kali Linux, Ubuntu, o Debian.

Privilegios: Se requiere acceso Root (sudo).

Ejecución paso a paso
Clonar el repositorio:

Bash

git clone https://github.com/TU_USUARIO/kali-sentinel.git
cd kali-sentinel
Dar permisos de ejecución:

Bash

chmod +x kali_sentinel_v2.sh
Ejecutar el script:

Bash

sudo ./kali_sentinel_v2.sh
Ver resultados: Al finalizar, el script mostrará la mejora en el puntaje de seguridad y generará el reporte.

Bash

cat Informe_Ejecutivo_Seguridad.txt
 Análisis Técnico (Detalle de Cambios)
A continuación se detalla la lógica aplicada en la fase de Hardening:

1. Blindaje del Kernel (sysctl.conf)
Se modifican parámetros volátiles del kernel para mitigar ataques de red:

net.ipv4.conf.all.accept_redirects = 0: Evita que un atacante redirija el tráfico de red (MITM).

net.ipv4.icmp_echo_ignore_broadcasts = 1: Protege contra ataques Smurf (DDoS).

net.ipv4.tcp_syncookies = 1: Mitigación contra ataques SYN Flood.

kernel.randomize_va_space = 2: Habilita ASLR completo para dificultar exploits de desbordamiento de búfer.

2. Seguridad SSH (sshd_config)
Se aplica el principio de mínimo privilegio:

PermitRootLogin no: Obliga a los administradores a loguearse como usuario normal y escalar privilegios, dejando traza de auditoría.

MaxAuthTries 3: Limita los intentos de conexión para dificultar fuerza bruta.

3. Integridad de Archivos
Se utiliza chattr +i /etc/resolv.conf para hacer el archivo de DNS inmutable, evitando que malware o scripts maliciosos secuestren la resolución de nombres.

 Ejemplo de Reporte Generado
Plaintext

================================================================
INFORME DE CIBERSEGURIDAD Y HACKING ÉTICO - KALI LINUX
Fecha del reporte: 12-01-2026 10:30
Auditor: Sentinel v2.0 (Automated Script)
================================================================

1. RESUMEN EJECUTIVO
--------------------
Se ha realizado un proceso de auditoría y endurecimiento...

2. MÉTRICAS DE MEJORA
---------------------
- Nivel de Seguridad Inicial: 62 / 100
- Nivel de Seguridad Final:   84 / 100
- Estado Actual: PROTEGIDO
...
 Disclaimer
Este script realiza cambios significativos en la configuración del sistema. Se recomienda:

No ejecutar en entornos de producción sin una revisión previa.

Realizar una copia de seguridad antes de la ejecución.

Reiniciar el sistema tras la ejecución para aplicar los cambios en el Kernel.

Desarrollado por "Marcelo R. Damas" - Analista Técnico de Ciberseguridad

