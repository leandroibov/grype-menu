#!/bin/bash

# ============================================================
# SCRIPT: grype-menu
# DESCRIPTION: Interactive menu to manage and execute Grype
# Filter in relatories kev, kev all, kernel, epss, high, critical
# ============================================================

#added filtered relatories in option 7 to help filter KEV, epss etc...
#        https://github.com/anchore/grype/issues/1511
#        https://github.com/anchore/grype/issues/1973



# Colors for better visualization
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'           # No Color

# MAIN FILE TO REPORTS
touch /tmp/GRYPE-REPORT.TXT
chmod ug=rwx /tmp/GRYPE-REPORT.TXT
INPUT_FILE="/tmp/GRYPE-REPORT.TXT"
# Cache file for version check
VERSION_CACHE="/tmp/grype_version_cache"
CACHE_TTL=3600  # 1 hour in seconds

# ============================================================
# COMPLEMENTARY FUNCTIONS
# ============================================================

kev_all()
{
OUTPUT_FILE="/tmp/KEV-ALL-GRYPE.TXT"
touch /tmp/KEV-ALL-GRYPE.TXT
chmod ug=rwx /tmp/KEV-ALL-GRYPE.TXT

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "ERROR: File $INPUT_FILE not found!"
    echo "Please run: grype dir:/ > GRYPE-REPORT.TXT"
    exit 1
fi

# Create header
echo "═══════════════════════════════════════════════════════════════════════════════" > "$OUTPUT_FILE"
echo "              ALL KNOWN EXPLOITED VULNERABILITIES (KEV) REPORT               " >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "This report lists ALL Known Exploited Vulnerabilities (KEV) from the CISA catalog." >> "$OUTPUT_FILE"
echo "KEV vulnerabilities are actively being exploited in the wild and represent" >> "$OUTPUT_FILE"
echo "the highest immediate risk to your systems." >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "📌 INCLUDES ALL TYPES:" >> "$OUTPUT_FILE"
echo "  - Linux Kernel vulnerabilities" >> "$OUTPUT_FILE"
echo "  - Java libraries (SnakeYAML, Commons-Compress, etc.)" >> "$OUTPUT_FILE"
echo "  - Ruby gems (Nokogiri, Bundler, etc.)" >> "$OUTPUT_FILE"
echo "  - Go modules" >> "$OUTPUT_FILE"
echo "  - Python packages" >> "$OUTPUT_FILE"
echo "  - Applications and services" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Why KEV matters:" >> "$OUTPUT_FILE"
echo "  - Actively exploited by threat actors" >> "$OUTPUT_FILE"
echo "  - Often used in ransomware and data breach campaigns" >> "$OUTPUT_FILE"
echo "  - CISA requires federal agencies to patch within specific timeframes" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "🚨 CRITICAL - ALL KEVs MUST be fixed IMMEDIATELY (within 48-72 hours)" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Filter for ALL KEV (lines containing "(kev)")
grep -i "(kev)" "$INPUT_FILE" >> "$OUTPUT_FILE" 2>/dev/null

# Add summary by type
echo "" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "                          SUMMARY BY TYPE                                      " >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Count KEVs by type
echo "KERNEL KEVs:" >> "$OUTPUT_FILE"
grep -i "(kev)" "$INPUT_FILE" | grep -i "linux-kernel" | wc -l >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "JAVA KEVs:" >> "$OUTPUT_FILE"
grep -i "(kev)" "$INPUT_FILE" | grep -i "java-archive" | wc -l >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "RUBY GEMS KEVs:" >> "$OUTPUT_FILE"
grep -i "(kev)" "$INPUT_FILE" | grep -i "gem" | wc -l >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "GO MODULES KEVs:" >> "$OUTPUT_FILE"
grep -i "(kev)" "$INPUT_FILE" | grep -i "go-module" | wc -l >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "PYTHON KEVs:" >> "$OUTPUT_FILE"
grep -i "(kev)" "$INPUT_FILE" | grep -i "python" | wc -l >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "OTHER KEVs:" >> "$OUTPUT_FILE"
grep -i "(kev)" "$INPUT_FILE" | grep -v -E "linux-kernel|java-archive|gem|go-module|python" | wc -l >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "Report generated: $(date)" >> "$OUTPUT_FILE"
echo "Total ALL KEV vulnerabilities: $(grep -i "(kev)" "$INPUT_FILE" | wc -l)" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"

echo "✅ ALL KEV report saved to: $OUTPUT_FILE"
echo "Total ALL KEV vulnerabilities: $(grep -i "(kev)" "$INPUT_FILE" | wc -l)"

}

