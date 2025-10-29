RH_Automatizado
Overview

RH_Automatizado is an advanced automation framework designed to streamline and manage Human Resources (HR) workflows.
It combines multiple service layers—data management, scheduling, AI integration, and communication channels—to automate repetitive HR operations such as candidate tracking, report generation, and multi-channel notifications.

This module belongs to the RefreshCode Technical Lab, serving as a testing and development environment for applied automation, integration, and AI-enhanced workflows.

Architecture

The project follows a modular architecture divided into three main layers: core, services, and storage.

1. Core Layer

Handles execution control, validation, AI operations, and reporting logic.

File	Description
drive_connector.py	Connects and synchronizes files between local and cloud storage (Google Drive or equivalent).
logger.py	Centralized logging handler for debugging, auditing, and execution tracking.
openai_engine.py	Manages AI-based text generation, summarization, and classification tasks using OpenAI API.
report_builder.py	Generates and compiles HR reports automatically using Excel or CSV templates.
scheduler.py	Controls periodic or event-based task execution.
validator.py	Validates input data and checks structural integrity across HR datasets.
2. Services Layer

Implements communication and data services used by the core system.

File	Description
email_service.py	Sends and receives HR-related emails using SMTP or Outlook integration.
excel_service.py	Reads, writes, and formats Excel-based HR records.
json_service.py	Loads and saves JSON configurations, candidate queues, and job definitions.
logs_service.py	Handles creation and archival of log files for audit purposes.
notifier.py	Triggers alerts and messages for key automation events.
whatsapp_apy.py	Integrates with WhatsApp API to send automated notifications to candidates or managers.
3. Storage Layer

Holds configuration, templates, and operational artifacts generated during automation runs.

Folder	Description
Archivos_Json/	JSON templates and job definitions (e.g., vacante_modelo.json).
Evidencias/	Folder for document validation and evidence storage.
Excels/	Contains base Excel templates (candidates, presentations, reports).
Imagenes/	Visual assets and evidence attachments.
Logs/	Operation logs, execution history, and error reports.
Purpose

The goal of RH_Automatizado is to build a self-sufficient, configurable automation framework that centralizes HR operations by combining:

Data processing and validation

Document and report generation

AI-based text analysis using OpenAI

Integration with email and messaging APIs

Task scheduling and error management

This approach reduces manual work, improves consistency in communications, and ensures traceability across HR processes.

Technologies and Libraries
Category	Libraries / Tools
Language	Python 3.11
Data Handling	pandas, openpyxl, json, os
Automation & Scheduling	schedule, datetime
Communication	smtplib, email, requests
AI / NLP	OpenAI API
Storage Integration	Google Drive API, PyDrive
Logging	Custom logger + standard logging module
Typical Use Cases

Candidate registration and validation automation.

Automatic email generation for HR notifications.

WhatsApp message dispatch for interviews or updates.

Report compilation from Excel templates.

AI-based analysis of candidate descriptions or resumes.

Execution Example

To execute a complete cycle:

python scheduler.py


This will:

Validate the configuration files (via validator.py).

Load job definitions from json_service.py.

Fetch candidate data from Excel sources.

Generate reports and send notifications.

Log results and upload artifacts via drive_connector.py.

Future Enhancements

Add SQL database integration (SQLite or SQL Server).

Develop a unified controller for service orchestration.

Implement a web dashboard for monitoring executions.

Extend the OpenAI engine for natural language classification and sentiment analysis.

Integrate Power Automate connectors for enterprise-level workflows.

Author

Developed and maintained by Osiris Jiménez
As part of the RefreshCode Technical Lab, focused on applied experimentation in automation, AI integration, and process orchestration.
