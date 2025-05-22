# SailPoint IIQ Linux Backup

PowerShell module to connect to a SailPoint IdentityIQ (IIQ) environment on Linux, download a selected backup (defaulting to the latest), and optionally extract and parse its XML components.

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
X,hd1,host1,development,user,/home/user/backup
Y,hs2,host2,staging,user,/home/user/backup
Z,hp3,host3,production,user,/home/user/backup
```

- The **Tag** value is used to name the local extraction folder (e.g. `hd1_20250519_bk` for the backup retrieved from host1 in the development environment).
- **Backup** is the path where the `.tar.gz` backup resides

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
