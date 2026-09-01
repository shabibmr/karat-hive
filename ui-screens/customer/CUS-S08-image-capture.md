# CUS-S08 · Image capture / gallery picker

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-007`, `FR-SYS-009` |

## Purpose

Attach photographic images to a Request (camera or gallery), with reorder, remove, and upload progress.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | From any create flow needing media |
| Exit | Back to create form with images attached |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Capture from camera | Action | — | — | Live capture |
| Pick from gallery | Action | — | multi-select | |
| Image slot list (1–5) | Display | — | thumbnails | Max 5 |
| Upload progress per image | System | — | percent / state | Retry on fail |
| Remove image | Action | — | — | Pre-publish |
| Reorder images | Input | — | drag/reorder | First = Request thumbnail |
| Thumbnail indicator | Display | — | “cover” on first | |
| Done / Confirm | Action | — | — | Return to form |

## Validation & rules

- Formats: JPEG, PNG, HEIC; max 10 MB before client compression.
- Client compress max edge 2048 px.
- EXIF (incl. GPS) stripped server-side before store/serve.
- Malware scan must be CLEAN before publish (`REQUEST_MEDIA`).

## Empty / error / edge states

- Failed upload with retry; format/size rejection.

## Related screens

CUS-S04…S07 · CUS-S09 · CUS-S10 (edit images if allowed)