kev()
{
OUTPUT_FILE="/tmp/KEV-GRYPE.TXT"
touch /tmp/KEV-GRYPE.TXT
chmod ug=rwx /tmp/KEV-GRYPE.TXT

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "ERROR: File $INPUT_FILE not found!"
    echo "Please run: grype dir:/ > GRYPE-REPORT.TXT"
    exit 1
fi

# Create header
echo "═══════════════════════════════════════════════════════════════════════════════" > "$OUTPUT_FILE"
echo "                    KEV (KNOWN EXPLOITED VULNERABILITIES) REPORT              " >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "This report lists Known Exploited Vulnerabilities (KEV) from the CISA catalog." >> "$OUTPUT_FILE"
echo "KEV vulnerabilities are actively being exploited in the wild and represent" >> "$OUTPUT_FILE"
echo "the highest immediate risk to your systems." >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Why KEV matters:" >> "$OUTPUT_FILE"
echo "  - Actively exploited by threat actors" >> "$OUTPUT_FILE"
echo "  - Often used in ransomware and data breach campaigns" >> "$OUTPUT_FILE"
echo "  - CISA requires federal agencies to patch within specific timeframes" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "🚨 CRITICAL - These MUST be fixed IMMEDIATELY (within 48-72 hours)" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Filter for KEV (lines containing "(kev)")
grep -i "(kev)" "$INPUT_FILE" >> "$OUTPUT_FILE" 2>/dev/null

echo "" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "Report generated: $(date)" >> "$OUTPUT_FILE"
echo "Total KEV vulnerabilities: $(grep -i "(kev)" "$INPUT_FILE" | wc -l)" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"

echo "✅ KEV report saved to: $OUTPUT_FILE"
echo "Total KEV vulnerabilities: $(grep -i "(kev)" "$INPUT_FILE" | wc -l)"
}

kernel()
{
OUTPUT_FILE="/tmp/KERNEL-GRYPE.TXT"
touch /tmp/KERNEL-GRYPE.TXT
chmod ug=rwx /tmp/KERNEL-GRYPE.TXT

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "ERROR: File $INPUT_FILE not found!"
    echo "Please run: grype dir:/ > GRYPE-REPORT.TXT"
    exit 1
fi

# Create header
echo "═══════════════════════════════════════════════════════════════════════════════" > "$OUTPUT_FILE"
echo "                    LINUX KERNEL VULNERABILITIES REPORT                       " >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "This report lists all Linux kernel vulnerabilities found during the scan." >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "⚠️  IMPORTANT: Kernel vulnerabilities are EXTREMELY CRITICAL because:" >> "$OUTPUT_FILE"
echo "  - The kernel runs at the highest privilege level (ring 0)" >> "$OUTPUT_FILE"
echo "  - Exploitation often leads to full system compromise (root access)" >> "$OUTPUT_FILE"
echo "  - Can affect all users and processes on the system" >> "$OUTPUT_FILE"
echo "  - May be used to bypass security controls and hide malicious activity" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "🚨 CRITICAL - Kernel vulnerabilities should be patched IMMEDIATELY" >> "$OUTPUT_FILE"
echo "   Kernel updates often require a system reboot to take effect" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Filter for kernel vulnerabilities
grep -i "linux-kernel" "$INPUT_FILE" >> "$OUTPUT_FILE" 2>/dev/null

echo "" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "Report generated: $(date)" >> "$OUTPUT_FILE"
echo "Total kernel vulnerabilities: $(grep -i "linux-kernel" "$INPUT_FILE" | wc -l)" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"

echo "✅ Kernel vulnerabilities report saved to: $OUTPUT_FILE"
echo "Total kernel vulnerabilities: $(grep -i "linux-kernel" "$INPUT_FILE" | wc -l)"
}

