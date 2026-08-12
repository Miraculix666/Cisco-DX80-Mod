AI DevOps Verification Manifest (Universal Enterprise Standard)

Zweck: Dieses Manifest dient als universelle Checkliste und System-Prompt für KI-Agenten und Entwickler. Jeder generierte Code, jedes Skript und jede Systemarchitektur MUSS vor der finalen Ausgabe zwingend durch diese 23 Analyse-Layer iteriert und gehärtet werden, um stabile, idempotente und produktionsreife Ergebnisse zu garantieren.

Phase 1: Core Dependencies & Lifecycles

1. Dependency-Tree Analysis (Abhängigkeits-Baum)

Sind alle versteckten Betriebssystem-Abhängigkeiten deklariert? (z.B. C++ Redistributables auf Windows, build-essential oder spezifische Codecs/Header auf Linux).

Werden native Paketmanager gezwungen, Interaktionen zu unterdrücken (z.B. --silent, -y)?

2. Process-Lock & Lifecycle Check

Greift das Skript auf Dateien zu (z.B. Binaries oder Datenbanken), die durch laufende Hintergrund-Services blockiert sein könnten?

Laufende Ziel-Prozesse müssen vor einem Update zwingend sicher beendet werden.

3. Sub-Process & Daemon Race-Conditions

Starten asynchrone Services in der korrekten Abhängigkeitsreihenfolge?

Sind Timeout-Werte (TimeoutStartSec) für Worst-Case-Szenarien (z.B. das Laden gigantischer Modelle in den RAM) ausreichend dimensioniert?

Phase 2: State, Storage & Resilienz

4. State-Drift & Kapazitäts-Analyse

Wurden Festplatten- oder RAM-Anforderungen vorab kalkuliert und geprüft?

Wird bei Versionskontrollsystemen (Git) ein sauberer Zustand erzwungen (z.B. git fetch --all && git reset --hard), um Merge-Konflikte durch lokale Artefakte zu vermeiden?

5. Idempotency & State-Corruption Check

Was passiert bei einem Abbruch in der Mitte des Skripts?

Werden korrupte oder halb heruntergeladene Dateien (Archive, Modelle) vor einem erneuten Ausführungsversuch zuverlässig erkannt und gelöscht?

6. Security Context Analysis

Werden Prozesse stumm durch Antiviren-Software (z.B. Windows Defender Deep-Scans) blockiert? (Ggf. Exclusions setzen).

Erben heruntergeladene Binaries Sicherheits-Flags (wie "Mark of the Web" unter Windows) und müssen explizit deblockiert werden?

7. Path-Traversal & Space-Path Resilienz

Zerbrechen Dateipfade, wenn Ordnernamen Leerzeichen enthalten? (Zwingende Nutzung von Quotes oder Array-Injektionen).

Werden Escape-Zeichen (z.B. Backslashes \ in Windows-Pfaden) korrekt verarbeitet, wenn sie an andere Sprachen (wie Python oder JSON) übergeben werden?

Phase 3: Architektur & Orchestrierung

8. CLI-Deprecation & Wrapper Avoidance

Setzt die Architektur auf fehleranfällige CLI-Wrapper oder veraltete Kommandozeilen-Tools?

Best Practice: Nutzung direkter nativer APIs oder SDK-Aufrufe (z.B. Python-Skripte statt reiner Shell-Befehle) für mehr Stabilität und besseres Error-Handling.

9. Identity Hijacking Protection

Überschreibt das Skript blindlings bestehende Ressourcen (z.B. Container-IDs, Ports, Verzeichnisse)?

Prüfung: Vor der Erstellung muss die Identität (z.B. Hostname, Projekt-Tag) einer existierenden Ressource verifiziert werden.

10. Idempotent State-Reconciliation Analysis

Vergleicht das Skript den Soll-Zustand mit dem Ist-Zustand, bevor Aktionen ausgeführt werden (Deklarativer Ansatz)? (z.B. Prüfen auf Datei-Existenz anstatt blind neu herunterzuladen).

