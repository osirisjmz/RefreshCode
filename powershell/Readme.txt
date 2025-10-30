PowerShell Automation Lab
Overview

This directory serves as a technical laboratory for the creation, testing, and maintenance of PowerShell scripts used across multiple automation and integration environments.
It acts as an internal scripting hub for developing utilities that perform installations, repairs, environment configurations, and direct executions on platforms such as UiPath Orchestrator, Power Automate, Azure, Windows, and Python environments.

Each script in this collection represents a real-world use case extracted from your automation projects—developed to improve setup efficiency, accelerate infrastructure deployment, and maintain stable environments during RPA and AI solution delivery.

The folder is not a static script repository; it is an active lab used to prototype, optimize, and validate system-level automations that can later be integrated into production frameworks or CI/CD pipelines.

Core Purpose

The PowerShell Automation Lab is designed to:

Build and test custom automation utilities for orchestrators, machines, and bots.

Automate installation, configuration, and repair processes for development and production environments.

Simplify interactions with cloud APIs, including UiPath Orchestrator and Azure endpoints.

Enable rapid recovery of Python environments, registry configurations, and service dependencies.

Serve as a toolbox for infrastructure engineers and RPA architects to execute repeatable maintenance tasks with minimal manual intervention.

This lab directly supports your work as a Solution Architect by allowing you to model repeatable automation patterns before formalizing them into pipelines or production scripts.

Structure Overview
/powershell/Orchestrator

Scripts dedicated to automation and maintenance of UiPath Orchestrator components and environments.

File	Function
AltaBots/Check-Or-Create-Folder.ps1	Verifies and creates Orchestrator folders dynamically.
AltaBots/Check-Or-Create-MachineTemplate.ps1	Creates machine templates automatically if missing.
AltaBots/Check-Or-Create-RobotAccount.ps1	Registers new robot accounts in unattended or attended mode.
MainSetup.ps1	Initializes and validates all Orchestrator connection parameters.
CreateMachine.ps1	Creates a machine entity in Orchestrator.
CreateRobot.ps1	Registers robot instances tied to a specific machine.
GetMachines.ps1, GetRobots.ps1, GetUsers.ps1	Retrieve existing Orchestrator resources for validation or audit.
Get_List_Robots.ps1	Returns an indexed list of all robots and their assigned folders.
machine_validation_id.ps1	Confirms machine-to-robot ID mapping before deployment.
testapips.ps1 / testuniversalqueue.ps1	Validates REST API endpoints and queue connectivity.
upload_queue_items_orchestrator.ps1	Uploads and updates transaction queues directly via Orchestrator API.
Validate-MachineVisibilityInFolder.ps1	Ensures that machines are properly assigned to active folders.
Test_UiPathAPI_20250412_091432.ps1	Test harness for UiPath Cloud API validation.

Usage:
These scripts are used to automate repetitive tasks such as environment provisioning, queue setup, and Orchestrator API testing — removing the need for manual configuration through the web interface.

/powershell/Python

Scripts designed to automate installation, cleanup, and repair of Python environments used in RPA and AI projects.

File	Function
CleanInstallation.ps1	Performs a clean uninstall and reinstallation of Python, resetting PATH variables.
removepython310.ps1	Removes outdated Python 3.10 installations safely.
SetupPython390.ps1	Installs Python 3.9 with system-wide availability and pip preconfiguration.
RepairOsirisEnvironment.ps1	Repairs your local environment by restoring Python, pip, and registry values.
repaipippython.ps1	Reinstalls and validates pip modules, ensuring full dependency functionality.
reparacion_permisos_folder.ps1	Restores permissions on system folders affecting Python or RPA paths.
RestoreUserWithoutReboot.ps1	Applies user configuration and registry recovery without requiring a reboot.

Usage:
Used to maintain clean and reproducible Python environments for UiPath integrations, Power Automate connectors, and AI model execution, ensuring full compatibility between automation platforms and development tools.

Broader Purpose of the Lab

This PowerShell Lab has evolved into a cross-platform automation workspace.
It includes utilities not limited to RPA infrastructure but extending to general IT automation, including:

System Diagnostics & Recovery

Detects and fixes broken paths, registry corruption, or dependency failures.

Restores critical environment variables and permissions.

Environment Provisioning

Automates the creation of folders, users, machines, and configurations.

Synchronizes system-level and cloud-level assets (e.g., Drive, Orchestrator).

API and Service Testing

Uses custom PowerShell REST calls for validating Orchestrator, Azure, or custom APIs.

Facilitates debugging and auditing of automation integrations.

Infrastructure Templates

Acts as a foundation for reusable scripts in enterprise CI/CD deployments.

Simplifies developer onboarding by replicating environment setup steps automatically.

Technologies Used
Category	Technologies / Tools
Core Platform	Windows PowerShell 5.1+
RPA Integration	UiPath Orchestrator REST API
Cloud Services	Azure REST APIs, Google Drive API
Environment Setup	Python 3.9 / 3.10, .NET 4.8+, WinRM
Scripting Utilities	Invoke-RestMethod, Invoke-WebRequest, ScheduledTasks, PSReadLine
Example Scenarios
Example 1 — Automating Orchestrator Setup
cd .\powershell\Orchestrator\
.\MainSetup.ps1


This initializes the connection, validates machine templates, and deploys robots automatically.

Example 2 — Repairing Python Environment
cd .\powershell\Python\
.\RepairOsirisEnvironment.ps1


Executes a full environment recovery, reinstalls Python, resets permissions, and confirms pip integrity.

Example 3 — Uploading Queue Items to Orchestrator
.\upload_queue_items_orchestrator.ps1


Uploads JSON-defined queue transactions directly to UiPath Orchestrator using API calls.

Integration Context

These scripts are used actively across your automation ecosystem:

UiPath Projects (BTS, TECO, SCM): Used to initialize environments before deployment.

Power Automate Flows: Executed for environment validation and repair.

Omnix Studio Experiments: Tested as reusable modules for system orchestration.

RefreshCode Framework: Integrated into your lab for environment bootstrap and diagnostics.

Future Enhancements

Convert scripts into a modular PowerShell module (psm1) for easier import.

Add centralized logging to Dataverse or Azure Application Insights.

Integrate dependency checks for Python and Orchestrator APIs.

Automate deployment of new Orchestrator tenants and machine groups.

Implement Git-based version control and self-update functionality.

Author

Developed and maintained by Osiris Jiménez
Part of the RefreshCode Technical Lab, focused on building intelligent automation, infrastructure provisioning, and AI integration tools through PowerShell experimentation.