high()
{
OUTPUT_FILE="/tmp/HIGH-GRYPE.TXT"
touch /tmp/HIGH-GRYPE.TXT
chmod ug=rwx /tmp/HIGH-GRYPE.TXT

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "ERROR: File $INPUT_FILE not found!"
    echo "Please run: grype dir:/ > GRYPE-REPORT.TXT"
    exit 1
fi

# Create header
echo "═══════════════════════════════════════════════════════════════════════════════" > "$OUTPUT_FILE"
echo "                    HIGH SEVERITY VULNERABILITIES REPORT                      " >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "This report lists all vulnerabilities with HIGH severity from the Grype scan." >> "$OUTPUT_FILE"
echo "HIGH severity vulnerabilities represent serious security risks that should" >> "$OUTPUT_FILE"
echo "be prioritized for remediation. These vulnerabilities often lead to:" >> "$OUTPUT_FILE"
echo "  - Remote code execution" >> "$OUTPUT_FILE"
echo "  - Privilege escalation" >> "$OUTPUT_FILE"
echo "  - Data breach or information disclosure" >> "$OUTPUT_FILE"
echo "  - Denial of service" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Priority: HIGH - Should be fixed within 7-14 days" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Filter for HIGH severity
grep -i "High" "$INPUT_FILE" | grep -v "Critical" >> "$OUTPUT_FILE" 2>/dev/null

echo "" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "Report generated: $(date)" >> "$OUTPUT_FILE"
echo "Total HIGH vulnerabilities: $(grep -i "High" "$INPUT_FILE" | grep -v "Critical" | wc -l)" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"

echo "✅ HIGH severity report saved to: $OUTPUT_FILE"
echo "Total HIGH vulnerabilities: $(grep -i "High" "$INPUT_FILE" | grep -v "Critical" | wc -l)"
}

