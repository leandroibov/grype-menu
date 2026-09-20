

# Grype Menu - Offline Vulnerability Scanner with KEV/EPSS Filtering for Auto Penetration Testing

Interactive Bash script for managing Grype vulnerability scans and generating **prioritized filtered reports** for KEV, EPSS, HIGH severity, and Kernel vulnerabilities.

## 🚀 About This Project

This script fills a gap in the open-source vulnerability scanning ecosystem by providing **report filtering capabilities that Grype doesn't natively support via CLI commands**. While Grype DB v6 now includes KEV and EPSS data (issues #1511 and #1973), it lacks built-in filtering options for these critical prioritization signals.

### Issues Addressed

- **[anchore/grype#1511](https://github.com/anchore/grype/issues/1511)** - CISA KEV data integration
- **[anchore/grype#1973](https://github.com/anchore/grype/issues/1973)** - EPSS metrics inclusion

This script extracts and filters those datasets from Grype output to enable risk-based prioritization.

## ✨ Features

- **KEV Filtering** - Known Exploited Vulnerabilities from CISA catalog (actively exploited in the wild)
- **KEV All** - Complete KEV report with summary by type (Java, Go, Python, Ruby, Kernel)
- **EPSS Scoring** - Filter by exploit probability (>50%, >70%, >90%)
- **High Severity** - Extract HIGH severity vulnerabilities (excluding Critical)
- **Kernel Vulnerabilities** - Isolate linux-kernel CVEs (ring 0 privilege level risk)
- **Version Management** - Auto-check/update Grype with SHA256 verification
- **Offline Support** - Works in air-gapped environments after initial database download

## 📊 Report Output Structure

```
/tmp/GRYPE-REPORT.TXT     # Main scan output
/tmp/KEV-GRYPE.TXT        # Critical: Active exploitation confirmed
/tmp/KEV-ALL-GRYPE.TXT    # Extended KEV with type breakdown
/tmp/HIGH-GRYPE.TXT       # High severity (excl. Critical)
/tmp/EPSS-GRYPE.TXT       # High EPSS score vulnerabilities
/tmp/KERNEL-GRYPE.TXT     # Linux kernel CVEs
```

## 🛠️ Quick Start

```bash
# Clone or copy script
chmod +x grype-menu.sh
./grype-menu.sh
```

### Recommended Workflow

1. **Install Grype** (Option 1) - Auto-downloads latest .deb with hash verification
2. **Update Database** (Option 2) - Ensures fresh vulnerability signatures
3. **Run Scan** (Option 5) - Pre-defined targets: root, home, current directory
4. **Filter Reports** (Option 7) - Generate all prioritized reports at once

## 🔍 Prioritization Hierarchy

Based on industry best practices (CISA KEV, FIRST.org EPSS):

| Priority | Signal | SLA Recommendation |
|----------|--------|-------------------|
| **EMERGENCY** | KEV listed | 24-48 hours |
| **CRITICAL** | EPSS > 90% | Immediate |
| **HIGH** | EPSS 50-90% | 7 days |
| **MEDIUM** | High severity | 14 days |

> ℹ️ **Note:** Your filtered reports implement this exact hierarchy through Option 7.

## 🖥️ Examples

**Quick scan of entire system:**
```bash
./grype-menu.sh
# Select option 5 → Option 1
# Then select option 7 to filter
```

**Custom scan command:**
```bash
./grype-menu.sh
# Select option 4
# Enter: grype dir:/home/user/project --exclude "*.log"
```

## ⚙️ Configuration

Modify these variables at the top of the script:

```bash
INPUT_FILE="/tmp/GRYPE-REPORT.TXT"      # Main scan output
VERSION_CACHE="/tmp/grype_version_cache"  # Update check cache
CACHE_TTL=3600                           # Cache validity (seconds)
EPSS_THRESHOLD="50"                      # EPSS cutoff percentage
```

## 📁 Dependencies

- bash (≥4.0)
- curl
- grep
- bc (for EPSS calculation)
- sudo (for installation)
- stat (file metadata)

## 🐧 Tested On

- Debian 13 (Trixie)
- Ubuntu 22.04 LTS
- Qubes OS templates
- Other Debian/Ubuntu derivatives

## 🔒 Security Features

- SHA256 verification during Grype installation
- Manual hash confirmation prompt before install
- Cache TTL prevents excessive GitHub API calls
- Files created with controlled permissions (ug=rwx)

## 📝 License

MIT License - Feel free to use, modify, and distribute.

## 🤝 Contributing

Contributions welcome! Especially:

- Additional filter types (CVE ranges, vendor-specific)
- JSON output integration (`-o json` parsing)
- Report aggregation (single consolidated file)
- Persistent storage (move from `/tmp` to user directory)

## 📚 References

- [CISA Known Exploited Vulnerabilities Catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog)
- [FIRST.org EPSS](https://www.first.org/epss/)
- [Grype Documentation](https://github.com/anchore/grype)
- [Anchore Security Research](https://anchore.com/)

---

**Made with ❤️ for security practitioners who need actionable vulnerability intelligence.**

---

# Doe monero para nos ajudar: (donate XMR)

    87JGuuwXzoMGwQAcSD7cvS7D7iacPpN2f5bVqETbUvCgdEmrPZa12gh5DSiKKRgdU7c5n5x1UvZLj8PQ7AAJSso5CQxgjak

Página oficial de segurança digital:

https://traderprofissional.com.br/seguranca-digital.aspx

---
