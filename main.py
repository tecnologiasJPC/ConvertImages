from pathlib import Path
from PIL import Image

# this script converts WebP, AVIF, and JFIF images to PNG format without modifying the content.
PROJECT_ROOT = Path(__file__).resolve().parent
INPUT_FOLDER = PROJECT_ROOT / "ImagesToConvert"
OUTPUT_FOLDER_WEBP = INPUT_FOLDER / "Converted"
FORMATS_WEBP = {".webp", ".avif", ".jfif"}  # formatos de conversion a PNG disponibles


def delete_webp_images(images: list[Path]):
    """Delete the source images that were passed for conversion."""
    deleted_count = 0
    for img_path in images:
        try:
            img_path.unlink()
            deleted_count += 1
        except Exception as exc:
            print(f"❌ Failed to delete {img_path.name}: {exc}")

    if deleted_count:
        print(f"  🗑️  Deleted {deleted_count} original image(s) from webp_images.")


def convert_webp_images(images: list[Path]):
    """Convierte imágenes WebP a PNG sin modificar el contenido."""
    if not images:
        print("⚠️  No images found.\n")
        return

    OUTPUT_FOLDER_WEBP.mkdir(parents=True, exist_ok=True)
    print(f"🔄  {len(images)} image(s) found for conversion:\n")

    for i, img_path in enumerate(images, start=1):
        output_path = OUTPUT_FOLDER_WEBP / f"{img_path.stem}.png"
        print(f"  [{i}/{len(images)}] {img_path.name} → {output_path.name}")

        with Image.open(img_path) as img:
            img.convert("RGBA").save(output_path, "PNG")

    print(f"\n  ✅ Saved in: {OUTPUT_FOLDER_WEBP.resolve()}\n")
    delete_webp_images(images)


def process_folder():

    if not INPUT_FOLDER.exists():
        print(f"❌ Folder does not exist: {INPUT_FOLDER.resolve()}")
        return

    all_files = list(INPUT_FOLDER.iterdir())

    webp_images = [p for p in all_files if p.suffix.lower() in FORMATS_WEBP]

    print("Images found:", webp_images)

    if not webp_images:
        print(f"⚠️  There are no images in the folder: {INPUT_FOLDER.resolve()}")
        return

    print(f"\n📂 Folder: {INPUT_FOLDER.resolve()}\n")

    convert_webp_images(webp_images)

    print("🎉 Conversion completed successfully! 🎉\n")

if __name__ == "__main__":
    print("Converting images to PNG format...\n")
    process_folder()
