# 🦴 OsteoSense (ऑस्टियोसेंस)
### AI-Powered Offline Screening Tool for Early-Stage Knee Osteoarthritis (OA)
**Smart India Hackathon 2026 | Problem Statement 26004 (Ministry of Development of North Eastern Region — MDoNER)**  
*Developed by Team TECHSTRIDE*

---

## 🎯 About the Project

**OsteoSense** is a 100% offline, AI-driven mobile screening application engineered to detect early-stage Knee Osteoarthritis (OA) in resource-constrained medical environments. 

In rural health camps across India's North East region, patients often lack access to orthopaedic specialists and X-ray imaging machines. **OsteoSense** empowers frontline health workers to film a patient walking for 10–15 seconds on a standard smartphone camera. The app extracts knee flexion trajectories frame-by-frame, measures biomechanical gait markers (Flexion Range of Motion, Left-Right Asymmetry, Cadence, Jerk), combines them with a standard 5-question **WOMAC-lite** symptom questionnaire, and produces a calibrated **Low / Moderate / High / Extreme** OA risk classification with actionable medical recommendations.

---

## 🌟 Why is this Project Important?

1. **Closing the Healthcare Gap in Rural & Remote Regions**:
   - In rural North East India and remote health camps, specialized diagnostic infrastructure (X-rays, MRI, orthopaedic doctors) is virtually non-existent.
   - OsteoSense provides immediate, clinical-grade triage screening right at the point of care.

2. **Early Detection Prevents Permanent Disability**:
   - Knee OA is often diagnosed late when joint degeneration is severe and irreversible. Early detection enables timely physiotherapy, lifestyle modification, and conservative management—averting costly joint replacement surgery.

3. **100% Offline Edge Computation**:
   - Rural health camps frequently operate with zero internet connectivity or cell service. OsteoSense performs all video pose tracking, trigonometric angle calculations, risk scoring algorithms, and patient record database persistence (SQLite) locally on-device without network calls.

4. **Bilingual Accessibility (English + Hindi)**:
   - Built-in localized UI language switching (English & Hindi string maps) tailored for regional health workers and rural patients.

---

## 📱 Why Porting to Flutter Matters

While early prototypes operated as Python/Streamlit scripts, this **Flutter mobile application** transforms the proof-of-concept into a production-ready mobile platform:

- **Cross-Platform On-Device Performance**: Runs natively on Android, iOS, Windows, and Web with native 60 FPS UI rendering.
- **Decoupled Data Architecture**: A clean `GaitFeatures` data abstraction allows seamless data input from video pose analysis or future **Bluetooth Low Energy (BLE)** knee-band IMU hardware sensors without touching the underlying scoring engine.
- **Local SQLite Patient Record Tracking**: Keeps historical screening logs on-device so health workers can track patient OA progression over subsequent visits.

---

## 🧠 Biomechanical Scoring Logic

OsteoSense combines two quantitative pillars into a composite 12-point risk score:

### 1. Gait Sub-Score (0–6 Points)
Derived from BlazePose joint angle signals ($180^\circ - \text{joint angle}$):
- **Flexion Range of Motion (ROM)**:
  - Worst ROM $< 20^\circ$: +3 points (Severely reduced)
  - Worst ROM $< 25^\circ$: +2 points (Moderately reduced)
  - Worst ROM $< 30^\circ$: +1 point (Mildly reduced)
- **Left-Right Asymmetry**:
  - Asymmetry $\ge 50\%$: +3 points (Severe)
  - Asymmetry $\ge 35\%$: +2 points (Marked)
  - Asymmetry $\ge 20\%$: +1 point (Mild)

### 2. Symptom Sub-Score (0–6 Points)
Derived from the 5-question WOMAC-lite Questionnaire (0–20 total):
- WOMAC $\ge 15$: +6 points (Severe pain & stiffness)
- WOMAC $\ge 10$: +4 points (Moderate-to-high symptoms)
- WOMAC $\ge 5$: +2 points (Mild symptoms)

### Composite Risk Classification
- **$\ge 8$ Points**: **Extreme Risk** $\rightarrow$ Urgent surgical consultation & mobility aid assessment.
- **$\ge 5$ Points**: **High Risk** $\rightarrow$ Orthopedic referral & imaging (X-ray / MRI).
- **$\ge 2$ Points**: **Moderate Risk** $\rightarrow$ Structured physiotherapy & contrast therapy.
- **$< 2$ Points**: **Low Risk** $\rightarrow$ Joint health maintenance & routine rescreening.

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                       # App entry point with SharedPreferences language persistence
├── translations.dart               # Offline English & Hindi translation maps (t(key, lang))
├── models/
│   ├── gait_features.dart         # Decoupled gait metric data model
│   └── patient_record.dart        # SQLite patient record schema
├── services/
│   ├── database_helper.dart       # Local SQLite storage (sqflite)
│   ├── scoring_service.dart       # Ported Python scoring rules & recommendations engine
│   └── gait_analysis_service.dart # Frame angle extraction, smoothing & step counter
├── widgets/
│   ├── language_toggle.dart       # English / Hindi dynamic toggle
│   ├── flexion_chart.dart         # Interactive knee flexion trajectory line chart
│   └── past_records_list.dart     # SQLite history accordion
└── screens/
    ├── patient_details_screen.dart    # Home & patient registration form
    ├── womac_questionnaire_screen.dart# WOMAC-lite symptom questionnaire
    ├── video_selection_screen.dart    # Video file picker & BLE sensor stub
    ├── processing_screen.dart         # Animated offline analysis progress
    └── results_screen.dart            # Risk banner, breakdown, chart, markers & auto-save
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- Dart SDK (v3.0.0 or higher)

### Installation & Execution

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/iniyazhikaaaki/osteosense.git
   cd osteosense
   ```

2. **Fetch Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Automated Unit Tests**:
   ```bash
   flutter test
   ```

4. **Launch Application**:
   - On Web Browser:
     ```bash
     flutter run -d chrome
     ```
   - On Windows Desktop:
     ```bash
     flutter run -d windows
     ```

---

## ⚠️ Disclaimer
*OsteoSense is designed strictly as a clinical screening aid and risk assessment tool. It does not replace formal radiological diagnosis or evaluation by a qualified orthopaedic physician.*