epss()
{
OUTPUT_FILE="/tmp/EPSS-GRYPE.TXT"
touch /tmp/EPSS-GRYPE.TXT
chmod ug=rwx /tmp/EPSS-GRYPE.TXT
EPSS_THRESHOLD="50"  # Minimum EPSS percentage to include

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "ERROR: File $INPUT_FILE not found!"
    echo "Please run: grype dir:/ > GRYPE-REPORT.TXT"
    exit 1
fi

# Create header
echo "═══════════════════════════════════════════════════════════════════════════════" > "$OUTPUT_FILE"
echo "                    HIGH EPSS SCORE VULNERABILITIES REPORT                    " >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "This report lists vulnerabilities with high EPSS (Exploit Prediction)" >> "$OUTPUT_FILE"
echo "Scoring System scores. EPSS estimates the probability that a vulnerability" >> "$OUTPUT_FILE"
echo "will be exploited in the wild within the next 30 days." >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "EPSS Score Interpretation:" >> "$OUTPUT_FILE"
echo "  - > 90%: Critical - Almost certainly will be exploited" >> "$OUTPUT_FILE"
echo "  - 70-90%: High - Very likely to be exploited" >> "$OUTPUT_FILE"
echo "  - 50-70%: Medium - Moderate chance of exploitation" >> "$OUTPUT_FILE"
echo "  - < 50%: Low - Lower chance of exploitation" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Threshold: EPSS > ${EPSS_THRESHOLD}%" >> "$OUTPUT_FILE"
echo "Priority: HIGH - Vulnerabilities with high EPSS should be fixed immediately" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Filter for EPSS > threshold (extract lines with EPSS numbers)
# EPSS format: "96.8% (99th)" - we extract the number before %
grep -E "[0-9]+\.[0-9]+% \([0-9]+th\)" "$INPUT_FILE" | while read -r line; do
    epss=$(echo "$line" | grep -oE '[0-9]+\.[0-9]+%' | head -1 | sed 's/%//')
    if [[ -n "$epss" ]] && (( $(echo "$epss > $EPSS_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        echo "$line" >> "$OUTPUT_FILE"
    fi
done

echo "" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
echo "Report generated: $(date)" >> "$OUTPUT_FILE"
echo "Total vulnerabilities with EPSS > ${EPSS_THRESHOLD}%: $(grep -E "[0-9]+\.[0-9]+% \([0-9]+th\)" "$INPUT_FILE" | wc -l)" >> "$OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"

echo "✅ High EPSS report saved to: $OUTPUT_FILE"
echo "Total vulnerabilities with EPSS > ${EPSS_THRESHOLD}%: $(grep -E "[0-9]+\.[0-9]+% \([0-9]+th\)" "$INPUT_FILE" | wc -l)"
}


all_reports()
{
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}        Filtered Grype Report               ${NC}"
    echo -e "${CYAN} kev, all kevs, kernel, epss, High          ${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
kev
kev_all
high
epss
kernel
echo "All Reports Generated!"
echo "See /tmp Directory"
}

# ============================================================
# MAIN FUNCTIONS
# ============================================================

# Function to print header
print_header() {
    clear
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}        GRYPE MENU - OFFLINE SCAN         ${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
}

# Function to check Grype version
check_grype_version() {
    if ! command -v grype &> /dev/null; then
        echo "NOT_INSTALLED"
        return 0
    fi
    
    # Get current version from grype command
    local grype_output=$(grype version 2>/dev/null | head -n1)
    local current_version=$(echo "$grype_output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    # If version not found, try dpkg
    if [ -z "$current_version" ]; then
        current_version=$(dpkg -l grype 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    fi
    
    if [ -z "$current_version" ]; then
        echo "UNKNOWN:$grype_output"
        return 1
    fi
    
    # Check cache for latest version
    local latest_version=""
    local use_cache=false
    if [ -f "$VERSION_CACHE" ]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$VERSION_CACHE" 2>/dev/null || stat -f %m "$VERSION_CACHE" 2>/dev/null)))
        if [ "$cache_age" -lt "$CACHE_TTL" ]; then
            use_cache=true
        fi
    fi
    
    if [ "$use_cache" = true ]; then
        latest_version=$(cat "$VERSION_CACHE")
    else
        latest_version=$(curl -s https://api.github.com/repos/anchore/grype/releases/latest \
            | grep -oP '"tag_name":\s*"\K[^"]+' 2>/dev/null | sed 's/^v//')
        if [ -n "$latest_version" ]; then
            echo "$latest_version" > "$VERSION_CACHE"
        fi
    fi
    
    if [ -z "$latest_version" ]; then
        echo "ERROR"
        return 1
    fi
    
    # Compare versions
    if [ "$current_version" = "$latest_version" ]; then
        echo "UPDATED:$current_version"
        return 0
    else
        echo "UPDATE_AVAILABLE:$current_version->$latest_version"
        return 1
    fi
}

# ============================================================
# SHA256 FUNCTIONS
# ============================================================

# Function to calculate SHA256 of a file
calculate_sha256() {
    local file="$1"
    if [ -f "$file" ]; then
        sha256sum "$file" | awk '{print $1}'
    else
        echo ""
    fi
}

# Function to show SHA256 and ask for confirmation
verify_and_confirm_sha256() {
    local file="$1"
    local file_name="$2"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ File not found: $file${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}▶ Calculating SHA256 checksum...${NC}"
    local file_hash=$(calculate_sha256 "$file")
    
    if [ -z "$file_hash" ]; then
        echo -e "${RED}✗ Failed to calculate SHA256${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│  SHA256 of ${file_name}:${NC}"
    echo -e "${WHITE}│  ${GREEN}$file_hash${NC}"
    echo -e "${WHITE}└─────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    read -p "Do you want to continue with the installation? [Y/n]: " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}⚠ Installation cancelled by user${NC}"
        return 1
    fi
    
    return 0
}

# ============================================================
# INSTALLATION FUNCTIONS
# ============================================================

# Function to install Grype
install_grype() {
    echo -e "${CYAN}▶ Installing/Updating Grype...${NC}"
    
    # Get the latest version number
    echo -e "${YELLOW}▶ Fetching latest version...${NC}"
    local latest_version=$(curl -s https://api.github.com/repos/anchore/grype/releases/latest \
        | grep -oP '"tag_name":\s*"\K[^"]+' 2>/dev/null | sed 's/^v//')
    
    if [ -z "$latest_version" ]; then
        echo -e "${RED}✗ Failed to get latest version${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}▶ Latest version: $latest_version${NC}"
    
    # Construct the correct download URL for the .deb package
    local download_url="https://github.com/anchore/grype/releases/download/v${latest_version}/grype_${latest_version}_linux_amd64.deb"
    
    echo -e "${YELLOW}▶ Downloading from: $download_url${NC}"
    echo -e "${YELLOW}▶ Clique here to manual check the hash from .deb https://github.com/anchore/grype/releases/${NC}"

    
    # Download with -L to follow redirects
    curl -L -o /tmp/grype_latest.deb "$download_url" --progress-bar
    
    # Check if download was successful and file is valid
    if [ ! -f "/tmp/grype_latest.deb" ]; then
        echo -e "${RED}✗ Download failed - file not created${NC}"
        return 1
    fi
    
    # Verify it's a valid deb package
    if ! file /tmp/grype_latest.deb | grep -q "Debian binary package"; then
        echo -e "${RED}✗ Downloaded file is not a valid Debian package${NC}"
        echo -e "${YELLOW}File type: $(file /tmp/grype_latest.deb)${NC}"
        rm -f /tmp/grype_latest.deb
        return 1
    fi
    
    # Get file size for verification
    local file_size=$(stat -c%s /tmp/grype_latest.deb 2>/dev/null || stat -f%z /tmp/grype_latest.deb 2>/dev/null)
    if [ "$file_size" -lt 1000000 ]; then
        echo -e "${RED}✗ Downloaded file is too small ($file_size bytes) - probably invalid${NC}"
        rm -f /tmp/grype_latest.deb
        return 1
    fi
    
    # SHA256 CHECK
    if ! verify_and_confirm_sha256 "/tmp/grype_latest.deb" "grype_${latest_version}_linux_amd64.deb"; then
        rm -f /tmp/grype_latest.deb
        return 1
    fi
    
    # Install
    echo -e "${YELLOW}▶ Installing... (sudo required)${NC}"
    sudo dpkg -i /tmp/grype_latest.deb 2>/tmp/dpkg_error.log
    
    # Fix dependencies if needed
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}⚠ Fixing dependencies...${NC}"
        sudo apt-get install -f -y
        sudo dpkg -i /tmp/grype_latest.deb
    fi
    
    # Cleanup
    rm -f /tmp/grype_latest.deb
    
    # Verify installation
    if command -v grype &> /dev/null; then
        local installed_version=$(grype version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        echo -e "${GREEN}✓ Grype installed successfully!${NC}"
        echo -e "${GREEN}✓ Version: $installed_version${NC}"
        
        # Update database automatically after installation
        echo -e "${YELLOW}▶ Updating vulnerability database...${NC}"
        grype db update
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Database updated successfully!${NC}"
        else
            echo -e "${YELLOW}⚠ Database update failed. You can try again with option 2.${NC}"
        fi
        
        return 0
    else
        echo -e "${RED}✗ Installation failed${NC}"
        if [ -f /tmp/dpkg_error.log ]; then
            echo -e "${YELLOW}Error details:${NC}"
            cat /tmp/dpkg_error.log
            rm -f /tmp/dpkg_error.log
        fi
        return 1
    fi
}

# Function to update Grype database
update_grype_db() {
    echo -e "${CYAN}▶ Updating Grype vulnerability database...${NC}"
    
    # Check if Grype is installed
    if ! command -v grype &> /dev/null; then
        echo -e "${RED}✗ Grype is not installed. Please install first.${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}▶ Running: grype db update${NC}"
    grype db update
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Database updated successfully!${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to update database.${NC}"
        return 1
    fi
}

# Function to show scan examples
show_examples() {
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}          SCAN COMMAND EXAMPLES             ${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
    echo -e "${YELLOW}Example 1 - Scan entire root directory:${NC}"
    echo -e "  ${GREEN}grype dir:/ > $INPUT_FILE${NC}"
    echo ""
    echo -e "${YELLOW}Example 2 - Scan home directory:${NC}"
    echo -e "  ${GREEN}grype dir:/home > $INPUT_FILE${NC}"
    echo ""
    echo -e "${YELLOW}Example 3 - Scan specific directory:${NC}"
    echo -e "  ${GREEN}grype dir:/path/to/directory${NC}"
    echo ""
    echo -e "${YELLOW}Example 4 - Scan with JSON output:${NC}"
    echo -e "  ${GREEN}grype dir:/ -o json > grype-report.json${NC}"
    echo ""
    echo -e "${YELLOW}Example 5 - Scan with only critical vulnerabilities:${NC}"
    echo -e "  ${GREEN}grype dir:/ --fail-on critical --only-fixed > $INPUT_FILE${NC}"
    echo ""
    echo -e "${YELLOW}Example 6 - Scan and fail on high severity (useful for CI):${NC}"
    echo -e "  ${GREEN}grype dir:/ --fail-on high${NC}"
    echo ""
    echo -e "${CYAN}============================================${NC}"
}

# Function to run custom scan
run_custom_scan() {
    echo -e "${CYAN}▶ Warning: Option 7 only works if the scan output is saved as $INPUT_FILE!${NC}"
    echo -e "${CYAN}▶ Enter your custom Grype scan command:${NC}"
    echo -e "${YELLOW}  Example: grype dir:/${NC}"
    echo -e "${YELLOW}  Example with output file: grype dir:/ > $OUTPUT_FILE${NC}"
    echo ""
    read -p "Command: " user_command
    
    if [ -z "$user_command" ]; then
        echo -e "${RED}✗ No command entered.${NC}"
        return
    fi
    
    # Check if command contains grype
    if [[ ! "$user_command" =~ ^grype ]]; then
        echo -e "${YELLOW}⚠ Command doesn't start with 'grype'. Adding automatically...${NC}"
        user_command="grype $user_command"
    fi
    
    echo -e "${CYAN}▶ Executing: ${GREEN}$user_command${NC}"
    echo -e "${YELLOW}Press Ctrl+C to cancel...${NC}"
    sleep 2
    
    echo ""
    eval "$user_command"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Scan completed successfully!${NC}"
    else
        echo -e "${RED}✗ Scan failed with error code: $?${NC}"
    fi
}

# Function to run quick scan
run_quick_scan() {
    echo -e "${CYAN}▶ QUICK SCAN OPTIONS:${NC}"
    echo -e "  ${GREEN}1${NC}) Scan / (root directory)"
    echo -e "  ${GREEN}2${NC}) Scan /home"
    echo -e "  ${GREEN}3${NC}) Scan / (Critical only)"
    echo -e "  ${GREEN}4${NC}) Scan current directory"
    echo -e "  ${GREEN}5${NC}) Custom command"
    echo ""
    read -p "Choose quick scan [1-6]: " quick_choice
    
    case $quick_choice in
        1)
            echo -e "${CYAN}▶ Running: grype dir:/ > "$INPUT_FILE"${NC}"
            grype dir:/ > "$INPUT_FILE"
            echo -e "${GREEN}✓ Report saved to: "$INPUT_FILE"${NC}"
chmod ug=rwx "$INPUT_FILE"
            ;;
        2)
            echo -e "${CYAN}▶ Running: grype dir:/home > "$INPUT_FILE"${NC}"
            grype dir:/home > "$INPUT_FILE"
            echo -e "${GREEN}✓ Report saved to: "$INPUT_FILE"${NC}"
chmod ug=rwx "$INPUT_FILE"
            ;;

        3)
            echo -e "${CYAN}▶ Running: grype dir:/ --fail-on critical --only-fixed > "$INPUT_FILE"${NC}"
            grype dir:/ --fail-on critical --only-fixed > "$INPUT_FILE"
            echo -e "${GREEN}✓ Report saved to: "$INPUT_FILE"${NC}"
chmod ug=rwx "$INPUT_FILE"
            ;;
        4)
            echo -e "${CYAN}▶ Running: grype dir:. > "$INPUT_FILE"${NC}"
            grype dir:. > "$INPUT_FILE"
            echo -e "${GREEN}✓ Report saved to: "$INPUT_FILE"${NC}"
chmod ug=rwx "$INPUT_FILE"
            ;;
        5)
            run_custom_scan
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
}