11. Subprocess Environment & IPC Resilience

Werden Shell-Befehle, die aus höheren Sprachen (Python, Node.js) aufgerufen werden, mit striktem Error-Handling versehen (Erfassen von Exit-Codes, stdout und stderr)?

12. Orchestration-Language Segregation

Werden komplexe Logiken (z.B. das Generieren langer JSON/YAML-Konfigurationen oder Systemd-Services) fehleranfällig in Shell-Skripten (Bash EOF, Batch) erzwungen?

Best Practice: Auslagerung komplexer Orchestrierung in dafür geeignete Sprachen (Python, Ansible).

Phase 4: Netzwerke, Auth & Limits

13. Dependency Parity & Consistency Check

Sind Konfigurationen, installierte Agenten und Abhängigkeiten über verschiedene Ziel-Betriebssysteme (z.B. Client vs. Server) hinweg konsistent?

14. Network Port Binding & Collision Audit

Sind die genutzten Netzwerk-Ports kollisionsfrei?

Sind die Bindings sicherheitskonform (z.B. 127.0.0.1 für strikt lokale Dienste vs. 0.0.0.0 für Bridging im Container)?

15. Cross-Environment Variable Scope Check

Werden API-Keys und globale Base-URLs im korrekten Scope persistiert (z.B. .bashrc unter Linux oder System/User-Environment unter Windows)?

16. Continuous State Tracking (SSOT Verification)

Regel für KI-Agenten: Existiert ein Projekt-Tracker-Dokument (Single Source of Truth)? Bevor Code generiert oder überschrieben wird, muss diese SSOT gelesen werden, um Context-Loss und Halluzinationen zu verhindern.

17. Environment Limitation & OS Quirk Analysis

Berücksichtigt das Deployment betriebssystemspezifische Limits? (Beispiele: MAX_PATH Limit von 260 Zeichen in Windows anheben, erzwingen von IPv4 bei unsauberen IPv6-Routen).

18. Implicit Dependency & Hidden-Fetch Check

Laden Frameworks heimlich Daten im Hintergrund herunter (z.B. Caches, Embeddings)?

Prüfung: Caches müssen zwingend durch Umgebungsvariablen (wie HF_HOME) in vorhersehbare, überwachte Verzeichnisse umgeleitet werden, um ein Überlaufen der Root-Partition zu verhindern.

19. Graceful Degradation & Auth-Failure Handling

Stürzt die gesamte Pipeline ab, wenn ein einzelner Authentifizierungs-Token (z.B. für ein Gated-Repository) fehlt oder abgelaufen ist?

Best Practice: try-except Blöcke implementieren, die den Fehler loggen, den spezifischen Task überspringen, aber das Gesamtsystem erfolgreich hochfahren.

Phase 5: Hardware & Operations

20. Hardware Limits & OOM Simulation

Verhindert die Architektur Out-Of-Memory (OOM) Crashes?

Müssen Ressourcen limitiert oder priorisiert werden? (Nutzung von Swapping-Konzepten, Drosselung der CPU-Priorität via Nice oder IO-Scheduling, um das Host-System nicht einzufrieren).

21. Authentication Chain Verification

Werden sensible Tokens sicher und dynamisch abgefragt oder aus dem Environment geladen, anstatt sie im Code hart zu codieren? Werden sie sicher an Subprozesse vererbt?

22. Component Interoperability API-Check

Sprechen verschiedene Services (z.B. Frontend, Backend, AI-Orchestrator) fehlerfrei miteinander? Entsprechen die Endpunkte und Payloads den erwarteten Standards (z.B. OpenAI-kompatible REST APIs)?

23. Non-Destructive Configuration Audit

Oberste Regel für Updates: Existieren vom Nutzer anpassbare Konfigurationsdateien bereits?

Das Setup MUSS diese prüfen. Wenn sie existieren, dürfen sie nicht blind überschrieben werden. Das System muss den Schritt überspringen und den Nutzer darüber informieren, um manuelle Anpassungen zu schützen.