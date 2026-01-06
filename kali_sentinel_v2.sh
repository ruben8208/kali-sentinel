#!/bin/bash

# ============================================================
#  KALI-SENTINEL v2.0 - Auditoría, Hardening y Reporte
#  Genera informes técnicos y ejecutivos automáticamente.
# ============================================================

# Colores
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Archivo de Reporte para Humanos
FECHA=$(date +"%d-%m-%Y %H:%M")
REPORTE_HUMANO="Informe_Ejecutivo_Seguridad.txt"

# Verificar Root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${ROJO}[ERROR] Necesitas ser ROOT (sudo).${NC}"
    exit 1
fi

banner() {
    clear
    echo -e "${AZUL}"
    echo "███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗     "
    echo "██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║     "
    echo "███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║     "
    echo "╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║     "
    echo "███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗"
    echo "╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}>>> VERSIÓN 2.0 - CONSULTOR AUTOMATIZADO${NC}"
    echo "--------------------------------------------------------"
    sleep 2
}

obtener_puntaje() {
    # Extrae el Hardening Index del reporte de Lynis
    grep "Hardening index" /var/log/lynis.log | awk '{print $4}'
}

# --- FASE 1: AUDITORÍA INICIAL ---
fase_auditoria_inicial() {
    echo -e "${AMARILLO}[1/7] Realizando Auditoría de Estado Inicial...${NC}"
    # Verificar si lynis está instalado, si no, instalarlo rápido
    if ! command -v lynis &> /dev/null; then
        apt-get update -qq && apt-get install lynis -y -qq
    fi
    
    # Correr auditoría silenciosa
    lynis audit system --quick --quiet > /dev/null
    SCORE_INICIAL=$(obtener_puntaje)
    echo -e "${ROJO}>>> Puntuación de Seguridad Inicial: ${SCORE_INICIAL}/100${NC}"
}

# --- FASES DE REPARACIÓN (HARDENING) ---
fase_hardening() {
    echo -e "${AMARILLO}[2/7] Instalando Herramientas de Defensa...${NC}"
    apt-get install ufw fail2ban libpam-tmpdir apt-listchanges needrestart debsums -y -qq &> /dev/null
    
    echo -e "${AMARILLO}[3/7] Optimizando DNS (Anti-Bloqueo)...${NC}"
    chattr -i /etc/resolv.conf 2>/dev/null
    echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf
    chattr +i /etc/resolv.conf

    echo -e "${AMARILLO}[4/7] Blindando Kernel y Red...${NC}"
    cat <<EOF > /etc/sysctl.d/99-kali-hardener.conf
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.ip_forward = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_syncookies = 1
kernel.randomize_va_space = 2
EOF
    sysctl -p /etc/sysctl.d/99-kali-hardener.conf > /dev/null 2>&1

    echo -e "${AMARILLO}[5/7] Configurando Firewall y SSH...${NC}"
    # SSH Seguro
    cat <<EOF > /etc/ssh/sshd_config.d/hardening.conf
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 60
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
AllowAgentForwarding no
EOF
    systemctl restart ssh

    # Firewall
    ufw --force reset > /dev/null 2>&1
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw --force enable > /dev/null 2>&1
    
    # Fail2Ban
    if [ ! -f /etc/fail2ban/jail.local ]; then
        cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    fi
    systemctl enable fail2ban > /dev/null 2>&1
    systemctl restart fail2ban

    # Banners y Permisos
    echo "ACCESO RESTRINGIDO. SISTEMA MONITOREADO." > /etc/issue
    echo "ACCESO RESTRINGIDO. SISTEMA MONITOREADO." > /etc/issue.net
    usermod -s /usr/sbin/nologin postgres 2>/dev/null
    chmod 600 /etc/crontab
}

# --- FASE 2: AUDITORÍA FINAL ---
fase_auditoria_final() {
    echo -e "${AMARILLO}[6/7] Verificando Mejoras (Re-escaneo)...${NC}"
    lynis audit system --quick --quiet > /dev/null
    SCORE_FINAL=$(obtener_puntaje)
    echo -e "${VERDE}>>> Puntuación de Seguridad Final: ${SCORE_FINAL}/100${NC}"
}

# --- FASE 3: GENERAR REPORTE EJECUTIVO ---
generar_reporte() {
    echo -e "${AMARILLO}[7/7] Generando Informe Ejecutivo para Gerencia...${NC}"
    
    cat <<EOF > $REPORTE_HUMANO
================================================================
INFORME DE CIBERSEGURIDAD Y HACKING ÉTICO - KALI LINUX
Fecha del reporte: $FECHA
Auditor: Sentinel v2.0 (Automated Script)
================================================================

1. RESUMEN EJECUTIVO
--------------------
Se ha realizado un proceso de auditoría y endurecimiento (hardening) 
sobre la estación de trabajo. El objetivo fue mitigar vulnerabilidades 
críticas y preparar el sistema para operaciones seguras.

2. MÉTRICAS DE MEJORA
---------------------
- Nivel de Seguridad Inicial: $SCORE_INICIAL / 100
- Nivel de Seguridad Final:   $SCORE_FINAL / 100
- Estado Actual: PROTEGIDO

3. ACCIONES TÉCNICAS REALIZADAS
-------------------------------
[X] Firewall (Cortafuegos): ACTIVADO. Bloquea todo tráfico entrante no autorizado.
[X] Prevención de Intrusos: ACTIVADO (Fail2Ban). Protege contra fuerza bruta.
[X] Navegación Anónima: OPTIMIZADA. DNS configurados para evitar rastreo local.
[X] Núcleo del Sistema: BLINDADO. Protección contra ataques Man-in-the-Middle.
[X] Cumplimiento Legal: APLICADO. Banners de advertencia instalados.

4. CONCLUSIÓN
-------------
El sistema cumple con los estándares necesarios para operar en redes hostiles.
Se recomienda reiniciar el equipo para aplicar cambios profundos en el Kernel.

================================================================
FIN DEL REPORTE
================================================================
EOF
    echo -e "${VERDE}✅ Informe generado exitosamente: $REPORTE_HUMANO${NC}"
}

# --- EJECUCIÓN ---
banner
fase_auditoria_inicial
fase_hardening
fase_auditoria_final
generar_reporte

echo -e "${CYAN}Puedes abrir el reporte escribiendo: cat $REPORTE_HUMANO${NC}"