@echo off
REM ดับเบิลคลิกไฟล์นี้เพื่อตั้งค่าตัวรับกริ่งให้เปิดอัตโนมัติตอน login Windows
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-doorbell-pc.ps1"