# ============================================================
# MAIN MENU
# ============================================================

main_menu() {
    while true; do
        print_header
        
        # Check and manage Grype
        local grype_status=$(check_grype_version)
        
        echo -e "${WHITE}▶ GRYPE STATUS:${NC}"
        case "$grype_status" in
            NOT_INSTALLED)
                echo -e "  ${RED}✗ Grype is not installed${NC}"
                read -p "  Do you want to install Grype? [Y/n]: " install_choice
                if [[ "$install_choice" != "n" ]]; then
                    install_grype
                fi
                ;;
            UPDATED:*)
                local version=${grype_status#UPDATED:}
                echo -e "  ${GREEN}✓ Grype is up to date! (v$version)${NC}"
                ;;
            UPDATE_AVAILABLE:*)
                local versions=${grype_status#UPDATE_AVAILABLE:}
                local current=${versions%->*}
                local latest=${versions#*->}
                echo -e "  ${YELLOW}⚠ Update available: v$current → v$latest${NC}"
                read -p "  Do you want to update? [y/N]: " update_choice
                if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                    install_grype
                fi
                ;;
            UNKNOWN:*)
                local message=${grype_status#UNKNOWN:}
                echo -e "  ${YELLOW}⚠ Grype is installed but version detection failed${NC}"
                echo -e "  ${YELLOW}   Output: $message${NC}"
                echo -e "  ${YELLOW}   Try reinstalling with option 1${NC}"
                ;;
            ERROR)
                echo -e "  ${RED}✗ Failed to check version. Network issue?${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${CYAN}============================================${NC}"
        echo -e "${WHITE}Available options:${NC}"
        echo -e "  ${GREEN}1${NC}) Install/Update Grype"
        echo -e "  ${GREEN}2${NC}) Update Grype Database"
        echo -e "  ${GREEN}3${NC}) Show scan command examples"
        echo -e "  ${GREEN}4${NC}) Run custom scan command"
        echo -e "  ${GREEN}5${NC}) Run quick scan (pre-defined)"
        echo -e "  ${GREEN}6${NC}) Show versions and status"
        echo -e "  ${GREEN}7${NC}) Report Filtered for KEV, EPSS, HIGH, KERNEL"
        echo -e "  ${GREEN}8${NC}) Exit"
        echo ""
        read -p "Choose an option [1-7]: " choice
        
        case $choice in
            1)
                echo ""
                install_grype
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                echo ""
                update_grype_db
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                echo ""
                show_examples
                read -p "Press Enter to continue..."
                ;;
            4)
                echo ""
                run_custom_scan
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                echo ""
                run_quick_scan
                echo ""
                read -p "Press Enter to continue..."
                ;;
            6)
                echo ""
                echo -e "${WHITE}▶ VERSIONS AND STATUS:${NC}"
                echo -e "  ${WHITE}Grype:${NC}"
                if command -v grype &> /dev/null; then
                    echo -e "    ${GREEN}$(grype version | head -n1)${NC}"
                else
                    echo -e "    ${RED}Not installed${NC}"
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            7)
                echo ""
                all_reports
                echo ""
                read -p "Press Enter to continue..."
                ;;
            8)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please choose 1-7.${NC}"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# START SCRIPT
# ============================================================

main_menu


