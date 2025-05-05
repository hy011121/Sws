![f851b65c6bd57b0f66dd12f31e26123507cb18da_hq](https://github.com/user-attachments/assets/e2414aac-d753-4a4c-8e18-6bf813b5b0a3)

# **SWS - WebShell Scanner**  
**A PowerShell tool to detect webshells in mass domains.** 
SWS is a simple yet powerful tool used to detect webshell files in bulk across multiple domains. This tool is designed to help administrators, security researchers, and IT teams find potential compromises on websites, especially those using CMS such as WordPress, Joomla, and others. Using a combination of hundreds of common paths and popular shell file names, this tool automatically builds thousands of target URLs and examines server responses to identify suspicious files.

---

## **How It Works?**  

### **Version 1: Signature Scanner**  
Scans websites for common webshell patterns like `eval(base64_decode())`, `system()`, and known malicious filenames (`c99.php`, `r57.php`). Exports results in CSV format.  

**Usage:**  
```powershell
.\sws-v1.ps1 -DomainList targets.txt -OutputFile results.csv
```

### **Version 2: Path Brute-Forcer**  
Tests 100+ common webshell paths (e.g., `/uploads/shell.php`, `/wp-admin/cmd.php`) across multiple domains quickly. Outputs suspected URLs in a text file.  

**Usage:**  
```powershell
.\sws-v2.ps1
```

---

## **Architecture**  

### **Version 1 Flow**  
```mermaid
graph TD
    A[Domain List] --> B[URL Normalizer]
    B --> C[Content Fetcher]
    C --> D{HTTP Response}
    D -->|Success| E[Pattern Scanner]
    D -->|Error| F[Error Handler]
    E --> G[Link Extractor]
    G --> H[Extension Analyzer]
    G --> I[Filename Checker]
    H --> J[Result Aggregator]
    I --> J
    E --> J
    J --> K[CSV Generator]
    F --> K
    K --> L["webshell_scan_results.csv"]
```

### **Version 2 Flow**  
```mermaid
graph TD
    A[Domain List] --> B[URL Normalizer]
    B --> C[Path Generator]
    C --> D[URL Builder]
    D --> E{HTTP Request}
    E -->|200 OK| F[Signature Check]
    E -->|404/Timeout| G[Discard]
    F -->|WSO/R57 Pattern| H[Flag as CONFIRMED]
    F -->|Suspicious File| I[Flag as SUSPECT]
    F -->|Clean| J[Mark for Review]
    H --> K[Result Aggregator]
    I --> K
    J --> L[Review Queue]
    K --> M[Generate Report]
    L --> N[Manual Verification]
    M --> O["scan_results.txt"]
    N --> O
```
---

Only use on systems you own or have permission to scan.** Unauthorized testing may violate laws.

Contact: [https://t.me/Ox6218]  

this tool can still be developed further, i just made it simple

---
