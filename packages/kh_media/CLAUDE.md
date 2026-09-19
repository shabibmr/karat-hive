# kh_media

The whole image path from the picker to a `READY` media key, shared by KYC documents, request images and offer images.

## Pipeline

```
pick (image_picker)
  → convert to AVIF on-device (flutter_avif / libavif, web included)
  → persist in PendingUploadCache
  → POST /v1/media/upload-intent   (purpose, contentType, byteSize)
  → PUT bytes to the signed URL
  → POST complete
  → poll until the media is READY
```

`MediaUploader` owns the intent → PUT → complete → poll sequence; polling is bounded (`pollInterval`, `maxPolls`). `MediaUploadPurpose` carries the wire strings (`KYC_DOCUMENT`, `REQUEST_IMAGE`, `OFFER_IMAGE`) and is deliberately separate from `kh_domain`'s `MediaPurpose` — they are not interchangeable.

Images are **converted before upload, never after**. The backend receives AVIF.

`PendingUploadCache` keys converted bytes by a caller-supplied correlation id in the temp directory with a JSON manifest, so an interrupted upload retries without re-picking or re-converting. It survives app restarts and evicts on success — a caller that skips it makes a dropped connection cost the user the whole flow again.

## Testing

`ImageConverter` is an interface precisely so tests avoid the native libavif binding; inject the fake (the mobile app keeps one in `test/helpers/fake_image_converter.dart`) rather than converting real images.

Web and native diverge — the converter branches on `kIsWeb`, and only native writes the retry temp file. Changes here need checking on both.
