﻿Get-ChildItem -Path "Cert:\LocalMachine" -Recurse | Select FriendlyName,SerialNumber,SubjectName,Thumbprint,Issuer,Subject