# SailPoint IIQ Linux Backup

PowerShell module that connects to a SailPoint IdentityIQ (IIQ) environment on Linux, downloads a specified backup (defaulting to the latest), and optionally extracts and parses its XML components.

## 🚀 Features

- Interactive environment and host selection via a secure configuration file
- SSH connection to remote Linux hosts with IdentityIQ installed
- Automatic download of the latest daily backup (or a specified date)
- Extraction of `.tar.gz` backup archive to a local folder
- Optional parsing of XML files into individual resources (Applications, Rules, etc.)

## 📁 Configuration

Place a CSV configuration file at `$HOME\Temp\` named as you prefer (default expected path is hardcoded). The file must have the following structure:

```csv
Name,Tag,Hostname,Environment,User,Backup
IdentityIQ Dev,iiq-dev,iiq-dev01.acme.local,development,spadmin,/opt/sailpoint/backup
IdentityIQ Stage,iiq-stg,iiq-stg01.acme.local,staging,spadmin,/opt/sailpoint/backup
IdentityIQ Prod,iiq-prd,iiq-prd01.acme.local,production,spadmin,/data/backups/sailpoint
```

- The **Tag** value is used to name the local extraction folder (e.g. `iiq-dev_20250519_bk` for the backup retrieved from `iiq-dev01.acme.local` in the development environment).
- **Backup** is the path where the `.tar.gz` backup resides

> ℹ️ This module assumes that the SailPoint IdentityIQ instance on the target Linux host is configured to generate daily backups in the format `yyyyMMdd_backup.tar.gz`, stored in the backup path defined in your configuration CSV.  
> Ensure the backup process is correctly in place and the file is available for the desired date.

## 🧪 Usage

### Load the module

```powershell
Import-Module SailPoint.IIQ.LinuxBackup
```

### Run the backup operation (default: today's date)

```powershell
Invoke-IIQBackup
```

### Run for a specific date

```powershell
Invoke-IIQBackup -Date 20250519
```

### Parse specific components

```powershell
Invoke-IIQBackup -Date 20250519 -Application -Rule -Workflow
```
## 📅 Selecting the Backup Date

The `-Date` parameter lets you retrieve a backup for a specific date in the format `yyyyMMdd`.
Example:

```powershell
Invoke-IIQBackup -Date 20250519
```

If not provided, the current system date is used by default.

## 🧩 Supported Switches

You can pass one or more of the following switches to parse specific XML files:

```
-Application
-AuditConfig
-AuthenticationQuestion
-Bundle
-Capability
-CorrelationConfig
-EmailTemplate
-Form
-IdentityTrigger
-PasswordPolicy
-Plugin
-Policy
-QuickLink
-RoleChangeEvent
-Rule
-Server
-SPRight
-TaskDefinition
-TaskSchedule
-UIConfig
-Workflow
```

Parsed output is written by default to a subfolder named after each component (e.g. Application, Rule, etc.) inside `$HOME\Temp\<Tag>_<Date>_bk`

## 🔐 Requirements

- PowerShell Core 7+
- SSH access to the Linux machine with IdentityIQ
- The backup file named in the format `yyyyMMdd_backup.tar.gz` for the specified date

## 📦 Installation

Once available on PowerShell Gallery:

```powershell
Install-Module SailPoint.IIQ.LinuxBackup
```

## 📘 Help

You can view cmdlet help directly in PowerShell:

```powershell
Get-Help Invoke-IIQBackup -Full
```

## 🔗 Links

- [Project Repository](https://github.com/gvnadir/sailpoint-iiq-linux-backup)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/SailPoint.IIQ.LinuxBackup)

## 📄 License

MIT License
